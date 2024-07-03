#!/bin/bash

fork(){
    python3 -c "import subprocess; subprocess.run(['bash', '-c', '. \"$0\"; $1'])"
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

# Function to compare permissions between two files
compare_permissions() {
    log_function_run
    case "$1" in
    -h)
     echo "This function compares the permissions of two files."
        echo "You will be prompted to enter the paths of the two files to compare."
        echo "-h shows help , -f to fork the command , -s run it in a subshell , -t to use threads"
        exit 0;;
    -f)
        shift # Move to the next argument after -f
        fork "compare_permissions $@"
        exit 0;;
    -s)
        echo "<--Subshell-->"
        subshellCommand
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
    log_function_run
    case "$1" in
    -h)
    echo "This function changes the permission of a all files in given directory."
        echo "You will be prompted to enter the paths of a directory."
        echo "-h shows help , -f to fork the command , -s run it in a subshell , -t to use threads"
        exit 0;;
    -f)
        shift # Move to the next argument after -f
        fork "Change_Perm $@"
        exit 0;;
    -s)
        echo "<--Subshell-->"
        subshellCommand
        exit 0;;
    esac
    while true; do
        read -p "Enter the directory path: " dir
        if [ ! -d "$dir" ]; then
            echo "Directory does not exist."
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
    log_function_run
    case "$1" in
    -h)
    echo "This function Encypts of a all files in given directory."
        echo "You will be prompted to enter the path of a directory. and the wanted password"
        echo "-h shows help , -f to fork the command , -s run it in a subshell , -t to use threads"
        exit 0;;
    -f)
        shift # Move to the next argument after -f
        fork "Encrypt $@"
        exit 0;;
    -s)
        echo "<--Subshell-->"
        subshellCommand
        exit 0;;
    esac

    read -p "enter the path of the directory : " dir
    
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
Decrypt() {
    log_function_run
    case "$1" in
    -h)
    echo "This function Decrypt all files in given directory."
        echo "You will be prompted to enter the path of a directory. and the needed password"
        echo "-h shows help , -f to fork the command , -s run it in a subshell , -t to use threads"
        exit 0;;
    -f)
        shift # Move to the next argument after -f
        fork "Decrypt $@"
        exit 0;;
    -s)
        echo "<--Subshell-->"
        subshellCommand
        exit 0;;
    esac
    read -p "Enter the directory path: " dir
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

help(){
    echo "Usage: $0 [option]"
            echo "Options:"
            echo "  -h (help)          Display detailed documentation of the program"
            echo "  enc                Run the Encryption command"
            echo "  dec                Run the Decryption command"
            echo "  cmpp               Compare two files Permisions"
            echo "  cp                 Change the a Directory SubFolders Permissions"
            echo "Example:"
            echo "  enc -f"
            exit 0
}
# -s option

subshellCommand() {
    func=${FUNCNAME[1]} # Get the name of the calling function
    shift
    (
        # Run the provided function in a subshell with all remaining arguments
        $func "$@"
    )
}
# -l option
log_command() {
    dir="$1"
    if [ -z "$dir" ]; then
        echo "Please provide a directory for storing log files."
        exit 1
    fi
    if [ "$dir" = "$(cat logDirPath.txt 2>/dev/null)" ]; then
        echo "Log directory is already set to $(cat logDirPath.txt)"
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
    echo "$dir" > logDirPath.txt  # Store the directory path in logDirPath.txt
    echo "Log directory set to $(cat logDirPath.txt)"
}
#show the log directory
show_log_dir() {
    if [ ! -f logDirPath.txt ]; then
        echo "Log directory is not set."
        return
    fi
    echo "Log directory is set to $(cat logDirPath.txt)"
}
# -t option
generate_threads() {
    echo "Starting generate_threads in PID $$"
    local command="$1"
    local num_threads=2
    echo $command
    for ((i = 0; i < num_threads; i++)); do
        (
            eval "$command" &
        ) &
    done
}
# -r option
restore_command() {
    if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you need to run this script as root."
        exit 1
    fi
    if [ ! -f logDirPath.txt ]; then
        echo "Log directory is not set."
        return
    fi
    LOG_DIR=$(cat logDirPath.txt)
    > "$LOG_DIR/log.txt"  # Clear the log file
    # Add commands to restore default settings here
    echo "Logs cleared."
}
#test function
test_function() {
    echo "This is a test function."
}
#log function
log_function_run() {
    if [ ! -f logDirPath.txt ]; then
        echo "Log directory is not set."
        return
    fi
    LOG_DIR=$(cat logDirPath.txt)
    func=${FUNCNAME[1]} # Get the name of the calling function
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp: $func was run" >> "$LOG_DIR/log.txt"
}
# Parse command line arguments
while getopts ":hflr" opt; do
    case ${opt} in
        h ) # Display help message
            help
            ;;
        l ) # Set log directory
            log_command $2
            ;;
        r ) # Restore default settings
            restore_command
            ;;
        t ) # Generate threads
            generate_threads "$OPTARG"
            ;;
        *)  echo "Invalid option: $OPTARG" 1>&2;;
    esac
done
shift $((OPTIND -1))



# Otherwise, execute the specified function
case "$1" in
    enc) Encrypt "${@:2}" ;;
    dec) Decrypt "${@:2}" ;;
    cmpp) compare_permissions "${@:2}" ;;
    cp) Change_Perm "${@:2}" ;;
    test) test_function ;;
    
esac
