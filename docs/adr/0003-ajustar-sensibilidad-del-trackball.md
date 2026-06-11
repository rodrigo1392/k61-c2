# ADR 0003: Ajustar sensibilidad normal y snipe del PMW3610

## Estado

Aceptado.

## Commit relacionado

- `6989ace` - `velocidad raton 2`

## Contexto

El repo base configura el PMW3610 con sensibilidad normal relativamente baja y modo snipe mas alto. En el uso actual se busca que el modo normal tenga desplazamiento mas agil y que el modo snipe sea de precision fina.

Diferencia observada frente al repo base:

```conf
# repo base
CONFIG_PMW3610_CPI=400
CONFIG_PMW3610_SNIPE_CPI=800

# repo actual
CONFIG_PMW3610_CPI=1200
CONFIG_PMW3610_SNIPE_CPI=400
```

## Decision

Usar `CONFIG_PMW3610_CPI=1200` para el movimiento normal y `CONFIG_PMW3610_SNIPE_CPI=400` para el modo snipe.

## Consecuencias

El modo normal queda mas rapido y el modo snipe queda mas lento y preciso. Esto hace que `SNIPE` sea semanticamente consistente: no es un segundo modo rapido, sino un modo de apuntado fino.

## Archivos afectados

- `config/boards/shields/keyball61/keyball61_right.conf`

## Como revertir o ajustar

Editar:

```conf
CONFIG_PMW3610_CPI=1200
CONFIG_PMW3610_SNIPE_CPI=400
```

Subir `CPI` aumenta sensibilidad; bajarlo reduce sensibilidad. Si el cursor se siente demasiado rapido en uso normal, bajar `CONFIG_PMW3610_CPI`. Si el snipe no es suficientemente preciso, bajar `CONFIG_PMW3610_SNIPE_CPI`.
