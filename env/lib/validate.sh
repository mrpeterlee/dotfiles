#!/usr/bin/env bash
# validate.sh — Validation function for conda env
# Sourced by cli; do not run directly.

validate_env() {
    local prefix="$1"
    local env_python="${prefix}/bin/python"
    local failed=0

    info "Validating environment at ${prefix}..."

    # Check Python version is 3.11.x
    if [[ -x "$env_python" ]]; then
        local py_version
        py_version=$("$env_python" --version 2>&1)
        if [[ "$py_version" == *"3.11"* ]]; then
            success "Python: ${py_version}"
        else
            error "Python version mismatch: ${py_version} (expected 3.11.x)"
            failed=1
        fi
    else
        error "Python not found at ${env_python}"
        failed=1
    fi

    # Check critical Python imports
    local -a critical_imports=(pandas numpy scipy sqlalchemy loguru)
    for mod in "${critical_imports[@]}"; do
        if "$env_python" -c "import ${mod}" 2>/dev/null; then
            success "import ${mod}"
        else
            error "import ${mod} failed"
            failed=1
        fi
    done

    # Check uv
    local env_uv="${prefix}/bin/uv"
    if [[ -x "$env_uv" ]]; then
        success "uv: $("$env_uv" --version 2>&1)"
    else
        error "uv not found at ${env_uv}"
        failed=1
    fi

    # Check node
    local env_node="${prefix}/bin/node"
    if [[ -x "$env_node" ]]; then
        success "node: $("$env_node" --version 2>&1)"
    else
        error "node not found at ${env_node}"
        failed=1
    fi

    # Check all CLI tools expected in the env
    local -a env_cli_tools=(codex wrangler gh kubectl argocd helm aliyun aws bat rg fzf zoxide delta eza lazygit tmux nvim yazi sesh twm oh-my-posh)
    for tool in "${env_cli_tools[@]}"; do
        if [[ -x "${prefix}/bin/${tool}" ]]; then
            success "${tool} present"
        else
            warn "${tool} not found in ${prefix}/bin/ (non-critical)"
        fi
    done

    # Check op is available system-wide (installed via cli prereq)
    if command -v op &>/dev/null; then
        success "op present (system)"
    else
        warn "op not found on system PATH (install via: cli prereq)"
    fi

    if [[ "$failed" -eq 0 ]]; then
        success "Validation passed"
        return 0
    else
        error "Validation failed"
        return 1
    fi
}
