#!/bin/bash

matchFilesArr=()

checkFileName ()
{
fileName=$1
if [ ${#fileName} -eq 38 ] && [[ ${fileName:0:9} = "Partition" ]] \
&& [[ ${fileName:9:1} -eq 0 || ${fileName:9:1} -eq 1 ]] \
&& [ ${fileName:10:1} = "." ] && [[ ${fileName:11:8} =~ ^[[:digit:]]+$ ]] \
&& [ ${fileName:19:1} = "T" ] && [[ ${fileName:20:6} =~ ^[[:digit:]]+$ ]] \
&& [ ${fileName:26:12} = ".verified.gz" ] ;then
matchFilesArr+=($fileName)
fi
}

sortArr ()
{
if [ ${#matchFilesArr[@]} -gt 2 ]; then
date_1=""
date_2=""
path_1=""
path_2=""
for index in ${!matchFilesArr[@]}
do
arrVal=${matchFilesArr[$index]}
dateFromVal="${arrVal:11:4}-${arrVal:15:2}-${arrVal:17:2} ${arrVal:20:2}:${arrVal:22:2}:${arrVal:24:2}.123"
if [ $index = 0 ]; then
    date_1="$dateFromVal"
    path_1="$arrVal"
elif [ $index = 1 ]; then
    date_2="$dateFromVal"
    path_2="$arrVal"
else
    if [[ $date_1 > $dateFromVal ]] || [[ $date_2 > $dateFromVal ]]; then
	if [[ $date_1 < $date_2 ]]; then
	    date_2="$dateFromVal"
	    path_2="$arrVal"
	elif [[ $date_1 > $date_2 ]]; then
	    date_1="$dateFromVal"
	    path_1="$arrVal"
	elif [[ $date_1 = $date_2 ]]; then
	    datе_1="$dateFromVal"
	    path_1="$arrVal"
        fi
    fi
fi
done
unset matchFilesArr[@]
matchFilesArr=("$path_1" "$path_2")
fi
}

#Start of the program;
dirPath=$1
if [ -d $dirPath ] && [ $# -eq 1 ]; then
    for file in `find $dirPath -type f`
    do
    if [ -f $file ]; then
    checkFileName "$(basename $file)"
    fi
    done
else
echo "The path isn't directory or invalid input arguments!"
fi
sortArr
if [ ${#matchFilesArr[@]} == 2 ]; then
find $dirPath -type f \( ! -name "${matchFilesArr[0]}" ! -name "${matchFilesArr[1]}" \) -delete -printf 'Deleted file:= %f\n'
find $dirPath -type d -empty -delete -printf 'Deleted directory:= %f\n'
echo "Required files: [1]:= ${matchFilesArr[0]} and [2]:= ${matchFilesArr[1]}"
else
echo "The directory doesn't contain properly files! Exit..."
fi
