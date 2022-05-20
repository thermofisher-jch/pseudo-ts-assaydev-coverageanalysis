#!/bin/bash

history="hist_size.csv"

basedir="$(basename `pwd`)"
artifact="$(echo $basedir | sed 's/pseudo-//')"
state_now="$(cat state_now.dat)"

for line in `grep '^${artifact}' "${history}"`
do
	match_to="$(echo $line | awk -F, '{print $6}')"
	if [${match_to} == ${state_now}]
	then
		url="$(echo $line | awk -F, '{ print "http://nfs.ssfisilon2.itw/Valkyrie/AssayDev/TSDx/AssayDev/updates/"$1"_"$2"_"$3".deb" }')"
		wget "${url}"
		file="$(basename ${url})"
		echo $file > output.name
		exit 0
	fi
done

echo "artifact not found"
exit 1
