#!/bin/bash
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