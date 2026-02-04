# AI Development Environment

This document provides context for AI coding assistants (Claude, etc.) working with this dotfiles repository.

## NON-NEGOTIABLE: Verify Before Returning

**Before returning any result to the user, CLAUDE MUST run and verify that the changes complete successfully and the outputs match expectations.** This means:
- Run the relevant commands (`chezmoi apply`, `chezmoi diff`, shell source, etc.) after making changes
- Inspect the actual output files to confirm they rendered correctly
- Confirm environment variables are set, configs are valid, and no errors occurred
- If verification fails, fix the issue and re-verify before responding
- Never assume a change works — prove it

## Repository Overview

This is a **chezmoi-managed dotfiles** repository with:
- Cross-platform support (Linux, macOS, Windows/WSL)
- 1Password integration for secrets management
- Graphite keyboard layout (not QWERTY)
- Templates for machine-specific configuration

## Critical: Secrets Management

**NEVER hardcode sensitive data in this repository.** All secrets are managed through 1Password.

### 1Password Structure

| Vault | Item | Purpose |
|-------|------|---------|
| `AstroCapital` | `Infrastructure` | All infrastructure secrets (IPs, hostnames, AWS, etc.) |

### Reading Secrets

In `.chezmoi.toml.tmpl`:
```go
{{- $value := onepasswordRead "op://AstroCapital/Infrastructure/field_name" -}}
```

In shell scripts (runtime):
```bash
op read "op://AstroCapital/Infrastructure/field_name"
```

### Available Infrastructure Variables

These are defined in `.chezmoi.toml.tmpl` and available in all `.tmpl` files:

```go
{{ .infra.aws_account_id }}      // AWS account ID
{{ .infra.aws_route53_zone_id }} // Route53 hosted zone ID
{{ .infra.aws_iam_role }}        // IAM role ARN
{{ .infra.vpn_host }}            // VPN hostname
{{ .infra.vpn_port }}            // VPN SSH port
{{ .infra.vault_url }}           // HashiCorp Vault URL
{{ .infra.docker_registry }}     // Docker registry hostname
{{ .infra.internal_ip }}         // Internal server IP
{{ .infra.internal_port }}       // Internal service port
{{ .infra.base_domain }}         // Base domain for services
```

### Adding New Secrets

When you need to add a new secret:

1. **Add to 1Password** (user action):
   ```bash
   op item edit Infrastructure --vault AstroCapital "new_field=value"
   ```

2. **Update `.chezmoi.toml.tmpl`**:
   ```go
   {{- $newField := "default-value" -}}
   {{- if $opSignedIn -}}
   {{-   $newField = onepasswordRead "op://AstroCapital/Infrastructure/new_field" -}}
   {{- end -}}

   # In [data.infra] section:
   new_field = {{ $newField | quote }}
   ```

3. **Update `.chezmoidata.yaml`** (safe defaults):
   ```yaml
   infra:
     new_field: "placeholder-value"
   ```

4. **Use in templates**:
   ```go
   {{ .infra.new_field }}
   ```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Hostnames | `snake_case` with `_host` suffix | `vpn_host`, `db_host` |
| Ports | `snake_case` with `_port` suffix | `vpn_port`, `api_port` |
| URLs | `snake_case` with `_url` suffix | `vault_url`, `api_url` |
| AWS IDs | `aws_` prefix | `aws_account_id`, `aws_route53_zone_id` |
| IPs | `_ip` suffix | `internal_ip`, `gateway_ip` |
| Credentials | Use 1Password references directly, don't store in chezmoi |

## File Conventions

### Chezmoi Naming

| Prefix/Suffix | Meaning |
|---------------|---------|
| `dot_` | File starts with `.` (e.g., `dot_zshrc` → `.zshrc`) |
| `private_` | File has restricted permissions (600) |
| `executable_` | File is executable (755) |
| `.tmpl` | File is a Go template |
| `run_once_` | Script runs once per machine |
| `run_` | Script runs on every apply |

### Template Files

Files ending in `.tmpl` are processed by chezmoi. Common patterns:

