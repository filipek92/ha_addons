# Skripty pro správu submodulů

Tento repozitář obsahuje dva užitečné skripty pro práci s Home Assistant Add-ony jako submoduly:

## Scripts

### `update_submodules.sh`

Hlavní skript pro aktualizaci submodulů a údržbu repozitáře.

**Funkce:**
- Aktualizuje všechny submoduly na nejnovější verze z remote repozitářů
- Detekuje, které submoduly byly aktualizovány
- Automaticky aktualizuje tabulku verzí v README.md
- Vytvoří commit s popisem změn
- Volitelně pushne změny do remote repozitáře

**Použití:**
```bash
./update_submodules.sh
```

**Příklad výstupu:**
```
[INFO] Začíná aktualizace submodulů...
[INFO] Ukládám aktuální stav submodulů...
[INFO] Aktualizuji submoduly...
[INFO] PowerStreamPlan byl aktualizován (44c2db0 -> a1b2c3d)
[INFO] PowerStreamPlan verze: 2.4.2
[INFO] Ingress Proxy verze: 1.0.0
[SUCCESS] README.md aktualizováno s novými verzemi
[SUCCESS] Commit vytvořen s následující zprávou:
Aktualizace submodulů - aktualizovány: power_stream_plan

Aktuální verze:
- PowerStreamPlan: 2.4.2
- Ingress Proxy: 1.0.0

Chcete pushovat změny do remote repozitáře? (y/N):
```

### `check_versions.sh`

Informativní skript pro kontrolu aktuálních verzí všech addonů.

**Funkce:**
- Zobrazí verzi z config.yaml každého addonu
- Ukáže poslední git tag z každého submodulu
- Zobrazí aktuální commit hash
- Ukáže celkový stav submodulů

**Použití:**
```bash
./check_versions.sh
```

**Příklad výstupu:**
```
=== Kontrola verzí Home Assistant Add-onů ===

PowerStreamPlan:
  Config verze: 2.4.1
  Poslední tag: v2.4.1
  Aktuální commit: 44c2db0

Ingress Proxy:
  Config verze: 1.0.0
  Poslední tag: no-tags
  Aktuální commit: 3fb47d7

Stav submodulů:
 3fb47d7256e09ed8672b5561dde3cd6f2a06d343 ingress-proxy (heads/main)
 44c2db06312a8430f9e4efbe36f2724b6857ee11 power_stream_plan (v1.6.0-109-g44c2db0)

=== Konec kontroly ===
```

## Pracovní postup

1. **Před vydáním nové verze addonu** - spusťte `./check_versions.sh` pro kontrolu aktuálního stavu
2. **Po vydání nové verze** - spusťte `./update_submodules.sh` pro aktualizaci
3. **Pravidelná kontrola** - používejte `./check_versions.sh` pro monitoring verzí

## Požadavky

- Git
- Bash shell
- Přístup k remote repozitářům submodulů

## Poznámky

- Skripty automaticky pracují s git submoduly a respektují jejich strukturu
- Všechny změny jsou commitovány s popisnými zprávami
- README.md je automaticky aktualizováno s aktuálními verzemi
- Před pushováním do remote repozitáře je vždy vyžádáno potvrzení
