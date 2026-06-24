# 🏏 CricSense AI — Natural-Language IPL Analytics Platform

> Ask cricket questions in plain English. Get SQL-backed answers, charts, and scouting insights — instantly.

[![Python](https://img.shields.io/badge/Python-3.11-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110-009688.svg)](https://fastapi.tiangolo.com/)
[![React](https://img.shields.io/badge/React-18-61DAFB.svg)](https://react.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

CricSense AI turns a static SQL analysis of 16 IPL seasons (~260k ball-by-ball deliveries)
into a **live product**: a natural-language analytics engine where anyone — scouts, fantasy
players, journalists, fans — can query the data without writing a single line of SQL.

It started as a SQL coursework project. It became a full-stack, AI-powered analytics
product with a public API, a conversational front-end, and a product roadmap.

---

## ✨ What it does

| Capability | Description |
|------------|-------------|
| 🗣️ **Text-to-SQL** | Type "Who are the best death-over economy bowlers?" → an LLM generates safe, validated SQL → executes against the warehouse → returns ranked results. |
| 📊 **Auto-visualization** | Every answer is rendered as a table + the most appropriate chart (bar, line, scatter). |
| 🎯 **Player Archetypes** | Pre-built analytical lenses: Attacking Batsman, Anchor, Hard-Hitter, Economy Bowler, Wicket-Taker, All-Rounder, Wicket-Keeper. |
| 🏟️ **Venue Intelligence** | Run-scoring trends and pitch-behaviour analysis by stadium and season. |
| 🔒 **Guardrailed SQL** | Read-only execution, query allow-listing, statement timeouts, and schema-scoped prompts prevent injection and runaway queries. |
| 🤖 **Insight Narration** | The LLM summarizes each result set into a one-paragraph scouting note. |

---

## 🧱 Architecture

```
┌─────────────┐     natural language      ┌──────────────────┐
│  React SPA  │ ───────────────────────►  │   FastAPI         │
│  (Lovable)  │                           │   /api/ask        │
│             │ ◄─── JSON + chart spec ─── │                   │
└─────────────┘                           └────────┬──────────┘
                                                    │
                            ┌───────────────────────┼───────────────────────┐
                            ▼                       ▼                       ▼
                   ┌────────────────┐     ┌──────────────────┐    ┌─────────────────┐
                   │ Text-to-SQL    │     │  SQL Guardrail   │    │  Insight        │
                   │ (Claude/LLM)   │     │  Validator       │    │  Narrator (LLM) │
                   └────────────────┘     └────────┬─────────┘    └─────────────────┘
                                                    ▼
                                          ┌──────────────────┐
                                          │  DuckDB / Postgres│
                                          │  ipl_ball         │
                                          │  ipl_matches      │
                                          │  + analytical views│
                                          └──────────────────┘
```

**Why DuckDB?** The original project shipped a CSV. DuckDB lets the demo run entirely
in-process with zero database setup, while the same SQL runs unmodified on Postgres in
production. One codebase, two deployment modes.

---

## 🚀 Quickstart

```bash
# 1. Clone
git clone https://github.com/<you>/cricsense-ai.git
cd cricsense-ai

# 2. Backend
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env          # add your ANTHROPIC_API_KEY
python -m app.seed            # builds the DuckDB warehouse from CSVs
uvicorn app.main:app --reload # API on http://localhost:8000

# 3. Frontend
cd ../frontend
npm install
npm run dev                   # UI on http://localhost:5173
```

Then open the UI and ask: *"Top 10 hardest-hitting batsmen who played 3+ seasons."*

---

## 📂 Repository layout

```
cricsense-ai/
├── backend/                 # FastAPI + text-to-SQL engine
│   ├── app/
│   │   ├── main.py          # API entrypoint
│   │   ├── routers/         # /ask, /archetypes, /venues, /health
│   │   ├── services/        # llm_sql, guardrail, narrator, warehouse
│   │   └── models/          # Pydantic request/response schemas
│   ├── requirements.txt
│   └── .env.example
├── frontend/                # React SPA (mirrors Lovable build)
├── sql/                     # The 25+ analytical queries, productionized
│   ├── 00_schema.sql
│   ├── 01_views_batting.sql
│   ├── 02_views_bowling.sql
│   ├── 03_views_allrounder.sql
│   └── 04_views_venue.sql
├── product/                 # PM artifacts (PRD, roadmap, metrics)
├── docs/                    # Architecture, prompt design, API reference
├── .github/workflows/       # CI: lint, test, SQL validation
└── README.md
```

---

## 🧠 How text-to-SQL stays safe

A common interview question for this project: *"What stops the LLM from dropping your table?"*

1. **Schema-scoped prompt** — the LLM only sees table/column names and the allowed views, never write verbs.
2. **AST validation** — generated SQL is parsed; anything that isn't a single `SELECT` is rejected.
3. **Read-only connection** — the execution role has no `INSERT/UPDATE/DELETE/DDL` grants.
4. **Statement timeout** — queries are capped (default 5s) to kill runaway scans.
5. **Row cap** — results are `LIMIT`-ed to protect the payload and the UI.

See [`docs/PROMPT_DESIGN.md`](docs/PROMPT_DESIGN.md) for the full prompt and guardrail logic.

---

## 📈 From the original analysis

CricSense AI productionizes 25+ SQL queries originally built for IPL trend analysis,
including:

- **Attacking batsmen** by strike rate (min. 500 balls) — AD Russell tops at 182.3 SR
- **Anchor batsmen** by batting average across 3+ seasons
- **Hard-hitters** by boundary percentage — SP Narine leads at 81.2%
- **Economy bowlers** (min. 500 balls) — Sohail Tanvir at 6.25 RPO
- **Wicket-takers** by strike rate — Sohail Tanvir at 12.05 BSR
- **All-rounders** combining batting & bowling strike rates
- **Venue scoring** — Eden Gardens leads with 23,658 total runs

Full query catalogue: [`sql/`](sql/).

---

## 🗺️ Product roadmap

See [`product/ROADMAP.md`](product/ROADMAP.md). Highlights:

- **v1 (shipped):** Text-to-SQL, archetypes, venue intelligence
- **v2:** Win-probability model, fantasy-team optimizer
- **v3:** Multi-league (BBL, PSL, The Hundred), real-time match ingestion

---

## 🙌 Credits

Original SQL analysis & concept by **Nimish Vohra**.
Productized into CricSense AI as a full-stack, AI-powered analytics platform.

Data: public IPL ball-by-ball dataset (2008–2024).

## 📜 License

MIT — see [LICENSE](LICENSE).
