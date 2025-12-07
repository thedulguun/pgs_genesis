# DEV_GUIDE.md - How to work in this repository (Light Profile)

This repository uses the **Project Generation System - Genesis (light)**.

The goal is to make AI-assisted work:

- predictable,
- safe,
- easy to onboard into,
- lightweight enough for small or one-off projects.

If you understand this file, you understand how to work here in light mode.

---

## Core idea (1-minute version)

We do **not** rely on chat memory or clever prompting.

Instead, this project has:

- a simple **AI Project Guide** in `/ai-os/ai-project-guide.md`,
- a short **Project Summary** in `/ai-os/PROJECT_SUMMARY.md`,
- a single root entrypoint `chat.md` for new AI chats,
- a small **project system** in `project-system/`.

The flow is:

```text
read chat.md
   ↓
project-system/CHAT_INIT.md
   ↓
/ai-os/ai-project-guide.md + PROJECT_SUMMARY.md
```

You rarely need to touch `/ai-os/` directly. You talk to the AI; it keeps the OS files in sync.

---

## Important paths & files

### `/ai-os/` - AI Project OS (light)

This folder contains:

- `ai-project-guide.md` - detailed AI-facing guide:
  - how the AI should behave,
  - what this project is,
  - high-level scope and constraints,
  - typical workflows,
  - how the OS may evolve.
- `PROJECT_SUMMARY.md` - short project overview for humans:
  - one-paragraph description,
  - current focus,
  - important constraints/non-goals,
  - how to start a new task.

`ai-project-guide.md` is the **source of truth** for AI behavior and project definition.
`PROJECT_SUMMARY.md` is a **derived summary** for quick orientation and may lag behind the guide.

### `project-system/DEV_GUIDE.md` (this file)

You are reading it.

It explains:

- how to start new AI chats,
- how to re-sync AI mid-chat,
- how the light Project OS is structured at a high level,
- what to do when something breaks.

This file is meant to be:

- human-oriented,
- relatively stable,
- short enough to skim quickly.

### `project-system/CHAT_INIT.md` (AI bootloader, light)

You usually do **not** need to read or edit this file.

It tells the AI, when invoked:

1. to read `/ai-os/ai-project-guide.md` and `/ai-os/PROJECT_SUMMARY.md`,
2. to treat `ai-project-guide.md` as the highest authority,
3. how to behave after boot,
4. how to handle `chat resync` and `update summaries`.

It is loaded **indirectly** through `chat.md` at repo root.

### `chat.md` (root entry point)

Located at project root.

It contains a single instruction pointing to the bootloader, for example:

```md
Read project-system/CHAT_INIT.md and follow it.
```

Every new AI chat should start with:

```text
read chat.md
```

This is the only thing a new developer really needs to remember.

---

## Commands you need to know

- `read chat.md` — initialise a new AI chat with the Project OS loaded.
- `chat resync` — reload the OS files in `/ai-os/` during an ongoing chat while keeping the current task.
- `update summaries` — when `PROJECT_SUMMARY.md` feels stale or the OS has changed, ask the AI to refresh it from the current `ai-project-guide.md`.

If you are joining an existing project mid-stream:

- attach the repository in your AI tool,
- run `read chat.md`,
- then skim `/ai-os/PROJECT_SUMMARY.md`,
- and, if needed, ask the AI for a short recap based on the guide.

This is usually enough to get oriented.

---

## Starting a new AI chat (correctly)

Whenever you open a **new AI chat session** for this repository:

1. Make sure the repository (or folder) is attached / visible to the AI tool.
2. In the very first message, run:
   ```text
   read chat.md
   ```
3. Wait for the AI to respond.

A correct response should:

- confirm that it has loaded the light Project OS,
- summarize the project in **one sentence** (from `PROJECT_SUMMARY.md`),
- state that it will follow the guide’s rules and workflows,
- end with a question like: *"What do you want to work on?"*

If you see that pattern, the AI is properly initialized.

---

## Re-syncing an ongoing chat

Sometimes the AI may:

- feel "off" or confused,
- seem outdated after OS changes,
- behave in a way that doesn't match `ai-project-guide.md`.

Or OS files may have been edited while a chat is ongoing.

In this case, type:

