#!/bin/bash

main_branch=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p') # Determine current branch if HEAD is detached
main_branch="${main_branch##*/}" # Extract branch name if it's a ref
git checkout -q $main_branch

branches=()
refs=($(git for-each-ref refs/heads/ "--format=%(refname:short)"))

for branch in "${refs[@]}"
do
    mergeBase=$(git merge-base "$main_branch" "$branch")
    if [[ $(git cherry "$main_branch" $(git commit-tree $(git rev-parse "$branch^{tree}") -p "$mergeBase" -m _)) == "-"* ]]; then
        branches+=("$branch")
        echo $branch
    fi
done

if [[ ${#branches[@]} -gt 0 ]]; then
  echo "Continue deleting ${#branches[@]} branches? y/n"
  read -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    for branch in "${branches[@]}"
    do
      git branch -D $branch
    done
  fi
fi
