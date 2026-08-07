# Day 5 — Connecting SQL & Python

- SQL Alchemy (+ hands on)
- Bonus: MySQL Connector
- SQL challenge

Solved from the real class notebook,
[4.7_connecting_python_sql.ipynb](4.7_connecting_python_sql.ipynb), against the
real `bank` database (same case study as the rest of week 3 — see
[day 2's README](../day2/README.md) for setup notes). No fork/lab repo for
today — the notebook itself is the exercise.

---

## SQLAlchemy — the engine

SQLAlchemy is the bridge between Python and the database — instead of typing
raw SQL into MySQL Workbench, you build a `connection_string`, hand it to
`create_engine()`, and everything downstream (queries, results, even pandas)
runs through Python. This setup happens in two separate steps, worth reading
as two steps rather than one block: first get the password *safely*, then
use it to build the connection string and create the `engine`.

```python
# Step 1 -- get the password without ever writing it in the code
password = getpass.getpass("Please give me your SQL password: ")

# Step 2 -- build the connection string with it, and create the engine
bd = "bank"
connection_string = 'mysql+pymysql://root:' + password + '@localhost/' + bd
engine = create_engine(connection_string)
```

`getpass.getpass()` instead of a plain `password = "..."` line is the whole
point of that cell — it prompts for the password without echoing it to the
notebook's output, so the password itself never gets typed into a cell or
saved in the `.ipynb` file. Doesn't fully solve credential storage (still
worth reading the two articles linked in the notebook on safer approaches),
but it's a meaningfully better default than hardcoding a password in plain
text.

The connection string format is always
**`dialect+driver://username:password@host:port/database`** — here,
`mysql+pymysql` is the dialect+driver pair (MySQL via the `pymysql` Python
library), `root:<password>` are the credentials, `localhost` is the host (no
port needed since MySQL's default `3306` is assumed), and `bank` is the
database.

## Running queries

```python
with engine.connect() as connection:
    query = text("SELECT * FROM loan LIMIT 5")
    result = connection.execute(query)

result
```

Two things worth calling out:

- **`text()` wraps a raw SQL string** so SQLAlchemy knows to treat it as a
  literal query rather than trying to parse it as part of its own query-
  building API (the ORM layer, which this class doesn't cover).
- **`with engine.connect() as connection:`** is a context manager —
  the connection opens for the block and is guaranteed to close afterward,
  even if something inside raises an error. Same idea as `with open(...)
  as f:` for files; forgetting to close a DB connection manually is an easy
  way to leak connections in a long-running script.

Checked rather than assumed: **the `with` block closing does *not* commit
any writes.** Ran an `INSERT` inside a `with engine.connect()` block without
calling `.commit()`, closed it, opened a brand new connection, and queried
the same table — 0 rows came back, the insert had been silently rolled
back. Only once `connection.commit()` was added *before* the block exits
did the row actually persist. Every example above is a `SELECT`, which is
why this never came up — but it matters the moment `INSERT`/`UPDATE`/
`DELETE` enters the picture (as it does in the MySQL Connector example
below, where `conn.commit()` is explicit for exactly this reason).

`connection.execute()` always returns a `CursorResult` object — not the data
itself yet, just a handle you then pull rows out of, several different ways
depending on what you need:

```python
# .first() -- one row, then the result set is closed
with engine.connect() as connection:
    result = connection.execute(text("SELECT * FROM loan LIMIT 5"))
    first_row = result.first()

# .all() -- every row, as a list of Row objects (or wrap in pd.DataFrame directly)
with engine.connect() as connection:
    result = connection.execute(text("SELECT * FROM loan LIMIT 5"))
    all_rows = result.all()
    df = pd.DataFrame(result.all())  # more useful in practice than raw Row objects

# .scalars() -- iterate just the first column, one value at a time
with engine.connect() as connection:
    result = connection.execute(text("SELECT loan_id FROM loan LIMIT 5"))
    for loan_id in result.scalars():
        print(loan_id)

# .scalars().all() -- same first column, but collected into a plain list
with engine.connect() as connection:
    result = connection.execute(text("SELECT loan_id FROM loan LIMIT 5"))
    loan_ids = result.scalars().all()
```

Verified against `bank.loan`: `.first()` returns
`(5314, 1787, 930705, 96396, 12, 8033.0, 'B')`, and `.scalars().all()` on
`loan_id` gives `[5314, 5316, 6863, 5325, 7240]` for the first 5 rows — same
underlying data, just reshaped depending on whether you want one row, all
rows, or a single column.

**A pattern that trips people up, worth stating explicitly**: a `Result`
object can only be consumed **once**. Call `.all()` a second time on the
same `result`, or try to reuse it outside the `with` block after the
connection's closed, and it errors — pull everything you need out of it
inside the block, in one pass.

### More examples on raw queries

Two summary queries against `bank.loan`, verified for real:

```python
with engine.connect() as connection:
    query = text("""
        SELECT DATE_FORMAT(CONVERT(date, DATE), '%Y') AS loan_year,
               COUNT(*) AS loans_granted
        FROM loan
        GROUP BY loan_year
        ORDER BY loan_year
    """)
    loans_per_year = pd.DataFrame(connection.execute(query).all())
```

```
loan_year  loans_granted
1993       20
1994       101
1995       90
1996       117
1997       196
1998       158
```

```python
# `duration` is already stored in months (12/24/36/48/60), not years
with engine.connect() as connection:
    query = text("SELECT duration, COUNT(*) AS loan_count FROM loan GROUP BY duration ORDER BY duration")
    loans_per_duration = pd.DataFrame(connection.execute(query).all())
```

```
duration  loan_count
12        131
24        138
36        130
48        138
60        145
```

Worth a note on the exercise wording itself: the notebook's instruction
("get how many loans were granted every year, and the month of each
duration") is a little garbled — `duration` is already in months, so "the
month of each duration" doesn't quite parse as written. Interpreted it as
two separate, reasonable summaries (loans per year; loan count per duration
value) rather than guessing at a single combined query that the phrasing
doesn't clearly describe.

---

## Bonus: MySQL Connector

A second, lower-level way to talk to MySQL from Python — `mysql-connector-
python`, MySQL's own official client library. Compared to SQLAlchemy:

| | SQLAlchemy | MySQL Connector |
|---|---|---|
| Scope | Any SQL database (dialects for Postgres, SQLite, etc.) | MySQL only |
| Level | Higher-level, has an ORM layer on top if wanted | Lower-level — direct connection + cursor, nothing else |
| Query results | `Result` object with `.first()`/`.all()`/`.scalars()` | Plain tuples via `cursor.fetchall()` |

```python
conn = mysql.connector.connect(host='localhost', user='root', passwd=password)
cursor = conn.cursor()
```

A `cursor` is what actually runs queries and tracks position in the result
set — conceptually similar to a `Result` object above, just from a
different library with a slightly different API (`cursor.execute()` +
`cursor.fetchall()` instead of `connection.execute()` + `.all()`).

### Worked example: CoffeeShop DB

The notebook's own example — create a database, a table, insert rows, query
them back — ran end to end for real:

```python
cursor.execute("CREATE DATABASE IF NOT EXISTS CoffeeShop")
cursor.execute("USE CoffeeShop")
cursor.execute("""
    CREATE TABLE IF NOT EXISTS Menu (
        coffee_id INT AUTO_INCREMENT PRIMARY KEY,
        coffee_name VARCHAR(255) NOT NULL,
        price DECIMAL(5,2) NOT NULL
    )
""")

menu_items = [("Espresso", 2.50), ("Cappuccino", 3.00), ("Latte", 3.50),
              ("Americano", 2.00), ("Mocha", 3.75)]
cursor.executemany("INSERT INTO Menu (coffee_name, price) VALUES (%s, %s)", menu_items)
conn.commit()   # nothing is actually saved to the database until commit() is called
```

`conn.commit()` is the one easy-to-miss step here — unlike a `SELECT`,
anything that changes data (`INSERT`/`UPDATE`/`CREATE`/`DELETE`) needs an
explicit `commit()` or it never actually lands in the database, even though
`cursor.execute()` ran without error.

```python
cursor.execute("SELECT coffee_name, price FROM Menu ORDER BY price DESC")
pd.DataFrame(cursor.fetchall())
```

```
coffee_name  price
Mocha        3.75
Latte        3.50
Cappuccino   3.00
Espresso     2.50
Americano    2.00
```

Always `cursor.close()` then `conn.close()` at the end — same reasoning as
the SQLAlchemy `with` block, just manual here since `mysql.connector`
doesn't wrap it in a context manager by default.

---

## Quick reference

| | SQLAlchemy | MySQL Connector |
|---|---|---|
| Connect | `create_engine(connection_string)` then `.connect()` | `mysql.connector.connect(...)` |
| Run a query | `connection.execute(text("..."))` | `cursor.execute("...")` |
| Get one row | `.first()` | `cursor.fetchone()` |
| Get all rows | `.all()` | `cursor.fetchall()` |
| Get one column only | `.scalars()` / `.scalars().all()` | manual loop over `fetchall()` rows |
| Save changes (`INSERT`/`UPDATE`) | needs explicit `connection.commit()` | needs explicit `conn.commit()` |
| Close | automatic (`with` block) | manual `cursor.close()` + `conn.close()` |
