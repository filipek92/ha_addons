#!/bin/bash

# Skript pro aktualizaci submodulů a README s aktuálními verzemi
# Autor: Filip Richter
# Použití: ./update_submodules.sh

set -e

# Barvy pro výstup
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funkce pro výpis barevných zpráv
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Funkce pro získání verze z config.yaml
get_version_from_config() {
    local config_path="$1"
    if [[ -f "$config_path" ]]; then
        grep "^version:" "$config_path" | sed 's/version: *//g' | tr -d '"' | tr -d "'"
    else
        echo "unknown"
    fi
}

# Funkce pro aktualizaci README s tabulkou verzí
update_readme() {
    local power_stream_version="$1"
    local ingress_proxy_version="$2"
    
    # Vytvořit tabulku verzí
    local version_table="## Aktuální verze

| Add-on | Verze | Popis |
|--------|-------|-------|
| PowerStreamPlan | $power_stream_version | Inteligentní plánovač a optimalizátor pro energetickou produkci a spotřebu |
| Ingress Proxy | $ingress_proxy_version | Proxy server pro přístup k lokálním zařízením v síti |"

    # Najít pozici pro vložení tabulky (po sekci Instalace)
    local temp_file=$(mktemp)
    local in_addons_section=false
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^##[[:space:]]*Add-ony ]]; then
            # Vložit tabulku verzí před sekci Add-ony
            echo "$version_table"
            echo ""
            in_addons_section=true
        fi
        
        # Pokud jsme v sekci Add-ony, přeskočit původní obsah až do další sekce
        if [[ "$in_addons_section" == true ]]; then
            if [[ "$line" =~ ^##[[:space:]]*(?!Add-ony) ]] || [[ "$line" =~ ^##[[:space:]]*Přidání[[:space:]]*nového[[:space:]]*add-onu ]]; then
                in_addons_section=false
                echo "$line"
            fi
        else
            echo "$line"
        fi
    done < README.md > "$temp_file"
    
    mv "$temp_file" README.md
    log_success "README.md aktualizováno s novými verzemi"
}

# Hlavní funkce
main() {
    log_info "Začíná aktualizace submodulů..."
    
    # Ověřit, že jsme v git repozitáři
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Není to git repozitář!"
        exit 1
    fi
    
    # Uložit aktuální commit hashe submodulů před aktualizací
    log_info "Ukládám aktuální stav submodulů..."
    local before_power_stream=$(git submodule status power_stream_plan | cut -c2-41)
    local before_ingress_proxy=$(git submodule status ingress-proxy | cut -c2-41)
    
    # Aktualizovat submoduly
    log_info "Aktualizuji submoduly..."
    git submodule update --remote --merge
    
    # Získat nové commit hashe
    local after_power_stream=$(git submodule status power_stream_plan | cut -c2-41)
    local after_ingress_proxy=$(git submodule status ingress-proxy | cut -c2-41)
    
    # Pole pro ukládání aktualizovaných addonů
    declare -a updated_addons=()
    
    # Zkontrolovat, které submoduly byly aktualizovány
    if [[ "$before_power_stream" != "$after_power_stream" ]]; then
        log_info "PowerStreamPlan byl aktualizován ($before_power_stream -> $after_power_stream)"
        updated_addons+=("power_stream_plan")
    fi
    
    if [[ "$before_ingress_proxy" != "$after_ingress_proxy" ]]; then
        log_info "Ingress Proxy byl aktualizován ($before_ingress_proxy -> $after_ingress_proxy)"
        updated_addons+=("ingress-proxy")
    fi
    
    # Získat aktuální verze z config.yaml souborů
    local power_stream_version=$(get_version_from_config "power_stream_plan/config.yaml")
    local ingress_proxy_version=$(get_version_from_config "ingress-proxy/config.yaml")
    
    log_info "PowerStreamPlan verze: $power_stream_version"
    log_info "Ingress Proxy verze: $ingress_proxy_version"
    
    # Aktualizovat README
    update_readme "$power_stream_version" "$ingress_proxy_version"
    
    # Zkontrolovat, zda jsou nějaké změny k commitnutí
    if git diff --quiet && git diff --cached --quiet; then
        log_info "Žádné změny k commitnutí"
        return 0
    fi
    
    # Přidat změny do indexu
    git add .
    
    # Vytvořit commit zprávu
    local commit_message="Aktualizace submodulů"
    if [[ ${#updated_addons[@]} -gt 0 ]]; then
        commit_message="$commit_message - aktualizovány: $(IFS=', '; echo "${updated_addons[*]}")"
    fi
    commit_message="$commit_message

Aktuální verze:
- PowerStreamPlan: $power_stream_version
- Ingress Proxy: $ingress_proxy_version"
    
    # Vytvořit commit
    git commit -m "$commit_message"
    
    log_success "Commit vytvořen s následující zprávou:"
    echo "$commit_message"
    
    # Zeptat se, zda má pushovat změny
    echo
    read -p "Chcete pushovat změny do remote repozitáře? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push origin main
        log_success "Změny byly pushnuty do remote repozitáře"
    else
        log_warning "Změny nebyly pushnuty. Můžete je pushovat později pomocí: git push origin main"
    fi
}

# Spustit hlavní funkci
main "$@"
