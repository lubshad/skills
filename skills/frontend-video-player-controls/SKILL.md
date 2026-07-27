---
name: frontend-video-player-controls
description: Use when implementing playback controls, visibility timing, or interaction behavior for video players.
---

# Frontend Video Player Controls

## Core Rules

- Keep essential playback controls visible when playback is paused, blocked, ended, or unavailable.
- While the active video is playing, hide nonessential controls after a short period of inactivity. Three seconds is a suitable default for short-form video.
- Any direct player interaction, including tap, pointer movement, keyboard control, play, pause, seek, or volume changes, must reveal controls and restart the inactivity timer when playback continues.
- Do not hide controls for inactive slides based on their own media events. The player container owns visibility state for the active item.
- Cancel visibility timers when playback stops, the active video changes, or the player unmounts.
- Hidden controls must remain discoverable: a tap or keyboard interaction on the player should reveal them before invoking an unrelated action.

## Verification

- Start playback and confirm controls hide after the configured idle interval.
- Pause the video and confirm controls remain visible indefinitely.
- Resume playback and confirm the timeout begins again.
- Interact with seek or volume controls and confirm the timer resets.
- Change to another video and confirm a timer from the previous video cannot hide its controls.
- Leave the player and confirm no delayed state update occurs after unmount.
