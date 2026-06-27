# 0020. Reorganizar capas QWRT, SCROLL y FUN

## Context

Se necesita ajustar el acceso a `SCROLL`, `FUN` y los controles de mouse/media
sin cambiar las teclas de `QWRT` que no fueron solicitadas.

## Decision

Reordenar los indices de capas para que `SCROLL` sea layer 2 y `FUN` sea layer
3. Mover `TRACKBLESS` a layer 4 y `SYM` a layer 5.

En `QWRT`, asignar la posicion 40 a click izquierdo, la posicion 41 a `V`, la
posicion 42 a `B`, la posicion 55 a hold `MOUSE` / triple tap toggle `MOUSE`, la
posicion 56 a `SCROLL` momentaneo y la posicion 57 a hold `FUN` / tap toggle
`FUN`.

En `MOUSE`, heredar las posiciones de `QWRT` con `&trans`, salvo `S`, `D` y `F`,
que envian click derecho, click medio y click izquierdo.

Desactivar `automouse-layer`: el movimiento del trackball ya no activa `MOUSE`
porque las funciones necesarias de mouse estan disponibles desde `QWRT`.

En `SCROLL`, agregar flechas, delete en backspace, click medio, page up/down,
salida a `QWRT`, bracket izquierdo, un bloque numerico con operadores y acceso
a `SUPERFUN` desde la posicion de `\`. En `SCROLL` y `FUN`, tocar `\` alterna
`SUPERFUN` y mantenerla presionada activa la capa momentaneamente.

En `SCROLL`, asignar `S`, `D` y `F` a click derecho, click medio y click
izquierdo.

En `FUN`, conservar las funciones existentes y mover los accesos de `BLOCKED`,
`SYM` y `SNIPE` a las posiciones 1, 2 y 3. Alternar `TRACKBLESS` solo desde
`FUN`, en la posicion 5. `TRACKBLESS` se desactiva desde la posicion 57, que
vuelve a `QWRT`.

En `FUN`, las posiciones sin funcion especial envian la tecla normal equivalente
de `QWRT`. Las posiciones 55 y 56 mantienen click derecho e izquierdo, y la
posicion 58 envia `ENTER`.

En todas las capas no base, la posicion 57 vuelve explicitamente a `QWRT`.

Asignar controles multimedia a las posiciones 0, 12, 24, 36 y 50.

En `SUPERFUN`, asignar brillo, `Ctrl+D` y cambio de escritorio virtual de
Windows a las posiciones 0, 12, 24, 36 y 50.

Mover de `SYM` a `SUPERFUN` los controles Bluetooth, conservando
`A=BT_CLR` y `S/D/F=perfiles 1/2/3`. Agregar los perfiles 4 y 5 en `G` y `T`.

## Consequences

La configuracion del PMW3610 debe actualizar `scroll-layers` a 2 y bloquear el
trackball en `TRACKBLESS` usando el nuevo indice 4.

La configuracion del PMW3610 deja de declarar `automouse-layer` y opciones de
timeout/umbral de automouse.

El modificador de backspace ahora envia delete solo con Shift. Ctrl+Backspace y
Alt+Backspace conservan el comportamiento normal del sistema.

Los botones de mouse usan la configuracion actual de ZMK con
`CONFIG_ZMK_POINTING=y` y `dt-bindings/zmk/pointing.h`.

La matriz de ambas mitades se declara como fuente de despertar. El lado derecho
no entra en sueño profundo, para mantener activo el enlace central y permitir
que una tecla de cualquiera de las dos mitades reactive el teclado desde idle.
Esto aumenta el consumo durante periodos largos de inactividad frente al sueño
profundo.

## Reversal strategy

Restaurar el orden anterior de capas, los bindings anteriores de `QWRT`,
`MOUSE`, `SCROLL`, `FUN` y `SUPERFUN`, y devolver las referencias numericas del
PMW3610 a los indices previos.
