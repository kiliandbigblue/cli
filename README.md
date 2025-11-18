# CLI Toolkit

A personal CLI toolkit for streamlined DevOps and Git workflows, designed to work with reflow and atlas repositories.

## Overview

This toolkit provides interactive command-line utilities for common development tasks including:
- 🚀 Kubernetes service deployments
- 📋 Cloud log viewing
- 🔀 Git workflow automation
- 🏷️ Version tagging

## Prerequisites

- [just](https://github.com/casey/just) - Command runner
- [gum](https://github.com/charmbracelet/gum) - Interactive prompts
- [gh](https://cli.github.com/) - GitHub CLI
- Git
- Access to Google Cloud Platform

## Installation

```bash
# Clone the repository
git clone <repo-url> ~/projects/cli
cd ~/projects/cli

# Make scripts executable
chmod +x *.sh
```

## Commands

All commands are accessible through the `just` command runner. Run `just --justfile ~/projects/cli/justfile ` to see the full list of available commands.

### DevOps Commands

#### `just deploy`
Interactively deploy reflow or atlas services to Kubernetes.

**Features:**
- Select multiple services to deploy
- Choose specific version/tag to deploy
- Normal or force deployment modes
- Deployment summary with previous versions
- Results copied to clipboard for easy sharing

**Usage:**
```bash
just deploy
```

The script will guide you through:
1. Selecting services to deploy
2. Choosing a version (from git tags)
3. Selecting deployment mode (Normal/Force)
4. Confirming the deployment

#### `just logs`
Open Google Cloud logs for reflow or atlas services.

**Features:**
- Select multiple services
- Choose environment (prod/staging for atlas)
- Opens in browser with pre-configured query
- Shows logs from last 30 minutes
- Groups by service name

**Usage:**
```bash
just logs
```

**Environment Variables:**
- `REFLOW_REPO_PATH` - Override default reflow repo path (default: `~/projects/reflow`)
- `ATLAS_REPO_PATH` - Override default atlas repo path (default: `~/projects/atlas`)

### Git Commands

#### `just submit`
Submit a pull request with the current branch.

**Features:**
- Force pushes current branch
- Creates new PR or opens existing one
- Auto-assigns to yourself
- Uses branch name as PR title

**Usage:**
```bash
just submit
```

#### `just sync`
Sync the current repo with the remote.

**Features:**
- Ensures working directory is clean
- Checks out and pulls main/master branch
- Cleans up merged branches using `gh poi`

**Usage:**
```bash
just sync
```

**Requirements:**
- Clean working directory (no uncommitted changes)

#### `just tag`
Tag the current revision with an incremental fix number.

**Features:**
- Finds latest tag by creation date
- Auto-increments fix number (e.g., `v1.2.3-fix.1`, `v1.2.3-fix.2`)
- Pushes tag to remote

**Usage:**
```bash
just tag
```

**Example:**
```bash
# If latest tag is v1.2.3
# Creates: v1.2.3-fix.1
```

## Project Structure

```
cli/
├── deploy.sh      # Kubernetes deployment script
├── logs.sh        # Google Cloud logs viewer
├── submit.sh      # Pull request automation
├── sync.sh        # Repository sync script
├── tag.sh         # Version tagging script
└── justfile       # Command runner configuration
```

## Configuration

### Justfile
The `justfile` defines all available commands and groups them into categories:
- **devops**: Deployment and logging commands
- **git**: Git workflow commands

All commands run with `[no-cd]` attribute, allowing them to work from any directory.

### Repository Detection
The deploy script automatically detects whether you're in a reflow or atlas repository and adjusts its behavior accordingly:
- **reflow**: Deploys to `bigblue` prod environment
- **atlas**: Allows choosing between prod and staging environments

## Notes

- The deploy and log scripts expect specific repository structures for reflow and atlas
- Some commands require being run from within a git repository
- The sync command uses `gh poi` for branch cleanup (requires GitHub CLI extension)
- All interactive prompts use `gum` for a better CLI experience

## License

Personal project - use at your own discretion.

