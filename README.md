# c_init

A quick script that sets up a C project folder for you.

## What it does

- Asks you for a project name and creates the folder with `src/` inside
- Asks if you want to clone **get_next_line**, **ft_printf**, or **libft** from your GitHub repos
- Strips `.git/` from any cloned repos so they're just regular folders
- Drops a `.gitignore` with common C stuff (`.o`, `.a`, `.d`, `.DS_Store`)
- Runs `git init`, stages everything, and makes an initial commit

## Setup

1. Put `c_init.sh` in your home directory (`~/`)
2. Add this to your `~/.zshrc`:
```bash
alias cinit="~/c_init.sh"
```
3. `source ~/.zshrc`
4. Open `c_init.sh` and paste your repo links at the top

## Usage

Just type `cinit` in your terminal. It will walk you through everything.
