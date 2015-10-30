#!/bin/bash

set -eux

PYTHON_2_7=2.7.10
PYTHON_3_3=3.3.6
PYTHON_3_4=3.4.3
PYTHON_3_5=3.5.0
PY_PY=pypy-2.6.1

curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/7dae69619b4be4d49e485f4c997212ed74fc4973/bin/pyenv-installer | bash

set +x
echo '----------------------------------------------------'
echo 'Waiting for PATH to be updated in your shell dotfile'
echo '----------------------------------------------------'
echo 'Press enter when ready'
set -x
read -p 'Enter your shell dotfile, ~/.bash_profile by default: ' SHELL_PROFILE

if [ -z ${PS1+n} ]; then
  echo 'Setting PS1 since we are sourcing your profile for pyenv'
  export PS1=''
fi

if [ -z ${SHELL_PROFILE} ]; then
  source ~/.bash_profile
else
  eval SHELL_PROFILE=${SHELL_PROFILE}
  source ${SHELL_PROFILE}
fi

if [ -n $(uname | grep Darwin) ]; then
  set +x
  echo 'Ensure you have the Xcode Command Line Tools installed and accept the agreement'
  echo 'https://developer.apple.com/xcode/downloads/'
  set -x
else
  set +x
  echo 'On a debian-based system, run the following:'
  echo 'sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \'
  echo 'libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm'

  echo 'On a Fedora/CentOS/RedHat system:'
  echo 'sudo yum install zlib-devel bzip2 bzip2-devel readline-devel sqlite \'
  echo 'sqlite-devel openssl-devel'
  set -x
fi

for interpreter in ${PYTHON_2_7} \
                   ${PYTHON_3_3} \
                   ${PYTHON_3_4} \
                   ${PYTHON_3_5} \
                   ${PY_PY}; do
  if [ -n $(uname -r | grep Darwin) ]; then
    # Point to the zlib headers
    # https://github.com/yyuu/pyenv/wiki/Common-build-problems#build-failed-error-the-python-zlib-extension-was-not-compiled-missing-the-zlib
    CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv install -v $interpreter
  else
    set +x
    echo 'Warning... this has NOT been vetted on non OS X systems!'
    set -x
      pyenv install -v $interpreter
  fi
done

set +x
echo 'Setting python2.7 as the default.'
echo 'Also making other interpreters available'
set -x
pyenv global ${PYTHON_2_7} ${PYTHON_3_3} ${PYTHON_3_4} ${PYTHON_3_5} ${PY_PY}