```go
// Conditional blocks
{{ if eq .chezmoi.os "darwin" }}
# macOS specific
{{ else if eq .chezmoi.os "linux" }}
# Linux specific
{{ end }}

// Using infrastructure secrets
ssh -p {{ .infra.vpn_port }} user@{{ .infra.vpn_host }}

// String operations
{{ .infra.base_domain | upper }}
```

## Common Tasks

### Adding a New Config File

```bash
# Add existing file to chezmoi
chezmoi add ~/.config/app/config.toml

# If it needs templating, rename it
mv dot_config/app/config.toml dot_config/app/config.toml.tmpl
```

### Testing Templates

```bash
# Test template rendering
chezmoi execute-template '{{ .infra.vpn_host }}'

# Preview what would be written
chezmoi diff

# Apply changes
chezmoi apply
```

### Refreshing Secrets

```bash
# Re-read from 1Password
chezmoi init --force
chezmoi apply
```

## Security Guidelines

1. **Never commit real values** - Use templates with 1Password references
2. **Check before committing** - Run `git diff` and look for IPs, passwords, tokens
3. **Use .chezmoidata.yaml for defaults** - Safe placeholder values only
4. **Grep for sensitive patterns** before pushing:
   ```bash
   git diff --cached | grep -E "(password|secret|token|[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)"
   ```

## Keyboard Layout Note

This config uses **Graphite** layout. Navigation in vim/tmux/etc:
```
y = left    h = down    a = up    e = right
j = end-of-word    l = append    ' = yank
```

## Useful Commands

```bash
# CLI wrapper
./cli install|reinstall|uninstall|status|help

# Chezmoi operations
chezmoi diff              # Preview changes
chezmoi apply             # Apply changes
chezmoi edit ~/.zshrc     # Edit managed file
chezmoi data              # Show all template data
chezmoi doctor            # Diagnose issues

# 1Password operations
op signin                 # Sign in
op item list --vault AstroCapital  # List items
op item get Infrastructure --vault AstroCapital  # View item
```

## Conda Environment Management

The `cli env` command manages a blue-green conda environment at `/opt/conda/envs/`. This is the primary development environment ("acap") containing Python, Node.js, Rust, and all project dependencies.

### Architecture

```
/opt/conda/                              # miniconda base (system-wide)
/opt/conda/envs/
  acap-20260203-120000/                  # timestamped actual env
  acap-20260210-040000/                  # newer env
  prod -> acap-20260210-040000           # symlink (atomic swap)
  .prod-previous                         # records prior target for rollback
```

