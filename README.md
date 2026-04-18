# AI-skills

Public Claude Code plugin marketplace. Each listed skill lives in its own GitHub repo and is wired in as a git submodule.

## Why this is "public only"

Claude Code's `/plugin marketplace add` clones the marketplace repo with `--recurse-submodules`, which aborts if any submodule is inaccessible. A private submodule in this repo would break the whole marketplace for anyone without access. To keep this marketplace universally installable, **only public skills are listed here**. Private skills live in separate marketplaces (e.g. `AI-skills-private`) that only authorised users add alongside this one.

## For end users

Install the marketplace once, then install any plugin from it:

```
/plugin marketplace add nuschpl/AI-skills
/plugin install <plugin-name>@AI-skills
```

Refresh to pick up upstream changes:

```
/plugin marketplace update
```

## Layout

```
AI-skills/
├── .claude-plugin/
│   └── marketplace.json          # list of plugins
├── plugins/
│   └── <plugin-name>/
│       ├── .claude-plugin/
│       │   └── plugin.json       # plugin metadata
│       └── skills/
│           └── <SkillName>/      # git submodule → separate repo
├── bin/
│   ├── add-skill.sh              # add a new skill submodule + wire manifests
│   ├── update-all.sh             # bump every submodule to upstream HEAD
│   └── link-dev.sh               # symlink ~/.claude/skills/<skill> → here
└── README.md
```

Why submodules? Each skill has its own lifecycle, its own contributors, and its own visibility. The marketplace just lists them.

## For developers working on the skills

### First-time clone

```bash
git clone --recursive git@github.com:nuschpl/AI-skills.git
cd AI-skills
bin/link-dev.sh OLX          # makes ~/.claude/skills/OLX point here
```

If you forgot `--recursive`:

```bash
git submodule update --init --recursive
```

### Everyday edits to a skill

Submodules behave like independent repos. `cd` into one and work normally:

```bash
cd plugins/olx/skills/OLX
# edit, test, commit, push — this goes to AI-skills-auctions-OLX, not here
git add -p && git commit -m 'Fix foo' && git push
```

Back in the marketplace root, bump the recorded commit pointer:

```bash
cd ../../../..            # back to AI-skills/
git add plugins/olx/skills/OLX
git commit -m 'Bump olx to <short sha>'
git push
```

End users then see the new version after `/plugin marketplace update`.

### Adding a new skill

1. Create a new GitHub repo for the skill (e.g. `AI-skills-auctions-Allegro`) and push its initial `SKILL.md` + code.
2. In this marketplace:
   ```bash
   bin/add-skill.sh allegro Allegro git@github.com:nuschpl/AI-skills-auctions-Allegro.git
   ```
3. Edit the auto-generated description in `.claude-plugin/marketplace.json` and `plugins/allegro/.claude-plugin/plugin.json`.
4. Commit and push.

### Bumping every submodule at once

```bash
bin/update-all.sh
# review diff, then commit + push
```

## Gotchas

- **Private skills**: submodule clones for other people will fail unless they have access. Plan accordingly.
- **Plugin updates don't always re-sync submodules** in older Claude Code builds (see claude-code#25598). If an end user reports a stale plugin after `/plugin marketplace update`, ask them to reinstall it.
- **`${CLAUDE_PLUGIN_ROOT}`** is not expanded inside SKILL.md bash blocks (known upstream issue). Skills must resolve their own root from the SKILL.md file location.
