# Day 4 — Web Scraping

My notes on fetching a web page and pulling structured data out of its
HTML with `requests` + BeautifulSoup.

---

## The two libraries, two different jobs

```python
import requests
from bs4 import BeautifulSoup

response = requests.get(url)                        # 1. download the raw HTML
soup = BeautifulSoup(response.content, "html.parser")  # 2. parse it into something searchable
```

- **`requests`** — talks to the web server, downloads the page as raw
  bytes/text. It has no idea what HTML *means*.
- **`BeautifulSoup`** — takes that raw text and turns it into a tree of
  tags you can search, exactly the way a browser's DevTools "Elements"
  panel lets you click through the page structure.

`response.status_code` (200 = OK) and `response.headers['Content-Type']`
are worth checking before assuming the fetch actually got what you wanted
— a 403/429/404 still "succeeds" as a request, it just isn't the page.

### Getting blocked — 403 vs 429

- **403 Forbidden** — the server understood the request and refused it
  outright. Usually because `requests`' default User-Agent doesn't look
  like a real browser. Fix: send a real one.

  ```python
  headers = {"user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 ..."}
  response = requests.get(url, headers=headers)
  ```

  ([httpbin.org/user-agent](https://httpbin.org/user-agent) echoes back
  whatever User-Agent your own browser is currently sending, if you need a
  real one to copy.)
- **429 Too Many Requests** — a different problem: the server (or its IP
  reputation system) is rate-limiting or blocking the *origin*, not
  objecting to the headers. A better User-Agent doesn't fix this one — I
  hit this from a cloud/sandbox IP scraping `decathlon.com`, and it
  persisted even with the exact header that worked fine in class.

**Before scraping at all:** check whether the site has an API first (more
reliable, usually better-documented, and the way server admins would
rather you get the data) — and check `site.com/robots.txt` for what the
site's own guidelines say is/isn't OK to crawl.

---

## Finding elements

```python
soup.find("h1")                                          # first match
soup.find_all("h4", class_="product-title")               # every match, as a list
soup.select("article .product-title")                     # CSS selector syntax instead
```

- `find`/`find_all` take the tag name, then keyword arguments to filter —
  `class_` (trailing underscore, since `class` is a reserved word in
  Python), `id`, or any other attribute.
- `.select()` uses actual CSS selector syntax (`.class`, `#id`, `tag.class`,
  `parent child`) — same selectors as in a stylesheet or DevTools.
- Once you have one element, `.find()` again on *it* searches only inside
  that element's subtree — this is how you keep a name and its price
  paired to the same product instead of pulling all names and all prices
  as two separate, easily-misaligned lists.

### Getting the actual value out

```python
tag.text            # the visible text inside the tag
tag.get("href")      # an attribute's value (works for src, href, class, anything) -- None if missing
tag["href"]           # same as .get(), but raises an error instead of returning None if missing
```

---

## The real pattern: one container, not parallel lists

The naive approach — one `find_all` for every name, another for every
price — silently breaks the moment a page has missing/extra items,
because there's no guarantee list positions still line up.

```python
components = soup.find_all("product-card", class_="product-card size-style")   # the whole card, once

for component in components:
    name = component.find("span", class_="visually-hidden").text.strip()   # screen-reader text -- cleanest plain name available
    price_text = component.find("product-price").text.strip()
```

Find the **container** first (the whole product card), then search
*within* it for each field — that's what keeps a name and its price
guaranteed to belong to the same product, no matter how many items are on
the page.

**Real caveat, from actually doing this:** even with the container
pattern, extraction can still fail on a handful of items whose internal
HTML doesn't follow the same pattern as the rest (a handful of products
out of ~24 on the page, in my case) — real sites aren't perfectly
consistent, and a scraper that assumes 100% uniform structure will break
on the exceptions. Worth wrapping per-item extraction in a `try/except` if
missing a few items is preferable to the whole scrape crashing.

### Regex cleanup

Raw `.getText()` on a whole card often comes back full of stray
whitespace/newlines from the nesting:

