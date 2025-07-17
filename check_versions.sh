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

echo -e "${BLUE}=== Kontrola verzí Home Assistant Add-onů ===${NC}"
echo

# Získat informace o PowerStreamPlan
echo -e "${GREEN}PowerStreamPlan:${NC}"
power_stream_version=$(get_version_from_config "power_stream_plan/config.yaml")
power_stream_tag=$(get_latest_git_tag "power_stream_plan")
power_stream_commit=$(get_current_commit "power_stream_plan")

echo "  Config verze: $power_stream_version"
echo "  Poslední tag: $power_stream_tag"
echo "  Aktuální commit: $power_stream_commit"
echo

# Získat informace o Ingress Proxy
echo -e "${GREEN}Ingress Proxy:${NC}"
ingress_proxy_version=$(get_version_from_config "ingress-proxy/config.yaml")
ingress_proxy_tag=$(get_latest_git_tag "ingress-proxy")
ingress_proxy_commit=$(get_current_commit "ingress-proxy")

echo "  Config verze: $ingress_proxy_version"
echo "  Poslední tag: $ingress_proxy_tag"
echo "  Aktuální commit: $ingress_proxy_commit"
echo

# Zobrazit stav submodulů
echo -e "${YELLOW}Stav submodulů:${NC}"
git submodule status

echo
echo -e "${BLUE}=== Konec kontroly ===${NC}"
