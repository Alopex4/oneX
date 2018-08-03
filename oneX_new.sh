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
readonly ARG_ERROR=1
readonly ARG_INVALID=2
readonly OK=0

# Color code
readonly RED="\e[31m"
readonly PLAIN="\e[0m"

# Argument
readonly ARG1="${1}"
readonly ARG2="${2}"

# Global var
readonly G_re_match="http(s)?://1x.com/photo/[0-9]{4,12}/popular:all"

ARG_JUDGE(){
    local arg1=${1}
    local t_arg2="${2}"
    local arg2="${t_arg2:-`pwd`}"
      
    echo "${arg1}" | egrep "${G_re_match}" &> /dev/null
    if [ "$?" -eq "0" ]
    then
        local url="${arg1}"
        local download_dir="${arg2}"
    else
        echo "${arg2}" | egrep "${G_re_match}" &> /dev/null
        if [ "$?" -eq "0" ]
        then
            local url="${arg2}"
            local download_dir="${arg1}"
        else
           echo -e "The ${RED}URL${PLAIN} invalid"
           exit ${ARG_INVALID}
        fi
    fi
    local array=([1]="${url}" [2]="${download_dir}") 
    echo "${array[*]}"
}

ARG_STRING=`ARG_JUDGE ${ARG1} ${ARG2}`
# specific arg
readonly SINGLE_URL=`echo ${ARG_STRING} | cut -d ' ' -f1`
readonly SINGLE_dl_dir=`echo ${ARG_STRING} | cut -d ' ' -f2`
echo ${SINGLE_URL}
echo ${SINGLE_dl_dir}

usage(){
    local arg_num=${1}
    echo -e "Usage: ${0}"
    echo -e "${0} takes exactly ${RED}0${PLAIN} argument (${arg_num} given)"
}


main(){
    local arg_num=${#}

    if [ "${arg_num}" -ge 3 ]
    then
        usage ${arg_num}
        exit ${ARG_ERROR}

    elif [ "${arg_num}" -gt 0 -a "${arg_num}" -le 2 ]
    then
        :
        exit ${OK} 
    else
        exit ${OK} 
    fi
}

main $*