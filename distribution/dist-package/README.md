# Project Generation System – Genesis (Bootstrap Bundle)

This folder is the **distribution bundle** for Genesis.  
It contains platform-specific setup scripts that create a new project folder and drop the right Genesis files into it.

You should zip the contents of this folder when you publish Genesis.

---

## What Genesis does

Genesis is a small, opinionated system for starting AI-assisted projects in a predictable way.

Instead of relying on chat history, each project gets:

- a persistent **AI Project OS** (`/ai-os/`),
- a stable **boot path** (`chat.md` → `project-system/CHAT_INIT.md` → `/ai-os/`),
- a human-facing **guide** (`project-system/DEV_GUIDE.md`).

Genesis asks you questions, designs the OS, and then generates the OS files for that specific project.

---

## How to bootstrap a new project

1. **Download and unzip** this bundle somewhere on your machine.
2. Run the setup script for your OS:
   - **Windows:** double-click `genesis-setup.bat`.
   - **macOS:** double-click `genesis-setup.command`.
   - **Linux / Unix:** run `./genesis-setup.sh` in a terminal.
3. When prompted:
   - Enter a **project folder name** (new or existing).  
     - If it doesn’t exist, it will be created.  
     - If it does, Genesis files will be added to it.
   - Choose how you expect to use this project:
     - **Light** – smaller or short-lived project  
       - Simple OS (2 files), ideal for quick tools, experiments, solo work.
     - **Heavy** – ongoing or multi-developer project  
       - Full OS (rules, context, workflows, schema, changelog).
4. The script will create/prepare the project folder and add:
   - `GENESIS.md`
   - `DEV_GUIDE.md`
   - `CHAT_INIT.md`
   - `chat.md`

---

## After bootstrapping

1. Open the **project folder** you just created in your AI tool.
2. Start a **new chat** in that folder.
3. Run:

   ```text
   read GENESIS.md
   ```

4. Answer the questions. Genesis will:
   - design the Project OS (light or heavy),
   - generate the `/ai-os/` folder and OS files,
   - move `DEV_GUIDE.md` and `CHAT_INIT.md` into `project-system/`,
   - leave `chat.md` in place as the long-term entry point.

5. When Genesis says OS creation is complete and the structure looks good, **delete `GENESIS.md`** from that project. It is a one-time bootstrap file.

From that point on, for any new chat in that project, just run:

```text
read chat.md
```

and follow the prompts.

