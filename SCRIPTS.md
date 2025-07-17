# Skripty pro správu submodulů

Tento repozitář obsahuje dva užitečné skripty pro práci s Home Assistant Add-ony jako submoduly:

## Scripts

### `update_submodules.sh`

Hlavní skript pro aktualizaci submodulů a údržbu repozitáře.

**Funkce:**
- Automaticky detekuje všechny submoduly v repozitáři
- Aktualizuje všechny submoduly na nejnovější verze z remote repozitářů
- Detekuje, které submoduly byly aktualizovány
- **Pouze při změnách:** Automaticky aktualizuje tabulku verzí v README.md pro všechny addony
- **Pouze při změnách:** Vytvoří commit s popisem změn
- Volitelně pushne změny do remote repozitáře
- **Plně automatické** - při přidání nového submodulu se automaticky zahrne
- **Optimalizované** - nic nedělá, pokud nebyly žádné aktualizace

**Použití:**
```bash
./update_submodules.sh
```

**Příklad výstupu (bez změn):**
```
[INFO] Začíná aktualizace submodulů...
[INFO] Ukládám aktuální stav submodulů...
[INFO] Aktualizuji submoduly...
[INFO] Žádné submoduly nebyly aktualizovány
```

**Příklad výstupu (s aktualizací):**
```
[INFO] Začíná aktualizace submodulů...
[INFO] Ukládám aktuální stav submodulů...
[INFO] Aktualizuji submoduly...
[INFO] PowerStreamPlan byl aktualizován (44c2db0 -> a1b2c3d)
[INFO] Aktuální verze addonů:
[INFO]   PowerStreamPlan: 2.4.2
[INFO]   Ingress Proxy: 1.0.0
[SUCCESS] README.md aktualizováno s novými verzemi
[SUCCESS] Commit vytvořen s následující zprávou:
Aktualizace submodulů - aktualizovány: PowerStreamPlan

Aktuální verze:
- PowerStreamPlan: 2.4.2
- Ingress Proxy: 1.0.0

Chcete pushovat změny do remote repozitáře? (y/N):
```

### `check_versions.sh`

Informativní skript pro kontrolu aktuálních verzí všech addonů.

**Funkce:**
- Automaticky detekuje všechny submoduly v repozitáři
- Zobrazí verzi z config.yaml každého addonu
- Ukáže poslední git tag z každého submodulu
- Zobrazí aktuální commit hash
- Ukáže celkový stav submodulů
- **Plně automatické** - při přidání nového submodulu se automaticky zahrne

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
- **Automaticky detekují všechny submoduly** - při přidání nového addonu se automaticky zahrne
- Všechny změny jsou commitovány s popisnými zprávami
- README.md je automaticky aktualizováno s aktuálními verzemi všech addonů
- Před pushováním do remote repozitáře je vždy vyžádáno potvrzení
- Názvy a popisy addonů se automaticky načítají z config.yaml souborů
