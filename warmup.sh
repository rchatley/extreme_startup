#!/bin/sh

docker run -d -p 80:3000 -e WARMUP=1 extreme_startup
