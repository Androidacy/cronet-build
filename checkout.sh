#!/bin/bash
# SPDX-FileCopyrightText: 2021, microG Project Team
# SPDX-License-Identifier: Apache-2.0

CHROMIUM_TAG=108.0.5359.125
CHROMIUM_REVISION=5b477e094962242f87536cc5089044bd37c0f052

ROOT=$PWD

if ! [ -d "$ROOT/depot_tools" ]; then
  echo "## Preparing depot_tools..."
  git clone "https://chromium.googlesource.com/chromium/tools/depot_tools.git"
fi

PATH=$ROOT/depot_tools:$PATH

if ! [ -d "$ROOT/chromium" ]; then
  echo "## Initializing chromium..."
  mkdir "$ROOT/chromium"
  cd "$ROOT/chromium"

  gclient config "https://chromium.googlesource.com/chromium/src.git"
  echo 'target_os = ["android"]' >> .gclient

  git init -q src
  cd src
  git remote add -t $CHROMIUM_TAG origin "https://chromium.googlesource.com/chromium/src.git"
fi

cd "$ROOT/chromium/src"

echo "## Fetching chromium..."
# We need to make sure we have the commit with latest Change-Id
git fetch -q --depth=20 origin "$CHROMIUM_REVISION"
git checkout --detach "$CHROMIUM_REVISION"
git checkout "$CHROMIUM_REVISION"

echo "## Running gclient sync..."
gclient sync -D --no-history --nohooks --revision=$CHROMIUM_REVISION
