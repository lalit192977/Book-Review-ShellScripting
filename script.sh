#!/bin/bash

echo "============================START=============================="
#*****************************VARIABLES******************************
read -p "enter the package name: " package

#*****************************FUNCTIONS******************************
# check the service is-active or not
function isActive {
    sudo systemctl is-active -q $1
}

# function for installing the package
function installPackage {
    if dpkg -l | grep -w "$1" > /dev/null
    then
        echo "$1 : package is installed"
    else
        echo "package $1 is installing...."
        sudo apt install -y "$1"
        if dpkg -l | grep -w "$1" >/dev/null 
        then
            echo "package $1 installed"
        else
            echo "error in installing the package: $1"
        fi
    fi
}

# start the service 
function serviceStart {
    if isActive "$1"
    then
        echo "the service : $1 is already started"
    else
        echo "starting the service: $1"
        if isActive "$1"
        then
            echo "service: $1 started successfully"
        else
            echo "error in starting the service: $1"
        fi 
    fi
}



#******************************CALLING********************************
