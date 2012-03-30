#!/bin/bash
set -e
XCODE_OPTIONS=""
XCODE_VAR="DSTROOT=/"

for target in `cat TARGETS`
do
  xcodebuild $XCODE_OPTIONS -target $target install $XCODE_VAR
done