```text
chat resync
```

The AI is required to:

1. Re-read `/ai-os/ai-project-guide.md` and `/ai-os/PROJECT_SUMMARY.md`.
2. Re-align its behavior with the current OS.
3. Respond briefly:
   - confirming resync,
   - noting any important changes that affect the current work,
   - continuing the **same task** unless you ask to reset.

It must **not** silently reset the conversation or change tasks on `chat resync`.

---

## When the project or rules change

If any of the following change:

- project scope,
- core workflows,
- important rules in the guide,
- major assumptions or constraints,

Then, the recommended flow is:

1. Tell the AI, in an ongoing chat, what has changed.
2. Ask it to propose an update to `/ai-os/ai-project-guide.md` that reflects the new reality.
3. Review the proposed changes (in summary form, or in the file if you prefer).
4. Approve or adjust them.

After the guide is updated, you can say:

```text
update summaries
```

to have the AI refresh `/ai-os/PROJECT_SUMMARY.md` from the current guide.

If the summary and the guide ever disagree, assume the guide (`ai-project-guide.md`) is authoritative and the summary is stale. You can always ask the AI to refresh it.

---

## System file safety (what to do when things break)

The following are considered **system files**:

- `chat.md`
- `project-system/DEV_GUIDE.md`
- `project-system/CHAT_INIT.md`
- everything in `/ai-os/`

If any of these are deleted or corrupted:

- The AI is required (by the light OS rules) to **warn you explicitly**.
- The AI must **not** silently recreate or modify system files.
- Recovery is a **developer responsibility**.

Some common cases:

### 1. `chat.md` was deleted

If you run `read chat.md` in a new chat and it fails:

- Recreate `chat.md` at repo root with this canonical content:

  ```md
  Read project-system/CHAT_INIT.md and follow it.
  ```

- Or restore it from version control (git).

Then start a new chat and run `read chat.md` again.

### 2. `project-system/CHAT_INIT.md` is missing

If `chat.md` exists but the AI reports that it cannot read `project-system/CHAT_INIT.md`:

- Restore `project-system/CHAT_INIT.md` from version control.
- Or, if needed, recreate it based on the starter kit definition (a bootloader that loads `/ai-os/ai-project-guide.md` and `PROJECT_SUMMARY.md` and defines `chat resync` and `update summaries` behavior).

Until `CHAT_INIT.md` exists and is readable, the system cannot safely initialize.

### 3. `/ai-os/` or core OS files are missing

If `/ai-os/` or core OS files like `ai-project-guide.md` or `PROJECT_SUMMARY.md` are missing:

- The AI will warn you and treat the OS as degraded.
- You should either:
  - restore the files from version control, or
  - explicitly instruct the AI to help regenerate the missing pieces.

The AI must **not** silently guess or invent the previous OS.

### 4. OS files look corrupted or inconsistent

If the AI reports that OS files exist but appear corrupted, structurally invalid, or inconsistent with each other:

- treat the OS as being in a degraded state,
- review recent changes or diffs and restore known-good versions from version control where possible,
- or explicitly ask the AI to help regenerate specific files, with your approval.

The AI must not guess what the previous rules or context were based only on memory. It should warn and wait for your direction.

---

## Historical note: GENESIS.md

At the very beginning of this project, a file called `GENESIS.md` (light profile) was used to:

- ask questions about the project,
- design the light Project OS,
- generate `/ai-os/` (`ai-project-guide.md` and `PROJECT_SUMMARY.md`),
- move `DEV_GUIDE.md` and `CHAT_INIT.md` into `project-system/`,
- create `chat.md` at the root.

After that, `GENESIS.md` was deleted and should not return.

You do **not** need Genesis for day-to-day work.

---

## Mental model (keep this in your head)

- `/ai-os/ai-project-guide.md` → AI's detailed guide and memory  
- `/ai-os/PROJECT_SUMMARY.md` → quick human summary  
- `project-system/CHAT_INIT.md` → AI bootloader  
- `project-system/DEV_GUIDE.md` → human guide  
- `chat.md` → universal entrypoint for new chats  
- `chat resync` → "reload the guide, keep the task"  
- `update summaries` → "refresh the human summary from the guide"  

If you follow this, you won't get lost.

