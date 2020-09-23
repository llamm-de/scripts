#!/bin/bash

# Script to search fortran files for subroutines and/or functions
#
# Usage: searchSubs LIST_OF_SUBS DIRECTORY
#        LIST_OF_SUBS is a file containing all sub names to search for
#        DIRECTORY is the search directory. Search will be recursive.
#
# Author: Lukas Lamm

# Set some formating
bold=$(tput bold)
normal=$(tput sgr0)
white=$(tput setaf 7)
red=$(tput setaf 1)
green=$(tput setaf 2)

# Check for input parameters
if [ "$#" -lt 1 ]; then
    printf "Error: Not enough input arguments!\n"
    printf "Please use \"ssubs LIST_OF_SEARCH_ITEMS SEARCH_DIRECTORY\" instead.\n"
    printf "LIST_OF_SEARCH_ITEMS can be given as a single search item \n"
    printf "                     or a file containing multiple items.\n"
    exit 1
fi

# Set up output file
output=out.txt
if [ -f "$output" ]; then
    printf "Removing old search results!\n"
    rm ${output}
fi

# Get input from file or as single input
if [ -f "$1" ]; then
    printf "File including search items: ${bold}$1${normal}\n"
    input="$1"
else
    printf "No File selected. Using single search mode!\n"
    input=tmp.txt
    printf "$1\n" >> ${input}
    printf " " >> ${input}
fi

printf "Output for recursive search of subroutines or functions in $2\n" >> ${output}

# Initialize counters
totitems=0
founditems=0

#--------------------------------------------------------------------------''
# Main routine
#--------------------------------------------------------------------------''
printf "\nStarting recursive search for subroutines or functions in ${bold}$2${normal}\n"

# Loop through lines of file
while IFS= read -r line
do
    # Set search string
    searchstrsub="subroutine\s"
    searchstrsub+=$line
    searchstrsub+="(.*)"
    searchstrfun="function\s"
    searchstrfun+=$line
    searchstrfun+="(.*)"

    # Search using grep
    printf "Searching for: ${bold}%-10s${normal}... " $line
    tmpsub=$(grep -R -l "$searchstrsub" "$2")
    tmpfun=$(grep -R -l "$searchstrfun" "$2")
    
    printf "\nSearchresults for %s: \n" $line >> ${output}
    
    # Evaluate output and display to screen / write to files
    if [ ! -z "$tmpsub" ]
    then
        tmp="$tmpsub"
    elif [ ! -z "$tmpfun" ]
    then
        tmp="$tmpfun"
    fi

    if [ ! -z "$tmp" ]
    then
        printf "${green}Found some apperances of ${line}!${white}\n"
        founditems=$((founditems+1))
        printf "\t%s\n" $tmp >> ${output}
    else
        printf "${red}Found nothing!${white}\n"
        printf "\tNone!\n" >> ${output}
    fi
    totitems=$((totitems+1))
done < "${input}"

# Print evaluation of search
printf "Found %i out of %i search items!\n" $founditems $totitems
printf "Search completed!\n"
tail -n +2 ${output}
rm ${input}
