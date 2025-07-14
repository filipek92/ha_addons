# Přidání nového add-onu

Návod na přidání nového add-onu do Filip's Home Assistant Add-ons repository.

## Krok 1: Vytvořte nový repozitář

1. Vytvořte nový Git repozitář pro váš add-on
2. Použijte naming convention: `ha-addon-{addon-name}`
3. Například: `ha-addon-power-stream-plan`

## Krok 2: Implementujte add-on

Vytvořte následující soubory ve vašem add-on repozitáři:

### Povinné soubory:
- `config.json` - Hlavní konfigurační soubor
- `Dockerfile` - Docker image definice
- `README.md` - Dokumentace add-onu
- `run.sh` - Spouštěcí skript (v rootfs/)

### Doporučené soubory:
- `requirements.txt` - Python závislosti (pokud používáte Python)
- `package.json` - Node.js závislosti (pokud používáte Node.js)
- `CHANGELOG.md` - Historie změn
- `DOCS.md` - Detailní dokumentace

## Krok 3: Upravte repository.json

Přidejte váš add-on do `repository.json`:

```json
{
  "slug": "your-addon-slug",
  "name": "Your Add-on Name",
  "description": "Krátký popis vašeho add-onu",
  "url": "https://github.com/filipek92/your-addon-repo"
}
```

## Krok 4: Aktualizujte README.md

Přidejte informace o vašem add-onu do hlavního README.md:

```markdown
### Your Add-on Name

Krátký popis add-onu.

**Funkce:**
- Funkce 1
- Funkce 2
- Funkce 3

**Dokumentace:** [Your Add-on Name](https://github.com/filipek92/your-addon-repo)
```

## Krok 5: Testování

1. Přidejte repository do Home Assistant
2. Otestujte instalaci add-onu
3. Ověřte funkčnost

## Požadavky na add-on

- Musí být kompatibilní s Home Assistant Supervisor
- Musí obsahovat validní `config.json`
- Musí mít README.md s dokumentací
- Doporučeno: Multi-arch podpora (amd64, armv7, aarch64)

## Příklad config.json

```json
{
  "name": "Your Add-on Name",
  "version": "1.0.0",
  "slug": "your_addon_slug",
  "description": "Popis add-onu",
  "url": "https://github.com/filipek92/your-addon-repo",
  "arch": ["amd64", "armv7", "aarch64"],
  "startup": "application",
  "boot": "auto",
  "init": false,
  "ingress": true,
  "ingress_port": 8080,
  "options": {},
  "schema": {}
}
```
