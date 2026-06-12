# Configuracion actual

Fuente: `config/keyball61.keymap`.

## Layers

ZMK resuelve primero el layer activo con numero mas alto. Si una tecla es
`&trans`, cae al siguiente layer activo de menor prioridad, hasta llegar al
layer base.

| Numero | Define | Label | Preferencia |
| ---: | --- | --- | --- |
| 7 | `BLOCKED` | `BLOCKED` | 1, mas alta |
| 6 | `MOUSE` | `MOUSE` | 2 |
| 5 | `TRACKBLESS` | `TRACKBLESS` | 3 |
| 4 | `SCROLL` | `SCROLL` | 4 |
| 3 | `FUN` | `FUN` | 5 |
| 2 | `SYM` | `SYM` | 6 |
| 1 | `SNIPE` | `SNIPE` | 7 |
| 0 | `QWRT` | `QWRT` | 8, base |

## Numeracion de teclas en QWRT

La numeracion sigue el orden de `bindings` de ZMK, de izquierda a derecha y de
arriba hacia abajo. `Posicion ZMK` usa indice 0-based.

### Fila 1

| Posicion ZMK | Binding | Significado |
| ---: | --- | --- |
| 0 | `&kp GRAVE` | `` ` `` |
| 1 | `&kp N1` | `1` |
| 2 | `&kp N2` | `2` |
| 3 | `&kp N3` | `3` |
| 4 | `&kp N4` | `4` |
| 5 | `&kp N5` | `5` |
| 6 | `&kp N6` | `6` |
| 7 | `&kp N7` | `7` |
| 8 | `&kp N8` | `8` |
| 9 | `&kp N9` | `9` |
| 10 | `&kp N0` | `0` |
| 11 | `&kp BSPC` | Backspace |

### Fila 2

| Posicion ZMK | Binding | Significado |
| ---: | --- | --- |
| 12 | `&kp TAB` | Tab |
| 13 | `&kp Q` | `Q` |
| 14 | `&kp W` | `W` |
| 15 | `&kp E` | `E` |
| 16 | `&kp R` | `R` |
| 17 | `&kp T` | `T` |
| 18 | `&kp Y` | `Y` |
| 19 | `&kp U` | `U` |
| 20 | `&kp I` | `I` |
| 21 | `&kp O` | `O` |
| 22 | `&kp P` | `P` |
| 23 | `&kp BACKSLASH` | `\` |

### Fila 3

| Posicion ZMK | Binding | Significado |
| ---: | --- | --- |
| 24 | `&kp ESC` | Escape |
| 25 | `&kp A` | `A` |
| 26 | `&kp S` | `S` |
| 27 | `&kp D` | `D` |
| 28 | `&kp F` | `F` |
| 29 | `&kp G` | `G` |
| 30 | `&kp H` | `H` |
| 31 | `&kp J` | `J` |
| 32 | `&kp K` | `K` |
| 33 | `&kp L` | `L` |
| 34 | `&kp SEMI` | `;` |
| 35 | `&kp SQT` | `'` |

### Fila 4

| Posicion ZMK | Binding | Significado |
| ---: | --- | --- |
| 36 | `&kp LEFT_SHIFT` | Shift izquierdo |
| 37 | `&kp Z` | `Z` |
| 38 | `&kp X` | `X` |
| 39 | `&kp C` | `C` |
| 40 | `&kp V` | `V` |
| 41 | `&kp B` | `B` |
| 42 | `&kp LEFT_BRACKET` | `[` |
| 43 | `&kp RIGHT_BRACKET` | `]` |
| 44 | `&kp N` | `N` |
| 45 | `&kp M` | `M` |
| 46 | `&kp COMMA` | `,` |
| 47 | `&kp DOT` | `.` |
| 48 | `&kp FSLH` | `/` |
| 49 | `&kp RIGHT_SHIFT` | Shift derecho |

### Fila 5

| Posicion ZMK | Binding | Significado |
| ---: | --- | --- |
| 50 | `&kp LCTRL` | Control izquierdo |
| 51 | `&kp LEFT_WIN` | Super/Windows izquierdo |
| 52 | `&kp LEFT_ALT` | Alt izquierdo |
| 53 | `&kp MINUS` | `-` |
| 54 | `&td_fun_to_toggle` | Tap: `FUN`; doble tap: toggle `FUN` |
| 55 | `&kp SPACE` | Espacio |
| 56 | `&td_scroll_to_toggle` | Tap: `SCROLL`; doble tap: toggle `SCROLL` |
| 57 | `&ht_57_to_sym_hold_trackbless TRACKBLESS 0` | Tap: `SYM`; doble tap: toggle `SYM`; hold: toggle `TRACKBLESS` |
| 58 | `&kp SPACE` | Espacio |
| 59 | `&kp RIGHT_ALT` | Alt derecho |
| 60 | `&kp ENTER` | Enter |
