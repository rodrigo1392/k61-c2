# 0016. Eliminar layer NUM

## Context

El layer `NUM` existia como una capa intermedia para numeros y navegacion
simple, pero la configuracion actual ya cubre esos usos desde `QWRT`, `SYM` y
`FUN`.

Mantener `NUM` agregaba una capa sin acceso directo documentado y obligaba a
conservar indices mas altos para `MOUSE`, `TRACKBLESS`, `SNIPE` y `SCROLL`.

## Decision

Eliminar `NUM` de `config/keyball61.keymap`.

Renumerar las capas restantes de forma contigua:

```c
#define DEFAULT 0
#define SYM     1
#define FUN     2
#define MOUSE   3
#define TRACKBLESS 4
#define SNIPE   5
#define SCROLL  6
```

Actualizar `keyball61_right.overlay` para que los indices del PMW3610 sigan
apuntando a los layers correctos.

## Consequences

El firmware deja de tener layer `NUM`.

Los indices numericos de `SYM`, `FUN`, `MOUSE`, `TRACKBLESS`, `SNIPE` y
`SCROLL` cambian. Cualquier configuracion que referencie layers por numero debe
usar la nueva numeracion.

## Reversal strategy

Restaurar el bloque `number_layer`, volver a agregar `#define NUM 1` y
renumerar las capas posteriores. Luego actualizar nuevamente los indices del
PMW3610 en `keyball61_right.overlay`.
