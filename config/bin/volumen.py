#!/usr/bin/env python3
import subprocess
import sys

def adjust_volume(value):
    try:
        # Si el valor tiene el formato % o %+/- lo ajustamos.
        if value.endswith('%+') or value.endswith('%-'):
            subprocess.run(['amixer', 'set', 'Master', value], check=True)
            print(f"Volumen ajustado a {value}")
        else:
            print("Valor inválido. Usa el formato '10%+' o '10%-'.")
            sys.exit(1)
    except Exception as e:
        print(f"Error al ajustar el volumen: {e}")
        sys.exit(1)

def main():
    if len(sys.argv) != 2:
        print("Uso: volumen <valor>%+ o <valor>%-")
        sys.exit(1)

    # Tomamos el argumento directamente de la línea de comandos
    value = sys.argv[1]

    # Llamamos a la función que ajusta el volumen
    adjust_volume(value)

if __name__ == "__main__":
    main()

