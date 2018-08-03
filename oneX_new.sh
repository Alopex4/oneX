#!/bin/bash

#-------------CopyRight-------------  
#   Name: 
#   Version Number: 1.1
#   Type: 
#   Language: bash shell  
#   Date: 2018-7-24
#   Author: Alopex
#   Email: alopex4@163.com
#------------Environment------------  
#   Terminal: column 80 line 24  
#   Linux 4.15.0-24-generic
#   GNU Bash 4.3
#-----------------------------------  

# Error code
readonly ARG_ERROR=-1
readonly OK=0

# Color code
readonly RED="\e[31m"
readonly DEFAULT="\e[0m"

usage(){
    local arg_num=${1}
    echo -e "Usage: ${0}"
    echo -e "${0} takes exactly ${RED}0${DEFAULT} argument (${arg_num} given)"
}

main(){
    local arg_num=${#}
    if [ "${arg_num}" -ne 0 ]
    then
        usage ${arg_num}
        exit ${ARG_ERROR}
    else
        exit ${ok} 
    fi
}



main $*