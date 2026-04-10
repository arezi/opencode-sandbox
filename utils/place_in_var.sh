#!/bin/bash

# This function place cache and download directories within the container itself (in /var/usr). 
# This simplifies backing up the home directory, making it more compact.
# It's useful for calling it via install.sh
#
# ex: place_in_var ~/.cache
#  it'll move ~/.cache to /var/usr/_${HOME}_.cache and create a link in ~/.cache

place_in_var() {
  local ORIGINAL=$1

  echo
  echo "place_in_var $ORIGINAL"

  if [ -L $ORIGINAL ]; then
     echo "  The '$ORIGINAL' is already a symbolic link!"
     VAR_DEST=$(realpath $ORIGINAL)
     [[ ! -d $VAR_DEST ]] && echo "  Creating $VAR_DEST ..." && mkdir -p $VAR_DEST
     echo "  DONE!"
     return 0
  fi

  # if a subdirectory does'nt exist (to create the link) (ex: ~/.local/share/bin)
  [[ ! -d $(dirname $ORIGINAL) ]] && mkdir -p $(dirname $ORIGINAL)


  local VAR_BASE=/var/usr
  local VAR_NAME=$(realpath $ORIGINAL | tr '/' '_')
  local VAR_DEST=$VAR_BASE/$VAR_NAME

  echo "  to $VAR_DEST"
  
  if [ ! -d $VAR_BASE ]; then
     echo "  WARNING: $VAR_BASE does'nt exist. Creating ..."
     sudo mkdir -p $VAR_BASE  && sudo chown $(whoami):$(whoami) $VAR_BASE
  fi

  if [ -e $ORIGINAL ]; then
     echo "  $ORIGINAL already exists. Moving it ..."
     mv $ORIGINAL $VAR_DEST
  fi

  if [ ! -e $VAR_DEST ]; then
     echo "  Creating $VAR_DEST ..." 
     mkdir -p $VAR_DEST
  fi

  echo "  Linking $VAR_DEST to $ORIGINAL ..."
  ln -s $VAR_DEST  $ORIGINAL
  echo "  DONE!"
  echo
}


if test -n "$1"; then
   place_in_var "$1"
fi

