# ADRs del repo k61-c2

Este directorio registra decisiones de arquitectura y configuracion que explican por que este repo se separa del repo base [`tangbonze/zmk-config-Keyball61`](https://github.com/tangbonze/zmk-config-Keyball61).

No todo cambio de keymap necesita ADR. En particular, los commits automaticos `[Draw] ...` generados por `keymap-drawer` normalmente no son decisiones nuevas: son artefactos derivados del `.keymap`. La regla practica es crear ADR cuando el cambio afecta el modelo mental de uso o mantenimiento del teclado.

## ADRs actuales

| ADR | Tema | Commits relacionados |
| --- | --- | --- |
| [0001](0001-usar-repo-tangbonze-como-base.md) | Usar el repo de tangbonze como punto de partida. | historial inicial del fork |
| [0002](0002-automatizar-push-build-descarga-e-instalacion.md) | Automatizar commit, push, espera, descarga e instalacion del firmware derecho. | `5059262`, `95ec37d`, `842d828` |
| [0003](0003-ajustar-sensibilidad-del-trackball.md) | Cambiar CPI normal y CPI snipe del PMW3610. | `6989ace` |
| [0004](0004-reorganizar-keymap-sin-fijarlo-en-readme.md) | Mantener el README centrado en modelo ZMK y no en posiciones estables de teclas. | `269de49`, `66d6f59`, `eb84845`, `2e36170` |
| [0005](0005-bloquear-trackball-por-capas.md) | Sustituir automouse por bloqueo explicito del trackball en capas seleccionadas. | `2f83d46`, `7782a73`, `251ead8`, `041e3c4` |
| [0006](0006-modelar-mouse-scroll-lock-con-capas-y-comportamientos.md) | Mouse, scroll y lock como modos compuestos mediante layers, combos, hold-tap y tap-dance. | `3d32284`, `73c52b5`, `29ce45b`, `1a0b42e`, `74d485c`, `2c2b2da`, `3dbd0d5` |
| [0007](0007-volver-a-comportamiento-base-con-qwrt-local.md) | Volver al comportamiento base manteniendo QWRT local. | pendiente |
| [0008](0008-ajustar-trackball-y-controles-basicos.md) | Ajustar trackball, acceso a simbolos, espacio, enter y controles basicos de mouse. | pendiente |
| [0009](0009-bloquear-trackball-fuera-de-modos-de-puntero.md) | Bloquear trackball fuera de `MOUSE`, `SCROLL` y `SNIPE`. | pendiente |
| [0010](0010-agregar-layer-trackbless.md) | Agregar layer `TRACKBLESS` como QWRT con trackball bloqueado. | pendiente |
| [0011](0011-reorganizar-fila-inferior-y-scroll-direccional.md) | Reorganizar fila inferior, herencia de mouse/scroll y flechas en `SCROLL`. | pendiente |
| [0012](0012-ajustar-accesos-fun-trackbless-y-delete.md) | Ajustar acceso global a `FUN`, limitar toggle de `TRACKBLESS` y duplicar `DEL` en `SCROLL`. | pendiente |
| [0013](0013-priorizar-scroll-sobre-trackbless.md) | Priorizar `SCROLL` sobre `TRACKBLESS` para salir del modo bloqueado. | pendiente |
| [0014](0014-ajustar-salida-mouse-scroll.md) | Ajustar acceso a `SCROLL` desde `MOUSE` y salida a `QWRT`. | pendiente |
| [0015](0015-ajustar-fun-numerico-y-scroll-mouse.md) | Ajustar `FUN` numerico y acceso a `SCROLL` desde `MOUSE`. | pendiente |
| [0016](0016-eliminar-layer-num.md) | Eliminar `NUM` y renumerar layers activos. | pendiente |
| [0017](0017-reorganizar-layers-automouse-y-blocked.md) | Reorganizar layers, automouse y bloqueo total. | pendiente |
| [0018](0018-agregar-superfun.md) | Agregar layer `SUPERFUN` para atajos exclusivos por sistema operativo. | pendiente |
| [0019](0019-reordenar-mouse-trackbless.md) | Reordenar `MOUSE` y `TRACKBLESS` para permitir hold momentaneo desde mouse. | pendiente |
