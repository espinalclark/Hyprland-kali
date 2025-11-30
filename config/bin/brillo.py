#!/usr/bin/env python3
import subprocess
import sys

def adjust_brightness(value):
    try:
        # Permitir formatos como 10%+ o 10%-
        if value.endswith('%+') or value.endswith('%-'):
            subprocess.run(['brightnessctl', 'set', value], check=True)
            print(f"Brillo ajustado a {value}")
        else:
            print("Valor inválido. Usa el formato '10%+' o '10%-'.")
            sys.exit(1)
    except Exception as e:
        print(f"Error al ajustar el brillo: {e}")
        sys.exit(1)

def main():
    if len(sys.argv) != 2:
        print("Uso: brillo <valor>%+ o <valor>%-")
        sys.exit(1)

    value = sys.argv[1]
    adjust_brightness(value)

if __name__ == "__main__":
    main()

