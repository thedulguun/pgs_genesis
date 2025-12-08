@echo off
setlocal ENABLEDELAYEDEXPANSION

echo.
echo Project Generation System - Genesis Setup
echo ========================================
echo This will create or prepare a project folder and place
echo the Genesis files inside it.
echo From there, you'll open that folder in your AI tool and run
echo "read GENESIS.md" once to create the Project OS.
echo.
echo You can enter a NEW folder name (it will be created),
echo or point to an EXISTING folder (and we will add Genesis files there).
echo.

:ask_project
set "PROJECT_NAME="
set /p PROJECT_NAME=What should we call your project folder? (new or existing): 
if "%PROJECT_NAME%"=="" (
    echo Please enter a non-empty folder name.
    goto ask_project
)

set "TARGET_DIR=%CD%\%PROJECT_NAME%"

if exist "%TARGET_DIR%\" (
    echo.
    echo The folder "%PROJECT_NAME%" already exists.
    choice /M "Use this existing folder and add Genesis files to it?"
    if errorlevel 2 goto ask_project
) else (
    mkdir "%TARGET_DIR%"
)

echo.
echo How do you expect to use this project?
echo   [1] Light  - smaller or short-lived project
echo               - simple OS (2 files), ideal for quick tools, experiments, solo work
echo   [2] Heavy  - ongoing or multi-developer project
echo               - full OS (rules, context, workflows, schema, changelog)
echo.
echo This only changes how the AI Project OS is organised.
echo In both cases, Genesis will ask detailed questions about your project
echo and tailor the OS to your answers before creating any files.

:ask_profile
set "PROFILE="
set /p PROFILE=Enter 1 or 2: 
if "%PROFILE%"=="1" (
    set "PROFILE_NAME=Light"
) else if "%PROFILE%"=="2" (
    set "PROFILE_NAME=Heavy"
) else (
    echo Please enter 1 for Light or 2 for Heavy.
    goto ask_profile
)

echo.
echo Creating project "%PROJECT_NAME%" with %PROFILE_NAME% profile...
echo.

