# Day 2 — Flow Control & Functions

My notes on conditional logic, loops, and writing my own functions in Python.

---

## Flow control

"Flow control" just means: the order code runs in isn't always top-to-bottom —
these tools let the program branch or repeat.

### Conditionals (`if` / `elif` / `else`)

```python
age = 20

if age < 13:
    print("Child")
elif age < 18:
    print("Teenager")
else:
    print("Adult")
```

- Python checks conditions **top to bottom** and runs the **first** branch that's `True` — the rest are skipped, even if they'd also be `True`.
- `elif` = "else if" — lets you chain multiple conditions without nesting.
- `else` is optional — a fallback if nothing above matched.
- Indentation (4 spaces) is what defines the block — not `{}` like other languages.

### Comparison & logical operators (recap)

| Operator | Meaning |
|---|---|
| `== != > < >= <=` | comparisons — always return `True`/`False` |
| `and` | both sides must be `True` |
| `or` | at least one side must be `True` |
| `not` | flips a boolean |

```python
if age >= 18 and has_id:
    print("Can enter")
```

### Loops

**`for` loop** — repeat a fixed number of times, or once per item in something iterable (list, string, range, dict...):

```python
for fruit in ['apple', 'banana', 'orange']:
    print(fruit)

for i in range(5):        # 0, 1, 2, 3, 4
    print(i)
```

**`while` loop** — repeat as long as a condition stays `True`:

```python
count = 0
while count < 5:
    print(count)
    count += 1   # without this, infinite loop!
```

**Loop control keywords:**

| Keyword | What it does |
|---|---|
| `break` | exits the loop immediately |
| `continue` | skips to the next iteration, rest of the loop body is skipped |
| `pass` | does nothing — a placeholder so empty blocks don't error |

```python
for num in range(10):
    if num == 5:
        break        # stop entirely at 5
    if num % 2 == 0:
        continue     # skip even numbers, don't print them
    print(num)
```

**`for` vs `while`, when to use which:** if you know how many times / what you're iterating over → `for`. If you're waiting for a condition to change (and don't know how many loops that'll take) → `while`.

### Class exercise — even or odd (solved live, in groups)

In-class group exercise, ~10 minutes: prompt the user for a series of numbers (unknown count), store them in a list, then say which ones are even or odd.

```python
numbers = []

while True:
    entry = input("Enter a number (or type 'done' to finish): ")
    if entry.lower() == "done":
        break
    numbers.append(int(entry))

print("Numbers entered:", numbers)

for num in numbers:
    if num % 2 == 0:
        print(f"{num} is even")
    else:
        print(f"{num} is odd")
```

