#!/bin/bash

echo "============================START=============================="
#*****************************VARIABLES******************************
# read -p "enter the package name: " package

#*****************************FUNCTIONS******************************
# check the service is-active or not
function isActive {
    systemctl is-active -q $1
}

# function for installing the package
function installPackage {
    if dpkg -l | grep -w "$1" > /dev/null
    then
        echo "$1 : package is installed"
    else
        echo "package $1 is installing...."
        apt install -y "$1"
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
        echo "Starting $1 service..."
        systemctl start "$1"

        if isActive "$1"
        then
            echo "service: $1 started successfully"
        else
            echo "error in starting the service: $1"
        fi 
    fi
}

# clone the repo
function cloneRepository {
    if [ -d "./book-review-app" ]
    then
        echo "repository already exists"
    else
        git clone https://github.com/lalit192977/book-review-app.git
    fi
}

# install the dependency
function installNodeMOdules {
    echo "installing npm packages..." 

    npm install

    if [ $? -eq 0 ]
    then
        echo "Dependencies installed"
    else
        echo "npm install failed"
        exit
    fi

}

#******************************CALLING********************************
# installing package
installPackage "nodejs"
installPackage "npm"
installPackage "mysql-server"
installPackage "mysql-client"

# cloning the repo
cloneRepository

# changing the directory
cd ./book-review-app/backend || exit 
# install node module package
installNodeMOdules

# create database automatically
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS book_review_db;
CREATE USER IF NOT EXISTS 'bookuser'@'localhost' IDENTIFIED BY 'bookpass123';
GRANT ALL PRIVILEGES ON book_review_db.* TO 'bookuser'@'localhost';
FLUSH PRIVILEGES;
EOF

# create .env file and generate it with the environments
touch .env # creating a file

cat > .env <<EOF
DB_HOST=localhost
DB_USER=bookuser
DB_PASS=bookpass123
DB_NAME=book_review_db
DB_DIALECT=mysql

JWT_SECRET=mysecret

ALLOWED_ORIGINS=*
EOF

# start the backend
# nohup node src/server.js &
node src/server.js 
