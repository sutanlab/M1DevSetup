#!/bin/zsh

# Script to install dependencies for a developer on Apple Silicon M1. 
# Pre-requisites: Git, Zsh (Mac uses zsh by default)
# Note: that all dependencies installed through homebrew by default will be done through Rosetta 2 since M1 doesnt't have native support for all formulas.
# Note: Homebrew in rosetta is installed in /usr/local/bin. When M1 support arrives it will be installed in /opt
# Node v15 works on Mac M1 for now. 

# Author: Hemant Joshi

# TODO: Install php, mongo, mysql, postgresql

source ~/.zshrc

bold=$(tput bold)

check_install_result() {
    if [ $? -eq 0 ]; then
        printf "\n${bold}$1 installed successfully\n"
    fi

    sleep 5
}

printf "${bold}\n--------------------- Welcome to dev setup Part I ---------------------\n\n"
printf "${bold}This includes setting up of homebrew and installing basic dependencies...\n"

arch -x86_64 /usr/local/bin/brew -v >> /dev/null
if [ $? -eq 0 ]; then
    printf "${bold}\nHomebrew is already installed under Rosetta..\n"
else
    printf "${bold}\nHomebrew is not installed... Installing homebrew under Rosetta for now...\n"
    arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    echo 'alias ibrew="arch -x86_64 /usr/local/bin/brew"' >> ~/.zshrc
    source ~/.zshrc
    ibrew --help
    check_install_result "ibrew"
fi

/opt/homebrew/bin/brew -v >> /dev/null
if [ $? -eq 0 ]; then
    printf "${bold}\nM1 Homebrew already Installed\n"
else
    printf "${bold}\nInstalling M1 Homebrew\n..."
    sudo mkdir -p /opt/homebrew
    sudo chown -R $(whoami):staff /opt/homebrew
    cd /opt
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
    echo 'export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH' >> ~/.zshrc
fi

commands_install=(
    zsh-syntax-highlighting
    go
    android-platform-tools
    htop
    openjdk
    redis
    pyenv
    postgresql
    sqlc
)

printf "\n"

for j in $commands_install
do
    printf "${bold}Installing $j\n"
    ibrew list $j > /dev/null
    if [ $? -eq 0 ]; then
        printf "$j already installed successfully\n\n"
    else
        ibrew install $j
        check_install_result "$j"
    fi
done

java --version
if [ $? -eq 0 ]; then
    printf "\n${bold} Java setup successfull"
else
    `sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk`
fi

# Installing heroku-cli
printf "\n${bold} Heroku CLI\n"
ibrew list heroku > /dev/null
if [ $? -eq 0 ]; then
    printf "heroku installed successfully\n"
else
    ibrew tap heroku/brew > /dev/null
    ibrew install heroku
    check_install_result "heroku"
fi

zsh node_deps.sh
yarn --version
if [ $? -eq 0 ]; then
    printf "${bold}\nYarn installed successfully\n"
else
    printf "${bold}\nYarn not installed\n"
fi

echo 'export PATH=$(pyenv root)/shims:$PATH' >> ~/.zshrc

zsh py_deps.sh
python --version
if [ $? -eq 0 ]; then
    printf "${bold}\nPython Installed...\n"
else
    printf "${bold}\nReinstall python\n"
fi