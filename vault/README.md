# Firmware Vault

Local cache for downloaded GitHub Actions firmware artifacts.

`scripts/install-right-firmware.sh` stores UF2 files here with this pattern:

```text
0001-commit-subject_firmware-label_shortsha.uf2
```

When the same commit and firmware label already exist here, the script reuses
the cached UF2 instead of downloading artifacts from GitHub Actions again.
