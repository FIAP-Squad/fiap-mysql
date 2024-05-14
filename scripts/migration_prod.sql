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
