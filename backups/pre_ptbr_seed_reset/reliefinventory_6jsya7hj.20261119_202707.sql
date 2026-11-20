/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.20-11.8.9-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: reliefinventory_6jsya7hj
-- ------------------------------------------------------
-- Server version	11.8.9-MariaDB-ubu2404-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `activity_log`
--

DROP TABLE IF EXISTS `activity_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `person_id` bigint(20) unsigned DEFAULT NULL,
  `driver_id` bigint(20) unsigned DEFAULT NULL,
  `training_team` tinyint(3) unsigned DEFAULT NULL,
  `station` tinyint(3) unsigned DEFAULT NULL,
  `action` varchar(60) NOT NULL,
  `subject_type` varchar(60) DEFAULT NULL,
  `subject_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `activity_log_person_id_created_at_index` (`person_id`,`created_at`),
  KEY `activity_log_training_team_created_at_index` (`training_team`,`created_at`),
  KEY `activity_log_created_at_index` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_log`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `activity_log` WRITE;
/*!40000 ALTER TABLE `activity_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `activity_log` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `backup_schedule`
--

DROP TABLE IF EXISTS `backup_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `backup_schedule` (
  `id` tinyint(3) unsigned NOT NULL,
  `hourly_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `hourly_keep` smallint(5) unsigned NOT NULL DEFAULT 24,
  `daily_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `daily_hour` tinyint(3) unsigned NOT NULL DEFAULT 2,
  `daily_keep` smallint(5) unsigned NOT NULL DEFAULT 14,
  `daily_with_files` tinyint(1) NOT NULL DEFAULT 0,
  `weekly_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `weekly_dow` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `weekly_keep` smallint(5) unsigned NOT NULL DEFAULT 8,
  `weekly_with_files` tinyint(1) NOT NULL DEFAULT 0,
  `monthly_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `monthly_keep` smallint(5) unsigned NOT NULL DEFAULT 12,
  `monthly_with_files` tinyint(1) NOT NULL DEFAULT 0,
  `last_run_at` timestamp NULL DEFAULT NULL,
  `last_status` varchar(20) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backup_schedule`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `backup_schedule` WRITE;
