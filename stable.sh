#!/usr/bin/env bash
# =====================================================================
# Stable — Installer/Manager (RU/EN), styled like Blockcast script
# Target: Ubuntu/Debian (root required)
# Version: 1.2.0
# =====================================================================
set -Eeuo pipefail

# -----------------------------
# Colors / UI
# -----------------------------
cG=$'\033[0;32m'; cC=$'\033[0;36m'; cB=$'\033[0;34m'; cR=$'\033[0;31m'
cY=$'\033[1;33m'; cM=$'\033[1;35m'; c0=$'\033[0m'; cBold=$'\033[1m'; cDim=$'\033[2m'

ok()   { echo -e "${cG}[OK]${c0} ${*}"; }
info() { echo -e "${cC}[INFO]${c0} ${*}"; }
warn() { echo -e "${cY}[WARN]${c0} ${*}"; }
err()  { echo -e "${cR}[ERROR]${c0} ${*}"; }
hr()   { echo -e "${cDim}────────────────────────────────────────────────────────${c0}"; }

logo(){ 
  echo -e '\033[0;35m'
  echo -e ' ███████████  ███████████      ███████    ███████████ █████ ███████████    ██████   █████    ███████    ██████████   ██████████  █████████ '
  echo -e '░░███░░░░░███░░███░░░░░███   ███░░░░░███ ░░███░░░░░░█░░███ ░█░░░███░░░█   ░░██████ ░░███   ███░░░░░███ ░░███░░░░███ ░░███░░░░░█ ███░░░░░███'
  echo -e ' ░███    ░███ ░███    ░███  ███     ░░███ ░███   █ ░  ░███ ░   ░███  ░     ░███░███ ░███  ███     ░░███ ░███   ░░███ ░███  █ ░ ░███    ░░░ '
  echo -e ' ░██████████  ░██████████  ░███      ░███ ░███████    ░███     ░███        ░███░░███░███ ░███      ░███ ░███    ░███ ░██████   ░░█████████ '
  echo -e ' ░███░░░░░░   ░███░░░░░███ ░███      ░███ ░███░░░█    ░███     ░███        ░███ ░░██████ ░███      ░███ ░███    ░███ ░███░░█    ░░░░░░░░███'
  echo -e ' ░███         ░███    ░███ ░░███     ███  ░███  ░     ░███     ░███        ░███  ░░█████ ░░███     ███  ░███    ███  ░███ ░   █ ███    ░███'
  echo -e ' █████        █████   █████ ░░░███████░   █████       █████    █████       █████  ░░█████ ░░░███████░   ██████████   ██████████░░█████████'
  echo -e '░░░░░        ░░░░░   ░░░░░    ░░░░░░░    ░░░░░       ░░░░░    ░░░░░       ░░░░░    ░░░░░    ░░░░░░░    ░░░░░░░░░░   ░░░░░░░░░░  ░░░░░░░░░  '
  echo -e '\e[0m'
  echo -e "\nПриватное сообщество о нодах Profit Nodes - https://t.me/ProfitNodes_bot\n"
}

# -----------------------------
# App constants
# -----------------------------
APP_NAME="Stable"
SERVICE_NAME="stabled"
BIN_PATH="/usr/bin/stabled"
HOME_DIR="/root/.stabled"
CHAIN_ID="stabletestnet_2201-1"

STABLED_URL="https://stable-testnet-data.s3.us-east-1.amazonaws.com/stabled-1.1.1-linux-amd64-testnet.tar.gz"
GENESIS_ZIP_URL="https://stable-testnet-data.s3.us-east-1.amazonaws.com/stable_testnet_genesis.zip"
RPC_CFG_ZIP_URL="https://stable-testnet-data.s3.us-east-1.amazonaws.com/rpc_node_config.zip"
SNAPSHOT_URL="https://stable-snapshot.s3.eu-central-1.amazonaws.com/snapshot.tar.lz4"

GENESIS_SHA256_EXPECTED="66afbb6e57e6faf019b3021de299125cddab61d433f28894db751252f5b8eaf2"

# Базовые peers (официальные из документации Stable)
PEERS="5ed0f977a26ccf290e184e364fb04e268ef16430@37.187.147.27:26656,128accd3e8ee379bfdf54560c21345451c7048c7@37.187.147.22:26656"
# Резервный набор из 10 пиров (если оставить ввод пустым)
BACKUP_PEERS="e8dc4eb1aed53078d90209c7d8d19d10e79e40bb@62.84.184.22:26656,babe0a3c95868b13cafe31d3473ab646268b7ceb@217.76.62.42:26656,9b9897064ed6a27f3e44d3269ebe9bc06e1ba233@217.76.55.225:26656,91947248cd012523a7b8cfe40791e09465031396@38.242.158.172:26656,86dab3dc399c33ff9770fd089f51125d004a2fe3@130.185.118.7:26656,0bbbed1c8c054f66d45e81a11520456f42e7fca7@45.8.132.10:26656,68a099f9fcf3a3fcff6e549105d206125b51d973@62.169.31.251:26656,0a09e1e1c96f3e8be3204bf10d35ac64294ca826@109.199.108.76:26656,5db9f874c394590ce45c7d946fbd1a1afbf01d21@5.189.136.244:26656,d941c5214bd00b2652a638397c1121fa4a51eae4@89.117.58.6:26656"

SCRIPT_VERSION="1.2.0"
LANG="ru"

# -----------------------------
# GitHub bootstrap (set to YOUR repo raw URLs)
# -----------------------------
GITHUB_REPO_RAW="https://raw.githubusercontent.com/Sshadow84/Stable-Full-Node---Installation-Management-Scripts/main"
SNAP_HELPER="/usr/local/bin/stable-apply-snapshot.sh"
SNAP_HELPER_URL="${GITHUB_REPO_RAW}/stable-apply-snapshot.sh"
MANAGER_URL="${GITHUB_REPO_RAW}/stable-monitor.sh"

SNAP_SERVICE="stable-apply-snapshot.service"
SNAP_TIMER="stable-apply-snapshot.timer"

# -----------------------------
# Language
# -----------------------------
choose_lang(){
  clear; logo
  echo -e "\n${cBold}${cM}Select language / Выберите язык${c0}"
  echo -e "1) 🇷🇺 Русский"
  echo -e "2) 🇬🇧 English"
  read -rp "> " a
  case "${a:-}" in
    2) LANG="en" ;;
    *) LANG="ru" ;;
  esac
}

