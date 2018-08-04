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

# ------------------------- Global argument assign begin -------------------------
# --------------------------------------------------------------------------------
# Error code
readonly ARG_ERROR=1
readonly ARG_INVALID=2
readonly NETWORK_ERROR=3
readonly OK=0

# Color code
readonly RED="\e[31m"
readonly PLAIN="\e[0m"

# Argument
readonly ARG1="${1}"
readonly ARG2="${2}"

# Global var
readonly G_rank="(latest|popular|curators-choice)"
readonly temp_categories="(all abstract action animals architecture conceptual \
            creative-edit documentary everyday fine-art-nude humour landscape\
            macro mood night performance portrait still-life street \
            underwater wildlife)"
readonly G_categories=`echo ${temp_categories} | tr ' ' '|'`
readonly G_re_match="http[s]?://1x.com/photo/[0-9]{4,12}/${G_rank}:${G_categories}"

# Define which is URL url
ARG_JUDGE(){
    local arg1=${1}
    local t_arg2="${2}"
    local cur_dir=`pwd`
    local arg2="${t_arg2:-${cur_dir}}"

    if [ "${arg2}" != ${cur_dir} ]
    then
        arg2="${cur_dir}/${arg2}"
    fi
      
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


# specific arg
ARG_STRING=`ARG_JUDGE ${ARG1} ${ARG2}`
readonly SINGLE_URL=`echo ${ARG_STRING} | cut -d ' ' -f1`
readonly SINGLE_DL_DIR=`echo ${ARG_STRING} | cut -d ' ' -f2`
# echo ${SINGLE_URL}
# echo ${SINGLE_DL_DIR}
# ------------------------- Global argument assign end ---------------------------
# --------------------------------------------------------------------------------


usage(){
    local arg_num=${1}
    echo -e "Usage: ${0}"
    echo -e "${0} takes exactly ${RED}[0-2]${PLAIN} argument (${arg_num} given)"
}

network_try(){
    local index="https://1x.com/"
    local try_time=3
    local success=-1
    while [ "${try_time}" -ne 0 -a "${success}" -ne 0 ]
    do
        sleep 0.7
        curl -s -o /dev/null -w "${http_code}" --connect-timeout 2 ${index}
        success=$?
        let try_time--
    done

    if [ "${success}" -ne 0 ]
    then
        echo -e "Check you netwok first."
        exit ${NETWORK_ERROR}
    fi
}

source_jpg_link(){
    :
}

single_pic_download(){
    local source_url=${1}
    local download_dir=${2}
    echo $source_url
    echo $download_dir
}


main(){
    network_try
    local arg_num=${#}

    if [ "${arg_num}" -ge 3 ]
    then
        usage ${arg_num}
        exit ${ARG_ERROR}

    elif [ "${arg_num}" -gt 0 -a "${arg_num}" -le 2 ]
    then
        single_pic_download "${SINGLE_URL}" "${SINGLE_DL_DIR}"
        exit ${OK} 
    else
        exit ${OK} 
    fi
}

main $*