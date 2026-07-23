# Day 4 — Lambda Functions & Higher-Order Functions

My notes on lambda functions and the three higher-order functions built on
top of them: `map`, `filter`, `reduce`.

---

## Lambda functions

A lambda is a small, **anonymous** (unnamed), **single-expression** function —
no `def`, no name, defined right where it's used.

```python
lambda arguments: expression
```

```python
add = lambda x, y: x + y
add(5, 3)   # 8
```

Same idea as `def add(x, y): return x + y`, just compressed to one line —
there's an implicit `return`, you never write the word.

### When to actually use one

From the lesson's own checklist:

- Will I reuse this function elsewhere in the code? → if yes, use `def`
  instead (a lambda has no name to call again, unless you save it to a
  variable, which mostly defeats the point).
- Can the whole logic fit in a single expression? → if yes, lambda is fine;
  if it needs multiple lines/statements, `def` is required (lambdas can't
  contain `if/else` blocks, loops, multiple lines, etc. — only one expression).

In practice: lambdas show up almost entirely as **throwaway arguments** to
another function — `map()`, `filter()`, `reduce()`, `sorted(key=...)` — not
as a general replacement for `def`.

```python
data = [(2, 'apple'), (1, 'banana'), (3, 'orange')]
sorted(data, key=lambda elem: elem[1])   # sort by the second item of each tuple
```

**Summary:** no name, in-line, on the spot, not reusable (unless assigned to
a variable), can take multiple parameters just like a normal function.

---

## Higher-order functions

A higher-order function is one that **takes another function as an
argument** (or returns one). `map`, `filter`, and `reduce` are the three
standard ones — each takes a function + an iterable, and does something
different with the combination:

| Function | Takes | Returns | Same length as input? |
|---|---|---|---|
| `map` | function + iterable | iterator applying the function to each item | yes |
| `filter` | function (must return `True`/`False`) + iterable | iterator with only the items where it's `True` | no — usually shorter |
| `reduce` | function (2 args) + iterable | a single value | no — collapses to one |

All three return an **iterator**, not a list directly — wrap the call in
`list(...)` to see/use the results as a list.

### `map` — apply a function to every item

```python
numbers = [1, 2, 3, 4, 5]

def square(x):
    return x ** 2

squared_numbers = list(map(square, numbers))     # [1, 4, 9, 16, 25]
squared_numbers = list(map(lambda x: x ** 2, numbers))   # same, with lambda
```

Equivalent to a `for` loop with `.append()`, or a list comprehension — `map`
just saves writing the loop yourself when you already have a function ready.

**With two iterables at once:** the function needs as many parameters as
there are iterables, and `map` pairs up values by position:

```python
def addition(a, b):
    return a + b

iterable = [4, 16, 36]
iterable_2 = [40, 160, 360, 202202]

list(map(addition, iterable, iterable_2))                 # [44, 176, 396]
list(map(lambda a, b: a + b, iterable, iterable_2))        # same, with lambda
```

`map` stops at the **shortest** iterable — the extra `202202` in
`iterable_2` (which has no partner in `iterable`) is silently dropped, no
error.

**Check for understanding — solved in [1.5_lambda_functions.ipynb](1.5_lambda_functions.ipynb):** rewriting the two-iterable `addition` example with a lambda instead of `def`.

### `filter` — keep only the items that pass a test

```python
def is_even(x):
    return x % 2 == 0

numbers = [1, 2, 3, 4, 5]
list(filter(is_even, numbers))   # [2, 4]
```

The function passed to `filter` must return `True`/`False` — `filter` keeps
the item if `True`, drops it if `False`. Same result as a list comprehension
with an `if`:

```python
composers = ["Mozart", "Beethoven", "Bach", "Brahms", "Debussy"]
[c for c in composers if c.startswith("B")]              # comprehension
list(filter(lambda c: c.startswith("B"), composers))     # same, with filter+lambda
```

**Combining multiple conditions:** use `and`/`or` inside the lambda, same as
any other boolean expression — both sides must evaluate `True` for `and`.

**Check for understanding — solved in the notebook:** filter composers
starting with `"B"` **and** shorter than 7 characters.

```python
list(filter(lambda name: name.startswith("B") and len(name) < 7, composers))
# ['Bach', 'Brahms']  — "Beethoven" passes the first check but fails the
# second (9 characters), which is exactly why `and` matters here, not `or`.
```

### `reduce` — collapse an iterable down to one value

Not a built-in — has to be imported:

```python
from functools import reduce
```

```python
reduce(function, iterable)
```

It applies the function **cumulatively**: calls it on the first two items,
then calls it again on that result and the third item, and so on, until one
value is left.

```python
def addition(a, b):
    return a + b

numbers_15 = list(range(1, 16))
reduce(addition, numbers_15)   # 120 — same as sum(numbers_15)
```

**Trace for `reduce(addition, [2, 4, 7, 3])`:**
- `addition(2, 4)` → `6`
- `addition(6, 7)` → `13`
- `addition(13, 3)` → `16`
- no items left → returns `16`

Each step's result becomes the first argument (`a`) of the next call — that's
what "cumulative" means.

**Check for understanding — solved in the notebook:** join a list of words
into one string using `reduce` + lambda.

```python
list_of_strings = ["hey", "how", "are", "you", "doing"]
reduce(lambda a, b: a + " " + b, list_of_strings)
# "hey how are you doing"
```

Same result as `" ".join(list_of_strings)` — `reduce` is the general-purpose
tool for "collapse a list into one value," `.join()` is the specialized,
more idiomatic tool for this specific job (joining strings). Worth knowing
`reduce` exists for cases `.join()`/`sum()` don't cover (custom combining
logic), but reach for the specialized method first when one exists.

---

## Why use these instead of a `for` loop?

- Saves writing the loop/`.append()` boilerplate yourself.
- Often faster/more memory-efficient — they return iterators (produce values
  one at a time) rather than building a full list in memory immediately.
- Can make the intent more obvious at a glance once you're used to reading
  them — "map = transform each," "filter = keep some," "reduce = collapse to
  one."

---

## Quick reference

| Concept | Syntax |
|---|---|
| Lambda | `lambda args: expression` |
| Map | `list(map(function, iterable))` |
| Map, lambda | `list(map(lambda x: ..., iterable))` |
| Map, two iterables | `list(map(function, iterable1, iterable2))` |
| Filter | `list(filter(function, iterable))` — function must return `True`/`False` |
| Filter, lambda | `list(filter(lambda x: ..., iterable))` |
| Reduce | `from functools import reduce` then `reduce(function, iterable)` |

---

## Lab | Error Handling

Took the comprehension-lab solution (Managing Customer Orders) and wrapped
the input-taking functions in `try/except` retry loops so the program can't
crash on bad input:

- `initialize_inventory` — retries per product if the quantity is negative or
  not a number. Can't stay a one-line dict comprehension anymore, since each
  product needs its own retry loop.
- `calculate_total_price` — same retry pattern, for prices.
- `get_customer_orders` — now takes `inventory` as a parameter, so it can
  reject product names that don't exist or have zero stock, on top of
  validating the order count is a non-negative number.

**Key idea:** `int()`/`float()` already raise `ValueError` on non-numeric
input on their own — the `if quantity < 0: raise ValueError(...)` just adds
a *second*, explicit reason to land in the same `except` block, so both
"not a number" and "a negative number" get caught by one `except ValueError`.

Solved here: [lab-python-error-handling.ipynb](lab-python-error-handling.ipynb)
(submitted via PR from [lab-python-error-handling](https://github.com/aroaxinping/lab-python-error-handling), required for the Student Portal to mark it as done)
