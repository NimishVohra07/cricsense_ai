-- ============================================================
-- Batting analytical views
-- Productionized from the original "attacking / anchor / hard-hitter" queries.
-- ============================================================

-- ---- Attacking batsmen: strike rate over legal balls (min 500) ----
CREATE OR REPLACE VIEW v_attacking_batsman AS
WITH agg AS (
    SELECT batsman,
           SUM(batsman_runs)                                            AS run_count,
           COUNT(ball)                                                  AS total_balls,
           COUNT(ball) FILTER (WHERE extras_type = 'wides')             AS wides
    FROM ipl_ball
    GROUP BY batsman
)
SELECT batsman,
       run_count,
       (total_balls - wides)                                           AS legal_balls,
       ROUND(run_count * 100.0 / NULLIF(total_balls - wides, 0), 2)    AS strike_rate
FROM agg
WHERE (total_balls - wides) > 500
ORDER BY strike_rate DESC;

-- ---- Anchor batsmen: batting average across 3+ seasons ----
CREATE OR REPLACE VIEW v_anchor_batsman AS
SELECT batsman,
       SUM(batsman_runs)                                               AS run_count,
       SUM(is_wicket)                                                  AS dismissals,
       ROUND(SUM(batsman_runs) * 1.0 / NULLIF(SUM(is_wicket), 0), 2)   AS average,
       COUNT(DISTINCT season)                                          AS seasons
FROM master
GROUP BY batsman
HAVING COUNT(DISTINCT season) > 2
ORDER BY average DESC;

-- ---- Hard-hitters: boundary % (share of runs from 4s & 6s), 3+ seasons ----
CREATE OR REPLACE VIEW v_hard_hitter AS
WITH base AS (
    SELECT batsman,
           COUNT(*) FILTER (WHERE batsman_runs = 6)                    AS six_count,
           COUNT(*) FILTER (WHERE batsman_runs = 4)                    AS four_count,
           SUM(batsman_runs)                                           AS total_runs,
           COUNT(DISTINCT season)                                      AS seasons
    FROM master
    GROUP BY batsman
)
SELECT batsman,
       six_count,
       four_count,
       total_runs,
       seasons,
       (six_count + four_count)                                        AS boundaries,
       ROUND(((six_count * 6) + (four_count * 4)) * 100.0
             / NULLIF(total_runs, 0), 2)                               AS boundary_pct
FROM base
WHERE seasons > 2
ORDER BY boundary_pct DESC;
