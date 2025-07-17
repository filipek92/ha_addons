#!/bin/bash

# Skript pro kontrolu aktuálních verzí submodulů
# Autor: Filip Richter
# Použití: ./check_versions.sh

set -e

# Barvy pro výstup
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funkce pro získání verze z config.yaml
get_version_from_config() {
    local config_path="$1"
    if [[ -f "$config_path" ]]; then
        grep "^version:" "$config_path" | sed 's/version: *//g' | tr -d '"' | tr -d "'"
    else
        echo "unknown"
    fi
}

# Funkce pro získání posledního tagu z git repozitáře
get_latest_git_tag() {
    local repo_path="$1"
    if [[ -e "$repo_path/.git" ]]; then
        (cd "$repo_path" && git describe --tags --abbrev=0 2>/dev/null || echo "no-tags")
    else
        echo "no-git"
    fi
}

# Funkce pro získání aktuálního commit hash
get_current_commit() {
    local repo_path="$1"
    if [[ -e "$repo_path/.git" ]]; then
        (cd "$repo_path" && git rev-parse --short HEAD)
    else
        echo "no-git"
    fi
}

# Funkce pro získání názvu addonu z cesty
get_addon_name() {
    local repo_path="$1"
    if [[ -f "$repo_path/config.yaml" ]]; then
        grep "^name:" "$repo_path/config.yaml" | sed 's/name: *//g' | tr -d '"' | tr -d "'"
    else
        echo "$(basename "$repo_path")"
    fi
}

# Funkce pro získání všech submodulů
get_all_submodules() {
    git config --file .gitmodules --get-regexp path | awk '{print $2}'
}

echo -e "${BLUE}=== Kontrola verzí Home Assistant Add-onů ===${NC}"
echo

# Projít všechny submoduly
while IFS= read -r submodule_path; do
    if [[ -n "$submodule_path" ]]; then
        addon_name=$(get_addon_name "$submodule_path")
        
        echo -e "${GREEN}$addon_name (${submodule_path}):${NC}"
        
        config_version=$(get_version_from_config "$submodule_path/config.yaml")
        latest_tag=$(get_latest_git_tag "$submodule_path")
        current_commit=$(get_current_commit "$submodule_path")
        
        echo "  Config verze: $config_version"
        echo "  Poslední tag: $latest_tag"
        echo "  Aktuální commit: $current_commit"
        echo
    fi
done <<< "$(get_all_submodules)"

# Zobrazit stav submodulů
echo -e "${YELLOW}Stav submodulů:${NC}"
git submodule status

echo
echo -e "${BLUE}=== Konec kontroly ===${NC}"
