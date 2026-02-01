#!/usr/bin/env bash
#
# Setup 1Password Infrastructure item for dotfiles secrets
#
# This script creates an "Infrastructure" item in the AstroCapital vault
# with all the fields needed by chezmoi templates.
#
# Usage:
#   ./scripts/setup-1password-secrets.sh
#
# Prerequisites:
#   - 1Password CLI installed (op)
#   - Signed in to 1Password (op signin)
#   - AstroCapital vault exists
#
set -euo pipefail

VAULT="AstroCapital"
ITEM="Infrastructure"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

info() { echo -e "${BLUE}==>${RESET} $*"; }
success() { echo -e "${GREEN}✓${RESET} $*"; }
warn() { echo -e "${YELLOW}!${RESET} $*"; }
error() { echo -e "${RED}✗${RESET} $*" >&2; exit 1; }

# Check prerequisites
command -v op &>/dev/null || error "1Password CLI (op) not found. Install it first."
op account list &>/dev/null || error "Not signed in to 1Password. Run 'op signin' first."

# Check if vault exists
if ! op vault get "$VAULT" &>/dev/null; then
    error "Vault '$VAULT' not found. Create it first in 1Password."
fi

# Check if item already exists
if op item get "$ITEM" --vault "$VAULT" &>/dev/null; then
    warn "Item '$ITEM' already exists in vault '$VAULT'."
    read -p "Update it with new values? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    UPDATE=true
else
    UPDATE=false
fi

echo ""
echo -e "${BLUE}Setting up Infrastructure secrets in 1Password${RESET}"
echo "────────────────────────────────────────────────"
echo ""
echo "Enter your infrastructure values (press Enter to skip/keep default):"
echo ""

# Prompt for values
read -p "AWS Account ID [e.g., 123456789012]: " aws_account_id
read -p "AWS Route53 Zone ID [e.g., ZXXXXXXXXXXXXX]: " aws_route53_zone_id
read -p "AWS IAM Role ARN [e.g., arn:aws:iam::123456789012:role/MyRole]: " aws_iam_role
read -p "VPN Hostname [e.g., vpn.company.com]: " vpn_host
read -p "VPN Port [default: 55555]: " vpn_port
read -p "Vault URL [e.g., https://vault.company.com]: " vault_url
read -p "Docker Registry [e.g., registry.company.com]: " docker_registry
read -p "Internal IP [e.g., 10.1.1.100]: " internal_ip
read -p "Internal Port [default: 8080]: " internal_port
read -p "Base Domain [e.g., company.com]: " base_domain

# Set defaults
vpn_port="${vpn_port:-55555}"
internal_port="${internal_port:-8080}"

echo ""
info "Creating/updating 1Password item..."

if $UPDATE; then
    # Update existing item
    op item edit "$ITEM" --vault "$VAULT" \
        "aws_account_id=${aws_account_id}" \
        "aws_route53_zone_id=${aws_route53_zone_id}" \
        "aws_iam_role=${aws_iam_role}" \
        "vpn_host=${vpn_host}" \
        "vpn_port=${vpn_port}" \
        "vault_url=${vault_url}" \
        "docker_registry=${docker_registry}" \
        "internal_ip=${internal_ip}" \
        "internal_port=${internal_port}" \
        "base_domain=${base_domain}" \
        >/dev/null
else
    # Create new item
    op item create --category=login --vault "$VAULT" --title "$ITEM" \
        "aws_account_id=${aws_account_id}" \
        "aws_route53_zone_id=${aws_route53_zone_id}" \
        "aws_iam_role=${aws_iam_role}" \
        "vpn_host=${vpn_host}" \
        "vpn_port=${vpn_port}" \
        "vault_url=${vault_url}" \
        "docker_registry=${docker_registry}" \
        "internal_ip=${internal_ip}" \
        "internal_port=${internal_port}" \
        "base_domain=${base_domain}" \
        >/dev/null
fi

echo ""
success "Infrastructure secrets saved to 1Password!"
echo ""
echo "You can now run 'chezmoi init' to regenerate your config with real values."
echo ""
echo "To verify, run:"
echo "  op item get '$ITEM' --vault '$VAULT' --format json | jq '.fields[] | {label, value}'"
echo ""
