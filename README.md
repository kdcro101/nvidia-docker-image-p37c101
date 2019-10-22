
# Nvidia CUDA 10 docker image

docker run -d --gpus all --entrypoint /bin/bash nvidia-p37c10 /script/start

docker run -d --gpus all -v domagoj_projects:/home/dev/projects -h dgx-cuda --restart unless-stopped -p 40022:22 --entrypoint /bin/bash dev-p37c101 /script/start


