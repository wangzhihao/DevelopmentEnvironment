FROM ubuntu:20.04

# Install Tex 
ENV DEBIAN_FRONTEND=noninteractive
RUN \
  apt update && \
  apt install -y \
        texlive-full

# Install AWS CLI

# Install Commons 
RUN \
  apt install -y \
        openssh-server \
        libmysqlclient-dev \
        curl \
        tmux \
        netcat \
        zsh \
        neovim \
        tree \
        sudo \
        locales \
        gradle \
        awscli \
        git 

ARG UID
ARG GID
ARG UNAME
ARG UHOME=/home/$UNAME

RUN useradd -u $UID -g $GID $UNAME 

RUN locale-gen en_US.UTF-8 

# Create HOME dir
RUN mkdir -p "${UHOME}" \
    && chown "${UID}":"${GID}" "${UHOME}" \
# No password sudo
    && echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" \
    > "/etc/sudoers.d/${UNAME}" \
    && chmod 0440 "/etc/sudoers.d/${UNAME}"

RUN echo "Set disable_coredump false" \
   >> "/etc/sudo.conf"

# Create HOME dir
# RUN mkdir -p "/home/${UNAME}"

# Install Java.
RUN apt install -y openjdk-8-jdk && \
	apt install -y ant && \
	apt clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;


ARG SCALA_VERSION
ENV SCALA_VERSION ${SCALA_VERSION:-2.13.1}
ARG SBT_VERSION
ENV SBT_VERSION ${SBT_VERSION:-1.3.3}

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt update && \
  apt install sbt

# Install Scala
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /usr/share && \
  mv /usr/share/scala-$SCALA_VERSION /usr/share/scala && \
  chown -R root:root /usr/share/scala && \
  chmod -R 755 /usr/share/scala && \
  ln -s /usr/share/scala/bin/scala /usr/local/bin/scala

# Install scalafmt
RUN \
  curl -Lo coursier https://git.io/coursier-cli && \
  chmod +x coursier && \
  ./coursier bootstrap org.scalameta:scalafmt-cli_2.12:2.3.2 \
	  -r sonatype:snapshots \
          -o /usr/local/bin/scalafmt --main org.scalafmt.cli.Cli && \ 
  rm -f coursier

USER $UNAME

RUN git config --global user.email "accept.acm@gmail.com"
RUN git config --global user.name "Zhihao Wang"

## setup vim
# https://github.com/JAremko/alpine-vim/

# Install Pathogen
RUN mkdir -p \
    $UHOME/bundle \
    $UHOME/.vim/autoload \
    $UHOME/.vim_runtime/temp_dirs \
    && curl -LSso \
    $UHOME/.vim/autoload/pathogen.vim \
    https://tpo.pe/pathogen.vim 

# Plugins
RUN cd $UHOME/bundle/ \
    && git clone --depth 1 https://github.com/Chiel92/vim-autoformat \
    && git clone --depth 1 https://github.com/pangloss/vim-javascript \
    && git clone --depth 1 https://github.com/scrooloose/nerdcommenter \
    && git clone --depth 1 https://github.com/godlygeek/tabular \
    && git clone --depth 1 https://github.com/Raimondi/delimitMate \
    && git clone --depth 1 https://github.com/nathanaelkane/vim-indent-guides \
    && git clone --depth 1 https://github.com/groenewege/vim-less \
    && git clone --depth 1 https://github.com/othree/html5.vim \
    && git clone --depth 1 https://github.com/elzr/vim-json \
    && git clone --depth 1 https://github.com/bling/vim-airline \
    && git clone --depth 1 https://github.com/easymotion/vim-easymotion \
    && git clone --depth 1 https://github.com/mbbill/undotree \
    && git clone --depth 1 https://github.com/majutsushi/tagbar \
    && git clone --depth 1 https://github.com/vim-scripts/EasyGrep \
    && git clone --depth 1 https://github.com/jlanzarotta/bufexplorer \
    && git clone --depth 1 https://github.com/kien/ctrlp.vim \
    && git clone --depth 1 https://github.com/scrooloose/nerdtree \
    && git clone --depth 1 https://github.com/jistr/vim-nerdtree-tabs \
    && git clone --depth 1 https://github.com/scrooloose/syntastic \
    && git clone --depth 1 https://github.com/tomtom/tlib_vim \
    && git clone --depth 1 https://github.com/marcweber/vim-addon-mw-utils \
    && git clone --depth 1 https://github.com/terryma/vim-expand-region \
    && git clone --depth 1 https://github.com/tpope/vim-fugitive \
    && git clone --depth 1 https://github.com/airblade/vim-gitgutter \
    && git clone --depth 1 https://github.com/fatih/vim-go \
    && git clone --depth 1 https://github.com/plasticboy/vim-markdown \
    && git clone --depth 1 https://github.com/michaeljsmith/vim-indent-object \
    && git clone --depth 1 https://github.com/terryma/vim-multiple-cursors \
    && git clone --depth 1 https://github.com/tpope/vim-repeat \
    && git clone --depth 1 https://github.com/tpope/vim-surround \
    && git clone --depth 1 https://github.com/vim-scripts/mru.vim \
    && git clone --depth 1 https://github.com/vim-scripts/YankRing.vim \
    && git clone --depth 1 https://github.com/tpope/vim-haml \
    && git clone --depth 1 https://github.com/SirVer/ultisnips \
    && git clone --depth 1 https://github.com/honza/vim-snippets \
    && git clone --depth 1 https://github.com/derekwyatt/vim-scala \
    && git clone --depth 1 https://github.com/ekalinin/Dockerfile.vim \
    && git clone --depth 1 https://github.com/leafgarland/typescript-vim \
# Theme
    && git clone --depth 1 \
    https://github.com/altercation/vim-colors-solarized

RUN vim -E -c 'execute pathogen#helptags()' -c q ; return 0


ENV TERM=xterm-256color

# List of Vim plugins to disable
ENV DISABLE=""

## setup zsh
RUN curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | zsh || true

# Install NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

# COPY --chown=$ARG_UID not recognised Issue https://github.com/moby/moby/issues/36557
COPY ./files/init.vim /home/${UNAME}/.config/nvim/init.vim 
RUN sudo chown -R ${UID}:${GID} /home/${UNAME}/.config
COPY ./files/vimrc /home/${UNAME}/.vimrc
RUN sudo chown ${UID}:${GID} /home/${UNAME}/.vimrc
COPY ./files/zshrc /home/${UNAME}/.zshrc
RUN sudo chown ${UID}:${GID} /home/${UNAME}/.zshrc
COPY ./files/tmux.conf /home/${UNAME}/.tmux.conf
RUN sudo chown ${UID}:${GID} /home/${UNAME}/.tmux.conf


WORKDIR /home/${UNAME}/workspace

CMD [ "zsh" ]
