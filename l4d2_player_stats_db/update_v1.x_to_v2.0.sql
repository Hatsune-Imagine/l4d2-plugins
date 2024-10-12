USE `player_stats`;

CREATE TABLE IF NOT EXISTS `t_server` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `server_name` varchar(32) NOT NULL DEFAULT '' COMMENT 'Server name',
  `server_ip` varchar(16) NOT NULL DEFAULT '' COMMENT 'Server ip',
  `server_port` varchar(8) NOT NULL DEFAULT '' COMMENT 'Server port',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record created time',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uni_idx_ip_port` (`server_ip`,`server_port`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Server info';

CREATE TABLE IF NOT EXISTS `t_player_chat_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `server_id` bigint unsigned NOT NULL COMMENT 'Server ID',
  `steam_id` varchar(32) NOT NULL COMMENT 'Player Steam ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record created time',
  `server_map` varchar(32) NOT NULL DEFAULT '' COMMENT 'Server map',
  `server_mode` varchar(32) NOT NULL DEFAULT '' COMMENT 'Server gamemode',
  `map_round` int unsigned NOT NULL DEFAULT 1 COMMENT 'Map round',
  `player_team` varchar(16) NOT NULL DEFAULT '' COMMENT 'Player team',
  `content` varchar(255) NOT NULL DEFAULT '' COMMENT 'Player chat content',
  PRIMARY KEY (`id`),
  KEY `idx_server_id` (`server_id`) USING BTREE,
  KEY `idx_steam_id` (`steam_id`) USING BTREE,
  KEY `idx_create_time` (`create_time`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Player chat log';


ALTER TABLE t_player ADD teammate_incapped int unsigned NOT NULL DEFAULT 0 COMMENT 'Player incapped teammate count' AFTER teammate_revived;
ALTER TABLE t_player ADD teammate_killed int unsigned NOT NULL DEFAULT 0 COMMENT 'Player killed teammate count' AFTER teammate_incapped;
ALTER TABLE t_player CHANGE incapacitated incapped int unsigned NOT NULL DEFAULT 0 COMMENT 'Player incapped count' AFTER ledge_hanged;
ALTER TABLE t_player ADD dead int unsigned NOT NULL DEFAULT 0 COMMENT 'Player dead count' AFTER incapped;
ALTER TABLE t_player_round_detail ADD gametime bigint unsigned NOT NULL DEFAULT 0 COMMENT 'Player gametime in this round (seconds)' AFTER map_round;
ALTER TABLE t_player_round_detail ADD teammate_incapped int unsigned NOT NULL DEFAULT 0 COMMENT 'Player incapped teammate count' AFTER teammate_revived;
ALTER TABLE t_player_round_detail ADD teammate_killed int unsigned NOT NULL DEFAULT 0 COMMENT 'Player killed teammate count' AFTER teammate_incapped;
ALTER TABLE t_player_round_detail CHANGE incapacitated incapped int unsigned NOT NULL DEFAULT 0 COMMENT 'Player incapped count' AFTER ledge_hanged;
ALTER TABLE t_player_round_detail ADD dead int unsigned NOT NULL DEFAULT 0 COMMENT 'Player dead count' AFTER incapped;

ALTER TABLE t_player_round_detail ADD server_id bigint unsigned NOT NULL COMMENT 'Server ID' AFTER id;
CREATE INDEX idx_server_id USING BTREE ON t_player_round_detail (server_id);

INSERT INTO t_server (server_ip, server_port) SELECT DISTINCT server_ip, server_port FROM t_player_round_detail ORDER BY server_ip, server_port;
UPDATE t_player_round_detail rd, t_server s SET rd.server_id = s.id WHERE rd.server_ip = s.server_ip AND rd.server_port = s.server_port;

ALTER TABLE t_player_round_detail DROP COLUMN server_ip;
ALTER TABLE t_player_round_detail DROP COLUMN server_port;

ALTER TABLE t_player_connect_log ADD server_id bigint unsigned NOT NULL COMMENT 'Server ID' AFTER id;
CREATE INDEX idx_server_id USING BTREE ON t_player_connect_log (server_id);
ALTER TABLE t_player_connect_log CHANGE connect_time connect_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Player join time' AFTER steam_id;
ALTER TABLE t_player_connect_log CHANGE connect_ip connect_ip varchar(16) NOT NULL DEFAULT '' COMMENT 'Player connect ip';
ALTER TABLE t_player_connect_log ADD ip_country varchar(32) NOT NULL DEFAULT '<N/A>' COMMENT 'IP country';
ALTER TABLE t_player_connect_log ADD ip_region varchar(32) NOT NULL DEFAULT '<N/A>' COMMENT 'IP region';
ALTER TABLE t_player_connect_log ADD ip_city varchar(100) NOT NULL DEFAULT '<N/A>' COMMENT 'IP city';
ALTER TABLE t_player_connect_log ADD latitude decimal(16,6) NOT NULL DEFAULT 0.0 COMMENT 'Latitude';
ALTER TABLE t_player_connect_log ADD longitude decimal(16,6) NOT NULL DEFAULT 0.0 COMMENT 'Longitude';
UPDATE t_player_connect_log cl, (SELECT IFNULL(MIN(server_id), 0) min_server_id, steam_id, DATE(create_time) create_date FROM t_player_round_detail GROUP BY steam_id, create_date) rd SET cl.server_id = rd.min_server_id WHERE cl.steam_id = rd.steam_id AND DATE(cl.connect_time) = rd.create_date;
UPDATE t_player_connect_log cl SET server_id = (SELECT CEIL(RAND() * (SELECT MAX(id) FROM t_server))) WHERE server_id = 0;
