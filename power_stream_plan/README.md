# PowerStreamPlan Add-on

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

Inteligentní plánovač a optimalizátor pro energetickou produkci a spotřebu v Home Assistant.

## Funkce

- **Inteligentní plánování**: Automatické plánování energetické produkce na základě předpovědí
- **Optimalizace spotřeby**: Optimalizace spotřeby energie v reálném čase
- **Predikce**: Pokročilé algoritmy pro předpovídání energetických potřeb
- **Automatizace**: Automatické řízení zařízení pro maximální efektivitu
- **Monitoring**: Detailní monitoring a analýza energetických dat
- **Notifikace**: Upozornění na důležité události a optimalizační příležitosti

## Instalace

1. Přidejte tento repository do Home Assistant
2. Najděte "PowerStreamPlan" v Add-on Store
3. Klikněte na "Install"
4. Konfigurujte add-on podle vašich potřeb
5. Spusťte add-on

## Konfigurace

### Základní nastavení

```yaml
log_level: info
optimization_interval: 300
prediction_window: 24
enable_notifications: true
```

### Parametry

- **log_level**: Úroveň logování (trace, debug, info, notice, warning, error, fatal)
- **optimization_interval**: Interval optimalizace v sekundách (60-3600)
- **prediction_window**: Časové okno pro predikci v hodinách (1-48)
- **enable_notifications**: Povolit notifikace (true/false)

## Požadavky

- Home Assistant 2023.1.0 nebo novější
- MQTT broker (doporučeno Mosquitto broker add-on)
- Energetické senzory v Home Assistant

## Použití

Po instalaci a spuštění add-onu:

1. Otevřete webové rozhraní přes panel Home Assistant
2. Nakonfigurujte vaše energetické zařízení
3. Nastavte optimalizační cíle
4. Spusťte automatickou optimalizaci

## Webové rozhraní

Add-on poskytuje webové rozhraní dostupné na portu 8080, které je automaticky integrovано do Home Assistant panelu.

## Integrace

PowerStreamPlan se automaticky integruje s:
- Home Assistant Energy dashboard
- MQTT senzory a zařízení
- Solární panely a baterie
- Chytré spotřebiče

## Podpora

Pro hlášení problémů nebo návrhy vytvořte issue na [GitHub](https://github.com/filipek92/ha_addons/issues).

## Changelog

### 1.0.0
- Počáteční vydání
- Základní optimalizační funkce
- Webové rozhraní
- MQTT integrace

---

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