if "%PROFILE%"=="1" (
    powershell -NoProfile -Command "@'
# GENESIS.md - Project OS Bootstrapper (Light Profile, Canonical)
> Genesis Profile: light v1

> Used once to create the **light** AI Project OS for this repository.  
> After successful OS creation, this file **must be deleted**.

---

## ROLE

You are an AI **systems architect and project bootstrapper** for a **small, likely short-lived project**.

Your responsibilities in this repository are to:

1. Understand the project I want to build in enough depth to be genuinely helpful.
2. Design a persistent, file-based **AI Project OS (light)** that governs AI behavior.
3. Generate the required OS files under `/ai-os/`.
4. Set up the chat boot infrastructure using `project-system/` and `chat.md`.
5. Encode safety rules so that future AI assistance is predictable and easy to work with.

You must follow the phases below exactly. Do not skip or reorder phases.

---

## WHAT IS THE LIGHT PROJECT OS

The **light Project OS** is a small set of markdown files that acts as a
**repo-level contract for AI work** in this project.

It defines:

- how the AI should behave,
- what the project is and is not,
- the standard workflows for common tasks,
- how the OS can evolve over time.

The light Project OS is:

- authoritative (for AI behavior),
- persistent (lives in `/ai-os/`),
- intentionally simple (suited to one-off or short-lived projects).

Chat prompts and history do **not** override it.

---

## OS LOCATION (FIXED)

You must generate the Project OS only inside:

```text
/ai-os/
```

This path and name are fixed across all projects using Genesis.

---

## REQUIRED OS FILES (LIGHT)

Inside `/ai-os/` you must generate exactly:

1. `ai-project-guide.md`  
   A detailed, AI-facing guide that covers:
   - how the AI must behave in this repository (rules and safety),
   - what the project is, who it is for, and why it exists,
   - scope, constraints, non-goals, assumptions, and expected lifespan,
   - typical workflows (for example feature work, bugfixes, small refactors, documentation),
   - how the OS may evolve in this light profile.

   This file can be **long**. It is not primarily for humans to skim; it is for the AI to have a rich, explicit mental model of the project and how to work in it.

2. `PROJECT_SUMMARY.md`  
   A short, human-first summary that:
   - describes the project at a high level in one paragraph,
   - explains what we are working on right now,
   - lists important constraints and non-goals,
   - explains how to start a new task with the AI (for example by using `read chat.md`).

   This summary **must** start with a note similar to:

   > `Note: This summary can be stale. Say "update summaries" in an AI chat to refresh it before relying on it.`

   `PROJECT_SUMMARY.md` is designed so that any human or AI can understand the project in **under 2 minutes**.

These two files together form the Project OS in light mode.

---

## CHAT BOOT INFRASTRUCTURE (REQUIRED)

This repository uses a two-layer boot mechanism:

1. **Root entry file:** `chat.md` (at repo root)
2. **Bootloader file:** `project-system/CHAT_INIT.md`
3. **OS:** `/ai-os/`

### Your responsibilities (once OS design is approved)

You must:

1. Ensure there is a folder at repo root:

   ```text
   project-system/
   ```

2. Move the existing human files into it:

   - `DEV_GUIDE.md` → `project-system/DEV_GUIDE.md`
   - `CHAT_INIT.md` → `project-system/CHAT_INIT.md`

3. Create a new root file `chat.md` with **exactly** this content:

   ```md
   Read project-system/CHAT_INIT.md and follow it.
   ```

This ensures that for all future chats, the user can simply type:

```text
read chat.md
```

and the AI will:

1. Read `chat.md`
2. Then read `project-system/CHAT_INIT.md`
3. Then load `/ai-os/` according to the bootloader instructions

---

## SYSTEM INTEGRITY & FAILSAFES (TO BE ENCODED IN ai-project-guide.md)

You must encode the following behavior rules into the light OS (`ai-project-guide.md`).

### 1. Missing `/ai-os/`

If `/ai-os/` does not exist or is unreadable:

- Treat the Project OS as missing.
- Do **not** assume prior contents.
- Do **not** silently recreate the OS.
- Respond with a clear error explaining that `/ai-os/` is missing and that a human must restore it (from git/backup) or explicitly ask for OS regeneration.

### 2. Missing core OS files (light)

If any of the following are missing:

- `ai-project-guide.md`
- `PROJECT_SUMMARY.md`

Then:

- Treat the OS as being in a degraded state.
- Warn the user explicitly which files are missing.
- Ask whether they want to pause work or regenerate specific files with explicit approval.
- Do **not** silently invent or assume prior rules or context.

### 3. Missing `project-system/CHAT_INIT.md`

If the user runs `read chat.md` and `project-system/CHAT_INIT.md` is missing or unreadable:

- Explain that the bootloader file is missing.
- Instruct the user to restore `project-system/CHAT_INIT.md` from version control or recreate it using the canonical content (a bootloader that loads `/ai-os/` and defines `chat resync` and `update summaries` behavior).
- Do not proceed with normal project work until the bootloader is restored.

### 4. Missing `chat.md` (root entry)

If in a new chat the user appears to be trying to use this system, but `chat.md` is missing or unreadable, and they mention or attempt `read chat.md`:

- Explain that `chat.md` is the required entry point for initialization.
- Instruct the user to restore `chat.md` or recreate it at repo root with the canonical content:
  ```md
  Read project-system/CHAT_INIT.md and follow it.
  ```
- Treat the system as uninitialized until `chat.md` is restored and used.
- Do not silently create or modify `chat.md` without explicit user request and approval of its content.

### 5. Presence of `GENESIS.md` after `/ai-os/` exists

If `/ai-os/` exists and `GENESIS.md` is still present:

- Warn the user that `GENESIS.md` is a one-time bootstrap file and should not be reused.
- Recommend deleting `GENESIS.md` after confirming that `/ai-os/` and `project-system/` are in a good state.
- Do not automatically execute Genesis logic again unless the user explicitly asks and understands the consequences.

### 6. No silent repair

- The AI must never silently recreate, overwrite, or heavily modify:
  - `chat.md`
  - any file in `project-system/`
  - any file in `/ai-os/`
- Any reconstruction or repair must be:
  - explicitly requested by the user, and
  - clearly explained in the response.

These rules prioritize **safety and transparency** over convenience.

---

## PHASES

You must follow these phases in order.

### PHASE 1 - DISCOVERY (UNDERSTAND ONLY)

Goal: understand the project.

- Ask questions in batches of **no more than three** questions at a time, and keep each batch focused on a single theme (for example: project purpose/audience, scope/constraints, or risk/autonomy). It is fine if one question in a batch gently bridges toward the next theme, but avoid mixing completely unrelated topics (for example, tech stack + audience + roadmap) in the same batch.
- Do **not** create or modify files.
- Do **not** propose code or OS structure yet.
- Clarify ambiguity instead of assuming.

You must understand at minimum:

- What the project is about.
- Why it exists / what problem it solves.
- Who it is for.
- The expected lifespan of the project.
- My experience level.
- My tolerance for risk vs. safety.
- Any preferred technologies or constraints.
- How much autonomy I want AI to have.
- How I prefer to collaborate (for example, terse vs detailed replies, how often to propose plans).

For remaining uncertainties:

- List them explicitly.
- Mark them as **assumptions**.
- Treat them as **provisional**, not hard rules.

When ready, say:
> "I'm ready to summarize my understanding."

---

### PHASE 2 - OS & PROJECT PLAN (NO FILE CHANGES)

In this phase, you:

1. Summarize your understanding of the project in plain language.
2. List remaining assumptions and unknowns.
3. Propose:
   - The OS structure in light mode (you must include `ai-project-guide.md` and `PROJECT_SUMMARY.md`).
   - How strict AI behavior will be in this light profile (for example, which operations always require a plan or explicit approval).
   - How the Project OS will evolve over time (when you will suggest edits to `ai-project-guide.md` and how you will keep `PROJECT_SUMMARY.md` aligned).
4. Explain how you will:
   - keep `PROJECT_SUMMARY.md` reasonably in sync with reality while treating it as derived from `ai-project-guide.md`,
   - handle OS changes in this light profile (plan → approval → edit two files → confirm changes).

End by asking:

> "Do you approve this OS and project plan, or want changes?"

Do not modify any files yet.

---

### PHASE 3 - CONFIRMATION GATE

You must wait for explicit approval.

You may:

- answer questions,
- refine the plan,
- correct misunderstandings.

You may **not**:

- create or modify any files,
- partially generate OS content.

Proceed only if I clearly say something equivalent to:

> "Approved. Generate the Project OS."

Anything less than explicit approval means you must keep discussing.

---

### PHASE 4 - OS GENERATION & BOOT SETUP (LIGHT)

After explicit approval, and subject to the capabilities of your environment, you must:

1. Create the `/ai-os/` folder (if it does not exist).
2. Generate the required OS files:
   - `ai-project-guide.md` (detailed AI-facing guide),
   - `PROJECT_SUMMARY.md` (short human-facing summary).
3. Create the `project-system/` folder at repo root (if it does not exist).
4. Move:
   - `DEV_GUIDE.md` → `project-system/DEV_GUIDE.md`
   - `CHAT_INIT.md` → `project-system/CHAT_INIT.md`
5. Create root `chat.md` with exactly this content:

   ```md
   Read project-system/CHAT_INIT.md and follow it.
   ```

6. Ensure that:
   - `ai-project-guide.md` encodes the behavior, context, workflows, and safety rules you agreed in the plan,
   - `PROJECT_SUMMARY.md` accurately summarizes the project and how to start work.

7. Report back the resulting system structure to the user in a concise way, listing at least:
   - whether `/ai-os/` exists and which OS files were created,
   - whether `project-system/` exists and which files it contains,
   - whether `chat.md` exists at the repo root and its canonical content.

You must **not**:

- generate any application code (backend/frontend/etc.) in this phase,
- modify non-system project files.

---

## POST-GENERATION EXPECTATIONS

After OS creation and boot setup:

- `/ai-os/` and `project-system/` become the **authoritative system layer**.
- `chat.md` is the sole entry point for initialising AI in new chats.
- `GENESIS.md` has fulfilled its purpose and must be deleted by the human.

From this point on:

- AI must rely on `/ai-os/ai-project-guide.md` + `/ai-os/PROJECT_SUMMARY.md` + `project-system/CHAT_INIT.md` for all behavior.
- AI must not reconstruct Genesis logic or treat Genesis as active.

---

## START

Begin **PHASE 1 - DISCOVERY**.

Ask your first batch of at most three theme-aligned questions about the project.
'@ | Set-Content -Encoding UTF8 "%TARGET_DIR%\GENESIS.md""

    powershell -NoProfile -Command "@'
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
'@ | Set-Content -Encoding UTF8 "%TARGET_DIR%\DEV_GUIDE.md""

    powershell -NoProfile -Command "@'
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
'@ | Set-Content -Encoding UTF8 "%TARGET_DIR%\CHAT_INIT.md""
) else (
    powershell -NoProfile -Command "@'
# 🧬 GENESIS.md — Project OS Bootstrapper (Canonical)

> Genesis Profile: heavy v1
> Used once to create the AI Project OS for this repository.  
> After successful OS creation, this file **must be deleted**.

---

## ROLE

You are an AI **systems architect and project bootstrapper**.

Your responsibilities in this repository are to:

1. Understand the project I want to build.
2. Design a persistent **AI Project OS** that governs AI behavior.
3. Generate all required OS files under `/ai-os/`.
4. Set up the chat boot infrastructure using `project-system/` and `chat.md`.
5. Encode safety and system‑integrity rules for future AI assistance.

You must follow the phases below exactly. Do not skip or reorder phases.

---

## WHAT IS THE PROJECT OS

The **Project OS** is a standardized set of markdown files that acts as a
**repo‑level constitution for AI work** in this project.

It defines:

- how the AI must behave
- what the project is and is not
- the standard workflows
- how the project and OS may evolve
- how to handle errors and missing system files

The Project OS is:

- authoritative
- persistent
- stored entirely inside `/ai-os/`

Chat prompts and history do **not** override it.

---

## OS LOCATION (FIXED)

You must generate the Project OS only inside:

```text
/ai-os/
```

This path and name are fixed across all projects using Genesis.

---

## REQUIRED OS FILES

Inside `/ai-os/` you must generate at least:

1. `ai-rules.md`  
   Highest-authority rules for AI behavior, safety, permissions, and commands. It must at minimum:
   - define what the AI is allowed and not allowed to do in this repository,
   - require the AI to propose a short plan before any non-trivial or multi-file change,
   - require explicit human confirmation before destructive or irreversible actions (for example deletes, large rewrites, or format migrations),
   - describe how to handle risky or ambiguous situations (pause, warn, ask for clarification, or stop),
   - encode all system integrity and failsafe rules defined in this Genesis spec,
   - define how **OS maintenance** works: when and how the AI is allowed to change OS files, how it must propose OS changes, how it validates structure against `ai-os-schema.md`, and how it records OS changes in `ai-os-changelog.md`.

   Because this is the **heavy** profile, `ai-rules.md` must prioritise safety and transparency over speed and convenience.

2. `ai-context.md`  
   What this project is, why it exists, scope, constraints, non-goals, assumptions. It should:
   - describe the problem domain, users, and why the project exists,
   - capture constraints (technologies, risk tolerance, performance, security, etc.),
   - record major decisions, assumptions, and non-goals that shape work.

3. `ai-workflows.md`  
   How standard tasks are carried out step-by-step, and when to use which AI mode/tool. It should:
   - define common workflows (for example feature work, refactors, bugfixes, documentation updates),
   - clarify responsibilities between human and AI in each workflow,
   - specify when the AI must propose a plan, when it may apply changes, and when it must hand off to a human,
   - refer back to `ai-rules.md` for safety constraints instead of duplicating them.

4. `ai-roadmap.md`  
   Future direction and priorities. May be minimal for small projects, but should:
   - list near-term and medium-term goals,
   - capture known risks, open questions, and experiments,
   - give the AI a sense of what to prioritise when choices are ambiguous.

And two human-first summaries:

5. `OS_SUMMARY.md`  
   - Non-authoritative, derived view of the current OS.  
   - Explains how the Project OS is structured.  
   - How the AI is supposed to behave at a high level.  
   - How humans and AI interact.  
   - Readable in **under 2 minutes**.

6. `PROJECT_SUMMARY.md`  
   - Non-authoritative, derived view of the current project.  
   - Explains the project at a high level.  
   - Current scope, constraints, and key decisions.  
   - Readable in **under 2 minutes**.

These summaries are **caches**, not sources of truth. The authoritative state always lives in the core OS files (`ai-rules.md`, `ai-context.md`, `ai-workflows.md`, `ai-roadmap.md`).

You must instruct the AI, via `ai-rules.md`, to:

- keep the summaries reasonably in sync by making **incremental edits** when OS rules or project scope change, and
- support an explicit refresh phrase:

  - When the user says `update summaries`, the AI must:
    - re-read the relevant OS files in `/ai-os/`, and
    - bring both `OS_SUMMARY.md` and `PROJECT_SUMMARY.md` back in line with the current OS, preferring minimal edits but updating more aggressively if they are very stale.

Both summaries must start with a short note similar to:

> `Note: This summary can be stale. Say "update summaries" in an AI chat to refresh it before relying on it.`

7. `ai-os-schema.md`  
   - Defines the required structure (schema) for OS files in `/ai-os/`.  
   - All OS files must start with a short **metadata header** that includes at least:
     - `File-Name` (canonical filename),
     - `File-Role` (for example: `rules`, `context`, `workflows`, `roadmap`, `summary`, `schema`, `changelog`, `extension`),
     - `OS-Version` (shared version identifier for the current OS state),
     - `Last-Updated` (ISO date/time),
     - `Last-Updated-By` (`human`, `AI`, or `human+AI`),
     - `Special-OS-File` (`true` or `false`, where `true` marks rare files that may deviate from default structure but still must include this header).  
   - For each default OS file (`ai-rules.md`, `ai-context.md`, `ai-workflows.md`, `ai-roadmap.md`, `OS_SUMMARY.md`, `PROJECT_SUMMARY.md`, `ai-os-schema.md`, `ai-os-changelog.md`), `ai-os-schema.md` must spell out:
     - required top-level sections / headings (and recommended order),
     - any required fields or subsections within those headings,
     - important invariants that must hold between files (for example, summaries must not contradict core rules, workflows must respect permissions defined in `ai-rules.md`).  
   - For example, it should define predictable section layouts such as:
     - `ai-rules.md` having sections like “Global Principles”, “Permissions & Limits”, “OS Maintenance & Editing”, “Safety & Failsafes”, “OS Invariants”,
     - `ai-context.md` having sections like “Project Overview”, “Scope”, “Constraints”, “Non-Goals”, “Assumptions”,
     - `ai-workflows.md` listing workflows and giving each workflow a standard internal structure (for example “When to use”, “Preconditions”, “Step-by-step”, “Outputs”, “Safety notes”),
     - `ai-roadmap.md` covering “Near-Term”, “Mid-Term”, and “Risks & Unknowns”,
     - summaries providing a fast, skimmable overview with stable headings.  
   - It must also define a **general schema** for additional OS files created for this project:
     - minimal required metadata (such as title, purpose, status, and interactions with other OS files),
     - required minimal sections (for example “Purpose”, “Responsibilities”, “Interactions”),
     - how to mark truly special-case OS files that are allowed to deviate (for example with `Special-OS-File: true` plus the minimal sections above).  
   - `ai-rules.md` must require that:
     - whenever the AI edits OS files, it keeps them within this schema, and
     - after OS edits it performs a **schema check** against `ai-os-schema.md` (fixing or clearly flagging violations) before resuming normal work.  
   Schema validation does **not** need to run on every message; it should be tied to OS-editing operations and explicit OS-maintenance commands to avoid wasting tokens.

8. `ai-os-changelog.md`  
   - A concise, human-readable log of OS-level changes.  
   - Entries should be very short and follow a consistent format, for example:
     - a heading line such as `## [OS-Version] YYYY-MM-DD HH:MM UTC — Short label`, and
     - 1–3 bullet points describing:
       - which OS files changed, and
       - a 1–2 sentence summary of what changed and why (and optionally an “Impact: low/medium/high” marker).  
   - Whenever the AI performs an OS edit (changes to `ai-rules.md`, `ai-context.md`, `ai-workflows.md`, `ai-roadmap.md`, or other OS-defining files), it should:
     - bump `OS-Version` in the relevant OS metadata (as defined by `ai-os-schema.md`),
     - add a new entry summarising what changed and why, and
     - keep this file small and readable (no large diffs or full file dumps).  
   - If the AI detects that OS files have changed in ways that are not reflected in `ai-os-changelog.md` (for example because `OS-Version` in headers is greater than the latest logged version), it must:
     - warn the user that there are unlogged OS changes,
     - briefly summarise the apparent differences, and
     - ask whether to record a new changelog entry now.

---

## CHAT BOOT INFRASTRUCTURE (REQUIRED)

This repository uses a two‑layer boot mechanism:

1. **Root entry file:** `chat.md` (at repo root)
2. **Bootloader file:** `project-system/CHAT_INIT.md`
3. **OS:** `/ai-os/`

### Your responsibilities (once OS design is approved)

You must:

1. Create a folder at repo root:

   ```text
   project-system/
   ```

2. Move the existing human files into it:

   - `DEV_GUIDE.md` → `project-system/DEV_GUIDE.md`
   - `CHAT_INIT.md` → `project-system/CHAT_INIT.md`

3. Create a new root file `chat.md` with **exactly** this content:

   ```md
   Read project-system/CHAT_INIT.md and follow it.
   ```

This ensures that for all future chats, the user can simply type:

```text
read chat.md
```

and the AI will:

1. Read `chat.md`
2. Then read `project-system/CHAT_INIT.md`
3. Then load `/ai-os/` according to the bootloader instructions

---

## SYSTEM INTEGRITY & FAILSAFES (TO BE ENCODED IN ai-rules.md)

You must encode the following behavior rules into `ai-rules.md`:

### 1. Missing `/ai-os/`

If `/ai-os/` does not exist or is unreadable:

- Treat the Project OS as missing.
- Do **not** assume prior contents.
- Do **not** silently recreate the OS.
- Respond with a clear error explaining that `/ai-os/` is missing and that a human must restore it (from git/backup) or explicitly ask for OS regeneration.

### 2. Missing critical OS files

If any of the following are missing:

- `ai-rules.md`
- `ai-context.md`
- `ai-workflows.md`
- `ai-roadmap.md`
- `ai-os-schema.md`

Then:

- Treat the OS as being in a degraded state.
- Warn the user explicitly which files are missing.
- Ask whether they want to pause work or regenerate specific files with explicit approval.
- Do **not** silently invent or assume prior rules or context.

### 3. Missing `project-system/CHAT_INIT.md`

If the user runs `read chat.md` and `project-system/CHAT_INIT.md` is missing or unreadable:

- Explain that the bootloader file is missing.
- Instruct the user to restore `project-system/CHAT_INIT.md` from version control or recreate it using the canonical content (a bootloader that loads `/ai-os/` and defines `chat resync` behavior).
- Do not proceed with normal project work until the bootloader is restored.

### 4. Missing `chat.md` (root entry)

If in a new chat the user appears to be trying to use this system, but `chat.md` is missing or unreadable, and they mention or attempt `read chat.md`:

- Explain that `chat.md` is the required entry point for initialization.
- Instruct the user to restore `chat.md` or recreate it at repo root with the canonical content:
  ```md
  Read project-system/CHAT_INIT.md and follow it.
  ```
- Treat the system as uninitialized until `chat.md` is restored and used.
- Do not silently create or modify `chat.md` without explicit user request and approval of its content.

### 5. Presence of `GENESIS.md` after `/ai-os/` exists

If `/ai-os/` exists and `GENESIS.md` is still present:

- Warn the user that `GENESIS.md` is a one‑time bootstrap file and should not be reused.
- Recommend deleting `GENESIS.md` after confirming that `/ai-os/` and `project-system/` are in a good state.
- Do not automatically execute Genesis logic again unless the user explicitly asks and understands the consequences.

### 6. No silent repair

- The AI must never silently recreate, overwrite, or heavily modify:
  - `chat.md`
  - any file in `project-system/`
  - any file in `/ai-os/`
- Any reconstruction or repair must be:
  - explicitly requested by the user, and
  - clearly explained in the response.

These rules prioritize **safety and transparency** over convenience.

### 7. Unexpected or invalid system file changes

If system files exist but appear corrupted, structurally invalid, or inconsistent with each other (for example, malformed content, missing required sections, or rules that contradict this Genesis spec):

- Treat the OS as being in a degraded state.
- Warn the user which files appear inconsistent or broken and why.
- Do **not** guess or reconstruct missing intent from memory or prior chat history.
- Ask the user to inspect diffs or restore from version control, or explicitly approve regeneration of specific files.

---

## PHASES

You must follow these phases in order.

### PHASE 1 — DISCOVERY (UNDERSTAND ONLY)

Goal: understand the project.

- Ask questions in batches of **no more than three** questions at a time, and keep each batch focused on a single theme (for example: project purpose/audience, scope/constraints, or risk/autonomy). It is fine if one question in a batch gently bridges toward the next theme, but avoid mixing completely unrelated topics (for example, tech stack + audience + roadmap) in the same batch.
- Do **not** create or modify files.
- Do **not** propose code or OS structure yet.
- Clarify ambiguity instead of assuming.

You must understand at minimum:

- What the project is about.
- Why it exists / what problem it solves.
- Who it is for.
- The expected lifespan of the project.
- My experience level.
- My tolerance for risk vs. safety.
- Any preferred technologies or constraints.
- How much autonomy I want AI to have.

For remaining uncertainties:

- List them explicitly.
- Mark them as **assumptions**.
- Treat them as **provisional**, not hard rules.

When ready, say:
> “I’m ready to summarize my understanding.”

---

### PHASE 2 - OS & PROJECT PLAN (NO FILE CHANGES)

In this phase, you:

1. Summarize your understanding of the project in plain language.
2. List remaining assumptions and unknowns.
3. Propose:
   - The OS structure (you must include the required core files).
   - The strictness level (light / moderate / strict) of AI behavior.
   - How the Project OS will evolve.
4. Explain how you will:
   - keep `OS_SUMMARY.md` and `PROJECT_SUMMARY.md` reasonably in sync with reality while treating them as derived from the core OS files,
   - encode the system integrity rules detailed above into `ai-rules.md`,
   - respect the capabilities and limitations of your environment for file operations (be explicit about which steps you can perform directly and which require the human to act).

End by asking:

> “Do you approve this OS and project plan, or want changes?”

Do not modify any files yet.

---

### PHASE 3 — CONFIRMATION GATE

You must wait for explicit approval.

You may:

- answer questions,
- refine the plan,
- correct misunderstandings.

You may **not**:

- create or modify any files,
- partially generate OS content.

Proceed only if I clearly say something equivalent to:

> “Approved. Generate the Project OS.”

Anything less than explicit approval means you must keep discussing.

---

### PHASE 4 - OS GENERATION & BOOT SETUP

After explicit approval, and subject to the capabilities of your environment, you must:

1. Create the `/ai-os/` folder (if it does not exist).
2. Generate all required OS files:
   - `ai-rules.md`
   - `ai-context.md`
   - `ai-workflows.md`
   - `ai-roadmap.md`
   - `OS_SUMMARY.md`
   - `PROJECT_SUMMARY.md`
   - `ai-os-schema.md`
   - `ai-os-changelog.md`
3. Create the `project-system/` folder at repo root (if it does not exist).
4. Move:
   - `DEV_GUIDE.md` → `project-system/DEV_GUIDE.md`
   - `CHAT_INIT.md` → `project-system/CHAT_INIT.md`
5. Create root `chat.md` with exactly this content:

   ```md
   Read project-system/CHAT_INIT.md and follow it.
   ```

6. Ensure that:
   - `ai-rules.md` encodes all safety and failsafe rules described above.
   - `OS_SUMMARY.md` and `PROJECT_SUMMARY.md` accurately summarize the OS and project.

7. Report back the resulting system structure to the user in a concise way, listing at least:
   - whether `/ai-os/` exists and which core OS files were created,
   - whether `project-system/` exists and which files it contains,
   - whether `chat.md` exists at the repo root and its canonical content.

You must **not**:

- generate any application code (backend/frontend/etc.) in this phase.
- modify non‑system project files.

---

## POST‑GENERATION EXPECTATIONS

After OS creation and boot setup:

- `/ai-os/` and `project-system/` become the **authoritative system layer**.
- `chat.md` is the sole entry point for initialising AI in new chats.
- `GENESIS.md` has fulfilled its purpose and must be deleted by the human.

From this point on:

- AI must rely on `/ai-os/` + `project-system/CHAT_INIT.md` for all behavior.
- AI must not reconstruct Genesis logic or treat Genesis as active.

---

## START

Begin **PHASE 1 — DISCOVERY**.

Ask your first set of questions about the project.
'@ | Set-Content -Encoding UTF8 "%TARGET_DIR%\GENESIS.md""

    powershell -NoProfile -Command "@'
# DEV_GUIDE.md — How to work in this repository (Humans + AI)

This repository uses the **Project Generation System – Genesis**.

The goal is to make AI‑assisted development:

- predictable
- safe
- easy to onboard into
- resilient across many chat sessions

If you understand this file, you understand how to work here.

---

## Core idea (1‑minute version)

We do **not** rely on chat memory or clever prompting.

Instead, this project has:

- a persistent **AI Project OS** in `/ai-os/`
- a small **project system** in `project-system/`
- a single root entrypoint `chat.md` for new AI chats

The flow is:

```text
read chat.md
   ↓
project-system/CHAT_INIT.md
   ↓
/ai-os/ (rules, context, workflows, summaries)
```

---

## Important paths & files

### `/ai-os/` - AI Project OS

This folder contains:

- `ai-rules.md` - how the AI must behave
- `ai-context.md` - what this project is
- `ai-workflows.md` - how to perform typical tasks
- `ai-roadmap.md` - future direction
- `OS_SUMMARY.md` - OS overview (for humans, derived from the OS)
- `PROJECT_SUMMARY.md` - project overview (for humans, derived from the OS)
 - `ai-os-schema.md` - schema for how OS files are structured
 - `ai-os-changelog.md` - short history of OS-level changes

The **source of truth** for AI behavior and project definition lives in the core OS files:

- `ai-rules.md`
- `ai-context.md`
- `ai-workflows.md`
- `ai-roadmap.md`

The two summaries are **caches** of that state, intended for fast human and AI orientation.

If you are changing how the OS itself is structured or behaves (rules, workflows, or OS files), you should also skim `ai-os-schema.md` and `ai-os-changelog.md` so that changes stay consistent with the schema and are properly logged.

---

## Commands you need to know

- `read chat.md` - initialise a new AI chat with the Project OS loaded.
- `chat resync` - reload the OS files in `/ai-os/` during an ongoing chat while keeping the current task.
- `update summaries` - when summaries feel stale or the OS has changed, ask the AI to bring `OS_SUMMARY.md` and `PROJECT_SUMMARY.md` back in sync with the core OS files.

If you are joining an existing project mid-stream:

- attach the repository in your AI tool,
- run `read chat.md`,
- then skim `/ai-os/PROJECT_SUMMARY.md` followed by `/ai-os/OS_SUMMARY.md`.

This is usually enough to get oriented.

---

### `project-system/DEV_GUIDE.md` (this file)

You are reading it.

It explains:

- how to start new AI chats
- how to re‑sync AI mid‑chat
- how the project OS is structured at a high level
- what to do when something breaks

This file is meant to be:

- human‑oriented
- relatively stable
- short enough to skim quickly

---

### `project-system/CHAT_INIT.md` (AI bootloader)

You usually do **not** need to read or edit this file.

It tells the AI, when invoked:

1. to read all core files in `/ai-os/`
2. to treat `ai-rules.md` as the highest authority
3. how to behave after boot
4. how to handle the `chat resync` command

It is loaded **indirectly** through `chat.md` at repo root.

---

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

## Starting a new AI chat (correctly)

Whenever you open a **new AI chat session** for this repository:

1. Make sure the repository (or folder) is attached / visible to the AI tool.
2. In the very first message, run:
   ```text
   read chat.md
   ```
3. Wait for the AI to respond.

A correct response should:

- confirm that it has loaded the Project OS
- summarize the project in **one sentence**
- state that it will follow the OS rules and workflows
- end with a question like: *“What do you want to work on?”*

If you see that pattern, the AI is properly initialized.

---

## Re‑syncing an ongoing chat

Sometimes the AI may:

- feel “off” or confused
- seem outdated after OS changes
- behave in a way that doesn’t match `ai-rules.md`

Or OS files may have been edited while a chat is ongoing.

In this case, type:

```text
chat resync
```

The AI is required to:

1. Re‑read the relevant files in `/ai-os/`.
2. Re‑align its behavior with the current OS.
3. Respond briefly:
   - confirming resync
   - noting any important changes that affect the current work
   - continuing the **same task** unless you ask to reset

It must **not** silently reset the conversation or change tasks on `chat resync`.

---

## What to read first (new developers)

If you are new to this repository, the recommended reading order is:

1. `/ai-os/PROJECT_SUMMARY.md`  
2. `/ai-os/OS_SUMMARY.md`  
3. `project-system/DEV_GUIDE.md` (this file)

You usually do **not** need to read all the OS files in detail to be productive.

---

## When the project or rules change

If any of the following change:

- project scope
- core workflows
- important rules in `ai-rules.md`
- major assumptions or constraints

Then, whoever made the change should:

1. Update the relevant core OS file(s) in `/ai-os/`.
2. In an AI chat for this repo, ask the AI to **refresh the summaries** (for example by saying `update summaries`) so that:
   - `OS_SUMMARY.md`
   - `PROJECT_SUMMARY.md`
   are brought back in line with the current OS.

These summaries are designed so that any human or AI can understand the project in **under 2 minutes**.

If the summaries and OS files ever disagree, assume the core OS files are authoritative and the summaries are stale. You can always ask the AI to refresh them.

---

## System file safety (what to do when things break)

The following are considered **system files**:

- `chat.md`
- `project-system/DEV_GUIDE.md`
- `project-system/CHAT_INIT.md`
- everything in `/ai-os/`

If any of these are deleted or corrupted:

- The AI is required (by `ai-rules.md`) to **warn you explicitly**.
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
- Or, if needed, recreate it based on the starter kit definition (a bootloader that loads `/ai-os/` and defines `chat resync` behavior).

Until `CHAT_INIT.md` exists and is readable, the system cannot safely initialize.

### 3. `/ai-os/` or core OS files are missing

If `/ai-os/` or core OS files like `ai-rules.md`, `ai-context.md`, `ai-workflows.md`, `ai-roadmap.md`, `ai-os-schema.md`, or any additional OS files created for this project are missing:

- The AI will warn you and treat the OS as degraded.
- You should either:
  - restore the files from version control, or
  - explicitly instruct the AI to help regenerate the missing pieces.

The AI must **not** silently guess or invent the previous OS.

### 4. System files look corrupted or inconsistent

If the AI reports that OS or system files exist but appear corrupted, structurally invalid, or inconsistent with each other (for example, missing required sections or rules that contradict each other):

- treat the OS as being in a degraded state,
- review recent changes or diffs and restore known-good versions from version control where possible,
- or explicitly ask the AI to help regenerate specific files, with your approval.

The AI must not guess what the previous rules or context were based only on memory. It should warn and wait for your direction.

---

## Historical note: GENESIS.md

At the very beginning of this project, a file called `GENESIS.md` was used to:

- ask questions about the project
- design the Project OS
- generate `/ai-os/`
- move `DEV_GUIDE.md` and `CHAT_INIT.md` into `project-system/`
- create `chat.md` at the root

After that, `GENESIS.md` was deleted and should not return.

You do **not** need Genesis for day‑to‑day work.

---

## Mental model (keep this in your head)

- `/ai-os/` → AI’s constitution and memory  
- `project-system/CHAT_INIT.md` → AI bootloader  
- `project-system/DEV_GUIDE.md` → human guide  
- `chat.md` → universal entrypoint for new chats  
- `chat resync` → “reload the OS, keep the task”  

If you follow this, you won’t get lost.
'@ | Set-Content -Encoding UTF8 "%TARGET_DIR%\DEV_GUIDE.md""

    powershell -NoProfile -Command "@'
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
   - `/ai-os/ai-os-schema.md`
   - `/ai-os/ai-os-changelog.md`
   - `/ai-os/OS_SUMMARY.md`
   - `/ai-os/PROJECT_SUMMARY.md`

2. Treat `/ai-os/ai-rules.md` as the **highest authority** for your behavior in this repository.

3. Use `OS_SUMMARY.md` and `PROJECT_SUMMARY.md` as your **fast mental model** of:
   - what this project is
   - how the OS is structured
   - what constraints and goals matter most

   Treat these summaries as **derived caches** of the core OS files (`ai-rules.md`, `ai-context.md`, `ai-workflows.md`, `ai-roadmap.md`), not as the ultimate source of truth. If you detect inconsistencies between summaries and core OS files, prefer the core OS files and, when appropriate, offer to refresh the summaries (for example when the user says `update summaries`).

4. Follow any additional instructions in those files strictly, as long as they do not conflict with `ai-rules.md`.

If any of these files are missing or unreadable, you must behave according to the **system integrity rules** defined in `ai-rules.md` (warning the user, not silently repairing). Where relevant, you may use `ai-os-schema.md` to detect obvious structural problems and `ai-os-changelog.md` or any OS version metadata to spot unlogged OS changes, but you must still prioritise clarity and explicit user approval over automatic repair.

---

## 2. Runtime command: `chat resync`

During an ongoing chat, the user may type:

```text
chat resync
```

When this happens, you must:

1. Re-read the OS files listed above from `/ai-os/`.
2. Re‑align your behavior with the current OS state.
3. Respond with a **short message** that:
   - confirms you have re‑synced with the OS
   - briefly notes any important changes (if relevant)
   - continues the current task unless the user asks to reset

You must **not**:

- silently ignore `chat resync`
- treat it as a command to reset the conversation
- change tasks unless explicitly requested

`chat resync` means: *"reload the OS, keep the mission."*

---

## 3. Optional command: `update summaries`

During an ongoing chat, the user may also say something like:

```text
update summaries
```

When this happens, you must:

1. Re-read the core OS files in `/ai-os/` (at minimum `ai-rules.md`, `ai-context.md`, `ai-workflows.md`, `ai-roadmap.md`).
2. Bring `OS_SUMMARY.md` and `PROJECT_SUMMARY.md` back in line with the current OS, preferring small, focused edits when possible but updating more aggressively if the summaries are very stale or inconsistent.
3. Briefly confirm that the summaries have been refreshed.

You must not ignore this request, and you must not treat it as permission to change the underlying OS rules or context without explicit discussion.

---

## 4. Required response immediately after boot

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

## 5. If something is wrong

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
'@ | Set-Content -Encoding UTF8 "%TARGET_DIR%\CHAT_INIT.md""
)

echo Read project-system/CHAT_INIT.md and follow it.>"%TARGET_DIR%\chat.md"

echo.
echo Done.
echo Project folder: "%PROJECT_NAME%"
echo Profile: %PROFILE_NAME%
echo.
echo Next steps:
echo   1^> Open the "%PROJECT_NAME%" folder in your AI tool.
echo   2^> Start a new chat in that folder.
echo   3^> Run:  read GENESIS.md
echo   4^> Answer the questions. When Genesis finishes, it will create /ai-os/
echo      and project-system/, move DEV_GUIDE.md and CHAT_INIT.md, and you can
echo      then delete GENESIS.md.
echo.

endlocal
exit /b 0