tr(){
  local k="${1:-}"; [[ -z "$k" ]] && return 0
  if [[ "$LANG" == "en" ]]; then
    case "$k" in
      need_root)   echo "Run as root: sudo ./$(basename "$0")" ;;
      press)       echo "Press Enter to return to menu..." ;;
      menu_title)  echo "${APP_NAME} Node" ;;
      m1) echo "Initialize server environment";;
      m2) echo "Deploy Stable node";;
      m3) echo "Start node service";;
      m4) echo "View event log";;
      m5) echo "Node operation info";;
      m6) echo "Restart service";;
      m7) echo "Complete node removal";;
      m8) echo "Show binary version";;
      m9) echo "Health check";;
      m10) echo "Quick sync (snapshot)";;
      m11) echo "Auto-sync scheduler";;
      m12) echo "Update peer list";;
      m13) echo "Auto-detect upgrades";;
      m14) echo "Install target version";;
      m15) echo "Restore previous version";;
      m16) echo "Archive critical data";;
      m17) echo "Change node ports";;
      m0) echo "Terminate";;

      prep_start)  echo "Updating APT and installing dependencies...";;
      prep_done)   echo "Server is ready.";;
      prep_firewall) echo "Configuring firewall...";;
      prep_firewall_done) echo "Firewall configured (port 26656 opened)";;
      ask_moniker) echo "📝 Enter a UNIQUE name for your node (moniker):";;
      ask_moniker_empty) echo "⚠️  Name cannot be empty! Enter moniker.";;
      ask_moniker_ascii) echo "⚠️  Use only Latin letters, numbers, dash (-) and underscore (_)";;
      ask_moniker_ok) echo "✅ Node name set:";;
      bin_fetch)   echo "Downloading and installing stabled binary...";;
      init_node)   echo "Initializing node with chain-id ${CHAIN_ID}...";;

      genesis_fetch) echo "Fetching genesis...";;
      genesis_ok)    echo "genesis checksum OK.";;
      genesis_bad)   echo "genesis checksum mismatch";;

      cfg_fetch)   echo "Fetching prebuilt configs (config.toml, app.toml)...";;
      cfg_patch)   echo "Patching configs (peers, RPC, limits, CORS, moniker)...";;

      svc_write)   echo "Writing systemd service ${SERVICE_NAME}.service...";;
      svc_enable)  echo "Enabling service...";;
      install_done) echo "Installation completed.";;
      start_ok)    echo "Node started.";;
      restart_ok)  echo "Node restarted.";;
      remove_ask)  echo "Remove binary, service and all node data? [y/N]:";;
      remove_cancel) echo "Canceled.";;
      remove_done) echo "Node and its logs removed.";;
      invalid_choice) echo "Invalid choice.";;
      
      backup_title) echo "Keys Backup";;
      backup_not_installed) echo "Node is not installed. Nothing to backup.";;
      backup_copying) echo "Copying critical files...";;
      backup_archiving) echo "Creating archive...";;
      backup_success) echo "✅ Backup created successfully!";;
      backup_location) echo "📁 Backup location";;
      backup_download) echo "💡 Download to your PC: scp root@YOUR_SERVER_IP:";;
      
      ports_title) echo "Change Node Ports";;
      ports_current) echo "Current ports:";;
      ports_checking) echo "Checking for port conflicts...";;
      ports_conflict) echo "⚠️  Port conflict detected!";;
      ports_suggest) echo "Suggested new ports:";;
      ports_confirm) echo "Apply these changes?";;
      ports_stopping) echo "Stopping node service...";;
      ports_updating_config) echo "Updating config.toml...";;
      ports_updating_service) echo "Updating systemd service...";;
      ports_opening_firewall) echo "Opening firewall ports...";;
      ports_firewall_ok) echo "✅ Firewall: port opened";;
      ports_restarting) echo "Starting node with new ports...";;
      ports_success) echo "✅ Ports successfully changed!";;
      ports_failed) echo "⚠️  Failed to start node. Check logs:";;
      ports_new_ports) echo "New ports configuration:";;
      ports_check_hint) echo "Check node status with:";;

      ver_title)   echo "Stable Node Version";;
      ver_bin)     echo "Binary version:";;
      ver_fail)    echo "Failed to read binary version";;

      hc_title)    echo "Stable Node Health Check";;
      hc_running)  echo "Service is running";;
      hc_stopped)  echo "Service is not running";;
      hc_synced)   echo "Node is synced";;
      hc_syncing)  echo "Node is syncing";;
      hc_peers_ok) echo "Connected peers:";;
      hc_peers_low)echo "Low peer count:";;
      hc_disk_ok)  echo "Disk usage";;
      hc_disk_high)echo "High disk usage";;
      hc_mem_ok)   echo "Memory usage";;
      hc_mem_high) echo "High memory usage";;
      hc_done)     echo "Health Check Complete";;

      snap_ask)    echo "Apply snapshot now? [y/N]:";;
      snap_do)     echo "Applying snapshot...";;
      snap_done)   echo "Snapshot applied.";;
      snap_menu_ask) echo "This will reset data and apply latest official snapshot. Continue? [y/N]:";;
      snap_reset)  echo "Stopping service and resetting (unsafe-reset-all --keep-addr-book)...";;
      snap_dl)     echo "Downloading snapshot from official S3...";;
      snap_clean)  echo "Removing old data directory...";;
      snap_extract)echo "Extracting snapshot to node home...";;
      snap_start)  echo "Starting node service...";;
      snap_ok)     echo "Snapshot applied.";;

      auto_title)  echo "Snapshot automation (systemd timer)";;
      auto_time)   echo "Enter daily time (HH:MM, 24h) for snapshot (default 00:15):";;
      auto_set_ok) echo "Timer installed/updated and enabled.";;
      auto_bad_tm) echo "Invalid time format. Use HH:MM (00..23:00..59).";;
      auto_need)   echo "Snapshot helper not found at ${SNAP_HELPER} and couldn't fetch.";;
      auto_now)    echo "Triggered snapshot run (service started).";;
      auto_dis_ok) echo "Timer disabled.";;
      auto_stat)   echo "Timer status:";;
      auto_fetch)  echo "Fetch/Update helper from GitHub";;
      fetchh_title) echo "Fetch/Update helper from GitHub";;
      fetchh_try)   echo "Downloading helper to";;
      fetchh_ok)    echo "Helper installed/updated:";;
      fetchh_fail)  echo "Failed to download helper from";;

      peers_title)   echo "Update peers & restart";;
      peers_prompt)  echo "Paste a comma-separated peers list (nodeID@ip:port). Leave empty to use backup peers:";;
      peers_backup)  echo "Backed up config.toml";;
      peers_write)   echo "Writing peers/seeds/PEX settings to config.toml";;
      peers_done)    echo "Peers updated.";;
      peers_keepbak) echo "No input provided; using BACKUP_PEERS.";;
      restart_now)   echo "Restarting service...";;
      show_peers_count) echo "Connected peers:";;
      show_sync)     echo "Catching up:";;

      upg_title)   echo "Upgrade stabled";;
      upg_detect)  echo "Detected upgrade target from logs:";;
      upg_enter)   echo "Enter target version (default 1.1.1):";;
      upg_ver_ask) echo "Version to install (e.g., 1.1.1):";;
      upg_dl_fail) echo "Download failed";;
      upg_ex_fail) echo "Extract failed";;
      upg_done)    echo "Upgrade complete.";;
      upg_nobak)   echo "No backups found";;
      upg_rb_done) echo "Rollback done ->";;
    esac
  else
    case "$k" in
      need_root)   echo "запусти от root: sudo ./$(basename "$0")" ;;
      press)       echo "Нажмите Enter для возврата в меню..." ;;
      menu_title)  echo "Нода ${APP_NAME}" ;;
      m1) echo "Инициализация окружения сервера";;
      m2) echo "Развернуть ноду Stable";;
      m3) echo "Старт службы ноды";;
      m4) echo "Просмотр журнала событий";;
      m5) echo "Информация о работе ноды";;
      m6) echo "Перезапуск службы";;
      m7) echo "Полное удаление ноды";;
      m8) echo "Показать версию бинаря";;
      m9) echo "Проверка состояния (Health check)";;
      m10) echo "Быстрая синхронизация (snapshot)";;
      m11) echo "Планировщик автосинхронизации";;
      m12) echo "Актуализация списка пиров";;
      m13) echo "Автообнаружение обновлений";;
      m14) echo "Установить целевую версию";;
      m15) echo "Восстановить предыдущую версию";;
      m16) echo "Архивация критических данных";;
      m17) echo "Изменить порты ноды";;
      m0) echo "Завершить работу";;

      prep_start)  echo "Обновляю APT и ставлю зависимости...";;
      prep_done)   echo "Сервер готов.";;
      prep_firewall) echo "Настраиваю файрвол...";;
      prep_firewall_done) echo "Файрвол настроен (порт 26656 открыт)";;
      ask_moniker) echo "📝 Введите УНИКАЛЬНОЕ имя вашей ноды (moniker):";;
      ask_moniker_empty) echo "⚠️  Имя не может быть пустым! Введите moniker.";;
      ask_moniker_ascii) echo "⚠️  Используйте только латинские буквы, цифры, дефис (-) и подчеркивание (_)";;
      ask_moniker_ok) echo "✅ Имя ноды установлено:";;
      bin_fetch)   echo "Скачиваю и устанавливаю бинарь stabled...";;
      init_node)   echo "Инициализирую ноду с chain-id ${CHAIN_ID}...";;

      genesis_fetch) echo "Скачиваю genesis...";;
      genesis_ok)    echo "genesis checksum ок.";;
      genesis_bad)   echo "checksum genesis не совпал";;

      cfg_fetch)   echo "Скачиваю готовые конфиги (config.toml, app.toml)...";;
      cfg_patch)   echo "Правлю конфиги (peers, RPC, лимиты, CORS, moniker)...";;

      svc_write)   echo "Пишу systemd сервис ${SERVICE_NAME}.service...";;
      svc_enable)  echo "Включаю сервис...";;
      install_done) echo "Установка завершена.";;

      start_ok)    echo "Нода запущена.";;
      restart_ok)  echo "Нода перезапущена.";;
      remove_ask)  echo "Удалить бинарь, сервис и все данные ноды? [y/N]:";;
      remove_cancel) echo "Отмена.";;
      remove_done) echo "Нода и её логи удалены.";;
      invalid_choice) echo "Неверный выбор.";;
      
      backup_title) echo "Резервное копирование ключей";;
      backup_not_installed) echo "Нода не установлена. Нечего бэкапить.";;
      backup_copying) echo "Копирую критически важные файлы...";;
      backup_archiving) echo "Создаю архив...";;
      backup_success) echo "✅ Бекап успешно создан!";;
      backup_location) echo "📁 Местоположение бекапа";;
      backup_download) echo "💡 Скачать на ПК: scp root@ВАШ_IP_СЕРВЕРА:";;
      
      ports_title) echo "Изменение портов ноды";;
      ports_current) echo "Текущие порты:";;
      ports_checking) echo "Проверяю конфликты портов...";;
      ports_conflict) echo "⚠️  Обнаружен конфликт портов!";;
      ports_suggest) echo "Предлагаемые новые порты:";;
      ports_confirm) echo "Применить эти изменения?";;
      ports_stopping) echo "Останавливаю службу ноды...";;
      ports_updating_config) echo "Обновляю config.toml...";;
      ports_updating_service) echo "Обновляю systemd сервис...";;
      ports_opening_firewall) echo "Открываю порты в файрволе...";;
      ports_firewall_ok) echo "✅ Файрвол: порт открыт";;
      ports_restarting) echo "Запускаю ноду с новыми портами...";;
      ports_success) echo "✅ Порты успешно изменены!";;
      ports_failed) echo "⚠️  Не удалось запустить ноду. Проверьте логи:";;
      ports_new_ports) echo "Новая конфигурация портов:";;
      ports_check_hint) echo "Проверьте статус ноды командами:";;

      ver_title)   echo "Версия ноды Stable";;
      ver_bin)     echo "Версия ноды:";;
      ver_fail)    echo "Не удалось получить версию бинаря";;

      hc_title)    echo "Проверка состояния ноды Stable";;
      hc_running)  echo "Сервис запущен";;
      hc_stopped)  echo "Сервис не запущен";;
      hc_synced)   echo "Нода синхронизирована";;
      hc_syncing)  echo "Нода синхронизируется";;
      hc_peers_ok) echo "Подключённых пиров:";;
      hc_peers_low)echo "Мало пиров:";;
      hc_disk_ok)  echo "Занято диска";;
      hc_disk_high)echo "Высокая загрузка диска";;
      hc_mem_ok)   echo "Занято памяти";;
      hc_mem_high) echo "Высокая загрузка памяти";;
      hc_done)     echo "Проверка завершена";;

      snap_ask)    echo "Подтянуть снапшот сейчас? [y/N]:";;
      snap_do)     echo "Применяю снапшот...";;
      snap_done)   echo "Снапшот применён.";;
      snap_menu_ask) echo "Будет сброшена БД и применён оф. снапшот. Продолжить? [y/N]:";;
      snap_reset)  echo "Останавливаю сервис и делаю reset (unsafe-reset-all --keep-addr-book)...";;
      snap_dl)     echo "Скачиваю снапшот с оф. S3...";;
      snap_clean)  echo "Удаляю старые данные ноды...";;
      snap_extract)echo "Распаковываю снапшот...";;
      snap_start)  echo "Запускаю сервис ноды...";;
      snap_ok)     echo "Снапшот применён.";;
      
      auto_title)  echo "Автоматизация снапшотов (systemd timer)";;
      auto_time)   echo "Укажи ежедневное время (HH:MM, 24ч), по умолчанию 00:15:";;
      auto_set_ok) echo "Таймер установлен/обновлён и включён.";;
      auto_bad_tm) echo "Неверный формат времени. Используй HH:MM (00..23:00..59).";;
      auto_need)   echo "Helper не найден и не удалось скачать.";;
      auto_now)    echo "Ручной запуск снапшота инициирован (service started).";;
      auto_dis_ok) echo "Таймер отключён.";;
      auto_stat)   echo "Статус таймера:";;
      auto_fetch)  echo "Подтянуть/обновить helper из GitHub";;

      peers_title)   echo "Обновить peers и перезапустить";;
      peers_prompt)  echo "Вставьте список peers через запятую (nodeID@ip:port). Оставьте пусто — возьмём BACKUP_PEERS:";;
      peers_backup)  echo "Сделан бэкап config.toml";;
      peers_write)   echo "Записываю peers/seeds/PEX в config.toml";;
      peers_done)    echo "Peers обновлены.";;
      peers_keepbak) echo "Ввода нет: использую BACKUP_PEERS.";;
      restart_now)   echo "Перезапускаю сервис...";;
      show_peers_count) echo "Подключённых пиров:";;
      show_sync)     echo "Статус догоняния (catching_up):";;

      upg_title)   echo "Обновление stabled";;
      upg_detect)  echo "Найдена версия из логов:";;
      upg_enter)   echo "Укажи целевую версию (по умолчанию 1.1.1):";;
      upg_ver_ask) echo "Версия для установки (например, 1.1.1):";;
      upg_dl_fail) echo "Ошибка загрузки";;
      upg_ex_fail) echo "Ошибка распаковки";;
      upg_done)    echo "Обновление завершено.";;
      upg_nobak)   echo "Бэкапов не найдено";;
      upg_rb_done) echo "Откат выполнен ->";;
    esac
  fi
}

