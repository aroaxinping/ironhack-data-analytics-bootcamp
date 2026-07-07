# Day 3 — List, Dict & Set Comprehension

My notes on comprehensions: a one-line way to build a list, dict, or set from
an existing iterable, instead of writing out a loop.

> Separate note: [when-to-use-list-tuple-set-dict.md](when-to-use-list-tuple-set-dict.md)
> — the reasoning for picking a list vs tuple vs set vs dict, not just syntax.

---

## List comprehension

```python
words = ['banana', 'apple', 'grape']

# the loop way
uppercase_words = []
for word in words:
    uppercase_words.append(word.upper())

# the comprehension way — same result
uppercase_words = [word.upper() for word in words]
```

- Three parts inside the brackets: **expression**, `for` loop, optional
  **condition**.
- No need to create an empty list first and `.append()` to it — the
  comprehension does both in one line.
- Works with any iterable, not just lists: `range()`, strings, dict `.items()`, etc.

  ```python
  squares = [n ** 2 for n in range(1, 11)]
  ```

### Adding a condition (filtering)

Putting `if` **after** the `for` filters which items make it into the result:

```python
even_numbers = [n for n in range(10) if n % 2 == 0]
```

- Only items where the condition is `True` get included — everything else is
  skipped, not transformed.
- Useful for skipping items that would otherwise error, e.g. calling `.upper()`
  on a list with non-string elements:

  ```python
  mixed_list = ['banana', 42, 'apple', None, 'grape', 3.14]
  uppercase_words = [item.upper() for item in mixed_list if isinstance(item, str)]
  ```

### If / else (transforming, not filtering)

If/else goes **before** the `for` instead — every item stays in the result,
but which expression is applied depends on the condition:

```python
new_list = [expression_if_true if condition else expression_if_false for item in original_list]
```

```python
mixed_words = ['banana', 'watermelon', 'kiwi', 'strawberry']
result = [word if len(word) > 7 else word.upper() for word in mixed_words]
# ['BANANA', 'watermelon', 'KIWI', 'strawberry']
```

**Filter vs transform, the key difference:** `if` alone after the `for` drops
items; `if/else` before the `for` keeps every item but changes what it becomes.

---

## Dictionary comprehension

```python
new_dict = {key_expression: value_expression for item in iterable}
```

```python
dict_numbers = {"a": 1, "b": 2, "c": 3, "d": 4, "e": 5}

# the loop way
dict_double = {}
for key, value in dict_numbers.items():
    dict_double[key] = value * 2

# the comprehension way — same result
dict_double = {key: value * 2 for key, value in dict_numbers.items()}
```

- Same idea as list comprehension: `key_expression` and `value_expression` can
  reuse the original key/value (here, `key` stays the same, `value * 2` changes).

```python
numbers = [1, 2, 3, 4, 5]
squares_dict = {n: n ** 2 for n in numbers}
```

- Can also build a dict straight from a list, using the list's values as keys:

  ```python
  words = ['banana', 'apple', 'grape']
  word_lengths = {word: len(word) for word in words}
  ```

- Or from two lists at once, zipped together (one as keys, one as values):

  ```python
  new_dict = {person: age for person, age in zip(names, ages)}
  ```

---

## Set comprehension

```python
new_set = {expression for item in iterable}
```

Same syntax as list comprehension, curly braces instead of square ones — and
since it's a set, duplicates collapse automatically:

```python
codes_countries = ["es-91", "en-88", "fra-12", "it-33", "ar-55", "it-34", "es-98"]
unique_codes = {code.split('-')[0].upper() for code in codes_countries}
# {'ES', 'EN', 'FRA', 'IT', 'AR'} — 'it-33' and 'it-34' both collapse to 'IT'
```

---

## Extra: nested comprehensions

Flattening a list of lists — one comprehension inside another:

```python
list_of_lists = [[1, 2, 3], [4, 5], [6, 7, 8, 9]]
flattened_list = [num for sublist in list_of_lists for num in sublist]
```

Read the `for` clauses left to right, same order as nesting a regular loop:
outer loop first, inner loop second.

---

## Lab | List, Dict, Set Comprehension

Took the [Managing Customer Orders](https://github.com/aroaxinping/lab-python-functions)
solution from the functions lab and rewrote each piece with comprehension:

- `initialize_inventory` — loop that filled the dict, replaced with a dict comprehension.
- `get_customer_orders` — asks for a number of orders up front, then builds the
  set with `{... for _ in range(num_orders)}` instead of a `while True` loop.
- `calculate_total_price` (new) — `sum(... for product in customer_orders)`, a
  generator expression passed straight into `sum()`.
- `update_inventory` — dict comprehension that both decrements the ordered
  products **and** filters out any that hit 0, so it disappears from the
  inventory instead of printing as `0`.

Solved here: [lab-python-list-comprehension.ipynb](lab-python-list-comprehension.ipynb)
(submitted via PR from [lab-python-list-dict-set-comprehension](https://github.com/aroaxinping/lab-python-list-dict-set-comprehension), required for the Student Portal to mark it as done)

---

## Quick reference

| Comprehension | Syntax | Notes |
|---|---|---|
| List | `[expr for item in iterable]` | |
| List, filtered | `[expr for item in iterable if cond]` | `if` after `for` → drops items |
| List, if/else | `[a if cond else b for item in iterable]` | `if/else` before `for` → transforms every item |
| Dict | `{key: value for item in iterable}` | |
| Set | `{expr for item in iterable}` | duplicates collapse automatically |
