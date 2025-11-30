#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-}"
ARG="${2:-}"

if [[ "$ACTION" != "start" && "$ACTION" != "stop" && "$ACTION" != "status" ]]; then
  cat <<USO
Uso: vpnhtb {start|stop|status} [archivo.ovpn]
Ejemplo:
  sudo vpnhtb start startinghtb.ovpn
  sudo vpnhtb status
  sudo vpnhtb stop
USO
  exit 2
fi

# Helper: get base name and paths for a given ovpn path
make_paths() {
  local ovpn_path="$1"
  BASE_NAME="$(basename "$ovpn_path" .ovpn)"
  PID_FILE="/run/openvpn-${BASE_NAME}.pid"
  LOG_FILE="/var/log/openvpn-${BASE_NAME}.log"
  OVPN_PATH="$ovpn_path"
}

# Resolve ovpn for start: prefer explicit arg, else startinghtb.ovpn, else any .ovpn in cwd
resolve_ovpn_for_start() {
  if [[ -n "$ARG" ]]; then
    if [[ ! -f "$ARG" ]]; then
      echo "Archivo no encontrado: $ARG" >&2
      exit 3
    fi
    make_paths "$ARG"
    return
  fi

  if [[ -f "./startinghtb.ovpn" ]]; then
    make_paths "$(realpath ./startinghtb.ovpn)"
    return
  fi

  shopt -s nullglob
  local arr=(./*.ovpn)
  shopt -u nullglob
  if [[ ${#arr[@]} -gt 0 ]]; then
    make_paths "$(realpath "${arr[0]}")"
    return
  fi

  echo "No se encontró ningún archivo .ovpn en el directorio actual y no se pasó argumento." >&2
  exit 4
}

# Resolve ovpn for status/stop:
resolve_ovpn_for_status_or_stop() {
  if [[ -n "$ARG" ]]; then
    if [[ -f "$ARG" ]]; then
      make_paths "$(realpath "$ARG")"
      return
    elif [[ -f "./$ARG" ]]; then
      make_paths "$(realpath "./$ARG")"
      return
    else
      echo "Advertencia: no se encontró el archivo especificado: $ARG" >&2
    fi
  fi

  # look for pid files
  pidfiles=(/run/openvpn-*.pid)
  if [[ ${#pidfiles[@]} -eq 1 && -f "${pidfiles[0]}" ]]; then
    pidf="${pidfiles[0]}"
    base="$(basename "$pidf" .pid)"
    base="${base#openvpn-}"
    PID_FILE="$pidf"
    LOG_FILE="/var/log/openvpn-${base}.log"
    BASE_NAME="$base"
    OVPN_PATH=""
    return
  fi

  # try to find running openvpn process
  pids=$(ps -eo pid,cmd | grep '[o]penvpn' | awk '{print $1":"substr($0,index($0,$2))}')
  if [[ -n "$pids" ]]; then
    selected_line="$(echo "$pids" | grep -i 'startinghtb' || true)"
    if [[ -z "$selected_line" ]]; then
      selected_line="$(echo "$pids" | head -n1)"
    fi
    pid="$(echo "$selected_line" | cut -d: -f1)"
    cmdline="$(echo "$selected_line" | cut -d: -f2-)"
    if [[ "$cmdline" =~ --config[[:space:]]+([^[:space:]]+) ]]; then
      cfg="${BASH_REMATCH[1]}"
      if [[ -f "$cfg" ]]; then
        make_paths "$(realpath "$cfg")"
        return
      fi
    fi
    BASE_NAME="pid-${pid}"
    PID_FILE="/run/openvpn-${BASE_NAME}.pid"
    LOG_FILE="/var/log/openvpn-${BASE_NAME}.log"
    OVPN_PATH=""
    return
  fi

  echo "No se detectó ninguna instancia de OpenVPN en ejecución y no se proporcionó archivo." >&2
  exit 5
}

# ---------------------------
# START (SILENCIOSO)
# ---------------------------
start_vpn() {
  resolve_ovpn_for_start

  # If already running (pid file), silently exit
  if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    return 0
  fi

  # Ensure log dir exists (may require sudo)
  sudo mkdir -p "$(dirname "$LOG_FILE")" >/dev/null 2>&1 || true

  # Start openvpn via sudo and redirect all output to /dev/null
  # We wrap in sh -c so the redirections are executed as root.
  sudo sh -c "openvpn --config \"${OVPN_PATH}\" --daemon --writepid \"${PID_FILE}\" --log-append \"${LOG_FILE}\" >/dev/null 2>&1"

  # Wait briefly for PID to appear (but do not print anything)
  for i in {1..20}; do
    if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      return 0
    fi
    sleep 0.2
  done

  # If after waiting no pid, still return non-zero quietly
  return 1
}

# ---------------------------
# STOP and STATUS (unchanged)
# ---------------------------
stop_vpn() {
  resolve_ovpn_for_status_or_stop

  if [[ -f "$PID_FILE" ]]; then
    pid="$(cat "$PID_FILE")"
    if kill -0 "$pid" 2>/dev/null; then
      sudo kill "$pid"
      for i in {1..20}; do
        if kill -0 "$pid" 2>/dev/null; then
          sleep 0.2
        else
          break
        fi
      done
      if kill -0 "$pid" 2>/dev/null; then
        sudo kill -9 "$pid" || true
      fi
      sudo rm -f "$PID_FILE" || true
      echo "Detenido."
      return
    else
      sudo rm -f "$PID_FILE" || true
      echo "PID file eliminado."
      return
    fi
  fi

  pids=$(ps aux | grep '[o]penvpn' | grep -i 'startinghtb\|\.ovpn' | awk '{print $2}')
  if [[ -n "$pids" ]]; then
    sudo kill $pids || true
    echo "Matados procesos OpenVPN detectados."
    return
  fi

  echo "No se detectó ningún PID asociado a una VPN manejada por este script."
}

status_vpn() {
  resolve_ovpn_for_status_or_stop

  if [[ -f "$PID_FILE" ]]; then
    pid="$(cat "$PID_FILE")"
    if kill -0 "$pid" 2>/dev/null; then
      echo "OpenVPN CORRIENDO. PID: $pid"
      if [[ -n "$OVPN_PATH" ]]; then
        echo "Config: $OVPN_PATH"
      fi
      echo "Log: $LOG_FILE"
      echo
      echo "Interfaces tun/tap:"
      ip -brief addr show | grep -E 'tun|tap' || echo "(no hay interfaz tun/tap mostrada)"
      echo
      echo "Últimas 30 líneas del log:"
      sudo tail -n 30 "$LOG_FILE" || true
      return 0
    else
      echo "PID file existe pero proceso no activo. PID: $pid"
    fi
  fi

  pfull=$(ps aux | grep '[o]penvpn' || true)
  if [[ -n "$pfull" ]]; then
    echo "Se encontraron procesos openvpn:"
    echo "$pfull"
    return 0
  fi

  echo "No hay conexión OpenVPN activa detectada por el script."
  return 1
}

case "$ACTION" in
  start) start_vpn ;;
  stop) stop_vpn ;;
  status) status_vpn ;;
esac

