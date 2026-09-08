# Day 5 — Quest 2 deliverable, Data Wrangling challenge & APIs

## Requests vs. `.get()`, and why it matters

`response.json()` turns an API response into a plain dict/list — normal
Python indexing rules apply from there. `dict[key]` raises `KeyError` if
the key is missing; `dict.get(key)` returns `None` instead. For API
responses specifically, `.get()` is usually the safer default — a field
being absent from one response (a null source, an optional attribute)
is common and shouldn't crash a whole pipeline.

## Flattening nested JSON: `json_normalize` over manual dict access

A raw API response is almost never flat — nested dicts and lists inside
dicts are the norm (e.g. NewsAPI's `articles[i]["source"]["name"]`).
`pd.DataFrame(response_list)` keeps the nested structure as dict-valued
columns, still awkward to work with. `pd.json_normalize(response_list)`
flattens nested keys into dotted column names (`source.name`,
`source.id`) directly — much less manual dict-digging than building the
same columns by hand.

## Path parameters vs. query parameters

- **Path parameters** are baked into the URL itself
  (`/satellites/{id}` → `/satellites/25544`) — used when the parameter
  identifies *which* resource you want.
- **Query parameters** go in the `params=` dict passed to `requests.get`
  and get appended as `?key=value&...` — used for filtering/options on a
  resource you've already identified. `requests` builds and
  URL-encodes the query string for you; no manual string concatenation
  needed.

## Auth: never hardcode a key, always `.env` + `python-dotenv`

`os.getenv("SOME_API_KEY")` after `load_dotenv()` reads the key from a
local `.env` file (gitignored, never committed) instead of pasting it
directly into a notebook cell — the direct-paste version silently leaks
the key the moment the notebook gets pushed to GitHub. Common failure
mode: naming the file `.env.txt` instead of `.env` — most OSes hide the
real extension by default, so this is an easy typo to make and not
notice.

## Check for understanding — public API pick

Picked **Open-Meteo** (weather forecasts, no API key required at all) —
a useful contrast to NewsAPI/CoinCap earlier in the notebook, both of
which need registration + a key. Sent `latitude`/`longitude` plus a
`current` query param listing which fields to return (temperature,
humidity, wind speed, WMO weather code) for Madrid — got a clean 200
response back immediately. Worth remembering for next time: check an
API's docs for a no-auth quickstart before assuming every API needs the
full `.env` setup — some genuinely don't.

## Quest 2 — Shark Attacks (data cleaning practice)

The week's Quest deliverable: clean the [GSAF shark attack dataset](https://www.sharkattackfile.net/incidentlog.htm)
with pandas (≥5 data cleaning techniques) and run basic EDA to check a
hypothesis. Kept as its own repo (as the quest requires):

- Repo: [`shark-attack-risk-analysis`](https://github.com/aroaxinping/shark-attack-risk-analysis)
- Hypothesis: certain activities (surfing, swimming, diving...) carry more
  shark-attack risk than others — validated by comparing raw attack counts
  vs. fatality rate per activity.
