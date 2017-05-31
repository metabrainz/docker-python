FROM metabrainz/consul-template-base

# Ensure that local Python build is preferred over whatever might come with the base image
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# Runtime dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
                       tcl \
                       tk \
	&& rm -rf /var/lib/apt/lists/*

ENV GPG_KEY C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF
ENV PYTHON_VERSION 2.7.12
ENV PYTHON_PIP_VERSION 9.0.1

RUN set -ex \
    # Installing build dependencies
	&& buildDeps=' \
		build-essential \
		libssl-dev \
		tcl-dev \
		tk-dev \
        	libbz2-dev \
	' \
	&& apt-get update \
	&& apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

# Building Python
RUN wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& rm -r "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	&& cd /usr/src/python \
	&& ./configure \
		--enable-shared \
		--enable-unicode=ucs4 \
	&& make -j$(nproc) \
	&& make install \
	&& ldconfig

# Installing pip
RUN if [ ! -e /usr/local/bin/pip ]; then : \
		&& wget -O /tmp/get-pip.py 'https://bootstrap.pypa.io/get-pip.py' \
		&& python /tmp/get-pip.py "pip==$PYTHON_PIP_VERSION" \
		&& rm /tmp/get-pip.py \
	; fi \
	&& pip install --no-cache-dir --upgrade --force-reinstall "pip==$PYTHON_PIP_VERSION" \
    # then we use "pip list" to ensure we don't have more than one pip version installed
    # https://github.com/docker-library/python/pull/100
	&& [ "$(pip list |tac|tac| awk -F '[ ()]+' '$1 == "pip" { print $2; exit }')" = "$PYTHON_PIP_VERSION" ]

# Cleanup
RUN find /usr/local -depth \
		\( \
			\( -type d -a -name test -o -name tests \) \
			-o \
			\( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		\) -exec rm -rf '{}' + \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf /usr/src/python ~/.cache