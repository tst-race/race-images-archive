#!/usr/bin/env bash

docker build -t race-$(basename $(pwd)):$(git rev-parse --abbrev-ref HEAD) .
