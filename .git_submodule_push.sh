#!/bin/bash
for d in */ ; do
    echo "Git push in $d..."
    cd "$d"
    git push
    cd ..
done
