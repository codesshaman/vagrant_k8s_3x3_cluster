#!/bin/bash
touch /home/vagrant/hosts
i = 0
for word in $1
do
    string = ${2[i]} + " " + ${1[i]} + " " + ${1[i]} + ".loc"
    echo $string >> /etc/hosts
    let i++
done
i = 0
for word in $3
do
    string = ${4[i]} + " " + ${3[i]} + " " + ${3[i]} + ".loc"
    echo $string >> /etc/hosts
    let i++
done

