---
name: screen-recording
description: Use when the user requests a screen recording or video walkthrough of an Android/iOS app or web app.
---

# Screen Recording

Record the requested app journey and save the video in `recordings/` at the root of the current working directory.
This skill covers requested recordings, not screenshots, performance traces, video-player implementation, or routine UI checks without a recording request.

## Workflow

1. **Target.** Identify the app and requested journey. Resolve the current working directory once; use `<current-directory>/recordings/` even if later commands run elsewhere. Read `project-connections.md` when locating a connected app, URL, or device environment.
2. **Tool readiness.** Select the branch below by the running target, not its source framework. Continue only when the required tool is available, connected, and supports video capture.
3. **Capture.** Create the output directory if needed. Use a unique descriptive filename with a timestamp and the actual video extension. Start recording before the requested interactions; stop and finalize afterward, including on failure where possible. Record only the requested scope and keep credentials and unrelated private content out of the capture.
4. **Save.** Transfer or decode the completed video into the output directory when the tool returns remote bytes, base64, or a tool-local artifact. Preserve existing recordings. The destination is project-relative `recordings/`, not the filesystem directory `/recordings/`.
5. **Verify and deliver.** Confirm the saved file exists, is nonempty, and has a readable video stream with positive duration using an available media probe or playback. Select the delivery format below. Return the artifact paths and state whether the requested journey completed. If verification is unavailable or fails, report that limit instead of claiming success.

## Report delivery

- **Short delivery:** for a single recording with a brief outcome, return the video link and outcome in the response; a report file is optional.
- **Large report:** when delivery covers multiple journeys or needs detailed steps, findings, or evidence sections, write a uniquely named HTML report in the resolved `recordings/` directory instead of a Markdown report. Honor an explicit user request for another format.
- Organize the HTML with an outcome summary, section links, and one section per journey or finding. Include the observed result, relevant steps, capture limits, and the matching video; distinguish completed, failed, and unverified work.
- Use native `<video controls preload="metadata">` players with relative media paths and direct video links. Keep videos as adjacent files rather than base64 inside the HTML. Use browser-playable MP4/WebM when available; for unsupported formats, state the playback limit and provide a download link instead of claiming inline playback works.
- Keep report styling inline and independent of remote assets. Escape inserted text and attribute values. Use readable, responsive sections and descriptive headings; native controls must remain keyboard-accessible. Share the HTML together with its referenced videos so relative links continue to work.
- Before delivery, confirm each media link resolves to the intended saved file. Check the HTML in an available browser for layout and playback, and state any check that could not be run. Return the HTML report link as the main deliverable and keep the final message brief.

## Android and iOS apps

- Use Appium for device interactions and screen recording on real devices, emulators, or simulators. Read the available `appium-skill` companion before using Appium.
- Confirm the Appium server, platform driver, target device, and app session are ready. Check the installed driver's recording API and prerequisites before starting capture.
- Use the driver's supported start/stop recording operations and export the resulting video. If unsupported or disconnected, report the missing capability or setup and ask for the needed user action.

## Web apps

- Use the browser-extension MCP (`browse`) for web apps, including mobile-sized pages, PWAs, and Flutter Web. Its server instructions own browser interaction; the `browser` companion covers the separate in-app browser and is not required for this branch.
- Discover `browse.status`, `browse.navigate`, `browse.snapshot`, `browse.recording`, and file-transfer tools before use. Check the connection with `status`; if disconnected, relay its `nextStep` to the user and wait. If the MCP or recording tool is unavailable, ask the user to enable it before continuing.
- Open the target with `navigate` and retain the returned `tab` for every capture and interaction call. Use an existing user tab only when lent or explicitly requested. Follow inspect–act–verify with fresh snapshots around interactions.
- Start `recording` with `action: "start"`, the target `tab`, and a unique output `path` before the journey. Prefer `.mp4` or `.webm` for browser playback; both require ffmpeg on the MCP host. Use `.mkv` when transcoding is unavailable; it supports video playback in VLC/mpv but not browsers. Set `maxDurationMs` to bound capture.
- Stop with `recording` using `action: "stop"` and the same `tab`, including after a failed journey where possible. Inspect the returned `path`, `bytes`, `durationMs`, `frameCount`, and any `endedBecause` value for empty or truncated capture. A screenshot, trace, or `demonstrate` action log does not satisfy a video request.
- Save directly to the resolved output directory only when it is inside the MCP's allowed file roots and on the same filesystem. Otherwise record in an allowed private folder, then transfer the completed file to the local output directory using supported file operations. A tool-host path alone is not evidence of a local save; report blocked transfer or verification explicitly.
- Finalize and save the recording before closing tabs opened for this task. Leave lent user tabs open.

## Verification

- Required platform tool was available and connected before capture.
- Capture was stopped and finalized; the saved video is under the resolved `recordings/` directory without overwriting existing files.
- Video readability and positive duration were checked, or the verification limit was stated.
- Delivery format follows Report delivery; HTML media links resolve, and layout/playback checks or their limits are reported when an HTML report is produced.
- Final response gives the saved path and any incomplete journey or capture failure. A documentation-only change to this skill does not require a live recording.
