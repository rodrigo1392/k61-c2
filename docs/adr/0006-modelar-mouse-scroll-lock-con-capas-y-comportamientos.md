# ADR 0006: Modelar mouse, scroll y lock con capas, combos, hold-tap y tap-dance

## Estado

Aceptado.

## Commits relacionados

- `3d32284` - `mouse adjust`
- `73c52b5` - `flechas navegacion`
- `29ce45b` - `mouse togglers`
- `1a0b42e` - `hold tap 55`
- `74d485c` - `mouse enriquecido`
- `2c2b2da` - `mouse mejorado`
- `3dbd0d5` - `ctrl x z v c activados en mouse`

## Contexto

El Keyball61 combina teclado y trackball. Para que el trackball sea util sin abandonar la posicion de escritura, el firmware debe ofrecer varios modos:

- mouse momentaneo;
- mouse persistente;
- scroll momentaneo;
- scroll persistente, pero dificil de activar por accidente;
- bloqueo del trackball;
- navegacion y acciones frecuentes desde la capa mouse.

## Decision

Definir comportamientos custom en `config/keyball61.keymap`:

```c
mouse_hold_toggle: mouse_hold_toggle {
    compatible = "zmk,behavior-hold-tap";
    #binding-cells = <2>;
    tapping-term-ms = <500>;
    flavor = "balanced";
    bindings = <&mo>, <&tog>;
};
```

```c
td_scroll_toggle: td_scroll_toggle {
    compatible = "zmk,behavior-tap-dance";
    #binding-cells = <0>;
    tapping-term-ms = <350>;
    bindings = <&none>, <&tog SCROLL>;
};
```

```c
scroll_hold_toggle: scroll_hold_toggle {
    compatible = "zmk,behavior-hold-tap";
    #binding-cells = <2>;
    tapping-term-ms = <200>;
    flavor = "hold-preferred";
    bindings = <&mo>, <&td_scroll_toggle>;
};
```

Y definir combos para entrar/salir de lock:

```c
combo_mouse_lock {
    timeout-ms = <80>;
    key-positions = <54 58>;
    layers = <MOUSE>;
    bindings = <&to LOCK>;
};

combo_unlock {
    timeout-ms = <80>;
    key-positions = <54 58>;
    layers = <LOCK>;
    bindings = <&to DEFAULT>;
};
```

## Consecuencias

Una misma tecla puede servir para acceso momentaneo y toggle, lo que reduce cantidad de posiciones dedicadas a cambios de modo. El scroll persistente exige doble tap, reduciendo activaciones accidentales. El modo `LOCK` queda separado y reversible por combo.

El keymap se vuelve mas poderoso, pero tambien mas conceptual: para mantenerlo hay que entender `hold-tap`, `tap-dance`, `combos`, `&mo`, `&tog` y `&to`. Por eso el README debe explicar estos conceptos con detalle y no limitarse a listar capas.

## Archivos afectados

- `config/keyball61.keymap`
- `config/boards/shields/keyball61/keyball61_right.overlay`
