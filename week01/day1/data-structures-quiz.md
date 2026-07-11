# Data Structures Quiz

Practice questions on Python lists, dictionaries, sets, and tuples.

---

### 1. Slicing a list

**Question:** After slicing a list with `[1:4]`, which elements will be included in the result?

```python
my_list = [1, 2, 3, 4, 5]
result = my_list[1:4]
print(result)
```

**Answer:** `[2, 3, 4]`

Slicing `[start:stop]` includes the start index but excludes the stop index. `[1:4]` grabs indices 1, 2, 3 (values 2, 3, 4) — index 4 (value 5) is left out.

---

### 2. Dictionary `.get()` with a default value

**Question:** An interviewer asks: "You're working with customer data stored in a dictionary. If a key doesn't exist, how would you safely retrieve a default value?" What will this code return when the `'city'` key is missing?

```python
my_dict = {'name': 'Alice', 'age': 25}
result = my_dict.get('city', 'Not found')
```

**Answer:** `'Not found'`

`.get(key, default)` looks up `key`. If it doesn't exist, it returns `default` instead of raising an error. This is the safe alternative to `my_dict['city']`, which would raise a `KeyError` since `'city'` isn't in the dictionary.

---

### 3. Appending and removing from a list

**Question:** A list starts with 3 items. After appending one item and removing another, how many items remain?

```python
fruits = ['apple', 'banana', 'orange']
fruits.append('grape')
fruits.remove('banana')
print(len(fruits))
```

**Answer:** `3`

`.append('grape')` adds one item (4 total), then `.remove('banana')` deletes one specific item by value (back to 3). Net change is zero, so the list still has 3 items — just different ones (`['apple', 'orange', 'grape']`).

---

### 4. Set intersection

**Question:** The intersection of two sets returns elements that appear in both. What will be the result of this operation?

```python
set1 = {1, 2, 3}
set2 = {3, 4, 5}
result = set1.intersection(set2)
print(result)
```

**Answer:** `{3}`

`.intersection()` returns only the elements common to **both** sets. `3` is the only value present in both `set1` and `set2`.

---

### 5. Indexing a tuple

**Question:** Accessing index `[1]` of a tuple returns which element?

```python
my_tuple = (10, 20, 30)
result = my_tuple[1]
```

**Answer:** `20`

Tuples are indexed the same way as lists — position 0 is the first element. `my_tuple[1]` is the second element: `20`.

---

### 6. Data structure characteristics (select all that apply)

**Question:** During a technical screening, you're asked about Python data structures. Which statements correctly describe their characteristics?

```python
# Consider these data structures:
my_list = [1, 2, 3]
my_dict = {'a': 1, 'b': 2}
my_set = {1, 2, 3}
my_tuple = (1, 2, 3)
```

- ✅ Dictionaries use keys to access values
- ❌ Tuples can be modified using the `append()` method — **false**, tuples are immutable and have no `append()` method
- ✅ Sets automatically remove duplicate elements
- ✅ Lists are mutable and can be modified after creation

**Key takeaway:** tuples are the only one of the four that's immutable — once created, it can't be changed.

---

### 7. Nested dictionary access

**Question:** Accessing nested dictionary data requires chaining indices. What value will be returned from this nested access?

```python
student = {'name': 'John', 'grades': [85, 90, 78]}
result = student['grades'][1]
print(result)
```

**Answer:** `90`

`student['grades']` first gets the list `[85, 90, 78]`. Then `[1]` grabs index 1 of *that* list — `90`. Chaining indices/keys like this lets you reach values buried inside nested structures.

---

### 8. Sorting a list

**Question:** After sorting a list in ascending order, the first element will be which value?

```python
numbers = [5, 2, 8, 1, 9]
numbers.sort()
print(numbers[0])
```

**Answer:** `1`

`.sort()` sorts the list in place, ascending by default. After sorting, `numbers` is `[1, 2, 5, 8, 9]`, so index `0` is the smallest value. For descending order, use `numbers.sort(reverse=True)`.

---

### 9. Inserting at an index

**Question:** Inserting an element at index 1 shifts existing elements. What will the list contain after this insertion?

```python
my_list = [1, 2, 3]
my_list.insert(1, 10)
print(my_list)
```

**Answer:** `[1, 10, 2, 3]`

`.insert(index, value)` places `value` at that exact position and shifts everything from that index onward one spot to the right. Nothing is overwritten or deleted. This differs from `.append()`, which always adds to the end.

---

### 10. Converting dictionary keys to a list

**Question:** Converting dictionary keys to a list creates which data structure?

```python
my_dict = {'a': 1, 'b': 2, 'c': 3}
result = list(my_dict.keys())
```

**Answer:** `['a', 'b', 'c']`

`.keys()` returns the dictionary's keys (not its values), and `list()` converts that into a list. For the values instead, use `.values()`.

| Method | Returns |
|---|---|
| `.keys()` | keys — `'a', 'b', 'c'` |
| `.values()` | values — `1, 2, 3` |
| `.items()` | key-value pairs — `('a', 1), ('b', 2), ('c', 3)` |
