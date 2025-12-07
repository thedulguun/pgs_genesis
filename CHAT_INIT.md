# CHAT_INIT.md — AI Bootloader for This Project

You are an AI assisting in this repository.

This file defines how you must **initialize yourself** for any new chat session once the Project OS already exists.

It is always invoked indirectly, via the root `chat.md` file.

---

## 1. Boot sequence (what you must do when this file is read)

When instructed to “Read `project-system/CHAT_INIT.md` and follow it”, you must:

1. Read the following files from `/ai-os/` in this order (if they exist):

   - `/ai-os/ai-rules.md`
   - `/ai-os/ai-context.md`
   - `/ai-os/ai-workflows.md`
   - `/ai-os/ai-roadmap.md`
   - `/ai-os/OS_SUMMARY.md`
   - `/ai-os/PROJECT_SUMMARY.md`

2. Treat `/ai-os/ai-rules.md` as the **highest authority** for your behavior in this repository.

3. Use `OS_SUMMARY.md` and `PROJECT_SUMMARY.md` as your **fast mental model** of:
   - what this project is
   - how the OS is structured
   - what constraints and goals matter most

4. Follow any additional instructions in those files strictly.

If any of these files are missing or unreadable, you must behave according to the **system integrity rules** defined in `ai-rules.md` (warning the user, not silently repairing).

---

## 2. Runtime command: `chat resync`

During an ongoing chat, the user may type:

```text
chat resync
```

When this happens, you must:

1. Re‑read the OS files listed above from `/ai-os/`.
2. Re‑align your behavior with the current OS state.
3. Respond with a **short message** that:
   - confirms you have re‑synced with the OS
   - briefly notes any important changes (if relevant)
   - continues the current task unless the user asks to reset

You must **not**:

- silently ignore `chat resync`
- treat it as a command to reset the conversation
- change tasks unless explicitly requested

`chat resync` means: *“reload the OS, keep the mission.”*

---

## 3. Required response immediately after boot

Right after you process this `CHAT_INIT.md` and load the OS for a **new chat session**, your next message to the user must be:

- short (roughly 2–4 sentences)
- structured as follows:
  1. Confirm that you have loaded the Project OS.
  2. Give a **single‑sentence summary** of this project (based on `PROJECT_SUMMARY.md`).
  3. Confirm that you will follow the OS rules and workflows.
  4. End with a question such as: *“What do you want to work on?”*

You must **not**:

- dump file contents
- propose work before the user asks
- ignore or override the OS

---

## 4. If something is wrong

If, during or after boot, you detect:

- that `/ai-os/` is missing or incomplete
- that critical OS files are missing
- that your behavior would rely on guesswork

You must:

1. Warn the user clearly.
2. Explain what appears to be missing or broken.
3. Suggest that they restore files from version control, or explicitly ask for regeneration.
4. Avoid making strong commitments based on incomplete OS state.

Follow the detailed safety rules defined in `ai-rules.md`.

---

From this point onwards in a chat, you are fully initialized and must act according to the Project OS.
