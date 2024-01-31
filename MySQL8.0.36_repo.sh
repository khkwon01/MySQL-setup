#!/bin/sh
#set -vx


AUTHOR="kihyuk (kwon.kihyuk@oracle.com)"
VERSION="8.0.36"
TARFILE="p36186202_580_Linux-x86-64.zip"

ERR=0
# Used for a better dialog visualization on putty
export NCURSES_NO_UTF8_ACS=1

# Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

export working_dir="$( dirname $0 )"
if [[ ! ${working_dir} =~ ^/ ]]; then
    working_dir="$( pwd)/${working_dir}"
fi

export log_file="${working_dir}/$(basename -s .sh $0).log"
export sw_dir="${working_dir}/pkg"

export MOS_LINK_SRV_TAR='https://updates.oracle.com/Orion/Services/download/'${TARFILE}'?aru=25528186&patch_file='${TARFILE}

#####################################################
# FUNCTIONS
#####################################################

# Exit from errors
stop_execution_for_error () {
# first parameter is the exiut code
# second parameter is the error message

    ERR=$1
    ERR=${ERR:=1}

    MSG=$2
    MSG=${MSG:="Generic error"}
    echo "$(date) - ERROR - ${MSG}" |tee -a ${log_file}
    echo "$(date) - INFO - End" >> ${log_file}

    exit $ERR
}

download_software_from_MOS () {
    ERR=0

    echo "$(date) - INFO - Start function ${FUNCNAME[0]}" >> ${log_file}

    exec 3>&1

    result=$(dialog \
        --title "MOS Info" \
        --clear \
        --cancel-label "Exit" \
        --form "Put MOS info of support.com" 10 60 0 \
        "id  : " 1 1 "" 1 12 25 0 \
        "pass: " 2 1 "" 2 12 25 0 \
    2>&1 1>&3)

    exit_status=$?

    exec 3>&-

    if [ $? -ne 0 ] || [ -z "$result" ]
    then
        ERR=1
	stop_execution_for_error $ERR "MOS info didn't get from user input"
    fi

    MOS_USERNAME=`echo $result | cut -d " " -f 1`
    MOS_PASSWORD=`echo $result | cut -d " " -f 2`

    # Cookie file for the authentication
    export COOKIE_FILE=$(mktemp  --tmpdir=${working_dir} wget_sh_XXXXXX)
    if [ $? -ne 0 ] || [ -z "$COOKIE_FILE" ]
    then
        ERR=1
        stop_execution_for_error $ERR "Temporary cookie file creation failed."
    fi

    # Authentication on MOS (https://support.oracle.com)
    #read -p 'MOS (https://support.oracle.com) Username: ' MOS_USERNAME
    
    #wget  --secure-protocol=auto --save-cookies="${COOKIE_FILE}" --keep-session-cookies  --http-user "${MOS_USERNAME}" --ask-password  "https://updates.oracle.com/Orion/Services/download" -O /dev/null -a ${log_file}

    wget  --secure-protocol=auto --save-cookies="${COOKIE_FILE}" --keep-session-cookies  --http-user "${MOS_USERNAME}" --http-password "${MOS_PASSWORD}"  "https://updates.oracle.com/Orion/Services/download" -O /dev/null -a ${log_file}

    echo "$(date) - INFO - Download of MySQL tar repo... please wait..." |tee -a ${log_file}
    wget --progress=dot --load-cookies="$COOKIE_FILE" --save-cookies="$COOKIE_FILE" --keep-session-cookies ${MOS_LINK_SRV_TAR} -O "${sw_dir}/${TARFILE}" 2>&1 | stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | dialog --backtitle "MySQL configuration" --gauge "Download MySQL binary tar (${VERSION})" 10 60
    
#    SRV_TAR_PKG_DOWNLOAD_PID=$!
#    wait ${SRV_TAR_PKG_DOWNLOAD_PID}
    SRV_TAR_PKG_DOWNLOAD_STATUS=$?
    if [ $SRV_TAR_PKG_DOWNLOAD_STATUS -ne 0 ] ; then
       echo "$(date) - INFO - Download completed for MySQL tar" |tee -a ${log_file}
    fi

    sudo rm -rf ${working_dir}/wget_sh_*

    return $ERR
}

test_func () {
    
    exec 3>&1

    result=$(dialog \
        --title "Dialog test" \
	--clear \
	--cancel-label "Exit" \
	--form "Put MOS info of support.com" 10 60 0 \
        "id  : " 1 1 "" 1 12 25 0 \
	"pass: " 2 1 "" 2 12 25 0 \
    2>&1 1>&3)

    exit_status=$?

    exec 3>&-

    echo $result
}

###################################################################################################
# MAIN
###################################################################################################

echo "$(date) - INFO - Start" >> ${log_file}
echo "$(date) - INFO - Script version ${VERSION}" >> ${log_file}

echo "$(date) - INFO - Check, and if needed install, pre-requisites" |tee -a ${log_file}

sudo yum -y -q install ncurses-compat-libs dialog wget unzip jq 2>&1 >>${log_file}
sudo mkdir -p ${sw_dir} 2>&1 >>${log_file}

ERR=$?
if [ $ERR -ne 0 ] ; then
    stop_execution_for_error $ERR "Issues during required software installation"
fi

if [ $OPTIND -eq 1 ]; then
    echo "$(date) - INFO - Interactive mode" >> ${log_file}

    while true
    do
    	exec 3>&1

	selection=$(dialog --keep-tite \
		--backtitle "MySQL configuration" \
		--title "MySQL configuration menu" \
		--clear  \
		--cancel-label "Exit" \
		--menu "\nEnter follow number to use these commands" 0 0 0\
		"1" "Download mysql binary install file from oracle" \
		"9" "dialog test" \
		2>&1 1>&3)

        exit_status=$?

        # Close file descriptor 3
        exec 3>&-

	case $exit_status in
        $DIALOG_CANCEL)
            clear
            echo "$(date) - INFO - Interactive menu end" >> ${log_file}
            exit
            ;;
        $DIALOG_ESC)
            clear
            echo "$(date) - INFO - Interactive menu cancelled" >> ${log_file}
            return $ERR
            ;;
        esac

	case $selection in
	1 )
	    download_software_from_MOS
	    ;;
	9 ) 
	    test_func

	    read -p "Press ENTER to continue"
	    ;;
	esac

    done
fi

echo "$(date) - INFO - End" >> ${log_file}
exit $ERR
