#!/bin/bash

###############################################################################
# Relevant function and variables. 
###############################################################################

# Function to install packages
function install_package()
{
	local package="$1"
	if ! dpkg -s "$package" > /dev/null 2>&1; then
		echo "Installing $package ..."
		sudo apt-get install "$package" -y
	else
		:
	fi
}

# Defining an array of dependencies
packages=(
	"gcc"
	"valgrind"
	"make"
	"gdb"
	"inotify-tools"
	"findutils"
	"git"
	"xdotool"
	"xdg-utils"
	"tar"
	"bzip2"
	"gzip"
	"unrar"
	"unzip"
	"binutils"goto dhcp
	"coreutils"
	"sed"
	"curl"
	"ffmpeg"
	"cmatrix"
	"tree"
	"nodejs"
	"npm"
	"xclip"
)

# Get the path to the directory where the script is located
SCRIPT_DIR="$PWD"

# Find path to git repository.
CHOOSE_GIT=($(find "$HOME" -name ".git" -type d -exec dirname {} \;))
num_dirs=${#CHOOSE_GIT[@]}
CHOOSED_GIT="$CHOOSE_GIT"

if [ $num_dirs -eq 0 ]; then
	echo "No git directories found."
	return 1
elif [ $num_dirs -gt 1 ]; then
	echo "Multiple git directories found."
	for (( i=0; i<$num_dirs; i++ )); do
		echo "[$i] ${CHOOSE_GIT[$i]}"
	done
	read -p "Enter the number of the directory to navigate to: " choice
	CHOOSED_GIT="${CHOOSE_GIT[$choice]}"
fi

GIT="$CHOOSED_GIT"

###############################################################################
# Welcome message for user. 
###############################################################################

echo -e "Welcome to your new environment!" 
read -p "First we need to install some dependencies. Are you ready? [y/n]: " answer

if [[ "$answer" != "y" ]] && [[ "$answer" != "Y" ]]; then
	echo "Installation cancelled by "$USER" 😑️"
	exit 1
fi

###############################################################################
# Updating and installing packages.
###############################################################################

echo "Updating before installation. This may take a while ..."
sudo apt-get update && sudo apt-get upgrade -y

# Loop through the array of package names
for pkg in "${packages[@]}"; do
	install_package "$pkg"
done

if npm list -g how2 >/dev/null 2>&1; then
	:
else
	sudo npm install -g how2
fi

if [ -z "$GIT" ]; then
	echo "Error: Could not find your git repository in $(pwd) or its parent directories" >&2
	exit 1
fi

clear

###############################################################################
# Rename files, insert text, copy files and create necessary directories.
###############################################################################

# Create necessary directories
make_files_dir="$GIT/utils/make_files"
project_files_dir="$GIT/utils/project_files"

if [[ -d "$make_files_dir" ]] || [[ -d "$project_files_dir" ]]; then
    # Directories exist, delete them
    rm -rf "$make_files_dir" "$project_files_dir"
fi

mkdir -p "$make_files_dir" "$project_files_dir"

# Check if directories were created successfully
if [ $? -ne 0 ]; then
	echo "Error: Failed to create necessary directories" >&2
	exit 1
fi

# Create necessary files
makefile_example_file="$make_files_dir/makefile_example"
complex_makefile_example_file="$make_files_dir/complex_makefile_example"
c_file_example_file="$project_files_dir/c_file_example.c"
test_file_example_file="$project_files_dir/test_file_example.c"
h_file_example_file="$project_files_dir/h_file_example.h"
test_file_file="$project_files_dir/test_file.c"

# Copy the files
cp "${SCRIPT_DIR}/makefile_example_setup" "$makefile_example_file"
cp "${SCRIPT_DIR}/complex_makefile_example_setup" "$complex_makefile_example_file"
cp "${SCRIPT_DIR}/c_file_example_setup.c" "$c_file_example_file"
cp "${SCRIPT_DIR}/test_file_example_setup.c" "$test_file_example_file"
cp "${SCRIPT_DIR}/h_file_example_setup.h" "$h_file_example_file"
cp "${SCRIPT_DIR}/test_file_setup.c" "$test_file_file"

# Check if files were copied successfully
if [ $? -ne 0 ]; then
	echo "Error: Failed to create necessary files" >&2
	exit 1
fi

# Update test_file_example.c and c_file_example.c with the user's name
sed -i "s/&/$(echo $USER | sed 's/.*/\u&/')/g" "$test_file_example_file" "$c_file_example_file"

if [ $? -ne 0 ]; then
	echo "Error: Failed to update test_file_example.c or c_file_example.c" >&2
	exit 1
fi

# Create .myfuncs file if it doesn't exist
myfuncs_file="$GIT/.myfuncs"

if [ ! -e "$myfuncs_file" ]; then
	touch "$myfuncs_file"
fi

# Create remaining files
funfuncs_file="$GIT/.funfuncs"
if [ ! -e "$funfuncs_file" ]; then
	touch "$funfuncs_file"
fi

tricks_file="$GIT/.tricks"
if [ ! -e "$tricks_file" ]; then
	touch "$tricks_file"
fi

cp -f "${SCRIPT_DIR}/.research" "$tricks_file"
cp -f "${SCRIPT_DIR}/.fun_functions" "$funfuncs_file"
cp -f "${SCRIPT_DIR}/.functions" "$myfuncs_file"

if [ $? -ne 0 ]; then
	echo "Error: Failed to create remaining files" >&2
	exit 1
fi

###############################################################################
# Push things to configuration file .bashrc.
###############################################################################

if grep -q 'CHOOSE_GIT=($(find "$HOME" -name ".git" -type d -exec dirname {} \;))' ~/.bashrc; then
	:
else
	echo 'CHOOSE_GIT=($(find "$HOME" -name ".git" -type d -exec dirname {} \;))
num_dirs=${#CHOOSE_GIT[@]}
CHOOSED_GIT="$CHOOSE_GIT"

if [ $num_dirs -eq 0 ]; then
	echo "No git directories found."
	return 1
elif [ $num_dirs -gt 1 ]; then
	echo "Multiple git directories found."
	for (( i=0; i<$num_dirs; i++ )); do
		echo "[$i] ${CHOOSE_GIT[$i]}"
	done
	read -p "Enter the number of the directory to navigate to: " choice
	CHOOSED_GIT="${CHOOSE_GIT[$choice]}"
fi

export CHOSEN_GIT="$CHOOSED_GIT"' >> ~/.bashrc
fi

if grep -q 'export PATH="'"$HOME"'/:$PATH"' ~/.bashrc; then
	:
else
	echo 'export PATH="'"$HOME"'/:$PATH"' >> ~/.bashrc
fi

if grep -q "source "$GIT"/.myfuncs" ~/.bashrc; then
	:
else
	echo "source "$GIT"/.myfuncs" >> ~/.bashrc
fi

if grep -q "source "$GIT"/.funfuncs" ~/.bashrc; then
	:
else
	echo "source "$GIT"/.funfuncs" >> ~/.bashrc
fi

clear

###############################################################################
# Display documentations of .myfunc
###############################################################################

echo "A small explanation about function and alias you can use now:"
echo ""
echo ""
echo "# ----------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/leak
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Execute a program with valgrind to detect memory leaks and report them
#
# Syntax: leak [<program_name>]
#
# Description: The 'leak()' function executes a program with valgrind to detect memory
# leaks and report them. If no argument is provided, the function will search for the
# first executable file in the current directory and execute it with valgrind. If the
# current directory is 'test' and no argument is provided, the function will search for
# a C file in the current directory whose name ends with '_test.c', compile it into an
# executable, and execute it with valgrind. If an argument is provided, the function will
# search for a file with the provided name in the home directory (excluding the '.cache'
# directory) and execute it with valgrind.
#
# Examples: 
#   Execute an executable in the current directory with valgrind:
#   $ leak
#
#   Execute a specific executable with valgrind:
#   $ leak myprogram
#
#   Compile and execute a C file with valgrind:
#   $ cd test
#   $ touch myprogram_test.c
#   $ gcc myprogram_test.c -o myprogram_test
#   $ leak
#
#   Execute a program located in the home directory with valgrind:
#   $ leak ~/myprogram
#
# Notes:
#   - The valgrind tool must be installed on your system for this function to work.
#   - This function assumes that the program being executed is compiled with the -g flag
#     in order to generate debug information that valgrind can use.
#   - This function may not work correctly with all types of programs or in all scenarios,
#     so use it with caution and always verify the results.
# License: GPL 2.x.
# ----------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi
echo "# ----------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/run
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Execute a program with optional arguments
#
# Syntax: run [<program_name>]
#
# Description: The 'run()' function executes a program with optional arguments. If no
# argument is provided, the function will search for the first executable file in the
# current directory and execute it. If the current directory is 'test' and no argument
# is provided, the function will search for a C file in the current directory whose
# name ends with '_test.c', compile it into an executable, and execute it. If an
# argument is provided, the function will search for a file with the provided name in
# the home directory (excluding the '.cache' directory) and execute it.
#
# Examples:
#   Execute an executable in the current directory:
#   $ run
#
#   Execute a specific executable:
#   $ run myprogram
#
#   Compile and execute a C file:
#   $ cd test
#   $ touch myprogram_test.c
#   $ gcc myprogram_test.c -o myprogram_test
#   $ run
#
#   Execute a program located in the home directory:
#   $ run ~/myprogram
#
# Notes:
#   - This function assumes that the program being executed is compiled with the -g flag
#     in order to generate debug information.
#   - This function may not work correctly with all types of programs or in all scenarios,
#     so use it with caution and always verify the results.
# License: GPL 2.x.
# ----------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "#----------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/debug
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Start the GNU Debugger (GDB) in text user interface (TUI) mode for an executable with debug information
#
# Syntax: debug <executable>
#
# Description: The 'debug()' function starts the GNU Debugger (GDB) in text user interface
# (TUI) mode for an executable that has debugging information. If the executable file does
# not have debugging information, an error message will be displayed and the function will
# return a non-zero exit status. If no argument is provided, an error message will be displayed
# and the function will return a non-zero exit status.
#
# Examples:
#   Start debugging an executable in the current directory:
#   $ debug myprogram
#
# Notes:
#   - The GNU Debugger (GDB) must be installed on your system for this function to work.
#   - This function assumes that the program being debugged is compiled with the -g flag
#     in order to generate debug information that GDB can use.
#   - This function may not work correctly with all types of programs or in all scenarios,
#     so use it with caution and always verify the results.
# License: GPL 2.x.
# ----------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# ----------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/watch
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Watch files and run a make command when they change
#
# Syntax: watch [<make_command>] <file1> [<file2> ...]
#
# Description: The 'watch()' function monitors changes to specified files and runs a make
# command when any of the files change. The function uses the 'inotifywait' command to
# monitor file changes. The 'make' command is used by default, but an optional make command
# can be provided as the first argument. The function will search for files that match the
# provided names in the home directory (excluding the '.cache' directory) and use them
# for monitoring changes.
#
# Examples:
#   Watch for changes in all C files and run the default make command:
#   $ watch *.c
#
#   Watch for changes in a specific file and run the default make command:
#   $ watch myprogram.c
#
#   Watch for changes in all C files and run the 'run' make command:
#   $ watch run my_project.c ...
#
# Notes:
#   - This function requires the 'inotifywait' command to be installed.
#   - This function may not work correctly with all types of files or in all scenarios,
#     so use it with caution and always verify the results.
# License: GPL 2.x.
# ----------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# ------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/search
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Search for keywords in a file and print the paragraph containing them
#
# Syntax: search <keyword1> [<keyword2> ...]
#
# Description: The 'search()' function searches for the specified keywords in a file
# called '.tricks' located in the user's home directory. It loops through each keyword
# and highlights it in the text of the paragraph that contains it. The keyword is printed
# in red and bold, and the paragraph is printed with the keyword highlighted in yellow.
# If a keyword contains spaces, it should be enclosed in quotes. 
#
# Arguments:
#   - <keyword1>: A search term to look for in the file.
#   - [<keyword2> ...]: Optional additional search terms.
#
# Examples:
#   Search for the keyword 'bash':
#   $ search bash
#
#   Search for multiple keywords:
#   $ search 'bash' 'linux'
#
#   Search for a keyword containing spaces:
#   $ search 'command line'
#
# Notes:
#   - The function only searches in the first occurrence of '.tricks' found in the user's
#     home directory.
#   - The function requires the 'awk' and 'sed' commands to be installed.
# ------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# ------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/gitget
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Pull a file from a remote Git repository
#
# Usage: gitget <file>
#
# Description: The 'gitget' function pulls a file from the remote Git repository
# located in the current working directory. The function takes a single argument,
# which is the name of the file to be pulled. If the file exists in the repository,
# the function will check out the current branch and pull the file to the local
# directory. If the file is not found in the repository, an error message is printed.
#
# Arguments:
#   - <file>: The name of the file to be pulled.
#
# Examples:
#   Pull a file called 'README.md':
#   $ gitget README.md
#
# Notes:
#   - The function assumes that the remote Git repository is located in the current
#     working directory.
# ------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# ------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/gitignore
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Open the .gitignore file in the default editor
#
# Usage: gitignore
#
# Description:
# The 'gitignore' function searches for a '.gitignore' file in the $HOME environment
# variable and opens it in the default editor. If multiple '.gitignore'
# files are found, the user is prompted to select one to open.
#
# Examples:
#   Open the .gitignore file of the current or parent directory:
#   $ gitignore
#
# Notes:
#   - The function assumes that the default editor is set up correctly.
# ------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# ------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/GIT
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Simplify the process of committing and pushing changes to a Git repository.
#
# Usage: GIT [<commit-message>]
#
# Description: The 'GIT()' function automates the process of committing and pushing changes
# to a Git repository. It first runs the 'gitconfig' function to configure Git if needed,
# then it clears the screen, goes to the root of the repository, shows the current status,
# adds all changes, shows the new status, commits the changes with the given message or
# a default one, pushes the changes to the remote repository, and shows the final status.
# If the Git command fails, an error message is displayed.
#
# Arguments:
#   - [<commit-message>]: An optional message to be used as the commit message. If not
#     provided, a default message will be used.
#
# Examples:
#   Commit and push changes with the default message:
#   $ GIT
#
#   Commit and push changes with a custom message:
#   $ GIT 'Update README'
#
# Notes:
#   - The function assumes that the Git repository is already initialized and configured.
#   - The function assumes that the root of the repository is the current working directory.
# ------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# ------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/push
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Push changes to a remote Git repository
#
# Usage: push [branch]
#
# Description: The 'push' function pushes the changes in the current branch to the
# remote Git repository. If a branch name is provided as an argument, the function
# pushes the changes in that branch instead of the current branch. If no branch name
# is provided, the function pushes the changes in the current branch. The function
# assumes that the remote repository is named 'origin'.
#
# Arguments:
#   - [branch]: The name of the branch to push changes to (optional).
#
# Examples:
#   Push changes to the current branch:
#   $ push
#
#   Push changes to a branch named 'my-branch':
#   $ push my-branch
#
# Notes:
#   - The function assumes that the remote Git repository is named 'origin'.
# ------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# ------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/delete
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Delete a directory
#
# Usage: delete <folder_name>
#
# Description: The 'delete' function searches for a directory with the provided name
# in the user's home directory and prompts the user for confirmation before deleting
# the directory. The function can also rename the provided folder name if the
# directory is named 'review', the function will rename it to 'code_review'.
#
# Arguments:
#   - <folder_name>: The name of the folder to delete.
#
# Examples:
#   Delete a directory named 'my_folder':
#   $ delete my_folder
#
#   Delete a directory named 'review' and rename it to 'code_review':
#   $ delete review
#
# Notes:
#   - The function will search for the directory in the user's home directory.
# ------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# ------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/clean
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Clean a directory
#
# Usage: clean <folder_name>
#
# Description: The 'clean' function searches for a directory with the provided name
# in the user's home directory and prompts the user for confirmation before cleaning
# the directory. The function can also rename the provided folder name if the
# directory is named 'review', the function will rename it to 'code_review'.
#
# Arguments:
#   - <folder_name>: The name of the folder to clean.
#
# Examples:
#   Clean a directory named 'my_folder':
#   $ clean my_folder
#
#   Clean a directory named 'review' and rename it to 'code_review':
#   $ clean review
#
# Notes:
#   - The function will search for the directory in the user's home directory.
# ------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "#-------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/fopen
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Open files from the command line
#
# Usage: fopen <file_name> | h | c | all
#
# Description: The 'fopen' function opens a file from the command line. It can
# open C files, header files, and test files. If the file is a test file, the
# function also opens the corresponding C file and header file. If the current
# directory is the test directory, the function searches for the corresponding
# file name in the parent directory's include and src directories. The function
# opens the file using the system's default opener (e.g. xdg-open on Linux).
#
# Arguments:
#   - <file_name>: The name of the file to open. For test files, use the name of
#     the C file without the '_test' suffix.
#
# Examples:
#   Open a file named 'file.c':
#   $ fopen file.c
#
#   Open a file named 'file.h':
#   $ fopen file.h
#
#   Open a test file named 'file_test.c':
#   $ fopen file_test
#
#   Open all C and header files in the current directory:
#   $ fopen all
#
# Notes:
#   - The function will search for test files in the parent directory if the
#     current directory is the test directory.
#   - The function uses the system's default opener (e.g. xdg-open on Linux) to
#     open the files.
#-------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "#-------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/rename
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Rename a file or folder in the current directory
#
# Usage: rename <old_name> <new_name>
#
# Description: The 'rename' function renames a file or folder in the current directory.
# The function takes two arguments: the old file/folder name and the new file/folder name. It
# checks that the old file/folder exists in the current directory, and then renames it
# using the 'mv' command with the '-T' option. If the rename is successful, it prints a 
# success message. If there is any error, it prints an error message and returns 
# a non-zero status code.
#
# Arguments:
#   - <old_name>: The name of the file or folder to be renamed.
#   - <new_name>: The new name for the file or folder.
#
# Examples:
#   Rename a file named 'file.txt' to 'newfile.txt':
#   $ rename file.txt newfile.txt
#
#   Rename a folder named 'my_folder' to 'new_folder':
#   $ rename my_folder new_folder
#
# Notes:
#   - The function assumes that the file/folder to be renamed exists in the current
#     directory.
#-------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# ------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/histo
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Search bash history for a specific keyword.
#
# Usage: histo <keyword>
#
# Description: The 'histo' function clears the screen and searches the bash history
# for the specified keyword, displaying all commands that match.
#
# Arguments:
#   - <keyword>: The keyword to search for in the bash history.
#
# Examples:
#   Search bash history for the keyword 'cd':
#   $ histo cd
#
# Notes:
#   - The function is case sensitive.
# ------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# ------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/goto
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Navigate to a directory and optionally execute a command.
#
# Usage: goto [<directory_name>] [<command>] [<goback>]
#
# Description: The 'goto' function allows you to quickly navigate to a directory
# by name, and optionally execute a command within that directory. If multiple
# directories match the given name, the user is prompted to choose one. If no
# directory name is provided, the function navigates to the parent directory of
# the first Git repository found in the user's home directory.
#
# Arguments:
#   - <directory_name> (optional): The name of the directory to navigate to.
#   If omitted, the function navigates to the parent directory of the first Git
#   repository found in the user's home directory.
#   - <command> (optional): The command to execute in the target directory.
#   If 'open', opens all .c and .h files in the directory. Otherwise, executes
#   the specified command.
#   - <goback> (optional): If set to 'goback', navigates back to the previous
#   directory after executing the command.
#
# Examples:
#   Navigate to the 'src' directory and open all C and header files:
#   $ goto src open
#
#   Navigate to the 'work' directory, execute 'make' and then navigate back:
#   $ goto work make goback
#
# Notes:
#   - The function searches for the specified directory name in all directories
#   listed in the $PATH environment variable.
# ------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "#------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/explorer
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Open a directory in a graphical file manager.
#
# Usage: explorer <directory>
#
# Description: The 'explorer' function uses the 'find' command to search for
# directories with a given name in the directories specified in the 'PATH'
# environment variable. If a single directory is found, it is opened in the
# default graphical file manager. If multiple directories are found, the user
# is prompted to select one to open.
#
# Arguments:
#   - <directory>: The name of the directory to open.
#
# Examples:
#   Open the directory named 'Documents' in the default graphical file manager:
#   $ explorer Documents
#
# Notes:
#   - If no directory with the given name is found, the function opens the
#     current working directory.
#   - The function uses the 'xdg-open' command to open directories in the default
#     graphical file manager, which may differ depending on the user's operating
#     system and configuration.
#------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# ------------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/folder
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Create a new directory and change to it.
#
# Usage: folder <folder name>
#
# Description: The 'folder' function creates a new directory with the specified name
# and navigates to it.
#
# Arguments:
#   - <folder name>: The name of the directory to create.
#
# Examples:
#   Create a new directory called 'my_folder' and navigate to it:
#   $ folder my_folder
#
# Notes:
#   - If a directory with the specified name already exists, the function will
#     still navigate to it.
# ------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "#-------------------------------------------------------------------------------
#
#                     shlifim() function:
#
#                      Usage: shlifim
#
# The shlifim function searches for the ".tricks" file in the user's home
# directory and opens it in the default application set for that file type.
# This file is used to store custom shell functions that the user has defined.
#
#-------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "#-------------------------------------------------------------------------------
#
#                     funcommands() function:
#
#                      Usage: funcommands
#
# The funcommands function searches for the ".funfuncs" file in the user's home
# directory and opens it in the default application set for that file type.
# This file is used to store custom shell functions that the user has defined.
#
#-------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "#-------------------------------------------------------------------------------
#
#                     commands() Function:
#
#                       Usage: commands
#
# The commands function searches for the ".myfuncs" file in the user's home
# directory and opens it in the default application set for that file type.
# This file is used to store custom shell functions that the user has defined.
#
#-------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "#-------------------------------------------------------------------------------
#
#                     makefile() function:
#
#                      Usage: makefile
#
# The commands function searches for the 'complex_makefile_example' file in the 
# user's home directory and opens it in the default application set for that file 
# type. This file is used to store custom shell functions that the user has defined.
#
#-------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "#-------------------------------------------------------------------------------
#
#                     project_files() function:
#
#                       Usage: project_files
#
# The project_files function opens all the files in the "project_files" directory 
# in the user's file system
#
#-------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "#-------------------------------------------------------------------------------
#
#                     make?() function:
#
#                      Usage: make?
#
# The make? function checks if a Makefile or makefile exists in the current
# directory. If a Makefile exists, the function opens it with xdg-open. If a
# makefile exists, the function opens it with xdg-open. If neither Makefile nor
# makefile exist, the function outputs an error message.
#
#-------------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# -----------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/project
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Create a new project directory and populate it with example files.
#
# Usage: project
#
# Arguments: None.
#
# Description: The 'project' function prompts the user for a location and a name
# for the new project directory. It creates the directory and subdirectories for
# source, header, and test files. Then, it copies example files from a util
# directory into the new project directory. Finally, it opens all the project
# files in the user's preferred editor. The example files are:
#   - c_file_example.c: A C source file with basic boilerplate.
#   - h_file_example.h: A header file with a basic function declaration.
#   - test_file_example.c: A test file with a basic test function.
#   - makefile: A Makefile for building the project.
#
# Examples:
#   Create a new project directory:
#   $ project
#
# Notes:
#   - The user must have write access to the chosen location for the project.
#   - The user's preferred editor is assumed to be set in the '$EDITOR' variable.
#   - The example files are assumed to be located in the util directory.
#   - The project name must be unique in the chosen location.
# -----------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi


echo "# -----------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/local_project
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Create a new local C project with example files.
#
# Usage: local_project <project name>
#
# Arguments:
#   - <project name>: Name of the project to create.
#
# Description: The 'local_project' function creates a new directory with the
# specified project name, and copies example C files and a makefile from a
# utility directory into the new project directory. The function then replaces
# placeholder values in the example files with the project name, and opens all
# project files in a text editor.
#
# Examples:
#   Create a new project named 'my_project':
#   $ local_project my_project
#
# Notes:
#   - Example files are assumed to be located in ~/example_files.
#   - The function assumes that the makefile for the new project should be named
#     'makefile'.
# -----------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# -----------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/cfile
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Create a new C source file with a given name in the current directory.
#
# Usage: cfile <name of the file>
#
# Arguments:
#   - <name of the file>: The name of the new C source file to create.
#
# Description: The 'cfile' function takes the name of a new C source file as an argument,
# and creates a new file in the current directory with that name. The new file is
# initialized with the contents of an example C source file from the user's home directory.
# The function then opens the new file for editing.
#
# Examples:
#   Create a new C source file called 'my_file.c' and open it for editing:
#   $ cfile my_file
#
# Notes:
#   - The example C source file is assumed to be located in the user's home directory.
#   - The new file will overwrite any existing file with the same name in the current directory.
# -----------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# -----------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/makeme
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Create test functions or function skeletons for a C project.
#
# Usage: makeme <'tests' or 'functions'>
#
# Arguments:
#   - <'tests' or 'functions'>: The type of code to generate. If 'tests', test
#     functions will be generated for each function in the project's header file.
#     If 'functions', function skeletons will be generated for each function in
#     the project's header file.
#
# Description: The 'makeme' function takes one argument to generate test functions
# or function skeletons for a C project. If the argument is 'tests', the function
# will generate test functions for each function in the project's header file,
# and insert them into the project's test file. If the argument is 'functions',
# the function will generate function skeletons for each function in the project's
# header file, and insert them into the project's source file.
#
# Examples:
#   Generate test functions for a project named 'my_project':
#   $ cd /path/to/my_project
#   $ makeme tests
#
#   Generate function skeletons for a project named 'my_project':
#   $ cd /path/to/my_project
#   $ makeme functions
#
# Notes:
#   - This function assumes that the project follows a certain directory structure,
#     with source files in '../../src/' and header files in '../../include/'.
#   - The project name is assumed to be the name of the current working directory.
#   - This function only generates code for functions declared with the 'void'
#     return type.
# -----------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "# -----------------------------------------------------------------------------
# File: tal.aharon/.myfuncs/delete_project
# Author: Tal Aharon
# License: GPL 2.x
#
# Purpose: Deletes a project and all of its related files.
#
# Usage: delete_project <project name>
#
# Arguments:
#   - <project name>: The name of the project to delete.
#
# Description: The 'delete_project' function takes the name of a project as an argument,
# and deletes the project directory and all of its related files. The function prompts
# the user for confirmation before deleting the files. If the user confirms the deletion,
# the function navigates to the project directory, deletes the makefile, navigates up one
# directory, deletes the project directory, and then searches the parent directory and all
# of its subdirectories for files containing the project name and deletes them.
#
# Examples:
#   Delete the project called 'my_project':
#   $ delete_project my_project
#
# Notes:
#   - This function does not perform any safety checks. Use with caution.
#   - This function permanently deletes files and cannot be undone.
# -----------------------------------------------------------------------------"
echo ""
read -p "Press enter to continue: " answer
if [[ -z "$answer" ]]; then
	clear
fi

echo "#-------------------------------------------------------------------------------
# We are done!
#
# To review, edit or add functions you can type in the terminal: 
#
# $ commands
#
# It will open your .myfuncs file with gedit for editing and review.
#
#-------------------------------------------------------------------------------"
echo ""
read -p "Press enter to finish" finish


###############################################################################
# Delete the folder and the setup file, closing terminal and opening a new one. 
###############################################################################

cd .. && rm -rf setup.run && rm env.run

TERMINAL_ID=$(xdotool getactivewindow)

if [[ -z "$finish" ]]; then 
	# Launch a new terminal window
	gnome-terminal & disown

	# Wait for the new terminal to start up
	sleep 1s

	# Send the close command to the original terminal window
	xdotool windowactivate $TERMINAL_ID
	xdotool key ctrl+shift+w
fi
