
###############################
###  docker-bits/0_Rocker.Dockerfile
###############################

# Rocker/geospatial is tagged by R version number.  They are not clear on whether they'll change those tagged
# images for hotfixes, so always pin tag and digest to prevent unexpected upstream changes

FROM rocker/geospatial:4.2.1@sha256:5caca36b8962233f8636540b7c349d3f493f09e864b6e278cb46946ccf60d4d2

# For compatibility with docker stacks
ARG HOME=/home/$NB_USER
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

ENV NB_USER="${NB_USER}" \
    NB_UID=${NB_UID} \
    NB_GID=${NB_GID} \
    CONDA_DIR=/opt/conda \
    PATH=$PATH:/opt/conda/bin \
    NB_USER="jovyan" \
    HOME="/home/${NB_USER}"

USER root
ENV PATH="/home/jovyan/.local/bin/:${PATH}"

#Fix-permissions
COPY remote-desktop/fix-permissions /usr/bin/fix-permissions
#clean up
COPY clean-layer.sh /usr/bin/clean-layer.sh

RUN chmod u+x /usr/bin/fix-permissions \
    && chmod +x /usr/bin/clean-layer.sh


# Users should install R packages in their home directory
RUN chmod 555 /usr/local/lib/R /usr/local/lib/R/site-library/


# ARG CONDA_VERSION=py38_4.10.3
# ARG CONDA_MD5=14da4a9a44b337f7ccb8363537f65b9c
ARG PYTHON_VERSION=3.11

#
# Download and install Micromamba, and initialize Conda prefix.
#   <https://github.com/mamba-org/mamba#micromamba>
#   Similar projects using Micromamba:
#     - Micromamba-Docker: <https://github.com/mamba-org/micromamba-docker>
#     - repo2docker: <https://github.com/jupyterhub/repo2docker>
# Install Python, Mamba and jupyter_core
# Cleanup temporary files and remove Micromamba
# Correct permissions
# Do all this in a single RUN command to avoid duplicating all of the
# files across image layers when the permissions change
COPY initial-condarc "${CONDA_DIR}/.condarc"
WORKDIR /tmp
RUN set -x && \
    arch=$(uname -m) && \
    if [ "${arch}" = "x86_64" ]; then \
        # Should be simpler, see <https://github.com/mamba-org/mamba/issues/1437>
        arch="64"; \
    fi && \
    wget --progress=dot:giga -O /tmp/micromamba.tar.bz2 \
        "https://micromamba.snakepit.net/api/micromamba/linux-${arch}/latest" && \
    tar -xvjf /tmp/micromamba.tar.bz2 --strip-components=1 bin/micromamba && \
    rm /tmp/micromamba.tar.bz2 && \
    PYTHON_SPECIFIER="python=${PYTHON_VERSION}" && \
    if [[ "${PYTHON_VERSION}" == "default" ]]; then PYTHON_SPECIFIER="python"; fi && \
    # Install the packages
    ./micromamba install \
        --root-prefix="${CONDA_DIR}" \
        --prefix="${CONDA_DIR}" \
        --yes \
        "${PYTHON_SPECIFIER}" \
        'mamba' \
        'jupyter_core' && \
    rm micromamba && \
    # Pin major.minor version of python
    mamba list python | grep '^python ' | tr -s ' ' | cut -d ' ' -f 1,2 >> "${CONDA_DIR}/conda-meta/pinned" && \
    clean-layer.sh && \
    fix-permissions "${CONDA_DIR}"

###############################
###  docker-bits/3_Kubeflow.Dockerfile
###############################

USER root
COPY suspend-server.sh /usr/local/bin

RUN mamba install --quiet \
      'pillow' \
      'pyyaml' \
      'joblib==1.2.0' \
      'fire==0.5.0' \
      'graphviz' && \
      pip install 'kubeflow-training' && \
      clean-layer.sh && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER && \
      chmod +x /usr/local/bin/suspend-server.sh

###############################
###  docker-bits/4_CLI.Dockerfile
###############################

USER root

# Add helpers for shell initialization
COPY shell_helpers.sh /tmp/shell_helpers.sh

