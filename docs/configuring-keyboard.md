## Flujo mental completo

El circuito completo puede pensarse asi:

```text
config/*.keymap + config/*.conf + config/boards/shields/keyball61/*
        |
        |  describen comportamiento, hardware, capas, sensor y opciones ZMK
        v
build.yaml
        |
        |  enumera que firmwares construir: izquierda, derecha y settings_reset
        v
.github/workflows/build.yml
        |
        |  llama al workflow reusable oficial de ZMK
        v
GitHub Actions
        |
        |  descarga ZMK y modulos externos segun config/west.yml
        v
artefactos UF2
        |
        |  se descargan e instalan manualmente o con scripts/install-right-firmware.sh
        v
nice_nano_v2 izquierdo / nice_nano_v2 derecho
```

El punto central es que ZMK separa tres ideas que al principio parecen una sola:

1. **La placa controladora**, que en este repo es `nice_nano_v2`.
2. **El shield**, que describe el teclado concreto, sus pines, matriz, pantallas y sensor; en este repo es `keyball61_left` o `keyball61_right`.
3. **El keymap**, que describe que hace cada posicion fisica cuando se presiona en cada capa.

Cuando se cambia una tecla, normalmente se modifica `config/keyball61.keymap`. Cuando se cambia algo del trackball, normalmente se modifica `config/boards/shields/keyball61/keyball61_right.overlay` o `config/boards/shields/keyball61/keyball61_right.conf`. Cuando se cambia que firmwares se construyen, se modifica `build.yaml`.

## Estructura del repositorio

```text
.
├── README.md
├── AGENTS.md
├── build.yaml
├── config/
│   ├── keyball61.keymap
│   ├── keyball61.conf
│   ├── west.yml
│   ├── keyball61.json
│   └── boards/shields/keyball61/
│       ├── Kconfig.defconfig
│       ├── Kconfig.shield
│       ├── keyball61.conf
│       ├── keyball61.dtsi
│       ├── keyball61.zmk.yml
│       ├── keyball61_left.conf
│       ├── keyball61_left.overlay
│       ├── keyball61_right.conf
│       └── keyball61_right.overlay
├── .github/workflows/
│   ├── build.yml
│   └── keymap_drawer.yml
├── keymap-drawer/
│   ├── keyball61.svg
│   └── keyball61.yaml
├── keymap_drawer.config.yaml
├── scripts/
│   ├── install-right-firmware.sh
│   └── push-and-install.sh
├── vault/
│   └── README.md
└── docs/adr/
```

## Archivos principales y que se cambia en cada uno

| Archivo | Rol mental | Cambiar cuando se quiera... |
| --- | --- | --- |
| `config/keyball61.keymap` | Comportamiento del teclado. Define capas, teclas, combos, macros y comportamientos custom. | Cambiar una tecla, agregar un layer, crear un combo, ajustar un hold-tap, crear una macro, cambiar accesos a mouse/scroll/lock. |
| `config/keyball61.conf` | Opciones globales de ZMK. | Ajustar opciones Bluetooth, colas de eventos, pantalla, potencia o features globales. |
| `config/west.yml` | Dependencias externas y versiones. | Cambiar la version de ZMK o el driver externo PMW3610. |
| `build.yaml` | Matriz de firmwares generados por GitHub Actions. | Agregar/quitar firmwares, cambiar board, cambiar shield, agregar snippets. |
| `.github/workflows/build.yml` | Workflow de compilacion. | Cambiar como GitHub Actions invoca el build de ZMK. |
| `.github/workflows/keymap_drawer.yml` | Workflow de generacion grafica del keymap. | Cambiar como se produce `keymap-drawer/keyball61.svg`. |
| `config/boards/shields/keyball61/keyball61.dtsi` | Descripcion comun del shield: layout fisico, transformacion de matriz y scanner. | Cambiar el modelo fisico de posiciones, el orden de posiciones o la relacion matriz→keymap. |
| `config/boards/shields/keyball61/keyball61_left.overlay` | Hardware especifico de la mitad izquierda. | Cambiar pines de filas/columnas, pantalla o perifericos de la izquierda. |
| `config/boards/shields/keyball61/keyball61_right.overlay` | Hardware especifico de la mitad derecha. | Cambiar pines, bus SPI, nodo PMW3610, capas de scroll/snipe o bloqueo del trackball. |
| `config/boards/shields/keyball61/keyball61_right.conf` | Opciones del sensor y features de la mitad derecha. | Cambiar CPI, scroll tick, orientacion, ahorro de energia, polling o ZMK Studio. |
| `keymap_drawer.config.yaml` | Configuracion visual del diagrama. | Cambiar etiquetas, parseo o dibujo del SVG. No afecta el firmware. |
| `vault/` | Cache local de UF2 descargados. | Guardar trazabilidad de builds instalados. No es fuente de configuracion. |

