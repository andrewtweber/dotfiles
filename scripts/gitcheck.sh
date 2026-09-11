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

names=()
branches=()
branchcolors=()
statuses=()
statuscolors=()
remotestatuses=()
remotecolors=()

namewidth=0
branchwidth=0
statuswidth=0

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

        branch="[$branch]"

        names+=("$dir")
        branches+=("$branch")
        branchcolors+=("$branchcolor")
        statuses+=("$status")
        statuscolors+=("$statuscolor")
        remotestatuses+=("$remotestatus")
        remotecolors+=("$remotecolor")

        [[ ${#dir} -gt $namewidth ]] && namewidth=${#dir}
        [[ ${#branch} -gt $branchwidth ]] && branchwidth=${#branch}
        [[ ${#status} -gt $statuswidth ]] && statuswidth=${#status}
    fi
done

nameheader="Repo"
branchheader="Branch"
statusheader="Status"
remoteheader="Remote"

[[ ${#nameheader} -gt $namewidth ]] && namewidth=${#nameheader}
[[ ${#branchheader} -gt $branchwidth ]] && branchwidth=${#branchheader}
[[ ${#statusheader} -gt $statuswidth ]] && statuswidth=${#statusheader}

printf "\n"

printf "  ${white}%-*s${reset}    ${white}%-*s${reset}    ${white}%-*s${reset}    ${white}%s${reset}\n" \
    "$namewidth" "$nameheader" \
    "$branchwidth" "$branchheader" \
    "$statuswidth" "$statusheader" \
    "$remoteheader"

printf "  ${black}%-*s${reset}    ${black}%-*s${reset}    ${black}%-*s${reset}    ${black}%s${reset}\n" \
    "$namewidth" "$(printf '%*s' "$namewidth" '' | tr ' ' '-')" \
    "$branchwidth" "$(printf '%*s' "$branchwidth" '' | tr ' ' '-')" \
    "$statuswidth" "$(printf '%*s' "$statuswidth" '' | tr ' ' '-')" \
    "$(printf '%*s' "${#remoteheader}" '' | tr ' ' '-')"

for i in "${!names[@]}"
do
    printf "  ${statuscolors[$i]}%-*s${reset}    ${branchcolors[$i]}%-*s${reset}    ${statuscolors[$i]}%-*s${reset}    ${remotecolors[$i]}%s${reset}\n" \
        "$namewidth" "${names[$i]}" \
        "$branchwidth" "${branches[$i]}" \
        "$statuswidth" "${statuses[$i]}" \
        "${remotestatuses[$i]}"
done

printf "\n"

exit;
