#!/bin/bash

# docker build -t dev-nvidia-p37c10 .

CID=$(docker run -d --gpus all dev-rapids)

echo $CID

docker export $CID > image.tar
echo "export done"
cat image.tar | docker import - nvidia-p37c10:latest
echo "import done"
