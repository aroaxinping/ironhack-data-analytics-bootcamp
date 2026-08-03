# Ironhack Data Analytics Bootcamp

Documentation and exercises from the Ironhack Data Analytics bootcamp (July 2026).

> The bootcamp is taught in English, so I keep all my notes in English too.

## Structure

- [`prework/`](prework) — exercises before the bootcamp starts: data types, descriptive statistics, pseudocode, data structures (lists, dictionaries), conditionals and functions in Python.

Each week has its own folder with a `README.md` summary and `day1`–`day5` subfolders for each day's exercises. Expand a week to jump straight to its days:

<details>
<summary><strong>Week 1 — Introduction to Python</strong></summary>

[Week folder](week01)

- [Day 1](week01/day1) — Terminal, Git & GitHub, data structures
- [Day 2](week01/day2) — Flow control & functions
- [Day 3](week01/day3) — More on functions & comprehensions
- [Day 4](week01/day4) — Lambda, map/reduce/filter & error handling
- [Day 5](week01/day5) — Object-Oriented Programming & Python challenge

</details>

<details>
<summary><strong>Week 2 — Data Wrangling & Retrieval</strong></summary>

[Week folder](week02)

- [Day 1](week02/day1) — Data wrangling, GDPR & intro to Pandas
- [Day 2](week02/day2) — Data cleaning & manipulation
- [Day 3](week02/day3) — Structuring, combining & aggregating data
- [Day 4](week02/day4) — Web scraping
- [Day 5](week02/day5) — Quest deliverable & Data Wrangling challenge

</details>

<details>
<summary><strong>Week 3 — SQL</strong></summary>

[Week folder](week03)

- [Day 1](week03/day1) — Databases & data modelling
- [Day 2](week03/day2) — Basic SQL queries & aggregation
- [Day 3](week03/day3) — SQL joins & subqueries
- [Day 4](week03/day4) — Temporary tables, views, CTEs & window functions
- [Day 5](week03/day5) — Connecting SQL & Python, SQL challenge

</details>

<details>
<summary><strong>Week 4 — First Project</strong></summary>

[Week folder](week04)

- [Day 1](week04/day1) — Project kickoff, Git collaboration & Agile
- [Day 2](week04/day2) — Project work
- [Day 3](week04/day3) — Project work
- [Day 4](week04/day4) — Project work
- [Day 5](week04/day5) — Presentation & deliverable

</details>

<details>
<summary><strong>Week 5 — EDA and Inferential Stats</strong></summary>

[Week folder](week05)

- [Day 1](week05/day1) — EDA & univariate analysis
- [Day 2](week05/day2) — EDA bivariate analysis
- [Day 3](week05/day3) — Probability & hypothesis testing
- [Day 4](week05/day4) — Correlation, normality & Tableau
- [Day 5](week05/day5) — Advanced Tableau, storytelling & Vanguard project

</details>

<details>
<summary><strong>Week 6 — Second Project</strong></summary>

[Week folder](week06)

- [Day 1](week06/day1) — Project kickoff, Git & environments
- [Day 2](week06/day2) — Project work
- [Day 3](week06/day3) — Project work
- [Day 4](week06/day4) — Project work
- [Day 5](week06/day5) — Presentation & deliverable

</details>

<details>
<summary><strong>Week 7 — Machine Learning</strong></summary>

[Week folder](week07)

- [Day 1](week07/day1) — Intro to Machine Learning
- [Day 2](week07/day2) — Feature engineering
- [Day 3](week07/day3) — Supervised learning & ensemble methods
- [Day 4](week07/day4) — Hyperparameter tuning
- [Day 5](week07/day5) — Class imbalance

</details>

<details>
<summary><strong>Week 8 — APIs, LLMs, Cloud Computing, BigQuery & Final Project</strong></summary>

[Week folder](week08)

- [Day 1](week08/day1) — Week 7 project presentation & deliverable
- [Day 2](week08/day2) — APIs
- [Day 3](week08/day3) — Large Language Models (LLMs)
- [Day 4](week08/day4) — Cloud computing & BigQuery
- [Day 5](week08/day5) — Final project kickoff

</details>

<details>
<summary><strong>Week 9 — Final Project</strong></summary>

[Week folder](week09)

- [Day 1](week09/day1) — Final project work
- [Day 2](week09/day2) — Final project work
- [Day 3](week09/day3) — Final project work
- [Day 4](week09/day4) — Final project work
- [Day 5](week09/day5) — Presentation & deliverable

</details>

<details>
<summary><strong>Week 10 — Extra Week 1: Unsupervised Learning & Streamlit</strong></summary>

[Week folder](week10)

