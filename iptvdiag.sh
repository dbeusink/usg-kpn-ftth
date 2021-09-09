#!/bin/vbash

echo -e "Running IPTV diagnostics:"

pppoe2Result=$(/opt/vyatta/bin/vyatta-op-cmd-wrapper show interfaces | awk '$1 == "pppoe2" { print $2 }')
if [ -z "$pppoe2Result" ]; then
    echo -e "1/3 \033[0;31m[Fail]\033[0m pppoe2 interface not present!"
    exit 1
else
    echo -e "1/3 \033[0;32m[Success]\033[0m pppoe2 interface is present. External IP: \033[0;36m$pppoe2Result\033[0m"
fi

kernalRoute=$(/opt/vyatta/bin/vyatta-op-cmd-wrapper show ip route | perl -n -e'/^K>\* (.+? via .+?, .+?)$/ && print $1')

if [ -z "$kernalRoute" ]; then
    echo -e "2/3 \033[0;31m[Fail]\033[0m Kernal route not present!"
    exit 1
else
    echo -e "2/3 \033[0;32m[Success]\033[0m Kernel route is present: \033[0;36m$kernalRoute\033[0m"
fi

paIn=$(/opt/vyatta/bin/vyatta-op-cmd-wrapper show ip multicast interfaces | awk '$1 == "eth0.4" { print $3 }')

if [ -z "$paIn" ]; then
    echo -e "3/3 \033[0;31m[Fail]\033[0m No multicast traffic detected!"
    exit 1
else
    paOut=$(/opt/vyatta/bin/vyatta-op-cmd-wrapper show ip multicast interfaces | awk '$5 == '$paIn' { print $1 }')
    echo -e "3/3 \033[0;32m[Success]\033[0m Multicast traffic found traveling from interface \033[0;36m$paOut\033[0m to interface eth0.4. \033[0;36m$paIn\033[0m packets."
fi

memPercentage=$(free -m | grep Mem | awk '{print ($3/$2)*100}')

if [ -z "$memPercentage" ]; then
    echo -e "\033[0;31m[Fail]\033[0m Could not load RAM percentage!"
    exit 1
else
    echo -e "\033[0;36m[Info]\033[0m Memory usage: \033[0;36m$memPercentage\033[0m %."
    logger "Checked memory usage: $memPercentage %."
fi