## Modelo de ZMK aplicado al Keyball61

### 1. ZMK usa DeviceTree para describir hardware y comportamiento

Los archivos `.keymap`, `.overlay` y `.dtsi` tienen sintaxis de DeviceTree. Aunque algunos parezcan configuracion de teclado, para ZMK son nodos y propiedades que luego Zephyr procesa al compilar.

Por eso aparecen estructuras como:

```c
/ {
    keymap {
        compatible = "zmk,keymap";
        default_layer {
            bindings = < ... >;
        };
    };
};
```

Y tambien:

```c
trackball: trackball@0 {
    compatible = "zmk,pmw3610";
    scroll-layers = <7>;
    snipe-layers = <6>;
};
```

El primer bloque describe comportamiento de teclas. El segundo describe un dispositivo real conectado por SPI.

### 2. `build.yaml` combina board + shield

El archivo actual es:

```yaml
include:
  - board: nice_nano_v2
    shield: keyball61_left
  - board: nice_nano_v2
    shield: keyball61_right
    snippet: studio-rpc-usb-uart
  - board: nice_nano_v2
    shield: settings_reset
```

Esto produce tres firmwares:

- `keyball61_left-nice_nano_v2-zmk.uf2`: firmware de la mitad izquierda.
- `keyball61_right-nice_nano_v2-zmk.uf2`: firmware de la mitad derecha.
- `settings_reset-nice_nano_v2-zmk.uf2`: firmware especial para limpiar configuraciones persistentes.

El snippet `studio-rpc-usb-uart` se aplica a la mitad derecha para habilitar comunicacion de ZMK Studio por USB UART, coherente con `CONFIG_ZMK_STUDIO=y` en `keyball61_right.conf`.

### 3. `west.yml` fija ZMK y el driver PMW3610

`config/west.yml` define dos remotos:

```yaml
remotes:
  - name: zmkfirmware
    url-base: https://github.com/zmkfirmware
  - name: tangbonze
    url-base: https://github.com/tangbonze
```

Y dos proyectos principales:

```yaml
projects:
  - name: zmk
    remote: zmkfirmware
    revision: v0.3
    import: app/west.yml
  - name: zmk-pmw3610-driver
    remote: tangbonze
    revision: main
```

Esto significa que el repo local no necesita contener ZMK entero. GitHub Actions usa West para descargar ZMK y el driver externo del sensor PMW3610 al compilar.

### 4. El shield describe el teclado real

La carpeta `config/boards/shields/keyball61/` contiene la descripcion del hardware Keyball61.

Los archivos `Kconfig.shield` y `Kconfig.defconfig` hacen que ZMK reconozca `keyball61_left` y `keyball61_right` como shields validos. Los overlays concretos describen pines, buses y dispositivos de cada mitad.

La mitad derecha importa `keyball61.dtsi`, aplica `col-offset = <7>`, define filas/columnas, configura el bus SPI y declara el trackball:

```c
trackball: trackball@0 {
    status = "okay";
    compatible = "zmk,pmw3610";
    reg = <0>;
    spi-max-frequency = <2000000>;
    irq-gpios = <&gpio1 11 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>;
    scroll-layers = <7>;
    snipe-layers = <6>;
};
```

### 5. La matriz fisica no es lo mismo que el keymap

`keyball61.dtsi` contiene una transformacion:

```c
default_transform: keymap_transform_0 {
    compatible = "zmk,matrix-transform";
    columns = <13>;
    rows = <5>;

    map = <
        RC(0,0) RC(0,1) ...
    >;
};
```

