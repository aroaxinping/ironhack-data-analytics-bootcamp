# Day 3 — Large Language Models (LLMs)

- Intro to LLMs
- Large Language Models APIs

---

Class notebook: [`8.3_llm_apis_intro.ipynb`](8.3_llm_apis_intro.ipynb). Left
**unexecuted as downloaded** — every live cell needs a `GROQ_API_KEY` in a
local `.env` file, which I don't have configured on this machine. The
mini-activities are open-ended ("run this several times and compare",
"discuss with a classmate") rather than something with one deterministic
answer to compute, so there's nothing to fake here — running it for real
needs the user's own Groq key.

## An LLM API is still just an API

The whole notebook's framing: same ingredients as any other HTTP API —
endpoint, headers (auth), JSON payload, POST, JSON response. The only new
part is the payload shape a chat endpoint expects
(`{"model": ..., "messages": [...]}`) and the response shape
(`response["choices"][0]["message"]["content"]`).

## Three things people conflate: model, tokenizer, provider

- **Model/model family** — e.g. Llama, Qwen (the actual neural network +
  weights).
- **Tokenizer** — converts text ↔ tokens; tied to a specific model family,
  usually invisible when using a hosted API.
- **Provider** — who actually runs the model and exposes it over HTTP (e.g.
  Groq hosting a Llama or GPT-OSS model). The same model can be hosted by
  multiple providers with different price/latency/limits — picking a model
  and picking a provider are two separate decisions.

## Don't hardcode the model — discover it

```python
response = requests.get(MODELS_URL, headers=headers, timeout=30)
available_models = [model["id"] for model in response.json()["data"]]
```

Provider catalogues change (models get renamed/removed), so the notebook
queries `GET /models` instead of hardcoding an ID. But `/models` doesn't
tell you which ones are chat-appropriate — it can list speech-to-text or
safety models too — so the pattern is a **preferred-list intersected with
what's actually available**, not `available_models[0]`:

```python
preferred_models = ["openai/gpt-oss-20b", "openai/gpt-oss-120b"]
MODEL = next((m for m in preferred_models if m in available_models), None)
```

Taking `available_models[0]` blindly would risk picking a non-chat model
(the API has no `type: chat` filter here) and silently sending it a chat
payload it isn't built for.

## Messages, roles, and memory

A conversation is a **list of dicts** with `role` (`system`/`user`/
`assistant`) and `content` — `system` sets behavior/persona, `user` is
input, `assistant` is a prior model reply fed back in.

The one non-obvious part: **the API has no memory of its own.** Every
request is stateless — a follow-up question only "remembers" earlier turns
because the client re-sends the whole message list, with the previous
answer appended as an `assistant` message:

```python
conversation.append({"role": "assistant", "content": first_answer})
conversation.append({"role": "user", "content": "Now explain with an INNER JOIN..."})
second_answer = chat(conversation)   # sees the full history, not just the new question
```

Drop the earlier turns and a follow-up like "explain how the result would
differ" has nothing to compare against — the model has no idea what "the
result" even refers to anymore.

## `temperature` ≠ a creativity dial

Lower temperature → more deterministic/predictable token selection; higher
→ more varied. It does **not** make the model more knowledgeable or
"better" — it changes how much it's willing to deviate from the
highest-probability next token. For anything where a wrong/inconsistent
answer is costly (e.g. summarizing real business numbers), lower
temperature is the safer default.

## Context and hallucination

Asking `"What was the total revenue of my company last year?"` with no data
attached has exactly one honest answer: "I don't have that information."
An LLM can instead produce a plausible-sounding but fabricated number — a
**hallucination**. The fix isn't "trust it less," it's **give it the actual
data as context** before asking it to reason over it.

## The actual DA pattern: pandas calculates, the LLM interprets

```
Raw data → pandas (real metrics) → LLM + instructions + those metrics → written interpretation
```

The notebook's example feeds a small `sales` DataFrame's *already-computed*
`return_rate`/`revenue_share` columns to the model as CSV text inside the
prompt, and asks it to identify insights **supported by the given numbers**
— explicitly instructed not to invent causes not present in the data. The
LLM is doing communication/interpretation, not the arithmetic — pandas
already did that deterministically. Worth reviewing the output critically
regardless: did it confuse revenue with units sold, did it infer an
unsupported cause, are "most important" insights actually objective or a
judgment call dressed up as one.

## To actually run this notebook

1. Get a Groq API key, put it in `~/ironhack-data-analytics-bootcamp/.env`
   as `GROQ_API_KEY="..."` (already gitignored — never commit it).
2. `pip install requests python-dotenv pandas` if not already available.
3. Run top to bottom; the mini-activities (temperature comparison, memory
   on/off, improved prompt) are meant to be run interactively and compared
   by eye, not graded by a fixed expected output.