```python
import re
item = re.sub(r'\n+\s+', '\n', elem.getText()).split("\n")
```

This collapses any run of `\n` + following whitespace down to a single
`\n`, then splits into a clean list of just the actual text lines. Fragile
in a different way though: parsing by **list index** (`item[1]`,
`item[4]`...) assumes every card has exactly the same number of text lines
in exactly the same order — breaks the moment one product's markup
structure differs even slightly.

---

## Scraping multiple pages

```python
pages = [f"https://example.com/products?page={p}" for p in range(1, total_pages + 1)]

def get_df_from_url(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    return extract_item_info(soup)

dfs = [get_df_from_url(page) for page in pages]
result_df = pd.concat(dfs, ignore_index=True)
```

Same single-page logic, just looped and concatenated. Two ways to know how
many pages exist: read the page count off the site's own pagination UI
(divide total product count by items-per-page), or loop until a page
comes back empty/404 (what I did in the lab, since
`books.toscrape.com/catalogue/page-51.html` returning a 404 was a
reliable, no-hardcoding stopping signal).

**Dynamic content — the thing that quietly breaks this:** the actual
results didn't fully match what the live site showed when scrolling
manually. Many modern sites load additional products via JavaScript
*after* the initial page load — `requests` only ever sees that first,
incomplete HTML response, since it doesn't run JavaScript at all. Tools
like **Selenium** exist specifically because they can drive a real browser
and wait for that JS-loaded content to actually appear before scraping it.
Worth checking early (view page source vs. what's visible in DevTools) —
if there's a mismatch, `requests`/BeautifulSoup alone won't be enough.

---

## Check for understanding — solved in [2.5_web_scraping.ipynb](2.5_web_scraping.ipynb)

`extract_item_info(soup)`: the container pattern above, wrapped into a
reusable function — item name, sale price, regular price, and product URL
per card, then looped across pages and concatenated.

Real, verified results from running this in class (not a synthetic test):
**24 items** on the first page, **288 rows total** after scraping and
concatenating 13 pages of `decathlon.com/collections/camp-hike`.

> **Note on re-verification:** I couldn't re-run this live from my
> environment — `decathlon.com` returned `429 Too Many Requests` even with
> the exact same User-Agent header that worked during class (see the 403
> vs 429 note above — this looks like an IP-level block on the sandbox,
> not a headers problem). The numbers above are the notebook's own stored
> output from when it *was* run successfully, not a re-verification by me.

---

## Lab | Web Scraping

`scrape_books(min_rating, max_price)` against
[books.toscrape.com](http://books.toscrape.com/) — a site built
specifically for scraping practice, no anti-bot blocking, unlike
`decathlon.com` above.

- Loops catalogue pages (`page-1.html`, `page-2.html`, ...) until a `404`
  signals the last one.
- Filters on the **listing page** first (price, star-rating class word —
  `"star-rating Four"` etc., mapped `One`–`Five` to `1`–`5`) — only books
  that already pass both thresholds get a second request to their detail
  page. Skipping the detail-page fetch for the ~925 non-matching books
  (out of 1000) is what keeps this fast (~30s instead of minutes).
- UPC, genre, and full description only exist on the **detail page**, not
  the listing — genre specifically comes from the breadcrumb
  (`Home / Books / <genre> / <title>`), not a dedicated "genre" field.
- `requests.Session()` reuses one connection across all ~125 requests
  (50 listing pages + 75 matching detail pages) instead of opening a new
  one each time.

Ran `scrape_books(min_rating=4.0, max_price=20)` — **75 books** matched,
returned as a DataFrame with the 7 required columns. Fully re-verified
live from this environment (unlike the class notebook above, this site
doesn't block scraping at all).

Solved here: [lab-web-scraping.ipynb](lab-web-scraping.ipynb)
(submitted via PR from [lab-web-scraping](https://github.com/aroaxinping/lab-web-scraping), required for the Student Portal to mark it as done)
