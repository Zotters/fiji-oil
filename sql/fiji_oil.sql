CREATE TABLE IF NOT EXISTS `fiji_oil_reputation` (
  `identifier` VARCHAR(64) NOT NULL,
  `company_id` VARCHAR(32) NOT NULL,
  `reputation` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`identifier`, `company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `fiji_oil_player_contracts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `identifier` VARCHAR(64) NOT NULL,
  `company_id` VARCHAR(32) NOT NULL,
  `contract_id` VARCHAR(64) NOT NULL,
  `progress` INT NOT NULL DEFAULT 0,
  `status` ENUM('active','complete') NOT NULL DEFAULT 'active',
  `accepted_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_fiji_contracts_identifier_status` (`identifier`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `fiji_oil_supply_orders` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `identifier` VARCHAR(64) NOT NULL,
  `company_id` VARCHAR(32) NOT NULL,
  `item` VARCHAR(64) NOT NULL,
  `quantity` INT NOT NULL,
  `dropoff_hq` VARCHAR(32) NOT NULL,
  `ordered_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ready_at` TIMESTAMP NOT NULL,
  `status` ENUM('pending','ready','collected') NOT NULL DEFAULT 'pending',
  PRIMARY KEY (`id`),
  KEY `idx_fiji_orders_identifier_status` (`identifier`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
