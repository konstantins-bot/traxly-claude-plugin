# Traxly for Claude Code

A little robot on your desk in the [Traxly](https://traxly.pro) 3D office shows your team what your AI is doing:
it types while Claude works, waves when Claude waits for you, holds up a sheet when a turn is done, dozes when
nothing happens. You see «Claude ждёт вас / Claude is waiting for you» in the office, even with the terminal hidden.

## Install

The easiest way: Traxly Office → Settings → «Claude Code connected» (one click, no terminal).

From Claude Code:

```
/plugin marketplace add konstantins-bot/traxly-claude-plugin
/plugin install traxly@traxly
```

## What it sends

Nothing leaves your computer from this plugin. Each hook runs scripts/ai-event.sh, which appends one line — the time and `work`, `wait` or `done` —
to `~/.traxly/ai-events.log`. Traxly Office reads the last line and shows the state on your robot; only that state
(and your robot's colour) reaches your office. No prompt, answer, file name or path is ever written or sent.

## Status line

`scripts/statusline.sh` prints the office line and your plan's usage limits, which Claude Code passes to a status line
on Pro/Max plans:

```
● Traxly · в офисе 2 · агенты: 3 работают, 1 ждёт · лимит 5 ч 42% (сброс 18:30) · неделя 67%
```

Amber from 80%, red from 95%. Traxly Office sets it up when you connect Claude Code (it copies the script to
`~/.traxly/statusline.sh`, and only when you have no status line of your own). By hand, in `~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "sh \"$HOME/.traxly/statusline.sh\"", "refreshInterval": 15 }
```

The script needs only `sh` and `awk` (macOS, Linux, Git Bash on Windows). It keeps the last limit numbers (two
percentages, two reset times, the time seen) in `~/.traxly/ai-limits` so the office can show them on your desk; that
file never leaves your computer.

Remove the plugin (`/plugin uninstall traxly`) or switch it off in Traxly Office at any time.
