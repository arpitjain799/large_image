FROM ubuntu:20.04

# This is mostly based on the Dockerfiles from themattrix/pyenv and
# themattrix/tox-base.  It has some added packages, most notably liblzma-dev,
# to work for more of our conditions, plus some convenience libraries like
# libldap2-dev, libsasl2-dev, fuse to facilitate girder-based testing.  Also,
# gosu was removed.

LABEL maintainer="Kitware, Inc. <kitware@kitware.com>"

# The default python version will be the first of all the versions listed
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    PYENV_ROOT="/.pyenv" \
    PATH="/.pyenv/bin:/.pyenv/shims:$PATH" \
    PYTHON_VERSIONS="3.9.15 3.8.15 3.7.15 3.6.15 3.10.8 3.11.0"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      # general utilities \
      software-properties-common \
      # as specified by \
      # https://github.com/pyenv/pyenv/wiki#suggested-build-environment
      build-essential \
      curl \
      libbz2-dev \
      libffi-dev \
      liblzma-dev \
      libncursesw5-dev \
      libreadline-dev \
      libsqlite3-dev \
      libssl-dev \
      libxml2-dev \
      libxmlsec1-dev \
      llvm \
      make \
      tk-dev \
      wget \
      xz-utils \
      zlib1g-dev \
      # for curl \
      ca-certificates \
      # girder convenience
      fuse \
      libldap2-dev \
      libsasl2-dev \
      # developer convenience \
      bzip2 \
      dirmngr \
      git \
      gpg-agent \
      less \
      locales \
      ssh \
      vim \
      # testing convenience \
      fonts-dejavu \
      libmagic-dev \
      # shrink docker image \
      rdfind \
      # core girder
      gcc \
      libpython3-dev \
      python3-pip \
      python3-venv \
      cmake \
      iptables \
      dnsutils \
      automake \
      rsync \
      && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash && \
    find / -xdev -name __pycache__ -type d -exec rm -r {} \+ && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

RUN git clone "https://github.com/universal-ctags/ctags.git" "./ctags" && \
    cd ./ctags && \
    ./autogen.sh && \
    ./configure && \
    make -j `nproc` && \
    make install -j `nproc`  && \
    cd .. && \
    rm -rf ./ctags

RUN pyenv update && \
    pyenv install --list && \
    echo $PYTHON_VERSIONS | xargs -P `nproc` -n 1 pyenv install && \
    pyenv global $(pyenv versions --bare) && \
    find $PYENV_ROOT/versions -type d '(' -name '__pycache__' -o -name 'test' -o -name 'tests' ')' -exec rm -rfv '{}' + >/dev/null && \
    find $PYENV_ROOT/versions -type f '(' -name '*.py[co]' -o -name '*.exe' ')' -exec rm -fv '{}' + >/dev/null && \
    echo $PYTHON_VERSIONS | tr " " "\n" > $PYENV_ROOT/version && \
    find / -xdev -name __pycache__ -type d -exec rm -r {} \+ && \
    rm -rf /tmp/* /var/tmp/* && \
    # This makes duplicate python library files hardlinks of each other \
    rdfind -minsize 1048576 -makehardlinks true -makeresultsfile false /.pyenv

RUN for ver in $PYTHON_VERSIONS; do \
    pyenv local $ver && \
    python -m pip install --no-cache-dir -U pip && \
    python -m pip install --no-cache-dir tox wheel && \
    pyenv local --unset; \
    done && \
    pyenv rehash && \
    find / -xdev -name __pycache__ -type d -exec rm -r {} \+ && \
    rm -rf /tmp/* /var/tmp/*

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs && \
    find / -xdev -name __pycache__ -type d -exec rm -r {} \+ && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app
