# Show HN: o-o (looky-looky) – HTML files that watch the web and update themselves

Each `.o-o.html` file is a polyglot — valid HTML and valid bash. Open it in a browser to read a nicely formatted article. Run it with `bash` to update it via an LLM research agent.

```
open  article.o-o.html   # read it
bash  article.o-o.html   # update it
```

No build step, no server, no database. The file *is* the app.

**Why o-o?** The page has eyes. It watches the web and updates itself.

**How it works:** Each file has three zones — a shell preamble (hidden from the browser via heredoc), HTML/CSS/article content (rendered by the browser), and shell code at the bottom (executed by bash). When you bash it, the shell extracts an embedded "update contract" — topic, research intents, source policy, budget — and launches `claude -p` with a minimal bootstrap prompt. The agent reads the file itself, follows the contract, searches the web, and edits the article content in-place.

The agent never receives the whole file as prompt context. It reads the file using the Read tool and surgically edits only the `<article>`, manifest, source cache, and changelog.

**What's in the contract:**
- Identity: subject, scope, audience, tone
- Research: search intents, required sections, preferred/denied sources
- Budget: max cost per update (typically $0.50–$2.00)
- Images: whether to embed base64 data URIs, layout classes
- Freshness: daily/weekly/monthly — the file self-checks before spending money

**Library management:** An `index.o-o.html` serves as both a browsable card-grid library and a CLI:

```
bash index.o-o.html --new "Topic / scope description"   # scaffold + populate
bash index.o-o.html --update-all                         # update stale docs
```

**Requirements:** bash 3.2+ and the Claude Code CLI. No Python, Node, jq, or GNU coreutils. Portable across macOS and Linux.

**Why this format?** I wanted documents that stay current without me babysitting a pipeline. The polyglot trick means zero infrastructure — every file is self-contained, self-updating, and self-documenting. The contract gives you fine-grained control over what the agent researches and how much it spends.

Each document costs about $0.50–$3.00 per update depending on scope and model. The budget is embedded in the contract — you set it once and forget it.

GitHub: https://github.com/jahala/o-o
