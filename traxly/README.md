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

Remove the plugin (`/plugin uninstall traxly`) or switch it off in Traxly Office at any time.
