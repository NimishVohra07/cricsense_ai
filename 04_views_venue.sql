-- ============================================================
-- Venue & team analytical views
-- ============================================================

-- ---- Total runs scored by venue ----
CREATE OR REPLACE VIEW v_venue_runs AS
SELECT venue,
       SUM(total_runs) AS runs_scored,
       COUNT(DISTINCT match_id) AS matches
FROM master
GROUP BY venue
ORDER BY runs_scored DESC;

-- ---- Year-wise runs at a given venue (parameterized in app layer) ----
CREATE OR REPLACE VIEW v_venue_season_runs AS
SELECT venue,
       season,
       SUM(total_runs) AS runs
FROM master
GROUP BY venue, season
ORDER BY venue, season;

-- ---- Boundary count by batting team ----
CREATE OR REPLACE VIEW v_team_boundaries AS
SELECT batting_team AS team,
       COUNT(*) FILTER (WHERE total_runs IN (4, 6)) AS boundaries
FROM ipl_ball
GROUP BY batting_team
ORDER BY boundaries DESC;

-- ---- Dot balls bowled by team (pressure metric) ----
CREATE OR REPLACE VIEW v_team_dot_balls AS
SELECT bowling_team AS team,
       COUNT(*) FILTER (WHERE total_runs = 0) AS dot_balls
FROM ipl_ball
GROUP BY bowling_team
ORDER BY dot_balls DESC;

-- ---- Matches per city ----
CREATE OR REPLACE VIEW v_city_matches AS
SELECT city,
       COUNT(DISTINCT match_id) AS matches
FROM master
GROUP BY city
ORDER BY matches DESC;
