#!/bin/bash
FABDEP_HOME="$HOME/.fabdep"
NODEJS_VERSION="v12.16.1"
FABRIC_VERSION="1.4.6"
FABRIC_CA_VERSION="1.4.6"
MONGODB_VERSION="4.0.16"
ANSIBLE_LATEST='ansible==2.9'
FABDEP_VERSION="2.0"
FABDEP_UI_VERSION="0.0.1"
MINIMUM_ANSIBLE_VERSION="2.5"
MINIMUM_MONGODB_VERSION="v3.3.3"
DELAY=2
CONNECTIVITY_ERROR="Failed either you internet connection is down or downloading from internet is not enabled in Software and Updates or Firewall does not allow u to download new packages"

# check command already exist or not
command_exists() {
	command -v "$@" > /dev/null 2>&1
}

# check command already exist or not
printFaliureMessage() {
	echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    echo @@@@@@@@@@@@@@@@@@@@ Failure: $1 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    exit
}
checkNodePort() {
    PORT=$1
    echo 
    echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    echo @@@@@@@@@@@@@@@@@@@@ PORT: $PORT is free or not? @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    SYSTEM_NODE_PORT=$(sudo lsof -t -i:$PORT)

    if [ ! -z "$SYSTEM_NODE_PORT" ]; then
        echo
        echo
        echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        read -p "Port $PORT is already in use. Press Y to kill the service running on port $PORT [Y/N]" ARG
        case "$ARG" in
            y | Y)
                echo
                sudo kill -9 $SYSTEM_NODE_PORT
                echo
            ;;
            n | N)
                echo 
                echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                echo @@@@@@@@ Please free the port $PORT manually @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   
                echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                echo 
                exit 0
                ;;
            *)
                echo
                echo "Invalid Response"
                echo
                checkNodePort $PORT
                ;;
        esac
    else
        echo 
        echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        echo @@@@@@@@@@@@@@@@@@@@ Port $PORT is free @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        echo 
    fi
}

installMongoDB() {
    wget -qO - https://www.mongodb.org/static/pgp/server-4.0.asc | sudo apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -c | awk '{print $2}')/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
    sudo apt-get update -y
    sudo apt-get install -y mongodb-org=$MONGODB_VERSION || printFaliureMessage "installMongoDB $CONNECTIVITY_ERROR" 
    sudo systemctl start mongod
    sudo systemctl enable mongod
}

installAnsible() {
    sudo apt-get remove --purge ansible
    sudo apt-get autoremove
    sudo apt-get install software-properties-common -y
    sudo apt-add-repository --yes --update ppa:ansible/ansible -y
    sudo apt-get update -y
    sudo apt-get install ansible -y || printFaliureMessage "installAnsible $CONNECTIVITY_ERROR"
    sudo apt-get install python-pip -y
    sudo pip install $ANSIBLE_LATEST

 }

setUpAnsible() {
    echo "[defaults]" | sudo tee -a /etc/ansible/ansible.cfg >/dev/null
    echo "host_key_checking = False" | sudo tee -a /etc/ansible/ansible.cfg >/dev/null
    echo "command_warnings = False" | sudo tee -a /etc/ansible/ansible.cfg >/dev/null
    echo "system_warnings = True" | sudo tee -a /etc/ansible/ansible.cfg >/dev/null
    echo "deprecation_warnings = True" | sudo tee -a /etc/ansible/ansible.cfg >/dev/null
}
setFabricBinaries() {
   echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   echo @@@@@@@@@@@@@@@@ Fabric Binaries $FABRIC_VERSION  @@@@@@@@
   echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   echo
   curl -sSL http://bit.ly/2ysbOFE | bash -s -- $FABRIC_VERSION $FABRIC_CA_VERSION -sd
   echo
   sleep $DELAY
}
installNVM() {
sudo apt-get update -y
sudo apt-get -y install build-essential libssl-dev || printFaliureMessage "installNVM $CONNECTIVITY_ERROR"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

sleep $DELAY
. $HOME/.bashrc
}
. $HOME/.profile

