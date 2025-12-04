# Task Runners: Make vs Just vs Task

A detailed analysis of command/task runners for workflow automation.

## TL;DR

| Tool | Best For | Install |
|------|----------|---------|
| **Make** | Build systems, C/C++ projects, legacy | Pre-installed |
| **just** | Simple command running, scripts with arguments | `brew install just` |
| **Task** | Cross-platform teams, file change detection | `brew install go-task` |

**Recommendation**: Use **just** for personal workflows and scripts. Use **Task** if you need file-based dependency tracking or work on a cross-platform team.

---

## Philosophy: Build System vs Command Runner

### Make (1976)
- **Purpose**: Build system for compiling software
- **Model**: File-based dependencies with timestamps
- **Question it answers**: "What files need to be rebuilt?"

### just (2016)
- **Purpose**: Pure command runner
- **Model**: Recipe execution, no file tracking
- **Question it answers**: "What command do I want to run?"

### Task (2017)
- **Purpose**: Task runner with optional build features
- **Model**: Hybrid - commands with optional file tracking
- **Question it answers**: "What task do I want to run, and has anything changed?"

---

## Syntax Comparison

### Simple Task

**Makefile**
```makefile
.PHONY: test
test:
	pytest tests/    # MUST be a tab, not spaces!
```

**justfile**
```just
test:
    pytest tests/    # spaces are fine
```

**Taskfile.yml**
```yaml
version: '3'
tasks:
  test:
    cmds:
      - pytest tests/
```

### Task with Dependencies

**Makefile**
```makefile
.PHONY: all build test deploy

build:
	python -m build

test: build
	pytest

deploy: test
	rsync -avz dist/ server:/app/
```

**justfile**
```just
build:
    python -m build

test: build
    pytest

deploy: test
    rsync -avz dist/ server:/app/

# Run everything
all: deploy
```

**Taskfile.yml**
```yaml
version: '3'
tasks:
  build:
    cmds:
      - python -m build

  test:
    deps: [build]
    cmds:
      - pytest

  deploy:
    deps: [test]
    cmds:
      - rsync -avz dist/ server:/app/
```

### Task with Arguments

**Makefile** (awkward)
```makefile
# Must use: make deploy ENV=staging
deploy:
	./deploy.sh $(ENV)
```

**justfile** (natural)
```just
# Usage: just deploy staging
deploy env:
    ./deploy.sh {{env}}

# With default value
deploy env="staging":
    ./deploy.sh {{env}}

# Variadic (multiple args)
test *args:
    pytest {{args}}
```

**Taskfile.yml**
```yaml
version: '3'
tasks:
  deploy:
    cmds:
      - ./deploy.sh {{.ENV}}
    vars:
      ENV: '{{.CLI_ARGS | default "staging"}}'
```

### Variables and Environment

**Makefile**
```makefile
PROJECT := myapp
VERSION := $(shell git describe --tags)

build:
	docker build -t $(PROJECT):$(VERSION) .
```

**justfile**
```just
project := "myapp"
version := `git describe --tags`

# Environment variables from .env are auto-loaded
build:
    docker build -t {{project}}:{{version}} .

# Export to environment
export DATABASE_URL := "postgres://localhost/dev"

migrate:
    alembic upgrade head
```

**Taskfile.yml**
```yaml
version: '3'
vars:
  PROJECT: myapp
  VERSION:
    sh: git describe --tags

tasks:
  build:
    cmds:
      - docker build -t {{.PROJECT}}:{{.VERSION}} .
```

### Conditional Execution

**justfile**
```just
# OS-specific commands
install:
    #!/usr/bin/env bash
    if [[ "{{os()}}" == "macos" ]]; then
        brew install myapp
    else
        apt install myapp
    fi

# Or use built-in conditionals
system-info:
    @echo "OS: {{os()}} / Arch: {{arch()}}"
```

**Taskfile.yml**
```yaml
version: '3'
tasks:
  install:
    cmds:
      - brew install myapp
    platforms: [darwin]

  install:
    cmds:
      - apt install myapp
    platforms: [linux]
```

### Scripts in Other Languages

**justfile**
```just
# Python script
analyze:
    #!/usr/bin/env python3
    import pandas as pd
    df = pd.read_csv("data.csv")
    print(df.describe())

# Node script
format:
    #!/usr/bin/env node
    const data = require('./config.json');
    console.log(JSON.stringify(data, null, 2));
```

---

## Feature Comparison

| Feature | Make | just | Task |
|---------|------|------|------|
| **Syntax** | Custom (tabs required!) | Make-like (spaces OK) | YAML |
| **File dependencies** | ✅ Timestamps | ❌ None | ✅ Checksums |
| **Recipe dependencies** | ✅ | ✅ | ✅ |
| **Arguments** | 😐 Clunky | ✅ Excellent | ✅ Good |
| **Variables** | ✅ Cryptic (`$@`, `$<`) | ✅ Clear (`{{var}}`) | ✅ Clear |
| **Environment/.env** | Manual | ✅ Auto-loads | ✅ Supports |
| **Cross-platform** | 😐 Unix-focused | ✅ Good | ✅ Excellent |
| **.PHONY needed** | Yes | No | No |
| **Task listing** | `make -n` (limited) | `just --list` | `task --list` |
| **Parallel execution** | ✅ `-j` flag | ❌ Sequential | ✅ Deps parallel |
| **Multi-file includes** | ✅ `include` | ✅ `import` | ✅ Namespaced |
| **Shell completion** | Limited | ✅ Built-in | ✅ Available |
| **Shebang scripts** | ❌ | ✅ Any language | ❌ |
| **Watch mode** | ❌ | ❌ | ✅ `--watch` |
| **Installation** | Pre-installed | Single binary | Single binary |

