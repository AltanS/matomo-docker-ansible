#!/bin/bash
set -e

# Update package list and install Python3, pip, and venv
sudo apt-get update

# Install Atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

## setup bash shell config required by atuin
curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
echo '[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh' >> ~/.bashrc

# setup atuin
echo 'eval "$(atuin init bash)"' >> ~/.bashrc
