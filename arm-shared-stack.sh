#!/usr/bin/env bash
# Arms the shared-* stack: three branches that all edit the SAME line of the SAME
# file. That is the shape whole-stack merge (G) used to fail on — once the bottom
# is squashed into main, the branch above still carries its commits, GitHub sees
# the same lines twice and refuses the merge. The green-* stack cannot show this:
# its layers touch separate files, so nothing ever collides.
#
#   bash arm-shared-stack.sh
#
# Idempotent and self-contained: tears its own branches down, leaves the rest of
# the QA fixture alone, and never commits to main. Ends checked out on shared-3.
set -uo pipefail
cd "$(dirname "$0")" || exit 1

say() { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }
FILE=shared.txt

say "Teardown: close shared-* PRs, drop the branches"
for n in $(gh pr list --state open --limit 100 --json number,headRefName \
             -q '.[]|select(.headRefName|startswith("shared-"))|.number' 2>/dev/null); do
  gh pr close "$n" --delete-branch=false >/dev/null 2>&1 && echo "  closed #$n"
done
git checkout main -q 2>/dev/null
git fetch origin -q --prune
for b in shared-1 shared-2 shared-3; do
  git branch -D "$b" >/dev/null 2>&1 && echo "  local  - $b"
  git push origin --delete "$b" >/dev/null 2>&1 && echo "  remote - $b"
  git config --unset "git-town-branch.$b.parent" 2>/dev/null
done
git reset --hard origin/main -q

say "Stack: shared-*  (every layer rewrites the same line)"
git checkout -b shared-1 -q
printf 'line A\nthe contested line, owned by layer 1\nline C\n' > "$FILE"
git add "$FILE"; git commit -q -m "shared-1: claim the contested line"
git push -q -u origin shared-1
git config git-town-branch.shared-1.parent main
echo "  + shared-1 (parent main)"

git checkout -b shared-2 -q
sed -i 's/^the contested line.*/the contested line, rewritten by layer 2/' "$FILE"
printf 'line D added by layer 2\n' >> "$FILE"
git add "$FILE"; git commit -q -m "shared-2: rewrite the contested line"
git push -q -u origin shared-2
git config git-town-branch.shared-2.parent shared-1
echo "  + shared-2 (parent shared-1)"

git checkout -b shared-3 -q
sed -i 's/^the contested line.*/the contested line, rewritten again by layer 3/' "$FILE"
git add "$FILE"; git commit -q -m "shared-3: rewrite the contested line again"
git push -q -u origin shared-3
git config git-town-branch.shared-3.parent shared-2
echo "  + shared-3 (parent shared-2)"

say "PRs"
gh pr create --base main     --head shared-1 --title "shared-1: claims the contested line" --body seed >/dev/null && echo "  PR shared-1 -> main"
gh pr create --base shared-1 --head shared-2 --title "shared-2: rewrites the same line"    --body seed >/dev/null && echo "  PR shared-2 -> shared-1"
gh pr create --base shared-2 --head shared-3 --title "shared-3: rewrites it once more"     --body seed >/dev/null && echo "  PR shared-3 -> shared-2"

git checkout shared-3 -q
say "Done. On shared-3. Expected after G: all three merged, main keeps layer 3's line."
