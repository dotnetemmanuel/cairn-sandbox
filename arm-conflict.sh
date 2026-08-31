#!/usr/bin/env bash
# Arms a conflict for demoing the resolver. Builds a three-branch stack, then adds
# a second commit to the BOTTOM branch, as if review feedback landed there after
# the layers above were already written. The layers above must now be replayed
# onto a bottom that moved, and they collide on the lines they share.
#
#   bash arm-conflict.sh      then, in Cairn: S, stand on demo-receipt, press R
#
# Round 1 (demo-checkout): 4 conflicts across 2 files, one per resolver choice.
# Round 2 (demo-receipt):  1 conflict, so the resolver reopens for the next layer.
#
# Local only: no push, no PRs, no commits on main, and it never touches a branch
# that is not demo-*. Idempotent. Ends checked out on demo-receipt.
set -uo pipefail
cd "$(dirname "$0")" || exit 1

say() { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }

say "Teardown: drop any previous demo-* branches"
# Deliberately not git-town undo: it would roll back whatever operation git-town
# ran last, which may have nothing to do with this fixture.
git rebase --abort >/dev/null 2>&1
git merge --abort  >/dev/null 2>&1
# An abandoned sync leaves git-town a runstate, and the next one stops to ask what
# to do with it. Cairn runs git-town with no terminal, so that ask is a dead end.
git-town status reset >/dev/null 2>&1
# git-town stashes untracked files while it works; if a run was killed mid-flight
# these scripts are sitting in that stash rather than on disk.
git stash list 2>/dev/null | grep -q "Git Town WIP" && git stash pop >/dev/null 2>&1 && git reset -q
git checkout main -q 2>/dev/null
for b in demo-menu demo-checkout demo-receipt; do
  git branch -D "$b" >/dev/null 2>&1 && echo "  - $b"
  git config --unset "git-town-branch.$b.parent" 2>/dev/null
done

# Each contested line needs at least five untouched lines around it, or git folds
# neighbouring edits into one big conflict region instead of separate ones.
gap() {
  printf '\n%s\n' "$1"
  printf '# these settings are inert, they only keep the sections apart\n'
  printf 'section_enabled = true\n'
  printf 'section_order = default\n\n'
}

say "demo-menu: the bottom branch"
git checkout -b demo-menu -q
{
  echo "greeting = Welcome to Northwind"
  gap "# --- prices ---"
  echo "currency = USD"
  gap "# --- payment methods ---"
  echo "methods = card"
  gap "# --- receipt ---"
  echo "receipt_footer = Thanks for shopping"
} > menu.txt
{
  echo "checkout_timeout_seconds = 30"
  gap "# --- retries ---"
  echo "retries = 1"
} > settings.txt
git add menu.txt settings.txt
git commit -q -m "demo-menu: first pass at the storefront settings"
git config git-town-branch.demo-menu.parent main
echo "  + demo-menu (parent main)"

say "demo-checkout: the middle layer, editing four of those lines"
git checkout -b demo-checkout -q
sed -i 's/^greeting = .*/greeting = Welcome back/'          menu.txt
sed -i 's/^currency = .*/currency = SEK/'                   menu.txt
sed -i 's/^methods = .*/methods = card, swish/'             menu.txt
sed -i 's/^checkout_timeout_seconds = .*/checkout_timeout_seconds = 45/' settings.txt
git add menu.txt settings.txt
git commit -q -m "demo-checkout: Swedish storefront and a longer timeout"
git config git-town-branch.demo-checkout.parent demo-menu
echo "  + demo-checkout (parent demo-menu)"

say "demo-receipt: a second branch off the bottom, editing a line of its own"
# A sibling of demo-checkout rather than a branch above it. Each one then replays
# only its own commit, so the second round asks a fresh question instead of
# repeating the first round's, and the tree shows a stack that forks.
git checkout demo-menu -q
git checkout -b demo-receipt -q
sed -i 's/^receipt_footer = .*/receipt_footer = Thanks! Keep this receipt/' menu.txt
# A second, uncontested change: without it, resolving the one conflict in favour
# of the incoming side empties the commit and git drops the branch's work.
echo "receipt_email = off" >> menu.txt
git add menu.txt
git commit -q -m "demo-receipt: reword the receipt footer"
git config git-town-branch.demo-receipt.parent demo-menu
echo "  + demo-receipt (parent demo-menu)"

say "Review feedback lands on demo-menu, and nothing above is restacked"
git checkout demo-menu -q
sed -i 's/^greeting = .*/greeting = Welcome to Northwind Traders/'   menu.txt
sed -i 's/^currency = .*/currency = EUR/'                            menu.txt
sed -i 's/^methods = .*/methods = card, invoice/'                    menu.txt
sed -i 's/^receipt_footer = .*/receipt_footer = Thank you for your order/' menu.txt
sed -i 's/^checkout_timeout_seconds = .*/checkout_timeout_seconds = 20/'   settings.txt
git add menu.txt settings.txt
git commit -q -m "demo-menu: apply review feedback on the storefront copy"

git checkout demo-menu -q
say "Armed. On demo-menu."
cat <<'TXT'
  In Cairn: press S, stand on demo-menu, press R (restack). Standing on the
  bottom branch is what pulls BOTH layers above it into the same run.

  Round 1 - demo-checkout, 4 conflicts over 2 files:
    menu.txt      greeting   ->  a   take incoming
    menu.txt      currency   ->  d   keep yours
    menu.txt      methods    ->  b   take both
    settings.txt  timeout    ->  e   edit your own value
    ] and [ move between files, f toggles the file list, n and N move between conflicts.
    c continues; from the confirmation, u undoes the whole restack.

  Round 2 - demo-receipt, 1 conflict on the receipt footer: the resolver reopens
  for the next branch, which is the point of the whole screen.

  To reset between rehearsals: bash arm-conflict.sh
TXT
