#!/bin/sh
# Traxly for Claude Code: append one line — the time and the event (work, wait or done) — to ~/.traxly/ai-events.log.
# Traxly Office reads the last line to show the state on your desk robot. Nothing else is read, written or sent, and
# nothing is printed: the hook never answers a permission question.
case "$1" in work|wait|done) ;; *) exit 0 ;; esac
dir="$HOME/.traxly"
mkdir -p "$dir" 2>/dev/null || exit 0
printf '%s %s\n' "$(date +%s)" "$1" >> "$dir/ai-events.log" 2>/dev/null
exit 0
