#!/bin/bash
ps aux | grep -i node | awk '{print $2}' | xargs  kill -SIGINT
exit 0
