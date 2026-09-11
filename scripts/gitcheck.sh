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

spinpid=""
spinfile=""

spinner() {
    local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    local i=0
    local label=""
    while :; do
        read -r label 2>/dev/null < "$spinfile"
        printf "\r\033[K  ${cyan}%s${reset} ${white}%s${reset}" "${frames[i++ % ${#frames[@]}]}" "$label"
        sleep 0.08
    done
}

startspinner() {
    [ -t 1 ] || return
    spinfile=`mktemp "${TMPDIR:-/tmp}/gitcheck.XXXXXX"` || return
    printf "%s\n" "$1" > "$spinfile"
    printf "\033[?25l"
    spinner &
    spinpid=$!
}

setspinner() {
    [[ -n "$spinfile" ]] || return
    printf "%s\n" "$1" > "$spinfile"
}

stopspinner() {
    [[ -n "$spinpid" ]] || return
    kill "$spinpid" 2>/dev/null
    wait "$spinpid" 2>/dev/null
    spinpid=""
    rm -f "$spinfile"
    spinfile=""
    printf "\r\033[K\033[?25h"
}

trap 'stopspinner; exit 130' INT TERM

startspinner "fetching remotes..."

# refresh remote refs in parallel so the up-to-date check is accurate
fetchpids=()
for dir in "$base"/*/
do
    if [ -d "$dir/.git" ]; then
        git -C "$dir" fetch --quiet >/dev/null 2>&1 &
        fetchpids+=($!)
    fi
done
[[ ${#fetchpids[@]} -gt 0 ]] && wait "${fetchpids[@]}"

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
        setspinner "checking $dir..."

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

stopspinner

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
