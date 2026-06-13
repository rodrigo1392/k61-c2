# 0019. Reordenar MOUSE y TRACKBLESS

## Context

Desde `MOUSE`, la posicion 57 necesita volver a `QWRT` con tap y activar
`TRACKBLESS` momentaneamente con hold.

Para que el hold tape a `MOUSE`, `TRACKBLESS` debe tener mayor prioridad que
`MOUSE`.

## Decision

Reordenar layers:

```c
#define QWRT       0
#define MOUSE      1
#define TRACKBLESS 2
#define SYM        3
```

Actualizar `automouse-layer` a `1` y `trackball_lock.layers` a `<2 8>`.

Cambiar la posicion 57 de `MOUSE` a un hold-tap: hold activa `TRACKBLESS`
momentaneamente, tap vuelve a `QWRT`.

## Consequences

El movimiento del trackball sigue activando `MOUSE`, ahora en indice 1.

`TRACKBLESS` queda por encima de `MOUSE`, por lo que puede taparlo mientras se
mantiene presionada la posicion 57.

## Reversal strategy

Restaurar `TRACKBLESS` como indice 1, `MOUSE` como indice 3, mover los bloques
del keymap a ese orden y devolver el overlay a los indices anteriores.
