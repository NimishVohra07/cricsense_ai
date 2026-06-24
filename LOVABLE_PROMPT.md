# Lovable Prompt — CricSense AI

Copy everything in the box below into [Lovable](https://lovable.dev) to generate
the live website. It's written as a single, self-contained build prompt. After
the first generation, use the follow-up prompts at the bottom to refine.

---

## 🟢 Main build prompt (paste this)

```
Build a polished, production-feeling web app called "CricSense AI" — a natural-language
analytics tool for Indian Premier League (IPL) cricket. The vibe: a sleek AI search
product (think Perplexity meets a sports stats site), not a dashboard.

CORE CONCEPT
Users type a cricket question in plain English (e.g. "Top 10 attacking batsmen by strike
rate"). The app sends it to a backend, gets back a SQL query, a result table, a chart spec,
and a one-line insight, then displays all of it beautifully.

LAYOUT (single page)
1. Header: "🏏 CricSense AI" with tagline "Ask anything about 16 seasons of IPL cricket —
   in plain English."
2. A prominent search/ask bar with a placeholder and an "Ask" button. Enter key submits.
3. A row of clickable sample-question chips:
   - "Top 10 attacking batsmen by strike rate"
   - "Most economical bowlers with 500+ balls"
   - "Which venue has seen the most runs?"
   - "Best all-rounders combining bat and ball"
   - "Hard hitters with the highest boundary percentage"
4. Result panel (appears after asking):
   - An insight callout box (light red left-border) showing the narrative text.
   - A chart (bar/line/scatter depending on the returned chart spec) using a charting lib.
   - A clean result table.
   - A collapsible "View generated SQL · N rows" section showing the SQL in a dark code block.
5. An "Explore by archetype" section: a responsive grid of cards (Attacking Batsmen, Anchor
   Batsmen, Hard Hitters, Economy Bowlers, Wicket Takers, All-Rounders, Wicket-Keepers).
   Tapping a card asks "Show me the top <archetype>".

DESIGN
- Brand color IPL red (#C8102E) for accents/buttons; clean white cards on a light gray (#f7f7f8)
  background; rounded corners (10–14px); subtle shadows.
- Modern system font stack. Generous spacing. Mobile-responsive.
- Loading state on the Ask button ("Thinking…").
- Friendly error banner if a request fails.

BACKEND INTEGRATION
Call a REST API at the base URL stored in an env var VITE_API_URL (default
http://localhost:8000):
- POST {API}/api/ask  with body {"question": "..."} →
  returns {question, sql, columns: string[], rows: object[], chart: {type, x, y},
  narrative, row_count}.
- GET {API}/api/archetypes → returns [{key, title, description, view}] for the archetype cards.
Render chart.type of "bar" (x=category, y=value), "line" (x=season, y=value),
"scatter" (x,y numeric), or "table" (no chart).

DATA NOTE
Until the backend is connected, mock the responses with realistic IPL data so the UI is fully
demoable: e.g. AD Russell strike rate 182.33, CH Gayle 9544 runs, Eden Gardens 23658 runs,
Sohail Tanvir economy 6.25. Make the mock easy to swap for the real fetch.

Keep it to a single clean React app. Prioritize a delightful first impression.
```

---

## 🔧 Follow-up refinement prompts

Use these one at a time after the first build:

1. **Polish the hero**
   > "Make the ask bar larger and centered with a soft focus glow in IPL red. Add a subtle
   > animated placeholder that cycles through the sample questions."

2. **Better charts**
   > "When the chart type is 'bar', sort bars descending and show value labels on each bar.
   > Use the IPL red (#C8102E) with a lighter red for hover."

3. **Empty + loading states**
   > "Add a skeleton loader in the result panel while waiting, and a friendly empty state
   > before the first question with a one-line explainer and an arrow pointing to the ask bar."

4. **Trust touches**
   > "In the 'View generated SQL' panel, add a 'Copy SQL' button and a small lock icon with
   > tooltip 'Read-only query — validated before running'."

5. **Connect the real backend**
   > "Replace the mocked responses with real fetch calls to VITE_API_URL using the /api/ask and
   > /api/archetypes endpoints exactly as specified. Keep the mock behind a USE_MOCK flag."

---

## Notes

- The React app in `frontend/` mirrors what this prompt produces, so you can either deploy
  the Lovable build or the repo's `frontend/` — they speak the same API.
- Set `VITE_API_URL` in Lovable's environment settings to your deployed backend URL.
