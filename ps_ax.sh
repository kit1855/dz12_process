#!/bin/bash

get_tty_name() {
    local pid=$1
    local tty_nr=$(awk '{print $7}' /proc/$pid/stat 2>/dev/null)

    [ -z "$tty_nr" ] && echo "?" && return;

    local major=$(( (tty_nr >> 8) & 0xFFF ))  # 12 бит для major
    local minor=$(( (tty_nr & 0xFF) | ((tty_nr >> 12) & 0xFFF00) ))

    case $major in
        0)   echo "?" ;;            # нет терминала
        4)   echo "tty$minor" ;;    # виртуальные консоли (tty1-tty63)
        5)   echo "tty" ;;          # /dev/tty (текущий терминал)
        136) echo "pts/$minor" ;;   # псевдотерминалы
        3)   echo "ttyp$minor" ;;   # старые BSD псевдотерминалы (редко)
        7)   echo "ttyS$minor" ;;   # последовательные порты (COM)
        8)   echo "ttyS$minor" ;;   # последовательные порты
        204) echo "ttyACM$minor" ;; # USB модемы
        188) echo "ttyUSB$minor" ;; # USB-COM адаптеры
        *)   echo "unknown (major=$major)" ;;
    esac
}

get_stat_like_ps() {
    local pid=$1
    local stat_file="/proc/$pid/stat"

    [ ! -f "$stat_file" ] && echo "?" && return

    # Читаем все нужные поля
    read -r pid_ cmd state ppid pgrp session tty_nr tpgid flags minflt cminflt majflt cmajflt utime stime cutime cstime priority nice num_threads itrealvalue starttime vsize rss rsslim startcode endcode startstack kstkesp kstkeip signal blocked sigignore sigcatch wchan nswap cnswap exit_signal processor rt_priority policy delayacct_blkio_ticks guest_time cguest_time < <(cat "$stat_file")

    # Начинаем с базового состояния
    result="$state"

    # Флаг s: лидер сеанса (PID == session)
    [ "$pid_" = "$session" ] && result="${result}s"

    # Флаг +: в группе переднего плана (pgrp == tpgid)
    [ "$pgrp" = "$tpgid" ] && result="${result}+"

    # Флаг <: высокий приоритет (nice < 0)
    [ "$nice" -lt 0 ] && result="${result}<"

    # Флаг N: низкий приоритет (nice > 0)
    [ "$nice" -gt 0 ] && result="${result}N"

    # Флаг l: многопоточный процесс (количество потоков > 1)
    [ "$num_threads" -gt 1 ] && result="${result}l"

    echo "$result"
}

get_time() {
    local pid=$1
    local ticks=$(awk '{print $14+$15}' "/proc/$pid/stat" 2>/dev/null)
    local seconds=$(( ticks / $(getconf CLK_TCK) ))
    printf "%d:%02d\n" $((seconds / 60)) $((seconds % 60))
}

get_command() {
    local pid=$1
    local cmdline=$(cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ' | tr -d '\n' | sed 's/[[:space:]]*$//')

    if [ ${#cmdline} -gt 1 ]; then
        echo "${cmdline:0:80}"
    else
        local comm=$(cat /proc/$pid/comm 2>/dev/null | tr -d '\n')
        if [ -n "$comm" ]; then
            echo "[$comm]"
        else
            echo "[?]"
        fi
    fi
}

echo "    PID    PPID TTY      STAT   TIME COMMAND"

cd /proc
for pid in $(ls -d [0-9]* 2>/dev/null | sort -n); do
column_PID=$(printf "%7d" "$pid")
current_ppid=$(awk '{print $4}' "/proc/$pid/stat" 2>/dev/null)
column_PPID=$(printf "%7s" "$current_ppid")
column_TTY=$(printf "%-8s" "$(get_tty_name "$pid")")
column_STAT=$(printf "%-6s" "$(get_stat_like_ps "$pid")")
column_TIME=$(printf "%-6s" "$(get_time "$pid")")
column_COMMAND=$(get_command "$pid")
echo "$column_PID $column_PPID $column_TTY $column_STAT $column_TIME $column_COMMAND"
done
