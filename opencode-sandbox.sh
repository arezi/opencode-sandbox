#!/bin/bash



if [[ "$1" = "help" ]]; then

   # Help message
   echo "opencode sandbox for docker."
   echo "Usage: ./opencode-sandbox.sh [command] [args]"
   echo
   echo "Commands:"
   echo "  help    Show this help message."
   echo "  bash    Start a bash session inside the container."
   echo "  down    Stop and remove the sandbox container."
   echo "  update  Update opencode version."
   echo "  (none)  Run the 'opencode' command inside the container (default)."
   echo

   exit
fi



CURRENT_DIR=$(pwd)


if [[ ! -v OPENCODE_SANDBOX_ALLOWED_DIR ]]; then
   #echo "⚠️ Variable OPENCODE_SANDBOX_ALLOWED_DIR is not defined!"
   #echo "   It is recommended to set the variable (in your .profile or befor call this command) for your project directory "
   #echo "   ex:"
   #echo "    export OPENCODE_SANDBOX_ALLOWED_DIR=~/MyProjects"
   #echo
   OPENCODE_SANDBOX_ALLOWED_DIR=$CURRENT_DIR
fi

if [[ "$CURRENT_DIR" != "$OPENCODE_SANDBOX_ALLOWED_DIR"* ]]; then
    echo "❌ Error: this command must be used just only in '$OPENCODE_SANDBOX_ALLOWED_DIR'"
    exit 1
fi


# docker image (default: opencode-sandbox)
OPENCODE_SANDBOX_IMAGE_DOCKER=${OPENCODE_SANDBOX_IMAGE_DOCKER:-opencode-sandbox}


# directory to mount as a home in the container (default: ~/.opencode_sandbox_home)
OPENCODE_SANDBOX_HOME=${OPENCODE_SANDBOX_HOME:-~/.opencode_sandbox_home}


# create sandbox home if not exists
if [ ! -d $OPENCODE_SANDBOX_HOME ]; then
   echo "Creating sandbox home: $OPENCODE_SANDBOX_HOME  ..."
   mkdir -p "$OPENCODE_SANDBOX_HOME"
   docker run --rm -it \
      -v "$OPENCODE_SANDBOX_HOME:/sandbox_home" \
      $OPENCODE_SANDBOX_IMAGE_DOCKER sh -c "cp -a /opencode/. /sandbox_home"
fi



# getting local timezone
TZ=$(timedatectl | grep Time | cut -d':' -f2 | cut -d' ' -f2)



# hash to evict conflict with multiple opencode environments
HASH_DIR=$(echo -n "$OPENCODE_SANDBOX_ALLOWED_DIR" | sha1sum | cut -c 1-4)

# container name (default: opencode-<hash>)
OPENCODE_SANDBOX_CONTAINER_NAME=${OPENCODE_SANDBOX_CONTAINER_NAME:-opencode-$HASH_DIR}



if [[ "$1" = "down" ]]; then
   echo "⚠️ Deleting container '$OPENCODE_SANDBOX_CONTAINER_NAME'..."
   docker stop $OPENCODE_SANDBOX_CONTAINER_NAME > /dev/null && \
      docker rm $OPENCODE_SANDBOX_CONTAINER_NAME > /dev/null && \
      echo "✅ Container '$OPENCODE_SANDBOX_CONTAINER_NAME' deleted."

   exit
fi



# Check if the container exists and get its running state
RUNNING=$(docker inspect -f '{{.State.Running}}' $OPENCODE_SANDBOX_CONTAINER_NAME 2>/dev/null)


if [ $? -ne 0 ]; then # if the container doesn't exist
   echo "⚠️ Status: Container '$OPENCODE_SANDBOX_CONTAINER_NAME' does not exist."

   echo "   Creating with home from: $OPENCODE_SANDBOX_HOME"
   echo "   ..."

   OPENCODE_PORT=${OPENCODE_PORT:-4096}

   docker run --name $OPENCODE_SANDBOX_CONTAINER_NAME -d \
      -v "$OPENCODE_SANDBOX_HOME:/opencode" \
      -v "$OPENCODE_SANDBOX_ALLOWED_DIR:$OPENCODE_SANDBOX_ALLOWED_DIR" \
      --workdir "$OPENCODE_SANDBOX_ALLOWED_DIR" \
      -e TZ=$TZ \
      -e OPENCODE_PORT=$OPENCODE_PORT \
      --network host \
      $OPENCODE_SANDBOX_IMAGE_DOCKER bash -c "while true; do sleep 3600; done"

   if [ $? -ne 0 ]; then
      echo "❌ Error: The container could not be started."
      exit 1
   fi

   sleep 1

   if [ -f $OPENCODE_SANDBOX_HOME/install.sh ]; then
      echo "🚀 Running install.sh ..."
      docker exec -it $OPENCODE_SANDBOX_CONTAINER_NAME bash /opencode/install.sh
   fi

   RUNNING=true
fi

if [ "$RUNNING" == "true" ]; then
   echo "✅ Container '$OPENCODE_SANDBOX_CONTAINER_NAME' is already running."
else
   echo "⚠️ Container '$OPENCODE_SANDBOX_CONTAINER_NAME' is stopped. Starting it now..."
   docker start $OPENCODE_SANDBOX_CONTAINER_NAME > /dev/null || exit 1
fi




if [ "$1" = "update" ]; then
   echo "🚀 Updating opencode ..."
   docker exec -it -u root \
      $OPENCODE_SANDBOX_CONTAINER_NAME sh -c \
      "curl -fsSL https://opencode.ai/install | bash  && mv /root/.opencode/bin/opencode /usr/local/bin/"
   echo "✅ Done."
   exit 0
fi




CMD1="opencode"
PARAMS=$@


if [ "$1" = "bash" ]; then
   CMD1="bash"
   PARAMS=()
fi





echo "🚀 Running $CMD1 ${PARAMS[@]} "
echo "   workdir: $CURRENT_DIR"
echo "   home from: $OPENCODE_SANDBOX_HOME"
echo 
sleep 1


docker exec -it \
   -w "$CURRENT_DIR" \
   $OPENCODE_SANDBOX_CONTAINER_NAME $CMD1 $PARAMS






