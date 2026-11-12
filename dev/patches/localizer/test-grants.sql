-- One-time test-database grants (dev/TESTING.md > "Control and accounts schemas").
-- Apply as MariaDB root: Get-Content dev/patches/localizer/test-grants.sql | docker exec -i ri-test-mariadb mariadb -u root
-- (never inline the command in PowerShell — it mangles the backticks).
--
-- NOTE for Windows hosts running the suite against a Dockerized MariaDB: PDO connects
-- from the host, which the container sees as the NAT gateway address, not 'localhost'.
-- If provisioning tests skip/fail on that, apply the same grants to
-- 'ri_test_provisioner'@'%' instead of @'localhost' (host-only convenience, never ship it).

GRANT ALL PRIVILEGES ON `test\_reliefinventory%`.* TO 'reliefinventory'@'localhost';
CREATE USER IF NOT EXISTS 'ri_test_provisioner'@'localhost' IDENTIFIED BY 'ri_test_provisioner';
GRANT CREATE USER ON *.* TO 'ri_test_provisioner'@'localhost';
GRANT ALL PRIVILEGES ON `test\_reliefinventory%`.* TO 'ri_test_provisioner'@'localhost' WITH GRANT OPTION;
