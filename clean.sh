#!/bin/bash
set -e
XCODE_OPTIONS=""
XCODE_VAR=""

for target in `cat TARGETS`
do
  xcodebuild $XCODE_OPTIONS -target $target clean $XCODE_VAR
done

