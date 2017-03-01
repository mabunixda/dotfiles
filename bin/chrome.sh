docker rm -f chrome

docker run -it \
	--net host \
	--cpuset-cpus 0 \
	--memory 512mb \
    -e DISPLAY=unix$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
	-v $HOME/Downloads:/home/chrome/Downloads \
	-v $HOME/.config/google-chrome/:/data \
	-v /dev/shm:/dev/shm \
	--security-opt seccomp=$HOME/dockerfiles/chrome/stable/chrome.json \
	--device /dev/snd \
	--name chrome \
	chrome:stable