#!/bin/sh
set -e
XCODE_OPTIONS=""
XCODE_VAR="DSTROOT=/"

xcodebuild $XCODE_OPTIONS -alltargets install $XCODE_VAR
