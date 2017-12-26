#!/bin/bash

# fail immediately if any build step fails
set -e

if [ "$BUILD_TYPE" = "audit" ]; then
  echo "build type audit (rubocop)"
  bundle exec rubocop -V
  bundle exec rubocop --config .rubocop.yml
else
  echo "build type: default"
  bundle exec rake
fi
