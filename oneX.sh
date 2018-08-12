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
#   Terminal: column 124 line 24  
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
readonly BLUE="\e[34m"
readonly PLAIN="\e[0m"
readonly BOLD="\e[1m"
readonly UNDERLINE="\e[4m"

# Argument
readonly ARG1="${1}"
readonly ARG2="${2}"

# Regular express
readonly G_re_photo_match="http[s]?://1x.com/photo/[0-9]{1,12}"
readonly G_re_member_match="http[s]?://1x.com/member/.*"
readonly G_re_image_match="http[s]?://1x.com/images/user/[0-f]+"
readonly G_re_publish_match='Published <span style="color: #[0-f]{3};">\([0-9]{1,}\)'
readonly G_re_memberID_match='"member_userid" value="[0-9]{1,}"'

# Define which is URL url
ARG_JUDGE(){
    local arg1=${1}
    local t_arg2="${2}"
    local cur_dir=`pwd`
    local arg2="${t_arg2:-${cur_dir}}"
    local photo_match="${G_re_photo_match}/?.*"
    local member_match="${G_re_member_match}"

    echo "${arg1}" | egrep "${photo_match}|${member_match}" &> /dev/null
    if [ "$?" -eq 0 ]
    then
        local url="${arg1}"
        if [ "${arg2}" != "${cur_dir}" ]
        then
            download_dir="${cur_dir}/${arg2}"
        fi
    else
        local url="${arg2}"
        if [ "${arg1}" != "${cur_dir}" ]
        then
            download_dir="${cur_dir}/${arg1}"
        fi
    fi
    local array=([1]="${url}" [2]="${download_dir:-${cur_dir}}") 
    echo "${array[*]}"
}

usage(){
    local arg_num=${1}
    echo -e "Usage: ${RED}${BOLD}${0}${PLAIN} ${BLUE}${UNDERLINE}${BOLD} 1x.com_URL ${PLAIN}"
    echo -e "       ${RED}${BOLD}${0}${PLAIN} ${BLUE}${UNDERLINE}${BOLD} 1x.com_URL ${PLAIN} ${BLUE} directory ${PLAIN}"
    echo -e "       ${RED}${BOLD}${0}${PLAIN} ${BLUE} directory ${PLAIN} ${BLUE}${UNDERLINE}${BOLD} 1x.com_URL ${PLAIN}"
    echo -e "${0} takes exactly ${RED}[1-2]${PLAIN} argument (${arg_num} given)"
}

# specific arg
ARG_STRING=`ARG_JUDGE ${ARG1} ${ARG2}`
if [ "${ARG_STRING}" == " " ]
then
    usage $#
    echo -e "The ${RED}URL${PLAIN} invalid"
    exit ${ARG_INVALID}
fi
# Global varable
SINGLE_DL_DIR=`echo ${ARG_STRING} | cut -d ' ' -f2`
Single_Url=`echo ${ARG_STRING} | cut -d ' ' -f1`

# ------------------------- Global argument assign end ---------------------------
# 
# --------------------------------------------------------------------------------


# ------------------------- Invoke function begin --------------------------------
# 
# --------------------------------------------------------------------------------
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

dir_exist_checking(){
    if [ ! -d "${SINGLE_DL_DIR}" ]
    then
        mkdir -p "${SINGLE_DL_DIR}"  &> /dev/null
    fi
}

get_member_id(){
    local contents=${1}
    local id=`echo ${contents} | egrep -o "${G_re_memberID_match}" | \
            egrep -o "[0-9]{1,}"`
    echo "${id}"
}

get_web_page_info(){
    local source_url=${1}
    local url_contents=`curl -s -i ${source_url}`
    local space=""

    if [[ ${Single_Url} =~ ${G_re_photo_match} ]]
    then
        local title=`echo ${url_contents} | egrep  -o "<title>.*</title>" | \
                sed -e 's!<[^>]*>!!g' -e s'!1x - !!' -e s'!by.*!!' | \
                tr ' ' '_' | sed 's!\.!!' | sed 's!_$!!'`
        local hd_url=`echo ${url_contents} | egrep -o ${G_re_image_match} | \
                uniq -d | sed 's!$!-hd2.jpg!'`

    elif [[ ${Single_Url} =~ ${G_re_member_match} ]]
    then
        local total_photoes=`echo ${url_contents} | egrep  -o \
            "${G_re_publish_match}" | egrep -o '\([0-9]{1,}\)'| egrep -o '[0-9]{1,}'`
        local name=`echo ${url_contents} | egrep  -o "<title>.*</title>" | \
                sed -e 's!<[^>]*>!!g' -e s'!1x - !!' -e s'! - Latest.*!!' | \
                sed 's! !-!g'`
    fi
    # Attention here
    # Because the url is a huge string(has space)
    # The parameter must use "double quotes"
    local id=`get_member_id "${url_contents}"`
    local array=([1]="${hd_url:-${total_photoes}}" [2]="${title:-${name}}" [3]="${id:-${space}}") 
    echo "${array[*]}"
}

