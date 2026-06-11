# ADR 0007: Volver al comportamiento base manteniendo QWRT local

## Estado

Aceptado.

## Contexto

El repo `zmk-config-Keyball61` contiene la configuracion original de fabrica del
teclado. En `k61-c2` se habian acumulado cambios para experimentar con mouse,
scroll, lock, combos, macros, capas adicionales y bloqueo explicito del
trackball.

Para volver a configurar el teclado desde cero conviene recuperar el
comportamiento base y conservar solo la distribucion QWRT local. Esa
distribucion modifica la capa base para mantener las posiciones de escritura
actuales.

## Decision

Restaurar el comportamiento de fabrica en:

- layers no base (`NUM`, `SYM`, `FUN`, `MOUSE`, `SCROLL`, `SNIPE`);
- configuracion PMW3610 de la mitad derecha;
- activacion automatica de mouse mediante `automouse-layer = <4>`;
- divisor CPI original del repo base;
- eliminacion de `LOCK`, combos, macros y behaviors custom de mouse/scroll.

Mantener como excepcion la capa base `QWRT`, usando las posiciones locales de
teclas alfanumericas y simbolos principales.

La fila inferior vuelve a usar comportamientos simples de fabrica para acceder a
modos:

```c
&mo SNIPE
&lt MOUSE SPACE
&mo SCROLL
&lt SYM BACKSPACE
```

Esto evita depender de `mouse_hold_toggle`, `scroll_hold_toggle` y
`td_scroll_toggle`, que pertenecian al modelo experimental anterior.

## Consecuencias

El firmware queda mas cercano al punto de partida del repo original y es mas
facil volver a iterar sobre una base conocida.

Se pierden los modos experimentales agregados en ADRs anteriores:

- toggle persistente de mouse;
- doble tap para scroll persistente;
- layer `LOCK`;
- combos para bloquear/desbloquear;
- macro `email_rodrigo`;
- layout enriquecido de la capa `MOUSE`.

La excepcion QWRT significa que el comportamiento no es una copia literal del
repo original: la capa base conserva las posiciones locales ya usadas en
`k61-c2`.

## Archivos afectados

- `config/keyball61.keymap`
- `config/boards/shields/keyball61/keyball61_right.conf`
- `config/boards/shields/keyball61/keyball61_right.overlay`

## Reversal strategy

Para volver al modelo experimental, reintroducir los behaviors, combos y capa
`LOCK` documentados en ADR 0005 y ADR 0006, y volver a ajustar
`keyball61_right.overlay` para usar `trackball_lock` en lugar de
`automouse-layer`.
