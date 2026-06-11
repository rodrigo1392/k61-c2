# k61-c2: firmware ZMK para Keyball61

Este repositorio contiene una configuracion de ZMK para un teclado **Keyball61** con controladores `nice_nano_v2`, funcionamiento dividido en dos mitades y trackball PMW3610 en la mitad derecha. No contiene el firmware completo de ZMK, sino un **user config repo**: el codigo fuente de ZMK y los modulos externos se descargan mediante `west.yml`, y el firmware se compila en GitHub Actions a partir de los archivos de configuracion de este repositorio.

El repositorio deriva de [`tangbonze/zmk-config-Keyball61`](https://github.com/tangbonze/zmk-config-Keyball61). Esta configuracion conserva la base de hardware del Keyball61, pero modifica el comportamiento del teclado, el manejo del trackball, las capas de mouse/scroll/lock, los valores CPI del sensor, la automatizacion de instalacion del firmware y la documentacion del proyecto. Las diferencias principales estan registradas en [`docs/adr/`](docs/adr/).

El objetivo de este README no es fijar para siempre la distribucion exacta de teclas, porque el keymap cambiara muchas veces, sino explicar el **modelo de ZMK aplicado a este teclado** y dejar claro que archivos modificar para conseguir determinados comportamientos.

## Uso rapido del repositorio

### Scripts principales

| Script | Funcion | Uso tipico |
| --- | --- | --- |
| [`scripts/push-and-install.sh`](scripts/push-and-install.sh) | Automatiza el ciclo completo: hacer commit, rebase, push, esperar un tiempo y ejecutar el instalador de firmware. | `./scripts/push-and-install.sh -m "ajuste keymap" --wait 10` |
| [`scripts/install-right-firmware.sh`](scripts/install-right-firmware.sh) | Busca el build de GitHub Actions asociado al `HEAD` actual, descarga el artefacto UF2 de la mitad derecha, lo cachea en `vault/` y lo copia al volumen `NICENANO` desde WSL/Windows. | `./scripts/install-right-firmware.sh --commit` |

`push-and-install.sh` es el camino corto cuando ya se sabe que el cambio debe commitearse y probarse. Internamente hace `git fetch`, `git add .`, `git commit`, `git rebase origin/main`, `git push` y luego llama a `install-right-firmware.sh --commit`.

`install-right-firmware.sh` puede ejecutarse en modo dry run, sin copiar el firmware, para verificar que encuentra el build y el artefacto correcto. Al pasar `--commit`, copia el UF2 a una ruta intermedia de WSL, genera o reutiliza un helper de PowerShell y deja que Windows copie el archivo al volumen montado del `nice!nano`.

Ejemplos:

```bash
# Ver ayuda
./scripts/push-and-install.sh --help
./scripts/install-right-firmware.sh --help

# Commit + push + instalacion posterior
./scripts/push-and-install.sh -m "ajuste capa mouse" --wait 10

# Solo descargar e instalar el firmware derecho del commit actual
./scripts/install-right-firmware.sh --commit

# Probar sin copiar nada al teclado
./scripts/install-right-firmware.sh --dry-run
```

Requisitos practicos del flujo automatizado:

- `git` configurado dentro del repo.
- GitHub CLI (`gh`) instalado y autenticado con `gh auth login`.
- Acceso al repo remoto `rodrigo1392/k61-c2` o al repo indicado con `--repo`.
- Entorno WSL con acceso a `powershell.exe` y `wslpath`.
- Mitad derecha en modo bootloader, montada en Windows como volumen `NICENANO`.


### Dibujo del keymap

`.github/workflows/keymap_drawer.yml` usa `caksoylar/keymap-drawer` para generar una representacion visual:

```yaml
uses: caksoylar/keymap-drawer/.github/workflows/draw-zmk.yml@main
```

Entradas relevantes:

- `keymap_patterns: "config/*.keymap"`
- `json_path: "config"`
- `config_path: "keymap_drawer.config.yaml"`
- `output_folder: "keymap-drawer"`
- `destination: "both"`

El archivo generado `keymap-drawer/keyball61.svg` sirve para revisar visualmente el layout, pero no modifica el firmware.

Nota: el path observado en el trigger contiene `keymap_draser.yml`, con una `s`. Si se quiere que cambios al propio workflow disparen correctamente el workflow, conviene revisar ese nombre.

## ADRs y documentacion de decisiones

Las decisiones de configuracion estan en [`docs/adr/`](docs/adr/). La decisión para este repo es documentar un ADR por cada commiteo del trackball. Los commits automaticos `[Draw] ...` no deberian tener ADR propio salvo que el workflow de dibujo cambie. Normalmente son artefactos generados a partir del keymap.

## Referencias oficiales utiles

- ZMK keymaps y layers: https://zmk.dev/docs/keymaps
- ZMK behaviors overview: https://zmk.dev/docs/keymaps/behaviors
- Key press: https://zmk.dev/docs/keymaps/behaviors/key-press
- Layer behaviors: https://zmk.dev/docs/keymaps/behaviors/layers
- Hold-tap: https://zmk.dev/docs/keymaps/behaviors/hold-tap
- Macros: https://zmk.dev/docs/keymaps/behaviors/macros
- Combos: https://zmk.dev/docs/keymaps/combos
- Bluetooth behavior: https://zmk.dev/docs/keymaps/behaviors/bluetooth
- Mouse emulation: https://zmk.dev/docs/keymaps/behaviors/mouse-emulation
- Reset behavior: https://zmk.dev/docs/keymaps/behaviors/reset
- User setup: https://zmk.dev/docs/user-setup
- Repo base: https://github.com/tangbonze/zmk-config-Keyball61
