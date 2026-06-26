# 0020. Reorganizar capas QWRT, SCROLL y FUN

## Context

Se necesita ajustar el acceso a `SCROLL`, `FUN` y los controles de mouse/media
sin cambiar las teclas de `QWRT` que no fueron solicitadas.

## Decision

Reordenar los indices de capas para que `SCROLL` sea layer 2 y `FUN` sea layer
3. Mover `TRACKBLESS` a layer 4 y `SYM` a layer 5.

En `QWRT`, asignar la posicion 42 a `SCROLL` momentaneo, las posiciones 55 y 56
a click derecho e izquierdo, y la posicion 57 a hold `FUN` / tap toggle `FUN`.

En `MOUSE`, dejar todas las posiciones transparentes para heredar `QWRT`.

En `SCROLL`, agregar flechas, delete en backspace, click medio, page up/down,
salida a `QWRT`, bracket izquierdo y un bloque numerico con operadores.

En `FUN`, conservar las funciones existentes y mover los accesos de `BLOCKED`,
`SYM` y `SNIPE` a las posiciones 1, 2 y 3. Asignar controles multimedia a las
posiciones 0, 12, 24, 36 y 50.

En `SUPERFUN`, asignar brillo, `Ctrl+D` y cambio de escritorio virtual de
Windows a las posiciones 0, 12, 24, 36 y 50.

## Consequences

La configuracion del PMW3610 debe actualizar `scroll-layers` a 2 y bloquear el
trackball en `TRACKBLESS` usando el nuevo indice 4.

El modificador de backspace ahora envia delete con Ctrl o Alt.

## Reversal strategy

Restaurar el orden anterior de capas, los bindings anteriores de `QWRT`,
`MOUSE`, `SCROLL`, `FUN` y `SUPERFUN`, y devolver las referencias numericas del
PMW3610 a los indices previos.
