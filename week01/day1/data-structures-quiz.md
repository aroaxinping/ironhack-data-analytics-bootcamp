# Data Structures Quiz

Practice questions on Python lists, dictionaries, sets, and tuples.

---

### 1. Slicing a list

```python
my_list = [1, 2, 3, 4, 5]
result = my_list[1:4]
print(result)
```

**Answer:** `[2, 3, 4]`

Slicing `[start:stop]` includes the start index but excludes the stop index. `[1:4]` grabs indices 1, 2, 3 (values 2, 3, 4) — index 4 (value 5) is left out.

---

### 2. Dictionary `.get()` with a default value

```python
my_dict = {'name': 'Alice', 'age': 25}
result = my_dict.get('city', 'Not found')
```

**Answer:** `'Not found'`

`.get(key, default)` looks up `key`. If it doesn't exist, it returns `default` instead of raising an error. This is the safe alternative to `my_dict['city']`, which would raise a `KeyError` since `'city'` isn't in the dictionary.

---

### 3. Data structure characteristics (select all that apply)

```python
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

### 4. Sorting a list

```python
numbers = [5, 2, 8, 1, 9]
numbers.sort()
print(numbers[0])
```

**Answer:** `1`

`.sort()` sorts the list in place, ascending by default. After sorting, `numbers` is `[1, 2, 5, 8, 9]`, so index `0` is the smallest value. For descending order, use `numbers.sort(reverse=True)`.

---

### 5. Inserting at an index

```python
my_list = [1, 2, 3]
my_list.insert(1, 10)
print(my_list)
```

**Answer:** `[1, 10, 2, 3]`

`.insert(index, value)` places `value` at that exact position and shifts everything from that index onward one spot to the right. Nothing is overwritten or deleted. This differs from `.append()`, which always adds to the end.

---

### 6. Converting dictionary keys to a list

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
