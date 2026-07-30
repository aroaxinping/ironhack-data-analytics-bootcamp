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

---

## Finding elements

```python
soup.find("h1")                                  # first match
soup.find_all("h4", class_="product-title")       # every match, as a list
soup.select("article .product-title")             # CSS selector syntax instead
```

- `find`/`find_all` take the tag name, then keyword arguments to filter —
  `class_` (trailing underscore, since `class` is a reserved word in
  Python), `id`, or any other attribute.
- `.select()` uses actual CSS selector syntax (`.class`, `#id`, `tag.class`,
  `parent child`) — same selectors as in a stylesheet or DevTools. Multiple
  tags/classes chain the same way CSS does: `"article h4"` means "any `h4`
  inside an `article`", `".de-ProductTile .de-ProductTile-title"` means
  "class inside class."
- Once you have one element, `.find()` again on *it* searches only inside
  that element's subtree — this is how you keep a name and its price
  paired to the same product instead of pulling all names and all prices
  as two separate, easily-misaligned lists.

### Getting the actual value out

```python
tag.text            # the visible text inside the tag
tag.get("href")      # an attribute's value (works for src, href, class, anything)
tag["href"]           # same as .get(), but raises an error if missing instead of returning None
```

---

## The real pattern: one container, not parallel lists

The naive approach — one `find_all` for every name, another for every
price — silently breaks the moment a page has missing/extra items,
because there's no guarantee list positions still line up.

```python
components = soup.find_all("article", class_="de-ProductTile")   # the whole card, once

for component in components:
    name = component.find("h4", class_="de-ProductTile-title").text.strip()
    price = component.find("span", class_="js-de-ProductTile-currentPrice").text.strip().replace("$", "")
```

Find the **container** first (the whole product card), then search
*within* it for each field — that's what keeps a name and its price
guaranteed to belong to the same product, no matter how many items are on
the page.

---

## Check for understanding — solved in [2.6_web_scraping.ipynb](2.6_web_scraping.ipynb)

`extract_bike_info(soup)`: same one-container-per-item pattern, extended
to also pull the product URL and image URL out of the link/`<img>` nested
inside each card.

> **Note on verification:** `decathlon.com` (the site this lesson scrapes)
> returned `429 Too Many Requests` from this environment, even with a
> normal browser `User-Agent` header — likely blocking the sandbox's IP
> range outright, not something fixable by changing headers, and not
> something to push further on. I verified the function's logic against a
> synthetic HTML sample built from the exact same classes
> (`de-ProductTile`, `de-ProductTile-title`,
> `js-de-ProductTile-currentPrice`) the notebook's own earlier, already-
> working cells scrape with — the parsing logic is confirmed correct, just
> not re-verified against the live site from here.

---

## Scraping multiple pages

```python
pages = [f"https://example.com/products?page={p}" for p in range(1, 5)]

for page_url in pages:
    resp = requests.get(page_url)
    soup = BeautifulSoup(resp.content, "html.parser")
    # ... extract from this page, append to a running list
```

Same single-page logic, just looped — the only new part is knowing how
many pages exist. Two common ways to find out: read the page count off the
site's own pagination UI, or loop until a page returns something empty/404
(what I did in the lab, since `books.toscrape.com/catalogue/page-51.html`
being a 404 was a reliable stopping signal, and I didn't want to hardcode
"50 pages" into the function).

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
returned as a DataFrame with the 7 required columns.

Solved here: [lab-web-scraping.ipynb](lab-web-scraping.ipynb)
(submitted via PR from [lab-web-scraping](https://github.com/aroaxinping/lab-web-scraping), required for the Student Portal to mark it as done)
