CREATE DATABASE IF NOT EXISTS `fiap-api` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `fiap-api`;

-- Criação da tabela account
CREATE TABLE IF NOT EXISTS `account` (
  `account_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `cgc` VARCHAR(14) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `password` VARCHAR(255) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `cgc_unique` (`cgc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Criação da tabela product
CREATE TABLE IF NOT EXISTS `product` (
  `product_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `unitprice` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`product_id`),
  INDEX `idx_product_name` (`name`)  -- Índice para busca por nome do produto
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Criação da tabela order
CREATE TABLE IF NOT EXISTS `order` (
  `order_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `status` CHAR(1) NOT NULL DEFAULT 'O' COMMENT 'O-Open, P-Production, F-Finished, D-Delivered',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `account_id` BIGINT(20) NOT NULL,
  `total_amount` DECIMAL(10,2) NOT NULL,
  `closedAt` DATETIME DEFAULT NULL,
  `paymentstatus` CHAR(1) NOT NULL DEFAULT 'O' COMMENT 'O-Open, P-Paid',
  PRIMARY KEY (`order_id`),
  KEY `order_account_FK` (`account_id`),
  CONSTRAINT `order_account_FK` FOREIGN KEY (`account_id`) REFERENCES `account` (`account_id`),
  INDEX `idx_order_status_created` (`status`, `created_at`)  -- Índice para filtro/ordenação por status e data
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Criação da tabela orderdet
CREATE TABLE IF NOT EXISTS `orderdet` (
  `orderdet_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT(20) NOT NULL,
  `product_id` BIGINT(20) NOT NULL,
  `qtdproduct` INT(11) NOT NULL,
  PRIMARY KEY (`orderdet_id`),
  KEY `orderdet_order_FK` (`order_id`),
  KEY `orderdet_product_FK` (`product_id`),
  CONSTRAINT `orderdet_order_FK` FOREIGN KEY (`order_id`) REFERENCES `order` (`order_id`),
  CONSTRAINT `orderdet_product_FK` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Criação da tabela payment
CREATE TABLE IF NOT EXISTS `payment` (
  `payment_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `order_id` BIGINT(20) NOT NULL,
  `totaldiscount` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `amount` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `nettotal` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`payment_id`),
  KEY `payment_order_FK` (`order_id`),
  CONSTRAINT `payment_order_FK` FOREIGN KEY (`order_id`) REFERENCES `order` (`order_id`),
  INDEX `idx_payment_created_nettotal` (`created_at`, `nettotal`) -- Índice para filtro/ordenação por data e valor total
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Criação da tabela paymentdet
CREATE TABLE IF NOT EXISTS `paymentdet` (
  `paymentdet_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `payment_id` BIGINT(20) NOT NULL,
  `sign` INT(11) NOT NULL DEFAULT '1',
  `type` CHAR(1) NOT NULL,
  `payment_method` VARCHAR(50) DEFAULT NULL,
  `amount` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`paymentdet_id`),
  KEY `paymentdet_payment_FK` (`payment_id`),
  CONSTRAINT `paymentdet_payment_FK` FOREIGN KEY (`payment_id`) REFERENCES `payment` (`payment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Criação das tabelas de log
CREATE TABLE IF NOT EXISTS `account_log` (
  `account_log_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `action` CHAR(1) NOT NULL COMMENT 'I-Insert, U-Update, D-Delete',
  `account_id` BIGINT(20) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`account_log_id`),
  KEY `account_log_account_FK` (`account_id`),
  CONSTRAINT `account_log_account_FK` FOREIGN KEY (`account_id`) REFERENCES `account` (`account_id`),
  INDEX `idx_account_log_account_id` (`account_id`)  -- Índice para busca por ID da conta
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `product_log` (
  `product_log_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `action` CHAR(1) NOT NULL COMMENT 'I-Insert, U-Update, D-Delete',
  `product_id` BIGINT(20) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_log_id`),
  KEY `product_log_product_FK` (`product_id`),
  CONSTRAINT `product_log_product_FK` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
  INDEX `idx_product_log_product_id` (`product_id`)  -- Índice para busca por ID do produto
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `order_log` (
  `order_log_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `action` CHAR(1) NOT NULL COMMENT 'I-Insert, U-Update, D-Delete',
  `order_id` BIGINT(20) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_log_id`),
  KEY `order_log_order_FK` (`order_id`),
  CONSTRAINT `order_log_order_FK` FOREIGN KEY (`order_id`) REFERENCES `order` (`order_id`),
  INDEX `idx_order_log_order_id` (`order_id`)  -- Índice para busca por ID do pedido
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;


DELIMITER $$
CREATE TRIGGER `account_after_insert` AFTER INSERT ON `account`
FOR EACH ROW
BEGIN
  CALL log_account_change(NEW.`account_id`, 'I');
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `account_after_update` AFTER UPDATE ON `account`
FOR EACH ROW
BEGIN
  CALL log_account_change(OLD.`account_id`, 'U');
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `account_after_delete` AFTER DELETE ON `account`
FOR EACH ROW
BEGIN
  CALL log_account_change(OLD.`account_id`, 'D');
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `log_account_change`(
  IN `account_id` BIGINT,
  IN `action_type` CHAR(1)
)
BEGIN
  INSERT INTO `account_log` (`account_id`, `action`) 
  VALUES (`account_id`, `action_type`);
END $$
DELIMITER ;

-- Triggers e Stored Procedures para Product

DELIMITER $$
CREATE TRIGGER `product_after_insert` AFTER INSERT ON `product`
FOR EACH ROW
BEGIN
  CALL log_product_change(NEW.`product_id`, 'I');
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `product_after_update` AFTER UPDATE ON `product`
FOR EACH ROW
BEGIN
  CALL log_product_change(OLD.`product_id`, 'U');
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `product_after_delete` AFTER DELETE ON `product`
FOR EACH ROW
BEGIN
  CALL log_product_change(OLD.`product_id`, 'D');
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `log_product_change`(
  IN `product_id` BIGINT,
  IN `action_type` CHAR(1)
)
BEGIN
  INSERT INTO `product_log` (`product_id`, `action`) 
  VALUES (`product_id`, `action_type`);
END $$
DELIMITER ;

-- Triggers e Stored Procedures para Order

DELIMITER $$
CREATE TRIGGER `order_after_insert` AFTER INSERT ON `order`
FOR EACH ROW
BEGIN
  CALL log_order_change(NEW.`order_id`, 'I');
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `order_after_update` AFTER UPDATE ON `order`
FOR EACH ROW
BEGIN
  CALL log_order_change(OLD.`order_id`, 'U');
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `order_after_delete` AFTER DELETE ON `order`
FOR EACH ROW
BEGIN
  CALL log_order_change(OLD.`order_id`, 'D');
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `log_order_change`(
  IN `order_id` BIGINT,
  IN `action_type` CHAR(1)
)
BEGIN
  INSERT INTO `order_log` (`order_id`, `action`) 
  VALUES (`order_id`, `action_type`);
END $$
DELIMITER ;