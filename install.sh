#!/usr/bin/env bash
set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Function to print colored messages
print_banner() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         Too Many Cooks - OpenCode Agent Installer          ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${BLUE}➜${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Main installation script
main() {
    print_banner

    # Get the directory where this script is located
    readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    readonly CONFIG_DIR="${HOME}/.config/opencode"
    readonly BACKUP_DIR="${CONFIG_DIR}/backup-$(date +%Y%m%d-%H%M%S)"

    # Step 1: Create config directory if it doesn't exist
    print_step "Creating config directory..."
    mkdir -p "${CONFIG_DIR}"
    mkdir -p "${CONFIG_DIR}/agent"
    mkdir -p "${CONFIG_DIR}/skills"
    print_success "Config directory ready: ${CONFIG_DIR}"

    # Step 2: Backup existing configuration
    print_step "Checking for existing configuration..."
    local has_existing=false
    [[ -f "${CONFIG_DIR}/opencode.json" ]] && has_existing=true
    [[ -n "$(ls -A "${CONFIG_DIR}/agent" 2>/dev/null)" ]] && has_existing=true
    [[ -n "$(ls -A "${CONFIG_DIR}/skills" 2>/dev/null)" ]] && has_existing=true

    if [[ "${has_existing}" == true ]]; then
        mkdir -p "${BACKUP_DIR}"
        print_warning "Backing up existing configuration to ${BACKUP_DIR}"

        if [[ -f "${CONFIG_DIR}/opencode.json" ]]; then
            cp "${CONFIG_DIR}/opencode.json" "${BACKUP_DIR}/"
            print_success "Backed up opencode.json"
        fi

        if [[ -n "$(ls -A "${CONFIG_DIR}/agent" 2>/dev/null)" ]]; then
            mkdir -p "${BACKUP_DIR}/agent"
            cp -r "${CONFIG_DIR}/agent"/* "${BACKUP_DIR}/agent/"
            print_success "Backed up agent files"
        fi

        if [[ -n "$(ls -A "${CONFIG_DIR}/skills" 2>/dev/null)" ]]; then
            mkdir -p "${BACKUP_DIR}/skills"
            cp -r "${CONFIG_DIR}/skills"/* "${BACKUP_DIR}/skills/"
            print_success "Backed up skill files"
        fi
    else
        print_success "No existing configuration found"
    fi

    # Step 3: Install agent files
    print_step "Installing agent files..."
    local agent_source_dir
    local agent_dest_dir
    agent_source_dir="${SCRIPT_DIR}/agent"
    agent_dest_dir="${CONFIG_DIR}/agent"

    if [[ -d "${agent_source_dir}" ]]; then
        local agent_count=0
        for agent_file in "${agent_source_dir}"/*.md; do
            if [[ -f "${agent_file}" ]]; then
                local filename
                filename=$(basename "${agent_file}")
                cp "${agent_file}" "${agent_dest_dir}/${filename}"
                echo -e "  ${CYAN}→${NC} ${filename}"
                ((agent_count++)) || true
            fi
        done
        print_success "Installed ${agent_count} agent file(s)"
    else
        print_error "Agent source directory not found: ${agent_source_dir}"
        exit 1
    fi

    # Step 4: Install skill files
    print_step "Installing skill files..."
    local skills_source_dir="${SCRIPT_DIR}/skills"
    local skills_dest_dir="${CONFIG_DIR}/skills"

    if [[ -d "${skills_source_dir}" ]]; then
        local skill_count=0
        for skill_dir in "${skills_source_dir}"/*/; do
            if [[ -d "${skill_dir}" ]] && [[ -f "${skill_dir}/SKILL.md" ]]; then
                local skill_name
                skill_name=$(basename "${skill_dir}")
                mkdir -p "${skills_dest_dir}/${skill_name}"
                cp "${skill_dir}/SKILL.md" "${skills_dest_dir}/${skill_name}/SKILL.md"
                echo -e "  ${CYAN}→${NC} ${skill_name}"
                ((skill_count++)) || true
            fi
        done

        if [[ ${skill_count} -eq 0 ]]; then
            print_success "No skills found to install (add skills to ${skills_source_dir}/<name>/SKILL.md)"
        else
            print_success "Installed ${skill_count} skill(s)"
        fi
    else
        print_warning "Skills source directory not found, skipping"
    fi

    # Step 5: Merge or create opencode.json
    print_step "Processing opencode.json..."
    local source_config="${SCRIPT_DIR}/opencode.json"
    local target_config="${CONFIG_DIR}/opencode.json"

    if [[ ! -f "${source_config}" ]]; then
        print_error "Source opencode.json not found: ${source_config}"
        exit 1
    fi

    if [[ -f "${target_config}" ]]; then
        # Merge existing config with new config
        print_warning "Merging with existing configuration..."

        # Check if jq is available
        if command -v jq &> /dev/null; then
            # Merge using jq - deep merge with preference for source config values
            jq -s '.[0] * .[1]' "${target_config}" "${source_config}" > "${target_config}.tmp"
            mv "${target_config}.tmp" "${target_config}"
            print_success "Merged configuration using jq"
        else
            # Fallback: show warning and append
            print_warning "jq not found - cannot safely merge JSON files"
            print_warning "Installing new configuration but backing up your original"
            cp "${source_config}" "${target_config}"
            print_warning "Please manually restore settings from ${BACKUP_DIR}/opencode.json if needed"
        fi
    else
        # No existing config, just copy
        cp "${source_config}" "${target_config}"
        print_success "Created new opencode.json"
    fi

    # Step 6: Summary
    echo ""
    print_banner
    echo -e "${GREEN}Installation complete!${NC}"
    echo ""
    echo -e "The following files have been installed:"
    echo -e "  • Agent files: ${CYAN}${agent_dest_dir}/*${NC}"
    echo -e "  • Skill files: ${CYAN}${skills_dest_dir}/*${NC}"
    echo -e "  • Config file: ${CYAN}${target_config}${NC}"
    echo ""
    if [[ -d "${BACKUP_DIR}" ]]; then
        echo -e "Backup created at: ${CYAN}${BACKUP_DIR}${NC}"
        echo ""
    fi
    echo -e "To use the Too Many Cooks agents, run OpenCode as normal."
    echo -e "The build and plan agents have been disabled in the configuration."
    echo ""
}

# Run main function
main "$@"
