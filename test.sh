#!/bin/bash
set -eo pipefail

if ! test -d "${PWD}/.git"; then
    echo "ERROR: Must run on a git repository."
    exit 1
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
DEFAULT_BRANCH="$(git remote show origin | grep "HEAD branch" | cut -d' ' -f5)"
if test "${CURRENT_BRANCH}" == "${DEFAULT_BRANCH}"; then
    echo "ERROR: Cannot run on default branch (current branch <${CURRENT_BRANCH}>)."
    exit 1
fi

export GITHUB_EVENT_NAME="pull_request"
export GITHUB_REPOSITORY="$(git config --get remote.origin.url | cut -d/ -f4-)"
export GITHUB_REPOSITORY_OWNER="$(echo "${GITHUB_REPOSITORY}" | cut -d/ -f1)"
export GITHUB_SHA="$(git rev-parse HEAD)"
export GITHUB_HEAD_REF="$(git branch --show-current)"
export GITHUB_PR_NUMBER="$(curl --silent "https://api.github.com/search/issues?q=repo:${GITHUB_REPOSITORY}+is:pr+head:${GITHUB_HEAD_REF}" | jq --raw-output '.items[].number')"
export GITHUB_REF="refs/pull/${GITHUB_PR_NUMBER}"
export GITHUB_BASE_REF="$(curl --silent "https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls/${GITHUB_PR_NUMBER}" | jq --raw-output '.base.ref')"
export GITHUB_WORKSPACE="/$(mktemp -d)/${GITHUB_REPOSITORY}"

echo
echo "#####################################"
echo "### Set up Homebrew for GitHub CI ###"
echo "#####################################"
echo "GITHUB_WORKSPACE:        ${GITHUB_WORKSPACE}"
echo "GITHUB_EVENT_NAME:       ${GITHUB_EVENT_NAME}"
echo "GITHUB_REPOSITORY:       ${GITHUB_REPOSITORY}"
echo "GITHUB_REPOSITORY_OWNER: ${GITHUB_REPOSITORY_OWNER}"
echo "GITHUB_SHA:              ${GITHUB_SHA}"
echo "GITHUB_HEAD_REF:         ${GITHUB_HEAD_REF}"
echo "GITHUB_PR_NUMBER:        ${GITHUB_PR_NUMBER}"
echo "GITHUB_REF:              ${GITHUB_REF}"
echo "GITHUB_BASE_REF:         ${GITHUB_BASE_REF}"

echo
echo "#####################################"
echo "### Set up Homebrew for GitHub CI ###"
echo "#####################################"
mkdir -p "${GITHUB_WORKSPACE}"
HOMEBREW_TAP_REPOSITORY="$(brew --repo "$GITHUB_REPOSITORY")"
if test -d "${HOMEBREW_TAP_REPOSITORY}"; then
    cd "${HOMEBREW_TAP_REPOSITORY}"
    git remote set-url origin "https://github.com/${GITHUB_REPOSITORY}"
else
    mkdir -p "${HOMEBREW_TAP_REPOSITORY}"
    cd "${HOMEBREW_TAP_REPOSITORY}"
    git init
    git remote add origin "https://github.com/${GITHUB_REPOSITORY}"
fi
if test -z "${HOMEBREW_IN_CONTAINER-}"; then
    rm -rf "${GITHUB_WORKSPACE}"
    ln -s "${HOMEBREW_TAP_REPOSITORY}" "${GITHUB_WORKSPACE}"
fi
git fetch origin "${GITHUB_SHA}" '+refs/heads/*:refs/remotes/origin/*'
git remote set-head origin --auto
head="$(git symbolic-ref refs/remotes/origin/HEAD)"
head="${head#refs/remotes/origin/}"
git checkout --force -B "${head}" FETCH_HEAD
cd -

echo
echo "############################"
echo "### Install bunlder gems ###"
echo "############################"
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
