# 0017. Reorganizar layers, automouse y bloqueo

## Context

El uso actual necesita que el movimiento del trackball active el modo de mouse y
que la escritura normal quede en el layer base (`QWRT`).

Tambien se necesita un layer `BLOCKED` para anular teclas y trackball, con una
salida explicita por doble tap.

## Decision

Reorganizar la numeracion de layers:

```c
#define QWRT       0
#define SNIPE      1
#define SYM        2
#define FUN        3
#define SCROLL     4
#define TRACKBLESS 5
#define MOUSE      6
#define BLOCKED    7
```

Configurar `automouse-layer = <6>` para que el movimiento del trackball active
`MOUSE`.

Agregar `BLOCKED` como layer 7, con todas las teclas en `&none` salvo doble tap
en las posiciones 56 o 57 para volver a `QWRT`.

## Consequences

`QWRT` queda como layer base. `MOUSE` queda en layer 6 y se activa por
automouse.

Los indices usados por el PMW3610 cambian: `SCROLL` es 4, `SNIPE` es 1, y el
bloqueo del trackball aplica a `TRACKBLESS` y `BLOCKED`.

## Reversal strategy

Restaurar `QWRT` como layer 0, devolver `MOUSE`, `SCROLL`, `SNIPE` y
`TRACKBLESS` a su numeracion anterior, y actualizar los indices del PMW3610 en
`keyball61_right.overlay`.