Esta transformacion define como se traducen filas y columnas electricas en posiciones lineales del keymap. Por eso los combos usan numeros como `<54 58>`: no son caracteres ni keycodes, sino indices de posiciones fisicas despues de aplicar el transform.

Modelo mental:

```text
switch fisico
   -> fila/columna electrica
   -> kscan detecta presion
   -> matrix-transform la convierte en posicion lineal
   -> keymap busca esa posicion en el layer activo
   -> binding ejecuta un comportamiento ZMK
```

### 6. El keymap no contiene teclas, contiene bindings

Una posicion del keymap puede enviar una tecla comun, activar una capa, disparar una macro, presionar un boton de mouse o no hacer nada.

Ejemplos:

```c
&kp A                 // envia la tecla A
&mo SYM               // activa SYM mientras se mantiene presionada
&lt FUN ENTER          // tap = Enter, hold = layer FUN
&mt LCTRL A           // tap = A, hold = Ctrl
&mkp LCLK             // click izquierdo de mouse
&bt BT_SEL 0          // selecciona perfil Bluetooth 0
&trans                // deja pasar al layer inferior
&none                 // bloquea la posicion
&email_rodrigo        // ejecuta una macro definida en este repo
```

> Recordar que posición 54, 55, 56, 57, 58 son las teclas de la zona thumb, de izquierda a derecha. Dos en el teclado izquierdo, 3 en el derecho.

## Capas actuales

Las capas estan definidas al inicio de `config/keyball61.keymap`:

```c
#define MOUSE      0
#define SNIPE      1
#define SYM        2
#define FUN        3
#define SCROLL     4
#define TRACKBLESS 5
#define QWRT       6
#define BLOCKED    7
```

La numeracion importa porque algunos nodos de hardware, como el PMW3610, referencian capas por numero:

```c
automouse-layer = <0>;
scroll-layers = <4>;
snipe-layers = <1>;
```

Por eso, si se reordena o renumera `MOUSE`, `SCROLL`, `SNIPE`, `TRACKBLESS` o
`BLOCKED`, tambien debe actualizarse `keyball61_right.overlay`.

| Layer | Funcion conceptual | Donde se modifica |
| --- | --- | --- |
| `MOUSE` | Layer base y destino de automouse por movimiento del trackball. | `config/keyball61.keymap` y `keyball61_right.overlay` |
| `SNIPE` | Capa que el driver interpreta como modo de precision. | `config/keyball61.keymap` y `keyball61_right.conf` |
| `SYM` | Simbolos, teclado numerico parcial y controles Bluetooth. | `config/keyball61.keymap` |
| `FUN` | Teclas F1-F12 y macros. | `config/keyball61.keymap` |
| `SCROLL` | Capa que el driver PMW3610 interpreta como modo scroll. | `config/keyball61.keymap` y `keyball61_right.overlay` |
| `TRACKBLESS` | Capa equivalente a `QWRT` con trackball bloqueado. | `config/keyball61.keymap` y `keyball61_right.overlay` |
| `QWRT` | Escritura normal y accesos principales a otras capas. | `config/keyball61.keymap` |
| `BLOCKED` | Bloqueo completo de teclas y trackball, con salida por doble tap. | `config/keyball61.keymap` y `keyball61_right.overlay` |

## Comportamientos ZMK usados en este repo

### Key press: `&kp`

`&kp` envia un keycode HID al host conectado.

```c
&kp A
&kp ENTER
&kp BSPC
&kp C_VOL_UP
```

Usar `&kp` cuando se quiera que una posicion actue como una tecla comun, una tecla multimedia o una tecla de control soportada por ZMK.

### Transparent: `&trans`

`&trans` significa: “esta capa no decide esta posicion; buscar en la siguiente capa activa inferior”.

Es util cuando una capa solo quiere sobrescribir algunas teclas y conservar el resto del comportamiento base.

### None: `&none`

`&none` significa: “esta posicion no hace nada y no se consulta ninguna capa inferior”.

Es util para capas de bloqueo, para evitar acciones accidentales o para posiciones que no deben heredar comportamiento del layer base.

### Momentary layer: `&mo`

