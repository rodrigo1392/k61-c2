# ADR 0002: Automatizar push, build, descarga e instalacion del firmware derecho

## Estado

Aceptado.

## Commits relacionados

- `5059262` - `velocidad de raton`
- `95ec37d` - `velocidad raton 2`
- `842d828` - `probando a ver si funciona pusheo`

## Contexto

El flujo normal de ZMK user config consiste en modificar archivos bajo `config/`, pushear el cambio a GitHub, esperar el workflow de build y descargar manualmente los artefactos UF2. Ese flujo funciona, pero es repetitivo cuando se esta iterando sobre sensibilidad del trackball, capas o keymap.

Ademas, en este teclado la mitad derecha concentra el trackball y la configuracion de ZMK Studio, por lo que muchos ensayos requieren instalar principalmente el firmware `keyball61_right-nice_nano_v2-zmk.uf2`.

## Decision

Agregar dos scripts:

- `scripts/push-and-install.sh` para automatizar `git fetch`, `git add .`, `git commit`, `git rebase`, `git push`, espera y llamada al instalador.
- `scripts/install-right-firmware.sh` para localizar el workflow del commit actual, esperar su finalizacion, descargar el UF2 derecho, cachearlo en `vault/` y copiarlo al volumen `NICENANO` mediante WSL/PowerShell.

## Consecuencias

El ciclo de prueba se reduce a un comando cuando el cambio esta listo para commitearse. El script tambien deja trazabilidad local en `vault/`, guardando firmwares con numero, asunto de commit, nombre de artefacto y hash corto.

La automatizacion introduce dependencias externas: `gh`, autenticacion con GitHub CLI, `powershell.exe`, `wslpath` y un entorno Windows/WSL con acceso al volumen del `nice!nano`.

## Notas de mantenimiento

El README debe explicar estos scripts cerca del inicio, porque son parte del flujo practico del repo y no simples utilidades accesorias.