- Two separate loops, one job each: the `while` loop only *collects* (doesn't judge the numbers yet); the `for` loop only *classifies*, once the full list is known.
- `"done"` is a **sentinel value** — a value the user types that means "stop," picked because it can never be confused with an actual number.
- `%` (modulo) returns the remainder of a division. Any whole number `% 2` is either `0` (even) or `1` (odd) — that's the entire logic behind the classification, no need for `elif`, since a number can't be anything else.
- A professor-suggested alternative uses a `condition` flag instead of `break`:
  ```python
  condition = True
  while condition:
      entry = input("Enter a number (or type 'done' to finish): ")
      if entry.lower() == "done":
          condition = False
      else:
          numbers.append(int(entry))
  ```
  Both versions are equally correct — `break` works fine in `while` loops too, that's not `for`-only. The flag version just makes the stopping condition visible on the `while` line itself instead of inside the loop body; it's a style/readability choice, not a rule.

---

## Functions

A function is a reusable block of code — write it once, run it as many times as needed.

### Defining and calling

```python
def greet(name):
    print(f"Hello, {name}!")

greet("Aroa")   # calling it
```

- `def` starts the definition. The indented block underneath is the function body.
- Values passed in (`name`) are called **parameters** (in the definition) or **arguments** (at call time).

### Defining ≠ running

A `def` block is just a stored recipe — nothing inside it executes until the function is actually **called**. That means a parameter's default value, or anything referencing a variable, doesn't need that variable to exist yet at definition time:

```python
def say_hello(name="Aroa"):    # just defines the recipe — doesn't run yet
    print(f"Hello {name}")

user_name = "Marc"             # must exist BEFORE the call below (top-to-bottom order)
say_hello(user_name)           # only NOW does the function body actually run
```

Passing `"Marc"` as an argument is different from using `input()` — an argument is a value *you* already chose in the code; `input()` is for asking the *person running the program* for a value while it's running. They can be combined (`say_hello(input("Name: "))`), but they're separate mechanisms.

### `return` vs `print` — output vs return value

This is the classic beginner trip-up, and the two words aren't interchangeable:

- **Output** = whatever gets displayed on screen, via `print()`. Purely visual, not reusable.
- **Return value** = what the function hands back via `return`, to whoever called it — storable in a variable, usable in further code.

```python
def version_a(a, b):
    print(a + b)          # only outputs — nothing returned

def version_b(a, b):
    return a + b          # only returns — nothing printed

x = version_a(2, 3)   # prints "5" on screen
print(x)              # None  ← version_a never used `return`

y = version_b(2, 3)   # nothing appears on screen
print(y)              # 5     ← usable, because it was returned
```

**The test:** can you *do something* with what the function gave you afterward (`result = my_func()`, then use `result`)? That only works if the function used `return` — otherwise `result` is just `None`.

- A function with no `return` statement implicitly returns `None`.
- Keeping a function's job to "compute and return" (no `print()` inside it) makes it reusable anywhere — not tied to always printing to a console. That's why `count_words()` only returns; the `print()` happens outside it, at the call site.

### Default parameter values

```python
def greet(name, greeting="Hello"):
    print(f"{greeting}, {name}!")

greet("Aroa")                # Hello, Aroa!
greet("Aroa", "Hi")           # Hi, Aroa!
```

Default values let you call the function with fewer arguments — Python fills in the rest. Not "hardcoding" — you can always override the default by passing your own argument.

### Type hints (optional — not enforced)

```python
def add(a: int, b: int) -> int:
    return a + b
```

`: int` and `-> int` are **type hints** — pure documentation for humans and tools (VS Code, mypy), not a rule Python checks. This runs with zero errors despite lying about the return type:

```python
def add(a, b) -> int:
    return "surprise!"    # no error — hints aren't enforced

print(add(2, 3))   # surprise!
```

Not required for these labs — plain `def function_name(params):` (no hints) is completely standard and what I've been using.

### `isinstance()` vs `type()`

- `type(x)` **tells you** what type something is (returns the type itself).
- `isinstance(x, int)` **asks a yes/no question** — returns `True`/`False` — so it's meant for branching (`if isinstance(...)`), not for "finding out."

```python
type(5)               # <class 'int'>
isinstance(5, int)    # True

isinstance(5, (int, float))   # True — check several types at once with a tuple
```

Useful for validating a value before using it, e.g. `if not isinstance(quantity, int): print("invalid")`.

### Scope (local vs global)

Variables created *inside* a function only exist inside that function:

```python
def my_func():
    x = 10        # local to my_func
    print(x)

my_func()
print(x)          # ❌ NameError — x doesn't exist out here
```

**Why it matters:** functions are self-contained — they don't accidentally clash with variables of the same name elsewhere in the program.

### Check for understanding — `count_words` (solved in class)

Exercise from `1.3_functions.ipynb`: write a function that counts the words in a sentence the user types in.

```python
def count_words(sentence):
    words = sentence.split()
    return len(words)

sentence = input("Enter a sentence: ")
word_count = count_words(sentence)
print(f"Word count: {word_count}")
```

- `.split()` with no arguments breaks the string wherever there's whitespace (spaces, tabs, multiple spaces in a row all collapse into one split point) and gives back a list of words.
- `len()` on that list = how many words there are.
- Kept `count_words` doing exactly one job (counting) and returning the number — the `input()`/`print()` around it stay outside the function, so the function itself could be reused anywhere without being tied to the console.

---

## Quick reference

| Concept | Keyword(s) |
|---|---|
| Branch on a condition | `if`, `elif`, `else` |
| Repeat over items | `for` |
| Repeat while true | `while` |
| Stop a loop early | `break` |
| Skip to next iteration | `continue` |
| Do nothing (placeholder) | `pass` |
| Define a function | `def` |
| Hand back a value | `return` |
