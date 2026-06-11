# ADR 0009: Bloquear trackball fuera de modos de puntero

## Estado

Aceptado.

## Contexto

El trackball puede mover el puntero aun cuando el usuario no esta trabajando en
una capa pensada para mouse, scroll o precision. Para evitar movimientos
accidentales, conviene descartar el movimiento de la bola en las capas de
escritura y funciones.

La numeracion actual de layers es:

```c
#define DEFAULT 0
#define NUM     1
#define SYM     2
#define FUN     3
#define MOUSE   4
#define SCROLL  5
#define SNIPE   6
```

## Decision

Agregar `trackball_lock` como subnodo del PMW3610 en el overlay derecho para
bloquear todos los layers excepto `MOUSE`, `SCROLL` y `SNIPE`:

```c
trackball: trackball@0 {
    ...

    trackball_lock {
        layers = <0 1 2 3>;
        bindings = <&none>, <&none>, <&none>, <&none>;
        tick = <1>;
    };
};
```

Las cuatro direcciones se asignan a `&none`, por lo que el movimiento
interceptado se descarta.

El nodo debe quedar dentro de `trackball: trackball@0`. Ubicarlo directamente
en `/ { ... }` no hizo que el driver interceptara el movimiento.

## Consecuencias

El trackball no deberia mover el puntero en `DEFAULT`, `NUM`, `SYM` ni `FUN`.
El movimiento queda permitido en `MOUSE`, `SCROLL` y `SNIPE`.

La decision acopla `keyball61_right.overlay` con la numeracion del keymap. Si se
renumeran layers, se debe actualizar `trackball_lock.layers`.

## Archivos afectados

- `config/boards/shields/keyball61/keyball61_right.overlay`

## Reversal strategy

Eliminar el nodo `trackball_lock` o quitar capas de `layers` para volver a
permitir movimiento del trackball en esas capas.
