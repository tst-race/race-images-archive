#!/usr/bin/env bash

docker build -t race-compile:$(git rev-parse --abbrev-ref HEAD) .