pause(){ read -rp "$(tr press)" _; }
need(){ command -v "$1" &>/dev/null || { err "not found '$1'"; exit 1; }; }

# -----------------------------
# Prepare server
# -----------------------------
prepare_server(){
  info "$(tr prep_start)"
  apt update && apt upgrade -y
  apt install -y curl wget tar unzip jq lz4 pv
  
  # Открыть P2P порт для входящих соединений
  if command -v ufw >/dev/null 2>&1; then
    info "$(tr prep_firewall)"
    ufw allow 26656/tcp comment 'Stable Node P2P' >/dev/null 2>&1 || true
    ufw allow 26656/udp comment 'Stable Node P2P' >/dev/null 2>&1 || true
    ok "$(tr prep_firewall_done)"
  fi
  
  ok "$(tr prep_done)"
}

# -----------------------------
# Helper fetcher (used inside menu 11 too)
# -----------------------------
_fetch_with(){
  # _fetch_with <url> <dst>
  local url="$1" dst="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$dst"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$dst" "$url"
  else
    return 127
  fi
}

fetch_helper(){
  local url="${SNAP_HELPER_URL}"
  local dst="${SNAP_HELPER}"
  echo -e "${cBold}${cM}$(tr fetchh_title)${c0}"
  info "$(tr fetchh_try) ${dst}"
  mkdir -p "$(dirname "$dst")"
  if ! _fetch_with "$url" "$dst"; then
    err "$(tr fetchh_fail) $url"
    return 1
  fi
  chmod +x "$dst"
  ok "$(tr fetchh_ok) $dst"
}

ensure_helper(){
  if [[ -x "$SNAP_HELPER" ]]; then
    return 0
  fi
  fetch_helper || { err "$(tr auto_need)"; return 1; }
}

