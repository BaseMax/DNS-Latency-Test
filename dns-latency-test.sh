#!/bin/bash

TEST_DOMAIN="download.docker.com"
PING_TIMEOUT=10
TEMP_RESULTS_FILE=$(mktemp)
DNS_LIST_FILE="dns_servers.txt"

COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'
COLOR_GREEN='\033[0;32m'
COLOR_RESET='\033[0m'

if [[ ! -f $DNS_LIST_FILE ]]; then
    echo "Error: $DNS_LIST_FILE not found!"
    exit 1
fi

echo "Testing DNS latency (Max: ${PING_TIMEOUT}s)..."
echo "------------------------------------------------------"
echo "DNS Server          Ping (ms)   Query Time (ms)"
echo "------------------------------------------------------"

check_ping_latency() {
    local dns_ip=$1
    ping -c 1 -W "$PING_TIMEOUT" "$dns_ip" | awk -F'=' '/time=/ {print $4}' | cut -d' ' -f1
}

check_dns_response_time() {
    local dns_ip=$1
    dig @$dns_ip $TEST_DOMAIN +stats +time="$PING_TIMEOUT" | awk '/Query time:/ {print $4}'
}

run_dns_test() {
    local dns_ip=$1
    local ping_time response_time color

    ping_time=$(check_ping_latency "$dns_ip")
    if [[ -z "$ping_time" ]]; then
        printf "%-20s ${COLOR_RED}Timeout${COLOR_RESET}   ${COLOR_RED}Unreachable${COLOR_RESET}\n" "$dns_ip" >> "$TEMP_RESULTS_FILE"
        return
    fi

    response_time=$(check_dns_response_time "$dns_ip")
    [[ -z "$response_time" ]] && response_time="Timeout"

    if [[ "$response_time" == "Timeout" ]]; then
        color="$COLOR_RED"
    elif [[ "$response_time" -lt 50 ]]; then
        color="$COLOR_GREEN"
    elif [[ "$response_time" -lt 150 ]]; then
        color="$COLOR_YELLOW"
    else
        color="$COLOR_RED"
    fi

    printf "%-20s ${COLOR_GREEN}%s ms${COLOR_RESET}   ${color}%s ms${COLOR_RESET}\n" "$dns_ip" "$ping_time" "$response_time" >> "$TEMP_RESULTS_FILE"
}

while read -r dns_ip; do
    [[ -n "$dns_ip" ]] && run_dns_test "$dns_ip" &
done < "$DNS_LIST_FILE"

sleep "$PING_TIMEOUT"
wait

sort -nk3 "$TEMP_RESULTS_FILE" 2>/dev/null
rm -f "$TEMP_RESULTS_FILE"

echo "------------------------------------------------------"

fastest_dns=$(awk '$3 ~ /^[0-9]+$/ {print $0}' "$TEMP_RESULTS_FILE" | sort -nk3 | head -n 1)
slowest_dns=$(awk '$3 ~ /^[0-9]+$/ {print $0}' "$TEMP_RESULTS_FILE" | sort -nk3 | tail -n 1)

echo -e "\n🚀 Fastest DNS: ${COLOR_GREEN}${fastest_dns}${COLOR_RESET}"
echo -e "🐢 Slowest DNS: ${COLOR_RED}${slowest_dns}${COLOR_RESET}"
