#!/bin/bash
no='\033[0m'		# Color Reset
ok='\033[32;01m'    # Green Ok
err='\033[31;01m'	# Error red
warn='\033[1;33m'   # Yellow
blue='\033[1;34m'   # Blue
purp='\033[1;35m'   # Purple
cyan='\033[1;36m'   # Cyan
white='\033[1;37m'  # White
# echo -e "${warn}[k8s installer]${no} ${cyan}Установка необходимого софта${no}"
# apt-get update && \
# apt-get install -y \
#     wget \
#     curl
# echo -e "${warn}[k8s installer]${no} ${cyan}Смена mac-адреса сервера${no}"
# macchanger -r --permanent eth0
# echo -e "${warn}[k8s installer]${no} ${cyan}Добавление серверов в hosts-файлы${no}"
str1=$2
if [[ "${str1: -1}" = " " ]]; then
  str1="${str1%?}"
fi
str2=$4
if [[ "${str2: -1}" = " " ]]; then
  str2="${str2%?}"
fi
strm=$1
if [[ "${strm: -1}" = " " ]]; then
  strm="${strm%?}"
fi
strw=$3
if [[ "${strw: -1}" = " " ]]; then
  strw="${strw%?}"
fi
spce=" "
dmin=".loc"
mapfile -d' ' -t ipsm <<< "$str1"
mapfile -d' ' -t ipsw <<< "$str2"
mapfile -d' ' -t nmsm <<< "$strm"
mapfile -d' ' -t nmsw <<< "$strw"
count=0
for ip in "${ipsw[@]}"
do
  string="$ip ${nmsw[count]} ${nmsw[count]}.loc"
  display=$(echo "$string" | tr '\n' ' ')
  string=$(echo "$display" | tr -s " ")
  if [[ "${string: -6:1}" = " " ]]; then
    string=${string::-6}${string: -5}
  fi
  echo "$string" >> /etc/hosts
  ((count++))
done
for ip in "${ipsm[@]}"
do
  string="$ip ${nmsm[count]} ${nmsm[count]}.loc"
  display=$(echo "$string" | tr '\n' ' ')
  string=$(echo "$display" | tr -s " ")
  if [[ "${string: -6:1}" = " " ]]; then
    string=${string::-6}${string: -5}
  fi
  echo "$string" >> /etc/hosts
  ((count++))
done