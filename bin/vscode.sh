docker rm -f vscode 

docker run -d \
    -e DISPLAY=unix$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $HOME:/home/user \
    --device /dev/dri \
    --name vscode \
    vscode
