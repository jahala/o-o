#!/usr/bin/env bash
# test-update-all.sh — `--update-all` must dispatch an agent for EVERY stale doc.
#
# Real `claude -p` reads its stdin when stdin is not a terminal. update_all feeds
# its file list to a `while read` loop on stdin, so an agent that inherits that
# stdin swallows the rest of the list and only the first stale doc is updated.
# The stand-in `claude` below drains stdin the same way and records which doc
# each call was asked to update. Nothing is researched; costs $0.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail() { echo "FAIL: $*"; exit 1; }

WORK="$(mktemp -d /tmp/oo-test.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$WORK/docs" "$WORK/bin"
cp "$REPO/example/index.o-o.html" "$WORK/docs/"
for slug in openclaw agi-declared yc-w26-batch; do
  # Mark each doc stale so the freshness gate picks it.
  perl -pe 's/("as_of"\s*:\s*")[^"]*(")/${1}2000-01-01${2}/' \
    "$REPO/example/$slug.o-o.html" > "$WORK/docs/$slug.o-o.html"
done

CALLS="$WORK/calls.txt"
cat > "$WORK/bin/claude" <<STUB
#!/usr/bin/env bash
cat > /dev/null    # drain stdin, as real \`claude -p\` does when it is piped
printf '%s\n' "\$*" | grep -o '[^/ ]*\.o-o\.html' | head -1 >> "$CALLS"
STUB
chmod +x "$WORK/bin/claude"

( cd "$WORK/docs" && PATH="$WORK/bin:$PATH" bash index.o-o.html --update-all ) \
  > "$WORK/run.log" 2>&1 || fail "update-all exited non-zero. log:
$(cat "$WORK/run.log")"

got="$(sort "$CALLS" 2>/dev/null | tr '\n' ' ')"
want="agi-declared.o-o.html openclaw.o-o.html yc-w26-batch.o-o.html "
[[ "$got" == "$want" ]] || fail "expected agents for [$want], got [$got]"

echo "PASS: update-all dispatched every stale doc ($got)"
