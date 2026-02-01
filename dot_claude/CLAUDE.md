# AI Development Environment

This document provides context for AI coding assistants (Claude, etc.) working with this dotfiles repository.

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

## Related Documentation

- `README.md` - User-facing documentation
- `docs/secrets-management.md` - Detailed secrets guide
- `.chezmoi.toml.tmpl` - Template configuration source
- `.chezmoidata.yaml` - Default values reference
