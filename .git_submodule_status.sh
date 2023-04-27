#!/bin/bash
for d in */ ; do
    echo "Git status in $d..."
    cd "$d"
    git status
    cd ..
done

