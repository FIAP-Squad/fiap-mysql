CREATE DATABASE IF NOT EXISTS `fiap-api` DEFAULT CHARACTER SET latin1;
USE `fiap-api`;
CREATE TABLE IF NOT EXISTS `account` (
  `idaccount` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `cgc` varchar(14) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(20) DEFAULT NULL,
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idaccount`),
  UNIQUE KEY `cgc_unique` (`cgc`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `log` (
  `idlog` bigint(20) NOT NULL AUTO_INCREMENT,
  `action` char(1) NOT NULL COMMENT 'I-Insert, U-Update, D-Disable',
  `account` bigint(20) DEFAULT NULL,
  `type` bigint(20) DEFAULT NULL,
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idlog`),
  KEY `IDaccount_FK` (`account`),
  CONSTRAINT `IDaccount_FK` FOREIGN KEY (`account`) REFERENCES `account` (`idaccount`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `product` (
  `idproduct` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `unitprice` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`idproduct`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `order` (
  `idorder` bigint(20) NOT NULL AUTO_INCREMENT,
  `status` char(1) NOT NULL DEFAULT 'O' COMMENT 'O-Open, P-Production, F-Finished, D-Delivered',
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idaccount` bigint(20) NOT NULL,
  `totalorder` decimal(10,0) NOT NULL,
  `closedAt` datetime DEFAULT NULL,
  `paymentstatus` char(1) NOT NULL DEFAULT 'O' COMMENT 'O-Open, P-Paid',
  PRIMARY KEY (`idorder`),
  KEY `order_account_FK` (`idaccount`),
  CONSTRAINT `order_account_FK` FOREIGN KEY (`idaccount`) REFERENCES `account` (`idaccount`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `orderdet` (
  `idorderdet` bigint(20) NOT NULL AUTO_INCREMENT,
  `idorder` bigint(20) NOT NULL,
  `idproduct` bigint(20) NOT NULL,
  `qtdproduct` int(11) NOT NULL,
  `unitval` decimal(10,2) NOT NULL DEFAULT '0.00',
  `totalval` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`idorderdet`),
  KEY `orderdet_order_FK` (`idorder`),
  KEY `orderdet_product_FK` (`idproduct`),
  CONSTRAINT `orderdet_order_FK` FOREIGN KEY (`idorder`) REFERENCES `order` (`idorder`),
  CONSTRAINT `orderdet_product_FK` FOREIGN KEY (`idproduct`) REFERENCES `product` (`idproduct`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `payment` (
  `idpayment` bigint(20) NOT NULL AUTO_INCREMENT,
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idorder` bigint(20) NOT NULL,
  `totaldiscount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `nettotal` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`idpayment`),
  KEY `payment_order_FK` (`idorder`),
  CONSTRAINT `payment_order_FK` FOREIGN KEY (`idorder`) REFERENCES `order` (`idorder`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `paymentdet` (
  `idpaymentdet` bigint(20) NOT NULL AUTO_INCREMENT,
  `idpayment` bigint(20) NOT NULL,
  `sign` int(11) NOT NULL DEFAULT '1',
  `type` char(1) NOT NULL,
  `transaction` varchar(100) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`idpaymentdet`),
  KEY `paymentdet_payment_FK` (`idpayment`),
  CONSTRAINT `paymentdet_payment_FK` FOREIGN KEY (`idpayment`) REFERENCES `payment` (`idpayment`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TRIGGER IF EXISTS prevent_log_update;
DELIMITER $$
CREATE TRIGGER prevent_log_update
BEFORE UPDATE
ON log FOR EACH ROW
BEGIN
  CALL raise_error('Não é permitido atualizar registros na tabela log.');
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS prevent_log_delete;
DELIMITER $$
CREATE TRIGGER prevent_log_delete
BEFORE DELETE
ON log FOR EACH ROW
BEGIN
  CALL raise_error('Não é permitido deleter registros na tabela log.');
END$$
DELIMITER ;