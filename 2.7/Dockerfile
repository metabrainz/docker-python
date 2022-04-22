FROM metabrainz/consul-template-base:focal-1.1.0_ct_0.27.1

# This Dockerfile is based on
# https://github.com/docker-library/python/blob/a33fcb6adc834c2fdddd894fd0bbfc2609488e69/2.7/wheezy/Dockerfile
# https://github.com/docker-library/python/blob/f1e613f48eb4fc88748b36787f5ed74c14914636/2.7/buster/Dockerfile
# and
# https://github.com/docker-library/python/blob/652ed14d33da62558f336047bf0f6ea45addb596/3.10/bullseye/slim/Dockerfile

# Ensure that local Python build is preferred over whatever might come with the base image
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8
# https://github.com/docker-library/python/issues/147
ENV PYTHONIOENCODING UTF-8

# runtime dependencies
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		netbase \
		tcl \
		tk \
		tzdata \
	; \
	rm -rf /var/lib/apt/lists/*

ENV GPG_KEY C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF
ENV PYTHON_VERSION 2.7.18
ENV PYTHON_PIP_VERSION 20.3.4

# We do this in a single RUN command so that we install the build dependencies
# and remove them in a single layer so that we don't use as much disk space
RUN set -ex \
	# Installing build dependencies
	&& buildDeps=' \
		build-essential \
		libssl-dev \
		tcl-dev \
		tk-dev \
		libbz2-dev \
		libreadline-dev \
		libsqlite3-dev \
	' \
	&& apt-get update \
	&& apt-get install -y $buildDeps --no-install-recommends \
	\
	# Build python
	&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver hkps://keyserver.ubuntu.com --recv-keys "$GPG_KEY" \
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
		--enable-optimizations \
		--enable-option-checking=fatal \
		--enable-shared \
		--enable-unicode=ucs4 \
# setting PROFILE_TASK makes "--enable-optimizations" reasonable: https://bugs.python.org/issue36044 / https://github.com/docker-library/python/issues/160#issuecomment-509426916
		PROFILE_TASK='-m test.regrtest --pgo \
			test_array \
			test_base64 \
			test_binascii \
			test_binhex \
			test_binop \
			test_bytes \
			test_c_locale_coercion \
			test_class \
			test_cmath \
			test_codecs \
			test_compile \
			test_complex \
			test_csv \
			test_decimal \
			test_dict \
			test_float \
			test_fstring \
			test_hashlib \
			test_io \
			test_iter \
			test_json \
			test_long \
			test_math \
			test_memoryview \
			test_pickle \
			test_re \
			test_set \
			test_slice \
			test_struct \
			test_threading \
			test_time \
			test_traceback \
			test_unicode \
		' \
	&& make -j "$(nproc)" \
	&& make install \
	&& ldconfig \
	\
	&& find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name test -o -name idle_tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' + \
	&& cd /root \
	&& rm -rf /usr/src/python \
	\
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf /var/lib/apt/lists/* \
	\
	&& python2 --version

# Installing pip
RUN set -ex; \
	\
	wget -O get-pip.py 'https://bootstrap.pypa.io/pip/2.7/get-pip.py'; \
	echo "40ee07eac6674b8d60fce2bbabc148cf0e2f1408c167683f110fd608b8d6f416 *get-pip.py" | sha256sum --check --strict -; \
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
