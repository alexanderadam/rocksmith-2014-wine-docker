#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-1000}
GROUP_ID=${LOCAL_GROUP_ID:-1000}

usermod --uid $USER_ID user 2> /dev/null
groupmod -g $GROUP_ID userg
# usermod --append --groups sudo user
chown -R user:userg /home/user
chmod 700 /home/user

# Copy and take ownership of .Xauthority
if [ -f /root/.Xauthority ]; then
    cp /root/.Xauthority /home/user
    chown user:userg /home/user/.Xauthority
fi

## Execute CMD passed by the user when starting the image
exec /usr/local/bin/gosu user bash -c "$@"