# -----------------------------
# Install node
# -----------------------------
install_node(){
  need wget; need unzip; need jq; need curl

  local ARCH DL_URL
  ARCH="$(dpkg --print-architecture 2>/dev/null || uname -m || echo unknown)"
  case "$ARCH" in
    amd64|x86_64) DL_URL="$STABLED_URL" ;;
    arm64|aarch64) DL_URL="${STABLED_URL/linux-amd64/linux-arm64}" ;;
    *)  warn "Неизвестная архитектура: ${ARCH}. Пытаюсь использовать amd64-архив."
        DL_URL="$STABLED_URL" ;;
  esac
  info "arch=${ARCH}; url=${DL_URL}"

  # ОБЯЗАТЕЛЬНЫЙ ввод moniker с проверками
  while true; do
    read -r -p "$(tr ask_moniker) " MONIKER
    
    # Проверка на пустоту
    if [ -z "$MONIKER" ]; then
      warn "$(tr ask_moniker_empty)"
      continue
    fi
    
    # Проверка на ASCII (только латиница, цифры, - и _)
    if ! echo "$MONIKER" | grep -qE '^[a-zA-Z0-9_-]+$'; then
      warn "$(tr ask_moniker_ascii)"
      continue
    fi
    
    # Всё OK - выходим из цикла
    break
  done
  
  ok "$(tr ask_moniker_ok) $MONIKER"

  info "$(tr bin_fetch)"
  cd /root
  wget -O stabled.tar.gz "$DL_URL"
  tar -xvzf stabled.tar.gz
  mv -f stabled "$BIN_PATH"
  chmod +x "$BIN_PATH"
  rm -f stabled.tar.gz
  "$BIN_PATH" version || true

  info "$(tr init_node)"
  "$BIN_PATH" init "$MONIKER" --chain-id "$CHAIN_ID"

  info "$(tr genesis_fetch)"
  wget -O stable_testnet_genesis.zip "$GENESIS_ZIP_URL"
  unzip -o stable_testnet_genesis.zip
  cp -f genesis.json "$HOME_DIR/config/genesis.json"
  sha=$(sha256sum "$HOME_DIR/config/genesis.json" | awk '{print $1}')
  if [[ "$sha" != "$GENESIS_SHA256_EXPECTED" ]]; then
    warn "$(tr genesis_bad): got $sha, expected $GENESIS_SHA256_EXPECTED"
  else
    ok "$(tr genesis_ok)"
  fi

  info "$(tr cfg_fetch)"
  wget -O rpc_node_config.zip "$RPC_CFG_ZIP_URL"
  unzip -o rpc_node_config.zip
  cp -f config.toml "$HOME_DIR/config/config.toml"
  cp -f app.toml "$HOME_DIR/config/app.toml"

  info "$(tr cfg_patch)"
  sed -i "s/^moniker = \".*\"/moniker = \"${MONIKER}\"/" "$HOME_DIR/config/config.toml"
  sed -i 's/^cors_allowed_origins = .*/cors_allowed_origins = ["*"]/' "$HOME_DIR/config/config.toml"
  sed -i "s|^persistent_peers = \".*\"|persistent_peers = \"${PEERS}\"|" "$HOME_DIR/config/config.toml"
  sed -i 's/^max_num_inbound_peers = .*/max_num_inbound_peers = 50/' "$HOME_DIR/config/config.toml"
  sed -i 's/^max_num_outbound_peers = .*/max_num_outbound_peers = 30/' "$HOME_DIR/config/config.toml"

  sed -i 's/^\(\s*enable\s*=\s*\).*/\1true/' "$HOME_DIR/config/app.toml"
  sed -i 's|^\(\s*address\s*=\s*\).*|\1"0.0.0.0:8545"|' "$HOME_DIR/config/app.toml"
  sed -i 's|^\(\s*ws-address\s*=\s*\).*|\1"0.0.0.0:8546"|' "$HOME_DIR/config/app.toml"
  sed -i 's/^\(\s*allow-unprotected-txs\s*=\s*\).*/\1true/' "$HOME_DIR/config/app.toml"

  info "$(tr svc_write)"
  tee /etc/systemd/system/${SERVICE_NAME}.service >/dev/null <<EOF
[Unit]
Description=Stable Daemon Service
After=network-online.target
Wants=network-online.target

[Service]
User=root
ExecStart=${BIN_PATH} start --chain-id ${CHAIN_ID}
Restart=always
RestartSec=3
LimitNOFILE=65535
StandardOutput=journal
StandardError=journal
SyslogIdentifier=${SERVICE_NAME}

