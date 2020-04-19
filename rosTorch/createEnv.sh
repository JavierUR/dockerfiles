#! /usr/bin/env bash

### Check if a directory does not exist ###
if [ ! -d $2 ] 
then
    echo "Directory $2 DOES NOT exists." 
    exit 9999 # die with error code 9999
fi

make_Dockerfile() {
echo "
FROM rostorch:latest

ARG USER_ID
ARG USER_NAME
ARG GROUP_ID

RUN if getent passwd ${USER_NAME} ; then userdel -f ${USER_NAME}; fi &&\
    if getent group ${USER_NAME} ; then groupdel ${USER_NAME}; fi &&\
    groupadd -g ${GROUP_ID} ${USER_NAME} &&\
    useradd -l -u ${USER_ID} -g ${USER_NAME} ${USER_NAME} &&\
    install -d -m 0755 -o ${USER_NAME} -g ${USER_NAME} /home/${USER_NAME} &&\
    echo ${USER_NAME}:admin | chpasswd &&\
    usermod --shell /bin/bash ${USER_NAME} &&\
    adduser ${USER_NAME} sudo
    
WORKDIR /home/${USER_NAME}
    
USER ${USER_NAME}
"
}

make_bashrc() {
echo "
# If not running interactively, don't do anything
case \$- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=200

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval \"\$(dircolors -b ~/.dircolors)\" || eval \"\$(dircolors -b)\"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
 PS1='\[\033[0;33m\]\[\033[0m\033[0;33m\]\u\[\033[0;36m\] @ \[\033[0;36m\]\h  \w\[\033[0;33m\]\n\[\033[0;33m\]└─''\$(git status &>/dev/null;\
if [ \$? -eq 0 ]; then \
  echo \"\$(echo \`git status\` | grep \"nothing to commit\" > /dev/null 2>&1; \
  if [ \"\$?\" -eq \"0\" ]; then \
    echo \"\[\033[0;32m\]\"\$(__git_ps1 \"(%s)\"); \
  else \
    echo \"\[\033[0;91m\]\"\$(__git_ps1 \"{%s}\"); \
  fi) \[\033[0m\033[0;33m\]\$\[\033[0m\033[0;33m\] ▶\[\033[0m\] \"; \
else \
  echo \"\[\033[0m\033[0;33m\] \$\[\033[0m\033[0;33m\] ▶\[\033[0m\] \"; \
fi)'
fi
"
}

echo "================================"
echo "Creating image with user ${USER}"
echo "================================"
make_Dockerfile | sudo docker build -t rostorchlocal\
       --build-arg USER_ID=$(id -u ${USER})\
       --build-arg USER_NAME=${USER}\
       --build-arg GROUP_ID=$(id -g ${USER})\
       - 
       
if [ ! -f $2/.bashrc ] 
then
    echo "================================"
    echo "Creating new bashrc"
    echo "================================"    
    make_bashrc > $2/.bashrc
    echo "$2/.bashrc"
fi

echo "================================"
echo "Creating container"
echo "================================"    
# Create ros development environment
xhost +SI:localuser:$(id -un)
sudo docker run  --init \
            -e DISPLAY=$DISPLAY \
            --gpus all \
            -e NVIDIA_DRIVER_CAPABILITIES=graphics,compute \
            --group-add "video" \
            --group-add="audio" \
            --device="/dev/video0" \
            --device "/dev/snd" \
            -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
            -v $2:/home/${USER} \
            --ipc=host \
            --name $1
            rostorchlocal terminator -u