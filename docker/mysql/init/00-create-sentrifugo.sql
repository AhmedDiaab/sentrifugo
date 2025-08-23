-- Runs only on first container start (empty data dir)

-- 1) Create app database
CREATE DATABASE IF NOT EXISTS `sentrifugo`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 2) Create app user (use a strong password in production)
CREATE USER IF NOT EXISTS 'sentrifugo'@'%' IDENTIFIED BY 'sentrifugo';

-- 3) Grant full privileges on the app DB to the app user (testing/dev)
GRANT ALL PRIVILEGES ON `sentrifugo`.* TO 'sentrifugo'@'%';


-- 4) Persist grants
FLUSH PRIVILEGES;

-- OPTIONAL (use config instead of SUPER-requiring statements):
-- Prefer setting this in my.cnf:
--   [mysqld]
--   log_bin_trust_function_creators=ON
--
-- If you absolutely must set at runtime and have SUPER, you could use:
--   -- SET PERSIST log_bin_trust_function_creators = ON;
--   -- or: SET GLOBAL log_bin_trust_function_creators = ON; FLUSH PRIVILEGES;
