#!/bin/bash

#-------------CopyRight-------------  
#   Name: oneX
#   Version Number: 1.1
#   Type: photoes crawler
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
#
# --------------------------------------------------------------------------------
# Error code
readonly ARG_ERROR=1
readonly ARG_INVALID=2
readonly NETWORK_ERROR=3
readonly URL_FAILED=4
readonly OK=0

# Color code
readonly RED="\e[31m"
readonly GREEN="\e[32m"
readonly PLAIN="\e[0m"

# Argument
readonly ARG1="${1}"
readonly ARG2="${2}"

readonly G_re_url_match="http[s]?://1x.com/photo/[0-9]{1,12}"
readonly G_re_image_match="https://1x.com/images/user/[0-f]+"

# Define which is URL url
ARG_JUDGE(){
    local arg1=${1}
    local t_arg2="${2}"
    local cur_dir=`pwd`
    local arg2="${t_arg2:-${cur_dir}}"
    local re_match="${G_re_url_match}/?.*"

    if [ "${arg2}" != "${cur_dir}" ]
    then
        arg2="${cur_dir}/${arg2}"
    fi
      
    echo "${arg1}" | egrep "${re_match}" &> /dev/null
    if [ "$?" -eq "0" ]
    then
        local url="${arg1}"
        local download_dir="${arg2}"
    else
        echo "${arg2}" | egrep "${re_match}" &> /dev/null
        if [ "$?" -eq "0" ]
        then
            local url="${arg2}"
            local download_dir="${cur_dir}/${arg1}"
        fi
    fi

    # Check the directory exist or not.
    if [ ! -d "${download_dir}" ]
    then
        mkdir -p "${download_dir}" 
    fi
    url=`echo ${url} | egrep -o ${G_re_url_match}`
    local array=([1]="${url}" [2]="${download_dir}") 
    echo "${array[*]}"
}


# specific arg
ARG_STRING=`ARG_JUDGE ${ARG1} ${ARG2}`
if [ "${ARG_STRING}" == " " ]
then
    echo -e "The ${RED}URL${PLAIN} invalid"
    exit ${ARG_INVALID}
fi
readonly SINGLE_DL_DIR=`echo ${ARG_STRING} | cut -d ' ' -f2`

# Varable
Single_Url=`echo ${ARG_STRING} | cut -d ' ' -f1`

# ------------------------- Global argument assign end ---------------------------
# 
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

get_url_jpg_info(){
    local source_url=${1}
    local url_contents=`curl -s -i ${source_url}`
    local title=`echo ${url_contents} | egrep  -o "<title>.*</title>" | \
                sed -e 's!<[^>]*>!!g' -e s'!1x - !!' -e s'!by.*!!'`
    local hd_url=`echo ${url_contents} | egrep -o ${G_re_image_match} | \
                uniq -d | sed 's!$!-hd2.jpg!'`

    local title=`echo ${title} | tr ' ' '_' | sed 's!\.!!'`
    local array=([1]="${hd_url}" [2]="${title}") 
    echo "${array[*]}"
}

single_pic_download(){
    local url_title=`get_url_jpg_info ${Single_Url}`
    local hd_url=`echo ${url_title} | cut -d ' ' -f1`
    local title=`echo ${url_title} | cut -d ' ' -f2`

    if [ "${url_title}" == " " ]
    then
        echo -e "The ${RED}URL${PLAIN} can't access."
    elif [ "${url_title}" == "${hd_url} " ]
    then
       local title=`echo $RANDOM | md5sum | cut -c 3-18`
    fi

    local file_name="${title}.jpg"
    # wget ${hd_url} -O ${SINGLE_DL_DIR}/${file_name}
    echo "wget ${hd_url} -O ${SINGLE_DL_DIR}/${file_name}"

    # Compatible with the non-HD(ld) photoes.
    if [ "$?" != "0" ]
    then
        local sd_url=`echo ${hd_url} | sed 's!hd2!sd!'`
        wget ${sd_url} -O ${SINGLE_DL_DIR}/${file_name}
        if [ "$?" != "0" ]
        then
            echo -e "Something wrong happen.. "
            echo -e "This photo ${RED}can't${PLAIN} download success!"
        fi
    fi
}

pic_download(){
    single_pic_download
    while true
    do
        Single_Url=""
        echo -e " Input ${GREEN}URL${PLAIN} or ${GREEN}(Q)uit${PLAIN} to exit: \c"
        read temp_new_url

        local new_url="${temp_new_url:-"none"}"
        local is_quit=`echo "${new_url}" | tr '[A-Z]' '[a-z]'`
        if [ "${new_url}" == "none" ]
        then
            continue
        elif [ "${is_quit}" == 'q' ]
        then
            break
        else
            new_url=`echo ${new_url} | sed 's![[:space:]]!!g'`
            Single_Url="${new_url}"
            single_pic_download
        fi

    done
}

main(){
    # network_try
    local arg_num=${#}

    if [ "${arg_num}" -ge 3 ]
    then
        usage ${arg_num}
        exit ${ARG_ERROR}

    elif [ "${arg_num}" -gt 0 -a "${arg_num}" -le 2 ]
    then
        pic_download
        exit ${OK} 
    else
        exit ${OK} 
    fi
}

main $*