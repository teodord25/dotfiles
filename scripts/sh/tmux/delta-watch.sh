#!/usr/bin/env bash
if ! command -v entr &> /dev/null; then
  echo "Error: entr is not installed"
  exit 1
fi
if ! command -v delta &> /dev/null; then
  echo "Error: delta is not installed"
  exit 1
fi
if ! git rev-parse --git-dir &>/dev/null; then
  echo "Not a git repository"
  exit 1
fi

git ls-files | entr sh -c 'git diff | delta --paging=never'