/*!40000 ALTER TABLE `backup_schedule` DISABLE KEYS */;
INSERT INTO `backup_schedule` VALUES
(1,0,24,1,2,14,0,0,0,8,0,0,12,0,'2026-11-19 23:10:03','complete','2026-11-17 22:18:50','2026-11-19 23:10:03');
/*!40000 ALTER TABLE `backup_schedule` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `backups`
--

DROP TABLE IF EXISTS `backups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `backups` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `status` varchar(20) NOT NULL DEFAULT 'queued',
  `scope` varchar(20) NOT NULL DEFAULT 'database',
  `tiers` varchar(60) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `size_bytes` bigint(20) unsigned DEFAULT NULL,
  `file_count` int(10) unsigned DEFAULT NULL,
  `progress` varchar(255) DEFAULT NULL,
  `error` text DEFAULT NULL,
  `requested_by` bigint(20) unsigned DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `finished_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backups`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `backups` WRITE;
/*!40000 ALTER TABLE `backups` DISABLE KEYS */;
INSERT INTO `backups` VALUES
(1,'complete','database','daily','relief-backup-20261117-221928-database-1.zip',45682,2,NULL,NULL,NULL,'2026-11-17 22:19:28','2026-11-17 22:19:30',NULL,'2026-11-17 22:19:28','2026-11-17 22:19:30'),
(2,'complete','database','daily','relief-backup-20261118-020006-database-2.zip',46163,2,NULL,NULL,NULL,'2026-11-18 02:00:06','2026-11-18 02:00:08',NULL,'2026-11-18 02:00:06','2026-11-18 02:00:08'),
(3,'complete','database','daily','relief-backup-20261119-230958-database-3.zip',46428,2,NULL,NULL,NULL,'2026-11-19 23:09:58','2026-11-19 23:10:03',NULL,'2026-11-19 23:09:58','2026-11-19 23:10:03');
/*!40000 ALTER TABLE `backups` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `banned_emails`
--

DROP TABLE IF EXISTS `banned_emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `banned_emails` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pattern` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `banned_emails_pattern_unique` (`pattern`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `banned_emails`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `banned_emails` WRITE;
/*!40000 ALTER TABLE `banned_emails` DISABLE KEYS */;
/*!40000 ALTER TABLE `banned_emails` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `banner_dismissals`
--

DROP TABLE IF EXISTS `banner_dismissals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `banner_dismissals` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `person_id` bigint(20) unsigned NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `dismissed_at` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `banner_dismissals_person_id_version_unique` (`person_id`,`version`),
  CONSTRAINT `banner_dismissals_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `banner_dismissals`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `banner_dismissals` WRITE;
/*!40000 ALTER TABLE `banner_dismissals` DISABLE KEYS */;
/*!40000 ALTER TABLE `banner_dismissals` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `banner_settings`
--

DROP TABLE IF EXISTS `banner_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `banner_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `type` enum('feedback','maintenance','message') DEFAULT NULL,
  `message` text DEFAULT NULL,
  `version` int(10) unsigned NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `banner_settings`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `banner_settings` WRITE;
/*!40000 ALTER TABLE `banner_settings` DISABLE KEYS */;
INSERT INTO `banner_settings` VALUES
(1,NULL,NULL,1,'2026-11-17 22:18:05','2026-11-17 22:18:05');
/*!40000 ALTER TABLE `banner_settings` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `building_closeouts`
--

DROP TABLE IF EXISTS `building_closeouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `building_closeouts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `closed_at` timestamp NOT NULL,
  `closed_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `building_closeouts_closed_by_person_id_foreign` (`closed_by_person_id`),
  CONSTRAINT `building_closeouts_closed_by_person_id_foreign` FOREIGN KEY (`closed_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `building_closeouts`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `building_closeouts` WRITE;
/*!40000 ALTER TABLE `building_closeouts` DISABLE KEYS */;
/*!40000 ALTER TABLE `building_closeouts` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `building_roll_call_confirmations`
--

DROP TABLE IF EXISTS `building_roll_call_confirmations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `building_roll_call_confirmations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `building_roll_call_id` bigint(20) unsigned NOT NULL,
  `volunteer_sign_in_id` bigint(20) unsigned NOT NULL,
  `confirmed_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `confirmed_at` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roll_call_confirmation_unique` (`building_roll_call_id`,`volunteer_sign_in_id`),
  KEY `building_roll_call_confirmations_volunteer_sign_in_id_foreign` (`volunteer_sign_in_id`),
  KEY `building_roll_call_confirmations_confirmed_by_person_id_foreign` (`confirmed_by_person_id`),
  CONSTRAINT `building_roll_call_confirmations_building_roll_call_id_foreign` FOREIGN KEY (`building_roll_call_id`) REFERENCES `building_roll_calls` (`id`) ON DELETE CASCADE,
  CONSTRAINT `building_roll_call_confirmations_confirmed_by_person_id_foreign` FOREIGN KEY (`confirmed_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `building_roll_call_confirmations_volunteer_sign_in_id_foreign` FOREIGN KEY (`volunteer_sign_in_id`) REFERENCES `volunteer_sign_ins` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `building_roll_call_confirmations`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `building_roll_call_confirmations` WRITE;
/*!40000 ALTER TABLE `building_roll_call_confirmations` DISABLE KEYS */;
/*!40000 ALTER TABLE `building_roll_call_confirmations` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `building_roll_call_snapshot`
--

DROP TABLE IF EXISTS `building_roll_call_snapshot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `building_roll_call_snapshot` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `building_roll_call_id` bigint(20) unsigned NOT NULL,
  `volunteer_sign_in_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roll_call_snapshot_unique` (`building_roll_call_id`,`volunteer_sign_in_id`),
  KEY `building_roll_call_snapshot_volunteer_sign_in_id_foreign` (`volunteer_sign_in_id`),
  CONSTRAINT `building_roll_call_snapshot_building_roll_call_id_foreign` FOREIGN KEY (`building_roll_call_id`) REFERENCES `building_roll_calls` (`id`) ON DELETE CASCADE,
  CONSTRAINT `building_roll_call_snapshot_volunteer_sign_in_id_foreign` FOREIGN KEY (`volunteer_sign_in_id`) REFERENCES `volunteer_sign_ins` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `building_roll_call_snapshot`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `building_roll_call_snapshot` WRITE;
/*!40000 ALTER TABLE `building_roll_call_snapshot` DISABLE KEYS */;
/*!40000 ALTER TABLE `building_roll_call_snapshot` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `building_roll_calls`
--

DROP TABLE IF EXISTS `building_roll_calls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `building_roll_calls` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `started_at` timestamp NOT NULL,
  `started_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `closed_at` timestamp NULL DEFAULT NULL,
  `closed_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `building_roll_calls_started_by_person_id_foreign` (`started_by_person_id`),
  KEY `building_roll_calls_closed_by_person_id_foreign` (`closed_by_person_id`),
  CONSTRAINT `building_roll_calls_closed_by_person_id_foreign` FOREIGN KEY (`closed_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `building_roll_calls_started_by_person_id_foreign` FOREIGN KEY (`started_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `building_roll_calls`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `building_roll_calls` WRITE;
/*!40000 ALTER TABLE `building_roll_calls` DISABLE KEYS */;
/*!40000 ALTER TABLE `building_roll_calls` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES
('laravel_cache_6jsya7hj_6jsya7hj_421762700a2c10da200dfdb9fe1032c83dd620c2','i:1;',1794954912),
('laravel_cache_6jsya7hj_6jsya7hj_421762700a2c10da200dfdb9fe1032c83dd620c2:timer','i:1794954912;',1794954912);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `carton_codes`
--

DROP TABLE IF EXISTS `carton_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `carton_codes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(14) NOT NULL,
  `item_id` bigint(20) unsigned NOT NULL,
  `qty_per_carton` int(10) unsigned NOT NULL,
  `inner_packs` int(10) unsigned DEFAULT NULL,
  `items_per_pack` int(10) unsigned DEFAULT NULL,
  `person_id_user` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `carton_codes_code_unique` (`code`),
  KEY `carton_codes_item_id_foreign` (`item_id`),
  CONSTRAINT `carton_codes_item_id_foreign` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carton_codes`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `carton_codes` WRITE;
/*!40000 ALTER TABLE `carton_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `carton_codes` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `block_start` int(10) unsigned DEFAULT NULL,
  `block_end` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES
(1,'Animal products & durable medical','2026-11-17 22:18:51','2026-11-17 22:18:51',0,99),
(2,'Food & water','2026-11-17 22:18:51','2026-11-17 22:18:51',100,199),
(3,'Personal care, pharmacy & safety','2026-11-17 22:18:51','2026-11-17 22:18:51',200,299),
(4,'Paper & disposables','2026-11-17 22:18:51','2026-11-17 22:18:51',300,399),
(5,'Baby & child','2026-11-17 22:18:51','2026-11-17 22:18:51',400,499),
(6,'Bedding & linens','2026-11-17 22:18:51','2026-11-17 22:18:51',500,599),
(7,'Kitchen & dining','2026-11-17 22:18:51','2026-11-17 22:18:51',600,699),
(8,'Cleaning & household','2026-11-17 22:18:51','2026-11-17 22:18:51',700,799),
(9,'Clothing & accessories','2026-11-17 22:18:51','2026-11-17 22:18:51',800,899),
(10,'Outdoor, emergency & tools','2026-11-17 22:18:51','2026-11-17 22:18:51',900,999),
(11,'Appliances, large (team-lift)','2026-11-17 22:18:51','2026-11-17 22:18:51',1000,1399),
(12,'Appliances, small (countertop)','2026-11-17 22:18:51','2026-11-17 22:18:51',1500,1699),
(13,'Building supplies','2026-11-17 22:18:51','2026-11-17 22:18:51',2000,2999),
(14,'Furniture','2026-11-17 22:18:51','2026-11-17 22:18:51',3000,3999),
(15,'Holy Bible','2026-11-17 22:18:51','2026-11-17 22:18:51',7777,7777);
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `container_types`
--

DROP TABLE IF EXISTS `container_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `container_types` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `container_types_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `container_types`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `container_types` WRITE;
/*!40000 ALTER TABLE `container_types` DISABLE KEYS */;
INSERT INTO `container_types` VALUES
(1,'Box','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(2,'Bin','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(3,'Bag','2026-11-17 22:18:59','2026-11-17 22:18:59');
/*!40000 ALTER TABLE `container_types` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `containers`
--

DROP TABLE IF EXISTS `containers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `containers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `container_type_id` bigint(20) unsigned NOT NULL,
  `pallet_id` bigint(20) unsigned DEFAULT NULL,
  `location_id` bigint(20) unsigned DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `containers_container_type_id_foreign` (`container_type_id`),
  KEY `containers_pallet_id_foreign` (`pallet_id`),
  KEY `containers_location_id_foreign` (`location_id`),
  CONSTRAINT `containers_container_type_id_foreign` FOREIGN KEY (`container_type_id`) REFERENCES `container_types` (`id`),
  CONSTRAINT `containers_location_id_foreign` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL,
  CONSTRAINT `containers_pallet_id_foreign` FOREIGN KEY (`pallet_id`) REFERENCES `pallets` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `containers`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `containers` WRITE;
/*!40000 ALTER TABLE `containers` DISABLE KEYS */;
/*!40000 ALTER TABLE `containers` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `counties`
--

DROP TABLE IF EXISTS `counties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `counties` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `county` varchar(255) NOT NULL,
  `state` varchar(2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `counties_county_state_unique` (`county`,`state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `counties`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `counties` WRITE;
/*!40000 ALTER TABLE `counties` DISABLE KEYS */;
/*!40000 ALTER TABLE `counties` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `design_poll_ideas`
--

DROP TABLE IF EXISTS `design_poll_ideas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `design_poll_ideas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `poll_slug` varchar(60) NOT NULL,
  `idea` text NOT NULL,
  `person_id` bigint(20) unsigned DEFAULT NULL,
  `voter_name` varchar(100) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `ok_to_contact` tinyint(1) NOT NULL DEFAULT 0,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `design_poll_ideas_person_id_foreign` (`person_id`),
  KEY `design_poll_ideas_poll_slug_created_at_index` (`poll_slug`,`created_at`),
  CONSTRAINT `design_poll_ideas_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `design_poll_ideas`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `design_poll_ideas` WRITE;
/*!40000 ALTER TABLE `design_poll_ideas` DISABLE KEYS */;
/*!40000 ALTER TABLE `design_poll_ideas` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `design_poll_reactions`
--

DROP TABLE IF EXISTS `design_poll_reactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `design_poll_reactions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `design_poll_vote_id` bigint(20) unsigned NOT NULL,
  `option_key` varchar(60) NOT NULL,
  `reaction` varchar(10) NOT NULL,
  `comment` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `design_poll_reactions_design_poll_vote_id_option_key_unique` (`design_poll_vote_id`,`option_key`),
  KEY `design_poll_reactions_option_key_reaction_index` (`option_key`,`reaction`),
  CONSTRAINT `design_poll_reactions_design_poll_vote_id_foreign` FOREIGN KEY (`design_poll_vote_id`) REFERENCES `design_poll_votes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `design_poll_reactions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `design_poll_reactions` WRITE;
/*!40000 ALTER TABLE `design_poll_reactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `design_poll_reactions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `design_poll_votes`
--

DROP TABLE IF EXISTS `design_poll_votes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `design_poll_votes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `poll_slug` varchar(60) NOT NULL,
  `voter_token_hash` varchar(64) NOT NULL,
  `person_id` bigint(20) unsigned DEFAULT NULL,
  `voter_name` varchar(100) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `design_poll_votes_poll_slug_voter_token_hash_unique` (`poll_slug`,`voter_token_hash`),
  KEY `design_poll_votes_person_id_foreign` (`person_id`),
  CONSTRAINT `design_poll_votes_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `design_poll_votes`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `design_poll_votes` WRITE;
/*!40000 ALTER TABLE `design_poll_votes` DISABLE KEYS */;
/*!40000 ALTER TABLE `design_poll_votes` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `design_polls`
--

DROP TABLE IF EXISTS `design_polls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `design_polls` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `slug` varchar(60) NOT NULL,
  `is_open` tinyint(1) NOT NULL DEFAULT 0,
  `opened_at` timestamp NULL DEFAULT NULL,
  `closed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `design_polls_slug_unique` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `design_polls`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `design_polls` WRITE;
/*!40000 ALTER TABLE `design_polls` DISABLE KEYS */;
INSERT INTO `design_polls` VALUES
(1,'delivery-days',0,NULL,NULL,'2026-11-17 22:18:47','2026-11-17 22:18:47');
/*!40000 ALTER TABLE `design_polls` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `device_releases`
--

DROP TABLE IF EXISTS `device_releases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `device_releases` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `kind` enum('app','os','print_client') NOT NULL,
  `version` varchar(255) NOT NULL,
  `architecture` varchar(255) NOT NULL,
  `release_type` enum('full','hotfix','disk_image','vm_image') NOT NULL DEFAULT 'full',
  `required_base_version` varchar(255) DEFAULT NULL,
  `sha256` varchar(64) NOT NULL,
  `storage_path` varchar(255) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `size_bytes` bigint(20) unsigned NOT NULL DEFAULT 0,
  `download_token` varchar(64) NOT NULL,
  `channels` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`channels`)),
  `notes` text DEFAULT NULL,
  `uploaded_by` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `device_releases_download_token_unique` (`download_token`),
  KEY `device_releases_uploaded_by_foreign` (`uploaded_by`),
  CONSTRAINT `device_releases_uploaded_by_foreign` FOREIGN KEY (`uploaded_by`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_releases`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `device_releases` WRITE;
/*!40000 ALTER TABLE `device_releases` DISABLE KEYS */;
/*!40000 ALTER TABLE `device_releases` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `device_session_tickets`
--

DROP TABLE IF EXISTS `device_session_tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `device_session_tickets` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `managed_device_id` bigint(20) unsigned NOT NULL,
  `ticket_hash` varchar(64) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `device_session_tickets_ticket_hash_unique` (`ticket_hash`),
  KEY `device_session_tickets_managed_device_id_foreign` (`managed_device_id`),
  CONSTRAINT `device_session_tickets_managed_device_id_foreign` FOREIGN KEY (`managed_device_id`) REFERENCES `managed_devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_session_tickets`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `device_session_tickets` WRITE;
/*!40000 ALTER TABLE `device_session_tickets` DISABLE KEYS */;
/*!40000 ALTER TABLE `device_session_tickets` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `device_trust_grants`
--

DROP TABLE IF EXISTS `device_trust_grants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `device_trust_grants` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `trusted_device_id` bigint(20) unsigned NOT NULL,
  `person_id` bigint(20) unsigned NOT NULL,
  `granted_at` timestamp NOT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `device_trust_grants_trusted_device_id_person_id_unique` (`trusted_device_id`,`person_id`),
  KEY `device_trust_grants_person_id_foreign` (`person_id`),
  CONSTRAINT `device_trust_grants_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE,
  CONSTRAINT `device_trust_grants_trusted_device_id_foreign` FOREIGN KEY (`trusted_device_id`) REFERENCES `trusted_devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_trust_grants`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `device_trust_grants` WRITE;
/*!40000 ALTER TABLE `device_trust_grants` DISABLE KEYS */;
/*!40000 ALTER TABLE `device_trust_grants` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `donation_offer_status_log`
--

DROP TABLE IF EXISTS `donation_offer_status_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `donation_offer_status_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `donation_offer_id` bigint(20) unsigned NOT NULL,
  `from_status` varchar(255) DEFAULT NULL,
  `to_status` varchar(255) NOT NULL,
  `changed_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `contact_method` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `donation_offer_status_log_donation_offer_id_foreign` (`donation_offer_id`),
  KEY `donation_offer_status_log_changed_by_person_id_foreign` (`changed_by_person_id`),
  CONSTRAINT `donation_offer_status_log_changed_by_person_id_foreign` FOREIGN KEY (`changed_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `donation_offer_status_log_donation_offer_id_foreign` FOREIGN KEY (`donation_offer_id`) REFERENCES `donation_offers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `donation_offer_status_log`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `donation_offer_status_log` WRITE;
/*!40000 ALTER TABLE `donation_offer_status_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `donation_offer_status_log` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `donation_offers`
--

DROP TABLE IF EXISTS `donation_offers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `donation_offers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `person_id` bigint(20) unsigned NOT NULL,
  `contact_person_id` bigint(20) unsigned DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'offered',
  `eta_start` date DEFAULT NULL,
  `eta_end` date DEFAULT NULL,
  `transit_notes` text DEFAULT NULL,
  `refused_reason` text DEFAULT NULL,
  `diverted_to` text DEFAULT NULL,
  `cancelled_reason` text DEFAULT NULL,
  `description` text DEFAULT NULL,
  `donation_id` bigint(20) unsigned DEFAULT NULL,
  `entered_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `donation_offers_person_id_foreign` (`person_id`),
  KEY `donation_offers_contact_person_id_foreign` (`contact_person_id`),
  KEY `donation_offers_donation_id_foreign` (`donation_id`),
  KEY `donation_offers_entered_by_person_id_foreign` (`entered_by_person_id`),
  CONSTRAINT `donation_offers_contact_person_id_foreign` FOREIGN KEY (`contact_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `donation_offers_donation_id_foreign` FOREIGN KEY (`donation_id`) REFERENCES `orderdonations` (`id`) ON DELETE SET NULL,
  CONSTRAINT `donation_offers_entered_by_person_id_foreign` FOREIGN KEY (`entered_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `donation_offers_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `donation_offers`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `donation_offers` WRITE;
/*!40000 ALTER TABLE `donation_offers` DISABLE KEYS */;
/*!40000 ALTER TABLE `donation_offers` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `donor_standing_log`
--

DROP TABLE IF EXISTS `donor_standing_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `donor_standing_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `person_id` bigint(20) unsigned NOT NULL,
  `from_standing` varchar(20) NOT NULL,
  `to_standing` varchar(20) NOT NULL,
  `note` text DEFAULT NULL,
  `person_id_user` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `donor_standing_log_person_id_index` (`person_id`),
  CONSTRAINT `donor_standing_log_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `donor_standing_log`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `donor_standing_log` WRITE;
/*!40000 ALTER TABLE `donor_standing_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `donor_standing_log` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `drivers`
--

DROP TABLE IF EXISTS `drivers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `drivers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `carrier` varchar(255) DEFAULT NULL,
  `pin_hash` varchar(255) DEFAULT NULL,
  `person_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `training_team` tinyint(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `drivers_person_id_foreign` (`person_id`),
  CONSTRAINT `drivers_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `drivers`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `drivers` WRITE;
/*!40000 ALTER TABLE `drivers` DISABLE KEYS */;
/*!40000 ALTER TABLE `drivers` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `federation_identities`
--

DROP TABLE IF EXISTS `federation_identities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `federation_identities` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned DEFAULT NULL,
  `uuid` uuid NOT NULL,
  `name` varchar(255) NOT NULL,
  `base_url` varchar(255) DEFAULT NULL,
  `public_key` varchar(64) NOT NULL,
  `private_key` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `federation_identities_uuid_unique` (`uuid`),
  UNIQUE KEY `federation_identities_tenant_id_unique` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `federation_identities`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `federation_identities` WRITE;
/*!40000 ALTER TABLE `federation_identities` DISABLE KEYS */;
/*!40000 ALTER TABLE `federation_identities` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `feedback_aggregation_settings`
--

DROP TABLE IF EXISTS `feedback_aggregation_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback_aggregation_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `instance_role` enum('remote','central') NOT NULL DEFAULT 'remote',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `feedback_trust_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `feedback_aggregation_settings_feedback_trust_id_foreign` (`feedback_trust_id`),
  CONSTRAINT `feedback_aggregation_settings_feedback_trust_id_foreign` FOREIGN KEY (`feedback_trust_id`) REFERENCES `trusts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedback_aggregation_settings`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `feedback_aggregation_settings` WRITE;
/*!40000 ALTER TABLE `feedback_aggregation_settings` DISABLE KEYS */;
INSERT INTO `feedback_aggregation_settings` VALUES
(1,'remote','2026-11-17 22:18:38','2026-11-17 22:18:38',NULL);
/*!40000 ALTER TABLE `feedback_aggregation_settings` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `feedback_report_status_logs`
--

DROP TABLE IF EXISTS `feedback_report_status_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback_report_status_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `feedback_report_id` bigint(20) unsigned NOT NULL,
  `status` enum('new','seen','in_development','review','resolved') DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `person_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `feedback_report_status_logs_feedback_report_id_foreign` (`feedback_report_id`),
  KEY `feedback_report_status_logs_person_id_foreign` (`person_id`),
  CONSTRAINT `feedback_report_status_logs_feedback_report_id_foreign` FOREIGN KEY (`feedback_report_id`) REFERENCES `feedback_reports` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feedback_report_status_logs_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedback_report_status_logs`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `feedback_report_status_logs` WRITE;
/*!40000 ALTER TABLE `feedback_report_status_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `feedback_report_status_logs` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `feedback_reports`
--

DROP TABLE IF EXISTS `feedback_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback_reports` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` uuid DEFAULT NULL,
  `instance_identifier` varchar(255) DEFAULT NULL,
  `warehouse_id` varchar(8) DEFAULT NULL,
  `person_id` bigint(20) unsigned DEFAULT NULL,
  `reporter_name` varchar(255) DEFAULT NULL,
  `reporter_email` varchar(255) DEFAULT NULL,
  `type` enum('bug','feature') NOT NULL,
  `urgent` tinyint(1) NOT NULL DEFAULT 0,
  `flagged_for_review` tinyint(1) NOT NULL DEFAULT 0,
  `flagged_reason` varchar(255) DEFAULT NULL,
  `status` enum('new','seen','in_development','review','resolved') DEFAULT 'new',
  `status_changed_at` timestamp NULL DEFAULT NULL,
  `submitted_at` timestamp NULL DEFAULT NULL,
  `message` text NOT NULL,
  `page_url` varchar(2048) NOT NULL,
  `page_title` varchar(255) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `screenshot_path` varchar(255) DEFAULT NULL,
  `commit_hash` varchar(16) DEFAULT NULL,
  `app_version` varchar(64) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `trust_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `feedback_reports_instance_identifier_uuid_unique` (`instance_identifier`,`uuid`),
  KEY `feedback_reports_person_id_foreign` (`person_id`),
  KEY `feedback_reports_trust_id_foreign` (`trust_id`),
  CONSTRAINT `feedback_reports_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`),
  CONSTRAINT `feedback_reports_trust_id_foreign` FOREIGN KEY (`trust_id`) REFERENCES `trusts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedback_reports`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `feedback_reports` WRITE;
/*!40000 ALTER TABLE `feedback_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `feedback_reports` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `firmware_settings`
--

DROP TABLE IF EXISTS `firmware_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `firmware_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `source_url` varchar(2048) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `firmware_settings`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `firmware_settings` WRITE;
/*!40000 ALTER TABLE `firmware_settings` DISABLE KEYS */;
INSERT INTO `firmware_settings` VALUES
(1,NULL,'2026-11-17 22:18:42','2026-11-17 22:18:42');
/*!40000 ALTER TABLE `firmware_settings` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `form_answers`
--

DROP TABLE IF EXISTS `form_answers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `form_answers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `form_submission_id` bigint(20) unsigned NOT NULL,
  `form_question_id` bigint(20) unsigned DEFAULT NULL,
  `question_label_snapshot` varchar(255) NOT NULL,
  `question_type_snapshot` varchar(255) NOT NULL,
  `value_text` text DEFAULT NULL,
  `value_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`value_json`)),
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_answers_form_submission_id_foreign` (`form_submission_id`),
  KEY `form_answers_form_question_id_foreign` (`form_question_id`),
  CONSTRAINT `form_answers_form_question_id_foreign` FOREIGN KEY (`form_question_id`) REFERENCES `form_questions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `form_answers_form_submission_id_foreign` FOREIGN KEY (`form_submission_id`) REFERENCES `form_submissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_answers`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `form_answers` WRITE;
/*!40000 ALTER TABLE `form_answers` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_answers` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `form_question_presets`
--

DROP TABLE IF EXISTS `form_question_presets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `form_question_presets` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `label` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL DEFAULT 'other',
  `type` varchar(255) NOT NULL,
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`options`)),
  `help_text` text DEFAULT NULL,
  `target_field` varchar(255) DEFAULT NULL,
  `order` int(10) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `form_question_presets_key_unique` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_question_presets`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `form_question_presets` WRITE;
/*!40000 ALTER TABLE `form_question_presets` DISABLE KEYS */;
INSERT INTO `form_question_presets` VALUES
(1,'org_name','Organization Name','basic_info','short_text',NULL,NULL,'organization',10,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(2,'address','Street Address','basic_info','short_text',NULL,NULL,'address',20,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(3,'city','City','basic_info','short_text',NULL,NULL,'city',30,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(4,'state','State','basic_info','short_text',NULL,NULL,'state',40,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(5,'zip','Zip Code','basic_info','short_text',NULL,NULL,'zip',50,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(6,'phone','Phone Number','basic_info','short_text',NULL,NULL,'phone',60,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(7,'email','Email Address','basic_info','short_text',NULL,NULL,'email',70,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(8,'website','Website','basic_info','short_text',NULL,NULL,NULL,80,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(9,'nonprofit_status','501(c)(3) Status','basic_info','single_choice','[\"Yes\",\"No\",\"Applied\"]',NULL,NULL,90,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(10,'reference','Reference Name or Organization','basic_info','short_text',NULL,NULL,NULL,100,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(11,'services_offered','Services Offered','other','long_text',NULL,NULL,NULL,110,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(12,'locations_served','Locations Served','other','long_text',NULL,NULL,NULL,120,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(13,'counties_served','Counties Served','other','long_text',NULL,NULL,NULL,130,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(14,'families_per_week','Estimated Number of Families Served per Week','other','number',NULL,'A rough estimate is fine.',NULL,140,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(15,'established','When Was Your Organization Established?','other','short_text',NULL,NULL,NULL,150,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(16,'vision','Organization Vision or Goal','other','long_text',NULL,NULL,NULL,160,'2026-11-17 22:18:34','2026-11-17 22:18:34'),
(17,'other_info','Other Important Information','other','long_text',NULL,NULL,NULL,170,'2026-11-17 22:18:34','2026-11-17 22:18:34');
/*!40000 ALTER TABLE `form_question_presets` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `form_questions`
--

DROP TABLE IF EXISTS `form_questions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `form_questions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `form_id` bigint(20) unsigned NOT NULL,
  `order` int(10) unsigned NOT NULL DEFAULT 0,
  `label` varchar(255) NOT NULL,
  `help_text` text DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`options`)),
  `required` tinyint(1) NOT NULL DEFAULT 0,
  `preset_key` varchar(255) DEFAULT NULL,
  `target_field` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_questions_form_id_order_index` (`form_id`,`order`),
  CONSTRAINT `form_questions_form_id_foreign` FOREIGN KEY (`form_id`) REFERENCES `forms` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_questions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `form_questions` WRITE;
/*!40000 ALTER TABLE `form_questions` DISABLE KEYS */;
INSERT INTO `form_questions` VALUES
(1,1,0,'Organization Name',NULL,'short_text',NULL,1,'org_name','organization','2026-11-17 22:18:36','2026-11-17 22:18:36'),
(2,1,1,'Street Address',NULL,'short_text',NULL,1,'address','address','2026-11-17 22:18:36','2026-11-17 22:18:36'),
(3,1,2,'City',NULL,'short_text',NULL,0,'city','city','2026-11-17 22:18:36','2026-11-17 22:18:36'),
(4,1,3,'State',NULL,'short_text',NULL,0,'state','state','2026-11-17 22:18:36','2026-11-17 22:18:36'),
(5,1,4,'Zip Code',NULL,'short_text',NULL,0,'zip','zip','2026-11-17 22:18:36','2026-11-17 22:18:36'),
(6,1,5,'Phone Number',NULL,'short_text',NULL,1,'phone','phone','2026-11-17 22:18:36','2026-11-17 22:18:36'),
(7,1,6,'Email Address',NULL,'short_text',NULL,1,'email','email','2026-11-17 22:18:36','2026-11-17 22:18:36'),
(8,1,7,'Website',NULL,'short_text',NULL,0,'website',NULL,'2026-11-17 22:18:36','2026-11-17 22:18:36'),
(9,1,8,'501(c)(3) Status',NULL,'single_choice','[\"Yes\",\"No\",\"Applied\"]',0,'nonprofit_status',NULL,'2026-11-17 22:18:36','2026-11-17 22:18:36'),
(10,1,9,'Reference Name or Organization',NULL,'short_text',NULL,0,'reference',NULL,'2026-11-17 22:18:36','2026-11-17 22:18:36'),
(11,1,10,'Services Offered',NULL,'long_text',NULL,0,'services_offered',NULL,'2026-11-17 22:18:36','2026-11-17 22:18:36'),
(12,1,11,'Locations Served',NULL,'long_text',NULL,0,'locations_served',NULL,'2026-11-17 22:18:36','2026-11-17 22:18:36'),
(13,1,12,'Counties Served',NULL,'long_text',NULL,0,'counties_served',NULL,'2026-11-17 22:18:36','2026-11-17 22:18:36'),
(14,1,13,'Estimated Number of Families Served per Week','A rough estimate is fine.','number',NULL,0,'families_per_week',NULL,'2026-11-17 22:18:36','2026-11-17 22:18:36'),
(15,1,14,'When Was Your Organization Established?',NULL,'short_text',NULL,0,'established',NULL,'2026-11-17 22:18:36','2026-11-17 22:18:36'),
(16,1,15,'Organization Vision or Goal',NULL,'long_text',NULL,0,'vision',NULL,'2026-11-17 22:18:36','2026-11-17 22:18:36'),
(17,1,16,'Other Important Information',NULL,'long_text',NULL,0,'other_info',NULL,'2026-11-17 22:18:36','2026-11-17 22:18:36');
/*!40000 ALTER TABLE `form_questions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `form_submission_status_log`
--

DROP TABLE IF EXISTS `form_submission_status_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `form_submission_status_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `form_submission_id` bigint(20) unsigned NOT NULL,
  `from_status` varchar(255) DEFAULT NULL,
  `to_status` varchar(255) DEFAULT NULL,
  `changed_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_submission_status_log_form_submission_id_foreign` (`form_submission_id`),
  KEY `form_submission_status_log_changed_by_person_id_foreign` (`changed_by_person_id`),
  CONSTRAINT `form_submission_status_log_changed_by_person_id_foreign` FOREIGN KEY (`changed_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `form_submission_status_log_form_submission_id_foreign` FOREIGN KEY (`form_submission_id`) REFERENCES `form_submissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_submission_status_log`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `form_submission_status_log` WRITE;
/*!40000 ALTER TABLE `form_submission_status_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_submission_status_log` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `form_submissions`
--

DROP TABLE IF EXISTS `form_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `form_submissions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `form_id` bigint(20) unsigned NOT NULL,
  `approval_status` varchar(255) DEFAULT NULL,
  `reviewed_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `submitted_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `submitter_name` varchar(255) DEFAULT NULL,
  `submitter_email` varchar(255) DEFAULT NULL,
  `submitter_phone` varchar(255) DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `linked_person_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_submissions_form_id_foreign` (`form_id`),
  KEY `form_submissions_reviewed_by_person_id_foreign` (`reviewed_by_person_id`),
  KEY `form_submissions_submitted_by_person_id_foreign` (`submitted_by_person_id`),
  KEY `form_submissions_linked_person_id_foreign` (`linked_person_id`),
  CONSTRAINT `form_submissions_form_id_foreign` FOREIGN KEY (`form_id`) REFERENCES `forms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `form_submissions_linked_person_id_foreign` FOREIGN KEY (`linked_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `form_submissions_reviewed_by_person_id_foreign` FOREIGN KEY (`reviewed_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `form_submissions_submitted_by_person_id_foreign` FOREIGN KEY (`submitted_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_submissions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `form_submissions` WRITE;
/*!40000 ALTER TABLE `form_submissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_submissions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `forms`
--

DROP TABLE IF EXISTS `forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `forms` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `intro_text` text DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'draft',
  `access_mode` varchar(255) NOT NULL DEFAULT 'staff_only',
  `requires_approval` tinyint(1) NOT NULL DEFAULT 0,
  `on_approval_action` varchar(255) NOT NULL DEFAULT 'none',
  `notify_person_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`notify_person_ids`)),
  `notify_emails` text DEFAULT NULL,
  `created_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `forms_slug_unique` (`slug`),
  KEY `forms_created_by_person_id_foreign` (`created_by_person_id`),
  CONSTRAINT `forms_created_by_person_id_foreign` FOREIGN KEY (`created_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forms`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `forms` WRITE;
/*!40000 ALTER TABLE `forms` DISABLE KEYS */;
INSERT INTO `forms` VALUES
(1,'Partner Agency Intake','partner-agency-intake','Thank you for your interest in partnering with our warehouse. This form collects the information we need to evaluate a new partner agency application. Please fill it out as completely as you can — an estimate is fine where noted.','active','both',1,'create_or_link_partner',NULL,NULL,NULL,'2026-11-17 22:18:36','2026-11-17 22:18:36');
/*!40000 ALTER TABLE `forms` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `import_batch_rows`
--

DROP TABLE IF EXISTS `import_batch_rows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `import_batch_rows` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `import_batch_id` bigint(20) unsigned NOT NULL,
  `row_number` int(10) unsigned NOT NULL,
  `source_key` varchar(255) DEFAULT NULL,
  `outcome` enum('created','updated','skipped','error') DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `raw_row` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`raw_row`)),
  `mapped_entity_type` varchar(255) DEFAULT NULL,
  `mapped_entity_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `import_batch_rows_import_batch_id_outcome_index` (`import_batch_id`,`outcome`),
  CONSTRAINT `import_batch_rows_import_batch_id_foreign` FOREIGN KEY (`import_batch_id`) REFERENCES `import_batches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `import_batch_rows`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `import_batch_rows` WRITE;
/*!40000 ALTER TABLE `import_batch_rows` DISABLE KEYS */;
/*!40000 ALTER TABLE `import_batch_rows` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `import_batches`
--

DROP TABLE IF EXISTS `import_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `import_batches` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `source` varchar(255) NOT NULL,
  `file_type` varchar(255) NOT NULL,
  `original_filename` varchar(255) NOT NULL,
  `stored_path` varchar(255) NOT NULL,
  `status` enum('previewed','committing','completed','failed') NOT NULL DEFAULT 'previewed',
  `summary` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`summary`)),
  `created_by` bigint(20) unsigned DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `import_batches_created_by_foreign` (`created_by`),
  CONSTRAINT `import_batches_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `import_batches`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `import_batches` WRITE;
/*!40000 ALTER TABLE `import_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `import_batches` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `item_ledgers`
--

DROP TABLE IF EXISTS `item_ledgers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `item_ledgers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `orderdonation_id` bigint(20) unsigned NOT NULL,
  `item_id` bigint(20) unsigned NOT NULL,
  `pallet_id` bigint(20) unsigned DEFAULT NULL,
  `stock_pallet_id` bigint(20) unsigned DEFAULT NULL,
  `order_line_id` bigint(20) unsigned DEFAULT NULL,
  `qty_added` int(11) NOT NULL DEFAULT 0,
  `qty_subtracted` int(11) NOT NULL DEFAULT 0,
  `disposition` enum('usable','outdated','trashed','diverted') NOT NULL DEFAULT 'usable',
  `item_condition` varchar(10) DEFAULT NULL,
  `expires_on` date DEFAULT NULL,
  `person_id_user` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `item_ledgers_orderdonation_id_foreign` (`orderdonation_id`),
  KEY `item_ledgers_item_id_foreign` (`item_id`),
  KEY `item_ledgers_pallet_id_foreign` (`pallet_id`),
  KEY `item_ledgers_order_line_id_foreign` (`order_line_id`),
  KEY `item_ledgers_person_id_user_foreign` (`person_id_user`),
  KEY `item_ledgers_stock_pallet_id_foreign` (`stock_pallet_id`),
  CONSTRAINT `item_ledgers_item_id_foreign` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`),
  CONSTRAINT `item_ledgers_order_line_id_foreign` FOREIGN KEY (`order_line_id`) REFERENCES `orderlines` (`id`) ON DELETE SET NULL,
  CONSTRAINT `item_ledgers_orderdonation_id_foreign` FOREIGN KEY (`orderdonation_id`) REFERENCES `orderdonations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `item_ledgers_pallet_id_foreign` FOREIGN KEY (`pallet_id`) REFERENCES `pallets` (`id`) ON DELETE SET NULL,
  CONSTRAINT `item_ledgers_person_id_user_foreign` FOREIGN KEY (`person_id_user`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `item_ledgers_stock_pallet_id_foreign` FOREIGN KEY (`stock_pallet_id`) REFERENCES `pallets` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_ledgers`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `item_ledgers` WRITE;
/*!40000 ALTER TABLE `item_ledgers` DISABLE KEYS */;
/*!40000 ALTER TABLE `item_ledgers` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `itemtype_id` bigint(20) unsigned DEFAULT NULL,
  `packagetypes_id` bigint(20) unsigned NOT NULL,
  `pluscode` varchar(4) DEFAULT NULL,
  `size` decimal(8,2) DEFAULT NULL,
  `case_qty` int(11) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `description` text DEFAULT NULL,
  `upc` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `items_upc_unique` (`upc`),
  KEY `items_itemtype_id_foreign` (`itemtype_id`),
  KEY `items_packagetypes_id_foreign` (`packagetypes_id`),
  CONSTRAINT `items_itemtype_id_foreign` FOREIGN KEY (`itemtype_id`) REFERENCES `itemtypes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `items_packagetypes_id_foreign` FOREIGN KEY (`packagetypes_id`) REFERENCES `packagetypes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=457 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `items`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `items` WRITE;
/*!40000 ALTER TABLE `items` DISABLE KEYS */;
INSERT INTO `items` VALUES
(1,1,3,'0000',1.00,1,1,'Bird food GENERIC ITEM','200000010003','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(2,2,3,'0000',1.00,1,1,'Cat food, dry GENERIC ITEM','200000020019','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(3,3,2,'0000',1.00,1,1,'Cat food, wet (cans/pouches) GENERIC ITEM','200000020026','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(4,4,3,'0000',1.00,1,1,'Cat litter GENERIC ITEM','200000022006','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(5,5,2,'0000',1.00,1,1,'Cat litter scoop GENERIC ITEM','200000024000','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(6,6,2,'0000',1.00,1,1,'Cat care GENERIC ITEM','200000025007','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(7,7,5,'0000',1.00,1,1,'Cat litter box / tray GENERIC ITEM','200000026004','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(8,8,3,'0000',1.00,1,1,'Dog food, dry GENERIC ITEM','200000030018','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(9,9,2,'0000',1.00,1,1,'Dog food, wet (cans/pouches) GENERIC ITEM','200000030025','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(10,10,3,'0000',1.00,1,1,'Dog bones GENERIC ITEM','200000032005','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(11,11,5,'0000',1.00,1,1,'Pet food / water bowl GENERIC ITEM','200000033002','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(12,12,2,'0000',1.00,1,1,'Dog care GENERIC ITEM','200000034009','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(13,13,3,'0000',1.00,1,1,'Horse feed GENERIC ITEM','200000042011','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(14,14,2,'0000',1.00,1,1,'Collars, pet GENERIC ITEM','200000052003','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(15,15,2,'0000',1.00,1,1,'Leashes, dog/cat GENERIC ITEM','200000054007','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(16,16,5,'0000',1.00,1,1,'Kennels, dog/cat GENERIC ITEM','200000056001','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(17,17,2,'0000',1.00,1,1,'Pet food, misc (hamster, bunny, etc.) GENERIC ITEM','200000060008','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(18,18,2,'0000',1.00,1,1,'Pet supplies, misc GENERIC ITEM','200000061005','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(19,19,5,'0000',1.00,1,1,'Pet gate / playpen GENERIC ITEM','200000070007','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(20,20,5,'0000',1.00,1,1,'Wheelchairs GENERIC ITEM','200000081003','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(21,21,5,'0000',1.00,1,1,'Walkers GENERIC ITEM','200000082000','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(22,22,5,'0000',1.00,1,1,'Crutches / cane GENERIC ITEM','200000083007','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(23,23,5,'0000',1.00,1,1,'Bath chair GENERIC ITEM','200000084004','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(24,24,5,'0000',1.00,1,1,'Commode GENERIC ITEM','200000085001','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(25,25,2,'0000',1.00,1,1,'Canned food, mixed GENERIC ITEM','200000101008','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(26,26,2,'0000',1.00,1,1,'MRE (meals ready to eat) GENERIC ITEM','200000102005','2026-11-17 22:18:51','2026-11-17 22:18:51'),
(27,27,2,'0000',1.00,1,1,'Meal kits (not MREs) GENERIC ITEM','200000104009','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(28,28,2,'0000',1.00,1,1,'Mac & cheese GENERIC ITEM','200000105006','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(29,29,2,'0000',1.00,1,1,'Canned fruit GENERIC ITEM','200000110000','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(30,30,2,'0000',1.00,1,1,'Canned vegetables GENERIC ITEM','200000112004','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(31,31,2,'0000',1.00,1,1,'Canned beans GENERIC ITEM','200000114008','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(32,32,2,'0000',1.00,1,1,'Canned beans, #10 / gallon (institutional) GENERIC ITEM','200000114909','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(33,33,2,'0000',1.00,1,1,'Canned meats GENERIC ITEM','200000116002','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(34,34,2,'0000',1.00,1,1,'Canned pasta GENERIC ITEM','200000118006','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(35,35,2,'0000',1.00,1,1,'Canned soup GENERIC ITEM','200000120009','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(36,36,2,'0000',1.00,1,1,'Sauce / gravy GENERIC ITEM','200000122003','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(37,37,2,'0000',1.00,1,1,'Canned tomatoes GENERIC ITEM','200000123000','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(38,38,2,'0000',1.00,1,1,'Dried boxed food GENERIC ITEM','200000130008','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(39,39,2,'0000',1.00,1,1,'Cereals GENERIC ITEM','200000132002','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(40,40,2,'0000',1.00,1,1,'Dry pasta GENERIC ITEM','200000134006','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(41,41,2,'0000',1.00,1,1,'Dry beans GENERIC ITEM','200000136000','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(42,42,2,'0000',1.00,1,1,'Rice GENERIC ITEM','200000138004','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(43,43,2,'0000',1.00,1,1,'Peanut butter GENERIC ITEM','200000140007','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(44,44,2,'0000',1.00,1,1,'PB & jelly, mixed GENERIC ITEM','200000141004','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(45,45,2,'0000',1.00,1,1,'Jam / jelly GENERIC ITEM','200000142001','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(46,46,2,'0000',1.00,1,1,'Snacks, any kind GENERIC ITEM','200000144005','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(47,47,2,'0000',1.00,1,1,'Snacks, savory, any GENERIC ITEM','200000144104','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(48,48,2,'0000',1.00,1,1,'Chips GENERIC ITEM','200000144111','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(49,49,2,'0000',1.00,1,1,'Crackers GENERIC ITEM','200000144128','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(50,50,2,'0000',1.00,1,1,'Snacks, sweet, any GENERIC ITEM','200000144203','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(51,51,2,'0000',1.00,1,1,'Fruit cups GENERIC ITEM','200000144210','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(52,52,2,'0000',1.00,1,1,'Snack bars GENERIC ITEM','200000144227','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(53,53,2,'0000',1.00,1,1,'Salad dressing GENERIC ITEM','200000150006','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(54,54,2,'0000',1.00,1,1,'Vinegar GENERIC ITEM','200000151003','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(55,55,2,'0000',1.00,1,1,'Oil / shortening GENERIC ITEM','200000152000','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(56,56,2,'0000',1.00,1,1,'Flour GENERIC ITEM','200000153007','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(57,57,2,'0000',1.00,1,1,'Sugar GENERIC ITEM','200000154004','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(58,58,2,'0000',1.00,1,1,'Baking, misc GENERIC ITEM','200000155001','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(59,59,2,'0000',1.00,1,1,'Condiments GENERIC ITEM','200000156008','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(60,60,2,'0000',1.00,1,1,'Seasonings GENERIC ITEM','200000158002','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(61,61,2,'0000',1.00,1,1,'Mixed boxes, nonperishable GENERIC ITEM','200000159009','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(62,62,2,'0000',1.00,1,1,'Juices GENERIC ITEM','200000160005','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(63,63,2,'0000',1.00,1,1,'Coconut water GENERIC ITEM','200000161002','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(64,64,2,'0000',1.00,1,1,'Coffee GENERIC ITEM','200000162009','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(65,65,2,'0000',1.00,1,1,'Creamer GENERIC ITEM','200000163006','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(66,66,2,'0000',1.00,1,1,'Tea GENERIC ITEM','200000164003','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(67,67,2,'0000',1.00,1,1,'Rehydration drinks GENERIC ITEM','200000166007','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(68,68,2,'0000',1.00,1,1,'Supplement drink powders GENERIC ITEM','200000168018','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(69,69,2,'0000',1.00,1,1,'Supplement gummies GENERIC ITEM','200000168025','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(70,70,2,'0000',1.00,1,1,'Sparkling drinks GENERIC ITEM','200000169008','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(71,71,2,'0000',1.00,1,1,'Milk, canned / shelf-stable GENERIC ITEM','200000170004','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(72,72,2,'0000',1.00,1,1,'Milk, flavored / chocolate GENERIC ITEM','200000171001','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(73,73,2,'0000',1.00,1,1,'Milk, powdered GENERIC ITEM','200000172008','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(74,74,2,'0000',1.00,1,1,'Protein drinks GENERIC ITEM','200000174002','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(75,75,2,'0000',1.00,1,1,'Water GENERIC ITEM','200000180003','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(76,76,2,'0000',1.00,1,1,'Water, flavored GENERIC ITEM','200000181000','2026-11-17 22:18:52','2026-11-17 22:18:52'),
(77,77,2,'0000',1.00,1,1,'Produce / perishable GENERIC ITEM','200000190002','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(78,78,5,'0000',1.00,1,1,'Hygiene kits (bathroom items only) GENERIC ITEM','200000200008','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(79,79,2,'0000',1.00,1,1,'Personal care, misc GENERIC ITEM','200000201005','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(80,80,2,'0000',1.00,1,1,'Toothbrushes GENERIC ITEM','200000202002','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(81,81,2,'0000',1.00,1,1,'Toothpaste GENERIC ITEM','200000203009','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(82,82,2,'0000',1.00,1,1,'Mouthwash GENERIC ITEM','200000204006','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(83,83,2,'0000',1.00,1,1,'Soap / body wash, mixed GENERIC ITEM','200000206000','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(84,84,2,'0000',1.00,1,1,'Bar soap GENERIC ITEM','200000206017','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(85,85,2,'0000',1.00,1,1,'Body wash GENERIC ITEM','200000206024','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(86,86,2,'0000',1.00,1,1,'Liquid hand soap, refill GENERIC ITEM','200000206031','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(87,87,2,'0000',1.00,1,1,'Liquid hand soap, pump dispenser GENERIC ITEM','200000206048','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(88,88,2,'0000',1.00,1,1,'Floor-stand soap dispenser GENERIC ITEM','200000206901','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(89,89,2,'0000',1.00,1,1,'Shampoo & conditioner, mixed GENERIC ITEM','200000210007','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(90,90,2,'0000',1.00,1,1,'Shampoo GENERIC ITEM','200000210014','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(91,91,2,'0000',1.00,1,1,'Conditioner GENERIC ITEM','200000210021','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(92,92,2,'0000',1.00,1,1,'Comb, brush GENERIC ITEM','200000212001','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(93,93,2,'0000',1.00,1,1,'Grooming GENERIC ITEM','200000214005','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(94,94,2,'0000',1.00,1,1,'Deodorant GENERIC ITEM','200000216009','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(95,95,2,'0000',1.00,1,1,'Shavers, shaving cream GENERIC ITEM','200000218003','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(96,96,2,'0000',1.00,1,1,'Feminine care products GENERIC ITEM','200000220006','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(97,97,2,'0000',1.00,1,1,'Male hygiene GENERIC ITEM','200000221003','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(98,98,2,'0000',1.00,1,1,'Lotions, powder GENERIC ITEM','200000222000','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(99,99,2,'0000',1.00,1,1,'Personal wipes GENERIC ITEM','200000224004','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(100,100,6,'0000',1.00,1,1,'Personal wipes, mixed gaylord GENERIC ITEM','200000224998','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(101,101,2,'0000',1.00,1,1,'Sanitizer GENERIC ITEM','200000226008','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(102,102,2,'0000',1.00,1,1,'Denture products GENERIC ITEM','200000230005','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(103,103,2,'0000',1.00,1,1,'Eye care GENERIC ITEM','200000232009','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(104,104,2,'0000',1.00,1,1,'Sunglasses GENERIC ITEM','200000240004','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(105,105,2,'0000',1.00,1,1,'Personal care kit (beyond bathroom items) GENERIC ITEM','200000241001','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(106,106,2,'0000',1.00,1,1,'Sun block GENERIC ITEM','200000242008','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(107,107,2,'0000',1.00,1,1,'First aid kit GENERIC ITEM','200000250003','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(108,108,2,'0000',1.00,1,1,'First aid supplies GENERIC ITEM','200000252007','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(109,109,2,'0000',1.00,1,1,'Rehydration salts GENERIC ITEM','200000253004','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(110,110,2,'0000',1.00,1,1,'Gloves, disposable GENERIC ITEM','200000254001','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(111,111,2,'0000',1.00,1,1,'Protective suits GENERIC ITEM','200000258009','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(112,112,2,'0000',1.00,1,1,'OTC drugs, adult GENERIC ITEM','200000263003','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(113,113,2,'0000',1.00,1,1,'OTC drugs, child GENERIC ITEM','200000265007','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(114,114,2,'0000',1.00,1,1,'Adult diapers, case: Small GENERIC ITEM','200000270018','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(115,115,2,'0000',1.00,1,1,'Adult diapers, case: Medium GENERIC ITEM','200000270025','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(116,116,2,'0000',1.00,1,1,'Adult diapers, case: Large GENERIC ITEM','200000270032','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(117,117,2,'0000',1.00,1,1,'Adult diapers, case: XL GENERIC ITEM','200000270049','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(118,118,2,'0000',1.00,1,1,'Adult diapers, case: XXL GENERIC ITEM','200000270056','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(119,119,6,'0000',1.00,1,1,'Adult diapers, mixed gaylord GENERIC ITEM','200000270995','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(120,120,2,'0000',1.00,1,1,'Bed liners / adult pads GENERIC ITEM','200000272005','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(121,121,2,'0000',1.00,1,1,'Medical supplies GENERIC ITEM','200000276003','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(122,122,2,'0000',1.00,1,1,'Isolation gown, hat, shoe covers GENERIC ITEM','200000278007','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(123,123,2,'0000',1.00,1,1,'Lab coat GENERIC ITEM','200000279004','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(124,124,2,'0000',1.00,1,1,'Head protection GENERIC ITEM','200000280000','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(125,125,2,'0000',1.00,1,1,'Gloves, work GENERIC ITEM','200000282004','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(126,126,2,'0000',1.00,1,1,'Boots, rubber GENERIC ITEM','200000283001','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(127,127,2,'0000',1.00,1,1,'PPE masks GENERIC ITEM','200000284008','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(128,128,2,'0000',1.00,1,1,'Eye protection GENERIC ITEM','200000286002','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(129,129,2,'0000',1.00,1,1,'Ear protection GENERIC ITEM','200000287009','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(130,130,2,'0000',1.00,1,1,'Disposables, misc GENERIC ITEM','200000300005','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(131,131,2,'0000',1.00,1,1,'Plates, disposable GENERIC ITEM','200000310004','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(132,132,2,'0000',1.00,1,1,'Bowls, disposable GENERIC ITEM','200000312008','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(133,133,2,'0000',1.00,1,1,'Cups, disposable GENERIC ITEM','200000314002','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(134,134,2,'0000',1.00,1,1,'Cutlery kits, disposable GENERIC ITEM','200000316006','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(135,135,2,'0000',1.00,1,1,'Paper towels, household rolls GENERIC ITEM','200000318000','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(136,136,2,'0000',1.00,1,1,'Paper towels, C-fold (dispenser) GENERIC ITEM','200000318017','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(137,137,2,'0000',1.00,1,1,'Paper towels, multi-fold (dispenser) GENERIC ITEM','200000318024','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(138,138,2,'0000',1.00,1,1,'Paper towels, single-fold packs GENERIC ITEM','200000318031','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(139,139,7,'0000',1.00,1,1,'Paper towels, industrial giant roll GENERIC ITEM','200000318901','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(140,140,2,'0000',1.00,1,1,'Shop towels, boxed sheets GENERIC ITEM','200000318918','2026-11-17 22:18:53','2026-11-17 22:18:53'),
(141,141,2,'0000',1.00,1,1,'Napkins, disposable GENERIC ITEM','200000320003','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(142,142,2,'0000',1.00,1,1,'Tissues GENERIC ITEM','200000330002','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(143,143,2,'0000',1.00,1,1,'Toilet paper, household GENERIC ITEM','200000332006','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(144,144,2,'0000',1.00,1,1,'Toilet paper, giant dispenser roll GENERIC ITEM','200000332907','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(145,145,2,'0000',1.00,1,1,'Table cloths GENERIC ITEM','200000340001','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(146,146,2,'0000',1.00,1,1,'Cooking / baking disposables GENERIC ITEM','200000342005','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(147,147,2,'0000',1.00,1,1,'Sandwich bags GENERIC ITEM','200000350000','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(148,148,2,'0000',1.00,1,1,'Garbage bags GENERIC ITEM','200000352004','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(149,149,2,'0000',1.00,1,1,'Wraps (aluminum, plastic, wax) GENERIC ITEM','200000354008','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(150,150,5,'0000',1.00,1,1,'Baby kit GENERIC ITEM','200000400002','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(151,151,2,'0000',1.00,1,1,'Baby supplies, misc GENERIC ITEM','200000401009','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(152,152,5,'0000',1.00,1,1,'Diaper bags GENERIC ITEM','200000402006','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(153,153,2,'0000',1.00,1,1,'Diapers, newborn GENERIC ITEM','200000404000','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(154,154,2,'0000',1.00,1,1,'Diapers, size 1 GENERIC ITEM','200000404017','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(155,155,2,'0000',1.00,1,1,'Diapers, size 2 GENERIC ITEM','200000404024','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(156,156,2,'0000',1.00,1,1,'Diapers, size 3 GENERIC ITEM','200000404031','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(157,157,2,'0000',1.00,1,1,'Diapers, size 4 GENERIC ITEM','200000404048','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(158,158,2,'0000',1.00,1,1,'Diapers, size 5 GENERIC ITEM','200000404055','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(159,159,2,'0000',1.00,1,1,'Diapers, size 6 GENERIC ITEM','200000404062','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(160,160,2,'0000',1.00,1,1,'Diapers, size 7 GENERIC ITEM','200000404079','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(161,161,2,'0000',1.00,1,1,'Diapers, size 8 GENERIC ITEM','200000404086','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(162,162,2,'0000',1.00,1,1,'Diapers, overnight GENERIC ITEM','200000404109','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(163,163,6,'0000',1.00,1,1,'Diapers, mixed / gaylord GENERIC ITEM','200000404994','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(164,164,2,'0000',1.00,1,1,'Baby wipes GENERIC ITEM','200000410001','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(165,165,2,'0000',1.00,1,1,'Baby washcloths GENERIC ITEM','200000412005','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(166,166,2,'0000',1.00,1,1,'Baby lotion GENERIC ITEM','200000414009','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(167,167,2,'0000',1.00,1,1,'Baby clothes GENERIC ITEM','200000420000','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(168,168,2,'0000',1.00,1,1,'Baby outerwear GENERIC ITEM','200000422004','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(169,169,2,'0000',1.00,1,1,'Baby blankets GENERIC ITEM','200000424008','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(170,170,2,'0000',1.00,1,1,'Nursing pads GENERIC ITEM','200000430009','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(171,171,2,'0000',1.00,1,1,'Baby food GENERIC ITEM','200000440008','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(172,172,2,'0000',1.00,1,1,'Baby formula, powder GENERIC ITEM','200000442002','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(173,173,2,'0000',1.00,1,1,'Baby formula, liquid GENERIC ITEM','200000442019','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(174,174,2,'0000',1.00,1,1,'Toddler milk GENERIC ITEM','200000443009','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(175,175,2,'0000',1.00,1,1,'PediaSure GENERIC ITEM','200000444006','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(176,176,2,'0000',1.00,1,1,'Pedialyte GENERIC ITEM','200000446000','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(177,177,2,'0000',1.00,1,1,'Baby juice GENERIC ITEM','200000448004','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(178,178,2,'0000',1.00,1,1,'Baby water GENERIC ITEM','200000450007','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(179,179,2,'0000',1.00,1,1,'Baby bottles GENERIC ITEM','200000460006','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(180,180,2,'0000',1.00,1,1,'Pacifiers & baby toys GENERIC ITEM','200000462000','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(181,181,2,'0000',1.00,1,1,'Pull-ups GENERIC ITEM','200000470005','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(182,182,2,'0000',1.00,1,1,'Children\'s disaster kits GENERIC ITEM','200000480004','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(183,183,2,'0000',1.00,1,1,'Games, crafts GENERIC ITEM','200000482008','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(184,184,2,'0000',1.00,1,1,'Plush toys GENERIC ITEM','200000484002','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(185,185,2,'0000',1.00,1,1,'Toys, all GENERIC ITEM','200000486006','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(186,187,5,'0000',1.00,1,1,'School kits GENERIC ITEM','200000490003','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(187,188,2,'0000',1.00,1,1,'School supplies GENERIC ITEM','200000492007','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(188,189,5,'0000',1.00,1,1,'Car seats, children GENERIC ITEM','200000494001','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(189,190,2,'0000',1.00,1,1,'Safety equipment GENERIC ITEM','200000498009','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(190,191,5,'0000',1.00,1,1,'Bedroom kits GENERIC ITEM','200000500009','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(191,192,2,'0000',1.00,1,1,'Linens, misc GENERIC ITEM','200000501006','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(192,193,5,'0000',1.00,1,1,'Bedding kits GENERIC ITEM','200000502003','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(193,194,2,'0000',1.00,1,1,'Sheets, Twin GENERIC ITEM','200000510015','2026-11-17 22:18:54','2026-11-17 22:18:54'),
(194,195,2,'0000',1.00,1,1,'Sheets, Full GENERIC ITEM','200000510039','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(195,196,2,'0000',1.00,1,1,'Sheets, Queen GENERIC ITEM','200000510046','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(196,197,2,'0000',1.00,1,1,'Sheets, King GENERIC ITEM','200000510053','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(197,198,2,'0000',1.00,1,1,'Sheets, mixed GENERIC ITEM','200000510992','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(198,199,2,'0000',1.00,1,1,'Pillow cases, regular GENERIC ITEM','200000520007','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(199,200,2,'0000',1.00,1,1,'Pillow cases, king GENERIC ITEM','200000522001','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(200,201,2,'0000',1.00,1,1,'Pillows GENERIC ITEM','200000524005','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(201,202,2,'0000',1.00,1,1,'Blankets, Twin GENERIC ITEM','200000525019','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(202,203,2,'0000',1.00,1,1,'Blankets, Full GENERIC ITEM','200000525033','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(203,204,2,'0000',1.00,1,1,'Blankets, Queen GENERIC ITEM','200000525040','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(204,205,2,'0000',1.00,1,1,'Blankets, King GENERIC ITEM','200000525057','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(205,206,2,'0000',1.00,1,1,'Blankets, mixed GENERIC ITEM','200000525996','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(206,207,2,'0000',1.00,1,1,'Disaster blankets GENERIC ITEM','200000531003','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(207,208,2,'0000',1.00,1,1,'Throws (small blankets) GENERIC ITEM','200000532000','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(208,209,2,'0000',1.00,1,1,'Shipping blankets GENERIC ITEM','200000533007','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(209,210,2,'0000',1.00,1,1,'Bed liner GENERIC ITEM','200000534004','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(210,211,2,'0000',1.00,1,1,'Mattress toppers, Twin GENERIC ITEM','200000540012','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(211,212,2,'0000',1.00,1,1,'Mattress toppers, Twin XL GENERIC ITEM','200000540029','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(212,213,2,'0000',1.00,1,1,'Mattress toppers, Full GENERIC ITEM','200000540036','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(213,214,2,'0000',1.00,1,1,'Mattress toppers, Queen GENERIC ITEM','200000540043','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(214,215,2,'0000',1.00,1,1,'Mattress toppers, King GENERIC ITEM','200000540050','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(215,216,2,'0000',1.00,1,1,'Mattress toppers, Cal King GENERIC ITEM','200000540067','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(216,217,2,'0000',1.00,1,1,'Mattress toppers, mixed GENERIC ITEM','200000540999','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(217,218,5,'0000',1.00,1,1,'Bathroom kits GENERIC ITEM','200000550004','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(218,219,2,'0000',1.00,1,1,'Wash cloths GENERIC ITEM','200000560003','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(219,220,2,'0000',1.00,1,1,'Towels, hand GENERIC ITEM','200000562007','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(220,221,2,'0000',1.00,1,1,'Towels, bath GENERIC ITEM','200000564001','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(221,222,2,'0000',1.00,1,1,'Towels, misc GENERIC ITEM','200000566005','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(222,223,2,'0000',1.00,1,1,'Shower curtains GENERIC ITEM','200000570002','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(223,224,2,'0000',1.00,1,1,'Bathroom rugs GENERIC ITEM','200000572006','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(224,225,2,'0000',1.00,1,1,'Pillows, decorative GENERIC ITEM','200000582005','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(225,226,2,'0000',1.00,1,1,'Curtains GENERIC ITEM','200000584009','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(226,227,5,'0000',1.00,1,1,'Cooking kit GENERIC ITEM','200000600006','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(227,228,2,'0000',1.00,1,1,'Kitchen, misc GENERIC ITEM','200000601003','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(228,229,5,'0000',1.00,1,1,'Kitchen start-up kit GENERIC ITEM','200000610005','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(229,230,2,'0000',1.00,1,1,'Plates GENERIC ITEM','200000612009','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(230,231,2,'0000',1.00,1,1,'Bowls GENERIC ITEM','200000614003','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(231,232,2,'0000',1.00,1,1,'Dinnerware sets GENERIC ITEM','200000615000','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(232,233,2,'0000',1.00,1,1,'Cups, glasses GENERIC ITEM','200000616007','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(233,234,2,'0000',1.00,1,1,'Beverage tumblers, plastic GENERIC ITEM','200000617004','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(234,235,2,'0000',1.00,1,1,'Flatware GENERIC ITEM','200000618001','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(235,236,2,'0000',1.00,1,1,'Serving platters GENERIC ITEM','200000620004','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(236,237,2,'0000',1.00,1,1,'Serving utensils GENERIC ITEM','200000622008','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(237,238,2,'0000',1.00,1,1,'Pots / pans GENERIC ITEM','200000630003','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(238,239,2,'0000',1.00,1,1,'Cooking accessories GENERIC ITEM','200000632007','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(239,240,2,'0000',1.00,1,1,'Food containers GENERIC ITEM','200000634001','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(240,241,5,'0000',1.00,1,1,'Water filters GENERIC ITEM','200000636005','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(241,242,2,'0000',1.00,1,1,'Kitchen towels GENERIC ITEM','200000640002','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(242,243,5,'0000',1.00,1,1,'Air fryer GENERIC ITEM','200000650001','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(243,244,5,'0000',1.00,1,1,'Pressure / instant pots GENERIC ITEM','200000655006','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(244,245,5,'0000',1.00,1,1,'Household kits GENERIC ITEM','200000700003','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(245,246,5,'0000',1.00,1,1,'Clean-up kits GENERIC ITEM','200000705008','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(246,247,2,'0000',1.00,1,1,'Moisture absorbers GENERIC ITEM','200000706005','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(247,248,5,'0000',1.00,1,1,'Flood buckets GENERIC ITEM','200000710002','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(248,249,2,'0000',1.00,1,1,'Laundry detergent GENERIC ITEM','200000720001','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(249,250,2,'0000',1.00,1,1,'Dish soap GENERIC ITEM','200000721008','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(250,251,2,'0000',1.00,1,1,'Cleaners, misc GENERIC ITEM','200000722005','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(251,252,2,'0000',1.00,1,1,'Glass cleaner spray GENERIC ITEM','200000722012','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(252,253,2,'0000',1.00,1,1,'Degreaser spray GENERIC ITEM','200000722029','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(253,254,2,'0000',1.00,1,1,'Outdoor cleaners GENERIC ITEM','200000723002','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(254,255,2,'0000',1.00,1,1,'Bleach / OxiClean GENERIC ITEM','200000724009','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(255,256,2,'0000',1.00,1,1,'General-purpose cleaner spray GENERIC ITEM','200000725006','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(256,257,2,'0000',1.00,1,1,'Disinfectant wipes GENERIC ITEM','200000726003','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(257,258,2,'0000',1.00,1,1,'Cleaning sponges GENERIC ITEM','200000728007','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(258,259,2,'0000',1.00,1,1,'Disinfectant aerosol GENERIC ITEM','200000729004','2026-11-17 22:18:55','2026-11-17 22:18:55'),
(259,260,2,'0000',1.00,1,1,'Gloves, cleaning GENERIC ITEM','200000730000','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(260,261,2,'0000',1.00,1,1,'Dust masks GENERIC ITEM','200000732004','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(261,262,5,'0000',1.00,1,1,'Trash / garbage cans GENERIC ITEM','200000740009','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(262,263,2,'0000',1.00,1,1,'Cleaning spray bottles GENERIC ITEM','200000741006','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(263,264,5,'0000',1.00,1,1,'Buckets / pails, empty GENERIC ITEM','200000742003','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(264,265,5,'0000',1.00,1,1,'Mop / broom / dustpan GENERIC ITEM','200000744007','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(265,266,2,'0000',1.00,1,1,'Floor care chemicals GENERIC ITEM','200000746001','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(266,267,5,'0000',1.00,1,1,'Laundry baskets GENERIC ITEM','200000748005','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(267,268,2,'0000',1.00,1,1,'Laundry bags GENERIC ITEM','200000749002','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(268,269,2,'0000',1.00,1,1,'Clothesline, pins GENERIC ITEM','200000750008','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(269,270,2,'0000',1.00,1,1,'Flashlights GENERIC ITEM','200000760007','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(270,271,2,'0000',1.00,1,1,'Phone chargers GENERIC ITEM','200000761004','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(271,272,2,'0000',1.00,1,1,'Batteries, mixed/any GENERIC ITEM','200000762001','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(272,273,2,'0000',1.00,1,1,'Batteries, AAA GENERIC ITEM','200000762018','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(273,274,2,'0000',1.00,1,1,'Batteries, AA GENERIC ITEM','200000762025','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(274,275,2,'0000',1.00,1,1,'Batteries, C GENERIC ITEM','200000762032','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(275,276,2,'0000',1.00,1,1,'Batteries, D GENERIC ITEM','200000762049','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(276,277,2,'0000',1.00,1,1,'Batteries, 9-volt GENERIC ITEM','200000762094','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(277,278,2,'0000',1.00,1,1,'Power banks GENERIC ITEM','200000762605','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(278,279,2,'0000',1.00,1,1,'Lighters / matches GENERIC ITEM','200000763008','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(279,280,2,'0000',1.00,1,1,'Candles GENERIC ITEM','200000764005','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(280,281,5,'0000',1.00,1,1,'Fire extinguishers GENERIC ITEM','200000765002','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(281,282,2,'0000',1.00,1,1,'Umbrellas / ponchos GENERIC ITEM','200000766009','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(282,283,2,'0000',1.00,1,1,'CO2 detectors GENERIC ITEM','200000767006','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(283,284,2,'0000',1.00,1,1,'Backpacks / totes GENERIC ITEM','200000768003','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(284,285,5,'0000',1.00,1,1,'Luggage / suitcases GENERIC ITEM','200000769000','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(285,286,2,'0000',1.00,1,1,'Boxes, unmade GENERIC ITEM','200000770006','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(286,287,2,'0000',1.00,1,1,'Plastic bins GENERIC ITEM','200000771003','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(287,288,2,'0000',1.00,1,1,'Packing tape GENERIC ITEM','200000772000','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(288,289,5,'0000',1.00,1,1,'Musical instruments GENERIC ITEM','200000780005','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(289,290,5,'0000',1.00,1,1,'Computers GENERIC ITEM','200000781002','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(290,291,2,'0000',1.00,1,1,'Books GENERIC ITEM','200000782009','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(291,292,2,'0000',1.00,1,1,'Videos, DVDs GENERIC ITEM','200000783006','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(292,293,2,'0000',1.00,1,1,'Wrist watches GENERIC ITEM','200000784003','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(293,294,2,'0000',1.00,1,1,'Electronics, misc GENERIC ITEM','200000785000','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(294,295,5,'0000',1.00,1,1,'Radios, portable GENERIC ITEM','200000786007','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(295,296,5,'0000',1.00,1,1,'Wall mirrors GENERIC ITEM','200000787004','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(296,297,5,'0000',1.00,1,1,'Christmas trees GENERIC ITEM','200000788001','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(297,298,2,'0000',1.00,1,1,'Holiday decorations GENERIC ITEM','200000789008','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(298,299,2,'0000',1.00,1,1,'Household, misc GENERIC ITEM','200000791001','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(299,300,5,'0000',1.00,1,1,'Irons (clothes) GENERIC ITEM','200000792008','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(300,301,2,'0000',1.00,1,1,'Utility knives GENERIC ITEM','200000793005','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(301,302,2,'0000',1.00,1,1,'Clothing packs GENERIC ITEM','200000800000','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(302,303,2,'0000',1.00,1,1,'Clothing, misc GENERIC ITEM','200000801007','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(303,304,2,'0000',1.00,1,1,'Clothing, men/boys GENERIC ITEM','200000810009','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(304,305,2,'0000',1.00,1,1,'Sweaters/jackets, men/boys GENERIC ITEM','200000812003','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(305,306,2,'0000',1.00,1,1,'Coats, men/boys GENERIC ITEM','200000814007','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(306,307,2,'0000',1.00,1,1,'Clothing, women/girls GENERIC ITEM','200000820008','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(307,308,2,'0000',1.00,1,1,'Sweaters/jackets, women/girls GENERIC ITEM','200000822002','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(308,309,2,'0000',1.00,1,1,'Clothing, children\'s GENERIC ITEM','200000823009','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(309,310,2,'0000',1.00,1,1,'Coats, women/girls GENERIC ITEM','200000824006','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(310,311,2,'0000',1.00,1,1,'Underwear, men/boys GENERIC ITEM','200000830007','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(311,312,2,'0000',1.00,1,1,'Underwear, women/girls GENERIC ITEM','200000832001','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(312,313,2,'0000',1.00,1,1,'T-shirts GENERIC ITEM','200000834005','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(313,314,2,'0000',1.00,1,1,'Socks, men/boys GENERIC ITEM','200000840006','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(314,315,2,'0000',1.00,1,1,'Socks, women/girls GENERIC ITEM','200000842000','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(315,316,2,'0000',1.00,1,1,'Footwear, men/boys GENERIC ITEM','200000850005','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(316,317,2,'0000',1.00,1,1,'Footwear, women/girls GENERIC ITEM','200000852009','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(317,318,2,'0000',1.00,1,1,'Accessories, men\'s GENERIC ITEM','200000860004','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(318,319,2,'0000',1.00,1,1,'Accessories, women\'s GENERIC ITEM','200000862008','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(319,320,2,'0000',1.00,1,1,'Hangers GENERIC ITEM','200000864002','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(320,321,2,'0000',1.00,1,1,'Hats / beanies / visors GENERIC ITEM','200000870003','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(321,322,4,'0000',1.00,1,1,'Unsorted clothes GENERIC ITEM','200000899004','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(322,323,5,'0000',1.00,1,1,'Evacuation kits GENERIC ITEM','200000900007','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(323,324,2,'0000',1.00,1,1,'Outdoor, misc GENERIC ITEM','200000901004','2026-11-17 22:18:56','2026-11-17 22:18:56'),
(324,325,5,'0000',1.00,1,1,'Rope (clothesline, camping — 100 ft) GENERIC ITEM','200000902001','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(325,326,5,'0000',1.00,1,1,'Tents, canopies GENERIC ITEM','200000904005','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(326,327,3,'0000',1.00,1,1,'Grill fuels, charcoal GENERIC ITEM','200000905019','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(327,328,2,'0000',1.00,1,1,'Grill fuels, lighter fluid GENERIC ITEM','200000905026','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(328,329,5,'0000',1.00,1,1,'Grill fuels, propane GENERIC ITEM','200000905033','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(329,330,5,'0000',1.00,1,1,'Sleeping bags GENERIC ITEM','200000906009','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(330,331,2,'0000',1.00,1,1,'Hand warmers GENERIC ITEM','200000907006','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(331,332,5,'0000',1.00,1,1,'Camping chairs GENERIC ITEM','200000908003','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(332,333,5,'0000',1.00,1,1,'Air / foam mattresses GENERIC ITEM','200000909000','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(333,334,5,'0000',1.00,1,1,'Cots, portable beds GENERIC ITEM','200000910006','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(334,335,5,'0000',1.00,1,1,'Camp stoves / grills GENERIC ITEM','200000912000','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(335,336,5,'0000',1.00,1,1,'Portable toilets GENERIC ITEM','200000914004','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(336,337,5,'0000',1.00,1,1,'Kerosene heaters GENERIC ITEM','200000915001','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(337,338,5,'0000',1.00,1,1,'Coolers GENERIC ITEM','200000916008','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(338,339,5,'0000',1.00,1,1,'Water jugs GENERIC ITEM','200000917005','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(339,340,5,'0000',1.00,1,1,'Storage containers, plastic GENERIC ITEM','200000918002','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(340,341,2,'0000',1.00,1,1,'Repellent / pest control GENERIC ITEM','200000920005','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(341,342,2,'0000',1.00,1,1,'Sporting goods GENERIC ITEM','200000926007','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(342,343,2,'0000',1.00,1,1,'Gardening tools GENERIC ITEM','200000930004','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(343,344,5,'0000',1.00,1,1,'Carts, wheelbarrows GENERIC ITEM','200000932008','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(344,345,5,'0000',1.00,1,1,'Roof tarping kit (nails, hammer, instructions) GENERIC ITEM','200000938000','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(345,346,2,'0000',1.00,1,1,'Roofing nails GENERIC ITEM','200000939007','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(346,347,2,'0000',1.00,1,1,'Hand tools GENERIC ITEM','200000940003','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(347,348,5,'0000',1.00,1,1,'Chainsaws GENERIC ITEM','200000941000','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(348,349,5,'0000',1.00,1,1,'Power tools GENERIC ITEM','200000942007','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(349,350,5,'0000',1.00,1,1,'Extension cords GENERIC ITEM','200000943004','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(350,351,5,'0000',1.00,1,1,'Shop vacs GENERIC ITEM','200000944001','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(351,352,2,'0000',1.00,1,1,'Automotive, misc GENERIC ITEM','200000946005','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(352,353,5,'0000',1.00,1,1,'Motor oil GENERIC ITEM','200000947002','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(353,354,2,'0000',1.00,1,1,'2-cycle oil GENERIC ITEM','200000947019','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(354,355,5,'0000',1.00,1,1,'Bar & chain oil GENERIC ITEM','200000947026','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(355,356,5,'0000',1.00,1,1,'Tarps, small GENERIC ITEM','200000950101','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(356,357,5,'0000',1.00,1,1,'Tarps, 8×10 GENERIC ITEM','200000950118','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(357,358,5,'0000',1.00,1,1,'Tarps, 8×12 GENERIC ITEM','200000950125','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(358,359,5,'0000',1.00,1,1,'Tarps, medium GENERIC ITEM','200000950200','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(359,360,5,'0000',1.00,1,1,'Tarps, 16×20 GENERIC ITEM','200000950217','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(360,361,5,'0000',1.00,1,1,'Tarps, 18×24 GENERIC ITEM','200000950224','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(361,362,5,'0000',1.00,1,1,'Tarps, large GENERIC ITEM','200000950309','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(362,363,5,'0000',1.00,1,1,'Tarps, 20×30 GENERIC ITEM','200000950316','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(363,364,5,'0000',1.00,1,1,'Tarps, 20×40 GENERIC ITEM','200000950323','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(364,365,5,'0000',1.00,1,1,'Tarps, extra large GENERIC ITEM','200000950408','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(365,366,5,'0000',1.00,1,1,'Tarps, 40×60 GENERIC ITEM','200000950415','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(366,367,7,'0000',1.00,1,1,'Tarps, roll (bulk material) GENERIC ITEM','200000950903','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(367,368,5,'0000',1.00,1,1,'Tarps, mixed / all sizes GENERIC ITEM','200000950996','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(368,369,5,'0000',1.00,1,1,'Plastic sheeting GENERIC ITEM','200000952006','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(369,370,2,'0000',1.00,1,1,'Painting supplies GENERIC ITEM','200000960001','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(370,371,2,'0000',1.00,1,1,'Tape (electrical / duct / masking) GENERIC ITEM','200000964009','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(371,372,5,'0000',1.00,1,1,'Ladders GENERIC ITEM','200000970000','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(372,373,5,'0000',1.00,1,1,'Sump pumps GENERIC ITEM','200000978006','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(373,374,5,'0000',1.00,1,1,'Generators GENERIC ITEM','200000980009','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(374,375,5,'0000',1.00,1,1,'Fuel containers GENERIC ITEM','200000982003','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(375,376,5,'0000',1.00,1,1,'Fuel containers, kerosene GENERIC ITEM','200000982010','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(376,377,5,'0000',1.00,1,1,'Portable lights GENERIC ITEM','200000984007','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(377,378,5,'0000',1.00,1,1,'Air pumps GENERIC ITEM','200000986001','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(378,379,5,'0000',1.00,1,1,'Bicycles GENERIC ITEM','200000988005','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(379,380,5,'0000',1.00,1,1,'Overnight kits GENERIC ITEM','200000990008','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(380,381,2,'0000',1.00,1,1,'Communication equipment GENERIC ITEM','200000991005','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(381,382,5,'0000',1.00,1,1,'Casket, adult (Funeral) GENERIC ITEM','200000994006','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(382,383,5,'0000',1.00,1,1,'Gift cards GENERIC ITEM','200000995003','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(383,384,5,'0000',1.00,1,1,'Empty pallets GENERIC ITEM','200000996000','2026-11-17 22:18:57','2026-11-17 22:18:57'),
(384,385,4,'0000',1.00,1,1,'Unsorted donations GENERIC ITEM','200000997007','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(385,386,4,'0000',1.00,1,1,'Non-distributable, non-clothing GENERIC ITEM','200000998004','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(386,387,4,'0000',1.00,1,1,'Non-distributable, clothing GENERIC ITEM','200000999001','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(387,388,5,'0000',1.00,1,1,'Large appliances, misc GENERIC ITEM','200001000003','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(388,389,5,'0000',1.00,1,1,'Washing machines GENERIC ITEM','200001100000','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(389,390,5,'0000',1.00,1,1,'Clothes dryers GENERIC ITEM','200001155000','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(390,391,5,'0000',1.00,1,1,'Refrigerators GENERIC ITEM','200001201004','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(391,392,5,'0000',1.00,1,1,'Stoves / ranges & ovens GENERIC ITEM','200001225000','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(392,393,5,'0000',1.00,1,1,'Range hoods GENERIC ITEM','200001230004','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(393,394,5,'0000',1.00,1,1,'Dishwashers GENERIC ITEM','200001275005','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(394,395,5,'0000',1.00,1,1,'Hot water heaters GENERIC ITEM','200001301001','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(395,396,5,'0000',1.00,1,1,'Small appliances, misc GENERIC ITEM','200001500008','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(396,397,5,'0000',1.00,1,1,'Space heaters GENERIC ITEM','200001505003','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(397,398,5,'0000',1.00,1,1,'Microwaves GENERIC ITEM','200001525001','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(398,399,5,'0000',1.00,1,1,'Toasters GENERIC ITEM','200001550003','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(399,400,5,'0000',1.00,1,1,'Toaster ovens GENERIC ITEM','200001555008','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(400,401,5,'0000',1.00,1,1,'Coffeemakers GENERIC ITEM','200001575006','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(401,402,5,'0000',1.00,1,1,'Electric fans GENERIC ITEM','200001610004','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(402,403,2,'0000',1.00,1,1,'Floor tile GENERIC ITEM','200002202000','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(403,404,2,'0000',1.00,1,1,'Wall base trim GENERIC ITEM','200002203007','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(404,405,2,'0000',1.00,1,1,'Floor tile, vinyl GENERIC ITEM','200002212009','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(405,406,2,'0000',1.00,1,1,'Floor tile, ceramic GENERIC ITEM','200002214003','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(406,407,2,'0000',1.00,1,1,'Flooring, wood GENERIC ITEM','200002218001','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(407,408,2,'0000',1.00,1,1,'Carpet squares GENERIC ITEM','200002230003','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(408,409,5,'0000',1.00,1,1,'Sheetrock GENERIC ITEM','200002302007','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(409,410,2,'0000',1.00,1,1,'Spackling compound GENERIC ITEM','200002310002','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(410,411,2,'0000',1.00,1,1,'Wall tile, ceramic GENERIC ITEM','200002332004','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(411,412,2,'0000',1.00,1,1,'Roofing, aluminum GENERIC ITEM','200002380005','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(412,413,5,'0000',1.00,1,1,'Cabinetry GENERIC ITEM','200002502001','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(413,414,5,'0000',1.00,1,1,'Kitchen cabinets, upper GENERIC ITEM','200002510006','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(414,415,5,'0000',1.00,1,1,'Kitchen cabinets, upper corner GENERIC ITEM','200002512000','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(415,416,5,'0000',1.00,1,1,'Kitchen cabinets, lower GENERIC ITEM','200002520005','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(416,417,5,'0000',1.00,1,1,'Kitchen cabinets, lower corner GENERIC ITEM','200002522009','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(417,418,5,'0000',1.00,1,1,'Kitchen sinks GENERIC ITEM','200002530004','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(418,419,5,'0000',1.00,1,1,'Bathroom vanities GENERIC ITEM','200002552006','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(419,420,5,'0000',1.00,1,1,'Doors, interior GENERIC ITEM','200002610003','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(420,421,5,'0000',1.00,1,1,'Doors, interior panel GENERIC ITEM','200002612007','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(421,422,5,'0000',1.00,1,1,'Doors, interior bi-fold GENERIC ITEM','200002614001','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(422,423,5,'0000',1.00,1,1,'Doors, exterior misc GENERIC ITEM','200002630001','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(423,424,5,'0000',1.00,1,1,'Windows, misc GENERIC ITEM','200002650009','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(424,425,5,'0000',1.00,1,1,'Hot tubs GENERIC ITEM','200002750006','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(425,426,5,'0000',1.00,1,1,'Wood clamps GENERIC ITEM','200002812001','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(426,427,2,'0000',1.00,1,1,'Furniture parts GENERIC ITEM','200003100008','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(427,428,5,'0000',1.00,1,1,'Chairs, dining GENERIC ITEM','200003121003','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(428,429,5,'0000',1.00,1,1,'Tables, dining GENERIC ITEM','200003125001','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(429,430,5,'0000',1.00,1,1,'TV tables / trays GENERIC ITEM','200003141001','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(430,431,5,'0000',1.00,1,1,'Buffets GENERIC ITEM','200003150003','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(431,432,5,'0000',1.00,1,1,'Chairs, office GENERIC ITEM','200003207004','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(432,433,5,'0000',1.00,1,1,'Chairs, indoor folding GENERIC ITEM','200003305007','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(433,434,5,'0000',1.00,1,1,'Couches / sofas GENERIC ITEM','200003307001','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(434,435,5,'0000',1.00,1,1,'Benches GENERIC ITEM','200003310001','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(435,436,5,'0000',1.00,1,1,'Entertainment centers GENERIC ITEM','200003320000','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(436,437,5,'0000',1.00,1,1,'End tables GENERIC ITEM','200003341005','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(437,438,5,'0000',1.00,1,1,'Coffee tables GENERIC ITEM','200003345003','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(438,439,5,'0000',1.00,1,1,'Lamps GENERIC ITEM','200003350007','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(439,440,5,'0000',1.00,1,1,'Mattresses, Twin GENERIC ITEM','200003401013','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(440,441,5,'0000',1.00,1,1,'Mattresses, Twin XL GENERIC ITEM','200003401020','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(441,442,5,'0000',1.00,1,1,'Mattresses, Full GENERIC ITEM','200003401037','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(442,443,5,'0000',1.00,1,1,'Mattresses, Queen GENERIC ITEM','200003401044','2026-11-17 22:18:58','2026-11-17 22:18:58'),
(443,444,5,'0000',1.00,1,1,'Mattresses, King GENERIC ITEM','200003401051','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(444,445,5,'0000',1.00,1,1,'Mattresses, Cal King GENERIC ITEM','200003401068','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(445,446,5,'0000',1.00,1,1,'Mattresses, mixed/unknown GENERIC ITEM','200003401990','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(446,447,5,'0000',1.00,1,1,'Box springs, Twin GENERIC ITEM','200003411012','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(447,448,5,'0000',1.00,1,1,'Box springs, Twin XL GENERIC ITEM','200003411029','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(448,449,5,'0000',1.00,1,1,'Box springs, Full GENERIC ITEM','200003411036','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(449,450,5,'0000',1.00,1,1,'Box springs, Queen GENERIC ITEM','200003411043','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(450,451,5,'0000',1.00,1,1,'Box springs, King GENERIC ITEM','200003411050','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(451,452,5,'0000',1.00,1,1,'Box springs, Cal King GENERIC ITEM','200003411067','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(452,453,5,'0000',1.00,1,1,'Box springs, mixed/unknown GENERIC ITEM','200003411999','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(453,454,5,'0000',1.00,1,1,'Bed frames GENERIC ITEM','200003425002','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(454,455,5,'0000',1.00,1,1,'Chests of drawers GENERIC ITEM','200003451001','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(455,456,5,'0000',1.00,1,1,'Folding card tables GENERIC ITEM','200003924000','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(456,457,5,'0000',1.00,1,1,'Holy Bible GENERIC ITEM','200007777008','2026-11-17 22:18:59','2026-11-17 22:18:59');
/*!40000 ALTER TABLE `items` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `itemtypes`
--

DROP TABLE IF EXISTS `itemtypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `itemtypes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `category_id` bigint(20) unsigned NOT NULL,
  `unit_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `low_stock_threshold` int(10) unsigned DEFAULT NULL,
  `description` text DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `family` varchar(4) DEFAULT NULL,
  `variant` varchar(2) DEFAULT NULL,
  `status` enum('orderable','sort_hold','retired') NOT NULL DEFAULT 'orderable',
  `pick_sequence` tinyint(3) unsigned DEFAULT NULL,
  `storage_class` enum('F','L','K','A','N') DEFAULT NULL,
  `source_system` varchar(255) DEFAULT NULL,
  `source_ref` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `itemtypes_family_variant_unique` (`family`,`variant`),
  KEY `itemtypes_category_id_foreign` (`category_id`),
  KEY `itemtypes_unit_id_foreign` (`unit_id`),
  KEY `itemtypes_status_index` (`status`),
  KEY `itemtypes_source_system_source_ref_index` (`source_system`,`source_ref`),
  CONSTRAINT `itemtypes_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `itemtypes_unit_id_foreign` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=458 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `itemtypes`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `itemtypes` WRITE;
/*!40000 ALTER TABLE `itemtypes` DISABLE KEYS */;
INSERT INTO `itemtypes` VALUES
(1,1,10,'Bird food',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0010','00','orderable',NULL,NULL,NULL,NULL),
(2,1,10,'Cat food, dry',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0020','01','orderable',NULL,NULL,NULL,NULL),
(3,1,10,'Cat food, wet (cans/pouches)',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0020','02','orderable',NULL,NULL,NULL,NULL),
(4,1,10,'Cat litter',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0022','00','orderable',NULL,NULL,NULL,NULL),
(5,1,10,'Cat litter scoop',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0024','00','orderable',NULL,NULL,NULL,NULL),
(6,1,10,'Cat care',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0025','00','orderable',NULL,NULL,NULL,NULL),
(7,1,10,'Cat litter box / tray',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0026','00','orderable',NULL,NULL,NULL,NULL),
(8,1,10,'Dog food, dry',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0030','01','orderable',NULL,NULL,NULL,NULL),
(9,1,10,'Dog food, wet (cans/pouches)',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0030','02','orderable',NULL,NULL,NULL,NULL),
(10,1,10,'Dog bones',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0032','00','orderable',NULL,NULL,NULL,NULL),
(11,1,10,'Pet food / water bowl',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0033','00','orderable',NULL,NULL,NULL,NULL),
(12,1,10,'Dog care',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0034','00','orderable',NULL,NULL,NULL,NULL),
(13,1,10,'Horse feed',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0042','01','orderable',NULL,NULL,NULL,NULL),
(14,1,10,'Collars, pet',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0052','00','orderable',NULL,NULL,NULL,NULL),
(15,1,10,'Leashes, dog/cat',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0054','00','orderable',NULL,NULL,NULL,NULL),
(16,1,10,'Kennels, dog/cat',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0056','00','orderable',NULL,NULL,NULL,NULL),
(17,1,10,'Pet food, misc (hamster, bunny, etc.)',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0060','00','orderable',NULL,NULL,NULL,NULL),
(18,1,10,'Pet supplies, misc',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0061','00','orderable',NULL,NULL,NULL,NULL),
(19,1,10,'Pet gate / playpen',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0070','00','orderable',NULL,NULL,NULL,NULL),
(20,1,10,'Wheelchairs',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0081','00','orderable',NULL,NULL,NULL,NULL),
(21,1,10,'Walkers',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0082','00','orderable',NULL,NULL,NULL,NULL),
(22,1,10,'Crutches / cane',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0083','00','orderable',NULL,NULL,NULL,NULL),
(23,1,10,'Bath chair',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0084','00','orderable',NULL,NULL,NULL,NULL),
(24,1,10,'Commode',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0085','00','orderable',NULL,NULL,NULL,NULL),
(25,2,10,'Canned food, mixed',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0101','00','orderable',NULL,NULL,NULL,NULL),
(26,2,10,'MRE (meals ready to eat)',NULL,NULL,1,'2026-11-17 22:18:51','2026-11-17 22:18:51','0102','00','orderable',NULL,NULL,NULL,NULL),
(27,2,10,'Meal kits (not MREs)',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0104','00','orderable',NULL,NULL,NULL,NULL),
(28,2,10,'Mac & cheese',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0105','00','orderable',NULL,NULL,NULL,NULL),
(29,2,10,'Canned fruit',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0110','00','orderable',NULL,NULL,NULL,NULL),
(30,2,10,'Canned vegetables',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0112','00','orderable',NULL,NULL,NULL,NULL),
(31,2,10,'Canned beans',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0114','00','orderable',NULL,NULL,NULL,NULL),
(32,2,10,'Canned beans, #10 / gallon (institutional)',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0114','90','orderable',NULL,NULL,NULL,NULL),
(33,2,10,'Canned meats',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0116','00','orderable',NULL,NULL,NULL,NULL),
(34,2,10,'Canned pasta',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0118','00','orderable',NULL,NULL,NULL,NULL),
(35,2,10,'Canned soup',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0120','00','orderable',NULL,NULL,NULL,NULL),
(36,2,10,'Sauce / gravy',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0122','00','orderable',NULL,NULL,NULL,NULL),
(37,2,10,'Canned tomatoes',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0123','00','orderable',NULL,NULL,NULL,NULL),
(38,2,10,'Dried boxed food',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0130','00','orderable',NULL,NULL,NULL,NULL),
(39,2,10,'Cereals',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0132','00','orderable',NULL,NULL,NULL,NULL),
(40,2,10,'Dry pasta',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0134','00','orderable',NULL,NULL,NULL,NULL),
(41,2,10,'Dry beans',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0136','00','orderable',NULL,NULL,NULL,NULL),
(42,2,10,'Rice',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0138','00','orderable',NULL,NULL,NULL,NULL),
(43,2,10,'Peanut butter',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0140','00','orderable',NULL,NULL,NULL,NULL),
(44,2,10,'PB & jelly, mixed',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0141','00','orderable',NULL,NULL,NULL,NULL),
(45,2,10,'Jam / jelly',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0142','00','orderable',NULL,NULL,NULL,NULL),
(46,2,10,'Snacks, any kind',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0144','00','orderable',NULL,NULL,NULL,NULL),
(47,2,10,'Snacks, savory, any',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0144','10','orderable',NULL,NULL,NULL,NULL),
(48,2,10,'Chips',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0144','11','orderable',NULL,NULL,NULL,NULL),
(49,2,10,'Crackers',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0144','12','orderable',NULL,NULL,NULL,NULL),
(50,2,10,'Snacks, sweet, any',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0144','20','orderable',NULL,NULL,NULL,NULL),
(51,2,10,'Fruit cups',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0144','21','orderable',NULL,NULL,NULL,NULL),
(52,2,10,'Snack bars',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0144','22','orderable',NULL,NULL,NULL,NULL),
(53,2,10,'Salad dressing',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0150','00','orderable',NULL,NULL,NULL,NULL),
(54,2,10,'Vinegar',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0151','00','orderable',NULL,NULL,NULL,NULL),
(55,2,10,'Oil / shortening',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0152','00','orderable',NULL,NULL,NULL,NULL),
(56,2,10,'Flour',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0153','00','orderable',NULL,NULL,NULL,NULL),
(57,2,10,'Sugar',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0154','00','orderable',NULL,NULL,NULL,NULL),
(58,2,10,'Baking, misc',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0155','00','orderable',NULL,NULL,NULL,NULL),
(59,2,10,'Condiments',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0156','00','orderable',NULL,NULL,NULL,NULL),
(60,2,10,'Seasonings',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0158','00','orderable',NULL,NULL,NULL,NULL),
(61,2,10,'Mixed boxes, nonperishable',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0159','00','orderable',NULL,NULL,NULL,NULL),
(62,2,10,'Juices',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0160','00','orderable',NULL,NULL,NULL,NULL),
(63,2,10,'Coconut water',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0161','00','orderable',NULL,NULL,NULL,NULL),
(64,2,10,'Coffee',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0162','00','orderable',NULL,NULL,NULL,NULL),
(65,2,10,'Creamer',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0163','00','orderable',NULL,NULL,NULL,NULL),
(66,2,10,'Tea',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0164','00','orderable',NULL,NULL,NULL,NULL),
(67,2,10,'Rehydration drinks',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0166','00','orderable',NULL,NULL,NULL,NULL),
(68,2,10,'Supplement drink powders',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0168','01','orderable',NULL,NULL,NULL,NULL),
(69,2,10,'Supplement gummies',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0168','02','orderable',NULL,NULL,NULL,NULL),
(70,2,10,'Sparkling drinks',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0169','00','orderable',NULL,NULL,NULL,NULL),
(71,2,10,'Milk, canned / shelf-stable',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0170','00','orderable',NULL,NULL,NULL,NULL),
(72,2,10,'Milk, flavored / chocolate',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0171','00','orderable',NULL,NULL,NULL,NULL),
(73,2,10,'Milk, powdered',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0172','00','orderable',NULL,NULL,NULL,NULL),
(74,2,10,'Protein drinks',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0174','00','orderable',NULL,NULL,NULL,NULL),
(75,2,10,'Water',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0180','00','orderable',NULL,NULL,NULL,NULL),
(76,2,10,'Water, flavored',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0181','00','orderable',NULL,NULL,NULL,NULL),
(77,2,10,'Produce / perishable',NULL,NULL,1,'2026-11-17 22:18:52','2026-11-17 22:18:52','0190','00','sort_hold',NULL,NULL,NULL,NULL),
(78,3,10,'Hygiene kits (bathroom items only)',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0200','00','orderable',NULL,NULL,NULL,NULL),
(79,3,10,'Personal care, misc',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0201','00','orderable',NULL,NULL,NULL,NULL),
(80,3,10,'Toothbrushes',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0202','00','orderable',NULL,NULL,NULL,NULL),
(81,3,10,'Toothpaste',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0203','00','orderable',NULL,NULL,NULL,NULL),
(82,3,10,'Mouthwash',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0204','00','orderable',NULL,NULL,NULL,NULL),
(83,3,10,'Soap / body wash, mixed',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0206','00','orderable',NULL,NULL,NULL,NULL),
(84,3,10,'Bar soap',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0206','01','orderable',NULL,NULL,NULL,NULL),
(85,3,10,'Body wash',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0206','02','orderable',NULL,NULL,NULL,NULL),
(86,3,10,'Liquid hand soap, refill',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0206','03','orderable',NULL,NULL,NULL,NULL),
(87,3,10,'Liquid hand soap, pump dispenser',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0206','04','orderable',NULL,NULL,NULL,NULL),
(88,3,10,'Floor-stand soap dispenser',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0206','90','orderable',NULL,NULL,NULL,NULL),
(89,3,10,'Shampoo & conditioner, mixed',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0210','00','orderable',NULL,NULL,NULL,NULL),
(90,3,10,'Shampoo',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0210','01','orderable',NULL,NULL,NULL,NULL),
(91,3,10,'Conditioner',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0210','02','orderable',NULL,NULL,NULL,NULL),
(92,3,10,'Comb, brush',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0212','00','orderable',NULL,NULL,NULL,NULL),
(93,3,10,'Grooming',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0214','00','orderable',NULL,NULL,NULL,NULL),
(94,3,10,'Deodorant',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0216','00','orderable',NULL,NULL,NULL,NULL),
(95,3,10,'Shavers, shaving cream',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0218','00','orderable',NULL,NULL,NULL,NULL),
(96,3,10,'Feminine care products',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0220','00','orderable',NULL,NULL,NULL,NULL),
(97,3,10,'Male hygiene',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0221','00','orderable',NULL,NULL,NULL,NULL),
(98,3,10,'Lotions, powder',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0222','00','orderable',NULL,NULL,NULL,NULL),
(99,3,10,'Personal wipes',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0224','00','orderable',NULL,NULL,NULL,NULL),
(100,3,10,'Personal wipes, mixed gaylord',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0224','99','orderable',NULL,NULL,NULL,NULL),
(101,3,10,'Sanitizer',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0226','00','orderable',NULL,NULL,NULL,NULL),
(102,3,10,'Denture products',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0230','00','orderable',NULL,NULL,NULL,NULL),
(103,3,10,'Eye care',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0232','00','orderable',NULL,NULL,NULL,NULL),
(104,3,10,'Sunglasses',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0240','00','orderable',NULL,NULL,NULL,NULL),
(105,3,10,'Personal care kit (beyond bathroom items)',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0241','00','orderable',NULL,NULL,NULL,NULL),
(106,3,10,'Sun block',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0242','00','orderable',NULL,NULL,NULL,NULL),
(107,3,10,'First aid kit',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0250','00','orderable',NULL,NULL,NULL,NULL),
(108,3,10,'First aid supplies',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0252','00','orderable',NULL,NULL,NULL,NULL),
(109,3,10,'Rehydration salts',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0253','00','orderable',NULL,NULL,NULL,NULL),
(110,3,10,'Gloves, disposable',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0254','00','orderable',NULL,NULL,NULL,NULL),
(111,3,10,'Protective suits',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0258','00','orderable',NULL,NULL,NULL,NULL),
(112,3,10,'OTC drugs, adult',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0263','00','orderable',NULL,NULL,NULL,NULL),
(113,3,10,'OTC drugs, child',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0265','00','orderable',NULL,NULL,NULL,NULL),
(114,3,10,'Adult diapers, case: Small',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0270','01','orderable',NULL,NULL,NULL,NULL),
(115,3,10,'Adult diapers, case: Medium',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0270','02','orderable',NULL,NULL,NULL,NULL),
(116,3,10,'Adult diapers, case: Large',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0270','03','orderable',NULL,NULL,NULL,NULL),
(117,3,10,'Adult diapers, case: XL',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0270','04','orderable',NULL,NULL,NULL,NULL),
(118,3,10,'Adult diapers, case: XXL',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0270','05','orderable',NULL,NULL,NULL,NULL),
(119,3,10,'Adult diapers, mixed gaylord',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0270','99','orderable',NULL,NULL,NULL,NULL),
(120,3,10,'Bed liners / adult pads',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0272','00','orderable',NULL,NULL,NULL,NULL),
(121,3,10,'Medical supplies',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0276','00','orderable',NULL,NULL,NULL,NULL),
(122,3,10,'Isolation gown, hat, shoe covers',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0278','00','orderable',NULL,NULL,NULL,NULL),
(123,3,10,'Lab coat',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0279','00','orderable',NULL,NULL,NULL,NULL),
(124,3,10,'Head protection',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0280','00','orderable',NULL,NULL,NULL,NULL),
(125,3,10,'Gloves, work',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0282','00','orderable',NULL,NULL,NULL,NULL),
(126,3,10,'Boots, rubber',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0283','00','orderable',NULL,NULL,NULL,NULL),
(127,3,10,'PPE masks',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0284','00','orderable',NULL,NULL,NULL,NULL),
(128,3,10,'Eye protection',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0286','00','orderable',NULL,NULL,NULL,NULL),
(129,3,10,'Ear protection',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0287','00','orderable',NULL,NULL,NULL,NULL),
(130,4,10,'Disposables, misc',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0300','00','sort_hold',NULL,NULL,NULL,NULL),
(131,4,10,'Plates, disposable',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0310','00','orderable',NULL,NULL,NULL,NULL),
(132,4,10,'Bowls, disposable',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0312','00','orderable',NULL,NULL,NULL,NULL),
(133,4,10,'Cups, disposable',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0314','00','orderable',NULL,NULL,NULL,NULL),
(134,4,10,'Cutlery kits, disposable',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0316','00','orderable',NULL,NULL,NULL,NULL),
(135,4,10,'Paper towels, household rolls',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0318','00','orderable',NULL,NULL,NULL,NULL),
(136,4,10,'Paper towels, C-fold (dispenser)',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0318','01','orderable',NULL,NULL,NULL,NULL),
(137,4,10,'Paper towels, multi-fold (dispenser)',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0318','02','orderable',NULL,NULL,NULL,NULL),
(138,4,10,'Paper towels, single-fold packs',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0318','03','orderable',NULL,NULL,NULL,NULL),
(139,4,10,'Paper towels, industrial giant roll',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0318','90','orderable',NULL,NULL,NULL,NULL),
(140,4,10,'Shop towels, boxed sheets',NULL,NULL,1,'2026-11-17 22:18:53','2026-11-17 22:18:53','0318','91','orderable',NULL,NULL,NULL,NULL),
(141,4,10,'Napkins, disposable',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0320','00','orderable',NULL,NULL,NULL,NULL),
(142,4,10,'Tissues',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0330','00','orderable',NULL,NULL,NULL,NULL),
(143,4,10,'Toilet paper, household',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0332','00','orderable',NULL,NULL,NULL,NULL),
(144,4,10,'Toilet paper, giant dispenser roll',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0332','90','orderable',NULL,NULL,NULL,NULL),
(145,4,10,'Table cloths',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0340','00','orderable',NULL,NULL,NULL,NULL),
(146,4,10,'Cooking / baking disposables',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0342','00','orderable',NULL,NULL,NULL,NULL),
(147,4,10,'Sandwich bags',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0350','00','orderable',NULL,NULL,NULL,NULL),
(148,4,10,'Garbage bags',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0352','00','orderable',NULL,NULL,NULL,NULL),
(149,4,10,'Wraps (aluminum, plastic, wax)',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0354','00','orderable',NULL,NULL,NULL,NULL),
(150,5,10,'Baby kit',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0400','00','orderable',NULL,NULL,NULL,NULL),
(151,5,10,'Baby supplies, misc',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0401','00','orderable',NULL,NULL,NULL,NULL),
(152,5,10,'Diaper bags',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0402','00','orderable',NULL,NULL,NULL,NULL),
(153,5,10,'Diapers, newborn',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0404','00','orderable',NULL,NULL,NULL,NULL),
(154,5,10,'Diapers, size 1',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0404','01','orderable',NULL,NULL,NULL,NULL),
(155,5,10,'Diapers, size 2',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0404','02','orderable',NULL,NULL,NULL,NULL),
(156,5,10,'Diapers, size 3',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0404','03','orderable',NULL,NULL,NULL,NULL),
(157,5,10,'Diapers, size 4',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0404','04','orderable',NULL,NULL,NULL,NULL),
(158,5,10,'Diapers, size 5',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0404','05','orderable',NULL,NULL,NULL,NULL),
(159,5,10,'Diapers, size 6',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0404','06','orderable',NULL,NULL,NULL,NULL),
(160,5,10,'Diapers, size 7',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0404','07','orderable',NULL,NULL,NULL,NULL),
(161,5,10,'Diapers, size 8',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0404','08','orderable',NULL,NULL,NULL,NULL),
(162,5,10,'Diapers, overnight',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0404','10','orderable',NULL,NULL,NULL,NULL),
(163,5,10,'Diapers, mixed / gaylord',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0404','99','orderable',NULL,NULL,NULL,NULL),
(164,5,10,'Baby wipes',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0410','00','orderable',NULL,NULL,NULL,NULL),
(165,5,10,'Baby washcloths',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0412','00','orderable',NULL,NULL,NULL,NULL),
(166,5,10,'Baby lotion',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0414','00','orderable',NULL,NULL,NULL,NULL),
(167,5,10,'Baby clothes',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0420','00','orderable',NULL,NULL,NULL,NULL),
(168,5,10,'Baby outerwear',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0422','00','orderable',NULL,NULL,NULL,NULL),
(169,5,10,'Baby blankets',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0424','00','orderable',NULL,NULL,NULL,NULL),
(170,5,10,'Nursing pads',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0430','00','orderable',NULL,NULL,NULL,NULL),
(171,5,10,'Baby food',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0440','00','orderable',NULL,NULL,NULL,NULL),
(172,5,10,'Baby formula, powder',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0442','00','orderable',NULL,NULL,NULL,NULL),
(173,5,10,'Baby formula, liquid',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0442','01','orderable',NULL,NULL,NULL,NULL),
(174,5,10,'Toddler milk',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0443','00','orderable',NULL,NULL,NULL,NULL),
(175,5,10,'PediaSure',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0444','00','orderable',NULL,NULL,NULL,NULL),
(176,5,10,'Pedialyte',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0446','00','orderable',NULL,NULL,NULL,NULL),
(177,5,10,'Baby juice',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0448','00','orderable',NULL,NULL,NULL,NULL),
(178,5,10,'Baby water',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0450','00','orderable',NULL,NULL,NULL,NULL),
(179,5,10,'Baby bottles',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0460','00','orderable',NULL,NULL,NULL,NULL),
(180,5,10,'Pacifiers & baby toys',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0462','00','orderable',NULL,NULL,NULL,NULL),
(181,5,10,'Pull-ups',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0470','00','orderable',NULL,NULL,NULL,NULL),
(182,5,10,'Children\'s disaster kits',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0480','00','orderable',NULL,NULL,NULL,NULL),
(183,5,10,'Games, crafts',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0482','00','orderable',NULL,NULL,NULL,NULL),
(184,5,10,'Plush toys',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0484','00','orderable',NULL,NULL,NULL,NULL),
(185,5,10,'Toys, all',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0486','00','orderable',NULL,NULL,NULL,NULL),
(186,5,10,'Toy dolls',NULL,NULL,0,'2026-11-17 22:18:54','2026-11-17 22:18:54','0488','00','retired',NULL,NULL,NULL,NULL),
(187,5,10,'School kits',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0490','00','orderable',NULL,NULL,NULL,NULL),
(188,5,10,'School supplies',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0492','00','orderable',NULL,NULL,NULL,NULL),
(189,5,10,'Car seats, children',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0494','00','orderable',NULL,NULL,NULL,NULL),
(190,5,10,'Safety equipment',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0498','00','orderable',NULL,NULL,NULL,NULL),
(191,6,10,'Bedroom kits',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0500','00','orderable',NULL,NULL,NULL,NULL),
(192,6,10,'Linens, misc',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0501','00','orderable',NULL,NULL,NULL,NULL),
(193,6,10,'Bedding kits',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0502','00','orderable',NULL,NULL,NULL,NULL),
(194,6,10,'Sheets, Twin',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0510','01','orderable',NULL,NULL,NULL,NULL),
(195,6,10,'Sheets, Full',NULL,NULL,1,'2026-11-17 22:18:54','2026-11-17 22:18:54','0510','03','orderable',NULL,NULL,NULL,NULL),
(196,6,10,'Sheets, Queen',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0510','04','orderable',NULL,NULL,NULL,NULL),
(197,6,10,'Sheets, King',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0510','05','orderable',NULL,NULL,NULL,NULL),
(198,6,10,'Sheets, mixed',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0510','99','orderable',NULL,NULL,NULL,NULL),
(199,6,10,'Pillow cases, regular',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0520','00','orderable',NULL,NULL,NULL,NULL),
(200,6,10,'Pillow cases, king',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0522','00','orderable',NULL,NULL,NULL,NULL),
(201,6,10,'Pillows',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0524','00','orderable',NULL,NULL,NULL,NULL),
(202,6,10,'Blankets, Twin',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0525','01','orderable',NULL,NULL,NULL,NULL),
(203,6,10,'Blankets, Full',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0525','03','orderable',NULL,NULL,NULL,NULL),
(204,6,10,'Blankets, Queen',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0525','04','orderable',NULL,NULL,NULL,NULL),
(205,6,10,'Blankets, King',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0525','05','orderable',NULL,NULL,NULL,NULL),
(206,6,10,'Blankets, mixed',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0525','99','orderable',NULL,NULL,NULL,NULL),
(207,6,10,'Disaster blankets',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0531','00','orderable',NULL,NULL,NULL,NULL),
(208,6,10,'Throws (small blankets)',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0532','00','orderable',NULL,NULL,NULL,NULL),
(209,6,10,'Shipping blankets',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0533','00','orderable',NULL,NULL,NULL,NULL),
(210,6,10,'Bed liner',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0534','00','orderable',NULL,NULL,NULL,NULL),
(211,6,10,'Mattress toppers, Twin',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0540','01','orderable',NULL,NULL,NULL,NULL),
(212,6,10,'Mattress toppers, Twin XL',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0540','02','orderable',NULL,NULL,NULL,NULL),
(213,6,10,'Mattress toppers, Full',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0540','03','orderable',NULL,NULL,NULL,NULL),
(214,6,10,'Mattress toppers, Queen',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0540','04','orderable',NULL,NULL,NULL,NULL),
(215,6,10,'Mattress toppers, King',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0540','05','orderable',NULL,NULL,NULL,NULL),
(216,6,10,'Mattress toppers, Cal King',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0540','06','orderable',NULL,NULL,NULL,NULL),
(217,6,10,'Mattress toppers, mixed',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0540','99','orderable',NULL,NULL,NULL,NULL),
(218,6,10,'Bathroom kits',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0550','00','orderable',NULL,NULL,NULL,NULL),
(219,6,10,'Wash cloths',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0560','00','orderable',NULL,NULL,NULL,NULL),
(220,6,10,'Towels, hand',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0562','00','orderable',NULL,NULL,NULL,NULL),
(221,6,10,'Towels, bath',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0564','00','orderable',NULL,NULL,NULL,NULL),
(222,6,10,'Towels, misc',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0566','00','orderable',NULL,NULL,NULL,NULL),
(223,6,10,'Shower curtains',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0570','00','orderable',NULL,NULL,NULL,NULL),
(224,6,10,'Bathroom rugs',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0572','00','orderable',NULL,NULL,NULL,NULL),
(225,6,10,'Pillows, decorative',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0582','00','orderable',NULL,NULL,NULL,NULL),
(226,6,10,'Curtains',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0584','00','orderable',NULL,NULL,NULL,NULL),
(227,7,10,'Cooking kit',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0600','00','orderable',NULL,NULL,NULL,NULL),
(228,7,10,'Kitchen, misc',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0601','00','sort_hold',NULL,NULL,NULL,NULL),
(229,7,10,'Kitchen start-up kit',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0610','00','orderable',NULL,NULL,NULL,NULL),
(230,7,10,'Plates',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0612','00','orderable',NULL,NULL,NULL,NULL),
(231,7,10,'Bowls',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0614','00','orderable',NULL,NULL,NULL,NULL),
(232,7,10,'Dinnerware sets',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0615','00','orderable',NULL,NULL,NULL,NULL),
(233,7,10,'Cups, glasses',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0616','00','orderable',NULL,NULL,NULL,NULL),
(234,7,10,'Beverage tumblers, plastic',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0617','00','orderable',NULL,NULL,NULL,NULL),
(235,7,10,'Flatware',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0618','00','orderable',NULL,NULL,NULL,NULL),
(236,7,10,'Serving platters',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0620','00','orderable',NULL,NULL,NULL,NULL),
(237,7,10,'Serving utensils',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0622','00','orderable',NULL,NULL,NULL,NULL),
(238,7,10,'Pots / pans',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0630','00','orderable',NULL,NULL,NULL,NULL),
(239,7,10,'Cooking accessories',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0632','00','orderable',NULL,NULL,NULL,NULL),
(240,7,10,'Food containers',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0634','00','orderable',NULL,NULL,NULL,NULL),
(241,7,10,'Water filters',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0636','00','orderable',NULL,NULL,NULL,NULL),
(242,7,10,'Kitchen towels',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0640','00','orderable',NULL,NULL,NULL,NULL),
(243,7,10,'Air fryer',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0650','00','orderable',NULL,NULL,NULL,NULL),
(244,7,10,'Pressure / instant pots',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0655','00','orderable',NULL,NULL,NULL,NULL),
(245,8,10,'Household kits',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0700','00','orderable',NULL,NULL,NULL,NULL),
(246,8,10,'Clean-up kits',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0705','00','orderable',NULL,NULL,NULL,NULL),
(247,8,10,'Moisture absorbers',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0706','00','orderable',NULL,NULL,NULL,NULL),
(248,8,10,'Flood buckets',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0710','00','orderable',NULL,NULL,NULL,NULL),
(249,8,10,'Laundry detergent',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0720','00','orderable',NULL,NULL,NULL,NULL),
(250,8,10,'Dish soap',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0721','00','orderable',NULL,NULL,NULL,NULL),
(251,8,10,'Cleaners, misc',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0722','00','orderable',NULL,NULL,NULL,NULL),
(252,8,10,'Glass cleaner spray',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0722','01','orderable',NULL,NULL,NULL,NULL),
(253,8,10,'Degreaser spray',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0722','02','orderable',NULL,NULL,NULL,NULL),
(254,8,10,'Outdoor cleaners',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0723','00','orderable',NULL,NULL,NULL,NULL),
(255,8,10,'Bleach / OxiClean',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0724','00','orderable',NULL,NULL,NULL,NULL),
(256,8,10,'General-purpose cleaner spray',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0725','00','orderable',NULL,NULL,NULL,NULL),
(257,8,10,'Disinfectant wipes',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0726','00','orderable',NULL,NULL,NULL,NULL),
(258,8,10,'Cleaning sponges',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0728','00','orderable',NULL,NULL,NULL,NULL),
(259,8,10,'Disinfectant aerosol',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0729','00','orderable',NULL,NULL,NULL,NULL),
(260,8,10,'Gloves, cleaning',NULL,NULL,1,'2026-11-17 22:18:55','2026-11-17 22:18:55','0730','00','orderable',NULL,NULL,NULL,NULL),
(261,8,10,'Dust masks',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0732','00','orderable',NULL,NULL,NULL,NULL),
(262,8,10,'Trash / garbage cans',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0740','00','orderable',NULL,NULL,NULL,NULL),
(263,8,10,'Cleaning spray bottles',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0741','00','orderable',NULL,NULL,NULL,NULL),
(264,8,10,'Buckets / pails, empty',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0742','00','orderable',NULL,NULL,NULL,NULL),
(265,8,10,'Mop / broom / dustpan',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0744','00','orderable',NULL,NULL,NULL,NULL),
(266,8,10,'Floor care chemicals',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0746','00','orderable',NULL,NULL,NULL,NULL),
(267,8,10,'Laundry baskets',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0748','00','orderable',NULL,NULL,NULL,NULL),
(268,8,10,'Laundry bags',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0749','00','orderable',NULL,NULL,NULL,NULL),
(269,8,10,'Clothesline, pins',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0750','00','orderable',NULL,NULL,NULL,NULL),
(270,8,10,'Flashlights',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0760','00','orderable',NULL,NULL,NULL,NULL),
(271,8,10,'Phone chargers',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0761','00','orderable',NULL,NULL,NULL,NULL),
(272,8,10,'Batteries, mixed/any',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0762','00','orderable',NULL,NULL,NULL,NULL),
(273,8,10,'Batteries, AAA',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0762','01','orderable',NULL,NULL,NULL,NULL),
(274,8,10,'Batteries, AA',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0762','02','orderable',NULL,NULL,NULL,NULL),
(275,8,10,'Batteries, C',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0762','03','orderable',NULL,NULL,NULL,NULL),
(276,8,10,'Batteries, D',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0762','04','orderable',NULL,NULL,NULL,NULL),
(277,8,10,'Batteries, 9-volt',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0762','09','orderable',NULL,NULL,NULL,NULL),
(278,8,10,'Power banks',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0762','60','orderable',NULL,NULL,NULL,NULL),
(279,8,10,'Lighters / matches',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0763','00','orderable',NULL,NULL,NULL,NULL),
(280,8,10,'Candles',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0764','00','orderable',NULL,NULL,NULL,NULL),
(281,8,10,'Fire extinguishers',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0765','00','orderable',NULL,NULL,NULL,NULL),
(282,8,10,'Umbrellas / ponchos',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0766','00','orderable',NULL,NULL,NULL,NULL),
(283,8,10,'CO2 detectors',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0767','00','orderable',NULL,NULL,NULL,NULL),
(284,8,10,'Backpacks / totes',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0768','00','orderable',NULL,NULL,NULL,NULL),
(285,8,10,'Luggage / suitcases',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0769','00','orderable',NULL,NULL,NULL,NULL),
(286,8,10,'Boxes, unmade',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0770','00','orderable',NULL,NULL,NULL,NULL),
(287,8,10,'Plastic bins',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0771','00','orderable',NULL,NULL,NULL,NULL),
(288,8,10,'Packing tape',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0772','00','orderable',NULL,NULL,NULL,NULL),
(289,8,10,'Musical instruments',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0780','00','orderable',NULL,NULL,NULL,NULL),
(290,8,10,'Computers',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0781','00','orderable',NULL,NULL,NULL,NULL),
(291,8,10,'Books',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0782','00','orderable',NULL,NULL,NULL,NULL),
(292,8,10,'Videos, DVDs',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0783','00','orderable',NULL,NULL,NULL,NULL),
(293,8,10,'Wrist watches',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0784','00','orderable',NULL,NULL,NULL,NULL),
(294,8,10,'Electronics, misc',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0785','00','orderable',NULL,NULL,NULL,NULL),
(295,8,10,'Radios, portable',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0786','00','orderable',NULL,NULL,NULL,NULL),
(296,8,10,'Wall mirrors',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0787','00','orderable',NULL,NULL,NULL,NULL),
(297,8,10,'Christmas trees',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0788','00','orderable',NULL,NULL,NULL,NULL),
(298,8,10,'Holiday decorations',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0789','00','orderable',NULL,NULL,NULL,NULL),
(299,8,10,'Household, misc',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0791','00','orderable',NULL,NULL,NULL,NULL),
(300,8,10,'Irons (clothes)',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0792','00','orderable',NULL,NULL,NULL,NULL),
(301,8,10,'Utility knives',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0793','00','orderable',NULL,NULL,NULL,NULL),
(302,9,10,'Clothing packs',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0800','00','orderable',NULL,NULL,NULL,NULL),
(303,9,10,'Clothing, misc',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0801','00','orderable',NULL,NULL,NULL,NULL),
(304,9,10,'Clothing, men/boys',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0810','00','orderable',NULL,NULL,NULL,NULL),
(305,9,10,'Sweaters/jackets, men/boys',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0812','00','orderable',NULL,NULL,NULL,NULL),
(306,9,10,'Coats, men/boys',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0814','00','orderable',NULL,NULL,NULL,NULL),
(307,9,10,'Clothing, women/girls',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0820','00','orderable',NULL,NULL,NULL,NULL),
(308,9,10,'Sweaters/jackets, women/girls',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0822','00','orderable',NULL,NULL,NULL,NULL),
(309,9,10,'Clothing, children\'s',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0823','00','orderable',NULL,NULL,NULL,NULL),
(310,9,10,'Coats, women/girls',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0824','00','orderable',NULL,NULL,NULL,NULL),
(311,9,10,'Underwear, men/boys',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0830','00','orderable',NULL,NULL,NULL,NULL),
(312,9,10,'Underwear, women/girls',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0832','00','orderable',NULL,NULL,NULL,NULL),
(313,9,10,'T-shirts',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0834','00','orderable',NULL,NULL,NULL,NULL),
(314,9,10,'Socks, men/boys',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0840','00','orderable',NULL,NULL,NULL,NULL),
(315,9,10,'Socks, women/girls',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0842','00','orderable',NULL,NULL,NULL,NULL),
(316,9,10,'Footwear, men/boys',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0850','00','orderable',NULL,NULL,NULL,NULL),
(317,9,10,'Footwear, women/girls',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0852','00','orderable',NULL,NULL,NULL,NULL),
(318,9,10,'Accessories, men\'s',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0860','00','orderable',NULL,NULL,NULL,NULL),
(319,9,10,'Accessories, women\'s',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0862','00','orderable',NULL,NULL,NULL,NULL),
(320,9,10,'Hangers',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0864','00','orderable',NULL,NULL,NULL,NULL),
(321,9,10,'Hats / beanies / visors',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0870','00','orderable',NULL,NULL,NULL,NULL),
(322,9,10,'Unsorted clothes',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0899','00','sort_hold',NULL,NULL,NULL,NULL),
(323,10,10,'Evacuation kits',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0900','00','orderable',NULL,NULL,NULL,NULL),
(324,10,10,'Outdoor, misc',NULL,NULL,1,'2026-11-17 22:18:56','2026-11-17 22:18:56','0901','00','sort_hold',NULL,NULL,NULL,NULL),
(325,10,10,'Rope (clothesline, camping — 100 ft)',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0902','00','orderable',NULL,NULL,NULL,NULL),
(326,10,10,'Tents, canopies',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0904','00','orderable',NULL,NULL,NULL,NULL),
(327,10,10,'Grill fuels, charcoal',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0905','01','orderable',NULL,NULL,NULL,NULL),
(328,10,10,'Grill fuels, lighter fluid',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0905','02','orderable',NULL,NULL,NULL,NULL),
(329,10,10,'Grill fuels, propane',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0905','03','orderable',NULL,NULL,NULL,NULL),
(330,10,10,'Sleeping bags',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0906','00','orderable',NULL,NULL,NULL,NULL),
(331,10,10,'Hand warmers',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0907','00','orderable',NULL,NULL,NULL,NULL),
(332,10,10,'Camping chairs',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0908','00','orderable',NULL,NULL,NULL,NULL),
(333,10,10,'Air / foam mattresses',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0909','00','orderable',NULL,NULL,NULL,NULL),
(334,10,10,'Cots, portable beds',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0910','00','orderable',NULL,NULL,NULL,NULL),
(335,10,10,'Camp stoves / grills',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0912','00','orderable',NULL,NULL,NULL,NULL),
(336,10,10,'Portable toilets',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0914','00','orderable',NULL,NULL,NULL,NULL),
(337,10,10,'Kerosene heaters',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0915','00','orderable',NULL,NULL,NULL,NULL),
(338,10,10,'Coolers',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0916','00','orderable',NULL,NULL,NULL,NULL),
(339,10,10,'Water jugs',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0917','00','orderable',NULL,NULL,NULL,NULL),
(340,10,10,'Storage containers, plastic',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0918','00','orderable',NULL,NULL,NULL,NULL),
(341,10,10,'Repellent / pest control',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0920','00','orderable',NULL,NULL,NULL,NULL),
(342,10,10,'Sporting goods',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0926','00','orderable',NULL,NULL,NULL,NULL),
(343,10,10,'Gardening tools',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0930','00','orderable',NULL,NULL,NULL,NULL),
(344,10,10,'Carts, wheelbarrows',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0932','00','orderable',NULL,NULL,NULL,NULL),
(345,10,10,'Roof tarping kit (nails, hammer, instructions)',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0938','00','orderable',NULL,NULL,NULL,NULL),
(346,10,10,'Roofing nails',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0939','00','orderable',NULL,NULL,NULL,NULL),
(347,10,10,'Hand tools',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0940','00','orderable',NULL,NULL,NULL,NULL),
(348,10,10,'Chainsaws',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0941','00','orderable',NULL,NULL,NULL,NULL),
(349,10,10,'Power tools',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0942','00','orderable',NULL,NULL,NULL,NULL),
(350,10,10,'Extension cords',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0943','00','orderable',NULL,NULL,NULL,NULL),
(351,10,10,'Shop vacs',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0944','00','orderable',NULL,NULL,NULL,NULL),
(352,10,10,'Automotive, misc',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0946','00','orderable',NULL,NULL,NULL,NULL),
(353,10,10,'Motor oil',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0947','00','orderable',NULL,NULL,NULL,NULL),
(354,10,10,'2-cycle oil',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0947','01','orderable',NULL,NULL,NULL,NULL),
(355,10,10,'Bar & chain oil',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0947','02','orderable',NULL,NULL,NULL,NULL),
(356,10,10,'Tarps, small',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0950','10','orderable',NULL,NULL,NULL,NULL),
(357,10,10,'Tarps, 8×10',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0950','11','orderable',NULL,NULL,NULL,NULL),
(358,10,10,'Tarps, 8×12',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0950','12','orderable',NULL,NULL,NULL,NULL),
(359,10,10,'Tarps, medium',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0950','20','orderable',NULL,NULL,NULL,NULL),
(360,10,10,'Tarps, 16×20',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0950','21','orderable',NULL,NULL,NULL,NULL),
(361,10,10,'Tarps, 18×24',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0950','22','orderable',NULL,NULL,NULL,NULL),
(362,10,10,'Tarps, large',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0950','30','orderable',NULL,NULL,NULL,NULL),
(363,10,10,'Tarps, 20×30',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0950','31','orderable',NULL,NULL,NULL,NULL),
(364,10,10,'Tarps, 20×40',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0950','32','orderable',NULL,NULL,NULL,NULL),
(365,10,10,'Tarps, extra large',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0950','40','orderable',NULL,NULL,NULL,NULL),
(366,10,10,'Tarps, 40×60',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0950','41','orderable',NULL,NULL,NULL,NULL),
(367,10,10,'Tarps, roll (bulk material)',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0950','90','orderable',NULL,NULL,NULL,NULL),
(368,10,10,'Tarps, mixed / all sizes',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0950','99','orderable',NULL,NULL,NULL,NULL),
(369,10,10,'Plastic sheeting',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0952','00','orderable',NULL,NULL,NULL,NULL),
(370,10,10,'Painting supplies',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0960','00','orderable',NULL,NULL,NULL,NULL),
(371,10,10,'Tape (electrical / duct / masking)',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0964','00','orderable',NULL,NULL,NULL,NULL),
(372,10,10,'Ladders',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0970','00','orderable',NULL,NULL,NULL,NULL),
(373,10,10,'Sump pumps',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0978','00','orderable',NULL,NULL,NULL,NULL),
(374,10,10,'Generators',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0980','00','orderable',NULL,NULL,NULL,NULL),
(375,10,10,'Fuel containers',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0982','00','orderable',NULL,NULL,NULL,NULL),
(376,10,10,'Fuel containers, kerosene',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0982','01','orderable',NULL,NULL,NULL,NULL),
(377,10,10,'Portable lights',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0984','00','orderable',NULL,NULL,NULL,NULL),
(378,10,10,'Air pumps',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0986','00','orderable',NULL,NULL,NULL,NULL),
(379,10,10,'Bicycles',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0988','00','orderable',NULL,NULL,NULL,NULL),
(380,10,10,'Overnight kits',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0990','00','orderable',NULL,NULL,NULL,NULL),
(381,10,10,'Communication equipment',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0991','00','orderable',NULL,NULL,NULL,NULL),
(382,10,10,'Casket, adult (Funeral)',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0994','00','orderable',NULL,NULL,NULL,NULL),
(383,10,10,'Gift cards',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0995','00','orderable',NULL,NULL,NULL,NULL),
(384,10,10,'Empty pallets',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0996','00','orderable',NULL,NULL,NULL,NULL),
(385,10,10,'Unsorted donations',NULL,NULL,1,'2026-11-17 22:18:57','2026-11-17 22:18:57','0997','00','sort_hold',NULL,NULL,NULL,NULL),
(386,10,10,'Non-distributable, non-clothing',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','0998','00','sort_hold',NULL,NULL,NULL,NULL),
(387,10,10,'Non-distributable, clothing',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','0999','00','sort_hold',NULL,NULL,NULL,NULL),
(388,11,10,'Large appliances, misc',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1000','00','orderable',NULL,NULL,NULL,NULL),
(389,11,10,'Washing machines',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1100','00','orderable',NULL,NULL,NULL,NULL),
(390,11,10,'Clothes dryers',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1155','00','orderable',NULL,NULL,NULL,NULL),
(391,11,10,'Refrigerators',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1201','00','orderable',NULL,NULL,NULL,NULL),
(392,11,10,'Stoves / ranges & ovens',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1225','00','orderable',NULL,NULL,NULL,NULL),
(393,11,10,'Range hoods',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1230','00','orderable',NULL,NULL,NULL,NULL),
(394,11,10,'Dishwashers',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1275','00','orderable',NULL,NULL,NULL,NULL),
(395,11,10,'Hot water heaters',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1301','00','orderable',NULL,NULL,NULL,NULL),
(396,12,10,'Small appliances, misc',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1500','00','orderable',NULL,NULL,NULL,NULL),
(397,12,10,'Space heaters',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1505','00','orderable',NULL,NULL,NULL,NULL),
(398,12,10,'Microwaves',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1525','00','orderable',NULL,NULL,NULL,NULL),
(399,12,10,'Toasters',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1550','00','orderable',NULL,NULL,NULL,NULL),
(400,12,10,'Toaster ovens',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1555','00','orderable',NULL,NULL,NULL,NULL),
(401,12,10,'Coffeemakers',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1575','00','orderable',NULL,NULL,NULL,NULL),
(402,12,10,'Electric fans',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','1610','00','orderable',NULL,NULL,NULL,NULL),
(403,13,10,'Floor tile',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2202','00','orderable',NULL,NULL,NULL,NULL),
(404,13,10,'Wall base trim',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2203','00','orderable',NULL,NULL,NULL,NULL),
(405,13,10,'Floor tile, vinyl',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2212','00','orderable',NULL,NULL,NULL,NULL),
(406,13,10,'Floor tile, ceramic',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2214','00','orderable',NULL,NULL,NULL,NULL),
(407,13,10,'Flooring, wood',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2218','00','orderable',NULL,NULL,NULL,NULL),
(408,13,10,'Carpet squares',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2230','00','orderable',NULL,NULL,NULL,NULL),
(409,13,10,'Sheetrock',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2302','00','orderable',NULL,NULL,NULL,NULL),
(410,13,10,'Spackling compound',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2310','00','orderable',NULL,NULL,NULL,NULL),
(411,13,10,'Wall tile, ceramic',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2332','00','orderable',NULL,NULL,NULL,NULL),
(412,13,10,'Roofing, aluminum',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2380','00','orderable',NULL,NULL,NULL,NULL),
(413,13,10,'Cabinetry',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2502','00','orderable',NULL,NULL,NULL,NULL),
(414,13,10,'Kitchen cabinets, upper',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2510','00','orderable',NULL,NULL,NULL,NULL),
(415,13,10,'Kitchen cabinets, upper corner',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2512','00','orderable',NULL,NULL,NULL,NULL),
(416,13,10,'Kitchen cabinets, lower',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2520','00','orderable',NULL,NULL,NULL,NULL),
(417,13,10,'Kitchen cabinets, lower corner',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2522','00','orderable',NULL,NULL,NULL,NULL),
(418,13,10,'Kitchen sinks',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2530','00','orderable',NULL,NULL,NULL,NULL),
(419,13,10,'Bathroom vanities',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2552','00','orderable',NULL,NULL,NULL,NULL),
(420,13,10,'Doors, interior',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2610','00','orderable',NULL,NULL,NULL,NULL),
(421,13,10,'Doors, interior panel',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2612','00','orderable',NULL,NULL,NULL,NULL),
(422,13,10,'Doors, interior bi-fold',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2614','00','orderable',NULL,NULL,NULL,NULL),
(423,13,10,'Doors, exterior misc',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2630','00','orderable',NULL,NULL,NULL,NULL),
(424,13,10,'Windows, misc',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2650','00','orderable',NULL,NULL,NULL,NULL),
(425,13,10,'Hot tubs',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2750','00','orderable',NULL,NULL,NULL,NULL),
(426,13,10,'Wood clamps',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','2812','00','orderable',NULL,NULL,NULL,NULL),
(427,14,10,'Furniture parts',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3100','00','orderable',NULL,NULL,NULL,NULL),
(428,14,10,'Chairs, dining',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3121','00','orderable',NULL,NULL,NULL,NULL),
(429,14,10,'Tables, dining',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3125','00','orderable',NULL,NULL,NULL,NULL),
(430,14,10,'TV tables / trays',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3141','00','orderable',NULL,NULL,NULL,NULL),
(431,14,10,'Buffets',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3150','00','orderable',NULL,NULL,NULL,NULL),
(432,14,10,'Chairs, office',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3207','00','orderable',NULL,NULL,NULL,NULL),
(433,14,10,'Chairs, indoor folding',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3305','00','orderable',NULL,NULL,NULL,NULL),
(434,14,10,'Couches / sofas',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3307','00','orderable',NULL,NULL,NULL,NULL),
(435,14,10,'Benches',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3310','00','orderable',NULL,NULL,NULL,NULL),
(436,14,10,'Entertainment centers',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3320','00','orderable',NULL,NULL,NULL,NULL),
(437,14,10,'End tables',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3341','00','orderable',NULL,NULL,NULL,NULL),
(438,14,10,'Coffee tables',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3345','00','orderable',NULL,NULL,NULL,NULL),
(439,14,10,'Lamps',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3350','00','orderable',NULL,NULL,NULL,NULL),
(440,14,10,'Mattresses, Twin',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3401','01','orderable',NULL,NULL,NULL,NULL),
(441,14,10,'Mattresses, Twin XL',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3401','02','orderable',NULL,NULL,NULL,NULL),
(442,14,10,'Mattresses, Full',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3401','03','orderable',NULL,NULL,NULL,NULL),
(443,14,10,'Mattresses, Queen',NULL,NULL,1,'2026-11-17 22:18:58','2026-11-17 22:18:58','3401','04','orderable',NULL,NULL,NULL,NULL),
(444,14,10,'Mattresses, King',NULL,NULL,1,'2026-11-17 22:18:59','2026-11-17 22:18:59','3401','05','orderable',NULL,NULL,NULL,NULL),
(445,14,10,'Mattresses, Cal King',NULL,NULL,1,'2026-11-17 22:18:59','2026-11-17 22:18:59','3401','06','orderable',NULL,NULL,NULL,NULL),
(446,14,10,'Mattresses, mixed/unknown',NULL,NULL,1,'2026-11-17 22:18:59','2026-11-17 22:18:59','3401','99','orderable',NULL,NULL,NULL,NULL),
(447,14,10,'Box springs, Twin',NULL,NULL,1,'2026-11-17 22:18:59','2026-11-17 22:18:59','3411','01','orderable',NULL,NULL,NULL,NULL),
(448,14,10,'Box springs, Twin XL',NULL,NULL,1,'2026-11-17 22:18:59','2026-11-17 22:18:59','3411','02','orderable',NULL,NULL,NULL,NULL),
(449,14,10,'Box springs, Full',NULL,NULL,1,'2026-11-17 22:18:59','2026-11-17 22:18:59','3411','03','orderable',NULL,NULL,NULL,NULL),
(450,14,10,'Box springs, Queen',NULL,NULL,1,'2026-11-17 22:18:59','2026-11-17 22:18:59','3411','04','orderable',NULL,NULL,NULL,NULL),
(451,14,10,'Box springs, King',NULL,NULL,1,'2026-11-17 22:18:59','2026-11-17 22:18:59','3411','05','orderable',NULL,NULL,NULL,NULL),
(452,14,10,'Box springs, Cal King',NULL,NULL,1,'2026-11-17 22:18:59','2026-11-17 22:18:59','3411','06','orderable',NULL,NULL,NULL,NULL),
(453,14,10,'Box springs, mixed/unknown',NULL,NULL,1,'2026-11-17 22:18:59','2026-11-17 22:18:59','3411','99','orderable',NULL,NULL,NULL,NULL),
(454,14,10,'Bed frames',NULL,NULL,1,'2026-11-17 22:18:59','2026-11-17 22:18:59','3425','00','orderable',NULL,NULL,NULL,NULL),
(455,14,10,'Chests of drawers',NULL,NULL,1,'2026-11-17 22:18:59','2026-11-17 22:18:59','3451','00','orderable',NULL,NULL,NULL,NULL),
(456,14,10,'Folding card tables',NULL,NULL,1,'2026-11-17 22:18:59','2026-11-17 22:18:59','3924','00','orderable',NULL,NULL,NULL,NULL),
(457,15,10,'Holy Bible',NULL,NULL,1,'2026-11-17 22:18:59','2026-11-17 22:18:59','7777','00','orderable',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `itemtypes` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `kiosk_locations`
--

DROP TABLE IF EXISTS `kiosk_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `kiosk_locations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `welcome_message` varchar(255) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kiosk_locations`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `kiosk_locations` WRITE;
/*!40000 ALTER TABLE `kiosk_locations` DISABLE KEYS */;
INSERT INTO `kiosk_locations` VALUES
(1,'Main Location',NULL,1,'2026-11-17 22:18:26','2026-11-17 22:18:26');
/*!40000 ALTER TABLE `kiosk_locations` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `kiosk_settings`
--

DROP TABLE IF EXISTS `kiosk_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `kiosk_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `idle_reset_minutes` int(10) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kiosk_settings`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `kiosk_settings` WRITE;
/*!40000 ALTER TABLE `kiosk_settings` DISABLE KEYS */;
INSERT INTO `kiosk_settings` VALUES
(1,NULL,'2026-11-17 22:18:26','2026-11-17 22:18:26');
/*!40000 ALTER TABLE `kiosk_settings` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `kiosk_suggestions`
--

DROP TABLE IF EXISTS `kiosk_suggestions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `kiosk_suggestions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `kind` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `kiosk_suggestions_kind_value_unique` (`kind`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kiosk_suggestions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `kiosk_suggestions` WRITE;
/*!40000 ALTER TABLE `kiosk_suggestions` DISABLE KEYS */;
/*!40000 ALTER TABLE `kiosk_suggestions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `label_settings`
--

DROP TABLE IF EXISTS `label_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `label_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pallet_label_media` varchar(40) NOT NULL DEFAULT 'label_large',
  `inventory_label_media` varchar(40) NOT NULL DEFAULT 'label_small',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `label_settings`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `label_settings` WRITE;
/*!40000 ALTER TABLE `label_settings` DISABLE KEYS */;
INSERT INTO `label_settings` VALUES
(1,'label_large','label_small','2026-11-17 22:18:44','2026-11-17 22:18:44');
/*!40000 ALTER TABLE `label_settings` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `locations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `PullSequence` int(11) DEFAULT NULL,
  `Route` varchar(255) DEFAULT NULL,
  `Block` varchar(255) DEFAULT NULL,
  `Aisle` varchar(255) DEFAULT NULL,
  `Lane` varchar(255) DEFAULT NULL,
  `Stack` varchar(255) DEFAULT NULL,
  `use_id` bigint(20) unsigned DEFAULT NULL,
  `code` text NOT NULL,
  `status` enum('active','archived') NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `warehouse_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `locations_code_unique` (`code`) USING HASH,
  KEY `locations_use_id_foreign` (`use_id`),
  KEY `locations_warehouse_id_foreign` (`warehouse_id`),
  CONSTRAINT `locations_use_id_foreign` FOREIGN KEY (`use_id`) REFERENCES `uses` (`id`) ON DELETE SET NULL,
  CONSTRAINT `locations_warehouse_id_foreign` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locations`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `locations` WRITE;
/*!40000 ALTER TABLE `locations` DISABLE KEYS */;
/*!40000 ALTER TABLE `locations` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `login_history`
--

DROP TABLE IF EXISTS `login_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `person_id` bigint(20) unsigned NOT NULL,
  `method` varchar(255) NOT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `logged_in_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `login_history_person_id_logged_in_at_index` (`person_id`,`logged_in_at`),
  CONSTRAINT `login_history_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_history`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `login_history` WRITE;
/*!40000 ALTER TABLE `login_history` DISABLE KEYS */;
INSERT INTO `login_history` VALUES
(1,2,'password','172.21.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36','2026-11-18 03:39:20','2026-11-18 03:39:20','2026-11-18 03:39:20'),
(2,2,'password','172.21.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36','2026-11-18 20:39:03','2026-11-18 20:39:03','2026-11-18 20:39:03');
/*!40000 ALTER TABLE `login_history` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mail_settings`
--

DROP TABLE IF EXISTS `mail_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mail_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `mailer` varchar(255) DEFAULT NULL,
  `from_address` varchar(255) DEFAULT NULL,
  `from_name` varchar(255) DEFAULT NULL,
  `resend_key` text DEFAULT NULL,
  `smtp_host` varchar(255) DEFAULT NULL,
  `smtp_port` int(10) unsigned DEFAULT NULL,
  `smtp_username` varchar(255) DEFAULT NULL,
  `smtp_password` text DEFAULT NULL,
  `feedback_notify_emails` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mail_settings`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mail_settings` WRITE;
/*!40000 ALTER TABLE `mail_settings` DISABLE KEYS */;
INSERT INTO `mail_settings` VALUES
(1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-17 22:18:43','2026-11-17 22:18:43');
/*!40000 ALTER TABLE `mail_settings` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `managed_devices`
--

DROP TABLE IF EXISTS `managed_devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `managed_devices` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `trust_id` bigint(20) unsigned DEFAULT NULL,
  `device_uuid` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `mac_address` varchar(255) DEFAULT NULL,
  `kiosk_location_id` bigint(20) unsigned DEFAULT NULL,
  `session_token_hash` varchar(64) DEFAULT NULL,
  `revoked_at` timestamp NULL DEFAULT NULL,
  `update_channel` varchar(20) NOT NULL DEFAULT 'stable',
  `os_auto_update_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `kiosk_function` varchar(40) DEFAULT NULL,
  `language` varchar(10) DEFAULT NULL,
  `language_revision` int(10) unsigned NOT NULL DEFAULT 0,
  `app_version` varchar(255) DEFAULT NULL,
  `os_version` varchar(255) DEFAULT NULL,
  `architecture` varchar(255) DEFAULT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `cpu_temp_c` decimal(5,1) DEFAULT NULL,
  `last_ip` varchar(45) DEFAULT NULL,
  `last_seen_at` timestamp NULL DEFAULT NULL,
  `paired_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `platform` varchar(20) DEFAULT NULL,
  `reported_printers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`reported_printers`)),
  `printers_reported_at` timestamp NULL DEFAULT NULL,
  `wake_channel` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `managed_devices_device_uuid_unique` (`device_uuid`),
  UNIQUE KEY `managed_devices_wake_channel_unique` (`wake_channel`),
  UNIQUE KEY `managed_devices_session_token_hash_unique` (`session_token_hash`),
  KEY `managed_devices_kiosk_location_id_foreign` (`kiosk_location_id`),
  KEY `managed_devices_trust_id_foreign` (`trust_id`),
  CONSTRAINT `managed_devices_kiosk_location_id_foreign` FOREIGN KEY (`kiosk_location_id`) REFERENCES `kiosk_locations` (`id`) ON DELETE SET NULL,
  CONSTRAINT `managed_devices_trust_id_foreign` FOREIGN KEY (`trust_id`) REFERENCES `trusts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `managed_devices`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `managed_devices` WRITE;
/*!40000 ALTER TABLE `managed_devices` DISABLE KEYS */;
/*!40000 ALTER TABLE `managed_devices` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `menu_items`
--

DROP TABLE IF EXISTS `menu_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `page_id` bigint(20) unsigned DEFAULT NULL,
  `link_text` varchar(255) NOT NULL,
  `link_url` varchar(255) DEFAULT NULL,
  `submenu_page_id` bigint(20) unsigned DEFAULT NULL,
  `graphic_url` varchar(255) DEFAULT NULL,
  `order` int(11) NOT NULL DEFAULT 0,
  `group_label` varchar(255) DEFAULT NULL,
  `permission_key` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `menu_items_page_id_foreign` (`page_id`),
  KEY `menu_items_submenu_page_id_foreign` (`submenu_page_id`),
  CONSTRAINT `menu_items_page_id_foreign` FOREIGN KEY (`page_id`) REFERENCES `pages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `menu_items_submenu_page_id_foreign` FOREIGN KEY (`submenu_page_id`) REFERENCES `pages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_items`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `menu_items` WRITE;
/*!40000 ALTER TABLE `menu_items` DISABLE KEYS */;
INSERT INTO `menu_items` VALUES
(1,1,'Order Entry','/order-entry',NULL,'/img/order-entry-icon.webp',40,NULL,NULL,'2026-11-17 22:17:33','2026-11-17 22:18:18'),
(2,1,'Order Filling','/order-filling',NULL,'/img/order-filling-icon.webp',50,NULL,'manage-orders','2026-11-17 22:17:33','2026-11-17 22:18:30'),
(3,1,'Donation Sorting','/donation-sorting',NULL,'/img/donation-sorting-icon.webp',20,NULL,'manage-sorting','2026-11-17 22:17:33','2026-11-17 22:18:18'),
(4,1,'Inventory Movement','/inventory-movement',NULL,'/img/inventory-movement-icon.webp',30,NULL,'manage-pallets','2026-11-17 22:17:33','2026-11-17 22:18:18'),
(5,1,'Reports Menu','#reports',NULL,'/img/printing-reports.webp',70,NULL,'general-access','2026-11-17 22:17:33','2026-11-17 22:18:18'),
(6,1,'Setup Menu','#setup',NULL,'/img/settings-icon.webp',90,NULL,'general-access','2026-11-17 22:17:33','2026-11-17 22:18:18'),
(8,2,'Outstanding Orders','/reports/orders',NULL,'/img/printing-reports.webp',20,NULL,'view-reports','2026-11-17 22:17:33','2026-11-17 22:18:18'),
(9,2,'Inventory Report','/reports/inventory',NULL,'/img/reports.webp',30,NULL,'view-reports','2026-11-17 22:17:33','2026-11-17 22:18:01'),
(10,2,'Flow Reports','/reports/flow',NULL,'/img/reports.webp',40,NULL,'view-reports','2026-11-17 22:17:33','2026-11-17 22:18:43'),
(11,2,'Donor Report','/reports/donors',NULL,'/img/reports.webp',50,NULL,'view-reports','2026-11-17 22:17:33','2026-11-17 22:18:43'),
(12,2,'Partner Report','/reports/partners',NULL,'/img/reports.webp',60,NULL,'view-reports','2026-11-17 22:17:33','2026-11-17 22:18:43'),
(13,2,'Return','#main',NULL,'/img/back-arrow.webp',99,NULL,NULL,'2026-11-17 22:17:33','2026-11-17 22:17:33'),
(14,1,'Partner & Donor Info','/setup/people',NULL,'/img/donation-entry-icon.webp',60,NULL,'manage-people','2026-11-17 22:17:33','2026-11-17 22:18:18'),
(15,3,'Edit Master Item List','/setup/items',NULL,'/img/edit-items-icon.webp',20,'Warehouse Administration','manage-items','2026-11-17 22:17:33','2026-11-17 22:18:18'),
(16,3,'Edit Item Categories','/setup/categories',NULL,'/img/edit-statuses-icon.webp',30,'Warehouse Administration','manage-categories','2026-11-17 22:17:33','2026-11-17 22:18:18'),
(18,3,'Return','#main',NULL,'/img/back-arrow.webp',99,NULL,NULL,'2026-11-17 22:17:33','2026-11-17 22:17:33'),
(19,3,'Edit Location Names','/setup/locations',NULL,'/img/edit-statuses-icon.webp',33,'Warehouse Administration','manage-locations','2026-11-17 22:17:33','2026-11-17 22:18:18'),
(20,1,'Receiving','/receiving',NULL,'/img/donation-entry-icon.webp',10,NULL,'manage-receiving','2026-11-17 22:17:54','2026-11-17 22:18:18'),
(21,3,'Warehouse Backups','/setup/system',NULL,'/img/settings-icon.webp',80,'System Administration','admin-system','2026-11-17 22:17:57','2026-11-17 22:18:50'),
(22,2,'Warehouse Dashboard','/reports/dashboard',NULL,'/img/warehouse.webp',5,NULL,'view-dashboard','2026-11-17 22:18:01','2026-11-17 22:18:01'),
(23,2,'Situation Report','/reports/sitrep',NULL,'/img/printing-reports.webp',6,NULL,'view-sitrep','2026-11-17 22:18:01','2026-11-17 22:18:01'),
(24,3,'PIN Login','/setup/pin-login',NULL,'/img/edit-padlock-icon.webp',60,'System Administration','admin-system','2026-11-17 22:18:04','2026-11-17 22:18:18'),
(25,3,'Feedback & Bug Reports','/setup/feedback',NULL,'/img/settings-icon.webp',70,'System Administration','manage-feedback','2026-11-17 22:18:05','2026-11-17 22:18:18'),
(26,3,'User Activity','/setup/active-sessions',NULL,'/img/edit-users-icon.webp',55,'System Administration','admin-system','2026-11-17 22:18:06','2026-11-17 22:18:18'),
(27,3,'User Administration','/setup/users',NULL,'/img/edit-users-icon.webp',50,'System Administration','manage-users','2026-11-17 22:18:09','2026-11-17 22:18:18'),
(32,3,'Data Import','/setup/import',NULL,'/img/settings-icon.webp',75,'System Administration','manage-import','2026-11-17 22:18:16','2026-11-17 22:18:18'),
(33,3,'Site Banner','/setup/banner',NULL,'/img/settings-icon.webp',65,'System Administration','manage-feedback','2026-11-17 22:18:18','2026-11-17 22:18:18'),
(34,3,'Sign-in Kiosk','/volunteers/kiosk',NULL,'/img/edit-users-icon.webp',63,'System Administration','operate-kiosk','2026-11-17 22:18:20','2026-11-17 22:18:26'),
(35,3,'Kiosk Settings','/setup/kiosk-settings',NULL,'/img/edit-users-icon.webp',64,'System Administration','manage-kiosk','2026-11-17 22:18:29','2026-11-17 22:18:29'),
(36,1,'Shipping','/shipping',NULL,'/img/truck-delivery-icon.webp',55,NULL,'manage-orders','2026-11-17 22:18:31','2026-11-17 22:18:31'),
(37,1,'Driver Portal','/driver-portal',NULL,'/img/truck-box-icon.webp',57,NULL,'manage-orders','2026-11-17 22:18:31','2026-11-17 22:18:31'),
(38,3,'Forms & Surveys','/setup/forms',NULL,'/img/settings-icon.webp',71,'System Administration','manage-forms','2026-11-17 22:18:36','2026-11-17 22:18:36'),
(39,3,'Default Ordering Units','/setup/units',NULL,'/img/edit-statuses-icon.webp',34,'Warehouse Administration','manage-units','2026-11-17 22:18:38','2026-11-17 22:18:38'),
(40,3,'Package Types','/setup/package-types',NULL,'/img/edit-statuses-icon.webp',35,'Warehouse Administration','manage-packagetypes','2026-11-17 22:18:38','2026-11-17 22:18:38'),
(41,3,'R Station Devices','/setup/devices',NULL,'/img/edit-users-icon.webp',65,'System Administration','manage-devices','2026-11-17 22:18:39','2026-11-17 22:18:39'),
(42,1,'Print Queue','/print-queue',NULL,'/img/printing-reports.webp',58,NULL,'print-documents','2026-11-17 22:18:41','2026-11-17 22:18:41'),
(43,3,'R Station Firmware','/setup/firmware',NULL,'/img/edit-users-icon.webp',66,'System Administration','manage-firmware','2026-11-17 22:18:42','2026-11-17 22:18:42'),
(44,3,'Printers','/setup/printers',NULL,'/img/printing-reports.webp',67,'System Administration','manage-devices','2026-11-17 22:18:42','2026-11-17 22:18:42'),
(46,2,'Unfulfilled Requests','/reports/unfulfilled',NULL,'/img/printing-reports.webp',25,NULL,'view-reports','2026-11-17 22:18:42','2026-11-17 22:18:42'),
(47,3,'Testing Tools','/setup/testing',NULL,'/img/settings-icon.webp',81,'System Administration','admin-system','2026-11-17 22:18:42','2026-11-17 22:18:42'),
(48,2,'Sorting Area','/reports/sorting-area',NULL,'/img/printing-reports.webp',26,NULL,'view-reports','2026-11-17 22:18:43','2026-11-17 22:18:43'),
(49,3,'Carton Barcodes','/setup/carton-codes',NULL,'/img/edit-items-icon.webp',21,NULL,'manage-items','2026-11-17 22:18:43','2026-11-17 22:18:43'),
(50,3,'Email Settings','/setup/email',NULL,'/img/settings-icon.webp',79,'System Administration','admin-system','2026-11-17 22:18:43','2026-11-17 22:18:43'),
(51,1,'Help','/help',NULL,'/img/help-icon.webp',85,NULL,NULL,'2026-11-17 22:18:45','2026-11-17 22:18:45'),
(52,3,'Training Warehouse','/setup/training',NULL,'/img/help-icon.webp',82,NULL,'manage-training','2026-11-17 22:18:45','2026-11-17 22:18:45'),
(53,2,'Training Report Cards','/reports/training',NULL,'/img/printing-reports.webp',70,NULL,'manage-training','2026-11-17 22:18:45','2026-11-17 22:18:45'),
(54,3,'Design Votes','/setup/design-votes',NULL,'/img/printing-reports.webp',83,NULL,'manage-design-votes','2026-11-17 22:18:47','2026-11-17 22:18:47'),
(55,2,'Mailing Labels','/reports/mailing-labels',NULL,'/img/printing-reports.webp',65,NULL,'manage-people','2026-11-17 22:18:48','2026-11-17 22:18:48'),
(56,3,'Trust Console','/setup/trust',NULL,'/img/edit-users-icon.webp',68,'System Administration','manage-trusts','2026-11-17 22:18:49','2026-11-17 22:18:49'),
(57,3,'Signs','/setup/signs',NULL,'/img/signs-icon.webp',69,NULL,NULL,'2026-11-17 22:18:50','2026-11-17 22:18:50'),
(58,3,'Instance Admin','/setup/instance',NULL,'/img/settings-icon.webp',79,'System Administration','instance-admin','2026-11-17 22:18:50','2026-11-17 22:18:50');
/*!40000 ALTER TABLE `menu_items` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=243 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES
(1,'0001_01_01_000000_create_users_table',1),
(2,'0001_01_01_000001_create_cache_table',1),
(3,'0001_01_01_000002_create_jobs_table',1),
(4,'2025_01_08_202719_categories',1),
(5,'2025_01_08_202721_items',1),
(6,'2025_01_08_203435_create_people_table',1),
(7,'2025_01_08_203953_create_statuses_table',1),
(8,'2025_01_08_204002_create_orders_table',1),
(9,'2025_01_08_205446_rename_orders_to_orderdonations',1),
(10,'2025_01_08_205520_modify_orderdonations_table',1),
(11,'2025_01_08_210042_create_item_ledgers_table',1),
(12,'2025_01_08_210125_add_active_to_items_table',1),
(13,'2025_01_14_155836_create_menu_tables',1),
(14,'2025_01_15_041057_modify_type_column_in_people_table',1),
(15,'2025_01_24_011120_create_units_table',1),
(16,'2025_01_24_011130_create_packagetypes_table',1),
(17,'2025_01_24_011143_create_itemtypes_table',1),
(18,'2025_01_24_013228_update_items_table',1),
(19,'2025_01_24_040308_update_categories_table',1),
(20,'2025_01_27_031820_create_orderlines_table',1),
(21,'2025_01_27_031841_create_pallets_table',1),
(22,'2025_02_02_165919_create_table_locations',1),
(23,'2025_02_02_165920_create_table_palletstatus',1),
(24,'2025_02_02_211948_add_pallet_id_to_item_ledgers',1),
(25,'2025_02_05_000000_update_packagetypes_table',1),
(26,'2025_02_07_032500_modify_menu_pages_tables',1),
(27,'2025_02_07_032546_fill_menu_tables',1),
(28,'2025_02_10_005038_add_menu_item',1),
(29,'2025_02_10_012600_modify_locations',1),
(30,'2025_02_11_173108_modify_palletstatus_and_pallets_table',1),
(31,'2025_02_11_182644_modify_pallets_and_palletstatus_table',1),
(32,'2025_02_13_193810_modify_items_table',1),
(33,'2025_02_13_221053_create-people-roles',1),
(34,'2025_02_13_221248_modify_people_drop_type',1),
(35,'2025_02_19_170019_seed_roles_table',1),
(36,'2025_02_19_225331_create_counties_table',1),
(37,'2025_02_19_225850_create_warehouses_table',1),
(38,'2025_02_19_225935_modify_locations_table',1),
(39,'2025_02_19_230626_modify_people_table',1),
(40,'2025_02_20_154014_add_auth_fields_to_people_table',1),
(41,'2025_02_20_154339_migrate_users_to_people_table',1),
(42,'2025_02_20_155050_update_orderdonations_link_to_people',1),
(43,'2025_02_20_155051_drop_users_table',1),
(44,'2025_02_20_163441_delete_edit_users_menu_item',1),
(45,'2025_02_25_153842_add_role_bitpack_to_people_table',1),
(46,'2025_02_25_155049_reseed_roles_table',1),
(47,'2025_02_25_170215_add_role_level_to_menu_table',1),
(48,'2025_03_03_043919_create_banned_emails_table',1),
(49,'2025_03_06_231836_create_default_warehouse',1),
(50,'2026_07_12_000000_add_disposition_to_item_ledgers',1),
(51,'2026_08_12_000000_make_packagetype_id_nullable_on_orderlines',1),
(52,'2026_08_13_192244_add_family_variant_numbering_to_itemtypes_and_categories',1),
(53,'2026_08_14_011321_create_trucks_table',1),
(54,'2026_08_14_011322_rebuild_pallets_for_five_kind_model',1),
(55,'2026_08_14_011323_create_container_types_and_containers_tables',1),
(56,'2026_08_14_011324_create_streams_table',1),
(57,'2026_08_14_011325_add_pallets_enabled_to_warehouses_table',1),
(58,'2026_08_14_014948_add_receiving_fields_to_orderdonations_table',1),
(59,'2026_08_14_014949_add_donation_link_to_pallets_table',1),
(60,'2026_08_14_014950_add_receiving_menu_item',1),
(61,'2026_08_14_021144_create_permissions_tables',1),
(62,'2026_08_14_021201_drop_role_bitpack_from_people_table',1),
(63,'2026_08_14_021841_replace_role_level_with_permission_key_on_menu_items',1),
(64,'2026_08_14_120000_add_system_admin_menu_item',1),
(65,'2026_08_14_130000_move_people_menu_item_to_main_menu',1),
(66,'2026_08_14_130001_make_location_detail_fields_nullable',1),
(67,'2026_08_14_150000_add_content_fields_to_pallets',1),
(68,'2026_08_14_160000_gate_inventory_report_menu_item',1),
(69,'2026_08_15_000000_add_dashboard_and_sitrep_menu_items',1),
(70,'2026_08_15_010000_make_last_name_nullable_on_people',1),
(71,'2026_08_15_020000_add_donor_identification_pending_to_orderdonations',1),
(72,'2026_08_15_030000_add_unknown_donor_system_person',1),
(73,'2026_08_16_000000_create_pin_login_settings_table',1),
(74,'2026_08_16_000001_create_trusted_devices_table',1),
(75,'2026_08_16_000002_create_device_trust_grants_table',1),
(76,'2026_08_16_000003_add_pin_and_badge_to_people',1),
(77,'2026_08_16_000004_add_pin_login_menu_item',1),
(78,'2026_08_17_000000_create_feedback_reports_table',1),
(79,'2026_08_17_000001_create_banner_settings_and_dismissals_tables',1),
(80,'2026_08_17_000002_add_feedback_menu_item',1),
(81,'2026_08_17_010000_add_commit_hash_to_feedback_reports',1),
(82,'2026_08_17_010001_widen_feedback_reports_page_url',1),
(83,'2026_08_17_020000_add_urgent_to_feedback_reports',1),
(84,'2026_08_17_224330_add_last_url_to_sessions_table',1),
(85,'2026_08_17_224458_add_active_sessions_menu_item',1),
(86,'2026_08_18_102056_add_completion_fields_to_orderdonations_table',1),
(87,'2026_08_18_103154_rename_and_extend_order_delivery_fields_on_orderdonations_table',1),
(88,'2026_08_18_150000_add_visibility_flags_to_roles_table',1),
(89,'2026_08_18_150001_add_staff_roles',1),
(90,'2026_08_18_150002_add_disabled_at_to_people',1),
(91,'2026_08_18_150003_repoint_users_menu_item',1),
(92,'2026_08_18_160000_rename_staff_roles_and_add_volunteer_flag',1),
(93,'2026_08_18_170000_add_help_menu',1),
(94,'2026_08_18_180000_add_sorting_help_menu_item',1),
(95,'2026_08_20_010000_create_person_categories_table',1),
(96,'2026_08_20_010001_add_org_contact_fields_to_people_table',1),
(97,'2026_08_20_020000_add_donation_source_type_to_orderdonations_table',1),
(98,'2026_08_20_030000_create_import_batches_table',1),
(99,'2026_08_20_030001_create_import_batch_rows_table',1),
(100,'2026_08_20_030002_add_source_ref_columns_for_import',1),
(101,'2026_08_20_040000_add_import_menu_item',1),
(102,'2026_08_21_010000_add_receiving_intake_detail_fields_to_orderdonations_table',1),
(103,'2026_08_21_010001_add_box_bag_to_pallets_container_type',1),
(104,'2026_08_21_020000_add_other_descriptions_to_orderdonations_table',1),
(105,'2026_08_21_030000_add_delivery_truck_carrier_to_orderdonations_table',1),
(106,'2026_08_21_040000_drop_donation_source_type_from_orderdonations_table',1),
(107,'2026_08_21_050000_add_trailer_to_arrival_method_enum',1),
(108,'2026_08_21_060000_add_contact_person_id_to_orderdonations_table',1),
(109,'2026_08_21_070000_create_drivers_table',1),
(110,'2026_08_21_070001_add_driver_id_to_orderdonations_table',1),
(111,'2026_08_21_080000_add_photo_path_to_orderdonations_table',1),
(112,'2026_08_21_090000_structure_source_location_address',1),
(113,'2026_08_21_100000_add_tote_to_pallets_container_type',1),
(114,'2026_08_21_110000_replace_arrived_palletized_with_container_type',1),
(115,'2026_08_21_120000_convert_container_type_to_multi_select',1),
(116,'2026_08_21_130000_add_container_type_counts_to_orderdonations_table',1),
(117,'2026_08_21_140000_add_quick_sort_candidate_to_orderdonations_table',1),
(118,'2026_08_21_150000_create_login_history_table',1),
(119,'2026_08_22_000000_gate_outstanding_orders_report_menu_item',1),
(120,'2026_08_22_000000_rename_active_sessions_menu_item',1),
(121,'2026_08_22_010000_rename_customer_role_to_partner',1),
(122,'2026_08_22_081842_add_group_label_to_menu_items_table',1),
(123,'2026_08_22_081900_group_setup_menu_items',1),
(124,'2026_08_22_083000_rename_system_admin_menu_item',1),
(125,'2026_08_22_084500_add_site_banner_menu_item',1),
(126,'2026_08_22_090000_reorder_system_admin_menu_items',1),
(127,'2026_08_22_091000_reorder_main_menu_items',1),
(128,'2026_08_22_092000_use_help_icon_for_help_menu_item',1),
(129,'2026_08_23_000000_create_donation_offers_table',1),
(130,'2026_08_23_000001_create_donation_offer_status_log_table',1),
(131,'2026_08_23_000002_add_volunteer_scheduling_to_people_table',1),
(132,'2026_08_23_000003_create_volunteer_sign_in_categories_table',1),
(133,'2026_08_23_000004_create_volunteer_sign_ins_table',1),
(134,'2026_08_23_000005_create_volunteer_sign_in_audit_log_table',1),
(135,'2026_08_23_000006_add_volunteer_kiosk_menu_item',1),
(136,'2026_08_23_000007_rename_and_narrow_volunteer_kiosk_permission',1),
(137,'2026_08_23_000008_create_building_safety_tables',1),
(138,'2026_08_23_000009_add_kiosk_mode_to_trusted_devices_table',1),
(139,'2026_08_23_000010_move_volunteer_kiosk_menu_item_to_setup',1),
(140,'2026_08_23_010000_rename_reports_customers_route_to_partners',1),
(141,'2026_08_23_020000_change_donation_offers_eta_to_date_range',1),
(142,'2026_08_24_000000_create_kiosk_settings_table',1),
(143,'2026_08_24_000001_create_notifications_table',1),
(144,'2026_08_24_120000_add_auto_enable_to_kiosk_menu_item',1),
(145,'2026_08_24_130000_revert_kiosk_menu_item_link_url',1),
(146,'2026_08_26_000000_create_kiosk_locations_table',1),
(147,'2026_08_26_000001_add_kiosk_location_id_to_trusted_devices_table',1),
(148,'2026_08_26_000002_rename_volunteer_sign_in_categories_to_sign_in_categories',1),
(149,'2026_08_26_000003_add_kiosk_location_id_to_sign_in_categories_table',1),
(150,'2026_08_26_000004_create_kiosk_suggestions_table',1),
(151,'2026_08_26_000005_add_idle_reset_and_drop_welcome_message_from_kiosk_settings',1),
(152,'2026_08_26_000006_add_kiosk_settings_menu_item',1),
(153,'2026_08_27_000000_add_badge_login_enabled_to_pin_login_settings',1),
(154,'2026_08_27_000001_add_filling_columns_to_item_ledgers_table',1),
(155,'2026_08_27_000002_repurpose_order_filling_menu_item',1),
(156,'2026_08_27_000003_add_need_level_and_low_stock_threshold',1),
(157,'2026_08_27_124501_add_bol_fields_to_orderdonations_table',1),
(158,'2026_08_27_130021_add_pin_hash_to_drivers_table',1),
(159,'2026_08_27_130022_add_signed_bol_path_to_orderdonations_table',1),
(160,'2026_08_27_130023_add_shipping_and_driver_portal_menu_items',1),
(161,'2026_08_27_141627_add_bol_review_fields_to_orderdonations_table',1),
(162,'2026_08_27_150000_add_pallet_count_to_orderdonations_table',1),
(163,'2026_08_28_000000_add_requested_track_to_people_table',1),
(164,'2026_08_30_100224_create_offline_mode_settings_table',1),
(165,'2026_08_30_102534_add_address_verified_at_to_people_table',1),
(166,'2026_08_30_120000_create_forms_table',1),
(167,'2026_08_30_120001_create_form_questions_table',1),
(168,'2026_08_30_120002_create_form_question_presets_table',1),
(169,'2026_08_30_120003_create_form_submissions_table',1),
(170,'2026_08_30_120004_create_form_answers_table',1),
(171,'2026_08_30_120005_create_form_submission_status_log_table',1),
(172,'2026_08_30_120006_add_forms_menu_item',1),
(173,'2026_08_30_120007_seed_partner_intake_form',1),
(174,'2026_08_31_000000_add_partner_status_to_people',1),
(175,'2026_09_02_000000_add_flagged_for_review_to_feedback_reports',1),
(176,'2026_09_02_201632_rename_volunteer_kiosk_menu_item_to_sign_in_kiosk',1),
(177,'2026_09_02_210000_collapse_admin_manage_permissions_and_split_kiosk',1),
(178,'2026_09_02_211000_remove_print_labels_menu_item',1),
(179,'2026_09_03_000000_add_approved_at_to_people_table',1),
(180,'2026_09_03_010000_add_review_status_to_feedback_reports',1),
(181,'2026_09_06_120000_add_centralized_aggregation_columns_to_feedback_reports',1),
(182,'2026_09_07_000000_create_feedback_aggregation_settings_table',1),
(183,'2026_09_09_000000_add_more_default_ordering_units',1),
(184,'2026_09_09_000001_add_units_menu_item',1),
(185,'2026_10_08_000000_create_device_fleet_tables',1),
(186,'2026_10_14_000000_rename_kiosk_devices_menu_item_to_r_station',1),
(187,'2026_10_18_000000_create_print_queue_tables',1),
(188,'2026_10_18_000001_add_print_queue_menu_item',1),
(189,'2026_10_18_000002_add_wake_channel_to_managed_devices',1),
(190,'2026_10_19_000000_add_allocation_approval_to_orderlines',1),
(191,'2026_10_19_000001_add_condition_to_item_ledgers',1),
(192,'2026_10_19_100000_create_setup_state_table',1),
(193,'2026_10_19_200000_add_firmware_permission_and_printer_pages',1),
(194,'2026_10_19_200100_create_firmware_settings_table',1),
(195,'2026_10_20_100000_add_vm_image_to_device_releases_release_type',1),
(196,'2026_10_20_110000_add_print_client_kind_to_device_releases',1),
(197,'2026_10_20_120000_create_backups_table_and_permissions',1),
(198,'2026_10_20_180000_backup_scope_and_merge_backup_menu',1),
(199,'2026_10_20_200000_add_unfulfilled_requests_report_menu_item',1),
(200,'2026_10_20_210000_add_testing_tools_menu_item',1),
(201,'2026_10_20_220000_add_pallet_stock',1),
(202,'2026_10_20_230000_add_sorting_area_report_menu_item',1),
(203,'2026_10_21_120000_create_carton_codes',1),
(204,'2026_10_21_130000_add_carton_codes_menu_item',1),
(205,'2026_10_21_140000_add_device_sessions',1),
(206,'2026_10_21_150000_add_expires_on_to_item_ledgers',1),
(207,'2026_10_21_160000_add_inventory_adjustments',1),
(208,'2026_10_22_100000_add_app_version_to_feedback_reports',1),
(209,'2026_10_22_120000_create_mail_settings_table',1),
(210,'2026_10_22_120000_remove_help_menu',1),
(211,'2026_10_22_120001_add_email_settings_menu_item',1),
(212,'2026_10_22_130000_gate_flow_donor_partner_report_menu_items',1),
(213,'2026_10_22_131000_add_donor_standing',1),
(214,'2026_10_22_140000_create_label_settings_table',1),
(215,'2026_10_22_150000_add_inventory_labels',1),
(216,'2026_10_22_160000_add_password_change_required_to_people',1),
(217,'2026_10_22_170000_add_account_audit_to_people',1),
(218,'2026_10_23_120000_restore_help_menu_tile',1),
(219,'2026_10_23_130000_add_training_mode',1),
(220,'2026_10_23_140000_rework_trusted_device_approval',1),
(221,'2026_10_23_150000_create_training_registrations',1),
(222,'2026_10_23_160000_add_certificate_event_to_training_settings',1),
(223,'2026_10_23_170000_create_training_products',1),
(224,'2026_10_23_180000_add_reset_point_to_training_settings',1),
(225,'2026_10_24_090000_grant_trainee_catalog_lookups',1),
(226,'2026_10_25_120000_add_design_votes',1),
(227,'2026_10_25_130000_add_design_poll_ideas',1),
(228,'2026_10_25_140000_drop_voter_role_from_design_poll_votes',1),
(229,'2026_10_25_150000_add_design_poll_reactions',1),
(230,'2026_10_25_160000_add_contact_to_design_poll_ideas',1),
(231,'2026_10_25_170000_add_mailing_labels_menu_item',1),
(232,'2026_10_26_090000_create_federation_identities_table',1),
(233,'2026_10_26_100000_create_trust_tables',1),
(234,'2026_10_26_110000_add_trust_console_permission_and_menu',1),
(235,'2026_10_26_120000_link_feedback_to_trusts',1),
(236,'2026_10_26_130000_remove_legacy_shared_secrets_and_device_tokens',1),
(237,'2026_10_26_200000_add_signs_menu_tile',1),
(238,'2026_10_27_100000_move_logins_to_accounts',1),
(239,'2026_10_28_000001_add_warehouse_id_to_feedback_reports',1),
(240,'2026_10_30_120000_add_instance_admin_menu_item',1),
(241,'2026_10_31_000002_retire_training_mode_switch',1),
(242,'2026_11_02_000001_create_backup_schedule_and_backup_tiers',1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` uuid NOT NULL,
  `type` varchar(255) NOT NULL,
  `notifiable_type` varchar(255) NOT NULL,
  `notifiable_id` bigint(20) unsigned NOT NULL,
  `data` text NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notifications_notifiable_type_notifiable_id_index` (`notifiable_type`,`notifiable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `offline_mode_settings`
--

DROP TABLE IF EXISTS `offline_mode_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `offline_mode_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `enabled` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `offline_mode_settings`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `offline_mode_settings` WRITE;
/*!40000 ALTER TABLE `offline_mode_settings` DISABLE KEYS */;
INSERT INTO `offline_mode_settings` VALUES
(1,0,'2026-11-17 22:18:32','2026-11-17 22:18:32');
/*!40000 ALTER TABLE `offline_mode_settings` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `orderdonations`
--

DROP TABLE IF EXISTS `orderdonations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `orderdonations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `type` enum('order','donation','adjustment') NOT NULL,
  `category` enum('donation','equipment','supplies','other') DEFAULT NULL,
  `category_other` varchar(255) DEFAULT NULL,
  `container_count` int(10) unsigned DEFAULT NULL,
  `manifest` text DEFAULT NULL,
  `manifest_weight_lbs` decimal(10,2) DEFAULT NULL,
  `driver_id` bigint(20) unsigned DEFAULT NULL,
  `arrival_method` enum('semi','box_truck','personal_vehicle','delivery_truck','trailer','other') DEFAULT NULL,
  `arrival_method_other` varchar(255) DEFAULT NULL,
  `carrier` varchar(255) DEFAULT NULL,
  `container_types` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`container_types`)),
  `container_type_counts` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`container_type_counts`)),
  `quick_sort_candidate` tinyint(1) DEFAULT NULL,
  `source_address` text DEFAULT NULL,
  `source_city` varchar(255) DEFAULT NULL,
  `source_state` varchar(2) DEFAULT NULL,
  `source_zip` varchar(10) DEFAULT NULL,
  `person_id` bigint(20) unsigned DEFAULT NULL,
  `contact_person_id` bigint(20) unsigned DEFAULT NULL,
  `donor_identification_pending` tinyint(1) NOT NULL DEFAULT 0,
  `status_id` bigint(20) unsigned NOT NULL,
  `status_changed_at` timestamp NULL DEFAULT NULL,
  `person_id_user` bigint(20) unsigned DEFAULT NULL,
  `order_date` date NOT NULL,
  `comments` text DEFAULT NULL,
  `photo_path` varchar(255) DEFAULT NULL,
  `fulfillment_method` enum('delivery','pickup') DEFAULT NULL,
  `needed_by_date` date DEFAULT NULL,
  `delivery_days` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`delivery_days`)),
  `preferred_time` varchar(100) DEFAULT NULL,
  `contact_name` varchar(191) DEFAULT NULL,
  `contact_phone` varchar(50) DEFAULT NULL,
  `other_needs` text DEFAULT NULL,
  `special_instructions` text DEFAULT NULL,
  `pallet_count` smallint(5) unsigned DEFAULT NULL,
  `bol_number` varchar(255) DEFAULT NULL,
  `signed_bol_path` varchar(255) DEFAULT NULL,
  `bol_rejection_reason` text DEFAULT NULL,
  `bol_reviewed_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `source_system` varchar(255) DEFAULT NULL,
  `source_ref` varchar(255) DEFAULT NULL,
  `adjustment_reason` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `orders_person_id_foreign` (`person_id`),
  KEY `orders_status_id_foreign` (`status_id`),
  KEY `orderdonations_source_system_source_ref_index` (`source_system`,`source_ref`),
  KEY `orderdonations_contact_person_id_foreign` (`contact_person_id`),
  KEY `orderdonations_driver_id_foreign` (`driver_id`),
  KEY `orderdonations_bol_reviewed_by_person_id_foreign` (`bol_reviewed_by_person_id`),
  CONSTRAINT `orderdonations_bol_reviewed_by_person_id_foreign` FOREIGN KEY (`bol_reviewed_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orderdonations_contact_person_id_foreign` FOREIGN KEY (`contact_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orderdonations_driver_id_foreign` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orders_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE,
  CONSTRAINT `orders_status_id_foreign` FOREIGN KEY (`status_id`) REFERENCES `statuses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=390502 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderdonations`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `orderdonations` WRITE;
/*!40000 ALTER TABLE `orderdonations` DISABLE KEYS */;
INSERT INTO `orderdonations` VALUES
(390501,'donation','donation',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,5,'2026-11-18 21:01:42',2,'2026-11-18',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-18 21:01:42','2026-11-18 21:01:42',NULL,NULL,NULL);
/*!40000 ALTER TABLE `orderdonations` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `orderlines`
--

DROP TABLE IF EXISTS `orderlines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `orderlines` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `orderdonation_id` bigint(20) unsigned NOT NULL,
  `itemtype_id` bigint(20) unsigned NOT NULL,
  `packagetype_id` bigint(20) unsigned DEFAULT NULL,
  `qty_requested` int(11) NOT NULL,
  `qty_approved` int(10) unsigned DEFAULT NULL,
  `approved_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `need_level` enum('critical','moderate','low') DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `orderlines_orderdonation_id_foreign` (`orderdonation_id`),
  KEY `orderlines_itemtype_id_foreign` (`itemtype_id`),
  KEY `orderlines_packagetype_id_foreign` (`packagetype_id`),
  KEY `orderlines_approved_by_person_id_foreign` (`approved_by_person_id`),
  CONSTRAINT `orderlines_approved_by_person_id_foreign` FOREIGN KEY (`approved_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orderlines_itemtype_id_foreign` FOREIGN KEY (`itemtype_id`) REFERENCES `itemtypes` (`id`),
  CONSTRAINT `orderlines_orderdonation_id_foreign` FOREIGN KEY (`orderdonation_id`) REFERENCES `orderdonations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `orderlines_packagetype_id_foreign` FOREIGN KEY (`packagetype_id`) REFERENCES `packagetypes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderlines`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `orderlines` WRITE;
/*!40000 ALTER TABLE `orderlines` DISABLE KEYS */;
/*!40000 ALTER TABLE `orderlines` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `packagetypes`
--

DROP TABLE IF EXISTS `packagetypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `packagetypes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `singular` varchar(255) NOT NULL,
  `plural` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `packagetypes_singular_plural_unique` (`singular`,`plural`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `packagetypes`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `packagetypes` WRITE;
/*!40000 ALTER TABLE `packagetypes` DISABLE KEYS */;
INSERT INTO `packagetypes` VALUES
(3,'Bag','Bags'),
(2,'Case','Cases'),
(5,'Each','Each'),
(8,'Gallon','Gallons'),
(6,'Gaylord','Gaylords'),
(4,'Pallet','Pallets'),
(7,'Roll','Rolls'),
(10,'Shipping Container','Shipping Containers'),
(9,'Ton','Tons'),
(11,'Truckload','Truckloads'),
(1,'Unit','Units');
/*!40000 ALTER TABLE `packagetypes` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `hashtag` varchar(255) NOT NULL,
  `menu_title` varchar(255) NOT NULL,
  `header_text` varchar(255) NOT NULL,
  `content` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pages_hashtag_unique` (`hashtag`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `pages` WRITE;
/*!40000 ALTER TABLE `pages` DISABLE KEYS */;
INSERT INTO `pages` VALUES
(1,'main','Main Menu','Welcome to the Relief Inventory Application','This is the main menu where you can navigate to various parts of the application.','2026-11-17 22:17:33','2026-11-17 22:17:33'),
(2,'reports','Report Menu','Application Reports','Use this menu to configure statuses, items, and users.','2026-11-17 22:17:33','2026-11-17 22:17:33'),
(3,'setup','Setup Menu','Application Setup Options','Use this menu to configure Items, Categories, Users etc.','2026-11-17 22:17:33','2026-11-17 22:17:33');
/*!40000 ALTER TABLE `pages` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `pallet_stock_assignments`
--

DROP TABLE IF EXISTS `pallet_stock_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pallet_stock_assignments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pallet_id` bigint(20) unsigned NOT NULL,
  `item_id` bigint(20) unsigned NOT NULL,
  `qty` int(11) NOT NULL,
  `expires_on` date DEFAULT NULL,
  `person_id_user` bigint(20) unsigned DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pallet_stock_assignments_item_id_foreign` (`item_id`),
  KEY `pallet_stock_assignments_pallet_id_item_id_index` (`pallet_id`,`item_id`),
  CONSTRAINT `pallet_stock_assignments_item_id_foreign` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pallet_stock_assignments_pallet_id_foreign` FOREIGN KEY (`pallet_id`) REFERENCES `pallets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28700001 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pallet_stock_assignments`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `pallet_stock_assignments` WRITE;
/*!40000 ALTER TABLE `pallet_stock_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `pallet_stock_assignments` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `pallets`
--

DROP TABLE IF EXISTS `pallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pallets` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `kind` enum('R','W','S','H','Q') NOT NULL,
  `status` varchar(255) NOT NULL,
  `status_before_missing` varchar(255) DEFAULT NULL,
  `container_type` enum('pallet','gaylord','box','bag','tote') NOT NULL DEFAULT 'pallet',
  `donor_person_id` bigint(20) unsigned DEFAULT NULL,
  `destination_person_id` bigint(20) unsigned DEFAULT NULL,
  `truck_id` bigint(20) unsigned DEFAULT NULL,
  `earliest_expiry` date DEFAULT NULL,
  `condition` enum('pending','good','condemned') DEFAULT NULL,
  `datepacked` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `location_id` bigint(20) unsigned DEFAULT NULL,
  `orderdonation_id` bigint(20) unsigned DEFAULT NULL,
  `content_description` varchar(255) DEFAULT NULL,
  `content_item_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pallets_last_location_id_foreign` (`location_id`),
  KEY `pallets_donor_person_id_foreign` (`donor_person_id`),
  KEY `pallets_destination_person_id_foreign` (`destination_person_id`),
  KEY `pallets_truck_id_foreign` (`truck_id`),
  KEY `pallets_orderdonation_id_foreign` (`orderdonation_id`),
  KEY `pallets_content_item_id_foreign` (`content_item_id`),
  CONSTRAINT `pallets_content_item_id_foreign` FOREIGN KEY (`content_item_id`) REFERENCES `items` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pallets_destination_person_id_foreign` FOREIGN KEY (`destination_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pallets_donor_person_id_foreign` FOREIGN KEY (`donor_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pallets_last_location_id_foreign` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pallets_orderdonation_id_foreign` FOREIGN KEY (`orderdonation_id`) REFERENCES `orderdonations` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pallets_truck_id_foreign` FOREIGN KEY (`truck_id`) REFERENCES `trucks` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=20320001 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pallets`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `pallets` WRITE;
/*!40000 ALTER TABLE `pallets` DISABLE KEYS */;
/*!40000 ALTER TABLE `pallets` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `palletstatus`
--

DROP TABLE IF EXISTS `palletstatus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `palletstatus` (
  `pallet_id` bigint(20) unsigned NOT NULL,
  `location_id` bigint(20) unsigned DEFAULT NULL,
  `status` varchar(255) NOT NULL,
  `notes` text DEFAULT NULL,
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `palletstatus_pallet_id_foreign` (`pallet_id`),
  KEY `palletstatus_location_id_foreign` (`location_id`),
  CONSTRAINT `palletstatus_location_id_foreign` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`),
  CONSTRAINT `palletstatus_pallet_id_foreign` FOREIGN KEY (`pallet_id`) REFERENCES `pallets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `palletstatus`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `palletstatus` WRITE;
/*!40000 ALTER TABLE `palletstatus` DISABLE KEYS */;
/*!40000 ALTER TABLE `palletstatus` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `people`
--

DROP TABLE IF EXISTS `people`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `people` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) unsigned DEFAULT NULL,
  `system_key` varchar(50) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `organization` varchar(255) DEFAULT NULL,
  `is_organization` tinyint(1) NOT NULL DEFAULT 0,
  `parent_person_id` bigint(20) unsigned DEFAULT NULL,
  `contact_role` varchar(100) DEFAULT NULL,
  `category_id` bigint(20) unsigned DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `requested_track` enum('volunteer','donor','partner') DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `pin_hash` varchar(255) DEFAULT NULL,
  `badge_code` varchar(255) DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(2) DEFAULT NULL,
  `zip` varchar(10) DEFAULT NULL,
  `address_verified_at` timestamp NULL DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `county_id` bigint(20) unsigned DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  `is_volunteer` tinyint(1) NOT NULL DEFAULT 0,
  `partner_status` varchar(255) DEFAULT NULL,
  `volunteer_active` tinyint(1) NOT NULL DEFAULT 1,
  `volunteer_window_start` date DEFAULT NULL,
  `volunteer_window_end` date DEFAULT NULL,
  `source_system` varchar(255) DEFAULT NULL,
  `source_ref` varchar(255) DEFAULT NULL,
  `donor_standing` varchar(20) NOT NULL DEFAULT 'normal',
  `donor_standing_note` text DEFAULT NULL,
  `donor_standing_set_by` bigint(20) unsigned DEFAULT NULL,
  `donor_standing_set_at` timestamp NULL DEFAULT NULL,
  `password_change_required` tinyint(1) NOT NULL DEFAULT 0,
  `created_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `approved_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `is_trainee` tinyint(1) NOT NULL DEFAULT 0,
  `training_team` tinyint(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `people_email_unique` (`email`),
  UNIQUE KEY `people_system_key_unique` (`system_key`),
  UNIQUE KEY `people_badge_code_unique` (`badge_code`),
  UNIQUE KEY `people_account_id_unique` (`account_id`),
  KEY `people_county_id_foreign` (`county_id`),
  KEY `people_parent_person_id_foreign` (`parent_person_id`),
  KEY `people_category_id_foreign` (`category_id`),
  KEY `people_source_system_source_ref_index` (`source_system`,`source_ref`),
  KEY `people_created_by_person_id_foreign` (`created_by_person_id`),
  KEY `people_approved_by_person_id_foreign` (`approved_by_person_id`),
  CONSTRAINT `people_approved_by_person_id_foreign` FOREIGN KEY (`approved_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `people_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `person_categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `people_county_id_foreign` FOREIGN KEY (`county_id`) REFERENCES `counties` (`id`) ON DELETE SET NULL,
  CONSTRAINT `people_created_by_person_id_foreign` FOREIGN KEY (`created_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `people_parent_person_id_foreign` FOREIGN KEY (`parent_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `people`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `people` WRITE;
/*!40000 ALTER TABLE `people` DISABLE KEYS */;
INSERT INTO `people` VALUES
(1,NULL,'unknown-donor',NULL,NULL,'Unknown Donor',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'System-provided placeholder for donations whose source is genuinely unknown at intake. Reassign the donation to the real donor once identified; do not delete this record.','2026-11-17 22:18:01','2026-11-17 22:18:01',NULL,NULL,0,NULL,1,NULL,NULL,NULL,NULL,'normal',NULL,NULL,NULL,0,NULL,NULL,0,NULL),
(2,1,NULL,'Vinícius','Fontana',NULL,0,NULL,NULL,NULL,NULL,'vinimayerfontana@gmail.com',NULL,'2026-11-17 22:34:14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-17 22:34:14','2026-11-17 22:34:14',NULL,NULL,0,NULL,1,NULL,NULL,NULL,NULL,'normal',NULL,NULL,NULL,0,NULL,NULL,0,NULL);
/*!40000 ALTER TABLE `people` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `people_roles`
--

DROP TABLE IF EXISTS `people_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `people_roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `person_id` bigint(20) unsigned NOT NULL,
  `role_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `people_roles_person_id_role_id_unique` (`person_id`,`role_id`),
  KEY `people_roles_role_id_foreign` (`role_id`),
  CONSTRAINT `people_roles_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE,
  CONSTRAINT `people_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `people_roles`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `people_roles` WRITE;
/*!40000 ALTER TABLE `people_roles` DISABLE KEYS */;
INSERT INTO `people_roles` VALUES
(1,2,15,'2026-11-17 22:34:14','2026-11-17 22:34:14');
/*!40000 ALTER TABLE `people_roles` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permissions_key_unique` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES
(1,'manage-kiosk','manage-kiosk','Configure Sign-in Kiosk settings: locations, guest types, and behavior','2026-11-17 22:18:37','2026-11-17 22:18:37'),
(2,'manage-devices','manage-devices','Pair, configure, and revoke R Station devices and print servers, and set up their printers','2026-11-17 22:18:39','2026-11-17 22:18:39'),
(3,'print-documents','print-documents','Send documents to a site printer and see your own print jobs','2026-11-17 22:18:41','2026-11-17 22:18:41'),
(4,'manage-print-queue','manage-print-queue','See, cancel, retry, and divert any print job in the print queue','2026-11-17 22:18:41','2026-11-17 22:18:41'),
(5,'manage-firmware','manage-firmware','Upload and tag R Station firmware/software releases, and set the firmware source','2026-11-17 22:18:42','2026-11-17 22:18:42'),
(6,'manage-backups','manage-backups','Create, download, and delete full backup files (database and uploads)','2026-11-17 22:18:42','2026-11-17 22:18:42'),
(7,'view-app-key','view-app-key','Reveal the application encryption key (APP_KEY) so it can be written down','2026-11-17 22:18:42','2026-11-17 22:18:42'),
(8,'adjust-inventory','adjust-inventory','Manually adjust the quantities recorded on a warehouse pallet, with a reason','2026-11-17 22:18:43','2026-11-17 22:18:43'),
(9,'manage-donor-standing','manage-donor-standing','Set a donor\'s standing (preferred / normal / watch / decline) from the Donor Report','2026-11-17 22:18:44','2026-11-17 22:18:44'),
(10,'manage-training','manage-training','Run Training Mode classes: trainees, Prepare Training, setup packet and training report cards','2026-11-17 22:18:45','2026-11-17 22:18:45'),
(11,'manage-design-votes','manage-design-votes','Open and close Design Votes polls and see their results','2026-11-17 22:18:47','2026-11-17 22:18:47'),
(12,'manage-trusts','manage-trusts','Manage the Trust Console: pair client apps and other instances, and set what each trust may do','2026-11-17 22:18:49','2026-11-17 22:18:49'),
(13,'general-access','general-access','Access placeholder/non-resource pages not yet tied to a specific permission','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(14,'manage-people','manage-people','View, create, and update people (partners/donors)','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(15,'admin-people','admin-people','Delete people','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(16,'manage-orders','manage-orders','View, update, and delete orders/donations','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(17,'manage-items','manage-items','Manage the item catalog','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(18,'manage-units','manage-units','Manage units of measure','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(19,'manage-categories','manage-categories','View, create, update, and delete item categories','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(20,'manage-locations','manage-locations','View, create, update, and delete warehouse locations','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(21,'manage-warehouses','manage-warehouses','View, create, update, and delete warehouses','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(22,'manage-uses','manage-uses','View, create, update, and delete location uses','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(23,'manage-itemtypes','manage-itemtypes','View, create, update, and delete item types','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(24,'manage-packagetypes','manage-packagetypes','View, create, update, and delete package types','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(25,'manage-sorting','manage-sorting','Run donation sorting sessions','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(26,'manage-receiving','manage-receiving','Record dock-side intake and manage donation close-out','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(27,'manage-donation-offers','manage-donation-offers','Approve, refuse, divert, or cancel donation offers, and match arrivals to pending offers','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(28,'manage-pallets','manage-pallets','Manage pallets and pallet status history','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(29,'manage-trucks','manage-trucks','Manage trucks','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(30,'manage-containers','manage-containers','View, create, update, and delete generic containers and container types','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(31,'manage-streams','manage-streams','View, create, update, and delete pickup streams','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(32,'manage-roles','manage-roles','View, create, update, and delete roles','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(33,'manage-counties','manage-counties','Create, update, and delete counties','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(34,'admin-system','admin-system','System administration: software updates, backups, and the backup schedule','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(35,'view-reports','view-reports','View inventory and operational reports','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(36,'view-dashboard','view-dashboard','View the internal warehouse activity dashboard (full detail)','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(37,'view-sitrep','view-sitrep','View and export the external Situation Report (restricted, no names/PII)','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(38,'manage-trusted-devices','manage-trusted-devices','Approve, label, and revoke devices allowed to use PIN unlock','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(39,'manage-feedback','manage-feedback','View and manage in-app bug/feature reports, and configure the site banner','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(40,'manage-users','manage-users','Create, promote, and deactivate login-capable accounts (User Administration)','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(41,'manage-import','manage-import','Upload, preview, and commit external data imports','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(42,'admin-import','admin-import','View and delete import batch history','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(43,'operate-kiosk','operate-kiosk','Put a device into or out of Sign-in Kiosk mode, and confirm building-safety state (closeout, roll call)','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(44,'certify-volunteer-hours','certify-volunteer-hours','Certify volunteer hours for FEMA reporting','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(45,'view-building-occupancy','view-building-occupancy','View who is currently in the building, and mark people safe during an active roll call','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(46,'manage-forms','manage-forms','Build and edit survey/questionnaire forms','2026-11-17 22:18:59','2026-11-17 22:18:59'),
(47,'review-form-submissions','review-form-submissions','View, approve, and deny form submissions','2026-11-17 22:18:59','2026-11-17 22:18:59');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `person_categories`
--

DROP TABLE IF EXISTS `person_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `person_categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `person_categories_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_categories`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `person_categories` WRITE;
/*!40000 ALTER TABLE `person_categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `person_categories` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `person_partner_status_log`
--

DROP TABLE IF EXISTS `person_partner_status_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `person_partner_status_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `person_id` bigint(20) unsigned NOT NULL,
  `from_status` varchar(255) DEFAULT NULL,
  `to_status` varchar(255) DEFAULT NULL,
  `changed_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `form_submission_id` bigint(20) unsigned DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `person_partner_status_log_person_id_foreign` (`person_id`),
  KEY `person_partner_status_log_changed_by_person_id_foreign` (`changed_by_person_id`),
  KEY `person_partner_status_log_form_submission_id_foreign` (`form_submission_id`),
  CONSTRAINT `person_partner_status_log_changed_by_person_id_foreign` FOREIGN KEY (`changed_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `person_partner_status_log_form_submission_id_foreign` FOREIGN KEY (`form_submission_id`) REFERENCES `form_submissions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `person_partner_status_log_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_partner_status_log`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `person_partner_status_log` WRITE;
/*!40000 ALTER TABLE `person_partner_status_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `person_partner_status_log` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `person_permissions`
--

DROP TABLE IF EXISTS `person_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `person_permissions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `person_id` bigint(20) unsigned NOT NULL,
  `permission_id` bigint(20) unsigned NOT NULL,
  `granted` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `person_permissions_person_id_permission_id_unique` (`person_id`,`permission_id`),
  KEY `person_permissions_permission_id_foreign` (`permission_id`),
  CONSTRAINT `person_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `person_permissions_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_permissions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `person_permissions` WRITE;
/*!40000 ALTER TABLE `person_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `person_permissions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `pin_login_settings`
--

DROP TABLE IF EXISTS `pin_login_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pin_login_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `enabled` tinyint(1) NOT NULL DEFAULT 0,
  `trust_mode` enum('time_of_day','session_duration','indefinite') NOT NULL DEFAULT 'session_duration',
  `trust_time_of_day` time DEFAULT NULL,
  `trust_session_minutes` int(10) unsigned DEFAULT 480,
  `require_badge_and_pin` tinyint(1) NOT NULL DEFAULT 0,
  `badge_login_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pin_login_settings`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `pin_login_settings` WRITE;
/*!40000 ALTER TABLE `pin_login_settings` DISABLE KEYS */;
INSERT INTO `pin_login_settings` VALUES
(1,0,'session_duration',NULL,480,0,0,'2026-11-17 22:18:01','2026-11-17 22:18:01');
/*!40000 ALTER TABLE `pin_login_settings` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `print_job_status_log`
--

DROP TABLE IF EXISTS `print_job_status_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `print_job_status_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `print_job_id` bigint(20) unsigned NOT NULL,
  `from_status` varchar(20) DEFAULT NULL,
  `to_status` varchar(20) NOT NULL,
  `changed_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `managed_device_id` bigint(20) unsigned DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `print_job_status_log_print_job_id_foreign` (`print_job_id`),
  KEY `print_job_status_log_changed_by_person_id_foreign` (`changed_by_person_id`),
  KEY `print_job_status_log_managed_device_id_foreign` (`managed_device_id`),
  CONSTRAINT `print_job_status_log_changed_by_person_id_foreign` FOREIGN KEY (`changed_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `print_job_status_log_managed_device_id_foreign` FOREIGN KEY (`managed_device_id`) REFERENCES `managed_devices` (`id`) ON DELETE SET NULL,
  CONSTRAINT `print_job_status_log_print_job_id_foreign` FOREIGN KEY (`print_job_id`) REFERENCES `print_jobs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `print_job_status_log`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `print_job_status_log` WRITE;
/*!40000 ALTER TABLE `print_job_status_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `print_job_status_log` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `print_jobs`
--

DROP TABLE IF EXISTS `print_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `print_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `printer_id` bigint(20) unsigned DEFAULT NULL,
  `kiosk_location_id` bigint(20) unsigned DEFAULT NULL,
  `media` varchar(40) NOT NULL,
  `title` varchar(255) NOT NULL,
  `document` varchar(60) DEFAULT NULL,
  `pdf_path` varchar(255) DEFAULT NULL,
  `copies` smallint(5) unsigned NOT NULL DEFAULT 1,
  `status` varchar(20) NOT NULL DEFAULT 'queued',
  `claimed_by_device_id` bigint(20) unsigned DEFAULT NULL,
  `claimed_at` timestamp NULL DEFAULT NULL,
  `claim_expires_at` timestamp NULL DEFAULT NULL,
  `attempts` smallint(5) unsigned NOT NULL DEFAULT 0,
  `error_message` text DEFAULT NULL,
  `requested_by` bigint(20) unsigned DEFAULT NULL,
  `printed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `print_jobs_kiosk_location_id_foreign` (`kiosk_location_id`),
  KEY `print_jobs_claimed_by_device_id_foreign` (`claimed_by_device_id`),
  KEY `print_jobs_requested_by_foreign` (`requested_by`),
  KEY `print_jobs_printer_id_status_index` (`printer_id`,`status`),
  KEY `print_jobs_status_index` (`status`),
  CONSTRAINT `print_jobs_claimed_by_device_id_foreign` FOREIGN KEY (`claimed_by_device_id`) REFERENCES `managed_devices` (`id`) ON DELETE SET NULL,
  CONSTRAINT `print_jobs_kiosk_location_id_foreign` FOREIGN KEY (`kiosk_location_id`) REFERENCES `kiosk_locations` (`id`) ON DELETE SET NULL,
  CONSTRAINT `print_jobs_printer_id_foreign` FOREIGN KEY (`printer_id`) REFERENCES `printers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `print_jobs_requested_by_foreign` FOREIGN KEY (`requested_by`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `print_jobs`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `print_jobs` WRITE;
/*!40000 ALTER TABLE `print_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `print_jobs` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `printers`
--

DROP TABLE IF EXISTS `printers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `printers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `managed_device_id` bigint(20) unsigned NOT NULL,
  `queue_name` varchar(255) NOT NULL,
  `kiosk_location_id` bigint(20) unsigned DEFAULT NULL,
  `media` varchar(40) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 0,
  `sort_order` int(10) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `printers_managed_device_id_queue_name_unique` (`managed_device_id`,`queue_name`),
  KEY `printers_kiosk_location_id_foreign` (`kiosk_location_id`),
  CONSTRAINT `printers_kiosk_location_id_foreign` FOREIGN KEY (`kiosk_location_id`) REFERENCES `kiosk_locations` (`id`) ON DELETE SET NULL,
  CONSTRAINT `printers_managed_device_id_foreign` FOREIGN KEY (`managed_device_id`) REFERENCES `managed_devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `printers`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `printers` WRITE;
/*!40000 ALTER TABLE `printers` DISABLE KEYS */;
/*!40000 ALTER TABLE `printers` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `role_id` bigint(20) unsigned NOT NULL,
  `permission_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_permissions_role_id_permission_id_unique` (`role_id`,`permission_id`),
  KEY `role_permissions_permission_id_foreign` (`permission_id`),
  CONSTRAINT `role_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=158 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permissions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `role_permissions` WRITE;
/*!40000 ALTER TABLE `role_permissions` DISABLE KEYS */;
INSERT INTO `role_permissions` VALUES
(1,15,1,'2026-11-17 22:18:37','2026-11-17 22:18:37'),
(2,15,2,'2026-11-17 22:18:39','2026-11-17 22:18:39'),
(3,3,3,'2026-11-17 22:18:41','2026-11-17 22:18:41'),
(4,12,3,'2026-11-17 22:18:41','2026-11-17 22:18:41'),
(5,21,3,'2026-11-17 22:18:41','2026-11-17 22:18:41'),
(6,20,3,'2026-11-17 22:18:41','2026-11-17 22:18:41'),
(7,15,3,'2026-11-17 22:18:41','2026-11-17 22:18:41'),
(8,21,4,'2026-11-17 22:18:41','2026-11-17 22:18:41'),
(9,15,4,'2026-11-17 22:18:41','2026-11-17 22:18:41'),
(10,15,5,'2026-11-17 22:18:42','2026-11-17 22:18:42'),
(11,15,6,'2026-11-17 22:18:42','2026-11-17 22:18:42'),
(12,15,7,'2026-11-17 22:18:42','2026-11-17 22:18:42'),
(13,21,8,'2026-11-17 22:18:43','2026-11-17 22:18:43'),
(14,15,8,'2026-11-17 22:18:43','2026-11-17 22:18:43'),
(15,21,9,'2026-11-17 22:18:44','2026-11-17 22:18:44'),
(16,15,9,'2026-11-17 22:18:44','2026-11-17 22:18:44'),
(19,22,3,'2026-11-17 22:18:45','2026-11-17 22:18:45'),
(20,21,11,'2026-11-17 22:18:47','2026-11-17 22:18:47'),
(21,15,11,'2026-11-17 22:18:47','2026-11-17 22:18:47'),
(22,15,12,'2026-11-17 22:18:49','2026-11-17 22:18:49'),
(23,3,13,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(24,3,14,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(25,3,16,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(26,3,17,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(27,3,18,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(28,3,19,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(29,3,20,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(30,3,21,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(31,3,22,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(32,3,23,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(33,3,24,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(34,3,25,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(35,3,26,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(36,3,28,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(37,3,29,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(38,3,30,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(39,3,31,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(40,3,32,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(41,3,33,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(42,3,35,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(43,3,45,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(44,12,13,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(45,12,14,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(46,12,16,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(47,12,17,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(48,12,18,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(49,12,19,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(50,12,20,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(51,12,21,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(52,12,22,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(53,12,23,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(54,12,24,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(55,12,25,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(56,12,26,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(57,12,28,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(58,12,29,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(59,12,30,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(60,12,31,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(61,12,32,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(62,12,33,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(63,12,35,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(64,12,45,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(65,12,36,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(66,21,13,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(67,21,14,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(68,21,16,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(69,21,17,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(70,21,18,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(71,21,19,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(72,21,20,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(73,21,21,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(74,21,22,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(75,21,23,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(76,21,24,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(77,21,25,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(78,21,26,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(79,21,27,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(80,21,28,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(81,21,29,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(82,21,30,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(83,21,31,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(84,21,32,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(85,21,33,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(86,21,35,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(87,21,36,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(88,21,43,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(89,21,44,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(90,21,45,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(91,21,47,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(92,20,13,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(93,20,14,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(94,20,17,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(95,20,18,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(96,20,19,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(97,20,20,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(98,20,21,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(99,20,22,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(100,20,23,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(101,20,24,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(102,20,25,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(103,20,26,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(104,20,28,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(105,20,29,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(106,20,30,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(107,20,31,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(108,20,33,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(109,20,35,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(110,20,45,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(111,15,13,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(112,15,14,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(113,15,15,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(114,15,16,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(115,15,17,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(116,15,18,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(117,15,19,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(118,15,20,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(119,15,21,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(120,15,22,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(121,15,23,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(122,15,24,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(123,15,25,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(124,15,26,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(125,15,27,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(126,15,28,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(127,15,29,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(128,15,30,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(129,15,31,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(130,15,32,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(131,15,33,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(132,15,34,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(133,15,35,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(134,15,36,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(135,15,37,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(136,15,38,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(137,15,39,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(138,15,40,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(139,15,41,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(140,15,42,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(141,15,43,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(142,15,44,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(143,15,45,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(144,15,46,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(145,15,47,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(146,22,13,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(147,22,14,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(148,22,16,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(149,22,17,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(150,22,18,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(151,22,19,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(152,22,23,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(153,22,25,'2026-11-17 22:18:59','2026-11-17 22:18:59'),
(154,22,26,'2026-11-17 22:19:00','2026-11-17 22:19:00'),
(155,22,27,'2026-11-17 22:19:00','2026-11-17 22:19:00'),
(156,22,28,'2026-11-17 22:19:00','2026-11-17 22:19:00'),
(157,22,35,'2026-11-17 22:19:00','2026-11-17 22:19:00');
/*!40000 ALTER TABLE `role_permissions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `visible_in_people_form` tinyint(1) NOT NULL DEFAULT 0,
  `visible_in_user_admin` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES
(1,'Partner','Organization or distribution-site contact receiving relief supplies','2026-11-17 22:17:38','2026-11-17 22:18:18',1,1),
(2,'Donor','Person or organization donating supplies','2026-11-17 22:17:38','2026-11-17 22:17:38',1,0),
(3,'Volunteer','Person helping with relief efforts','2026-11-17 22:17:38','2026-11-17 22:17:38',0,0),
(12,'Team Leader','A Volunteer with More Privileges','2026-11-17 22:17:38','2026-11-17 22:17:38',0,0),
(15,'Administrator','Super User','2026-11-17 22:17:38','2026-11-17 22:17:38',0,1),
(20,'Sorting and Inventory','Warehouse-side work: receiving, sorting, pallets, and the item/location catalog. No order or people-management access beyond donor lookup.','2026-11-17 22:18:08','2026-11-17 22:18:08',0,1),
(21,'Office','Full operational access (orders, inventory, reporting) but no admin/setup permissions.','2026-11-17 22:18:08','2026-11-17 22:18:08',0,1),
(22,'Trainee','Training Mode trainee: station work only (receiving, sorting, pallets, picking, shipping, order entry).','2026-11-17 22:18:45','2026-11-17 22:18:45',0,0);
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `last_url` varchar(255) DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES
('ckMtAg0fuQ33AVxJqEJtsxUpWyvNKx8vtCQMH8my',2,'172.21.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36','json/mailing-labels','YTo3OntzOjY6Il90b2tlbiI7czo0MDoiN0hkRkV3SWZ1UVc5U0hDT2VRNHowckJUdU5HUnFHRnNxbVB2NDdmMyI7czoxMjoid2FyZWhvdXNlX2lkIjtzOjg6IjZKU1lBN0hKIjtzOjk6Il9wcmV2aW91cyI7YToyOntzOjM6InVybCI7czo0NDoiaHR0cDovL2xvY2FsaG9zdDo4MDgwL3JlcG9ydHMvbWFpbGluZy1sYWJlbHMiO3M6NToicm91dGUiO3M6Mjc6ImdlbmVyYXRlZDo6WmNaVjVyVlJzUG5SMkRjRyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjI7czoxNzoicGFzc3dvcmRfaGFzaF93ZWIiO3M6NjQ6ImZmZmUxMjFjM2I3ZmQ4NjE5ODBhNmZhNDUxMjgxMjljMDA5NDlhYzBjZGIwYjhiZjc1ZmY1OWNjMTczNGZhODEiO3M6MTg6ImFjY291bnRfYXV0aF9lcG9jaCI7YToyOntpOjA7aToxO2k6MTtpOjA7fX0=',1794973192),
('K0mutEv6S1z241097cZjpI5BPkwzBWfgKMfUPzCE',2,'172.21.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36','json/reports/donors','YTo3OntzOjY6Il90b2tlbiI7czo0MDoiUFhNV1dGYjd3MDdqRUYzcUN4MGdKcXZSMGd0WEV5ZU5WTWVMQlVObCI7czoxMjoid2FyZWhvdXNlX2lkIjtzOjg6IjZKU1lBN0hKIjtzOjk6Il9wcmV2aW91cyI7YToyOntzOjM6InVybCI7czozNjoiaHR0cDovL2xvY2FsaG9zdDo4MDgwL3JlcG9ydHMvZG9ub3JzIjtzOjU6InJvdXRlIjtzOjI3OiJnZW5lcmF0ZWQ6OmN5UmM0UlRZUWRabWx1bkUiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX1zOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7aToyO3M6MTc6InBhc3N3b3JkX2hhc2hfd2ViIjtzOjY0OiJmZmZlMTIxYzNiN2ZkODYxOTgwYTZmYTQ1MTI4MTI5YzAwOTQ5YWMwY2RiMGI4YmY3NWZmNTljYzE3MzRmYTgxIjtzOjE4OiJhY2NvdW50X2F1dGhfZXBvY2giO2E6Mjp7aTowO2k6MTtpOjE7aTowO319',1795040093);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `setup_state`
--

DROP TABLE IF EXISTS `setup_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `setup_state` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `completed_at` timestamp NULL DEFAULT NULL,
  `demo_data_seeded_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `setup_state`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `setup_state` WRITE;
/*!40000 ALTER TABLE `setup_state` DISABLE KEYS */;
INSERT INTO `setup_state` VALUES
(1,'2026-11-17 22:34:14',NULL,'2026-11-17 22:18:42','2026-11-17 22:34:14');
/*!40000 ALTER TABLE `setup_state` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sign_in_categories`
--

DROP TABLE IF EXISTS `sign_in_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sign_in_categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `kiosk_location_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sign_in_categories_kiosk_location_id_name_unique` (`kiosk_location_id`,`name`),
  CONSTRAINT `sign_in_categories_kiosk_location_id_foreign` FOREIGN KEY (`kiosk_location_id`) REFERENCES `kiosk_locations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sign_in_categories`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sign_in_categories` WRITE;
/*!40000 ALTER TABLE `sign_in_categories` DISABLE KEYS */;
INSERT INTO `sign_in_categories` VALUES
(1,1,'Maintenance/Repair','2026-11-17 22:18:28','2026-11-17 22:18:28'),
(2,1,'FEMA','2026-11-17 22:18:28','2026-11-17 22:18:28'),
(3,1,'State','2026-11-17 22:18:28','2026-11-17 22:18:28');
/*!40000 ALTER TABLE `sign_in_categories` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `statuses`
--

DROP TABLE IF EXISTS `statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `statuses` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `statuses_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `statuses`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `statuses` WRITE;
/*!40000 ALTER TABLE `statuses` DISABLE KEYS */;
INSERT INTO `statuses` VALUES
(1,'Shopping Cart','Order is being prepared for checkout.',NULL,NULL),
(2,'New Order','Order has been placed and is pending processing.',NULL,NULL),
(3,'Picking In Progress','Items are being picked for the order.',NULL,NULL),
(4,'Completed','Order has been fulfilled and completed.',NULL,NULL),
(5,'Sorting','Sorting','2026-11-17 22:36:12','2026-11-17 22:36:12'),
(6,'Received','Received','2026-11-17 22:36:12','2026-11-17 22:36:12'),
(7,'Complete','Complete','2026-11-17 22:36:12','2026-11-17 22:36:12'),
(8,'Ready to Fill','Ready to Fill','2026-11-17 23:52:40','2026-11-17 23:52:40'),
(9,'Filling','Filling','2026-11-17 23:52:40','2026-11-17 23:52:40'),
(10,'Filled','Filled','2026-11-17 23:52:40','2026-11-17 23:52:40'),
(11,'Ready to Ship','Ready to Ship','2026-11-17 23:52:40','2026-11-17 23:52:40'),
(12,'Shipped','Shipped','2026-11-17 23:52:40','2026-11-17 23:52:40'),
(13,'Delivered','Delivered','2026-11-17 23:52:40','2026-11-17 23:52:40'),
(14,'Delivered - Waiting on BOL','Delivered - Waiting on BOL','2026-11-17 23:52:40','2026-11-17 23:52:40'),
(15,'Closed - Unfulfilled','Closed - Unfulfilled','2026-11-18 22:14:47','2026-11-18 22:14:47');
/*!40000 ALTER TABLE `statuses` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `streams`
--

DROP TABLE IF EXISTS `streams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `streams` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `warehouse_id` bigint(20) unsigned NOT NULL,
  `counts_kind` enum('R','W','S','H','Q') DEFAULT NULL,
  `counts_status` varchar(255) DEFAULT NULL,
  `counts_condition` enum('pending','good','condemned') DEFAULT NULL,
  `threshold` int(10) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `streams_warehouse_id_foreign` (`warehouse_id`),
  CONSTRAINT `streams_warehouse_id_foreign` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `streams`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `streams` WRITE;
/*!40000 ALTER TABLE `streams` DISABLE KEYS */;
/*!40000 ALTER TABLE `streams` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `training_products`
--

DROP TABLE IF EXISTS `training_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `training_products` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `item_id` bigint(20) unsigned NOT NULL,
  `qty` int(10) unsigned NOT NULL DEFAULT 0,
  `person_id_user` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `training_products_item_id_unique` (`item_id`),
  KEY `training_products_person_id_user_foreign` (`person_id_user`),
  CONSTRAINT `training_products_item_id_foreign` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `training_products_person_id_user_foreign` FOREIGN KEY (`person_id_user`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `training_products`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `training_products` WRITE;
/*!40000 ALTER TABLE `training_products` DISABLE KEYS */;
/*!40000 ALTER TABLE `training_products` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `training_registrations`
--

DROP TABLE IF EXISTS `training_registrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `training_registrations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `person_id` bigint(20) unsigned NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `wants_updates` tinyint(1) NOT NULL DEFAULT 0,
  `help_volunteer` tinyint(1) NOT NULL DEFAULT 0,
  `help_software` tinyint(1) NOT NULL DEFAULT 0,
  `help_organization` tinyint(1) NOT NULL DEFAULT 0,
  `help_other` tinyint(1) NOT NULL DEFAULT 0,
  `recommend` text DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `training_registrations_person_id_foreign` (`person_id`),
  KEY `training_registrations_created_at_index` (`created_at`),
  CONSTRAINT `training_registrations_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `training_registrations`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `training_registrations` WRITE;
/*!40000 ALTER TABLE `training_registrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `training_registrations` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `training_settings`
--

DROP TABLE IF EXISTS `training_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `training_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `prepared_at` timestamp NULL DEFAULT NULL,
  `prepared_by` bigint(20) unsigned DEFAULT NULL,
  `prepared_summary` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`prepared_summary`)),
  `event_title` varchar(150) DEFAULT NULL,
  `event_location` varchar(150) DEFAULT NULL,
  `trainer1_name` varchar(100) DEFAULT NULL,
  `trainer1_signature` varchar(255) DEFAULT NULL,
  `trainer2_name` varchar(100) DEFAULT NULL,
  `trainer2_signature` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `training_settings`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `training_settings` WRITE;
/*!40000 ALTER TABLE `training_settings` DISABLE KEYS */;
INSERT INTO `training_settings` VALUES
(1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-17 22:18:45','2026-11-17 22:18:45');
/*!40000 ALTER TABLE `training_settings` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `trucks`
--

DROP TABLE IF EXISTS `trucks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `trucks` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `donor_person_id` bigint(20) unsigned DEFAULT NULL,
  `status` enum('received','unloaded') NOT NULL DEFAULT 'received',
  `trailer_number` varchar(255) DEFAULT NULL,
  `rough_pallet_estimate` int(10) unsigned DEFAULT NULL,
  `contents_summary` text DEFAULT NULL,
  `manifest_weight_lbs` decimal(10,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `trucks_donor_person_id_foreign` (`donor_person_id`),
  CONSTRAINT `trucks_donor_person_id_foreign` FOREIGN KEY (`donor_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trucks`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `trucks` WRITE;
/*!40000 ALTER TABLE `trucks` DISABLE KEYS */;
/*!40000 ALTER TABLE `trucks` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `trust_audit_log`
--

DROP TABLE IF EXISTS `trust_audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `trust_audit_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `trust_id` bigint(20) unsigned DEFAULT NULL,
  `event` varchar(48) NOT NULL,
  `actor_person_id` bigint(20) unsigned DEFAULT NULL,
  `detail` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`detail`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `trust_audit_log_trust_id_foreign` (`trust_id`),
  KEY `trust_audit_log_actor_person_id_foreign` (`actor_person_id`),
  CONSTRAINT `trust_audit_log_actor_person_id_foreign` FOREIGN KEY (`actor_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `trust_audit_log_trust_id_foreign` FOREIGN KEY (`trust_id`) REFERENCES `trusts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trust_audit_log`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `trust_audit_log` WRITE;
/*!40000 ALTER TABLE `trust_audit_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `trust_audit_log` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `trust_grants`
--

DROP TABLE IF EXISTS `trust_grants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `trust_grants` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `trust_id` bigint(20) unsigned NOT NULL,
  `permission` varchar(48) NOT NULL,
  `direction` varchar(8) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `trust_grants_trust_id_permission_direction_unique` (`trust_id`,`permission`,`direction`),
  CONSTRAINT `trust_grants_trust_id_foreign` FOREIGN KEY (`trust_id`) REFERENCES `trusts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trust_grants`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `trust_grants` WRITE;
/*!40000 ALTER TABLE `trust_grants` DISABLE KEYS */;
/*!40000 ALTER TABLE `trust_grants` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `trust_pairing_codes`
--

DROP TABLE IF EXISTS `trust_pairing_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `trust_pairing_codes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code_hash` char(64) NOT NULL,
  `kind` varchar(32) NOT NULL,
  `name_hint` varchar(255) DEFAULT NULL,
  `grants` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`grants`)),
  `kiosk_location_id` bigint(20) unsigned DEFAULT NULL,
  `created_by` bigint(20) unsigned DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `used_at` timestamp NULL DEFAULT NULL,
  `trust_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `trust_pairing_codes_code_hash_unique` (`code_hash`),
  KEY `trust_pairing_codes_kiosk_location_id_foreign` (`kiosk_location_id`),
  KEY `trust_pairing_codes_created_by_foreign` (`created_by`),
  KEY `trust_pairing_codes_trust_id_foreign` (`trust_id`),
  CONSTRAINT `trust_pairing_codes_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `trust_pairing_codes_kiosk_location_id_foreign` FOREIGN KEY (`kiosk_location_id`) REFERENCES `kiosk_locations` (`id`) ON DELETE SET NULL,
  CONSTRAINT `trust_pairing_codes_trust_id_foreign` FOREIGN KEY (`trust_id`) REFERENCES `trusts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trust_pairing_codes`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `trust_pairing_codes` WRITE;
/*!40000 ALTER TABLE `trust_pairing_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `trust_pairing_codes` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `trusted_devices`
--

DROP TABLE IF EXISTS `trusted_devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `trusted_devices` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `device_token` varchar(64) NOT NULL,
  `label` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','revoked','denied') NOT NULL DEFAULT 'pending',
  `requested_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `request_reason` text DEFAULT NULL,
  `kiosk_mode` tinyint(1) NOT NULL DEFAULT 0,
  `kiosk_mode_enabled_at` timestamp NULL DEFAULT NULL,
  `kiosk_mode_enabled_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `kiosk_location_id` bigint(20) unsigned DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `last_ip_address` varchar(45) DEFAULT NULL,
  `browser` varchar(100) DEFAULT NULL,
  `os` varchar(100) DEFAULT NULL,
  `requested_at` timestamp NOT NULL,
  `approved_by` bigint(20) unsigned DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `last_seen_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `trusted_devices_device_token_unique` (`device_token`),
  KEY `trusted_devices_approved_by_foreign` (`approved_by`),
  KEY `trusted_devices_kiosk_mode_enabled_by_person_id_foreign` (`kiosk_mode_enabled_by_person_id`),
  KEY `trusted_devices_kiosk_location_id_foreign` (`kiosk_location_id`),
  KEY `trusted_devices_requested_by_person_id_foreign` (`requested_by_person_id`),
  CONSTRAINT `trusted_devices_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `trusted_devices_kiosk_location_id_foreign` FOREIGN KEY (`kiosk_location_id`) REFERENCES `kiosk_locations` (`id`) ON DELETE SET NULL,
  CONSTRAINT `trusted_devices_kiosk_mode_enabled_by_person_id_foreign` FOREIGN KEY (`kiosk_mode_enabled_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `trusted_devices_requested_by_person_id_foreign` FOREIGN KEY (`requested_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trusted_devices`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `trusted_devices` WRITE;
/*!40000 ALTER TABLE `trusted_devices` DISABLE KEYS */;
/*!40000 ALTER TABLE `trusted_devices` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `trusts`
--

DROP TABLE IF EXISTS `trusts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `trusts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `identity_id` bigint(20) unsigned NOT NULL,
  `kind` varchar(32) NOT NULL,
  `peer_uuid` varchar(64) NOT NULL,
  `name` varchar(255) NOT NULL,
  `public_key` varchar(64) NOT NULL,
  `base_url` varchar(255) DEFAULT NULL,
  `status` varchar(16) NOT NULL DEFAULT 'approved',
  `session_epoch` int(10) unsigned NOT NULL DEFAULT 0,
  `auth_method` varchar(32) NOT NULL,
  `approved_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `approved_by_label` varchar(255) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `domain_verified_at` timestamp NULL DEFAULT NULL,
  `revoked_at` timestamp NULL DEFAULT NULL,
  `last_seen_at` timestamp NULL DEFAULT NULL,
  `last_seen_ip` varchar(64) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `trusts_identity_id_peer_uuid_unique` (`identity_id`,`peer_uuid`),
  KEY `trusts_approved_by_person_id_foreign` (`approved_by_person_id`),
  CONSTRAINT `trusts_approved_by_person_id_foreign` FOREIGN KEY (`approved_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `trusts_identity_id_foreign` FOREIGN KEY (`identity_id`) REFERENCES `federation_identities` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trusts`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `trusts` WRITE;
/*!40000 ALTER TABLE `trusts` DISABLE KEYS */;
/*!40000 ALTER TABLE `trusts` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `units`
--

DROP TABLE IF EXISTS `units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `units` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `abbreviation` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` enum('weight','volume','each','other') NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `units_abbreviation_unique` (`abbreviation`),
  UNIQUE KEY `units_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `units`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `units` WRITE;
/*!40000 ALTER TABLE `units` DISABLE KEYS */;
INSERT INTO `units` VALUES
(1,'case','case','other'),
(2,'bag','bag','other'),
(3,'pallet','pallet','other'),
(4,'jug','jug','other'),
(5,'lb','pound','weight'),
(6,'oz','ounce','weight'),
(7,'kg','kilogram','weight'),
(8,'g','gram','weight'),
(9,'gal','gallon','volume'),
(10,'each','each','each'),
(11,'unknown','unknown','other');
/*!40000 ALTER TABLE `units` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `uses`
--

DROP TABLE IF EXISTS `uses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `uses` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `use` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uses_use_unique` (`use`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `uses`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `uses` WRITE;
/*!40000 ALTER TABLE `uses` DISABLE KEYS */;
INSERT INTO `uses` VALUES
(1,'Staging','2026-11-17 22:17:33','2026-11-17 22:17:33'),
(2,'Long-Term Storage','2026-11-17 22:17:33','2026-11-17 22:17:33'),
(3,'Sorting','2026-11-17 22:17:33','2026-11-17 22:17:33');
/*!40000 ALTER TABLE `uses` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `volunteer_sign_in_audit_log`
--

DROP TABLE IF EXISTS `volunteer_sign_in_audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `volunteer_sign_in_audit_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `volunteer_sign_in_id` bigint(20) unsigned NOT NULL,
  `field` varchar(255) NOT NULL,
  `old_value` text DEFAULT NULL,
  `new_value` text DEFAULT NULL,
  `changed_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `volunteer_sign_in_audit_log_volunteer_sign_in_id_foreign` (`volunteer_sign_in_id`),
  KEY `volunteer_sign_in_audit_log_changed_by_person_id_foreign` (`changed_by_person_id`),
  CONSTRAINT `volunteer_sign_in_audit_log_changed_by_person_id_foreign` FOREIGN KEY (`changed_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `volunteer_sign_in_audit_log_volunteer_sign_in_id_foreign` FOREIGN KEY (`volunteer_sign_in_id`) REFERENCES `volunteer_sign_ins` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `volunteer_sign_in_audit_log`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `volunteer_sign_in_audit_log` WRITE;
/*!40000 ALTER TABLE `volunteer_sign_in_audit_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `volunteer_sign_in_audit_log` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `volunteer_sign_ins`
--

DROP TABLE IF EXISTS `volunteer_sign_ins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `volunteer_sign_ins` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `person_id` bigint(20) unsigned NOT NULL,
  `category` varchar(255) NOT NULL,
  `other_category_id` bigint(20) unsigned DEFAULT NULL,
  `other_category_text` varchar(255) DEFAULT NULL,
  `agency` varchar(255) DEFAULT NULL,
  `title_function` varchar(255) DEFAULT NULL,
  `work_site` varchar(255) DEFAULT NULL,
  `description_of_work` text DEFAULT NULL,
  `expected_departure_at` timestamp NULL DEFAULT NULL,
  `signed_in_at` timestamp NOT NULL,
  `signed_out_at` timestamp NULL DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'open',
  `certified_at` timestamp NULL DEFAULT NULL,
  `certified_by_person_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `volunteer_sign_ins_other_category_id_foreign` (`other_category_id`),
  KEY `volunteer_sign_ins_certified_by_person_id_foreign` (`certified_by_person_id`),
  KEY `volunteer_sign_ins_person_id_status_index` (`person_id`,`status`),
  KEY `volunteer_sign_ins_status_index` (`status`),
  CONSTRAINT `volunteer_sign_ins_certified_by_person_id_foreign` FOREIGN KEY (`certified_by_person_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `volunteer_sign_ins_other_category_id_foreign` FOREIGN KEY (`other_category_id`) REFERENCES `sign_in_categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `volunteer_sign_ins_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `volunteer_sign_ins`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `volunteer_sign_ins` WRITE;
/*!40000 ALTER TABLE `volunteer_sign_ins` DISABLE KEYS */;
/*!40000 ALTER TABLE `volunteer_sign_ins` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `warehouses`
--

DROP TABLE IF EXISTS `warehouses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `warehouses` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `state` varchar(2) NOT NULL,
  `zip` varchar(10) NOT NULL,
  `county_id` bigint(20) unsigned DEFAULT NULL,
  `manager_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `pallets_enabled` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `warehouses_name_unique` (`name`),
  KEY `warehouses_county_id_foreign` (`county_id`),
  KEY `warehouses_manager_id_foreign` (`manager_id`),
  CONSTRAINT `warehouses_county_id_foreign` FOREIGN KEY (`county_id`) REFERENCES `counties` (`id`) ON DELETE SET NULL,
  CONSTRAINT `warehouses_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `people` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `warehouses`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `warehouses` WRITE;
/*!40000 ALTER TABLE `warehouses` DISABLE KEYS */;
INSERT INTO `warehouses` VALUES
(1,'Default Warehouse','123 No Street','Nowhere','NC','00000',NULL,NULL,'2026-11-17 22:17:38','2026-11-17 22:17:38',1);
/*!40000 ALTER TABLE `warehouses` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-11-19 23:27:16
