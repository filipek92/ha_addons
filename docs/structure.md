# Struktura Add-on Repository

Toto je hlavní repository pro Filip's Home Assistant Add-ons. Obsahuje pouze index/katalog add-onů, přičemž každý add-on je hostován ve vlastním Git repozitáři.

## Struktura

```
ha_addons/
├── README.md              # Hlavní dokumentace
├── repository.json        # Katalog add-onů
└── docs/
    ├── structure.md       # Tento soubor
    └── add-addon.md       # Návod na přidání nového add-onu
```

## Přidání nového add-onu

1. Vytvořte nový Git repozitář pro váš add-on
2. Implementujte add-on podle [Home Assistant Add-on dokumentace](https://developers.home-assistant.io/docs/add-ons)
3. Upravte `repository.json` v tomto repozitáři
4. Aktualizujte `README.md` s informacemi o novém add-onu

## Formát repository.json

```json
{
  "name": "Filip's Home Assistant Add-ons",
  "slug": "filipek92-ha-addons",
  "maintainer": "Filip Richter <filip.richter92@gmail.com>",
  "url": "https://github.com/filipek92/ha_addons",
  "addons": [
    {
      "slug": "addon-slug",
      "name": "Add-on Name",
      "description": "Krátký popis add-onu",
      "url": "https://github.com/filipek92/addon-repository"
    }
  ]
}
```

## Aktuální add-ony

- **PowerStreamPlan**: https://github.com/filipek92/power-stream-plan
