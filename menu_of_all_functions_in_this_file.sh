#!/bin/bash
#
#   Copyright 2013 Christian Andersson, www.technotes.se
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
#
#   FEATURES: This script will print a menu of all the functions present
#           in this file that starts with the name functionX.
#           The function names will be converted into a readable format.
#           All function names starting with helpFunction will be ignored.
#           The user is presented with a menu from which the
#           user can chosse to run all functions in this list or a
#           specific function from the list.
#
#   USAGE:  Call the function helpFunctionPrintMenu to list a menu of all
#           the functions present in this file. The user can then choose 
#           to run one of these specific functions or all of them.


# Get the filename of this script
filename=$(echo $0 |cut -d "/" -f 2)

#Find all functions in this file by greping for the first part of the function name and then removing everything in the function string between ... to ...'('
functionsList=($(grep -v "functionsList" ${filename}|grep "function function" | awk '{gsub("function ", ""); print;}' | cut -d \( -f 1))

#Global variable used to convert the function name into a readable name.
readableFunctionName=""


# Print a menu of functions that the user can select from
function helpFunctionPrintMenu()
{
        printf "1 - Excute all\n"

        # For each item in the functionsList array, convert the function name to a readable format then print the menu item
        for index in ${!functionsList[*]}
        do
                readableFunctionName=${functionsList[$index]}
                helpFunctionSplitStringOnCapitalLetters
                # Since exit is defined as menu option 1 and the array index starts at zero add 2 to index
                # The awk part removes 'function ' from the string to make it more readable
                printf "%d - %s\n" $(echo $index + 2 | bc) "$(echo ${readableFunctionName} | awk '{gsub("function ", ""); print;}')"
        done

        # Call the helpFunctionReadAndCheckInput function to get and verify the users input, passing the correct menu item number, hence the $(echo ${index} + 2| bc)
        helpFunctionReadAndCheckInput $(echo ${index} + 2| bc)
}

# Split the function name into a readable format. Example: Input = "funcMyHelpFunction" will give the following output = "func My Help Function"
function helpFunctionSplitStringOnCapitalLetters()
{
        # The awk syntax can be a bit tricky to read therefore I explain the algorithm below
        # 0) Input the function name to awk - $(echo ${readableFunctionName} | awk ...
        # 1) Split all characters into a character array - {split($0, chars, "");
        # 2) Define an empty string variable in which we will store the final string - string = ""
        # 3) Traverse all characters - for(i=1;i<=length(chars);i++)
        # 4) If a char is an uppercase letter - if(match(chars[i], /[A-Z]/))
        # 5)    Then store an space char " " into the string variable
        # 6) Else store the char to the string variable as is
        # Example: Input = "funcMyHelpFunction" will give the following output = "func My Help Function"
        readableFunctionName=$(echo ${readableFunctionName} | awk '{split($0, chars, ""); string = ""; for(i=1;i<=length(chars);i++) {if(match(chars[i], /[A-Z]/)) {string = string " " chars[i]; } else { string = string chars[i]; } }  printf("%s\n", string);}')
}

# Verify that the user input is corresponding to a valid option from the menu
function helpFunctionReadAndCheckInput()
{
        numberOfMenuItems=$1
        # Print menu and get input from the user
        printf "Please choose one: "
        read REPLY
        echo "Your have choosen: '$REPLY'"
        # If the users input is greater than zero and less than the number of menu items
        if [[ ${REPLY} -gt 0 && ${REPLY} -lt $(echo ${numberOfMenuItems} + 1| bc) ]]
        then
                # If the user entered menu item 1 " Execute all" then run the function helpFunctionRunAllFunctions and run all functions listed in the menu
                if [[ ${REPLY} -eq 1 ]]
                then
                        helpFunctionRunAllFunctions
                # If the user entered one of the other menu items then call helpFunctionRunSpecificFunction and run the specific function selected from the menu
                else
                        helpFunctionRunSpecificFunction ${REPLY}
                fi
        # If the users input was not listed in the menu then print an error message and quit
        else
                echo "ERROR: Your input is not in the menu, quitting..."
                exit
        fi
}

# Run all functions in the functionsList array
function helpFunctionRunAllFunctions()
{
        # For each item in the functionsList array, run that function
        for index in ${!functionsList[*]}
        do
                ${functionsList[$index]}
        done
}

# Run the function in the functionList array corresponding to the function selected from the menu
function helpFunctionRunSpecificFunction()
{
        selecdtedMenuItem=$1
        printf "selecdtedMenuItem = ${selecdtedMenuItem}\n"
        # Run the function found in functionsList array at position menuItem -2 since the menu starts at "2" (Execute all menu item = "1") and the array index starts at "0"
        ${functionsList[$(echo $selecdtedMenuItem -2| bc)]}
}

# Example test function to demonstrate the functionality. This function will be called since the name of the function starts with function
function functionTestFuntion1()
{
	echo "Running example function 'functionTestFuntion1'"
}

# Example test function to demonstrate the functionality. This function will be called since the name of the function starts with function
function functionTestFuntion2()
{
        echo "Running example function 'functionTestFuntion2'"
}


# Run the print menu function, which is the starting point of this script
helpFunctionPrintMenu

# Exit this script
exit

