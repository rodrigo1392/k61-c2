# 0021. Instalar firmware local

## Context

El script de instalacion de firmware solo podia usar el artefacto asociado al
commit actual o descargarlo desde GitHub Actions.

Para probar versiones anteriores ya guardadas en `vault/`, se necesita instalar
un UF2 existente sin recompilar ni descargar artefactos.

## Decision

Agregar `--local-firmware PATH` a `scripts/install-right-firmware.sh`.

Cuando se usa esta opcion, el script valida que el archivo exista y sea `.uf2`,
lo copia al destino de staging y ejecuta el helper de PowerShell si se usa
`--commit`.

## Consequences

Se puede flashear cualquier UF2 local, incluyendo firmwares historicos de
`vault/`, sin depender del commit actual.

El flujo por defecto sigue usando GitHub Actions y cache por commit.

## Reversal strategy

Eliminar `--local-firmware` y restaurar el flujo unico basado en artefactos del
commit actual.