[Install]
WantedBy=multi-user.target
EOF

  info "$(tr svc_enable)"
  systemctl daemon-reload
  systemctl enable ${SERVICE_NAME}

  read -r -p "$(tr snap_ask) " use_snap
  if [[ "${use_snap,,}" =~ ^y ]]; then
    info "$(tr snap_do)"
    mkdir -p /root/stable-backup /root/snapshot
    cp -r "$HOME_DIR/data" /root/stable-backup/ 2>/dev/null || true
    cd /root/snapshot
    wget -c "$SNAPSHOT_URL" -O snapshot.tar.lz4
    rm -rf "$HOME_DIR/data"/* || true
    pv snapshot.tar.lz4 | tar -I lz4 -xf - -C "$HOME_DIR/"
    rm -f snapshot.tar.lz4
    ok "$(tr snap_done)"
  fi

  ok "$(tr install_done)"
}

# -----------------------------
# Snapshot: manual (menu option 10)
# -----------------------------
apply_official_snapshot(){
  need wget; need curl; need jq; need pv; need lz4

  read -r -p "$(tr snap_menu_ask) " yn
  if ! [[ "${yn,,}" =~ ^y ]]; then
    warn "$(tr remove_cancel)"
    return
  fi

  info "$(tr snap_reset)"
  systemctl stop "${SERVICE_NAME}" || true

  if command -v stabled &>/dev/null; then
    stabled comet unsafe-reset-all --home "$HOME_DIR" --keep-addr-book || true
  else
    "${BIN_PATH}" comet unsafe-reset-all --home "$HOME_DIR" --keep-addr-book || true
  fi

  info "$(tr snap_dl)"
  mkdir -p /root/snapshot
  cd /root/snapshot
  rm -f snapshot.tar.lz4
  wget -c "$SNAPSHOT_URL" -O snapshot.tar.lz4

  info "$(tr snap_clean)"
  rm -rf "$HOME_DIR/data" || true

  info "$(tr snap_extract)"
  pv snapshot.tar.lz4 | tar -I lz4 -xf - -C "$HOME_DIR/"
  rm -f snapshot.tar.lz4

  info "$(tr snap_start)"
  systemctl start "${SERVICE_NAME}"

  sleep 10
  local STATUS CATCH HEIGHT
  STATUS=$(curl -s localhost:26657/status || true)
  CATCH=$(jq -r '.result.sync_info.catching_up // empty' <<<"$STATUS" 2>/dev/null || echo "")
  HEIGHT=$(jq -r '.result.sync_info.latest_block_height // empty' <<<"$STATUS" 2>/dev/null || echo "")

  if [[ "$CATCH" == "false" && -n "$HEIGHT" ]]; then
    ok "$(tr snap_ok) height=${HEIGHT}"
  else
    warn "$(tr snap_ok) (node still syncing, height=${HEIGHT:-unknown})"
  fi
}

# -----------------------------
# Snapshot automation (systemd timer) — menu 11
# -----------------------------
install_or_update_timer(){
  ensure_helper || return 1
  local when input hh mm
  echo
  read -r -p "$(tr auto_time) " input
  input="${input:-00:15}"

  if [[ "$input" =~ ^([01]?[0-9]|2[0-3]):([0-5][0-9])$ ]]; then
    hh=$(printf "%02d" "${BASH_REMATCH[1]}")
    mm=$(printf "%02d" "${BASH_REMATCH[2]}")
  else
    err "$(tr auto_bad_tm)"; return 1
  fi

  when="*-*-* ${hh}:${mm}:00"

  tee /etc/systemd/system/${SNAP_SERVICE} >/dev/null <<EOF
[Unit]
Description=Stable: apply snapshot (oneshot)
Wants=network-online.target
After=network-online.target ${SERVICE_NAME}.service

[Service]
Type=oneshot
User=root
Environment=STABLE_SERVICE=${SERVICE_NAME}
Environment=STABLE_HOME=${HOME_DIR}
Environment=SNAPSHOT_URL=${SNAPSHOT_URL}
ExecStart=${SNAP_HELPER}
Nice=10
IOSchedulingClass=idle
EOF

  tee /etc/systemd/system/${SNAP_TIMER} >/dev/null <<EOF
[Unit]
Description=Stable: daily snapshot (${hh}:${mm})

[Timer]
OnCalendar=${when}
Persistent=true
RandomizedDelaySec=300
AccuracySec=1min

[Install]
WantedBy=timers.target
EOF

  systemctl daemon-reload
  systemctl enable --now ${SNAP_TIMER}
  ok "$(tr auto_set_ok)  (${hh}:${mm})"
}

disable_timer(){
  systemctl disable --now ${SNAP_TIMER} 2>/dev/null || true
  ok "$(tr auto_dis_ok)"
}

trigger_now(){
  ensure_helper || return 1
  systemctl start ${SNAP_SERVICE}
  ok "$(tr auto_now)"
}

timer_status(){
  echo; echo -e "${cBold}${cM}$(tr auto_stat)${c0}"
  systemctl status ${SNAP_TIMER} --no-pager 2>/dev/null || true
  echo
  systemctl status ${SNAP_SERVICE} --no-pager 2>/dev/null || true
  echo
  echo -e "${cDim}Next timers:${c0}"
  systemctl list-timers --all | grep -E "${SNAP_TIMER}|NEXT|^$" || true
}

snapshot_auto_menu(){
  while true; do
    clear; hr
    echo -e "${cBold}${cM}=== $(tr auto_title) ===${c0}\n"
    echo -e "1) ⏰ Install/Update daily timer"
    echo -e "2) ⛔ Disable timer"
    echo -e "3) ▶️  Run snapshot now (oneshot)"
    echo -e "4) 📊 Status"
    echo -e "5) 🔄 $(tr auto_fetch)"
    echo -e "0) ◀️  Back"
    hr
    read -rp "> " a
    case "${a:-}" in
      1) install_or_update_timer; pause ;;
      2) disable_timer;           pause ;;
      3) trigger_now;             pause ;;
      4) timer_status;            pause ;;
      5) fetch_helper;            pause ;;
      0) break ;;
      *) err "Invalid choice";    pause ;;
    esac
  done
}

# -----------------------------
# Update peers interactively & restart service — menu 12
# -----------------------------
update_peers_and_restart(){
  need jq; need curl
  local CFG="$HOME_DIR/config/config.toml"
  [[ -f "$CFG" ]] || { err "config.toml not found at $CFG"; return 1; }

  clear; hr
  echo -e "${cBold}${cM}$(tr peers_title)${c0}\n"
  echo -e "${cDim}$CFG${c0}\n"

  local CURRENT
  CURRENT="$(awk -F'= ' '/^\s*persistent_peers\s*=/{print $2}' "$CFG" | sed -E 's/^"|"//g')"
  if [[ -n "$CURRENT" ]]; then
    echo -e "${cDim}current persistent_peers:${c0}\n$CURRENT\n"
  fi

  local NEWPEERS
  read -r -p "$(tr peers_prompt) " NEWPEERS

  cp -a "$CFG" "$CFG.bak.$(date +%F_%H-%M-%S)"
  info "$(tr peers_backup)"

  if [[ -z "$NEWPEERS" ]]; then
    NEWPEERS="$BACKUP_PEERS"
    info "$(tr peers_keepbak)"
  fi

  info "$(tr peers_write)"
  sed -i '/^\s*seeds\s*=/d;/^\s*persistent_peers\s*=/d;/^\s*pex\s*=/d;/^\s*persistent_peers_max_dial_period\s*=/d;/^\s*addr_book_strict\s*=/d' "$CFG"

  awk -v NEWPEERS="$NEWPEERS" '
    BEGIN{in_p2p=0}
    /^\[p2p\]/{
      print "[p2p]";
      print "laddr = \"tcp://0.0.0.0:26656\"";
      print "seeds = \"\"";
      print "persistent_peers = \"" NEWPEERS "\"";
      print "persistent_peers_max_dial_period = \"0s\"";
      print "pex = true";
      print "addr_book_strict = false";
      in_p2p=1; next
    }
    in_p2p && /^\[/ { in_p2p=0 }
    !in_p2p { print }
  ' "$CFG" > /tmp/config.toml.tmp && mv /tmp/config.toml.tmp "$CFG"

  ok "$(tr peers_done)"

  info "$(tr restart_now)"
  systemctl restart "${SERVICE_NAME}"
  sleep 3
  local NPEERS CATCH
  NPEERS="$(curl -s localhost:26657/net_info | jq -r '.result.n_peers' 2>/dev/null || echo "?")"
  CATCH="$(curl -s localhost:26657/status   | jq -r '.result.sync_info.catching_up' 2>/dev/null || echo "?")"
  echo -e "${cG}✓${c0} $(tr show_peers_count) ${NPEERS}"
  echo -e "${cG}✓${c0} $(tr show_sync) ${CATCH}"
}

# -----------------------------
# Upgrade helpers — menu 13..15
# -----------------------------
upgrade_binary_to(){
  need wget
  local VER="$1" ARCH URL TS BAK
  [[ -z "$VER" ]] && { err "Version is empty"; return 1; }

  ARCH="$(dpkg --print-architecture 2>/dev/null || uname -m || echo amd64)"
  case "$ARCH" in
    amd64|x86_64)
      URL="https://stable-testnet-data.s3.us-east-1.amazonaws.com/stabled-${VER}-linux-amd64-testnet.tar.gz"
      ;;
    arm64|aarch64)
      URL="https://stable-testnet-data.s3.us-east-1.amazonaws.com/stabled-${VER}-linux-arm64-testnet.tar.gz"
      ;;
    *)
      warn "Unknown arch: ${ARCH}; using amd64"
      URL="https://stable-testnet-data.s3.us-east-1.amazonaws.com/stabled-${VER}-linux-amd64-testnet.tar.gz"
      ;;
  esac

  clear; hr
  echo -e "${cBold}${cM}$(tr upg_title) -> v${VER}${c0}\nURL: ${URL}\n"
  systemctl stop "${SERVICE_NAME}" || true

  TS="$(date +%Y%m%d-%H%M%S)"
  if [[ -x "${BIN_PATH}" ]]; then
    BAK="${BIN_PATH}.bak-${TS}"
    cp -f "${BIN_PATH}" "${BAK}" && echo -e "${cDim}Backup:${c0} ${BAK}"
  fi

  cd /root
  rm -f stabled.tar.gz stabled
  if ! wget -O stabled.tar.gz "$URL"; then
    err "$(tr upg_dl_fail)"; return 1
  fi
  if ! tar -xvzf stabled.tar.gz; then
    err "$(tr upg_ex_fail)"; return 1
  fi

  mv -f stabled "${BIN_PATH}"
  chmod +x "${BIN_PATH}"
  rm -f stabled.tar.gz

  echo -e "${cG}✓${c0} New binary:"
  "${BIN_PATH}" version || true

  systemctl start "${SERVICE_NAME}"
  sleep 3
  echo -e "${cDim}Quick status:${c0}"
  curl -s localhost:26657/status | jq -r '.result.node_info.network,.result.sync_info.catching_up,.result.sync_info.latest_block_height' || true
  ok "$(tr upg_done)"
}

auto_upgrade(){
  local VER
  VER="$(journalctl -u ${SERVICE_NAME} -n 2000 --no-pager 2>/dev/null \
        | sed -n 's/.*Upgrade to v\([0-9.]\+\).*/\1/p' | tail -n1)"
  if [[ -z "$VER" ]]; then
    read -r -p "$(tr upg_enter) " VER
    VER="${VER:-1.1.1}"
  else
    echo "$(tr upg_detect) v${VER}"
  fi
  upgrade_binary_to "$VER"
}

manual_upgrade(){
  local VER
  read -r -p "$(tr upg_ver_ask) " VER
  [[ -z "$VER" ]] && { err "Version empty"; return 1; }
  upgrade_binary_to "$VER"
}

rollback_binary(){
  local LAST
  LAST="$(ls -1t ${BIN_PATH}.bak-* 2>/dev/null | head -n1 || true)"
  if [[ -z "$LAST" ]]; then
    err "$(tr upg_nobak)"; return 1
  fi
  systemctl stop "${SERVICE_NAME}" || true
  cp -f "${LAST}" "${BIN_PATH}"
  chmod +x "${BIN_PATH}"
  systemctl start "${SERVICE_NAME}"
  ok "$(tr upg_rb_done) $(\"${BIN_PATH}\" version 2>/dev/null || echo unknown)"
}

