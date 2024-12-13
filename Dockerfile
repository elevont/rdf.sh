# syntax=docker/dockerfile:1
# NOTE Lint this file with https://hadolint.github.io/hadolint/

# First, prepare the python stuff
FROM bitnami/python:3.13-debian-12 AS python-builder

# Install system dependencies
RUN install_packages \
        git

RUN mkdir /tools
COPY requirements.txt /tools/

RUN mkdir /install
WORKDIR /install

# Install Python dependencies
RUN PYTHONUSERBASE=/install \
    pip install \
        --user \
        --upgrade \
	--requirement /tools/requirements.txt

# Then use a minimal container
# and only copy over the required files
# generated in the previous container(s).
FROM bitnami/python:3.13-debian-12

# Install system dependencies
RUN install_packages \
        curl \
        gawk \
        jq \
        raptor2-utils \
        rasqal-utils \
        uuid \
        wget

COPY --from=python-builder /install /usr/local

# copy main script
COPY rdf /usr/local/bin/
# copy man page
COPY rdf.1 /usr/local/man/man1/

# prepopulate the namespace prefix cache from prefix.cc
RUN \
    mkdir -p ~/.cache/rdf.sh/ && \
    curl -s "http://prefix.cc/popular/all.file.txt" \
        | sed -e "s/\t/|/" \
        > ~/.cache/rdf.sh/prefix.cache

LABEL \
    org.label-schema.name="rdf.sh" \
    org.label-schema.description="A multi-tool shell script for doing Semantic Web jobs on the command line." \
    org.label-schema.url="https://github.com/seebi/rdf.sh" \
    org.label-schema.vcs-url="https://github.com/seebi/rdf.sh" \
    org.label-schema.vendor="Sebastian Tramp" \
    org.label-schema.schema-version="1.0"

ENTRYPOINT ["/usr/local/bin/rdf"]
CMD ["help"]
