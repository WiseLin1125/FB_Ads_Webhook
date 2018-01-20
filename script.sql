
-- sp_update_conversion_spec_created_date_batch_by_period;

drop procedure if exists sp_update_conversion_spec_created_date_batch_by_period;
DELIMITER ;;
CREATE DEFINER=`carat_sql`@`%` PROCEDURE `sp_update_conversion_spec_created_date_batch_by_period`(dateFrom CHAR(10), dateTo CHAR(10))
BEGIN
    DECLARE dateEnd CHAR(19);
        WHILE DATE(dateFrom) <= DATE(dateTo) DO

        SET dateEnd = DATE_FORMAT(DATE_SUB(DATE_ADD(dateFrom, INTERVAL 1 DAY), INTERVAL 1 SECOND), '%Y-' '%m-' '%d ' '%T');
         
        CALL sp_update_conversion_spec_created_date_main (dateFrom , dateEnd);

        SET dateFrom = DATE_ADD(dateFrom, INTERVAL 1 DAY);
    END WHILE;
END;;
DELIMITER ;

-- sp_update_general_conversion1_batch_by_period

drop procedure if exists sp_update_general_conversion1_batch_by_period;

DELIMITER ;;
CREATE DEFINER=`carat_sql`@`%` PROCEDURE `sp_update_general_conversion1_batch_by_period`(dateFrom CHAR(10), dateTo CHAR(10))
BEGIN
    DECLARE dateEnd CHAR(19);
        WHILE DATE(dateFrom) <= DATE(dateTo) DO

        SET dateEnd = DATE_FORMAT(DATE_SUB(DATE_ADD(dateFrom, INTERVAL 1 DAY), INTERVAL 1 SECOND), '%Y-' '%m-' '%d ' '%T');

        CALL sp_update_general_conversion1_main_pid1 (dateFrom , dateEnd);

        SET dateFrom = DATE_ADD(dateFrom, INTERVAL 1 DAY);
    END WHILE;
END;;
DELIMITER ;

-- sp_update_general_conversion1_conversion2_batch_by_period

drop procedure if exists sp_update_general_conversion1_conversion2_batch_by_period;
DELIMITER ;;
CREATE DEFINER=`carat_sql`@`%` PROCEDURE `sp_update_general_conversion1_conversion2_batch_by_period`(dateFrom CHAR(10), dateTo CHAR(10))
BEGIN
    DECLARE dateEnd CHAR(19);
        WHILE DATE(dateFrom) <= DATE(dateTo) DO

        SET dateEnd = DATE_FORMAT(DATE_SUB(DATE_ADD(dateFrom, INTERVAL 1 DAY), INTERVAL 1 SECOND), '%Y-' '%m-' '%d ' '%T');

        CALL sp_update_general_conversion1_main_pid1 (dateFrom , dateEnd);
        CALL sp_update_general_conversion2_main_pid1 (dateFrom , dateEnd);

        SET dateFrom = DATE_ADD(dateFrom, INTERVAL 1 DAY);
    END WHILE;
END;;
DELIMITER ;

-- sp_update_media_assist1_batch_by_period

drop procedure if exists sp_update_media_assist1_batch_by_period;
DELIMITER ;;
CREATE DEFINER=`carat_sql`@`%` PROCEDURE `sp_update_media_assist1_batch_by_period`(dateFrom CHAR(10), dateTo CHAR(10))
BEGIN
    DECLARE dateEnd CHAR(19);
        WHILE DATE(dateFrom) <= DATE(dateTo) DO

        SET dateEnd = DATE_FORMAT(DATE_SUB(DATE_ADD(dateFrom, INTERVAL 1 DAY), INTERVAL 1 SECOND), '%Y-' '%m-' '%d ' '%T');
        CALL sp_update_media_assist1_main_pid1 (dateFrom , dateEnd);
        
        SET dateFrom = DATE_ADD(dateFrom, INTERVAL 1 DAY);
    END WHILE;
END;;
DELIMITER ;


-- sp_update_media_conversion1_batch_by_period
drop procedure if exists sp_update_media_conversion1_batch_by_period;

DELIMITER ;;
CREATE DEFINER=`carat_sql`@`%` PROCEDURE `sp_update_media_conversion1_batch_by_period`(dateFrom CHAR(10), dateTo CHAR(10))
BEGIN
    DECLARE dateEnd CHAR(19);
        WHILE DATE(dateFrom) <= DATE(dateTo) DO

        SET dateEnd = DATE_FORMAT(DATE_SUB(DATE_ADD(dateFrom, INTERVAL 1 DAY), INTERVAL 1 SECOND), '%Y-' '%m-' '%d ' '%T');
        CALL sp_update_media_conversion1 (dateFrom , dateEnd);
        CALL sp_update_media_conversion1_device0 (dateFrom , dateEnd);
        
        SET dateFrom = DATE_ADD(dateFrom, INTERVAL 1 DAY);
    END WHILE;
END;;
DELIMITER ;


