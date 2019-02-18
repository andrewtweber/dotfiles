#!/bin/bash

shopt -s nullglob
for dir in /var/www/*/
do
    cd $dir
    if [ -d .git ]; then
        if [[ `git status --porcelain` ]]; then
            echo $dir is dirty
        fi
    fi
done

exit;
