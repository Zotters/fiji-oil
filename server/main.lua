-- Bootstraps the DB schema (safety net for server owners who forgot to
-- import sql/fiji_oil.sql manually) and confirms oxmysql is ready.

local function EnsureSchema()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `fiji_oil_reputation` (
          `identifier` VARCHAR(64) NOT NULL,
          `company_id` VARCHAR(32) NOT NULL,
          `reputation` INT NOT NULL DEFAULT 0,
          PRIMARY KEY (`identifier`, `company_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])

    MySQL.query.await([[
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
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])

    MySQL.query.await([[
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
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
end

CreateThread(function()
    local ok, err = pcall(EnsureSchema)
    if not ok then
        print('^1[fiji-oil]^0 Failed to verify/create database schema: ' .. tostring(err))
        print('^1[fiji-oil]^0 Import sql/fiji_oil.sql manually and restart the resource.')
    end
end)
