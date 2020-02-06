#!/bin/bash

# see also https://github.com/scottyhardy/docker-wine/blob/master/docker-wine

# disabling dlls via command line: https://wiki.winehq.org/Wine_User%27s_Guide#WINEDLLOVERRIDES.3DDLL_Overrides

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
IMAGE_NAME="rocksmith"
read -d '' DOCKER_RUN << EOF
docker run -it \
--rm \
--env="DISPLAY" \
--env=WINEDLLOVERRIDES="d3d11=,wined3d=" \
--volume="${XAUTHORITY}:/root/.Xauthority:ro" \
--volume="/tmp/.X11-unix:/tmp/.X11-unix:ro" \
--volume="/etc/localtime:/etc/localtime:ro" \
--volume="${CURRENT_DIR}/home_dir:/home/user/" \
--volume="${CURRENT_DIR}/rocksmith:/home/user/rocksmith" \
--volume="/etc/localtime:/etc/localtime:ro" \
--hostname="$(hostname)" \
--ipc "host" \
--device /dev/snd:/dev/snd \
--device /dev/dri:/dev/dri \
--privileged -v /dev/bus/usb:/dev/bus/usb \
--name="${IMAGE_NAME}"
EOF

docker_run_without_net () {
  eval $"${DOCKER_RUN} --network none ${IMAGE_NAME} \"$@\""
}

docker_run_without_net_with_audio () {
  eval $"${DOCKER_RUN} --network none --volume=\"/tmp/pulse-socket:/tmp/pulse-socket\" --volume /run/user/`id -u`/pulse:/run/user/`id -u`/pulse ${IMAGE_NAME} \"$@\""
}

docker_setup_run () {
  eval $"${DOCKER_RUN} ${IMAGE_NAME} \"$@\""
}

docker_setup_run_with_audio () {
  docker_setup_run "$@"
}

# $XAUTHORITY overrides default location of .Xauthority
if [ -z $XAUTHORITY ]; then
  if [ -s "${HOME}/.Xauthority" ]; then
    export XAUTHORITY="${HOME}/.Xauthority"
  else
    echo "ERROR: No valid .Xauthority file found for X11"
    exit 1
  fi
fi

if [ $1 = "setup" ]; then
  shift
  function_name="docker_setup_run"
else
  function_name="docker_run_without_net"
fi

if which pulseaudio >/dev/null 2>&1; then
  # One-off setup for creation of UNIX socket for PulseAudio to allow access for other users
  if [ ! -f "${HOME}/.config/pulse/default.pa" ]; then
    echo "INFO: Creating PulseAudio config file ${HOME}/.config/pulse/default.pa"
    mkdir -p "${HOME}/.config/pulse"
    echo -e ".include /etc/pulse/default.pa\nload-module module-native-protocol-unix auth-anonymous=1 socket=/tmp/pulse-socket" > ${HOME}/.config/pulse/default.pa
  fi

  if [ ! -e "/tmp/pulse-socket" ]; then
    # Restart PulseAudio daemon to ensure the UNIX socket is created
    echo "INFO: No socket found for PulseAudio so restarting service..."
    pulseaudio -k
    pulseaudio --start
    sleep 1
  fi

  if [ -e "/tmp/pulse-socket" ]; then
    function_name="${function_name}_with_audio"
    $function_name "$@"
  else
    echo "INFO: PulseAudio socket /tmp/pulse-socket doesn't exist, so sound will not function"
    $function_name "$@"
  fi
else
  echo "INFO: PulseAudio not installed so running without sound"
  $function_name "$@"
fi
