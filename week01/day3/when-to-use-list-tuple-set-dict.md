# When to use a list, tuple, set, or dict

The four differ in more than syntax — each one solves a specific problem the
others don't. This is the reasoning for picking the right one, not just the
definitions.

## The core differences

| | List `[ ]` | Tuple `( )` | Set `{ }` | Dict `{k: v}` |
|---|---|---|---|---|
| Ordered? | yes | yes | **no** | yes (3.6+) |
| Mutable? | yes | **no** | yes | yes |
| Duplicates allowed? | yes | yes | **no** | keys: no / values: yes |
| Access by | index | index | *(can't access directly)* | key |

## Why you'd reach for each one

**List — the default choice.** An ordered collection you expect to change (add,
remove, reorder). `products = ["t-shirt", "mug", "hat"]` — order matters and
you expect to modify it over time.

**Tuple — a list that should never change.** Same as a list, except you're
telling yourself (and anyone reading the code) "this data is fixed, don't
touch it." E.g. `order_status = (total_products_ordered, percentage_ordered)`
from the customer orders lab — those two numbers are a fixed snapshot in
time, no reason they'd ever need `.append()` or `.remove()`. The immutability
is a *feature*, not a limitation — it protects the data from accidental
changes.

**Set — duplicates are meaningless and order doesn't matter.** The test:
*do I only care whether something exists, not how many times or in what
order?* That's `customer_orders` from the inventory lab — if the customer
types "mug" twice, that still just means "customer wants a mug," not "wants
two entries of the word mug." A list would happily store `["mug", "mug"]`; a
set collapses that to `{"mug"}` automatically. Same logic behind the
country-codes set comprehension — no need to write extra code to drop
duplicate `"IT"` codes, the set does it for free.

**Dict — look something up by a meaningful name, not a position.** The test:
*do I think of this data as pairs — a label and its value?*
`inventory = {"mug": 5, "hat": 3}` — you don't care that `"mug"` is at
position 0, you care that **the word "mug" maps to the number 5**. A list
would force you to remember "position 0 is always mugs," which is fragile.
A dict lets you ask directly: `inventory["mug"]`.

## Decision test while coding

1. Does each item need to be looked up by a **name/label**, not a position?
   → **dict**
2. Do duplicates need to be automatically thrown out, and order doesn't
   matter? → **set**
3. Is the data fixed forever once created (a fact, not something you'll
   edit)? → **tuple**
4. Otherwise — ordered, changeable, position-based? → **list** (the safe
   default)

If unsure, `list` is a fine fallback — but noticing when a set or dict fits
better (like `customer_orders`/`inventory` in the functions lab) is what
separates code that works from code that reads clearly and doesn't do
unnecessary extra work.
