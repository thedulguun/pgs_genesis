# CHAT_INIT.md - AI Bootloader for This Project (Light Profile)

You are an AI assisting in this repository.

This file defines how you must **initialize yourself** for any new chat session once the light Project OS already exists.

It is always invoked indirectly, via the root `chat.md` file.

---

## 1. Boot sequence (what you must do when this file is read)

When instructed to "Read `project-system/CHAT_INIT.md` and follow it", you must:

1. Read the following files from `/ai-os/` in this order (if they exist):

   - `/ai-os/ai-project-guide.md`
   - `/ai-os/PROJECT_SUMMARY.md`

2. Treat `/ai-os/ai-project-guide.md` as the **highest authority** for your behavior in this repository.

3. Use `PROJECT_SUMMARY.md` as your **fast mental model** of:
   - what this project is,
   - what we are focusing on right now,
   - what constraints and goals matter most.

4. Follow any additional instructions in `ai-project-guide.md` strictly.

If any of these files are missing or unreadable, you must behave according to the **system integrity rules** encoded in `ai-project-guide.md` (warning the user, not silently repairing).

---

## 2. Runtime command: `chat resync`

During an ongoing chat, the user may type:

```text
chat resync
```

When this happens, you must:

1. Re-read `/ai-os/ai-project-guide.md` and `/ai-os/PROJECT_SUMMARY.md`.
2. Re-align your behavior with the current OS state.
3. Respond with a **short message** that:
   - confirms you have re-synced with the OS,
   - briefly notes any important changes (if relevant),
   - continues the current task unless the user asks to reset.

You must **not**:

- silently ignore `chat resync`,
- treat it as a command to reset the conversation,
- change tasks unless explicitly requested.

`chat resync` means: *"reload the OS, keep the mission."*

---

## 3. Optional command: `update summaries`

During an ongoing chat, the user may also say something like:

```text
update summaries
```

When this happens, you must:

1. Re-read `/ai-os/ai-project-guide.md`.
2. Bring `/ai-os/PROJECT_SUMMARY.md` back in line with the current OS, preferring small, focused edits when possible but updating more aggressively if the summary is very stale or inconsistent.
3. Briefly confirm that the summary has been refreshed.

You must not ignore this request, and you must not treat it as permission to change the underlying OS rules or context without explicit discussion. It is a request to update the human-facing summary, not to rewrite the OS.

---

## 4. Required response immediately after boot

Right after you process this `CHAT_INIT.md` and load the OS for a **new chat session**, your next message to the user must be:

- short (roughly 2-4 sentences),
- structured as follows:
  1. Confirm that you have loaded the light Project OS.
  2. Give a **single-sentence summary** of this project (based on `PROJECT_SUMMARY.md`).
  3. Confirm that you will follow the guide’s rules and workflows.
  4. End with a question such as: *"What do you want to work on?"*

You must **not**:

- dump file contents,
- propose work before the user asks,
- ignore or override the OS.

---

## 5. If something is wrong

If, during or after boot, you detect:

- that `/ai-os/` is missing or incomplete,
- that `ai-project-guide.md` or `PROJECT_SUMMARY.md` is missing or clearly corrupted,
- that your behavior would rely on guesswork,

You must:

1. Warn the user clearly.
2. Explain what appears to be missing or broken.
3. Suggest that they restore files from version control, or explicitly ask for regeneration.
4. Avoid making strong commitments based on incomplete OS state.

Follow the detailed safety rules encoded in `ai-project-guide.md`.

---

From this point onwards in a chat, you are fully initialized in light mode and must act according to the Project OS.***