`&mo SYM` activa `SYM` solo mientras se mantiene presionada esa tecla. Al soltarla, la capa se desactiva.

Usar `&mo` para capas temporales, como simbolos, funciones o mouse momentaneo.

### Toggle layer: `&tog`

`&tog MOUSE` alterna la capa `MOUSE`: si esta apagada la enciende, y si esta encendida la apaga.

Usar `&tog` para modos que conviene dejar activos sin mantener una tecla presionada.

### To layer: `&to`

`&to BLOCKED` cambia a una capa concreta y desactiva otras capas no permanentes, conservando la capa base.

En este repo se usa para entrar a `BLOCKED` desde `FUN`.

### Layer-tap: `&lt`

`&lt FUN ENTER` significa:

- tap corto: enviar `ENTER`.
- hold: activar `FUN` mientras se mantiene presionada.

El comportamiento global de `&lt` esta ajustado asi:

```c
&lt {
    tapping-term-ms = <240>;
    flavor = "balanced";
    quick-tap-ms = <150>;
};
```

Cambiar `tapping-term-ms` si el tap se convierte en hold demasiado rapido o demasiado lento. Cambiar `flavor` si hay errores al teclear rapido y presionar otra tecla durante la ventana de decision.

### Mod-tap: `&mt`

`&mt LCTRL A` significa:

- tap corto: enviar `A`.
- hold: mantener `Left Ctrl`.

El comportamiento global de `&mt` esta ajustado asi:

```c
&mt {
    tapping-term-ms = <200>;
    flavor = "tap-preferred";
    quick-tap-ms = <150>;
};
```

Usar `&mt` para home-row mods o teclas que deben comportarse como letra al tocar y modificador al mantener.

### Hold-tap custom: `mouse_hold_toggle`

Este repo define un hold-tap propio:

```c
mouse_hold_toggle: mouse_hold_toggle {
    compatible = "zmk,behavior-hold-tap";
    #binding-cells = <2>;
    tapping-term-ms = <500>;
    flavor = "balanced";
    bindings = <&mo>, <&tog>;
};
```

Uso actual:

```c
&mouse_hold_toggle MOUSE MOUSE
```

Lectura:

- hold: ejecutar `&mo MOUSE`, activando mouse solo mientras se mantiene presionada la tecla.
- tap: ejecutar `&tog MOUSE`, dejando mouse encendido o apagado.

Esto permite que una sola posicion sirva tanto para acceso momentaneo como para modo persistente.

### Tap-dance: `td_scroll_to_toggle`

```c
td_scroll_to_toggle: td_scroll_to_toggle {
    compatible = "zmk,behavior-tap-dance";
    #binding-cells = <0>;
    tapping-term-ms = <350>;
    bindings = <&to SCROLL>, <&tog SCROLL>;
};
```

Lectura:

- un tap: cambia a `SCROLL`.
- dos taps dentro de 350 ms: toggle de `SCROLL`.

### Tap-dance: `td_qwrt_sym_toggle`

```c
td_qwrt_sym_toggle: td_qwrt_sym_toggle {
    compatible = "zmk,behavior-tap-dance";
    #binding-cells = <0>;
    tapping-term-ms = <350>;
    bindings = <&tog QWRT>, <&tog SYM>;
};
```

Lectura:

- un tap: toggle de `QWRT`.
- dos taps dentro de 350 ms: toggle de `SYM`.

Se usa en la posicion 57 de capas auxiliares para alternar entre escritura y
simbolos.

### Hold-tap custom: `ht_57_qwrt_hold_trackbless`

```c
ht_57_qwrt_hold_trackbless: ht_57_qwrt_hold_trackbless {
    compatible = "zmk,behavior-hold-tap";
    #binding-cells = <2>;
    tapping-term-ms = <200>;
    flavor = "hold-preferred";
    bindings = <&tog>, <&td_qwrt_sym_toggle>;
};
```

Lectura:

- hold: toggle de `TRACKBLESS`.
- tap: ejecuta `td_qwrt_sym_toggle`.

Uso actual:

```c
&ht_57_qwrt_hold_trackbless TRACKBLESS 0
```

### Mouse: `&mkp`, `&mmv`, `&msc`

