#!/bin/bash

set -e

#####
# Unit Tests

dart ./*_test.dart
EXITCODE=$?

if [ $EXITCODE -ne 0 ]; then
    exit $EXITCODE
fi

#####
# Type Analysis

echo
echo "dartanalyzer lib/*.dart"

results=`dartanalyzer lib/*.dart 2>&1`
EXITCODE=$?

echo "$results"

if [ $EXITCODE -ne 0 ]; then
    exit $EXITCODE
else
    echo "Passed analysis."
fi