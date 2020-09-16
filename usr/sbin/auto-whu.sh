#!/bin/sh
if [[ ! -f /etc/auto-whu.conf ]]; then
	echo "ERROR: Configuration file not found!"
	echo "[`date +"%Y-%m-%d-%H-%M"`] ERROR: Configuration file not found" >> /tmp/auto-whu.log
	exit
else
	source /etc/auto-whu.conf
fi
if [[ -z "$username" || -z "$pwd" ]]; then
	echo "ERROR: Either username or pwd is not set in configuration file"
	echo "[`date +"%Y-%m-%d-%H-%M"`] ERROR: Either username or pwd is not set in configuration file '/etc/auto-whu.conf'" >> /tmp/auto-whu.log
	exit
fi
while true; do
    ping -w1 -W1 -c 1 baidu.com
    if [[ $? = 0 ]]; then
		echo "INFO: Still online, next check in 1 minute"
        echo "[`date +"%Y-%m-%d-%H-%M"`] INFO: Still online, next check in 1 minute" >> /tmp/auto-whu.log
    else
		echo "WARNING: Check failed, offline, trying to reconnect"
        echo "[`date +"%Y-%m-%d-%H-%M"`] WARNING: Check failed, offline, trying to reconnect" >> /tmp/auto-whu.log
        curl -d "username=$username&pwd=$pwd" "http://172.19.1.9:8080/eportal/userV2.do?method=login&param=true&`curl baidu.com|grep -oP "(?<=\?).*(?=\')"`"
		ping -w1 -W1 -c 1 baidu.com
		if [[ $? = 0 ]]; then
			echo "INFO: (Re)connection successful" >> /tmp/auto-whu.log
			echo "[`date +"%Y-%m-%d-%H-%M"`] INFO: (Re)connection successful" >> /tmp/auto-whu.log
		else
			reconnect=1
			while [[ $reconnect -le 5 ]]; do
				echo "WARNING: (Re)connection failed for $reconnect time(s), retrying in 5 seconds"
				echo "[`date +"%Y-%m-%d-%H-%M"`] WARNING: (Re)connection failed for $reconnect time(s), retrying in 5 seconds"
				if [[ $? = 0 ]]; then
					echo "INFO: (Re)connection successful" >> /tmp/auto-whu.log
					echo "[`date +"%Y-%m-%d-%H-%M"`] INFO: (Re)connection successful" >> /tmp/auto-whu.log		
					break
				fi
				let reconnect++
			done
			if [[ $reconnect = 5 ]]; then
				echo "ERROR: (Re)connection failed after 5 retries, check your credential and network connection."
				echo "[`date +"%Y-%m-%d-%H-%M"`] ERROR: (Re)connection failed after 5 retries, check your credential and network connection." >> /tmp/auto-whu.log
				exit
			fi
		fi
    fi
    sleep 60
done
exit