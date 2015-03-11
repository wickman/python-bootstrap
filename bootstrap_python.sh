#!/bin/bash

set -ex

PYTHON_2_7=2.7.9
PYTHON_3_3=3.3.6
PYTHON_3_4=3.4.3
PY_PY=2.5.0

EXPAT_VERSION=2.1.0
READLINE_VERSION=6.3

SANDBOX=$(mktemp -d /tmp/python.XXXXXX)
pushd ${SANDBOX}
  wget ftp://ftp.cwru.edu/pub/bash/readline-${READLINE_VERSION}.tar.gz
  tar xzf readline-${READLINE_VERSION}.tar.gz
  pushd readline-${READLINE_VERSION}
    ./configure --disable-shared --enable-static --prefix=${SANDBOX}/readline
    make -j3 && make install
  popd
  rm -rf readline-${READLINE_VERSION}.tar.gz readline-${READLINE_VERSION}

  wget http://downloads.sourceforge.net/project/expat/expat/${EXPAT_VERSION}/expat-${EXPAT_VERSION}.tar.gz
  tar xzf expat-${EXPAT_VERSION}.tar.gz
  pushd expat-${EXPAT_VERSION}
    ./configure --disable-shared --enable-static --prefix=${SANDBOX}/expat
    make -j3 && make install
  popd
  rm -rf expat-${EXPAT_VERSION}.tar.gz expat-${EXPAT_VERSION}
popd

#TODO(Yasumoto): Move to a versioned tag
# https://github.com/yyuu/pyenv-installer/issues/20
curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

set +x
echo '----------------------------------------------------'
echo 'Waiting for PATH to be updated in your shell dotfile'
echo '----------------------------------------------------'
echo 'Press enter when ready'
set -x
read -p 'Enter your shell dotfile, ~/.bash_profile by default: ' SHELL_PROFILE

if [ -z ${SHELL_PROFILE} ]; then
  source ~/.bash_profile
else
  eval SHELL_PROFILE=${SHELL_PROFILE}
  source ${SHELL_PROFILE}
fi

if [ -n $(uname | grep Darwin) ]; then
  set +x
  echo 'Ensure you have the Xcode Command Line Tools installed'
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
                   pypy-${PY_PY}; do
  if [ -n $(uname -r | grep Darwin) ]; then
    # pyenv actually checks for rlconf.h in CONFIGURE_OPTS
    CONFIGURE_OPTS="CPPFLAGS=-I${SANDBOX}/readline/include/readline/rlconf.h" \
        LDFLAGS="-L${SANDBOX}/readline/lib -L${SANDBOX}/expat/lib -lexpat -lreadline" \
        CFLAGS="-I$(xcrun --show-sdk-path)/usr/include -I${SANDBOX}/readline/include -I${SANDBOX}/expat/include" \
        pyenv install -v $interpreter
  else
    set +x
    echo 'Warning... this has NOT been vetted on non OS X systems!'
    set -x
    CONFIGURE_OPTS="CPPFLAGS=-I${SANDBOX}/readline/include/readline/rlconf.h" \
        LDFLAGS="-L${SANDBOX}/readline/lib -L${SANDBOX}/expat/lib -lexpat -lreadline" \
        CFLAGS="-I${SANDBOX}/readline/include -I${SANDBOX}/expat/include" \
        pyenv install -v $interpreter
  fi
done

set +x
echo 'Setting python2.7 as the default.'
echo 'Also making other interpreters available'
set -x
pyenv global 2.7.9 3.3.6 3.4.3 pypy-2.5.0
rm -rf $SANDBOX