# -----------------------------
# Basic controls
# -----------------------------
start_node(){ systemctl start ${SERVICE_NAME}; ok "$(tr start_ok)"; }
logs_node(){ journalctl -u ${SERVICE_NAME} -f -n 200; }
status_node(){ systemctl status ${SERVICE_NAME}; }
restart_node(){ systemctl restart ${SERVICE_NAME}; ok "$(tr restart_ok)"; }

remove_node(){
  read -r -p "$(tr remove_ask) " yn
  [[ "${yn,,}" =~ ^y ]] || { warn "$(tr remove_cancel)"; return; }

  for UNIT in "${SERVICE_NAME}" "stable"; do
    systemctl stop "$UNIT" 2>/dev/null || true
    systemctl disable "$UNIT" 2>/dev/null || true
    rm -f "/etc/systemd/system/${UNIT}.service" 2>/dev/null || true
  done
  systemctl disable --now ${SNAP_TIMER} 2>/dev/null || true
  rm -f "/etc/systemd/system/${SNAP_SERVICE}" "/etc/systemd/system/${SNAP_TIMER}" 2>/dev/null || true
  systemctl daemon-reload

  pkill -f "[s]tabled" 2>/dev/null || true
  sleep 1
  pkill -9 -f "[s]tabled" 2>/dev/null || true

  rm -f "$HOME_DIR/data/LOCK" "$HOME_DIR/data/application.db/LOCK" "$HOME_DIR/data/snapshots/LOCK" 2>/dev/null || true

  rm -rf "$HOME_DIR" /root/snapshot /root/stable-backup /tmp/stable_genesis /tmp/rpc_cfg 2>/dev/null || true
  rm -f  "$BIN_PATH" 2>/dev/null || true
  rm -rf /var/log/stabled 2>/dev/null || true

  ok "$(tr remove_done)"
}

version_node(){
  clear; hr
  echo -e "${cBold}${cM}=== $(tr ver_title) ===${c0}\n"
  if out="$("${BIN_PATH}" version 2>/dev/null)"; then
    echo -e "${cG}✓${c0} $(tr ver_bin) ${out}"
  elif out="$(stabled version 2>/dev/null)"; then
    echo -e "${cG}✓${c0} $(tr ver_bin) ${out}"
  else
    err "$(tr ver_fail)"
  fi
}

# -----------------------------
# Real-time monitoring
# -----------------------------
start_realtime_monitor(){
  need curl; need jq
  
  # Определяем порты
  RPC_PORT_DETECT="26657"
  P2P_PORT_DETECT="26656"
  if [ -f "$HOME_DIR/config/config.toml" ]; then
    RPC_LINE=$(awk '/^\[rpc\]/,/^\[/ {if (/^laddr =/) print}' "$HOME_DIR/config/config.toml" | head -1)
    if [ -n "$RPC_LINE" ]; then
      RPC_CUSTOM=$(echo "$RPC_LINE" | grep -oP ':\d+' | grep -oP '\d+' | tail -1)
      [ -n "$RPC_CUSTOM" ] && [ "$RPC_CUSTOM" != "0" ] && RPC_PORT_DETECT="$RPC_CUSTOM"
    fi
    
    P2P_LINE=$(awk '/^\[p2p\]/,/^\[/ {if (/^laddr =/) print}' "$HOME_DIR/config/config.toml" | head -1)
    if [ -n "$P2P_LINE" ]; then
      P2P_CUSTOM=$(echo "$P2P_LINE" | grep -oP ':\d+' | grep -oP '\d+' | tail -1)
      [ -n "$P2P_CUSTOM" ] && [ "$P2P_CUSTOM" != "0" ] && P2P_PORT_DETECT="$P2P_CUSTOM"
    fi
  fi
  
  # Функция отрисовки прогресс-бара
  draw_bar_monitor() {
    local percent=$1
    local width=30
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    # Выбор цвета
    local color=$cG
    if [ $percent -ge 90 ]; then
      color=$cR
    elif [ $percent -ge 70 ]; then
      color=$cY
    fi
    
    printf "${color}["
    printf "%${filled}s" | tr ' ' '='
    printf "${c0}"
    printf "%${empty}s" | tr ' ' '-'
    printf "] ${cBold}%3d%%${c0}" $percent
  }
  
  while true; do
    clear
    
    # Заголовок
    echo -e "${cM}+===============================================================================+${c0}"
    echo -e "${cM}|${c0} ${cBold} STABLE NODE - REAL-TIME MONITOR${c0}                                          ${cM}|${c0}"
    echo -e "${cM}|${c0} ${cDim}Press Ctrl+C to exit${c0}                                                       ${cM}|${c0}"
    echo -e "${cM}+===============================================================================+${c0}"
    echo ""
    
    # NODE STATUS
    echo -e "${cC}+-----------------------------------------------------------------------------+${c0}"
    echo -e "${cC}|${c0} ${cBold} NODE STATUS${c0}                                                                ${cC}|${c0}"
    echo -e "${cC}+-----------------------------------------------------------------------------+${c0}"
    
    if systemctl is-active --quiet "${SERVICE_NAME}"; then
      echo -e "  ${cG}*${c0} Service:        ${cG}${cBold}RUNNING${c0}"
      
      STATUS_JSON=$(curl -s --connect-timeout 2 localhost:${RPC_PORT_DETECT}/status 2>/dev/null)
      NET_JSON=$(curl -s --connect-timeout 2 localhost:${RPC_PORT_DETECT}/net_info 2>/dev/null)
      
      if [ -n "$STATUS_JSON" ] && echo "$STATUS_JSON" | jq -e . >/dev/null 2>&1; then
        CATCHING_UP=$(echo "$STATUS_JSON" | jq -r '.result.sync_info.catching_up' 2>/dev/null)
        LATEST_HEIGHT=$(echo "$STATUS_JSON" | jq -r '.result.sync_info.latest_block_height' 2>/dev/null)
        
        if [ "$CATCHING_UP" == "false" ]; then
          echo -e "  ${cG}*${c0} Sync Status:    ${cG}${cBold}SYNCED${c0}"
        else
          echo -e "  ${cY}*${c0} Sync Status:    ${cY}${cBold}SYNCING...${c0}"
        fi
        
        echo -e "  ${cC}>${c0} Block Height:   ${cBold}${LATEST_HEIGHT:-N/A}${c0}"
      else
        echo -e "  ${cY}!${c0} RPC Status:     ${cY}NOT RESPONDING (port ${RPC_PORT_DETECT})${c0}"
      fi
      
      if [ -n "$NET_JSON" ]; then
        N_PEERS=$(echo "$NET_JSON" | jq -r '.result.n_peers' 2>/dev/null)
        if [ "$N_PEERS" -ge 3 ]; then
          echo -e "  ${cG}*${c0} Connected Peers: ${cG}${cBold}${N_PEERS}${c0} ${cG}(good)${c0}"
        elif [ "$N_PEERS" -gt 0 ]; then
          echo -e "  ${cY}*${c0} Connected Peers: ${cY}${cBold}${N_PEERS}${c0} ${cY}(low)${c0}"
        else
          echo -e "  ${cR}*${c0} Connected Peers: ${cR}${cBold}${N_PEERS}${c0} ${cR}(isolated)${c0}"
        fi
      fi
    else
      echo -e "  ${cR}*${c0} Service:        ${cR}${cBold}STOPPED${c0}"
    fi
    echo ""
    
    # CPU USAGE
    echo -e "${cY}+-----------------------------------------------------------------------------+${c0}"
    echo -e "${cY}|${c0} ${cBold} CPU USAGE${c0}                                                                    ${cY}|${c0}"
    echo -e "${cY}+-----------------------------------------------------------------------------+${c0}"
    
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)
    echo -ne "  Overall:        "
    draw_bar_monitor ${CPU_USAGE:-0}
    echo ""
    
    if systemctl is-active --quiet "${SERVICE_NAME}"; then
      STABLED_CPU=$(ps aux | grep "[s]tabled start" | awk '{print $3}' | cut -d'.' -f1)
      if [ -n "$STABLED_CPU" ]; then
        echo -ne "  stabled:        "
        draw_bar_monitor ${STABLED_CPU:-0}
        echo ""
      fi
    fi
    
    LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | xargs)
    CORES=$(nproc)
    echo -e "  ${cDim}Load Average:   ${cBold}${LOAD_AVG}${cDim} (${CORES} cores)${c0}"
    echo ""
    
    # MEMORY USAGE
    echo -e "${cM}+-----------------------------------------------------------------------------+${c0}"
    echo -e "${cM}|${c0} ${cBold} MEMORY USAGE${c0}                                                                 ${cM}|${c0}"
    echo -e "${cM}+-----------------------------------------------------------------------------+${c0}"
    
    MEM_INFO=$(free -m)
    MEM_TOTAL=$(echo "$MEM_INFO" | awk 'NR==2 {print $2}')
    MEM_USED=$(echo "$MEM_INFO" | awk 'NR==2 {print $3}')
    MEM_PERCENT=$((MEM_USED * 100 / MEM_TOTAL))
    
    echo -ne "  System:         "
    draw_bar_monitor ${MEM_PERCENT}
    echo -e "  ${cDim}(${MEM_USED} MB / ${MEM_TOTAL} MB)${c0}"
    
    if systemctl is-active --quiet "${SERVICE_NAME}"; then
      STABLED_RSS=$(ps aux | grep "[s]tabled start" | awk '{print $6}')
      if [ -n "$STABLED_RSS" ]; then
        STABLED_MB=$((STABLED_RSS / 1024))
        STABLED_PERCENT=$((STABLED_MB * 100 / MEM_TOTAL))
        echo -ne "  stabled:        "
        draw_bar_monitor ${STABLED_PERCENT}
        echo -e "  ${cDim}(${STABLED_MB} MB)${c0}"
      fi
    fi
    echo ""
    
    # DISK USAGE
    echo -e "${cB}+-----------------------------------------------------------------------------+${c0}"
    echo -e "${cB}|${c0} ${cBold} DISK USAGE${c0}                                                                   ${cB}|${c0}"
    echo -e "${cB}+-----------------------------------------------------------------------------+${c0}"
    
    DISK_INFO=$(df -h / | awk 'NR==2 {print $2, $3, $5}')
    DISK_TOTAL=$(echo "$DISK_INFO" | awk '{print $1}')
    DISK_USED=$(echo "$DISK_INFO" | awk '{print $2}')
    DISK_PERCENT=$(echo "$DISK_INFO" | awk '{print $3}' | tr -d '%')
    
    echo -ne "  Root (/)        "
    draw_bar_monitor ${DISK_PERCENT}
    echo -e "  ${cDim}(${DISK_USED} / ${DISK_TOTAL})${c0}"
    
    if [ -d "$HOME_DIR" ]; then
      NODE_SIZE=$(du -sh "$HOME_DIR" 2>/dev/null | awk '{print $1}')
      echo -e "  ${cDim}Node Data:      ${cBold}${NODE_SIZE:-N/A}${cDim} ($HOME_DIR)${c0}"
    fi
    echo ""
    
    # NETWORK & PORTS
    echo -e "${cG}+-----------------------------------------------------------------------------+${c0}"
    echo -e "${cG}|${c0} ${cBold} NETWORK & PORTS${c0}                                                              ${cG}|${c0}"
    echo -e "${cG}+-----------------------------------------------------------------------------+${c0}"
    
    if [ "$P2P_PORT_DETECT" == "26656" ]; then
      echo -e "  ${cC}>${c0} P2P Port:       ${cBold}${P2P_PORT_DETECT}${c0} ${cDim}(standard)${c0}"
    else
      echo -e "  ${cC}>${c0} P2P Port:       ${cBold}${P2P_PORT_DETECT}${c0} ${cY}(custom)${c0}"
    fi
    
    if [ "$RPC_PORT_DETECT" == "26657" ]; then
      echo -e "  ${cC}>${c0} RPC Port:       ${cBold}${RPC_PORT_DETECT}${c0} ${cDim}(standard)${c0}"
    else
      echo -e "  ${cC}>${c0} RPC Port:       ${cBold}${RPC_PORT_DETECT}${c0} ${cY}(custom)${c0}"
    fi
    
    if ss -tlnp | grep -q ":${P2P_PORT_DETECT}"; then
      echo -e "  ${cG}*${c0} P2P Listening:  ${cG}YES${c0}"
    else
      echo -e "  ${cR}*${c0} P2P Listening:  ${cR}NO${c0}"
    fi
    
    if ss -tlnp | grep -q ":${RPC_PORT_DETECT}"; then
      echo -e "  ${cG}*${c0} RPC Listening:  ${cG}YES${c0}"
    else
      echo -e "  ${cR}*${c0} RPC Listening:  ${cR}NO${c0}"
    fi
    echo ""
    
    # Footer
    echo -e "${cM}===============================================================================${c0}"
    CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${cDim}Last update: ${cBold}${CURRENT_TIME}${cDim}  |  Refresh: ${cBold}3s${c0}"
    echo -e "${cDim}Tip: Press ${cBold}Ctrl+C${cDim} to exit${c0}"
    echo ""
    
    sleep 3
  done
}

