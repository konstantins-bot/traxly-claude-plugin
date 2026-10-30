#!/bin/sh
# Traxly status line for Claude Code: the office line Traxly Office keeps in ~/.traxly/statusline.txt («● Traxly · в
# офисе 2 · агенты: 3 работают, 1 ждёт») and your plan's usage limits from the JSON Claude Code passes on stdin
# («лимит 5 ч 42% (сброс 18:30) · неделя 67%»; amber from 80%, red from 95%). The four limit numbers and the time are
# kept in ~/.traxly/ai-limits so the office can show them on your desk; that file stays on this computer, nothing is
# sent anywhere. POSIX sh + awk only (macOS, Linux, Git Bash on Windows).
d="$HOME/.traxly"
input=$(cat 2>/dev/null)
lang=$(cat "$d/statusline.lang" 2>/dev/null)
now=$(date +%s)
# rate_limits → "five_pct five_reset week_pct week_reset" ("-" where absent): the first "rate_limits" KEY (followed by
# a colon; a string with these words inside is escaped and never matches), its object to the closing brace, then each
# window's object and its two numbers. Newlines and spaces anywhere are fine.
nums=$(printf '%s' "$input" | tr '\r\n\t' '   ' | awk '
function num(obj,key,  s){
  if(!match(obj,"\"" key "\"[ ]*:[ ]*-?[0-9][0-9.eE+-]*"))return "-"
  s=substr(obj,RSTART,RLENGTH);sub(/^[^:]*:[ ]*/,"",s);return s
}
function win(rl,name,  o){
  if(!match(rl,"\"" name "\"[ ]*:[ ]*[{][^}]*[}]"))return "- -"
  o=substr(rl,RSTART,RLENGTH);return num(o,"used_percentage") " " num(o,"resets_at")
}
{all=all $0}
END{
  if(!match(all,/"rate_limits"[ ]*:[ ]*[{]/)){print "- - - -";exit}
  rest=substr(all,RSTART+RLENGTH);depth=1;rl=""
  for(i=1;i<=length(rest)&&depth>0;i++){c=substr(rest,i,1);if(c=="{")depth++;else if(c=="}")depth--;if(depth>0)rl=rl c}
  print win(rl,"five_hour") " " win(rl,"seven_day")
}')
set -- $nums
fp=${1:--};fr=${2:--};wp=${3:--};wr=${4:--}
if [ "$fp" != "-" ] || [ "$wp" != "-" ]; then
  mkdir -p "$d" 2>/dev/null
  printf 'five_hour=%s\nfive_hour_resets_at=%s\nseven_day=%s\nseven_day_resets_at=%s\nat=%s\n' "$fp" "$fr" "$wp" "$wr" "$now" > "$d/ai-limits.tmp" 2>/dev/null && mv -f "$d/ai-limits.tmp" "$d/ai-limits" 2>/dev/null
elif [ -f "$d/ai-limits" ]; then
  # A new session before its first answer: the last numbers seen, while fresh (6 h) and their window not over.
  saved=$(awk -F= -v now="$now" '{v[$1]=$2} END{
    if(v["at"]=="" || now-v["at"]>21600){print "- - - -";exit}
    f=v["five_hour"];fr=v["five_hour_resets_at"];w=v["seven_day"];wr=v["seven_day_resets_at"]
    if(f==""||(fr!="-"&&fr!=""&&fr+0<now)){f="-";fr="-"}
    if(w==""||(wr!="-"&&wr!=""&&wr+0<now)){w="-";wr="-"}
    print f " " (fr==""?"-":fr) " " w " " (wr==""?"-":wr)}' "$d/ai-limits" 2>/dev/null)
  set -- $saved
  fp=${1:--};fr=${2:--};wp=${3:--};wr=${4:--}
fi
pct() { awk -v p="$1" 'BEGIN{printf "%d", p+0.5}'; }
clock() { date -r "$1" +%H:%M 2>/dev/null || date -d "@$1" +%H:%M 2>/dev/null; }
day() { date -r "$1" +%d.%m 2>/dev/null || date -d "@$1" +%d.%m 2>/dev/null; }
paint() {
  if [ "$1" -ge 95 ]; then printf '\033[31m%s\033[0m' "$2"
  elif [ "$1" -ge 80 ]; then printf '\033[38;5;214m%s\033[0m' "$2"
  else printf '%s' "$2"; fi
}
if [ "$lang" = "ru" ]; then L5="лимит 5 ч"; LW="неделя"; LR="сброс"; else L5="5h limit"; LW="week"; LR="resets"; fi
office=$(head -n 1 "$d/statusline.txt" 2>/dev/null)
five="";five_short="";week="";week_short=""
if [ "$fp" != "-" ]; then
  p=$(pct "$fp");t=""
  [ "$fr" != "-" ] && t=$(clock "$fr")
  five_short=$(paint "$p" "$L5 $p%")
  if [ -n "$t" ]; then five=$(paint "$p" "$L5 $p% ($LR $t)"); else five=$five_short; fi
fi
if [ "$wp" != "-" ]; then
  p=$(pct "$wp");t=""
  [ "$p" -ge 80 ] && [ "$wr" != "-" ] && t=$(day "$wr")
  week_short=$(paint "$p" "$LW $p%")
  if [ -n "$t" ]; then week=$(paint "$p" "$LW $p% ($LR $t)"); else week=$week_short; fi
fi
join() {
  out=""
  for part in "$@"; do [ -n "$part" ] && { [ -n "$out" ] && out="$out · $part" || out="$part"; }; done
  printf '%s' "$out"
}
line=$(join "$office" "$five" "$week")
# Narrow terminal (COLUMNS when set): reset times go first, then the week, then the office line's parts from its end.
if [ -n "$COLUMNS" ] && [ "$COLUMNS" -gt 0 ] 2>/dev/null; then
  # characters, not bytes: colour codes out, UTF-8 continuation bytes not counted
  width() { printf '%s' "$1" | awk '{gsub(/\033\[[0-9;]*m/,"");printf "%s",$0}' | LC_ALL=C tr -d '\200-\277' | wc -c | tr -d ' '; }
  if [ "$(width "$line")" -gt "$COLUMNS" ]; then
    line=$(join "$office" "$five_short" "$week_short")
    one=${five_short:-$week_short}
    [ "$(width "$line")" -gt "$COLUMNS" ] && line=$(join "$office" "$one")
    while [ "$(width "$line")" -gt "$COLUMNS" ] && [ "${office% · *}" != "$office" ]; do
      office=${office% · *};line=$(join "$office" "$one")
    done
  fi
fi
[ -n "$line" ] && printf '%s\n' "$line"
exit 0
