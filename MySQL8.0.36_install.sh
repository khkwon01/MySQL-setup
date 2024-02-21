#!/bin/sh
#set -vx


AUTHOR="kihyuk (kwon.kihyuk@oracle.com)"
VERSION="8.0.36"
MYSQL="MySQL_"${VERSION}
MSHELL="MySQL_Shell_"${VERSION}

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

export MOS_LINK_SRV_TAR='https://updates.oracle.com/Orion/Services/download/p36186202_580_Linux-x86-64.zip?aru=25528186&patch_file=p36186202_580_Linux-x86-64.zip'
export MOS_LINK_SHELL_TAR='https://updates.oracle.com/Orion/Services/download/p36186982_800_Linux-x86-64.zip?aru=25528525&patch_file=p36186982_800_Linux-x86-64.zip'

#####################################################
# FUNCTIONS
#####################################################

# Display message
display_msg() {
    dialog --title "$1" \
        --no-collapse \
	--msgbox "$2" 0 0
}

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

install_mysql_utilites () {
    ERR=0

    echo "$(date) - INFO - Start function ${FUNCNAME[0]}" >> ${log_file}

    # Install MySQL clients
    echo "$(date) - INFO - Install MySQL client and Shell on $client" |tee -a ${log_file}    

    if [ ! -f "${sw_dir}/${MSHELL}.zip" ]
    then
       ERR=1
       msg="ERROR - Install Err due to not exist ${MSHELL}.zip"
       echo "$(date) - ${msg}" |tee -a ${log_file}
       display_msg "Install Error" "${msg}"       
       return $ERR
    fi	    

    sudo unzip "${sw_dir}/${MSHELL}.zip" -d "${sw_dir}/" *x86_64.rpm
    sudo rm -f ${sw_dir}/*debuginfo*.rpm 
    sudo yum -y install ${sw_dir}/*.rpm

    ERR=$?

    if [ $ERR -eq 0 ]
    then
       msg="MySQL shell installation completed"
       display_msg "Client installation" "${msg}"
       echo "$(date) - INFO - ${msg}" |tee -a ${log_file}
    else
       msg="MySQL shell installation failed"
       display_msg "Client installation" "${msg}"
       echo "$(date) - INFO - ${msg}(${ERR})" |tee -a ${log_file}
    fi



    echo "$(date) - INFO - End function ${FUNCNAME[0]}" >> ${log_file}

    return $ERR
}

install_mysql_server () {
    ERR=0

    echo "$(date) - INFO - Start $(echo ${FUNCNAME[0]})" |tee -a ${log_file}

    echo "$(date) - INFO - Create OS group mysqlgrp on this server" |tee -a ${log_file}
    sudo groupadd mysqlgrp
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during OS group mysqlgrp creation"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file} 
       return $ERR
    fi

    echo "$(date) - INFO - Create OS user mysqluser on this server" |tee -a ${log_file}
    sudo useradd -r -g mysqlgrp -s /bin/false mysqluser
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during OS user mysqluser creation"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    echo "$(date) - INFO - Create directoy structure on this server" |tee -a ${log_file}
    sudo mkdir -p /mysql/ /mysql/etc /mysql/data /mysql/log /mysql/temp /mysql/binlog
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during Directoy structure creation"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    rm -f ${sw_dir}/*x86_64.tar.xz
    sudo unzip ${sw_dir}/${MYSQL}.zip -d ${sw_dir} *.tar.xz

    echo "$(date) - INFO - Extract MySQL Enterprise tar on this server" |tee -a ${log_file}
    cd /mysql
    sudo tar xf ${sw_dir}/*x86_64.tar.xz 
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during MySQL Enterprise tar extraction"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    cd /mysql
    sudo mv $( basename -s .tar.xz ${sw_dir}/*x86_64.tar.xz ) ${MYSQL}

    echo "$(date) - INFO - Create symbolic link to MySQL Enterprise installation on this server" |tee -a ${log_file}
    cd /mysql
    sudo ln -s ${MYSQL} mysql-latest
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during symbolic link creation"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    echo "$(date) - INFO - Copy my.cnf for commercial installation on this server" |tee -a ${log_file}
    mycnf="https://github.com/khkwon01/MySQL-setup/raw/main/mycnf/my.cnf"
    cd /mysql/etc/
    sudo wget --secure-protocol=auto ${mycnf}
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during my.cnf copy into /mysql/etc"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    echo "$(date) - INFO - Set ownerships to MySQL Enterprise directories on this server" |tee -a ${log_file}
    sudo chown -R mysqluser:mysqlgrp /mysql
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during ownerships set"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    echo "$(date) - INFO - Set permissions to MySQL Enterprise directories on this server" |tee -a ${log_file}
    sudo chmod -R 770 /mysql
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during permissions set"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    echo "$(date) - INFO - Initialize MySQL Enterprise on this server" |tee -a ${log_file}
    sudo /mysql/mysql-latest/bin/mysqld --defaults-file=/mysql/etc/my.cnf --initialize --user=mysqluser
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during MySQL initialize"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    echo "$(date) - INFO - Find MySQL temp root password" |tee -a ${log_file}
    TMPPASS=$(sudo awk '/temporary password/ {print $NF}' /mysql/log/err_log.log)
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during finding MySQL root password"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    # if you want to disable permantly, you modify /etc/selinux/config file
    echo "$(date) - INFO - Change enforcing mode of selinux to permissive" |tee -a ${log_file} 
    sudo setenforce 0
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during OS selinux mode change"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    echo "$(date) - INFO - Download systemctl auto start script" |tee -a ${log_file}
    cd /mysql
    mystart="https://raw.githubusercontent.com/khkwon01/MySQL-setup/main/systemctl/mysqld-advanced.service"
    sudo wget --secure-protocol=auto ${mystart}
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during download of systemctl mysql script"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    echo "$(date) - INFO - Configure systemd startup for MySQL Enterprise on this server" |tee -a ${log_file}
    sudo mv /mysql/mysqld-advanced.service /usr/lib/systemd/system/
    sudo chmod 644 /usr/lib/systemd/system/mysqld-advanced.service
    sudo systemctl enable mysqld-advanced.service
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during systemd startup configuration"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    echo "$(date) - INFO - Start MySQL Enterprise on this server" |tee -a ${log_file}
    sudo systemctl start mysqld-advanced.service
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during MySQL server start"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    echo "$(date) - INFO - Get the password of root from user" |tee -a ${log_file}
    export PFILE=$(mktemp  --tmpdir=${working_dir} temp_pas_XXXXXX)
    dialog \
       --title "root password setup" \
       --clear \
       --no-collapse \
       --passwordbox "passwd(default:Welcome#1)" 10 50 2> $PFILE
    
    exit_status=$?

    case $exit_status in
       0)
           PASS=$(cat $PFILE) 
	   if [ -z $PASS ]
           then
	      PASS="Welcome#1"
	   fi
	   ;;	
       1)
	   PASS="Welcome#1" 
	   ;;
    esac

    rm -f $PFILE
    clear
    echo "$(date) - INFO - Change root password from temp password" |tee -a ${log_file}
    /mysql/mysql-latest/bin/mysql -uroot -h127.0.0.1 -P3306 --connect-expired-password -p${TMPPASS} -e "ALTER USER root@localhost IDENTIFIED BY '${PASS}'"
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during MySQL root password change"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    echo "$(date) - INFO - Add MySQL exec path to env on this server" |tee -a ${log_file}
    echo 'export PATH=/mysql/mysql-latest/bin:$PATH' >> ~/.bashrc
    ERR=$?
    if [ $ERR -ne 0 ]
    then
       msg="error during adding MySQL exec path"
       display_msg "Server installation" "${msg}"
       echo "$(date) - ERROR - ${msg}" >> ${log_file}
       return $ERR
    fi

    echo "$(date) - INFO - Add MySQL socket path" |tee -a ${log_file}
    echo 'export MYSQL_UNIX_PORT=/mysql/temp/mysql.sock' >> ~/.bashrc

    source $HOME/.bashrc

    display_msg "Server installation" "MySQL installation succeed.."
    echo "$(date) - INFO - End function ${FUNCNAME[0]}" >> ${log_file}

    return $ERR
}

connect_mysql_server () {
 
    display_msg "test connection" "checking....."
}

download_software_from_MOS () {
    ERR=0

    echo "$(date) - INFO - Start function ${FUNCNAME[0]}" >> ${log_file}

    exec 3>&1

    result=$(dialog \
        --title "MOS Info" \
        --clear \
	--no-collapse \
        --cancel-label "Exit" \
        --form "Put MOS info of support.com" 10 60 0 \
	"id  (↑): " 1 1 "" 1 12 25 0 \
	"pass(↓): " 2 1 "" 2 12 25 0 \
    2>&1 1>&3)

    exit_status=$?

    exec 3>&-

    case $exit_status in
    $DIALOG_CANCEL)
        clear
        echo "$(date) - INFO - Scripts menu end" >> ${log_file}	    
        return $ERR
        ;;
    $DIALOG_ESC)
        clear
        echo "$(date) - INFO - Scripts menu cancelled" >> ${log_file}           
        return $ERR
        ;;
    esac

    MOS_USERNAME=`echo $result | cut -d " " -f 1`
    MOS_PASSWORD=`echo $result | cut -d " " -f 2 -s`

    if [ "${#MOS_USERNAME}" -lt 2 ] || [ "${#MOS_PASSWORD}" -lt 2 ]
    then
        ERR=1
	msg="MOS info didn't get from user input"
        display_msg "Input Error" "${msg}"
	stop_execution_for_error $ERR "${msg}"
    fi

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

    if [ $? -ne 0 ]
    then
        ERR=1
	msg="the given credentials is wrong"
	display_msg "Auth Error" "${msg}"
	stop_execution_for_error $ERR $msg
    fi

    echo "$(date) - INFO - Download of MySQL tar repo... please wait..." |tee -a ${log_file}
    wget --progress=dot --load-cookies="$COOKIE_FILE" --save-cookies="$COOKIE_FILE" --keep-session-cookies ${MOS_LINK_SRV_TAR} -O "${sw_dir}/${MYSQL}.zip" 2>&1 | stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | dialog --backtitle "MySQL configuration" --gauge "Download MySQL binary tar (${VERSION})" 10 60
    
#    SRV_TAR_PKG_DOWNLOAD_PID=$!
#    wait ${SRV_TAR_PKG_DOWNLOAD_PID}
    SRV_TAR_PKG_DOWNLOAD_STATUS=$?
    if [ $SRV_TAR_PKG_DOWNLOAD_STATUS -ne 0 ] ; then
       msg="ERROR - Error during the download of MySQL server"
       echo "$(date) - ${msg}" |tee -a ${log_file}
       display_msg "Download Error" $msg
    fi

    echo "$(date) - INFO - Download of MySQL rpms repo... please wait..." |tee -a ${log_file}
    wget --progress=dot --load-cookies="$COOKIE_FILE" --save-cookies="$COOKIE_FILE" --keep-session-cookies ${MOS_LINK_SHELL_TAR} -O "${sw_dir}/${MSHELL}.zip" 2>&1 | stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | dialog --backtitle "MySQL configuration" --gauge "Download MySQL shell (${VERSION})" 10 60

    SHL_RPM_DOWNLOAD_STATUS=$?
    if [ $SHL_RPM_DOWNLOAD_STATUS -ne 0 ] ; then
       msg="ERROR - Error during the download of MySQL shell"
       echo "$(date) - ${msg}" |tee -a ${log_file}
       display_msg "Download Error" $msg
    fi    

    sudo rm -f "${COOKIE_FILE}"

    echo
    echo "$(date) - INFO - All downloads completed" |tee -a ${log_file}
    echo "$(date) - INFO - End function ${FUNCNAME[0]}" >> ${log_file}

    return $ERR
}

test_func () {
    
    #display_msg "test" "This is test message"
    
    #exec 3>&1

    #result=$(dialog \
    #    --title "Dialog test" \
    #    --clear \
    #    --cancel-label "Exit" \
    #    --form "Put MOS info of support.com" 10 60 0 \
    #    "id  : " 1 1 "" 1 12 25 0 \
    #    "pass: " 2 1 "" 2 12 25 0 \
    #2>&1 1>&3)

    #exit_status=$?

    #exec 3>&-

    #echo $result

    echo "10"
    sleep 1
    echo "20"
    sleep 2
    echo "30"
    sleep 3
    echo "40"
    sleep 4
    echo "50"
    sleep 5
    echo "60"
    sleep 6
    echo "70"
    sleep 7
    echo "80"
    sleep 8
    echo "90"
    sleep 9
    echo "100"
}

###################################################################################################
# MAIN
###################################################################################################

echo "$(date) - INFO - Start" >> ${log_file}
echo "$(date) - INFO - Script version ${VERSION}" >> ${log_file}

echo "$(date) - INFO - Check, and if needed install, pre-requisites" |tee -a ${log_file}

sudo yum -y -q install ncurses-compat-libs dialog wget unzip jq python39-libs 2>&1 >>${log_file}
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
		--backtitle "MySQL ${VERSION} configuration" \
		--title "MySQL configuration menu" \
		--clear  \
		--cancel-label "Exit" \
		--menu "\nEnter follow number to use these commands" 0 0 0\
		"1" "Download install file from oracle" \
		"2" "Install mysql shell" \
		"3" "Install mysql server" \
		"4" "Test connectivity of MySQL" \
		"9" "This Program test" \
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
        2 ) 
	    clear
	    install_mysql_utilites
	    ;;
        3 )
            clear
	    install_mysql_server
	    result=$?

	    if [ $result -ne 0 ]
	    then
                systemctl stop mysqld-advanced.service &> /dev/null
	        systemctl disable mysqld-advanced.service &> /dev/null
	        userdel mysqluser &> /dev/null
	        groupdel mysqlgrp &> /dev/null
	        rm -rf /mysql/  &> /dev/null
            fi
	    ;;
	4) 
	    connect_mysql_server
	    ;;
	9 ) 
	    test_func | dialog --backtitle "test" --gauge "progress test.." 10 60
	    #read -p "Press ENTER to continue"
	    ;;
	esac

    done
fi

echo "$(date) - INFO - End" >> ${log_file}
exit $ERR
