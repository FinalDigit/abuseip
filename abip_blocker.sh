#!/bin/bash
# Generates Output from AbuseIP.com
# EX:$ ./abuseip_output.sh 8.8.8.8
# Daemon Mode --daemon $interval
# '''Runs as daemon on set interval'''
# setsid myscript.sh >/dev/null 2>&1 < /dev/null &
# while true; do
# /usr/bin/abip_blocker.sh 
# ./abip_blocker.sh
# echo "waiting..."
# sleep <interval>
# done
#
# Set CronTab --crontab $interval
# '''Sets as cron task for set interval'''
# Block Remote Host -b --block
# '''Blocks malicious network connections; configurable'''
# iptables -I INPUT -s $abip -j DROP
# Remove All Previous Connection's iptable rules
# declare -a ips; ips=$(cat connection_history); iptables -D INPUT -s ${ips[@]} -j DROP
# Analyze current connection -a --analyze --netstat
# default behavior checks connections against abuseip
# if sys.argv == true; lookup ip on abuseIP.com

ip="$1"

echo "[-]Dont Block IPS"
doNotBlockIPS=$(cat donotblock.txt)
echo "$doNotBlockIPS"
echo

# Output netstat output to file - grabs IP address from established connections
echo "[-]Gathering Connections..."
ips=$(netstat -nt | grep -w '^tcp' | grep 'ESTABLISHED' | awk '{print $5}' | awk -F: '{print $1}') 

# ips="${ips}" # Debug For Adding IPS

# Current connections sorted with no duplicates
echo "$ips" | sort -u;

# Executing logic against Connected IPS
echo -e "\n[-]Scutinize IPS against rules"
for ip in $(echo "$ips" | sort -u); do
    sleep 0.2
    echo "[*]ESTABLISHED IP: $ip"
            
        if grep -q $ip donotblock.txt; then
            echo -e "\033[91m[!]Dont Block IP: $ip\033[0m"
            continue
            
        elif grep -q $ip connection_history.txt; then
            echo -e "\033[37m[!]IP ALREADY LOGGED: $ip\033[0m"
            continue
               
        else
            echo -e "\033[33m[!]New IP Connection: $ip\033[0m"
            echo -e "[!]Processing : $ip"
            sleep 10

            # Grab AbuseIP output against IP
            abip_output=$(curl -s https://www.abuseipdb.com/check/$ip | sed 's/<[^>]*>//g' | grep -i -A3 'ISP$\|hostname\|database\|usage type$\|country' | tr -d '\-\-' | sed '/^$/d')
            
            abip="$abip_output"

            # Returned Output Variables
            reported=$(echo "$abip" | grep "Confidence of Abuse" \
            | awk -F"Abuse is" '{print $2}' | awk '{print $1}'\
            | awk -F"%" '{print $1}')
            
            confidence=reported=$(echo "$abip" | grep "This IP was reported" \
            | awk -F"reported" '{print $2}' | awk '{print $1}')
            
            isp=$(echo "$abip" | grep -A1 "^ISP")
            hostname=$(echo "$abip" | grep -A1 "Hostname")
            usage_type=$(echo "$abip" | grep -A1 "Usage Type")
            country=$(echo "$abip" | grep -A1 "Country")

            # Final Variables
            reported=$(echo $reported)
            isp=$(echo $isp | cut -d " " -f2-)
            hostname=$(echo $hostname | cut -d " " -f2-)
            usage_type=$(echo $usage_type | cut -d " " -f2-)
            country=$(echo $country | cut -d " " -f2-)

            date=$(date -u)
            echo "$ip {Reported: $reported}{Confidence: $confidence}{ISP: $isp}{Hostname(s): $hostname}{Usage Type: $usage_type}{Country: $country} $date" >> connection_history.txt
            
        fi;
done;

echo -e "\n[*]Script Finished $(date -u)"
    
exit 0    
