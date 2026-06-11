# ADR 0010: Agregar layer TRACKBLESS

## Estado

Aceptado.

## Contexto

`DEFAULT` no puede quedar bloqueado por `trackball_lock` si se quiere mantener
la activacion automatica de `MOUSE` por movimiento. Para escribir sin riesgo de
mover el puntero, se necesita una capa equivalente a `QWRT` donde el trackball
si este bloqueado.

## Decision

Agregar el layer `TRACKBLESS`:

```c
#define TRACKBLESS 7
```

`TRACKBLESS` replica la distribucion de `QWRT`, pero se incluye en
`trackball_lock.layers`:

```c
layers = <1 2 3 7>;
```

Crear tap-dances para que la posicion 58 tenga una regla consistente en todos
los layers:

```c
td_trackbless_space: td_trackbless_space {
    compatible = "zmk,behavior-tap-dance";
    #binding-cells = <0>;
    tapping-term-ms = <350>;
    bindings = <&kp SPACE>, <&to TRACKBLESS>;
};
```

En `QWRT`, posicion 58:

- tap: `SPACE`;
- doble tap: ir a `TRACKBLESS`.

En `TRACKBLESS`, posicion 58:

- tap: `SPACE`;
- doble tap: ir a `QWRT`.

En `SYM`, posicion 58:

- tap: `ENTER`;
- doble tap: ir a `TRACKBLESS`.

En `MOUSE`, posicion 58:

- tap: volver a `QWRT`;
- doble tap: ir a `TRACKBLESS`.

En `NUM`, `FUN`, `SCROLL` y `SNIPE`, posicion 58:

- tap: no hace nada;
- doble tap: ir a `TRACKBLESS`.

Se elimina el tap-dance anterior `td_mouse_default`, que hacia que doble tap en
posiciones de `MOUSE` volviera a `QWRT`.

## Consecuencias

`QWRT` mantiene activacion automatica de `MOUSE` por movimiento. `TRACKBLESS`
mantiene el mismo layout de escritura, pero descarta movimiento del trackball.

La posicion 55 deja de ser `&lt MOUSE SPACE` y pasa a ser tap-dance de espacio
para permitir acceso a `TRACKBLESS` desde la zona de pulgar. La posicion 58
queda como control principal: desde `TRACKBLESS` vuelve a `QWRT`, y desde los
demas layers entra a `TRACKBLESS` con doble tap.

En `TRACKBLESS`, las posiciones 56 y 57 quedan dedicadas a acceso de capas:

- posicion 56: hold activa `SCROLL`; doble tap alterna `SCROLL`;
- posicion 57: hold activa `SYM`; doble tap alterna `SCROLL`.

El acceso a `MOUSE` queda principalmente por `automouse-layer`.

## Archivos afectados

- `config/keyball61.keymap`
- `config/boards/shields/keyball61/keyball61_right.overlay`

## Reversal strategy

Eliminar `TRACKBLESS`, quitar `7` de `trackball_lock.layers` y restaurar las
posiciones 55 y 58 de `QWRT` segun el keymap anterior.
