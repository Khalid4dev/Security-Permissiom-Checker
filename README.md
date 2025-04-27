# Security permission checker

## Overview
This repository contains a collection of Bash utility scripts for file permission management, encryption, decryption, and logging. These scripts are designed to simplify common administrative tasks and provide flexible options for running commands in various environments.

## Features
- **File Permission Management**: Check, compare, and change file permissions.
- **File Encryption and Decryption**: Secure files with AES-256 encryption and decrypt them when needed.
- **Logging**: Track the execution of functions and manage log directories.
- **Forking and Subshell Execution**: Run commands in a subshell or fork them to a new process.
- **Thread Generation**: Run commands in multiple threads for parallel execution.
- **Restoration**: Restore default settings and clear logs.

## Prerequisites
- **Python 3.x** (required for forking functionality)
- **OpenSSL** (for encryption and decryption)

## Installation
Clone the repository to your local machine:
```bash
git clone <repository-url>
cd <repository-directory>
```

## Usage
The script supports various options and commands:

### Options
- `-h` : Display detailed documentation of the program.
- `-l <directory>` : Set the log directory.
- `-r` : Restore default settings and clear logs.
- `-t <command>` : Generate threads to run the specified command.

### Commands
- `enc` : Run the encryption command.
- `dec` : Run the decryption command.
- `cmpp` : Compare the permissions of two files.
- `cp` : Change the permissions of all files in a given directory.
- `test` : Run a test function.

### Examples
- **Encrypt files in a directory**:
  ```bash
  ./script.sh enc -f
  ```
- **Decrypt files in a directory**:
  ```bash
  ./script.sh dec -f
  ```
- **Compare permissions of two files**:
  ```bash
  ./script.sh cmpp
  ```
- **Change permissions of files in a directory**:
  ```bash
  ./script.sh cp
  ```

### Subshell Execution
Use the `-s` option to run commands in a subshell:
```bash
./script.sh <command> -s
```

### Forking Commands
Use the `-f` option to fork commands to a new process:
```bash
./script.sh <command> -f
```

### Thread Generation
Run commands in multiple threads with the `-t` option:
```bash
./script.sh -t "<command>"
```

## Logging
Set the log directory using the `-l` option:
```bash
./script.sh -l <directory>
```
View the current log directory:
```bash
./script.sh show_log_dir
```

Restore default settings and clear logs:
```bash
./script.sh -r
```

## Contributors
Feel free to contribute by forking the repository and submitting pull requests.

