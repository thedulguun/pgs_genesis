# Project Generation System — Genesis

Project Generation System – **Genesis** is a small, opinionated system for starting and running AI‑assisted projects in a predictable way.

Instead of relying on fragile prompts or chat history, Genesis gives each project:

- A persistent **AI Project OS** (`/ai-os/`)
- A clear **AI boot path** (`chat.md` → `project-system/CHAT_INIT.md` → `/ai-os/`)
- A stable **human guide** (`project-system/DEV_GUIDE.md`)
- Safety rules and failsafes for system file changes or deletions

You can reuse this system across projects.

---

## Files in this starter kit

You copy these **three** files into an empty project folder:

- `GENESIS.md` – one‑time project bootstrapper (talks to the AI)
- `DEV_GUIDE.md` – human instructions for how to work with AI
- `CHAT_INIT.md` – AI bootloader instructions (will later be moved)

After you run Genesis once, it will:

- Generate `/ai-os/` (the Project OS)
- Create `project-system/` and move:
  - `DEV_GUIDE.md` → `project-system/DEV_GUIDE.md`
  - `CHAT_INIT.md` → `project-system/CHAT_INIT.md`
- Create a tiny root file `chat.md` that points to `project-system/CHAT_INIT.md`
- Leave `/ai-os/` and `project-system/` as the long‑term structure
- Allow you to safely delete `GENESIS.md`

Final shape (after Genesis completes):

```text
chat.md                      # tiny entry point for all future chats
project-system/
  DEV_GUIDE.md               # human guide
  CHAT_INIT.md               # AI bootloader

ai-os/                       # AI Project OS (generated)
  ai-rules.md
  ai-context.md
  ai-workflows.md
  ai-roadmap.md
  OS_SUMMARY.md              # fast OS overview (derived)
  PROJECT_SUMMARY.md         # fast project overview (derived)
  ai-os-schema.md            # OS file structure/schema
  ai-os-changelog.md         # short OS change history
```

---

## How to bootstrap a new project

1. Create an empty project folder.
2. Copy in these three files:
   - `GENESIS.md`
   - `DEV_GUIDE.md`
   - `CHAT_INIT.md`
3. Start a **new AI chat** in this folder.
4. Type:
   ```
   read GENESIS.md
   ```
5. Answer the questions the AI asks (Discovery phase).
6. Approve the OS plan when you’re happy.
7. Let the AI generate `/ai-os/`, `project-system/`, and `chat.md`.
8. **Delete `GENESIS.md`.** It must not be reused after OS creation.

From this point on, the system is “live” for that project.

---

## How to use the system afterwards

### For any new AI chat

Always start with:

```text
read chat.md
```

That does three things:

1. Reads `chat.md` (root)
2. Which tells the AI to read `project-system/CHAT_INIT.md`
3. Which makes the AI load `/ai-os/` and follow its rules

The AI should then respond with a short confirmation that the Project OS is loaded, a one‑sentence project summary, and a “What do you want to work on?” question.

### If the conversation drifts or OS changed mid‑chat

Use:

```text
chat resync
```

This tells the AI to re‑read `/ai-os/` and re‑align with the current OS state **without resetting the task**, unless you explicitly ask for a reset.

---

## When something breaks (system file safety)

System files include:

- `chat.md`
- `project-system/CHAT_INIT.md`
- `project-system/DEV_GUIDE.md`
- everything inside `/ai-os/`

If these are missing or corrupted, the AI is required (by `ai-rules.md`) to:

- **fail loudly**, not silently “fix” things
- warn you about missing or invalid files
- ask you to restore from version control or regenerate with your approval

Example: if `chat.md` is deleted and a new chat can’t run `read chat.md`, you must:

1. Recreate `chat.md` at project root with the canonical content:
   ```md
   Read project-system/CHAT_INIT.md and follow it.
   ```
2. Or restore it from git.

The AI will not silently recreate `chat.md` on its own before it has been initialized. This is intentional.

---

## Philosophy (short)

- Files > chat memory  
- Explicit > assumed  
- Boring > clever  
- Human‑visible > hidden conventions  
- One‑time bootstrap, long‑lived OS  

If you understand this README, you understand how to use Genesis.
