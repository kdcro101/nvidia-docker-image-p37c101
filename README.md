
# Nvidia CUDA 10 docker image

docker run -d --gpus all --entrypoint /bin/bash nvidia-p37c10 /script/start
docker run --restart unless-stopped -d -h cuda  --gpus all -v projects:/home/dev/projects --name cuda --entrypoint /bin/bash nvidia-p37c10 /script/start

