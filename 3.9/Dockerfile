FROM metabrainz/consul-template-base:v0.18.5-2

# This Dockerfile is based on
# https://github.com/docker-library/python/blob/393ba9b3/3.9/buster/Dockerfile

# remove expired let's encrypt certificate and install new ones
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /usr/share/ca-certificates/mozilla/DST_Root_CA_X3.crt \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Ensure that local Python build is preferred over whatever might come with the base image
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# Runtime dependencies. This includes the core packages for all of the buildDeps listed
# below. We explicitly install them so that when we `remove --auto-remove` the dev packages,
# these packages stay installed.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
                       ca-certificates \
                       gnupg-curl \
                       netbase \
                       libbz2-1.0 \
                       libexpat1 \
                       libffi6 \
                       libgdbm3 \
                       liblzma5 \
                       libncursesw5 \
                       libreadline6 \
                       libsqlite3-0 \
                       libssl1.0.0 \
                       libuuid1 \
                       tcl \
                       tk \
                       zlib1g \
	&& rm -rf /var/lib/apt/lists/*

ENV GPG_KEY E3FF2839C048B25C084DEBE9B26995E310250568
ENV PYTHON_VERSION 3.9.10

# The list of build dependencies comes from the python-docker slim version:
# https://github.com/docker-library/python/blob/393ba9b3/3.9/buster/slim/Dockerfile#L33
RUN set -ex \
	&& buildDeps=' \
		build-essential \
		libbz2-dev \
		libexpat1-dev \
		libffi-dev \
		libgdbm-dev \
		liblzma-dev \
		libncursesw5-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		tk-dev \
		tcl-dev \
		uuid-dev \
		xz-utils \
		zlib1g-dev \
	' \
	&& apt-get update \
	&& apt-get install -y $buildDeps --no-install-recommends \
    \
	&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--enable-loadable-sqlite-extensions \
		--enable-optimizations \
		--enable-option-checking=fatal \
		--enable-shared \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip \
	&& make -j "$(nproc)" \
	&& make install \
	&& rm -rf /usr/src/python \
	\
	&& find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
		\) -exec rm -rf '{}' + \
	\
	&& ldconfig \
	\
	&& python3 --version


# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config

# Install pip
# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 22.0.4
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/39356a9d34700a468cf847867ac1a3bd72cc5e45/get-pip.py
ENV PYTHON_GET_PIP_SHA256 ec367c5c9b82fa13c04cfabb0a069e84496d5c36714f14d19b5f24d519d3ba25

RUN set -ex; \
	\
	wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; \
	\
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py
