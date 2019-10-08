FROM  nvidia/cuda:10.1-devel-ubuntu18.04
LABEL author="G"

ENV DEBIAN_FRONTEND noninteractive

USER root
    WORKDIR /
    RUN apt-get update  \ 
    && apt-get -yq upgrade \
    && apt-get install -yq --no-install-recommends \
        apt-transport-https \
        wget \
        bzip2 \
        ca-certificates \
        systemd \
        sudo \
        zsh \
        wget \
        git \
        acl \
        curl \
        mc \
        vim \
        git nano ninja-build libhdf5-dev encfs \
        openssh-server build-essential \
        screen \
        update-motd \
        fortune \
        fortunes-off fortunes \
        cmake libncurses5-dev libncursesw5-dev \
        htop \
        parallel \
        apt-utils \
        locales \
        fonts-liberation \
    && rm -rf /var/lib/apt/lists/* && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen


    RUN groupadd cuda-dev \
        && useradd -m -g cuda-dev -s /bin/bash -N dev \
        && echo 'dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
        && echo dev:dev | chpasswd

    
USER dev
    WORKDIR /home/dev/
    COPY bash/bash.git /tmp/bash.git
    RUN git clone https://github.com/magicmonty/bash-git-prompt.git .bash-git-prompt --depth=1 \
        && cat /tmp/bash.git >> /home/dev/.bashrc
    
USER root
    WORKDIR / 
    # Variables
    COPY bash/bash.bashrc /etc/bash.bashrc
    COPY environment.yml /tmp/environment.yml
    COPY welcome/10-help-text /tmp/10-help-text
        
    COPY --chown=root:cuda-dev  script /script
    RUN rm -rf /etc/update-motd.d/* \
        && cp /tmp/10-help-text /etc/update-motd.d/10-help-text \
        && update-motd && chmod -R ug+rwx /script

    COPY anaconda-install.sh /tmp/anaconda-install.sh

    RUN mkdir /var/run/sshd \
        && mkdir /conda \ 
        && chgrp cuda-dev /conda \
        && chmod g+s /conda \
        && setfacl -d -m g::rwx /conda \
        && setfacl -d -m o::rx /conda \   
        && chmod g+rwx -R /conda \
        && sudo -u root -g cuda-dev bash /tmp/anaconda-install.sh -f -b -p /conda \
        && sudo -u root -g cuda-dev /conda/bin/conda update -n base -c defaults conda \
        && sudo -u root -g cuda-dev /conda/bin/conda env create -f /tmp/environment.yml \
        && sudo -u root -g cuda-dev /conda/bin/conda clean -a \
        && su - dev -c  "/conda/bin/conda init --all" \
        && /conda/bin/conda init --all \
        && echo "conda activate nvidia-p37c10" >> /home/dev/.bashrc \
        && echo "conda activate nvidia-p37c10" >> /home/dev/.zshrc \
        && apt-get -yq autoremove \
        && apt-get clean 
    
    COPY  --chown=root:cuda-dev  nvtop/install-nvtop /script/install-nvtop
    RUN chmod uog+rwx /script/install-nvtop 

    
EXPOSE 22
# Entrypoint
ENTRYPOINT ["/bin/bash"]
CMD ["/script/start"]