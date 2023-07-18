#!/usr/bin/env bash

docker buildx build -t race-$(basename $(pwd)):$(git rev-parse --abbrev-ref HEAD) .