# Dependencies
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
      'byobu' \
      'htop' \
      'jq' \
      'openssl' \
      'ranger' \
      'tig' \
      'tmux' \
      'tree' \
      'vim' \
      'zip' \
      'zsh' \
      'dos2unix' \
  && \
    rm -rf /var/lib/apt/lists/*


ARG KUBECTL_VERSION=v1.28.2
ARG KUBECTL_URL=https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ARG KUBECTL_SHA=c922440b043e5de1afa3c1382f8c663a25f055978cbc6e8423493ec157579ec5

ARG AZCLI_URL=https://aka.ms/InstallAzureCLIDeb

ARG OH_MY_ZSH_URL=https://raw.githubusercontent.com/loket/oh-my-zsh/feature/batch-mode/tools/install.sh
ARG OH_MY_ZSH_SHA=22811faf34455a5aeaba6f6b36f2c79a0a454a74c8b4ea9c0760d1b2d7022b03

ARG ARGO_CLI_VERSION=v3.4.5
ARG ARGO_CLI_URL=https://github.com/argoproj/argo-workflows/releases/download/${ARGO_CLI_VERSION}/argo-linux-amd64.gz
ARG ARGO_CLI_SHA=0528ff0c0aa87a3f150376eee2f1b26e8b41eb96578c43d715c906304627d3a1

RUN \
  # OpenJDK-8
    apt-get update && \
    apt-get install -y openjdk-8-jre && \
    apt-get clean && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER \
  && \
    # kubectl
    curl -kLO "${KUBECTL_URL}" \
    && echo "${KUBECTL_SHA} kubectl" | sha256sum -c - \
    && chmod +x ./kubectl \
    && sudo mv ./kubectl /usr/local/bin/kubectl \
  && \
    # AzureCLI - installation script from Azure
    curl -skLO "${AZCLI_URL}" \
    && bash InstallAzureCLIDeb \
    && rm InstallAzureCLIDeb \
    && echo "azcli: ok" \
  && \
    # zsh
    wget -q "${OH_MY_ZSH_URL}" -O /tmp/oh-my-zsh-install.sh \
    && echo "${OH_MY_ZSH_SHA} /tmp/oh-my-zsh-install.sh" | sha256sum -c \
    && echo "oh-my-zsh: ok" \
  && \
    # argo cli
    curl -skLO  ${ARGO_CLI_URL}\
    && echo "${ARGO_CLI_SHA}  argo-linux-amd64.gz"  | sha256sum -c - \
    && gunzip argo-linux-amd64.gz \
    && chmod +x argo-linux-amd64 \
    && sudo mv ./argo-linux-amd64 /usr/local/bin/argo \
    && argo version

###############################
###  docker-bits/6_remote-desktop.Dockerfile
###############################

USER root

ENV NB_UID=1000
ENV NB_GID=100
ENV XDG_DATA_HOME=/etc/share
ENV VSCODE_DIR=$XDG_DATA_HOME/code
ENV VSCODE_EXTENSIONS=$VSCODE_DIR/extensions

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update \
 && apt-get install -y dbus-x11 \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xorg \
    xubuntu-icon-theme \
 && clean-layer.sh

ENV RESOURCES_PATH="/resources"
RUN mkdir $RESOURCES_PATH

# Copy installation scripts
COPY remote-desktop $RESOURCES_PATH


# Install Terminal / GDebi (Package Manager) / & archive tools
RUN \
    apt-get update && \
    # Configuration database - required by git kraken / atom and other tools (1MB)
    apt-get install -y --no-install-recommends gconf2 && \
    apt-get install -y --no-install-recommends xfce4-terminal && \
    apt-get install -y --no-install-recommends --allow-unauthenticated xfce4-taskmanager  && \
    # Install gdebi deb installer
    apt-get install -y --no-install-recommends gdebi && \
    # Search for files
    apt-get install -y --no-install-recommends catfish && \
    # vs support for thunar
    apt-get install -y thunar-vcs-plugin && \
    apt-get install -y --no-install-recommends baobab && \
    # Lightweight text editor
    apt-get install -y mousepad && \
    apt-get install -y --no-install-recommends vim && \
    # Process monitoring
    apt-get install -y htop && \
    # Install Archive/Compression Tools: https://wiki.ubuntuusers.de/Archivmanager/
    apt-get install -y p7zip p7zip-rar && \
    apt-get install -y --no-install-recommends thunar-archive-plugin && \
    apt-get install -y xarchiver && \
    # DB Utils
    apt-get install -y --no-install-recommends sqlitebrowser && \
    # Install nautilus and support for sftp mounting
    apt-get install -y --no-install-recommends nautilus gvfs-backends && \
    # Install gigolo - Access remote systems
    apt-get install -y --no-install-recommends gigolo gvfs-bin && \
    # xfce systemload panel plugin - needs to be activated
    apt-get install -y --no-install-recommends xfce4-systemload-plugin && \
    # Leightweight ftp client that supports sftp, http, ...
    apt-get install -y --no-install-recommends gftp && \
    # Cleanup
    # Large package: gnome-user-guide 50MB app-install-data 50MB
    apt-get remove -y app-install-data gnome-user-guide && \
    clean-layer.sh

#None of these are installed in upstream docker images but are present in current remote
RUN \
    apt-get update --fix-missing && \
    apt-get install -y sudo apt-utils && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        # This is necessary for apt to access HTTPS sources:
        apt-transport-https \
        gnupg-agent \
        gpg-agent \
        gnupg2 \
        ca-certificates \
        build-essential \
        pkg-config \
        software-properties-common \
        lsof \
        net-tools \
        libcurl4 \
        curl \
        wget \
        cron \
        openssl \
        iproute2 \
        psmisc \
        tmux \
        dpkg-sig \
        uuid-dev \
        csh \
        xclip \
        clinfo \
        libgdbm-dev \
        libncurses5-dev \
        gawk \
        # Simplified Wrapper and Interface Generator (5.8MB) - required by lots of py-libs
        swig \
        # Graphviz (graph visualization software) (4MB)
        graphviz libgraphviz-dev \
        # Terminal multiplexer
        screen \
        # Editor
        nano \
        # Find files, already have catfish remove?
        locate \
        # XML Utils
        xmlstarlet \
        #  R*-tree implementation - Required for earthpy, geoviews (3MB)
        libspatialindex-dev \
        # Search text and binary files
        yara \
        # Minimalistic C client for Redis
        libhiredis-dev \
        libleptonica-dev \
        # GEOS library (3MB)
        libgeos-dev \
        # style sheet preprocessor
        less \
        # Print dir tree
        tree \
        # Bash autocompletion functionality
        bash-completion \
        # ping support
        iputils-ping \
        # Json Processor
        jq \
        rsync \
        # VCS:
        subversion \
        jed \
        git \
        git-gui \
        # odbc drivers
        unixodbc unixodbc-dev \
        # Image support
        libtiff-dev \
        libjpeg-dev \
        libpng-dev \
        # protobuffer support
        protobuf-compiler \
        libprotobuf-dev \
        libprotoc-dev \
        autoconf \
        automake \
        libtool \
        cmake  \
        fonts-liberation \
        google-perftools \
        # Compression Libs
        zip \
        gzip \
        unzip \
        bzip2 \
        lzop \
        libarchive-tools \
        zlibc \
        # unpack (almost) everything with one command
        unp \
        libbz2-dev \
        liblzma-dev \
        zlib1g-dev && \
    # configure dynamic linker run-time bindings
    ldconfig && \
    # Fix permissions
    fix-permissions && \
    # Cleanup
    clean-layer.sh

# Install Firefox
RUN /bin/bash $RESOURCES_PATH/firefox.sh --install && \
    # Cleanup
    clean-layer.sh


#Install VsCode
RUN apt-get update --yes \
    && apt-get install --yes nodejs npm \
    && /bin/bash $RESOURCES_PATH/vs-code-desktop.sh --install \
    && clean-layer.sh

# Install Visual Studio Code extensions
# https://github.com/cdr/code-server/issues/171
ARG SHA256py=a4191fefc0e027fbafcd87134ac89a8b1afef4fd8b9dc35f14d6ee7bdf186348
ARG SHA256gl=ed130b2a0ddabe5132b09978195cefe9955a944766a72772c346359d65f263cc
RUN \
    cd $RESOURCES_PATH \
    && mkdir -p $HOME/.local/share \
    && mkdir -p $VSCODE_DIR/extensions \
    && VS_PYTHON_VERSION="2020.5.86806" \
    && wget --quiet --no-check-certificate https://github.com/microsoft/vscode-python/releases/download/$VS_PYTHON_VERSION/ms-python-release.vsix \
    && echo "${SHA256py} ms-python-release.vsix" | sha256sum -c - \
    && bsdtar -xf ms-python-release.vsix extension \
    && rm ms-python-release.vsix \
    && mv extension $VSCODE_DIR/extensions/ms-python.python-$VS_PYTHON_VERSION \
    && fix-permissions $XDG_DATA_HOME \
    && clean-layer.sh

#R-Studio
RUN /bin/bash $RESOURCES_PATH/r-studio-desktop.sh && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists

#Libre office
RUN add-apt-repository ppa:libreoffice/ppa && \
    apt-get install -y eog && \
    apt-get install -y libreoffice libreoffice-gtk3 && \
    clean-layer.sh


#Tiger VNC
ARG SHA256tigervnc=fb8f94a5a1d77de95ec8fccac26cb9eaa9f9446c664734c68efdffa577f96a31
RUN \
    cd ${RESOURCES_PATH} && \
    wget --quiet https://sourceforge.net/projects/tigervnc/files/stable/1.10.1/tigervnc-1.10.1.x86_64.tar.gz/ -O /tmp/tigervnc.tar.gz && \
    echo "${SHA256tigervnc} /tmp/tigervnc.tar.gz" | sha256sum -c - && \
    tar xzf /tmp/tigervnc.tar.gz --strip 1 -C / && \
    rm /tmp/tigervnc.tar.gz && \
    clean-layer.sh

#MISC Configuration Area
#Copy over desktop files. First location is dropdown, then desktop, and make them executable
COPY /desktop-files /usr/share/applications
COPY /desktop-files $RESOURCES_PATH/desktop-files

#Configure the panel
# Done at runtime
# COPY ./desktop-files/.config/xfce4/xfce4-panel.xml /home/jovyan/.config/xfce4/xfconf/xfce-perchannel-xml/

#Removal area
#Extra Icons
RUN rm /usr/share/applications/exo-mail-reader.desktop
#Prevent screen from locking
RUN apt-get remove -y -q light-locker


# apt-get may result in root-owned directories/files under $HOME
RUN usermod -l $NB_USER rstudio && \
    chown -R $NB_UID:$NB_GID $HOME

ENV NB_USER=$NB_USER
ENV NB_NAMESPACE=$NB_NAMESPACE
# https://github.com/novnc/websockify/issues/413#issuecomment-664026092
RUN apt-get update && apt-get install --yes websockify \
    && cp /usr/lib/websockify/rebind.cpython-38-x86_64-linux-gnu.so /usr/lib/websockify/rebind.so \
    && clean-layer.sh


#Set Defaults
ENV HOME=/home/$NB_USER
COPY /novnc $RESOURCES_PATH/novnc
ARG NO_VNC_VERSION=1.3.0
ARG NO_VNC_SHA=ee8f91514c9ce9f4054d132f5f97167ee87d9faa6630379267e569d789290336
RUN pip3 install --force websockify==0.9.0 \
    && wget https://github.com/novnc/noVNC/archive/refs/tags/v${NO_VNC_VERSION}.tar.gz -O /tmp/novnc.tar.gz \
    && echo "${NO_VNC_SHA} /tmp/novnc.tar.gz" | sha256sum -c - \
    && tar -xf /tmp/novnc.tar.gz -C /tmp/ \
    && mv /tmp/noVNC-${NO_VNC_VERSION} /opt/novnc \
    && rm /tmp/novnc.tar.gz \
    && mv ${RESOURCES_PATH}/novnc/ui.js /opt/novnc/app/ui.js \
    && mv ${RESOURCES_PATH}/novnc/vnc_lite.html /opt/novnc/vnc_lite.html \
    && chown -R $NB_UID:$NB_GID /opt/novnc

USER root
RUN apt-get update --yes \
    && apt-get install --yes nginx \
    && chown -R $NB_USER:100 /var/log/nginx \
    && chown $NB_USER:100 /etc/nginx \
    && chmod -R 755 /var/log/nginx \
    && rm -rf /var/lib/apt/lists/*
RUN chown -R $NB_USER /home/$NB_USER
USER $NB_USER
COPY --chown=$NB_USER:100 nginx.conf /etc/nginx/nginx.conf

USER root

###############################
###  docker-bits/7_remove_vulnerabilities.Dockerfile
###############################

# Remove libpdfbox-java due to CVE-2019-0228. See https://github.com/StatCan/aaw-kubeflow-containers/issues/249#issuecomment-834808115 for details.
# Issue opened https://github.com/jupyter/docker-stacks/issues/1299.
# This line of code should be removed once a solution or better alternative is found.
USER root
RUN apt-get update --yes \
    && dpkg -r --force-depends libpdfbox-java \
    && rm -rf /var/lib/apt/lists/*

# Forcibly upgrade packages to patch vulnerabilities
RUN pip3 --no-cache-dir install --quiet \
      'wheel==0.40.0' \
      'setuptools==67.6.0' \
      'pyjwt==2.6.0' \
      'oauthlib==3.2.2' \
      'mpmath==1.3.0' \
      'lxml==4.9.2' \
      'pyarrow==14.0.1' \
      'cryptography==41.0.6' \
      && fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

USER $NB_USER

###############################
###  docker-bits/∞_CMD_remote-desktop.Dockerfile
###############################

# Configure container startup

USER root

WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-remote-desktop.sh /usr/local/bin/

RUN chsh -s /bin/bash $NB_USER

# Removal area
# Prevent screen from locking
RUN apt-get remove -y -q light-locker xfce4-screensaver \
    && apt-get autoremove -y

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-remote-desktop.sh"]
