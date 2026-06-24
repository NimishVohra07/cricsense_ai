-- ============================================================
-- Bowling analytical views
-- Productionized from the "economy bowler / attacking bowler" queries.
-- ============================================================

-- ---- Economy bowlers: runs conceded per over (min 500 balls) ----
CREATE OR REPLACE VIEW v_economy_bowler AS
WITH base AS (
    SELECT bowler,
           COUNT(ball)            AS ball_count,
           SUM(total_runs)        AS runs_conceded
    FROM ipl_ball
    GROUP BY bowler
    HAVING COUNT(ball) >= 500
)
SELECT bowler,
       ball_count,
       runs_conceded,
       ROUND(runs_conceded * 6.0 / NULLIF(ball_count, 0), 2)          AS economy_rate,
       ball_count / 6                                                  AS overs_bowled
FROM base
ORDER BY economy_rate ASC;

-- ---- Wicket-taking bowlers: bowling strike rate (balls per wicket), min 500 balls ----
CREATE OR REPLACE VIEW v_attacking_bowler AS
WITH base AS (
    SELECT bowler,
           SUM(CASE WHEN dismissal_kind = 'lbw'               THEN 1 ELSE 0 END) AS lbw,
           SUM(CASE WHEN dismissal_kind = 'caught'            THEN 1 ELSE 0 END) AS caught,
           SUM(CASE WHEN dismissal_kind = 'bowled'            THEN 1 ELSE 0 END) AS bowled,
           SUM(CASE WHEN dismissal_kind = 'stumped'           THEN 1 ELSE 0 END) AS stumped,
           SUM(CASE WHEN dismissal_kind = 'hit wicket'        THEN 1 ELSE 0 END) AS hit_wicket,
           SUM(CASE WHEN dismissal_kind = 'caught and bowled' THEN 1 ELSE 0 END) AS caught_bowled,
           COUNT(ball)                                                           AS ball_count
    FROM master
    GROUP BY bowler
)
SELECT bowler,
       (lbw + caught + bowled + stumped + hit_wicket + caught_bowled) AS total_wickets,
       ball_count,
       ROUND(ball_count * 1.0
             / NULLIF(lbw + caught + bowled + stumped + hit_wicket + caught_bowled, 0), 2)
                                                                       AS strike_rate
FROM base
WHERE ball_count >= 500
ORDER BY strike_rate ASC;

-- ---- Dismissal-type distribution ----
CREATE OR REPLACE VIEW v_dismissal_kinds AS
SELECT dismissal_kind,
       COUNT(*) AS total
FROM ipl_ball
WHERE dismissal_kind IS NOT NULL
  AND dismissal_kind <> 'NA'
GROUP BY dismissal_kind
ORDER BY total DESC;
