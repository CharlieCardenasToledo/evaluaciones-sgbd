-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: airline_loyalty_db
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Temporary view structure for view `v_active_customers`
--

DROP TABLE IF EXISTS `v_active_customers`;
/*!50001 DROP VIEW IF EXISTS `v_active_customers`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_active_customers` AS SELECT 
 1 AS `loyalty_number`,
 1 AS `loyalty_card`,
 1 AS `province`,
 1 AS `city`,
 1 AS `clv`,
 1 AS `enrollment_year`,
 1 AS `total_activity_records`,
 1 AS `lifetime_flights`,
 1 AS `lifetime_distance`,
 1 AS `lifetime_points_accumulated`,
 1 AS `lifetime_points_redeemed`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_loyalty_card_segments`
--

DROP TABLE IF EXISTS `v_loyalty_card_segments`;
/*!50001 DROP VIEW IF EXISTS `v_loyalty_card_segments`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_loyalty_card_segments` AS SELECT 
 1 AS `loyalty_card`,
 1 AS `customer_count`,
 1 AS `avg_clv`,
 1 AS `avg_salary`,
 1 AS `total_flights`,
 1 AS `total_points_accumulated`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_monthly_activity_summary`
--

DROP TABLE IF EXISTS `v_monthly_activity_summary`;
/*!50001 DROP VIEW IF EXISTS `v_monthly_activity_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_monthly_activity_summary` AS SELECT 
 1 AS `year`,
 1 AS `month`,
 1 AS `active_customers`,
 1 AS `total_flights`,
 1 AS `total_distance`,
 1 AS `total_points_accumulated`,
 1 AS `total_points_redeemed`,
 1 AS `total_dollar_cost`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `v_active_customers`
--

/*!50001 DROP VIEW IF EXISTS `v_active_customers`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_active_customers` AS select `clh`.`loyalty_number` AS `loyalty_number`,`clh`.`loyalty_card` AS `loyalty_card`,`clh`.`province` AS `province`,`clh`.`city` AS `city`,`clh`.`clv` AS `clv`,`clh`.`enrollment_year` AS `enrollment_year`,count(`cfa`.`activity_id`) AS `total_activity_records`,sum(`cfa`.`total_flights`) AS `lifetime_flights`,sum(`cfa`.`distance`) AS `lifetime_distance`,sum(`cfa`.`points_accumulated`) AS `lifetime_points_accumulated`,sum(`cfa`.`points_redeemed`) AS `lifetime_points_redeemed` from (`customer_loyalty_history` `clh` left join `customer_flight_activity` `cfa` on((`clh`.`loyalty_number` = `cfa`.`loyalty_number`))) where (`clh`.`cancellation_year` is null) group by `clh`.`loyalty_number`,`clh`.`loyalty_card`,`clh`.`province`,`clh`.`city`,`clh`.`clv`,`clh`.`enrollment_year` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_loyalty_card_segments`
--

/*!50001 DROP VIEW IF EXISTS `v_loyalty_card_segments`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_loyalty_card_segments` AS select `clh`.`loyalty_card` AS `loyalty_card`,count(distinct `clh`.`loyalty_number`) AS `customer_count`,avg(`clh`.`clv`) AS `avg_clv`,avg(`clh`.`salary`) AS `avg_salary`,sum(`cfa`.`total_flights`) AS `total_flights`,sum(`cfa`.`points_accumulated`) AS `total_points_accumulated` from (`customer_loyalty_history` `clh` left join `customer_flight_activity` `cfa` on((`clh`.`loyalty_number` = `cfa`.`loyalty_number`))) group by `clh`.`loyalty_card` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_monthly_activity_summary`
--

/*!50001 DROP VIEW IF EXISTS `v_monthly_activity_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_monthly_activity_summary` AS select `cfa`.`year` AS `year`,`cfa`.`month` AS `month`,count(distinct `cfa`.`loyalty_number`) AS `active_customers`,sum(`cfa`.`total_flights`) AS `total_flights`,sum(`cfa`.`distance`) AS `total_distance`,sum(`cfa`.`points_accumulated`) AS `total_points_accumulated`,sum(`cfa`.`points_redeemed`) AS `total_points_redeemed`,sum(`cfa`.`dollar_cost_points_redeemed`) AS `total_dollar_cost` from `customer_flight_activity` `cfa` group by `cfa`.`year`,`cfa`.`month` order by `cfa`.`year`,`cfa`.`month` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-24 12:43:13
