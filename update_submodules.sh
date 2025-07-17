#!/bin/bash

# Skript pro aktualizaci submodulů a README s aktuálními verzemi
# Autor: Filip Richter
# Použití: ./update_submodules.sh [--auto-push]
#   --auto-push: Automaticky pushovat změny bez dotazu

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

# Parametry
AUTO_PUSH=false
FORCE_UPDATE=false

# Zpracování parametrů
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto-push)
            AUTO_PUSH=true
            shift
            ;;
        --force-update)
            FORCE_UPDATE=true
            shift
            ;;
        -h|--help)
            echo "Použití: $0 [--auto-push] [--force-update]"
            echo "  --auto-push: Automaticky pushovat změny bez dotazu"
            echo "  --force-update: Vynutit aktualizaci README i bez změn submodulů"
            echo "  -h, --help: Zobrazit tuto nápovědu"
            exit 0
            ;;
        *)
            log_error "Neznámý parametr: $1"
            echo "Použijte --help pro nápovědu"
            exit 1
            ;;
    esac
done

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

# Hlavní funkce
main() {
    log_info "Začíná aktualizace submodulů..."
    
    # Ověřit, že jsme v git repozitáři
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Není to git repozitář!"
        exit 1
    fi
    
    # Zkontrolovat, zda nejsou nepushnuté změny
    local unpushed_commits=$(git log origin/main..HEAD --oneline 2>/dev/null | wc -l)
    if [[ $unpushed_commits -gt 0 ]]; then
        log_warning "Máte $unpushed_commits nepushnutých commitů"
        echo
        read -p "Chcete nejdříve pushovat existující změny? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push origin main
            log_success "Existující změny byly pushnuty"
        fi
        echo
    fi
    
    # Uložit aktuální commit hashe submodulů před aktualizací
    log_info "Ukládám aktuální stav submodulů..."
    declare -A before_commits=()
    
    while IFS= read -r submodule_path; do
        if [[ -n "$submodule_path" ]]; then
            before_commits["$submodule_path"]=$(git submodule status "$submodule_path" | cut -c2-41)
        fi
    done <<< "$(get_all_submodules)"
    
    # Aktualizovat submoduly
    log_info "Aktualizuji submoduly..."
    git submodule update --remote --merge
    
    # Pole pro ukládání aktualizovaných addonů
    declare -a updated_addons=()
    
    # Zkontrolovat, které submoduly byly aktualizovány
    while IFS= read -r submodule_path; do
        if [[ -n "$submodule_path" ]]; then
            local after_commit=$(git submodule status "$submodule_path" | cut -c2-41)
            local before_commit="${before_commits[$submodule_path]}"
            
            if [[ "$before_commit" != "$after_commit" ]]; then
                local addon_name=$(get_addon_name "$submodule_path")
                log_info "$addon_name byl aktualizován ($before_commit -> $after_commit)"
                updated_addons+=("$addon_name")
            fi
        fi
    done <<< "$(get_all_submodules)"
    
    # Pokud nebyly žádné změny, skončit (pokud není --force-update)
    if [[ ${#updated_addons[@]} -eq 0 ]]; then
        if [[ "$FORCE_UPDATE" == true ]]; then
            log_info "Žádné submoduly nebyly aktualizovány, ale vynucuji aktualizaci README"
        else
            log_info "Žádné submoduly nebyly aktualizovány"
            return 0
        fi
    fi
    
    # Zobrazit aktuální verze všech addonů
    log_info "Aktuální verze addonů:"
    declare -A current_versions=()
    
    while IFS= read -r submodule_path; do
        if [[ -n "$submodule_path" ]]; then
            local addon_name=$(get_addon_name "$submodule_path")
            local version=$(get_version_from_config "$submodule_path/config.yaml")
            current_versions["$addon_name"]="$version"
            log_info "  $addon_name: $version"
        fi
    done <<< "$(get_all_submodules)"
    
    # Aktualizovat README pouze pokud byly změny
    update_readme
    
    # Zkontrolovat, zda jsou nějaké změny k commitnutí
    if git diff --quiet && git diff --cached --quiet; then
        log_info "Žádné změny k commitnutí"
        return 0
    fi
    
    # Přidat změny do indexu
    git add .
    
    # Vytvořit commit zprávu
    if [[ ${#updated_addons[@]} -gt 0 ]]; then
        local commit_message="Aktualizace submodulů - aktualizovány: $(IFS=', '; echo "${updated_addons[*]}")"
    else
        local commit_message="Aktualizace README s aktuálními verzemi"
    fi
    
    commit_message="$commit_message

Aktuální verze:"
    
    for addon_name in "${!current_versions[@]}"; do
        commit_message="$commit_message
- $addon_name: ${current_versions[$addon_name]}"
    done
    
    # Vytvořit commit
    git commit -m "$commit_message"
    
    log_success "Commit vytvořen s následující zprávou:"
    echo "$commit_message"
    
    # Zeptat se, zda má pushovat změny (pokud není --auto-push)
    echo
    if [[ "$AUTO_PUSH" == true ]]; then
        git push origin main
        log_success "Změny byly automaticky pushnuty do remote repozitáře"
    else
        read -p "Chcete pushovat změny do remote repozitáře? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push origin main
            log_success "Změny byly pushnuty do remote repozitáře"
        else
            log_warning "Změny nebyly pushnuty. Můžete je pushovat později pomocí: git push origin main"
            log_warning "Nebo spusťte skript s parametrem --auto-push pro automatické pushování"
        fi
    fi
}

# Spustit hlavní funkci
main "$@"
