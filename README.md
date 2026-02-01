# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Quick Start

### One-liner install (new machine)

```bash
# With 1Password (recommended)
op signin
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply MrPeterLee

# Without 1Password (uses placeholder values)
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply MrPeterLee
```

### Using the CLI

```bash
# Clone and use the CLI
git clone https://github.com/MrPeterLee/dotfiles.git
cd dotfiles

./cli install      # First-time setup
./cli reinstall    # Clean slate reinstall
./cli uninstall    # Remove all managed files
./cli status       # Show what's installed
./cli help         # Full usage guide
```

## What's Included

| Category | Tools |
|----------|-------|
| **Shell** | zsh (zinit + powerlevel10k), bash |
| **Editor** | Neovim (AstroNvim v4 + Lazy.nvim) |
| **Terminal** | WezTerm, tmux + tmuxinator |
| **Git** | lazygit, git config with aliases |
| **File Manager** | yazi |
| **Utilities** | fzf, zoxide, bat, ripgrep |

## Platform Support

- **Linux**: Debian/Ubuntu (apt), Arch (pacman), Fedora (dnf)
- **macOS**: Homebrew
- **Windows**: WSL + native (GlazeWM, Windows Terminal)

## Keyboard Layout

This config uses the **Graphite** keyboard layout (not QWERTY). Navigation keys are remapped consistently across all tools:

```
y = left    h = down    a = up    e = right
j = end-of-word    l = append    ' = yank
```

## Secrets Management

This repo uses **1Password** as the single source of truth for all infrastructure secrets. Sensitive data (IPs, hostnames, AWS credentials) are stored in 1Password and injected via chezmoi templates.

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   1Password Vault: AstroCapital             │
│                   Item: Infrastructure                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ aws_account_id, aws_route53_zone_id, aws_iam_role   │   │
│  │ vpn_host, vpn_port, vault_url, docker_registry      │   │
│  │ internal_ip, internal_port, base_domain             │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ chezmoi reads via onepasswordRead
┌─────────────────────────────────────────────────────────────┐
│  ~/.config/chezmoi/chezmoi.toml                            │
│  [data.infra]                                              │
│      aws_account_id = "real-value"                         │
│      vpn_host = "real-hostname"                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ templates use {{ .infra.* }}
┌─────────────────────────────────────────────────────────────┐
│  Final config files with real values                        │
└─────────────────────────────────────────────────────────────┘
```

### Setup 1Password Secrets

```bash
# Interactive setup (creates Infrastructure item in AstroCapital vault)
./scripts/setup-1password-secrets.sh

# Or manually create via CLI
op item create --category=login --vault AstroCapital --title Infrastructure \
    "aws_account_id=123456789012" \
    "aws_route53_zone_id=ZXXXXXXXXXXXXX" \
    "vpn_host=vpn.example.com" \
    # ... etc
```

### Template Variables

Files ending in `.tmpl` use these variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{ .infra.aws_account_id }}` | AWS account ID | `123456789012` |
| `{{ .infra.aws_route53_zone_id }}` | Route53 hosted zone | `ZXXXXXXXXXXXXX` |
| `{{ .infra.aws_iam_role }}` | IAM role ARN | `arn:aws:iam::...` |
| `{{ .infra.vpn_host }}` | VPN hostname | `vpn.company.com` |
| `{{ .infra.vpn_port }}` | VPN SSH port | `55555` |
| `{{ .infra.vault_url }}` | HashiCorp Vault URL | `https://vault.company.com` |
| `{{ .infra.docker_registry }}` | Docker registry | `registry.company.com` |
| `{{ .infra.internal_ip }}` | Internal server IP | `10.1.1.100` |
| `{{ .infra.internal_port }}` | Internal service port | `8080` |
| `{{ .infra.base_domain }}` | Base domain for services | `company.com` |

### Without 1Password

If 1Password is not available, chezmoi uses placeholder values from `.chezmoidata.yaml`. You can also create a local secrets file:

```bash
touch ~/.config/zsh/.secrets.local.zsh
chmod 600 ~/.config/zsh/.secrets.local.zsh
# Add: export API_KEY="your-key"
```

## Common Commands

```bash
# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Edit a managed file
chezmoi edit ~/.zshrc

# Add a new file to chezmoi
chezmoi add ~/.config/some/file

# Update from remote
chezmoi update

# Re-run scripts (force refresh externals)
chezmoi apply --refresh-externals

# Re-initialize with 1Password (refresh secrets)
chezmoi init --force
```

## Directory Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl      # Machine config + 1Password integration
├── .chezmoidata.yaml       # Default/placeholder values
├── .chezmoiignore          # Platform exclusions
├── .chezmoiexternal.toml   # External deps (TPM, zinit, fzf)
├── .chezmoiscripts/        # Installation scripts
├── scripts/                # Helper scripts (1Password setup)
├── dot_config/             # ~/.config/* files
├── private_dot_local/      # ~/.local/* files
└── dot_*                   # Home directory dotfiles
```

## Adding New Secrets

1. Add the field to the 1Password "Infrastructure" item
2. Update `.chezmoi.toml.tmpl` to read it
3. Add a default to `.chezmoidata.yaml`
4. Use `{{ .infra.new_field }}` in templates

See `docs/secrets-management.md` for detailed guide.
