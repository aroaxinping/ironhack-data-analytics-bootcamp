# Day 5 — Object-Oriented Programming & Python Challenge

My notes on classes, objects, attributes, methods, and inheritance.

---

## Class vs object vs instance

- **Class** — a blueprint/template. Defines what data an object can hold
  (**attributes**) and what it can do (**methods**). Like a cookie cutter.
- **Object** — a concrete thing built from that blueprint. Like a cookie.
- **Instance** — same thing as object, just the more formal word for it
  ("this object is an *instance* of that class").

Every value we've used so far is already an object of some built-in class:

```python
numbers = [1, 2, 3]
print(dir(numbers))   # every method/attribute the list class provides
```

`numbers` is an object, `list` is its class, `.append()` is a method that
class provides. Same idea for `float`, `str`, and everything else — even
`"Hello, " + "world!"` works because `str` defines an `__add__()` method
that the `+` operator calls behind the scenes:

```python
print("Hello, ".__add__("world!"))   # same result as "Hello, " + "world!"
```

---

## Method vs function vs attribute

| Term | What it is | Syntax |
|---|---|---|
| Attribute | a variable that belongs to an object/class | `object.attribute` |
| Method | a function that belongs to an object/class | `object.method()` |
| Function | reusable code, **not** tied to any object/class | `function_name()` |

---

## Defining a class

```python
class Student:
    def __init__(self, name, age):
        self.name = name
        self.age = age
        self.courses = []   # starts empty — courses get added later

    def add_course(self, course):
        self.courses.append(course)

    def display_info(self):
        print(f"Name: {self.name}")
        print(f"Age: {self.age}")
        print("Courses Enrolled:")
        for course in self.courses:
            print(f"- {course}")
```

- `__init__()` runs automatically when a new object is created — it's where
  you set up that object's starting attributes.
- **`self`** is how each object keeps its own data separate. It's the
  parameter every method gets automatically, referring to "the specific
  object this method was called on" — without it, every `Student` would
  share the same `name`/`age`/`courses`, instead of each having their own.
- The double underscores in `__init__` mark it as a special/"magic" method —
  Python calls it for you, you never call `student.__init__()` directly.

### Creating and using objects

```python
student1 = Student("Alice", 20)
student2 = Student("Bob", 22)

print(student1.name)          # accessing an attribute — "Alice"
student1.add_course("Math")   # calling a method
student1.display_info()
```

- `student1` and `student2` are two separate objects — same class, own data.
  `self` inside a method is what makes sure `add_course("Math")` only
  touches `student1`'s `courses` list, not `student2`'s.

### Default attribute values

Same idea as default parameters in a regular function — give `__init__` a
default, and objects created without that argument just use it:

```python
def __init__(self, name, age, email="not provided"):
    ...
    self.email = email

Student("Carol", 21)                # email -> "not provided"
Student("Dan", 23, "dan@mail.com")  # email -> "dan@mail.com"
```

---

## Instance vs class attributes/methods

- **Instance attributes** — belong to one specific object, set inside
  `__init__` via `self.x = ...`. Everything above is this.
- **Class attributes** — shared by *every* object of the class, defined
  directly in the class body (not inside `__init__`, no `self`):

  ```python
  class Circle:
      pi = 3.14159   # class attribute — same for every Circle

      def __init__(self, radius):
          self.radius = radius   # instance attribute — different per Circle

      @classmethod
      def get_pi(cls):
          return cls.pi
  ```

  `cls` here plays the same role `self` plays for instance methods, just at
  the class level instead of the object level.

---

## Check for understanding — solved in [1.7_oop.ipynb](1.7_oop.ipynb)

- **Easy** — [Regular Ball Super Ball](https://www.codewars.com/kata/53f0f358b9cb376eca001079)
  (8 kyu): a `Ball` class with one optional constructor argument, defaulting
  to `"regular"` if not given.
- **Medium** — [Building Blocks](https://www.codewars.com/kata/55b75fcf67e558d3750000a3)
  (7 kyu): a `Block` class from a `[width, length, height]` list, with getter
  methods plus `get_volume()`/`get_surface_area()`. Checked against the
  kata's own example — `[2, 4, 6]` → volume `48`, surface area `88`.

---

## Extra: inheritance

A **child class** can be based on a **parent class** — it inherits the
parent's attributes/methods, can override any of them, and can add its own.

```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def say_hello(self):
        return f"Hello, my name is {self.name}."

    def say_goodbye(self):
        return f"Goodbye, my name is {self.name}."


class Student(Person):   # inherits from Person
    def __init__(self, name, age, email="NA"):
        super().__init__(name, age)   # runs Person's __init__ first
        self.courses = []
        self.email = email

    def say_hello(self):   # overrides Person's version
        return super().say_hello() + f" and my student email is {self.email}."

    # say_goodbye is not redefined — Student just inherits Person's as-is

    def add_course(self, course):
        self.courses.append(course)
```

- **Method defined only in the parent** → child inherits it unchanged.
- **Method defined only in the child** → belongs to the child alone
  (inheritance is one-way; a `Person` can't call `add_course()`).
- **Method defined in both** → the child's version wins (overriding). If you
  still want the parent's behavior *plus* something extra, call it via
  `super().method_name()` instead of rewriting it from scratch — that's what
  `say_hello` does above.
- `super().__init__(...)` inside the child's `__init__` is what actually
  runs the parent's setup — skip it and `name`/`age` never get set.

```python
person1 = Person("Alice", 30)
student1 = Student("Bob", 20, "bob@gmail.com")

print(person1.say_hello())    # Person's own say_hello
print(student1.say_hello())   # Student's overridden version, calls super() internally

print(person1.say_goodbye())    # Person's
print(student1.say_goodbye())   # inherited unchanged from Person

student1.add_course("Math")     # fine, Student has this method
person1.add_course("Math")      # ❌ AttributeError — Person never got it, inheritance doesn't go upward
```

---

## Quick reference

| Concept | Syntax |
|---|---|
| Define a class | `class ClassName:` |
| Constructor | `def __init__(self, ...): self.x = ...` |
| Instance method | `def method(self, ...): ...` |
| Create an object | `obj = ClassName(...)` |
| Access attribute | `obj.attribute` |
| Call method | `obj.method()` |
| Class attribute | defined in class body, no `self` |
| Class method | `@classmethod` + `def method(cls): ...` |
| Inheritance | `class Child(Parent):` |
| Call parent's method | `super().method_name()` |
