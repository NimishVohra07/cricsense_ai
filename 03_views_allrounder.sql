-- ============================================================
-- All-rounder & wicket-keeper analytical views
-- ============================================================

-- ---- All-rounders: players strong in both batting SR and bowling SR ----
CREATE OR REPLACE VIEW v_all_rounder AS
WITH bat AS (
    SELECT batsman                                                     AS player,
           SUM(batsman_runs)                                           AS runs,
           ROUND(SUM(batsman_runs) * 100.0 / NULLIF(COUNT(ball), 0), 2) AS bat_sr
    FROM ipl_ball
    GROUP BY batsman
    HAVING COUNT(ball) > 500
),
bowl AS (
    SELECT bowler                                                      AS player,
           total_wickets,
           strike_rate                                                 AS bowl_sr
    FROM v_attacking_bowler
)
SELECT bat.player,
       bat.runs,
       bat.bat_sr,
       bowl.total_wickets,
       bowl.bowl_sr
FROM bat
JOIN bowl ON bat.player = bowl.player
ORDER BY bat.bat_sr DESC, bowl.bowl_sr ASC;

-- ---- Wicket-keepers: stumpings + catches + batting contribution ----
CREATE OR REPLACE VIEW v_wicket_keeper AS
WITH stumpings AS (
    SELECT fielder                AS keeper,
           COUNT(*)               AS stumpings
    FROM master
    WHERE dismissal_kind = 'stumped'
    GROUP BY fielder
),
catches AS (
    SELECT fielder                AS keeper,
           COUNT(*)               AS catches
    FROM master
    WHERE dismissal_kind = 'caught'
    GROUP BY fielder
),
batting AS (
    SELECT batsman                AS keeper,
           SUM(batsman_runs)      AS total_runs,
           COUNT(DISTINCT season) AS seasons
    FROM master
    GROUP BY batsman
)
SELECT s.keeper,
       s.stumpings,
       COALESCE(c.catches, 0)     AS catches,
       COALESCE(b.total_runs, 0)  AS total_runs,
       COALESCE(b.seasons, 0)     AS seasons
FROM stumpings s
LEFT JOIN catches c ON s.keeper = c.keeper
LEFT JOIN batting b ON s.keeper = b.keeper
ORDER BY b.total_runs DESC NULLS LAST, s.stumpings DESC;