single_pic_download(){
    local url_title=`get_web_page_info ${1}`
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
    wget ${hd_url} -O ${SINGLE_DL_DIR}/${file_name}

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

set_default_dir(){
    if [ "${SINGLE_DL_DIR}" == `pwd` ]
    then
        SINGLE_DL_DIR="${SINGLE_DL_DIR}/1x"
        if [ ! -d "${SINGLE_DL_DIR}" ]
        then
            mkdir "${SINGLE_DL_DIR}" > /dev/null
        fi
    fi
}

get_link_photoID_file(){
   local photoes="${1}" 
    # Initial the meta_info
   local MemID="${2}"
   local FormID='0'
    #The link can't separate
   local Meta_Info="https://1x.com/backend/loadmore.php?app=member&from=${FormID}&cat=all&sort=latest&userid=${MemID}"
   local contents=`curl -s -i ${Meta_Info}`
   for(( FormID=30; $[ photoes / FormID ]> 0; FormID=${FormID}+30 ))
   do
        local Meta_Info="https://1x.com/backend/loadmore.php?app=member&from=${FormID}&cat=all&sort=latest&userid=${MemID}"
        local t_contents=`curl -s -i ${Meta_Info}`
        local contents="${contents} ${t_contents}"
   done
   local photo_links=`echo ${contents} | egrep -o '<a href="/photo/[0-9]{1,}' | \
     sed 's!<a href="!!g' | sed 's!^!https://1x.com!'`

    dir_exist_checking
    echo "${photo_links}" > "${SINGLE_DL_DIR}/photo_links.txt"
}


bulk_pics_download(){
    while read photo_link
    do
    (   Single_Url="${photo_link}"
        # This approach is much better
        # However it cost too much time.
        # single_pic_download ${Single_Url}

        wget ` curl -s ${photo_link}  | egrep -o \
         '(\/images\/user\/)[a-zA-Z0-9]{32}(-hd)[0-9]?\.jpg' | \
          sed 's/^/https:\/\/1x\.com/' | sed 's!-hd4!-hd2!g'` -P ${SINGLE_DL_DIR}
    )&
    done < "${SINGLE_DL_DIR}/photo_links.txt"
    wait
}

print_acInfo(){
    local photo_position=${1}
    echo    "-----------------------------------------------"
    echo    "-----------------------------------------------"
    echo -e " Photo store Directory: "
    echo -e " ${BOLD}${BLUE}${photo_position}${PLAIN}"
    echo    "-----------------------------------------------"
    echo    "-----------------------------------------------"
}

archive_or_not(){
   local member_name="${1}"
   local the_pwd=`pwd`
   local cur_dir=${SINGLE_DL_DIR}
   reset 
   echo -e "${BOLD}${RED}Archive and Compress${PLAIN} the bulk photoes? (y/N) \c"
   read -t 10 answer
   local answer=`echo ${answer} | tr '[A-Z]' '[a-z]'`
   if [ "${answer}" == "y" ]
   then
        target_file="${member_name}.tar.gz"
        source_file=`echo ${SINGLE_DL_DIR} | awk -F '/' '{print $NF}' | sed 's!$!/!'`
        tar -zcf ${target_file} ${source_file}
        rm -rf ${SINGLE_DL_DIR}
        target_file="${the_pwd}/${target_file}"
   fi
   print_acInfo ${target_file:-${cur_dir}}
}

# ------------------------- Invoke function end ----------------------------------
# 
# --------------------------------------------------------------------------------

# ### Management function ###
# ### Download single picture 
pic_download(){
    dir_exist_checking
    single_pic_download "${Single_Url}"
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
            single_pic_download "${Single_Url}"
        fi
    done
}

# ### Management function ###
# ### bulk photo download 
bulk_download(){
    local photoes_name_id=`get_web_page_info ${Single_Url}`
    local member_photoes=`echo ${photoes_name_id} | cut -d ' ' -f1`
    local member_name=`echo ${photoes_name_id} | cut -d ' ' -f2`
    local member_id=`echo ${photoes_name_id} | cut -d ' ' -f3`
    set_default_dir
    get_link_photoID_file "${member_photoes}" ${member_id}
    bulk_pics_download
    archive_or_not "${member_name}"
}

downloading(){
    if [[ ${Single_Url} =~ ${G_re_photo_match} ]]
    then
        pic_download
    else
        bulk_download
    fi
}

# ### main function ###
main(){
    network_try
    local arg_num=${#}

    if [ "${arg_num}" -ge 3 ]
    then
        usage ${arg_num}
        exit ${ARG_ERROR}
    else
        downloading
        exit ${OK} 
    fi
}

main $*