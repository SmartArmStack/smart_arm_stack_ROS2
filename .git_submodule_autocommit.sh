#!/bin/bash
for d in */ ; do
    echo "Git commit in $d..."
    cd "$d"
    git commit -a -m "[Auto commit submodules]"
    cd ..
done
