# Based on
# https://raw.githubusercontent.com/pmalmgren/dotfiles/master/Dockerfile
FROM debian:stable-slim

ARG username=talayhan
ARG DEBIAN_FRONTEND=noninteractive

LABEL Samet Talayhan <samet.${username}@gmail.com>

# System setup
RUN \
  apt-get update && \
  apt-get -yq upgrade && \
  apt-get clean && \
  apt-get -yq install curl

RUN \
  apt-get -yq install tmux && \
  apt-get -yq install git && \
  apt-get -yq install neovim && \
  apt-get -yq install locales && \
  apt-get -yq install zsh && \
  apt-get -yq install make

# locale
RUN \
  echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
  echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
  locale-gen en_US.UTF-8

# Create the user and copy over files
RUN useradd -ms /bin/bash $username
RUN chown -R $username:$username /home/$username

# SSH keys directory TBD at container run time
VOLUME /home/$username/.ssh

ADD . / /home/$username/dotfiles/

# Install oh-my-zsh and vim plug
USER $username
WORKDIR /home/$username/

RUN curl -L http://install.ohmyz.sh | sh || true
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$username/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# @TODO
# * zsh-auto suggestions
# * powerlevel10k
# * nvim > v0.4
# * let g:coc_disable_startup_warning = 1
# * ls -> dotfiles  Music  Pictures

# Override the .zshrc that oh-my-zsh gives us in favor of our own
RUN rm .zshrc
RUN ./dotfiles/install -c install_ubuntu.conf.yaml

# Change the shell to zsh
USER root
RUN chsh -s /usr/bin/zsh $username

USER $username
WORKDIR /home/$username

CMD ["zsh"]