Este repo usa `&mkp` para botones de mouse:

```c
&mkp LCLK
&mkp MCLK
&mkp RCLK
```

El movimiento real del cursor no se produce con `&mmv`, sino mediante el sensor PMW3610 declarado en el overlay derecho. Las capas `SCROLL` y `SNIPE` modifican como el driver interpreta el movimiento del trackball.

### Bluetooth: `&bt`

El layer `SYM` contiene controles Bluetooth:

```c
&bt BT_CLR
&bt BT_SEL 0
&bt BT_SEL 1
&bt BT_SEL 2
```

Usos habituales:

- `BT_SEL n`: seleccionar perfil Bluetooth.
- `BT_CLR`: limpiar el emparejamiento del perfil activo.
- `BT_CLR_ALL`: limpiar todos los perfiles, si se agrega al keymap.

### Macros

El repo define una macro:

```c
email_rodrigo: email_rodrigo {
    compatible = "zmk,behavior-macro";
    #binding-cells = <0>;
    wait-ms = <40>;
    tap-ms = <40>;
    bindings = <...>;
};
```

Una macro primero se declara dentro del nodo `macros` y luego se usa como binding:

```c
&email_rodrigo
```

Modificar una macro implica cambiar su lista `bindings`. Para escribir texto, se encadenan keycodes con `&kp`. Para combinaciones complejas, se pueden usar controles de macro como press, tap y release.

### Combos

Los combos se definen fuera del nodo `keymap` porque ZMK los procesa antes del keymap normal.

Ejemplo:

```c
combo_mouse_blocked {
    timeout-ms = <80>;
    key-positions = <54 58>;
    layers = <MOUSE>;
    bindings = <&to BLOCKED>;
};
```

Campos importantes:

- `timeout-ms`: ventana maxima entre presiones.
- `key-positions`: posiciones fisicas lineales, no keycodes.
- `layers`: capas donde el combo existe.
- `bindings`: comportamiento que se ejecuta.

Actualmente `config/keyball61.keymap` no define combos.

## Trackball PMW3610

El trackball se configura en dos niveles.

### Hardware y capas especiales

En `keyball61_right.overlay`:

```c
trackball: trackball@0 {
    status = "okay";
    compatible = "zmk,pmw3610";
    reg = <0>;
    spi-max-frequency = <2000000>;
    irq-gpios = <&gpio1 11 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>;
    scroll-layers = <7>;
    snipe-layers = <6>;

    trackball_lock {
        layers = <1 2 3 5>;
        bindings = <&none>, <&none>, <&none>, <&none>;
        tick = <1>;
    };
};
```

Lectura conceptual:

- `compatible = "zmk,pmw3610"`: usa el driver externo del sensor PMW3610.
- `spi-max-frequency`: velocidad maxima del bus SPI.
- `irq-gpios`: pin de interrupcion del sensor.
- `scroll-layers = <7>`: cuando `SCROLL` esta activo, el movimiento del trackball se interpreta como scroll.
- `snipe-layers = <6>`: cuando `SNIPE` esta activo, se usa CPI de precision.
- `trackball_lock`: anula el movimiento en capas seleccionadas, emitiendo `&none`.

### Parametros de sensibilidad y energia

En `keyball61_right.conf`:

```conf
CONFIG_PMW3610_CPI=1200
CONFIG_PMW3610_CPI_DIVIDOR=1
CONFIG_PMW3610_ORIENTATION_180=y
CONFIG_PMW3610_SNIPE_CPI=400
CONFIG_PMW3610_SNIPE_CPI_DIVIDOR=4
CONFIG_PMW3610_SCROLL_TICK=32
CONFIG_PMW3610_INVERT_SCROLL_X=y
CONFIG_PMW3610_INVERT_SCROLL_Y=n
CONFIG_PMW3610_SMART_ALGORITHM=y
CONFIG_PMW3610_RUN_DOWNSHIFT_TIME_MS=3264
CONFIG_PMW3610_REST1_SAMPLE_TIME_MS=20
CONFIG_PMW3610_POLLING_RATE_125_SW=y
CONFIG_PMW3610_AUTOMOUSE_TIMEOUT_MS=700
CONFIG_PMW3610_MOVEMENT_THRESHOLD=0
```