installnodejs() {
echo
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@ Installing Nodejs $NODEJS_VERSION LTS @@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#. ~/.nvm/nvm.sh
nvm install $NODEJS_VERSION || printFaliureMessage "installNode $CONNECTIVITY_ERROR"
nvm use $NODEJS_VERSION
nvm alias default $NODEJS_VERSION
echo
. $HOME/.profile
}

installPM2() {
. ~/.profile
. $HOME/.profile
. ~/.nvm/nvm.sh
npm install pm2 -g 
chown $USER:$USER -R /home/$USER/.pm2/

}



installfabdep() {
echo
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@ Installing Fabdep $FABDEP_UI_VERSION  @@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
sudo dpkg -i ./fabdep_$FABDEP_UI_VERSION-amd64.deb
echo
sleep $DELAY
. $HOME/.profile
}

# Check if the port is opened or not
checkNodePort 3002
sleep $DELAY

checkNodePort 4200
sleep $DELAY

# check $FABDEP_HOME dir already exits or not
if [ ! -d $FABDEP_HOME ]; then
    # make fabdep dir
    mkdir -p $FABDEP_HOME
fi

# copy the files
if [ "$PWD" != "$FABDEP_HOME" ]; then
    # Copy current files to to $FABDEP_HOME
    yes | cp -rf ./* $FABDEP_HOME
    cd $FABDEP_HOME
fi

if ([ ! -f $HOME/.profile ]) then
    cp /etc/skel/.profile /home/$USER/
fi


echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@ Now Fabdep is running in $FABDEP_HOME dir @@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


# Install curl
#Check if there is a curl command running if not then installs it
if (command_exists curl) then
    echo 
    echo curl already exists
    echo
else
    sudo apt-get -y install curl
fi
sleep $DELAY

# Install jq
#Check if there is a jq command running if not then installs it
if (command_exists jq) then
    echo 
    echo jq already exists
    echo
else
    sudo apt-get -y install jq
fi
sleep $DELAY

# Install wget
#Check if there is a wget command running if not then installs it
if (command_exists wget) then
    echo 
    echo wget already exists
    echo
else
    sudo apt-get -y install wget
fi
sleep $DELAY

# Install xdg-utils
#Check if there is a xdg-utils command running if not then installs it
if (command_exists xdg-utils) then
    echo 
    echo xdg-utils already exists
    echo
else
    sudo apt-get -y install xdg-utils
fi
sleep $DELAY

echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@ MongoDB $MONGODB_VERSION  @@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# This process checks if there is a current version of Mongodb installed and  if there is no mongodb installed installation starts. 
if (command_exists mongo) then
    echo 
    
    EXISITNG_MONGODB_VESION="$(mongo -version | head -1  | awk '{print $4}')"

    echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    echo @@@@@@@@@@@@@@@@ MongoDB already exists $EXISITNG_ANSIBLE_VESION @@@@@@@@@@@@@@@@@@
    echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    echo
else
    echo
    installMongoDB
    echo
fi
sleep $DELAY

# Install Ansible
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@ Installing Ansible @@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# This process checks if there is a current version of Ansible installed and  if there is no Ansible installed installation starts. 
ANSIBLE_VERSION="2.0.0.0"
if  [ -x "$(command -v ansible)" ] && [ "$(ansible --version|head -1|awk '{print $2}')" '>' "$ANSIBLE_VERSION" ]; then
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@Ansible already exits "$(ansible --version|head -1|awk '{print $2}')"@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    # Setup Ansible config file
    echo
    setUpAnsible
    echo
else
    echo 
    installAnsible
    echo
    sleep $DELAY

    echo
    setUpAnsible
    echo
fi
sleep $DELAY

# Install Fabric binaries
# This process checks if there is a current version of Binaries installed and then checks the current version and matches with the current version if there is no match in the version the Binaries installation starts again 
#CONFIGTXGEN_VERSION=$(configtxgen --version| head -2|tail -1| awk '{print $2}')
#echo @@@@@@@@@@@@@@@@ CONFIGTXGEN_VERSION $CONFIGTXGEN_VERSION@@@@@@@@@@@@@@@@@@

#CONFIGTXLATOR_VERSION=$(configtxlator  version| head -2|tail -1| awk '{print $2}')
#echo @@@@@@@@@@@@@@@@ CONFIGTXLATOR_VERSION $CONFIGTXLATOR_VERSION@@@@@@@@@@@@@@@@@@

if [ -x "$(command -v configtxgen)" ] && [ "$FABRIC_VERSION" = "$(configtxgen --version| head -2|tail -1| awk '{print $2}')" ] && [ "$FABRIC_VERSION" = "$(configtxlator  version| head -2|tail -1| awk '{print $2}')" ]; then 
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@ Binaries already exits $FABRIC_VERSION@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
else
setFabricBinaries
 echo
 sleep $DELAY
fi

# Import the bins to profile 
echo "export GOROOT=/usr/local/go" | tee -a $HOME/.profile
echo "export GOPATH=$HOME/go" | tee -a $HOME/.profile 
echo "export PATH=$FABDEP_HOME/bin:\$GOPATH/bin:\$GOROOT/bin:\$PATH" | tee -a $HOME/.profile


echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@ NVM Version $NVM_CURRENT_VERSION@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Check is there is  NVM existing files on the system.
if [ -f ~/.nvm/nvm.sh ]; then
    echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    echo @@@@@@@@@@@@@@@@@"NVM bash file exists."@@@@@@@@@@@@@@@@@@@@@@@@
    echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
. ~/.nvm/nvm.sh
#. ~/.bashrc
#. ~/.profile
else
. ~/.bashrc
#. ~/.profile
fi

# Check is there is  NVM is installed on the system.
if (command_exists nvm) then
    echo 
    echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    echo @@@@@@@@@@@@@@@@ NVM already exists @@@@@@@@@@@@@@@@@@
    echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    echo
else
   echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   echo @@@@@@@@@@@@@@@@ Inatslling nvm @@@@@@@@@@@@@@@@@@
   installNVM
    echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    echo
fi
sleep $DELAY

# Install nodejs
# This process checks if there is a current version of node installed and then checks the current version and matches with the current version if there is no match in the version the node instattion starts again 
NODEJS_VERSION="v12.16.1"
#NODEJS_CURRENT_VERSION=$(node --version)
echo  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@ Node Version $NODEJS_CURRENT_VERSION@@@@@@@@@@@@@@@@@@
echo  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
export NVM_DIR="$HOME/.nvm"

if  [ -x "$(command -v node)" ] && [ "$NODEJS_VERSION" = "$(node --version)" ] ; then 

echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@ NODEJS exits $NODEJS_VERSION@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
else
installnodejs 
 sleep $DELAY
fi

#Installing pm2
. ~/.nvm/nvm.sh
if (command_exists pm2) then
    echo 
    echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    echo @@@@@@@@@@@@@@@@ pm2 already exists @@@@@@@@@@@@@@@@@@
    echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    echo
else
   echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   echo @@@@@@@@@@@@@@@@ Installing pm2 @@@@@@@@@@@@@@@@@@
   installPM2
    echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    echo
fi

. $HOME/.profile
chown $USER:$USER -R /home/$USER/.pm2/


#Installing Fabdep
if  [ -x "$(command -v Xorg)" ]; then 

installfabdep
else
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@ fabdep requires gui for the build@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
fi

echo
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@ Starting Fabdep @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo
cd $FABDEP_HOME/fabdep-$FABDEP_VERSION-$NODEJS_VERSION
sleep $DELAY

. ~/.nvm/nvm.sh
. ~/.profile
. $HOME/.profile

npm install -y
pm2 start launcher.js --name fabdep
echo
sleep $DELAY
. ~/.bashrc
if(command_exists fabdep) then
    echo
    fabdep
    echo
else
    echo
    echo "Fabdep is not installed"
    exit 0
    echo
fi

