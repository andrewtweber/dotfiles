# Claude Code profiles: work vs personal.
#
# Claude Code derives its macOS Keychain credential entry from CLAUDE_CONFIG_DIR, so giving
# each profile its own config dir keeps the two subscriptions fully separated -- separate
# logins, settings, skills, and session history.

CLAUDE_PROFILE_WORK_DIR="$HOME/.claude-work"
CLAUDE_PROFILE_HOME_DIR="$HOME/.claude-home"
CLAUDE_PROFILE_LAST="$HOME/.claude-last-profile"

# Populates _claude_c_* with ANSI escapes, or with empty strings when colour is
# unwanted (NO_COLOR set, or stderr is not a terminal).
_claude_colors() {
  if [[ -n $NO_COLOR || ! -t 2 ]]; then
    typeset -g _claude_c_reset= _claude_c_bold= _claude_c_dim=
    typeset -g _claude_c_head= _claude_c_work= _claude_c_home= _claude_c_err=
    return
  fi

  typeset -g _claude_c_reset=$'\e[0m' _claude_c_bold=$'\e[1m' _claude_c_dim=$'\e[2m'
  typeset -g _claude_c_head=$'\e[38;5;208m'   # amber
  typeset -g _claude_c_work=$'\e[38;5;75m'    # blue
  typeset -g _claude_c_home=$'\e[38;5;114m'   # green
  typeset -g _claude_c_err=$'\e[38;5;203m'    # red
}

_claude_launch() {
  local profile=$1 dir=$2
  shift 2
  print -r -- "$profile" >| "$CLAUDE_PROFILE_LAST"

  _claude_colors
  local colour=$_claude_c_home label=Personal
  [[ $profile == work ]] && colour=$_claude_c_work label=Work
  print -u2 -r -- ""
  print -u2 -r -- "  ${colour}${_claude_c_bold}▸${_claude_c_reset}  ${colour}${label}${_claude_c_reset}  ${_claude_c_dim}${dir/#$HOME/~}${_claude_c_reset}"
  print -u2 -r -- ""

  CLAUDE_CONFIG_DIR="$dir" command claude "$@"
}

claude-work() { _claude_launch work "$CLAUDE_PROFILE_WORK_DIR" "$@" }
claude-home() { _claude_launch home "$CLAUDE_PROFILE_HOME_DIR" "$@" }

claude() {
  # Already inside a session, or a profile explicitly pinned: pass straight through.
  if [[ -n $CLAUDE_CONFIG_DIR || -n $CLAUDECODE ]]; then
    command claude "$@"
    return
  fi

  local last=home
  [[ -r $CLAUDE_PROFILE_LAST ]] && last=$(<"$CLAUDE_PROFILE_LAST")
  [[ $last == work || $last == home ]] || last=home

  # No TTY (piped, scripted, cron): can't prompt, so reuse the last profile.
  if [[ ! -t 0 ]]; then
    claude-$last "$@"
    return
  fi

  _claude_colors
  local default_colour=$_claude_c_home default_label=Personal
  [[ $last == work ]] && default_colour=$_claude_c_work default_label=Work

  local choice
  print -u2 -r -- ""
  print -u2 -r -- "  ${_claude_c_bold}${_claude_c_head}Which Claude account?${_claude_c_reset}"
  print -u2 -r -- ""
  print -u2 -r -- "    ${_claude_c_bold}${_claude_c_work}1${_claude_c_reset}${_claude_c_dim})${_claude_c_reset}  ${_claude_c_work}●${_claude_c_reset}  ${_claude_c_work}Work${_claude_c_reset}        ${_claude_c_dim}~/.claude-work${_claude_c_reset}"
  print -u2 -r -- "    ${_claude_c_bold}${_claude_c_home}2${_claude_c_reset}${_claude_c_dim})${_claude_c_reset}  ${_claude_c_home}●${_claude_c_reset}  ${_claude_c_home}Personal${_claude_c_reset}    ${_claude_c_dim}~/.claude-home${_claude_c_reset}"
  print -u2 -r -- ""
  read -r "choice?  ${_claude_c_dim}Select [Enter = ${_claude_c_reset}${default_colour}${default_label}${_claude_c_reset}${_claude_c_dim}]:${_claude_c_reset} "

  case ${choice:l} in
    1|w|work)            claude-work "$@" ;;
    2|p|h|personal|home) claude-home "$@" ;;
    "")                  claude-$last "$@" ;;
    *) print -u2 -r -- "${_claude_c_err}Unknown choice:${_claude_c_reset} $choice"; return 1 ;;
  esac
}