Cambios habituales:

| Objetivo | Parametro probable |
| --- | --- |
| Cursor mas rapido | subir `CONFIG_PMW3610_CPI` |
| Cursor mas lento | bajar `CONFIG_PMW3610_CPI` |
| Snipe mas preciso | bajar `CONFIG_PMW3610_SNIPE_CPI` o ajustar divisor |
| Scroll mas fino o mas grueso | cambiar `CONFIG_PMW3610_SCROLL_TICK` |
| Invertir direccion de scroll horizontal | cambiar `CONFIG_PMW3610_INVERT_SCROLL_X` |
| Invertir direccion de scroll vertical | cambiar `CONFIG_PMW3610_INVERT_SCROLL_Y` |
| Ajustar ahorro de energia | cambiar `CONFIG_PMW3610_RUN_DOWNSHIFT_TIME_MS`, `REST*` y `CONFIG_PMW3610_PM` |

## Guia de modificaciones frecuentes

### Cambiar una tecla normal

Editar `config/keyball61.keymap`, buscar el layer y reemplazar el binding.

```c
&kp A
```

por ejemplo:

```c
&kp B
```

### Hacer que una tecla active una capa mientras se mantiene

Usar `&mo`:

```c
&mo SYM
```

### Hacer tap = tecla y hold = layer

Usar `&lt`:

```c
&lt FUN ENTER
```

### Hacer tap = tecla y hold = modificador

Usar `&mt`:

```c
&mt LCTRL A
```

### Hacer que una tecla alterne una capa

Usar `&tog`:

```c
&tog MOUSE
```

### Hacer que una tecla tenga hold momentaneo y tap toggle

Crear o reutilizar un hold-tap custom como `mouse_hold_toggle`:

```c
&mouse_hold_toggle MOUSE MOUSE
```

### Agregar una macro de texto

Declarar en `macros`:

```c
macros {
    ejemplo: ejemplo {
        compatible = "zmk,behavior-macro";
        #binding-cells = <0>;
        wait-ms = <40>;
        tap-ms = <40>;
        bindings = <&kp H &kp O &kp L &kp A>;
    };
};
```

Y usarla en un layer:

```c
&ejemplo
```

### Agregar un combo

Agregar en el nodo `combos`:

```c
combo_escape {
    timeout-ms = <80>;
    key-positions = <0 1>;
    layers = <QWRT>;
    bindings = <&kp ESC>;
};
```

Primero confirmar las posiciones fisicas en `keyball61.dtsi` o mediante el SVG generado.

### Cambiar sensibilidad del trackball

Editar `config/boards/shields/keyball61/keyball61_right.conf`:

```conf
CONFIG_PMW3610_CPI=1200
```

### Cambiar que capa activa scroll del trackball

Actualizar los `#define` de `config/keyball61.keymap` y tambien `scroll-layers` en `keyball61_right.overlay`.

```c
#define SCROLL 4
```

```c
scroll-layers = <4>;
```

Ambos deben coincidir.

### Cambiar que capa activa precision/snipe

Actualizar `SNIPE` y `snipe-layers`:

```c
#define SNIPE 1
```

```c
snipe-layers = <1>;
```

Y ajustar sensibilidad en `keyball61_right.conf`:

```conf
CONFIG_PMW3610_SNIPE_CPI=400
```

### Bloquear movimiento del trackball en ciertas capas

Modificar el subnodo `trackball_lock`:

```c
trackball_lock {
    layers = <1 2 3 5>;
    bindings = <&none>, <&none>, <&none>, <&none>;
    tick = <1>;
};
```

Cada entrada de `layers` debe tener una entrada correspondiente en `bindings`.

## GitHub Actions

### Build de firmware

`.github/workflows/build.yml` delega la compilacion al workflow reusable de ZMK:

```yaml
name: Build ZMK Firmware
on: [push, pull_request, workflow_dispatch]

jobs:
  build:
    uses: zmkfirmware/zmk/.github/workflows/build-user-config.yml@v0.3
```

El workflow lee `build.yaml`, descarga dependencias segun `config/west.yml` y genera los UF2.
