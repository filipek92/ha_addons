#!/bin/bash

# Test funkce update_readme
set -e

# Barvy pro výstup
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
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

# Funkce pro získání názvu addonu z cesty
get_addon_name() {
    local repo_path="$1"
    if [[ -f "$repo_path/config.yaml" ]]; then
        grep "^name:" "$repo_path/config.yaml" | sed 's/name: *//g' | tr -d '"' | tr -d "'"
    else
        echo "$(basename "$repo_path")"
    fi
}

# Funkce pro získání popisu addonu
get_addon_description() {
    local repo_path="$1"
    if [[ -f "$repo_path/config.yaml" ]]; then
        grep "^description:" "$repo_path/config.yaml" | sed 's/description: *//g' | tr -d '"' | tr -d "'"
    else
        echo "Home Assistant Add-on"
    fi
}

# Funkce pro získání všech submodulů
get_all_submodules() {
    git config --file .gitmodules --get-regexp path | awk '{print $2}'
}

# Funkce pro aktualizaci README s tabulkou verzí
update_readme() {
    local -A addon_versions=()
    local -A addon_descriptions=()
    
    # Získat všechny submoduly a jejich informace
    while IFS= read -r submodule_path; do
        if [[ -n "$submodule_path" ]]; then
            local addon_name=$(get_addon_name "$submodule_path")
            local version=$(get_version_from_config "$submodule_path/config.yaml")
            local description=$(get_addon_description "$submodule_path")
            
            addon_versions["$addon_name"]="$version"
            addon_descriptions["$addon_name"]="$description"
        fi
    done <<< "$(get_all_submodules)"
    
    # Vytvořit tabulku verzí
    local version_table="## Aktuální verze

| Add-on | Verze | Popis |
|--------|-------|-------|"
    
    for addon_name in "${!addon_versions[@]}"; do
        version_table+="
| $addon_name | ${addon_versions[$addon_name]} | ${addon_descriptions[$addon_name]} |"
    done
    
    # Vytvořit nový README bez existujících sekcí "Aktuální verze"
    local temp_file=$(mktemp)
    local skip_version_section=false
    
    while IFS= read -r line; do
        # Začátek sekce "Aktuální verze" - začneme přeskakovat
        if [[ "$line" =~ ^##[[:space:]]*Aktuální[[:space:]]*verze ]]; then
            skip_version_section=true
            continue
        fi
        
        # Pokud jsme v sekci "Aktuální verze" a najdeme další sekci, skončíme přeskakování
        if [[ "$skip_version_section" == true ]] && [[ "$line" =~ ^##[[:space:]]+ ]]; then
            skip_version_section=false
            # Vložit novou tabulku verzí před tuto sekci
            echo "$version_table"
            echo ""
            echo "$line"
            continue
        fi
        
        # Pokud nepřeskakujeme sekci verzí, zapsat řádek
        if [[ "$skip_version_section" == false ]]; then
            echo "$line"
        fi
    done < README.md > "$temp_file"
    
    mv "$temp_file" README.md
    log_success "README.md aktualizováno s novými verzemi"
}

# Spustit test
update_readme
