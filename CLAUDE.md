# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a public Obsidian vault used as a personal knowledge base (Zettelkasten style). All content is written in Korean. The vault is synced to GitHub via the obsidian-git plugin, with topic branches (`docs/git`, `docs/cicd`, etc.) merged into `main`.

## Structure

- **Root level** - Standalone notes, scripts (EKS setup), and daily notes (`YYYY-MM-DD.md`)
- **`MZ-CLOUD/`** - Main knowledge base, organized by topic:
  - `git/` - Git command reference (~53 notes)
  - `rust/` - Rust language notes + GlueSQL/PipeSQL project notes (~75 notes)
  - `docker/` - Docker commands and Linux notes
  - `kubernetes/` - kubectl command reference
  - `github/` - GitHub Actions reference (`gha-*.md`)
  - `gitlab/` - GitLab CI/CD reference
  - `cicd/` - CI/CD daily learning logs and examples
  - `aws/` - AWS service notes
- **`MZ-CLOUD/.obsidian/`** - Nested vault config (MZ-CLOUD can be opened as a standalone vault)
- **`.obsidian/`** - Root vault config

## Note Conventions

### Format
Every note follows this structure:
```markdown
# Title (Korean)

#tag1 #tag2 #tag3

---

Brief description

| 명령어 | 설명 |
|--------|------|
| `command` | explanation |
```

### MOC (Map of Content) Hub Notes
Each topic has a `*_MOC.md` hub note (e.g., `Rust_MOC.md`, `Git_MOC.md`, `CICD_MOC.md`) that links all related atomic notes using `[[wiki-links]]`.

### File Naming
- Git: `git-<command>.md` (e.g., `git-commit.md`)
- Comparisons: `git-<x>-vs-<y>.md` (e.g., `git-merge-vs-rebase.md`)
- Rust: `rust-<topic>.md` (e.g., `rust-ownership.md`)
- Rust crates: `rust-crate-<name>.md` (e.g., `rust-crate-tokio.md`)
- GitHub Actions: `gha-<topic>.md` (e.g., `gha-workflow.md`)
- GitLab CI: `gitlab-<topic>.md` (e.g., `gitlab-jobs.md`)
- GlueSQL: `gluesql-<module>.md`
- PipeSQL: `pipesql-<module>.md`

### Content Rules
- Write all content in Korean
- Use Obsidian wiki-links `[[note-name]]` for internal links
- Use Korean hashtags: `#git #커밋 #브랜치`
- Tags go immediately after the `# Title` heading

## Branching Strategy

Each documentation topic gets its own branch (e.g., `docs/git`, `docs/cicd`), merged into `main` when ready. The obsidian-git plugin auto-commits with messages like `vault backup: YYYY-MM-DD HH:MM:SS`.

## Important Notes

- `.obsidian/` directories contain Obsidian app configuration - avoid modifying these
- The vault uses these plugins: obsidian-git, obsidian-icon-folder, table-editor-obsidian, automatic-table-of-contents
- `MZ-CLOUD/` is a nested vault with its own `.obsidian/` config
