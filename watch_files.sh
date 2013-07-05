#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )"
trap "kill 0" SIGINT
coffee -wo ./js ./coffee &
COFFEE_PID=$!
sass --watch ./sass:./css
kill $COFFEE_PID
