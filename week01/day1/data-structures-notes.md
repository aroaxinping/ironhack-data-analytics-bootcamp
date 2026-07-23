# Data Structures — Notes

> These are my own summary notes from the Day 1/2 lesson. The original class
> material (`1.1_data_structures.ipynb`) belongs to Ironhack's
> [data-bootcamp-v4/lessons](https://github.com/data-bootcamp-v4/lessons)
> repo — not reproduced here, just my takeaways in my own words.

---

## Data types recap

| Type | Example | Notes |
|---|---|---|
| `int` | `10`, `-5` | whole numbers |
| `float` | `20.2`, `-5.5` | decimals |
| `str` | `"hello"` | text |
| `bool` | `True`, `False` | `True` behaves like `1`, `False` like `0` |

`type(x)` tells you what you're dealing with. Handy when you're not sure what a variable holds.

## Operators, quick reference

- **Arithmetic:** `+ - * / // % **` — on strings, only `+` (concat) and `*` (repeat) work.
- **Assignment shortcuts:** `x += 3` is the same as `x = x + 3` (same idea for `-=`, `*=`, etc.)
- **Comparison:** `== != > < >= <=` → always return a boolean.
- **Logical:** `and`, `or`, `not` → combine/negate booleans.
- **Casting:** `int()`, `float()`, `str()`, `bool()` convert between types — only works if it actually makes sense (e.g. `int("abc")` blows up).

## Input / output

```python
name = input("Enter your name: ")   # input() ALWAYS returns a string
print("Hello,", name)
```

Common gotcha: if you `input()` a number, you have to `int()` or `float()` it yourself before doing math with it. Also: `print()` returns `None` — don't assign its result to a variable expecting something useful.

### f-strings

The `f` right before the opening quote turns `{ }` inside the string into "evaluate this as code, insert the result" instead of literal text:

```python
a = 5
print(f'Value of a is {a}')     # Value of a is 5
print('Value of a is {a}')      # Value of a is {a}  ← no f, no substitution
```

Works with any expression, not just a bare variable — math, method calls, formatting:

```python
print(f'Total: {precio * 1.21:.2f}')   # :.2f → 2 decimal places
```

It re-reads the value at the moment `print()` runs, so the same template gives different output if the variable changed in between. This is the standard way to build output now — cleaner than `"Hello, " + name + "!"` or `"Hello, {}!".format(name)`.

---

## Lists `[ ]` — ordered, mutable

- Indexed from `0`; negative indices count from the end (`-1` = last item).
- Slicing: `list[start:stop:step]` — `start` inclusive, `stop` exclusive.
- Mutable → you can reassign an item by index: `my_list[0] = 99`.
- `.sort()` sorts **in place** (changes the original list, returns `None`).
- `sorted(my_list)` returns a **new** sorted list, leaves the original untouched.
- Calling `.remove(x)` a second time on a value that's no longer there raises `ValueError` — the item is already gone.

### `.remove()` vs `.pop()`

| | `.remove(value)` | `.pop(index)` |
|---|---|---|
| Deletes by | **value** | **position** (last item if no index given) |
| Returns | `None` | the removed element |
| If missing/out of range | `ValueError` | `IndexError` |

```python
frutas = ["manzana", "pera", "uva", "pera"]
frutas.remove("pera")      # deletes only the FIRST "pera" → other stays
ultima = frutas.pop()      # removes AND returns the last item, usable afterward
```

Use `.pop()` when you need the removed value for something (e.g. `tarea = pendientes.pop(0)`); use `.remove()` when you just want a specific value gone and don't care about it afterward. `del my_list[i]` is a third option — deletes by index like `.pop()`, but returns nothing.

### List comprehensions

A compact way to build a new list from a loop, in one line instead of three. Same logic as a `for` + `.append()` loop, just reordered:

```python
# long way
squares = []
for n in range(1, 6):
    squares.append(n ** 2)

# comprehension — [expression for item in iterable]
squares = [n ** 2 for n in range(1, 6)]
```

Read it as *"give me `expression`, for each `item` in `iterable`"* — the "what to keep" comes before the "where it comes from," which is the opposite order from a normal loop and the reason it's confusing at first. Can also filter with an `if` at the end:

```python
short_names = [p for p in products if len(p) <= 3]
```

Only reach for this when actually **building a new list**; if the loop does something else (assign to a dict, call `input()`, etc.), a normal `for` loop is the right tool, not a comprehension.

**Where the word "comprehension" comes from:** not the everyday English sense ("understanding"). It's borrowed from math **set-builder notation** — `{x² : x ∈ {1,2,3}}` reads "the set of x², for each x in {1,2,3}" and was called a "set comprehension." Python reused the term for the same idea with lists. So "comprehension" here means *"the rule that defines which elements to include"* — nothing to do with comprehending/understanding.

**Check for understanding:** create a new list, substituting `"e"` for every `"a"` in each word of an existing `words` list.

```python
e_words = [word.replace('a', 'e') for word in words]
print(e_words)
```

- `word.replace('a', 'e')` — for each `word`, returns a new string with every `'a'` swapped for `'e'` (case-sensitive: a capital `'A'` is untouched).
- The comprehension applies that `.replace()` call to every word in `words` and collects the results into `e_words`.
- `words` itself is left unchanged — `.replace()` always returns a new string rather than modifying in place, since strings are immutable.
- One line is the complete, correct solution here — a comprehension is meant to replace the loop *and* the `.append()` in one go, so a short one-liner isn't "missing steps," it's the whole point.

## Dictionaries `{ key: value }` — key-based, mutable

- Access with `my_dict[key]` — raises `KeyError` if the key doesn't exist.
- Safer: `my_dict.get(key, default)` — returns `default` instead of crashing.
- Add/update: `my_dict[key] = value` (adds if new, overwrites if key exists).
- Remove: `del my_dict[key]` or `my_dict.pop(key)`.
- Check existence without crashing: `if key in my_dict:`.
- `.keys()`, `.values()`, `.items()` → views of keys, values, and (key, value) pairs.
- Values can be *anything*, including lists or other dictionaries — that's what makes nesting possible (see below).

## Sets `{ }` — unordered, unique, mutable

- No duplicates — adding an existing value does nothing.
- No indexing (`my_set[0]` doesn't work — there's no "first" item since it's unordered).
- Supports math-style set ops: `.union()`, `.intersection()`, `.difference()`.

## Tuples `( )` — ordered, immutable

- Same indexing/slicing as lists, but **no** `.append()`, `.remove()`, or item reassignment — trying it raises an error.
- Good for values that shouldn't change once created (e.g. coordinates, fixed stats).

## Cheat table: how do I access data?

| Structure | Access by |
|---|---|
| List / Tuple | index (position) |
| Dictionary | key |
| Set | *(no direct access — unordered)* |

---

## Nested structures (dict of dicts, list of dicts, etc.)

You can chain keys/indices to dig into nested data:

```python
student_data = {
    'Jane': {'age': 22, 'grades': [92, 88, 95]}
}

student_data['Jane']['grades'][0]   # → 92
```

Read it left to right: get `'Jane'` → get `'grades'` from that dict → get index `0` from that list. The type at each step tells you whether the next access should be `[key]` or `[index]`.

There's no real limit to how deep this can go — lists of dicts of lists of dicts, etc. When in doubt, `type()` the thing you're about to index into.

## `is` vs `==`

- `==` compares **values** — "do these look the same?"
- `is` compares **identity** — "are these literally the same object in memory?"

```python
a = [1, 2]
b = [1, 2]
a == b   # True  → same values
a is b   # False → different objects in memory
a = b
a is b   # True  → now they point to the same object
```

`id(x)` shows the memory address, which is what `is` actually checks under the hood. In practice: use `==` almost always; `is` mostly shows up when checking against `None` (`if x is None:`).
