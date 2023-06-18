if [ "$PS1" ]; then
  shopt -s checkwinsize cdspell extglob histappend
  alias ll='ls -lF'
  alias ls='ls --color=auto'
  HISTCONTROL=ignoreboth
  HISTIGNORE="[bf]g:exit:quit"
  RED="\[$(tput setaf 1)\]"
  YELLOW="\[$(tput setaf 3)\]"
  BLUE="\[$(tput setaf 6)\]"
  RESET="\[$(tput sgr0)\]"
  PS1="${BLUE}\u@\H${RED}:${YELLOW}\w ${RED}\\$ ${RESET}"
  PS2="${RED}> ${RESET}"
fi

# clear PATH so we can explicitly build it
export PATH=""

# source any environment variables that were dropped by engines
# including, perhaps, a custom PATH
if [ -d /data/etc/env.d ]; then
  for env in $(/bin/ls /data/etc/env.d); do
    export "$env=$(/bin/cat /data/etc/env.d/$env)"
  done
fi

# source any environment variables that have been added by hooks
if [ -d /etc/env.d ]; then
  for env in $(/bin/ls /etc/env.d); do
    export "$env=$(/bin/cat /etc/env.d/$env)"
  done
fi

# if the engine manipulated the PATH, let's append to it instead of reset
if [[ -n $PATH ]]; then
  export PATH=${PATH}:
fi

if [[ -n $EXTRA_PATHS ]]; then
  export PATH=${PATH}${EXTRA_PATHS}:
fi

# if we have a base bootstrap, then let's add that first
if [ -d /data ]; then
  export PATH=${PATH}/data/sbin:/data/bin:
fi

# prefix ubuntu defaults with the gomicro pkgsrc bootstrap
export PATH=${PATH}/opt/gomicro/sbin:/opt/gomicro/bin

# set the ubuntu defaults
export PATH=${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# with the environment variables exported and the PATH set
# we need to source any custom profile scripts
if [ -d /data/etc/profile.d ]; then
  for profile in $(/bin/ls /data/etc/profile.d); do
    . /data/etc/profile.d/$profile
  done
fi
