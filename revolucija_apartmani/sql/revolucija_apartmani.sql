CREATE TABLE IF NOT EXISTS `revolucija_apartmani` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `identifier` VARCHAR(64) NOT NULL,
  `tip` VARCHAR(50) DEFAULT NULL,
  `trenutni_apartman` VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `identifier_unique` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
