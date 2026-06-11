# ADR 0011: Reorganizar fila inferior y scroll direccional

## Estado

Aceptado.

## Contexto

La base de escritura necesita una fila inferior mas predecible para
modificadores y signos frecuentes. Ademas, las capas `MOUSE` y `SCROLL` deben
conservar el comportamiento de escritura del lado izquierdo, salvo por las
teclas de click en `MOUSE`.

## Decision

En `DEFAULT` y `TRACKBLESS`, configurar la fila inferior asi:

- lado izquierdo, desde la esquina inferior izquierda hacia la derecha:
  `LEFT_CONTROL`, `LEFT_GUI`, `LEFT_ALT`, `MINUS`;
- lado derecho final: `RIGHT_ALT`, `ENTER`.

En `MOUSE`, mantener `&trans` en las teclas del lado izquierdo para heredar de
`DEFAULT`, excepto:

- `A`: click derecho;
- `S`: click medio;
- `D`: click izquierdo.

Esto permite combinar clicks con modificadores heredados como `Ctrl`, `Alt` o
`Shift` cuando ZMK y el host aceptan esa combinacion.

En `SCROLL`, mantener herencia general y usar estas teclas como flechas:

- `.`: izquierda;
- `/`: abajo;
- `RIGHT_SHIFT`: derecha;
- `;`: arriba.

En `SYM`, asignar `DELETE` a la tecla fisica `]` de `DEFAULT`, para recuperar
`DEL` sin dedicarle una tecla fisica en `DEFAULT`.

## Consecuencias

La fila inferior queda mas cercana a un teclado convencional en las posiciones
de modificadores. `MOUSE` y `SCROLL` conservan mas comportamiento de `DEFAULT`,
reduciendo sorpresas al entrar en esas capas.

`DELETE` deja de estar asignado fisicamente en la fila inferior derecha, pero
queda disponible desde `SYM`.

## Archivos afectados

- `config/keyball61.keymap`

## Reversal strategy

Restaurar las filas afectadas de `DEFAULT`, `TRACKBLESS`, `MOUSE` y `SCROLL`
desde el keymap anterior.
