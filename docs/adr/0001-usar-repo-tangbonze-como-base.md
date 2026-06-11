# ADR 0001: Usar `tangbonze/zmk-config-Keyball61` como base

## Estado

Aceptado.

## Contexto

El proyecto parte de un Keyball61 con ZMK, `nice_nano_v2` y trackball PMW3610. En lugar de crear un shield desde cero, se clono o tomo como base el repo [`tangbonze/zmk-config-Keyball61`](https://github.com/tangbonze/zmk-config-Keyball61), que ya contiene una configuracion funcional para este hardware.

El repo base aporta:

- definicion del shield `keyball61_left` y `keyball61_right`;
- overlays de cada mitad;
- transformacion de matriz y layout fisico;
- configuracion del sensor PMW3610;
- `build.yaml` para compilar izquierda, derecha y `settings_reset`;
- workflow de GitHub Actions para build;
- workflow de `keymap-drawer`.

## Decision

Mantener el repo de tangbonze como referencia historica y documentar explicitamente su origen en el README.

Las personalizaciones propias se documentan como decisiones separadas cuando afectan el modelo de uso, especialmente en:

- `config/keyball61.keymap`;
- `config/boards/shields/keyball61/keyball61_right.conf`;
- `config/boards/shields/keyball61/keyball61_right.overlay`;
- `scripts/`.

## Consecuencias

El repositorio hereda una base funcional y reduce el riesgo de errores de hardware. Al mismo tiempo, se vuelve importante distinguir entre:

- configuracion heredada del repo original;
- configuracion propia;
- artefactos generados automaticamente;
- cambios experimentales de keymap.

El README debe mencionar el origen, pero no debe mezclar toda la historia del fork con la explicacion operativa. La historia de decisiones vive en ADRs.