Shell activation: `conda activate /opt/conda/envs/prod` (in each user's `.bashrc`).
The symlink lets builds complete and validate before activation takes effect.
The env is **shared across all users** on a host — there is one `prod` symlink, not per-user.

### Commands

| Command | Purpose |
|---------|---------|
| `cli env build` | Create a new timestamped env, validate it, atomically swap the `prod` symlink, clean up envs older than 30 days |
| `cli env status` | Show current `prod` target, Python/Node/uv versions, list all available envs |
| `cli env rollback` | Revert `prod` symlink to the previously recorded env |
| `cli env nuke` | Remove **all** `acap-*` envs and the `prod` symlink, then rebuild from scratch |
| `cli env install-timer` | Install a systemd user timer for weekly auto-rebuild (Sun 04:00) |

### What gets installed

The build pipeline runs in this order:

1. **Conda packages** (`env/config/conda-packages.txt`) -- `conda create -p <prefix> -c conda-forge --channel-priority strict`
   Core runtime: `python=3.11`, `nodejs`, `rust`, `uv`. Terminal utilities: `bat`, `ripgrep`, `fzf`, `zoxide`, `git-delta`, `eza`, `lazygit`, `tmux`, `neovim`. Plus scientific/dev/finance packages.

2. **Pip packages** (`env/config/pip-packages.txt`) -- `uv pip install --python <prefix>/bin/python`
   Packages that aren't on conda-forge (finance APIs, quant libs, etc.). Also includes `awscli`.

3. **NPM tools** (`env/config/npm-tools.txt`) -- `npm install -g` within the env
   `@openai/codex`, `wrangler`.

4. **Custom-index pip packages** (`env/config/pip-custom-indexes.sh`)
   Bloomberg `blpapi` from the private Bloomberg pip index (fails gracefully outside the Bloomberg network).

5. **Standalone CLI binaries** (`env/lib/cli-tools.sh`) -- downloaded into `<prefix>/bin/`
   `gh`, `kubectl`, `argocd`, `helm`, `aliyun`, `yazi`, `sesh`, `twm`, `oh-my-posh`.

6. **System-level tools** -- installed outside the env, available on system PATH
   `op` (1Password CLI, via `cli prereq`), `claude` (Claude Code, native standalone binary at `~/.local/bin/claude`).


### Adding or removing packages

- **Conda package**: edit `env/config/conda-packages.txt`, one package per line.
- **Pip package**: edit `env/config/pip-packages.txt`, one package per line.
- **NPM tool**: edit `env/config/npm-tools.txt`, one scoped-or-bare package per line.
- **Standalone binary**: add an `_install_<name>` function to `env/lib/cli-tools.sh` and call it from `install_cli_tools`.

After editing, run `cli env build` to create a fresh env with the changes. The previous env remains available for rollback.

### Cleanup policy

After every successful build, `_env_cleanup` (in `cli`) removes `acap-*` directories older than 30 days. The current `prod` target and the previous env (for rollback) are always preserved regardless of age.

### Validation

`env/lib/validate.sh` checks:
- Python is 3.11.x
- Critical imports: `pandas`, `numpy`, `scipy`, `sqlalchemy`, `loguru`
- `uv`, `node` binaries present
- NPM tools present (`codex`, `wrangler`)
- Terminal utilities present (`bat`, `rg`, `fzf`, `zoxide`, `delta`, `eza`, `lazygit`, `tmux`, `nvim`)
- Standalone CLI tools present (`gh`, `kubectl`, `argocd`, `helm`, `aliyun`, `aws`, `yazi`, `sesh`, `twm`, `oh-my-posh`)
- `op` available on system PATH

If validation fails, the new env is deleted and the `prod` symlink is **not** swapped.

### Key files

```
~/.files/
  cli                                    # main entry point — cmd_env and _env_cleanup live here
  env/
    config/
      conda-packages.txt                 # conda-forge packages
      pip-packages.txt                   # pip packages (installed via uv)
      npm-tools.txt                      # npm global tools
      pip-custom-indexes.sh              # private-index pip installs
    lib/
      build.sh                           # build_env() — orchestrates install steps
      validate.sh                        # validate_env() — post-build checks
      cli-tools.sh                       # install_cli_tools() — standalone binary downloads
    auto-upgrade.service                 # systemd oneshot for cli env build
    auto-upgrade.timer                   # weekly timer (Sun 04:00)
    deploy-host.sh                       # full host deployment (miniconda + env + user bashrc)
    setup-bashrc.sh                      # inject conda init block into each user's bashrc
```

### Multi-host deployment

The env is shared by all users on a given host. `/opt` must be owned by `peter`.

To deploy to a remote host (e.g. `acap-admin` at `52.221.6.72`):

```bash
# 1. Sync dotfiles to remote
rsync -avz --delete --exclude='.git' ~/.files/ acap-admin:~/.files/

# 2. Run deploy (installs miniconda if missing, builds env, fixes permissions)
ssh acap-admin 'export CONDA_DEFAULT_ENV="" CONDA_PREFIX="" CONDA_SHLVL=0 \
  PATH="/opt/conda/bin:$PATH" && bash ~/.files/env/deploy-host.sh'

# 3. Set up user bashrc files (requires sudo)
ssh acap-admin 'echo "<password>" | sudo -S true 2>/dev/null \
  && bash ~/.files/env/setup-bashrc.sh'
```

`deploy-host.sh` is safe to re-run: it skips miniconda install if `/opt/conda` already exists.
`setup-bashrc.sh` is idempotent: it only appends the conda block if not already present.

## Related Documentation

- `README.md` - User-facing documentation
- `docs/secrets-management.md` - Detailed secrets guide
- `.chezmoi.toml.tmpl` - Template configuration source
- `.chezmoidata.yaml` - Default values reference
