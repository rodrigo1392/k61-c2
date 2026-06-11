# ADR 0005: Bloquear el trackball por capas en lugar de depender solo de automouse

## Estado

Aceptado.

## Commits relacionados

- `2f83d46` - `trackball quieto`
- `7782a73` - `trackball bloqueado 2`
- `251ead8` - `teclas 56/57/58`
- `041e3c4` - `layer scroll y lock`

## Contexto

El repo base declara `automouse-layer = <4>` dentro del nodo PMW3610. Eso permite que el movimiento del trackball active una capa de mouse. En esta configuracion se busca un control mas explicito: que el trackball este activo, inactivo, en scroll o en precision segun capas seleccionadas por el keymap.

Diferencia conceptual frente al repo base:

```c
// repo base
trackball: trackball@0 {
    automouse-layer = <4>;
    scroll-layers = <5>;
    snipe-layers = <6>;
};

// repo actual
trackball: trackball@0 {
    scroll-layers = <5>;
    snipe-layers = <6>;

    trackball_lock {
        layers = <0 2 3 7>;
        bindings = <&none>, <&none>, <&none>, <&none>;
        tick = <1>;
    };
};
```

## Decision

Eliminar el uso de `automouse-layer` y agregar un subnodo `trackball_lock` que anula el movimiento del trackball en capas seleccionadas.

## Consecuencias

El comportamiento del trackball queda mas deliberado: no se depende de que el movimiento active automaticamente la capa mouse, sino de capas elegidas por el usuario. Esto reduce activaciones accidentales y permite un modo `LOCK` mas claro.

La decision acopla la numeracion de capas del keymap con `keyball61_right.overlay`. Si se renumeran `DEFAULT`, `SYM`, `FUN`, `SCROLL`, `SNIPE` o `LOCK`, se debe revisar tambien el overlay.

## Archivos afectados

- `config/boards/shields/keyball61/keyball61_right.overlay`
- `config/keyball61.keymap`

## Riesgo

Si las capas indicadas en `trackball_lock.layers` no coinciden con las definiciones del keymap, el trackball podria quedar activo o inactivo en capas inesperadas.
