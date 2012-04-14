#!/bin/sh
set -e
XCODE_OPTIONS=""
XCODE_VAR=""

xcodebuild $XCODE_OPTIONS -alltargets clean $XCODE_VAR

