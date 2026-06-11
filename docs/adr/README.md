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
