#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear

# Color paint 
BLACK='\E[0;30m'
RED='\E[0;31m'
GREEN='\E[0;32m'
YELLOW='\E[0;33m'
BLUE='\E[0;34m'
PINK='\E[0;35m'
CYAN='\E[0;36m'
WHITE='\E[0;37m'
RES='\E[0m'
Blink='\E[5m'

# Define domain name
onex='www.1x.com'

# Determine whether ROOT
    [[ $EUID -ne 0 ]] && echo -e "[${RED}${Blink}Error!${RES}]\nPlease run in ROOT!" && exit -1

# Check Network
    ping -c 1 $onex &> /dev/null 
    if [ $? -ne 0 ] ; then
        echo -e "[${YELLOW}${Blink}Warrning${RES}]\nPlease connect your internet."
        exit -1
    fi

# Create a directory
CreateDir(){
    read -p "Please input a Directory to store picture: " Dir
    if  [ -z "${Dir}" ] && Dir="`pwd`/1x"  ; then
        [ ! -d $Dir ] && mkdir -p $Dir &> /dev/null

    elif [ ${#Dir} -eq 1 ] && [ ${Dir:0:1} = \/ ] ; then 
        echo -e "[${YELLOW}${Blink}Warrning${RES}]\nYou should not start with \"/\"." 
        exit -1

    elif [ ${#Dir} -gt 1 ] && [ ${Dir:0:1} = \/ ] ; then 
        Dir="$Dir"
        [ ! -d $Dir ] && mkdir -p $Dir &> /dev/null

    else
        Dir="`pwd`/${Dir}" 
        [ ! -d $Dir ] && mkdir -p $Dir &> /dev/null
    fi

    echo 
    echo "---------------------------"
    echo "Dir = ${Dir}"
    echo "---------------------------"
    echo
}

# Get Information from URL store to assign directory
GetUserInfo(){
    echo "Please input the URL" 
    read -p "e.g 'https://1x.com/member/424114': " URL 
    suffix=${URL##*/}
    URLDir="${Dir}/${suffix}_source"
    curl -o ${URLDir} ${URL} &> /dev/null

# Get member Name to create the same name directory.
    MemName=`grep  "<title>1x " ${URLDir} | cut -d '-' -f 2 | tr ' ' '_'`
    MemName=`echo $MemName | awk  -F "/" '{print $NF}' | sed s/_//g`
    MemberDir="${Dir}/${MemName}"
    mkdir ${MemberDir} &> /dev/null

# Get member ID (The unique key)
    MemID=`grep "member_userid" ${URLDir} | cut -d "\"" -f 6`

# Get total photo quanity
    TotalPhoto=`egrep -o "Published.*Albums"  ${URLDir} | cut -d '(' -f 2 | cut -d ')' -f 1`

# Create a list to store photoid
    PhotoList="${Dir}/${MemName}.list"

# Set the base URL
    FromID='0'
    BaseURL="https://1x.com/backend/loadmore.php?app=member&from=${FromID}&cat=all&sort=latest&userid=${MemID}"

# Via BaseURL get the photoid
    curl -s ${BaseURL} | egrep -o '[0-9]{5,9}\/(latest:user:)'  | cut -d '/' -f1  > ${PhotoList}

# Detect whether total photo over 30 
    for(( FromID=30; $[ TotalPhoto / FromID ]> 0; FromID=$FromID+30 ))
    do 
      BaseURL="https://1x.com/backend/loadmore.php?app=member&from=${FromID}&cat=all&sort=latest&userid=${MemID}"
      curl -s ${BaseURL} | egrep -o '[0-9]{5,9}\/(latest:user:)'  | cut -d '/' -f1  >> ${PhotoList}
    done
# Detect whether the user truly want to download
    echo
    echo -e "Press any key to ${RED}Download${RES}...or Press ${RED}Ctrl+C${RES} to cancel"
    char=`get_char`
}

# Get a char to continue
get_char(){
    SAVEDSTTY=`stty -g`
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty $SAVEDSTTY
}

# Download photo
DownPhoto(){
    PhotoURL="${PhotoList}.url"
    while read photoids ;	
    do
    (
      echo ` curl -s https://1x.com/photo/$photoids  | egrep -o  '(\/images\/user\/)[a-zA-Z0-9]{32}(-hd)[0-9]?\.jpg' |  sed 's/^/https:\/\/1x\.com/' ` >> ${PhotoURL}
      wget -nd -t 3 --directory-prefix=${MemberDir} --no-check-certificate ` curl -s https://1x.com/photo/$photoids  | egrep -o  '(\/images\/user\/)[a-zA-Z0-9]{32}(-hd)[0-9]?\.jpg' |  sed 's/^/https:\/\/1x\.com/' ` 
    )&
    done < ${PhotoList}
  wait 
}

# Archive & Compress the download file
ArchiveCompress(){
    echo
    echo -e -n "Would you like to ${CYAN}Archive${RES} & ${CYAN}Compress${RES} your download photoes : " 
    read -n 1 answer
    answer=`echo $answer | tr [a-z] [A-Z]`
    if [ $answer = Y ]; then
        tarfile="${MemberDir}.tar.bz2"
        tar -Pjcf ${tarfile} ${MemberDir}
	rm -rf ${MemberDir}
	PrintACInfo
    else 
        PrintNoACInfo
    fi
}

# Clean temp file 
Clean(){
   : > ${PhotoList}; rm ${PhotoList}
   : > ${URLDir} ;   rm ${URLDir}
}

# print Info
PrintNoACInfo(){
    echo 
    echo    "-----------------------------------------------"
    echo -e "Photo store Directory = ${BLUE}${MemberDir}${RES}"
    echo    "-----------------------------------------------"
    echo    "-----------------------------------------------"
    echo -e "Photo URL store file = ${BLUE}${PhotoURL}${RES}"
    echo    "-----------------------------------------------"
}

PrintACInfo(){
    echo 
    echo    "-----------------------------------------------"
    echo -e "Photo store Directory = ${BLUE}${MemberDir}${RES}"
    echo    "-----------------------------------------------"
    echo    "-----------------------------------------------"
    echo -e "Photo URL store file = ${BLUE}${tarfile}${RES}"
    echo    "-----------------------------------------------"
}

# Control Panel
main(){
    CreateDir
    GetUserInfo
    DownPhoto
    Clean
    ArchiveCompress
}

# : replace to function 
  if [ -z $1 ] ; then
      main 
      exit 0
  else 
      echo "Usage ./$0 "
      exit -1
  fi
