#!/bin/bash
# Generates Output from AbuseIP.com
# EX:$ ./abuseip_output.sh 8.8.8.8
#  

ip="$1"

# Testing Several Types out output
#curl -s https://www.abuseipdb.com/check/"$ip" | sed 's/<[^>]*>//g' | grep -i -A2 -e 'ISP\|hostname' | head -n 7


#curl -s https://www.abuseipdb.com/check/3"$ip" | sed 's/<[^>]*>//g' | grep -i -A3 -e 'ISP\|hostname\|data\|usage\|country' | head -n 25 | sed '/^$/d'

curl -s https://www.abuseipdb.com/check/"$ip" | sed 's/<[^>]*>//g' | grep -i -A3 'ISP$\|hostname\|database\|usage type$\|country' | tr -d '\-\-' | sed '/^$/d'
