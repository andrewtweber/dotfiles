#!/bin/bash

reset="\033[0m";
blue="\033[38;5;20m";
cyan="\033[38;5;38m";
green="\033[38;5;35m";
yellow="\033[38;5;227m";
violet="\033[38;5;99m";
white="\033[38;5;250m";
red="\033[38;5;197m";
black="\033[38;1;90m";

shopt -s nullglob

base=`pwd`

# refresh remote refs in parallel so the up-to-date check is accurate
for dir in "$base"/*/
do
    if [ -d "$dir/.git" ]; then
        git -C "$dir" fetch --quiet >/dev/null 2>&1 &
    fi
done
wait

printf "\n"

for dir in "$base"/*/
do
    cd "$dir"
    dir=`basename "$dir"`
    branchcolor="${black}"

    if [ -d .git ]; then
        branch=`git rev-parse --abbrev-ref HEAD`
        if [[ "$branch" != "master" && "$branch" != "main" ]]; then
            branchcolor="${yellow}"
        fi

        if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
            behind=`git rev-list --count HEAD..@{u} 2>/dev/null`
            if [[ "$behind" -gt 0 ]]; then
                remotecolor="${yellow}"
                remotestatus="out of date"
            else
                remotecolor="${green}"
                remotestatus="up to date"
            fi
        else
            remotecolor="${black}"
            remotestatus="no upstream"
        fi

        if [[ `git status --porcelain` ]]; then
            statuscolor="${red}"
            status="dirty"
        else
            statuscolor="${green}"
            status="clean"
        fi

        printf "  ${statuscolor}%-20s  ${reset}${branchcolor}%-14s${reset} ${statuscolor}%-7s${reset}        ${remotecolor}%s${reset}\n" "$dir" "[$branch]" "$status" "$remotestatus"
    fi
done

printf "\n"

exit;