- [Day 1](week10/day1) — Web scraping recap & Gnod project
- [Day 2](week10/day2) — Unsupervised learning methods
- [Day 3](week10/day3) — Unsupervised learning metrics
- [Day 4](week10/day4) — Streamlit
- [Day 5](week10/day5) — PCA & week deliverable

</details>

<details>
<summary><strong>Week 11 — Extra Week 2: NumPy, PyTorch & Deep Learning</strong></summary>

[Week folder](week11)

- [Day 1](week11/day1) — Google Cloud Platform
- [Day 2](week11/day2) — NumPy
- [Day 3](week11/day3) — PyTorch tensors & neural networks
- [Day 4](week11/day4) — Build an LLM
- [Day 5](week11/day5) — Neural network example

</details>

As the bootcamp progresses, each week will be filled in with its projects and exercises.

## Labs

Solved `Lab | ...` notebooks live in this repo, inside their corresponding
day folder — see the day-by-day breakdown above.

Each lab is *also* kept as a separate fork of a
[`data-bootcamp-v4`](https://github.com/data-bootcamp-v4) template repo, only
because Ironhack's Student Portal requires it — it checks for an **open pull
request against the upstream repo** to mark a lab as done, not the code
itself. So the fork + PR is submission plumbing; this repo is the actual copy
I read back.

Workflow for each lab:

1. Fork the lab's template repo (e.g. `data-bootcamp-v4/lab-python-functions`) to my account.
2. Clone the fork locally.
3. Solve the exercise, commit, push to `origin` (my fork).
4. **Open a pull request from my fork back to the upstream `data-bootcamp-v4` repo** — easy to miss, some lab `README`s only mention `git push` and stop there.
5. Copy the solved notebook into this repo, in the matching day folder.
6. Sync/check in the Student Portal.

| Lab | Solved here | Submission PR |
|---|---|---|
| Data Structures | [week01/day1](week01/day1/lab-python-data-structures.ipynb) | [lab-python-data-structures](https://github.com/aroaxinping/lab-python-data-structures) |
| Flow Control | [week01/day2](week01/day2/lab-python-flow-control.ipynb) | [lab-python-flow-control](https://github.com/aroaxinping/lab-python-flow-control) |
| Functions | [week01/day2](week01/day2/lab-python-functions.ipynb) | [lab-python-functions](https://github.com/aroaxinping/lab-python-functions) |
| List, Dict, Set Comprehension | [week01/day3](week01/day3/lab-python-list-comprehension.ipynb) | [lab-python-list-dict-set-comprehension](https://github.com/aroaxinping/lab-python-list-dict-set-comprehension) |
| Error Handling | [week01/day4](week01/day4/lab-python-error-handling.ipynb) | [lab-python-error-handling](https://github.com/aroaxinping/lab-python-error-handling) |
| Pandas | [week02/day1](week02/day1/lab-dw-pandas.ipynb) | [lab-dw-pandas](https://github.com/aroaxinping/lab-dw-pandas) |
| Data Cleaning and Formatting | [week02/day2](week02/day2/lab-dw-data-cleaning-and-formatting.ipynb) | [lab-dw-data-cleaning-and-formatting](https://github.com/aroaxinping/lab-dw-data-cleaning-and-formatting) |
| Data Structuring and Combining | [week02/day3](week02/day3/lab-dw-data-structuring-and-combining.ipynb) | [lab-dw-data-structuring-and-combining](https://github.com/aroaxinping/lab-dw-data-structuring-and-combining) |
| Data Aggregation and Filtering | [week02/day3](week02/day3/lab-dw-aggregating.ipynb) | [lab-dw-data-aggregation-and-filtering](https://github.com/aroaxinping/lab-dw-data-aggregation-and-filtering) |
| Web Scraping | [week02/day4](week02/day4/lab-web-scraping.ipynb) | [lab-web-scraping](https://github.com/aroaxinping/lab-web-scraping) |
| MySQL Database Creation | [week03/day1](week03/day1/create.sql) | [lab-sql-mysql-db-creation](https://github.com/aroaxinping/lab-sql-mysql-db-creation) |

## Bonus content

Optional extra modules outside the 9 core weeks.

<details>
<summary><strong>Flask & Django</strong></summary>

[Folder](bonus/flask-django) — model deployment with Flask & Django (RNCP): intro to model deployment, deploying a data science project with Django, and Flask for data science deployment.

</details>

<details>
<summary><strong>AI Fundamentals</strong></summary>

[Folder](bonus/ai-fundamentals) — introduction to AI, ChatGPT & MS Copilot, AI ethics, AI security, field-specific AI applications, the societal impact of AI and the future of AI.

</details>

## About the bootcamp

Ironhack Data Analytics Bootcamp — an intensive full-time 9-week program with live classes taught in English. Start: July 2026.
