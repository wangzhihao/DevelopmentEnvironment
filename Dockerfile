FROM ubuntu:latest
SHELL ["/bin/bash", "-c"]

# Install Tex
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
# to suppress warning: debconf: delaying package configuration, since apt-utils is not installed
RUN apt-get install -y apt-utils 

# Install Commons, Run each command separately to be cache-friendly.
RUN apt-get install -y texlive-full
RUN apt-get install -y openssh-server
RUN apt-get install -y libmysqlclient-dev
RUN apt-get install -y curl
RUN apt-get install -y tmux
#RUN apt-get install -y netcat
RUN apt-get install -y zsh
RUN apt-get install -y cloc
RUN apt-get install -y neovim
RUN apt-get install -y tree
RUN apt-get install -y sudo
RUN apt-get install -y locales
RUN apt-get install -y iputils-ping
RUN apt-get install -y maven
RUN apt-get install -y zip
RUN apt-get install -y unzip
RUN apt-get install -y gradle
RUN apt-get install -y awscli
RUN apt-get install -y build-essential
RUN apt-get install -y cmake
RUN apt-get install -y python3-dev
RUN apt-get install -y mono-complete
RUN apt-get install -y golang
RUN apt-get install -y git

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

# Install coursier to manage scala binaries
RUN curl -fL https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz | gzip -d > /bin/cs
RUN chmod +x /bin/cs

#################################
# User mode.
#################################

USER $UNAME
# Create HOME dir
#RUN mkdir -p "/home/${UNAME}"

## setup zsh
RUN curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | zsh || true

# COPY --chown=$ARG_UID not recognised Issue https://github.com/moby/moby/issues/36557
COPY ./files/init.vim /home/${UNAME}/.config/nvim/init.vim
RUN sudo chown -R ${UID}:${GID} /home/${UNAME}/.config
COPY ./files/vimrc /home/${UNAME}/.vimrc
RUN sudo chown ${UID}:${GID} /home/${UNAME}/.vimrc
COPY ./files/zshrc /home/${UNAME}/.zshrc
RUN sudo chown ${UID}:${GID} /home/${UNAME}/.zshrc
COPY ./files/tmux.conf /home/${UNAME}/.tmux.conf
RUN sudo chown ${UID}:${GID} /home/${UNAME}/.tmux.conf


# Install NVM and use latest Node
ENV NVM_DIR /home/${UNAME}/.nvm 
ENV NODE_VERSION 18.6.0 

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm install -g yarn

# Install sdkman and tools
RUN curl -s "https://get.sdkman.io" | bash
RUN source "${UHOME}/.sdkman/bin/sdkman-init.sh" \
	&& sdk install java $(sdk list java | grep -o "8\.[0-9]*\.[0-9]*\.hs-adpt" | head -1) \
	&& sdk install sbt \
	&& sdk install scala \
	&& sdk install maven

RUN cs install metals
ENV PATH="$PATH:/home/${UNAME}/.local/share/coursier/bin"


RUN git config --global user.email "accept.acm@gmail.com"
RUN git config --global user.name "Zhihao Wang"

## setup nvim
RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

RUN vim +PlugInstall +qall
RUN vim -c 'CocInstall -sync coc-java coc-json' -c qall
COPY ./files/coc-settings.json /home/${UNAME}/.config/nvim/coc-settings.json
RUN sudo chown -R ${UID}:${GID} /home/${UNAME}/.config/nvim/coc-settings.json 

ENV TERM=xterm-256color

WORKDIR /workspace

CMD [ "zsh" ]
