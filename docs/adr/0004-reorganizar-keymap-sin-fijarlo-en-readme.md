# ADR 0004: Reorganizar el keymap sin fijar la distribucion exacta en el README

## Estado

Aceptado.

## Commits relacionados

- `269de49` - `Update QWRT mechanical keys`
- `66d6f59` - `tecla 56 para espacio`
- `eb84845` - `espacio corregido`
- `2e36170` - `define actualizados`

## Contexto

La distribucion de teclas del Keyball61 probablemente seguira cambiando. Documentar cada posicion exacta dentro del README generaria deuda documental, porque el README quedaria desactualizado con rapidez.

Al mismo tiempo, si el README omite el modelo de ZMK, el repo sigue siendo dificil de mantener para alguien que no conoce ZMK.

## Decision

El README debe priorizar:

- modelo mental de ZMK;
- relacion entre board, shield, keymap, overlay, dtsi y conf;
- que archivo cambiar para lograr determinado comportamiento;
- explicacion de behaviors como `&kp`, `&mo`, `&lt`, `&mt`, `&tog`, `&to`, `&trans`, `&none`, macros y combos.

La distribucion exacta de teclas debe documentarse preferentemente en:

- el propio `config/keyball61.keymap`;
- el SVG generado en `keymap-drawer/keyball61.svg`;
- ADRs especificos si una decision de layout tiene motivacion duradera;
- documentos de keymap separados si se quiere registrar una version estable.

## Consecuencias

El README queda mas estable y mas util para aprender ZMK. Los cambios frecuentes de layout no obligan a reescribir la documentacion principal, salvo cuando introducen un concepto nuevo.

## Archivos afectados

- `README.md`
- `config/keyball61.keymap`
- `keymap-drawer/keyball61.svg`