-- sp_update_product_uu_medium_source_batch_by_period
drop procedure if exists sp_update_product_uu_medium_source_batch_by_period;
DELIMITER ;;
CREATE DEFINER=`carat_sql`@`%` PROCEDURE `sp_update_product_uu_medium_source_batch_by_period`(dateFrom CHAR(10), dateTo CHAR(10))
BEGIN
    DECLARE dateEnd CHAR(19);
        WHILE DATE(dateFrom) <= DATE(dateTo) DO

        SET dateEnd = DATE_FORMAT(DATE_SUB(DATE_ADD(dateFrom, INTERVAL 1 DAY), INTERVAL 1 SECOND), '%Y-' '%m-' '%d ' '%T');
        CALL sp_update_product_uu_medium_source (dateFrom , dateEnd);
        
        SET dateFrom = DATE_ADD(dateFrom, INTERVAL 1 DAY);
    END WHILE;
END;;
DELIMITER ;


-- sp_update_product_uu_medium_source_batch_by_period

drop procedure if exists sp_update_media_conversion1;

DELIMITER ;;
CREATE DEFINER=`carat_sql`@`%` PROCEDURE `sp_update_media_conversion1`(IN start_date VARCHAR(100) , IN end_date VARCHAR(100))
BEGIN
DECLARE is_finished INTEGER DEFAULT 0;
DECLARE local_pid INTEGER DEFAULT 0;
DECLARE local_device TINYINT ;
DECLARE local_medium_source VARCHAR(255);
DECLARE local_utm_medium VARCHAR(100);
DECLARE local_utm_content VARCHAR(150);
DECLARE local_utm_campaign VARCHAR(100);
DECLARE local_utm_term VARCHAR(100);
DECLARE conversion_count INTEGER DEFAULT 0;

DECLARE media_cursor CURSOR FOR 
select pid,device,medium_source,utm_medium,utm_content,utm_campaign,utm_term, count(success_id) AS conversion_count FROM (
select pid,device, medium_source, utm_medium, utm_content, utm_campaign, utm_term, success_id FROM (
SELECT pid,device, medium_source, utm_medium, utm_content, utm_campaign, utm_term, 
SUBSTRING(url_current,LOCATE('success=',url_current)+8,LOCATE('&modelId=',url_current) -LOCATE('success=',url_current)-8) AS success_id 
 FROM uu WHERE (created_date BETWEEN start_date AND end_date) AND (url_current LIKE '%success%') 
 GROUP BY  pid,device,medium_source,utm_medium,utm_content,utm_campaign,utm_term,success_id
) AS group_by_all_media 
WHERE not exists (SELECT 1 FROM conversion AS c WHERE group_by_success.success_id = c.success_id AND c.created_date < start_date  )
GROUP BY success_id) AS group_by_success 
GROUP BY  pid,device,medium_source,utm_medium,utm_content,utm_campaign,utm_term;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET is_finished = 1;

OPEN media_cursor;
_loop:repeat
 FETCH media_cursor INTO local_pid,local_device,local_medium_source,local_utm_medium,local_utm_content,local_utm_campaign,local_utm_term,conversion_count;
IF is_finished =0 THEN
UPDATE media SET conversion1 = conversion_count 
WHERE
   (pid = local_pid or (local_pid is null and pid is null)) AND (device = local_device or (local_device is null and device is null)) AND (medium_source = local_medium_source or (local_medium_source is null and medium_source is null)) AND (utm_medium = local_utm_medium or (utm_medium is null and local_utm_medium is null)) AND (utm_content = local_utm_content or (local_utm_content is null and utm_content is null)) 
   AND (utm_campaign = local_utm_campaign or (local_utm_campaign is null and utm_campaign is null)) AND (utm_term = local_utm_term or (local_utm_term is null and utm_term is null)) AND (created_date BETWEEN start_date AND end_date);
END IF;
until is_finished end repeat _loop;
CLOSE media_cursor;

END;;
DELIMITER ;


-- sp_update_general_conversion1_main_pid1

drop procedure if exists sp_update_general_conversion1_main_pid1;
DELIMITER ;;
CREATE DEFINER=`carat_sql`@`%` PROCEDURE `sp_update_general_conversion1_main_pid1`(IN start_date VARCHAR(100) , IN end_date VARCHAR(100))
BEGIN
DROP TABLE IF EXISTS general_conversion1_temp_table;
CREATE TEMPORARY TABLE general_conversion1_temp_table (select pid,device, medium_source, utm_medium, utm_campaign, utm_term, success_id from (
SELECT pid,device, medium_source, utm_medium, utm_campaign, utm_term,
 SUBSTRING(url_current,LOCATE('success=',url_current)+8,LOCATE('&modelId=',url_current) -LOCATE('success=',url_current)-8) as success_id 
 FROM uu WHERE (created_date BETWEEN start_date AND end_date) AND (url_current like '%success%') 
 GROUP BY  pid,device,medium_source,utm_medium,utm_content,utm_campaign,utm_term, success_id
) as group_by_success
WHERE not exists (SELECT 1 FROM conversion AS c WHERE group_by_success.success_id = c.success_id AND c.created_date < start_date  )
 group by success_id);

call sp_update_general_conversion1_count_by_pid(start_date, end_date);

DROP TABLE IF EXISTS general_conversion1_temp_table;

END;;
DELIMITER ;