# -----------------------------
# Health Check
# -----------------------------
health_check(){
  need curl; need jq
  # Сразу запускаем интерактивный мониторинг
  start_realtime_monitor
}

# -----------------------------
# Backup keys
# -----------------------------
backup_keys(){
  info "$(tr backup_title)"
  
  if [ ! -d "$HOME_DIR" ]; then
    warn "$(tr backup_not_installed)"
    return
  fi

  BACKUP_ROOT="/root/stable_backups"
  TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
  BACKUP_TEMP="$BACKUP_ROOT/backup_$TIMESTAMP"
  
  mkdir -p "$BACKUP_TEMP"
  
  info "$(tr backup_copying)"
  [ -f "$HOME_DIR/config/priv_validator_key.json" ] && cp "$HOME_DIR/config/priv_validator_key.json" "$BACKUP_TEMP/" 2>/dev/null
  [ -f "$HOME_DIR/config/node_key.json" ] && cp "$HOME_DIR/config/node_key.json" "$BACKUP_TEMP/" 2>/dev/null
  [ -f "$HOME_DIR/data/priv_validator_state.json" ] && cp "$HOME_DIR/data/priv_validator_state.json" "$BACKUP_TEMP/" 2>/dev/null
  [ -f "$HOME_DIR/config/config.toml" ] && cp "$HOME_DIR/config/config.toml" "$BACKUP_TEMP/" 2>/dev/null
  [ -f "$HOME_DIR/config/app.toml" ] && cp "$HOME_DIR/config/app.toml" "$BACKUP_TEMP/" 2>/dev/null
  [ -f "$HOME_DIR/config/addrbook.json" ] && cp "$HOME_DIR/config/addrbook.json" "$BACKUP_TEMP/" 2>/dev/null
  
  info "$(tr backup_archiving)"
  cd "$BACKUP_ROOT"
  tar -czf "stable_backup_$TIMESTAMP.tar.gz" "backup_$TIMESTAMP" 2>/dev/null
  rm -rf "backup_$TIMESTAMP"
  
  BACKUP_FILE="$BACKUP_ROOT/stable_backup_$TIMESTAMP.tar.gz"
  
  ok "$(tr backup_success)"
  echo -e "${cC}$(tr backup_location): ${cBold}$BACKUP_FILE${c0}"
  echo -e "${cY}$(tr backup_download)$BACKUP_FILE ./${c0}"
  echo ""
}

