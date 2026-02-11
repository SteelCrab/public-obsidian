# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an Obsidian vault containing Git documentation written in Korean, organized in Zettelkasten (atomic notes) style.

## Structure

- `GCP/` - GCP infrastructure docs and scripts (GCP_MOC)
- `aws/` - AWS service reference notes (AWS_MOC)
- `cicd/` - CI/CD learning notes and examples (CICD_MOC)
- `database/` - Database & MySQL reference (Database_MOC)
- `docker/` - Docker command reference + day-based learning log (Docker_MOC)
- `git/` - Git command reference notes, one topic per file (Git_MOC)
- `github/` - GitHub Actions reference (GitHub_Actions_MOC)
- `gitlab/` - GitLab CI/CD reference (GitLab_MOC)
- `kubernetes/` - Kubectl reference + day-based learning log (Kubectl_MOC)
- `linux/` - Linux scripts and user management (Linux_MOC)
- `on-premise-ict/` - On-premise K8s/Docker project (OnPremise_MOC)
- `personal-project/` - K8s 3-Tier HA system project (PersonalProject_MOC)
- `python/` - Python learning notes (Python_MOC)
- `rust/` - Rust language and crate reference (Rust_MOC)
- `.obsidian/` - Obsidian configuration (do not modify)

## Conventions

### Note Format
Each note follows this structure:
```markdown
# Title

#tag1 #tag2

---

Description

| 명령어 | 설명 |
|--------|------|
| `command` | explanation |
```

### Linking
- Use Obsidian wiki-links: `[[note-name]]`
- Use Korean for content and descriptions

### Tags
- Use Korean hashtags: `#git #커밋 #브랜치`
- Tags appear after the title heading

### File Naming
- Git commands: `git-<command>.md` (e.g., `git-commit.md`)
- Comparison notes: `git-<x>-vs-<y>.md` (e.g., `git-merge-vs-rebase.md`)
