-- ============================================================
-- CricSense AI — Schema
-- Two base tables mirror the original IPL dataset.
-- Compatible with both DuckDB (demo) and PostgreSQL (prod).
-- ============================================================

DROP TABLE IF EXISTS ipl_ball;
DROP TABLE IF EXISTS ipl_matches;

-- Ball-by-ball deliveries (~260k rows)
CREATE TABLE ipl_ball (
    match_id          INTEGER,
    inning            INTEGER,
    over              INTEGER,
    ball              INTEGER,
    batsman           VARCHAR,
    non_striker       VARCHAR,
    bowler            VARCHAR,
    batsman_runs      INTEGER,
    extra_runs        INTEGER,
    total_runs        INTEGER,
    is_wicket         INTEGER,
    dismissal_kind    VARCHAR,
    player_dismissed  VARCHAR,
    fielder           VARCHAR,
    extras_type       VARCHAR,
    batting_team      VARCHAR,
    bowling_team      VARCHAR
);

-- Match-level metadata (~1000 rows)
CREATE TABLE ipl_matches (
    id              INTEGER,
    city            VARCHAR,
    match_date      DATE,
    player_of_match VARCHAR,
    venue           VARCHAR,
    neutral_venue   INTEGER,
    team1           VARCHAR,
    team2           VARCHAR,
    toss_winner     VARCHAR,
    toss_decision   VARCHAR,
    winner          VARCHAR,
    result          VARCHAR,
    result_margin   INTEGER,
    eliminator      VARCHAR,
    method          VARCHAR,
    umpire1         VARCHAR,
    umpire2         VARCHAR
);

-- The "master" join used throughout analysis: every ball enriched with match context.
CREATE OR REPLACE VIEW master AS
SELECT b.*,
       m.city,
       m.match_date,
       m.venue,
       m.winner,
       EXTRACT(YEAR FROM m.match_date) AS season
FROM ipl_ball b
JOIN ipl_matches m ON b.match_id = m.id;
