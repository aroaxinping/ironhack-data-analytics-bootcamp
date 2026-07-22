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

### `return` vs `print`

This is the classic beginner trip-up:

```python
def add(a, b):
    return a + b       # gives the result back to whoever called it

result = add(2, 3)     # result = 5, usable elsewhere
print(result)
```

- `print()` just displays something on screen — the function still returns `None`.
- `return` actually hands the value back so you can store it in a variable, pass it to another function, etc.
- A function with no `return` statement implicitly returns `None`.

### Default parameter values

```python
def greet(name, greeting="Hello"):
    print(f"{greeting}, {name}!")

greet("Aroa")                # Hello, Aroa!
greet("Aroa", "Hi")           # Hi, Aroa!
```

Default values let you call the function with fewer arguments — Python fills in the rest.

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
