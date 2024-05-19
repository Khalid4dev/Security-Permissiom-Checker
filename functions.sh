#!/bin/bash


fork() {
    echo "$1"
    python3 -c "import subprocess; subprocess.run(['bash', '-c', '. \"$0\"; exec \"$@\"'])"
}


# Function to check permissions of a file and return them
checkPermission() {
    file="$1"
    
    if [ ! -e "$file" ]; then
        echo "File '$file' does not exist."
        exit 1
    fi
    permissions=$(stat -c "%A" "$file")
    echo "$permissions"
}


check_vul(){
    
    vulnerable_files=$(find "$1" -type f \( -perm -o=w -o -perm -o=x \))
    return $vulnerable_files
}

# Function to compare permissions between two files
compare_permissions() {
    case "$1" in
    -h)
        echo "This function compares the permissions of two files."
        echo "You will be prompted to enter the paths of the two files to compare."
        echo "-h shows help , -f to fork the command , -s run it in a subshell , -t to use threads"
        exit 0;;
    -f)
        fork "compare_permissions $@"
        exit 0;;
  
    esac
   
    while true; do
        read -p "Enter path to first file: " file1
        read -p "Enter path to second file: " file2

        if [ -z "$file1" ] || [ -z "$file2" ]; then
            echo "Please provide paths to both files."
            continue
        fi

        if [ ! -e "$file1" ]; then
            echo "First file does not exist. Please enter an existing file."
            continue
        fi

        if [ ! -e "$file2" ]; then
            echo "Second file does not exist. Please enter an existing file."
            continue
        fi

        break
    done
    permissions_file1=$(checkPermission "$file1")
    permissions_file2=$(checkPermission "$file2")
    if [ "$permissions_file1" = "$permissions_file2" ]; then
        echo "Permissions are identical for both files."
    else
        echo "Permissions are different:"
        echo "$file1: $permissions_file1"
        echo "$file2: $permissions_file2"
    fi
}

# Function to change permissions of a file
Change_Perm() {

   

    case "$1" in
    -h)
    echo "This function changes the permission of a all files in given directory."
        echo "You will be prompted to enter the paths of a directory."
        echo "-h shows help , -f to fork the command , -s run it in a subshell , -t to use threads"
        exit 0;;
    -f)
        fork "Change_Perm $@"
        exit 0;;
    
    esac


    while true;do
    read -p "entrez le chemin de votre dossier : " dir
    if [ ! -e "$dir" ];then
        continue
    fi
    break
    done
    local files=$(find "$dir" -type f)
    for file in $files; do
        chmod o-xw "$file" && chmod g-xw "$file"
        echo "$file"
    done
    echo "done"
}

# Function to encrypt files
Encrypt() {
    case "$1" in
    -h)
    echo "This function Encypts of a all files in given directory."
        echo "You will be prompted to enter the path of a directory. and the wanted password"
        echo "-h shows help , -f to fork the command , -s run it in a subshell , -t to use threads"
        exit 0;;
    -f)
        fork Change_Perm @a
        exit 0;;
    
    esac

    read -p "entrez le chemin de votre dossier : " dir
    
    local files=$(find "$dir" -type f)

    echo $files
    local password="${!#}"
    for file in $files; do
        echo $file
        if [ -f "$file" ]; then
            openssl enc -aes-256-cbc -salt -pbkdf2 -in "$file" -out "$file.enc" -k "$password"
            rm "$file"
        fi
    done
}

# Function to decrypt files
Decrypt(){

    case "$1" in
    -h)
    echo "This function Decrypt of a all files in given directory."
        echo "You will be prompted to enter the paths of a directory. and its password"
        echo "-h shows help , -f to fork the command , -s run it in a subshell , -t to use threads"
        exit 0;;
    -f)
        fork Change_Perm @a
        exit 0;;
   
    esac

    read -p "entrez le chemin de votre dossier : " dir
    
    local files=$(find "$dir" -type f)
    local password="${!#}"
    for file in $files; do
        if [ -f "$file" ]; then
            if openssl enc -d -aes-256-cbc -pbkdf2 -in "$file" -out "${file%.enc}" -k "$password"; then
                echo "Decryption successful: $file"
                rm "$file"
            else
                echo "Decryption failed or incorrect password: $file"
                rm "${file%.enc}"
            fi
        fi
    done
}

# Function to weaken permissions of files in a directory
weaken(){

    dirs=$(find "$1" -type f)
    for file in $dirs;do
    chmod o+xw $file
    done
    echo "weaken done"
}



help() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  -h (help)          Display detailed documentation of the program"
    echo "  -f (fork)          Allows execution by creating subprocesses with fork"
    echo "  -t (thread)        Allows execution by threads"
    echo "  -s (subshell)      Executes the program in a subshell"
    echo "  -l (log)           Allows specifying a directory for storing the log file"
    echo "  -r (restore)       Resets default settings, usable only by administrators"
    echo "Example:"
    echo "  enc -f"
}

# -f option

fork_command() {
    file="$1"
    if [ -z "$file" ]; then
        echo "Please provide a file to monitor."
        exit 1
    fi
    echo "Forking command: Monitoring permissions of $file"
    while true; do
        permissions=$(checkPermission "$file")
        echo "Current permissions for $file: $permissions"
        sleep 5
    done
}
# -t option
threadCommand() {
    if [ $# -eq 0 ]; then
        echo "Please provide at least one file to monitor."
        exit 1
    fi
    trap 'kill $(jobs -p)' SIGINT
    for file in "$@"; do
        (
            while true; do
                permissions=$(checkPermission "$file")
                echo "Current permissions for $file: $permissions"
                sleep 5
            done
        ) &
    done

    # Wait for all background jobs to finish
    wait
}

# -s option

subshell_command() {
    log_function_run
    func=$1
    shift
    if [ -z "$func" ]; then
        echo "Please provide a function to run in a subshell."
        exit 1
    fi
    (
        # Run the provided function in a subshell with all remaining arguments
        $func "$@"
    )
}

# Global variable for the log directory that can be set with the -l option

# -l option
log_command() {
    dir="$1"
    if [ -z "$dir" ]; then
        echo "Please provide a directory for storing log files."
        exit 1
    fi
    if [ "$dir" = "$LOG_DIR" ]; then
        echo "Log directory is already set to $LOG_DIR"
        return
    fi
    if [ ! -d "$dir" ]; then
        echo "Directory '$dir' does not exist."
        exit 1
    fi
    if [ ! -w "$dir" ]; then
        echo "Directory '$dir' is not writable."
        exit 1
    fi
    LOG_DIR="$dir"
    echo "Log directory set to $LOG_DIR"
}
# -r option
restore_command() {
    if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you need to run this script as root."
        exit 1
    fi
    # Add commands to restore default settings here
    echo "Default settings restored."
}
#log function
log_function_run() {
    func=${FUNCNAME[1]} # Get the name of the calling function
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp: $func was run" >> "$LOG_DIR/function_log.txt"
}
# Function Menu


menu(){
    echo "cmpp. Compare Permissions"
    echo "cp. Change Permissions"
    echo "enc. Encrypt"
    echo "dec. Decrypt"
    echo "e. Exit"
    read -p "Enter your choice: " input

    choice=$(echo $input | awk '{print $1}')
    args=$(echo $input | cut -d ' ' -f 2-)
    

    echo $choice

    case $choice in
        cmpp) compare_permissions $args ;;
        cp) Change_Perm $args ;;
        enc) Encrypt $args ;;
        dec) Decrypt $args ;;
        5) read -p "Enter command to fork: " command
           fork_command "$command" ;;
        6) exit ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
}