# -----------------------------
# Change Ports
# -----------------------------
change_ports(){
  info "$(tr ports_title)"
  
  if [ ! -d "$HOME_DIR" ]; then
    warn "$(tr backup_not_installed)"
    return
  fi
  
  # Показываем текущие порты
  info "$(tr ports_current)"
  CURRENT_P2P=$(grep "^laddr.*tcp://0.0.0.0:" "$HOME_DIR/config/config.toml" | grep -oP ':\K[0-9]+' | head -1)
  CURRENT_RPC=$(grep "^laddr.*tcp.*26[0-9]" "$HOME_DIR/config/config.toml" | grep "rpc" -A1 | grep -oP ':\K[0-9]+' | tail -1)
  CURRENT_PROXY=$(grep "^proxy_app" "$HOME_DIR/config/config.toml" | grep -oP ':\K[0-9]+')
  CURRENT_PPROF=$(grep "^pprof_laddr" "$HOME_DIR/config/config.toml" | grep -oP ':\K[0-9]+')
  
  echo -e "${cC}  P2P:       ${cBold}${CURRENT_P2P:-26656}${c0}"
  echo -e "${cC}  RPC:       ${cBold}${CURRENT_RPC:-26657}${c0}"
  echo -e "${cC}  Proxy App: ${cBold}${CURRENT_PROXY:-26658}${c0}"
  echo -e "${cC}  pprof:     ${cBold}${CURRENT_PPROF:-6060}${c0}"
  echo ""
  
  # Проверяем занятость портов
  info "$(tr ports_checking)"
  P2P_USED=$(ss -tlnp | grep ":${CURRENT_P2P:-26656}" | grep -v "stabled" | wc -l)
  RPC_USED=$(ss -tlnp | grep ":${CURRENT_RPC:-26657}" | grep -v "stabled" | wc -l)
  
  if [ "$P2P_USED" -gt 0 ] || [ "$RPC_USED" -gt 0 ]; then
    warn "$(tr ports_conflict)"
    if [ "$P2P_USED" -gt 0 ]; then
      echo -e "${cY}  ⚠️  P2P порт ${CURRENT_P2P:-26656} занят:${c0}"
      ss -tlnp | grep ":${CURRENT_P2P:-26656}" | grep -v "stabled"
    fi
    if [ "$RPC_USED" -gt 0 ]; then
      echo -e "${cY}  ⚠️  RPC порт ${CURRENT_RPC:-26657} занят:${c0}"
      ss -tlnp | grep ":${CURRENT_RPC:-26657}" | grep -v "stabled"
    fi
    echo ""
  fi
  
  # Предлагаем новые порты
  info "$(tr ports_suggest)"
  NEW_P2P=$((${CURRENT_P2P:-26656} + 10))
  NEW_RPC=$((${CURRENT_RPC:-26657} + 10))
  NEW_PROXY=$((${CURRENT_PROXY:-26658} + 10))
  NEW_PPROF=$((${CURRENT_PPROF:-6060} + 10))
  
  echo -e "${cG}  P2P:       ${cBold}${NEW_P2P}${c0} ${cY}(было ${CURRENT_P2P:-26656})${c0}"
  echo -e "${cG}  RPC:       ${cBold}${NEW_RPC}${c0} ${cY}(было ${CURRENT_RPC:-26657})${c0}"
  echo -e "${cG}  Proxy App: ${cBold}${NEW_PROXY}${c0} ${cY}(было ${CURRENT_PROXY:-26658})${c0}"
  echo -e "${cG}  pprof:     ${cBold}${NEW_PPROF}${c0} ${cY}(было ${CURRENT_PPROF:-6060})${c0}"
  echo ""
  
  # Спрашиваем подтверждение
  read -r -p "$(tr ports_confirm) [y/N]: " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    warn "$(tr remove_cancel)"
    return
  fi
  
  # Останавливаем ноду
  info "$(tr ports_stopping)"
  systemctl stop stabled
  
  # Меняем порты в config.toml
  info "$(tr ports_updating_config)"
  sed -i "s|laddr = \"tcp://0.0.0.0:${CURRENT_P2P:-26656}\"|laddr = \"tcp://0.0.0.0:${NEW_P2P}\"|" "$HOME_DIR/config/config.toml"
  sed -i "s|laddr = \"tcp://.*:${CURRENT_RPC:-26657}\"|laddr = \"tcp://0.0.0.0:${NEW_RPC}\"|" "$HOME_DIR/config/config.toml"
  sed -i "s|proxy_app = \"tcp://.*:${CURRENT_PROXY:-26658}\"|proxy_app = \"tcp://127.0.0.1:${NEW_PROXY}\"|" "$HOME_DIR/config/config.toml"
  sed -i "s|pprof_laddr = \".*:${CURRENT_PPROF:-6060}\"|pprof_laddr = \"127.0.0.1:${NEW_PPROF}\"|" "$HOME_DIR/config/config.toml"
  
  # Меняем ExecStart в systemd
  info "$(tr ports_updating_service)"
  sed -i "s|ExecStart=.*|ExecStart=/usr/bin/stabled start --chain-id $CHAIN_ID --rpc.laddr tcp://0.0.0.0:${NEW_RPC} --p2p.laddr tcp://0.0.0.0:${NEW_P2P} --proxy_app tcp://127.0.0.1:${NEW_PROXY}|" /etc/systemd/system/stabled.service
  
  # Открываем порты в UFW
  info "$(tr ports_opening_firewall)"
  if command -v ufw &> /dev/null; then
    ufw allow ${NEW_P2P}/tcp &>/dev/null
    ufw allow ${NEW_P2P}/udp &>/dev/null
    ok "$(tr ports_firewall_ok) ${NEW_P2P}"
  fi
  
  # Перезагружаем systemd и запускаем
  info "$(tr ports_restarting)"
  systemctl daemon-reload
  systemctl start stabled
  sleep 3
  
  # Проверяем статус
  if systemctl is-active --quiet stabled; then
    ok "$(tr ports_success)"
    echo ""
    info "$(tr ports_new_ports)"
    echo -e "${cG}  P2P:       ${cBold}${NEW_P2P}${c0}"
    echo -e "${cG}  RPC:       ${cBold}${NEW_RPC}${c0}"
    echo -e "${cG}  Proxy App: ${cBold}${NEW_PROXY}${c0}"
    echo -e "${cG}  pprof:     ${cBold}${NEW_PPROF}${c0}"
    echo ""
    info "$(tr ports_check_hint)"
    echo -e "${cC}  curl -s localhost:${NEW_RPC}/status | jq .result.sync_info.catching_up${c0}"
    echo -e "${cC}  curl -s localhost:${NEW_RPC}/net_info | jq .result.n_peers${c0}"
  else
    warn "$(tr ports_failed)"
    journalctl -u stabled -n 20 --no-pager
  fi
  
  echo ""
}

# -----------------------------
# Menu
# -----------------------------
menu(){
  clear; logo; hr
  echo -e "${cBold}${cM}$(tr menu_title)${c0}\n"
  echo -e "1)  📦 $(tr m1)"
  echo -e "2)  ⚙️  $(tr m2)"
  echo -e "3)  🚀 $(tr m3)"
  echo -e "4)  📜 $(tr m4)"
  echo -e "5)  📊 $(tr m5)"
  echo -e "6)  🔄 $(tr m6)"
  echo -e "7)  🗑️  $(tr m7)"
  echo -e "8)  🏷️  $(tr m8)"
  echo -e "9)  💚 $(tr m9)"
  echo -e "10) 📸 $(tr m10)"
  echo -e "11) ⏰ $(tr m11)"
  echo -e "12) 🌐 $(tr m12)"
  echo -e "13) 🤖 $(tr m13)"
  echo -e "14) ⬆️  $(tr m14)"
  echo -e "15) ⬇️  $(tr m15)"
  echo -e "16) 💾 $(tr m16)"
  echo -e "17) 🔧 $(tr m17)"
  echo -e "0)  ❌ $(tr m0)"
  hr
  read -rp "> " c
  case "${c:-}" in
    1)  prepare_server;        pause ;;
    2)  install_node;          pause ;;
    3)  start_node;            pause ;;
    4)  logs_node ;;                 # follow
    5)  status_node;           pause ;;
    6)  restart_node;          pause ;;
    7)  remove_node;           pause ;;
    8)  version_node;          pause ;;
    9)  health_check; echo;    pause ;;
    10) apply_official_snapshot;     pause ;;
    11) snapshot_auto_menu ;;
    12) update_peers_and_restart;    pause ;;
    13) auto_upgrade;          pause ;;
    14) manual_upgrade;        pause ;;
    15) rollback_binary;       pause ;;
    16) backup_keys;           pause ;;
    17) change_ports;          pause ;;
    0)  exit 0 ;;
    *)  err "$(tr invalid_choice)";  pause ;;
  esac
}

# -----------------------------
# Bootstrap
# -----------------------------
main(){
  choose_lang
  if [[ "$EUID" -ne 0 ]]; then
    err "$(tr need_root)"; exit 1
  fi
  while true; do menu; done
}

main
