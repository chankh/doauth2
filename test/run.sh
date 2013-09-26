#!/bin/bash

set -e

#####
# Unit Tests

dart ./*_test.dart
EXITCODE=$?

if [ $EXITCODE -ne 0 ]; then
    exit $EXITCODE
fi

