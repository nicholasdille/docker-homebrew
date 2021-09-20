#!/bin/bash
set -eo pipefail

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# GITHUB_WORKSPACE=/home/runner/work/foo/bar
if test "$(pwd | tr -cd '/' | wc -c)" -lt 2; then
    echo "ERROR: Must be at least two directories deep."
    exit 1
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
DEFAULT_BRANCH="$(git remote show origin | grep "HEAD branch" | cut -d' ' -f5)"
if test "${CURRENT_BRANCH}" == "${DEFAULT_BRANCH}"; then
    echo "ERROR: Cannot run on default branch."
    exit 1
fi

export GITHUB_EVENT_NAME="pull_request"
export GITHUB_REPOSITORY="$(git config --get remote.origin.url | cut -d/ -f4-)"
export GITHUB_REPOSITORY_OWNER="$(echo "${GITHUB_REPOSITORY}" | cut -d/ -f1)"
export GITHUB_SHA="$(git rev-parse HEAD)"
export GITHUB_HEAD_REF="$(git branch --show-current)"
export GITHUB_PR_NUMBER="$(curl --silent "https://api.github.com/search/issues?q=repo:${GITHUB_REPOSITORY}+is:pr+head:${GITHUB_HEAD_REF}" | jq --raw-output '.items[].number')"
export GITHUB_REF="refs/pull/${GITHUB_PR_NUMBER}/merge"
export GITHUB_BASE_REF="$(curl --silent "https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls/${GITHUB_PR_NUMBER}" | jq --raw-output '.base.ref')"

printenv | sort

echo
echo "#####################################"
echo "### Set up Homebrew for GitHub CI ###"
echo "#####################################"
curl -sL https://github.com/Homebrew/actions/raw/master/setup-homebrew/main.sh | RUNNER_OS=Linux bash -s "" ""
brew install-bundler-gems

echo
echo "#####################################"
echo "### Test bot: Only cleanup before ###"
echo "#####################################"
brew test-bot --only-cleanup-before

echo
echo "#####################################"
echo "### Test bot: Only setup          ###"
echo "#####################################"
brew test-bot --only-setup

echo
echo "#####################################"
echo "### Test bot: Only tap syntax     ###"
echo "#####################################"
brew test-bot --only-tap-syntax

echo
echo "#####################################"
echo "### Test bot: Only formulae       ###"
echo "#####################################"
brew test-bot --only-formulae
