---
name: frontend-video-player-controls
description: Use when implementing video playback controls, idle visibility, or player interaction behavior.
---

# Video Controls

**Active player owns visibility.** Keep essential controls visible while paused, blocked, ended, or unavailable. During playback hide nonessential controls after brief idle (three seconds suits short-form video).

Tap/pointer/keyboard/play/pause/seek/volume reveals controls and restarts idle timing if playback continues. A revealing interaction must not invoke an unrelated action. Ignore inactive-slide media events for visibility; cancel timers on stop, item change, and unmount.

## Verification

Check idle hide, indefinite paused visibility, resume timer, seek/volume reset, old-item timer isolation, and no delayed updates after unmount.
