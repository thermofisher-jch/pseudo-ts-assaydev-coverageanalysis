#!/bin/bash

history="./hist_size.csv"

# Strip csd-genexus- and psuedo- prefixes away from working directory name
# to get the artifact name of project being build
basedir="$(basename "$(pwd)")"
artifact="$(echo "${basedir}" | sed 's/csd-genexus-//' | sed 's/pseudo-//')"
echo "${artifact}"

# Inspect checked in state file to understand what version we are pretending
# to be building a component of the bundle for.
state_now="$(cat state_now.dat)"
echo "${state_now}"

# Find the line for the component that will belong in the bundle whose
# version was given by ${state_now} and pull it by FTP, simulating a genuine
# build.
for line in $(grep "^${artifact}" "${history}")
do
	echo "${line}"
	match_to="$(echo $line | awk -F, '{print $8}')"
	echo "${match_to}"
	if [[ "${match_to}" == "${state_now}" ]]
	then
		url="$(echo "${line}" | awk -F, '{ print "http://lemon.itw/"$4"/TSDx/AssayDev/updates/"$1"_"$2"_"$3".deb" }')"
		wget "${url}"
		file="$(basename "${url}")"
		file_name_length="$(($(echo "${file}" | wc -c) - 1))"
		build_output_name="$(echo "${file}" | head -"${file_name_length}c" | tee build_output_name.dat)"
		cat > uploadBuildSpec.yaml << EOF
{
    "files": [
        {
            "pattern": "./${build_output_name}",
	    "target": "csd-genexus-debian-dev/${build_output_name}",
            "props": "test_prop=test_value;magic=wand;deb.distribution=bionic;deb.component=main;deb.architecture=amd64"
        }
    ]
}
EOF

		exit 0
	fi
done

echo "artifact not found"
exit 1