---

## Pain Points

### Make
1. **Tabs vs spaces**: Must use tabs for indentation (invisible bugs)
2. **PHONY boilerplate**: Every non-file target needs `.PHONY`
3. **Cryptic variables**: `$@`, `$<`, `$^` are not readable
4. **Silent failures**: Sometimes doesn't run commands without explanation
5. **Cross-platform**: Windows support is painful

### just
1. **No file tracking**: Can't skip unchanged work
2. **No parallel deps**: Dependencies run sequentially
3. **Less structure**: No namespacing for large projects

### Task
1. **YAML verbosity**: Simple commands need 4+ lines
2. **Learning curve**: More concepts to learn
3. **Go dependency**: Need Go toolchain for some features

---

## Real-World Examples

### ML Experiment Workflow (justfile)

```just
# Variables
model := "resnet50"
data_dir := "data/processed"
results_dir := "results"

# Default: show available commands
default:
    @just --list

# Run full pipeline
all: preprocess train evaluate plot upload

# Data preprocessing
preprocess:
    python scripts/preprocess.py --input data/raw --output {{data_dir}}

# Train model
train model=model:
    python train.py --model {{model}} --data {{data_dir}} --output models/

# Evaluate
evaluate:
    python evaluate.py --model models/best.pt --output {{results_dir}}/

# Generate plots
plot:
    python plot_results.py --input {{results_dir}}/ --output figures/

# Upload to server
upload:
    rsync -avz --progress figures/ server:/data/experiments/$(date +%Y%m%d)/

# Clean artifacts
clean:
    rm -rf {{results_dir}}/ figures/ models/*.pt

# Quick experiment with custom model
experiment model:
    just train {{model}}
    just evaluate
    just plot

# Watch and re-run on changes (using external tool)
watch:
    watchexec -e py -- just train
```

### Web Development Workflow (Taskfile.yml)

```yaml
version: '3'

vars:
  DOCKER_IMAGE: myapp
  DOCKER_TAG:
    sh: git rev-parse --short HEAD

tasks:
  default:
    cmds:
      - task --list
    silent: true

  install:
    desc: Install dependencies
    cmds:
      - npm install
    sources:
      - package.json
    generates:
      - node_modules/**/*

  build:
    desc: Build the application
    deps: [install]
    cmds:
      - npm run build
    sources:
      - src/**/*
    generates:
      - dist/**/*

  test:
    desc: Run tests
    deps: [install]
    cmds:
      - npm test

  docker:
    desc: Build Docker image
    deps: [build]
    cmds:
      - docker build -t {{.DOCKER_IMAGE}}:{{.DOCKER_TAG}} .

  deploy:
    desc: Deploy to production
    deps: [docker, test]
    cmds:
      - docker push {{.DOCKER_IMAGE}}:{{.DOCKER_TAG}}
      - kubectl set image deployment/app app={{.DOCKER_IMAGE}}:{{.DOCKER_TAG}}

  dev:
    desc: Start development server
    cmds:
      - npm run dev
```

---

## Decision Guide

### Use **Make** if:
- Working on C/C++ projects (it's the standard)
- Need file-based dependency tracking
- Team already knows it
- Don't want to install anything

### Use **just** if:
- Want simple, readable task definitions
- Need to pass arguments to tasks
- Want scripts in multiple languages
- Personal projects or small teams
- Primarily macOS/Linux

### Use **Task** if:
- Need file change detection (skip unchanged work)
- Cross-platform team (Windows users)
- Want YAML (familiar, IDE support)
- Need parallel dependency execution
- Larger projects with namespaced tasks

---

## Installation

```bash
# Make (usually pre-installed)
# macOS: comes with Xcode CLI tools
# Linux: apt install make

# just
brew install just              # macOS
cargo install just             # via Rust

# Task
brew install go-task           # macOS
sh -c "$(curl -fsSL https://taskfile.dev/install.sh)"  # Linux
```

---

## Resources

- [Make Manual](https://www.gnu.org/software/make/manual/)
- [just Manual](https://just.systems/man/en/)
- [just GitHub](https://github.com/casey/just)
- [Taskfile Documentation](https://taskfile.dev/)
- [Just vs Make comparison](https://spin.atomicobject.com/just-task-runner/)
- [Taskfile vs Make](https://tsh.io/blog/taskfile-or-gnu-make-for-automation/)
- [Applied Go comparison](https://appliedgo.net/spotlight/just-make-a-task/)
