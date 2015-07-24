FROM ubuntu:latest
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y wget
RUN apt-get install -y python
RUN apt-get install -y make
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
RUN pip install virtualenv
RUN git clone https://github.com/mesosphere/dcos-cli.git
WORKDIR /dcos-cli
RUN make env
RUN make packages
WORKDIR /dcos-cli/cli
RUN make env
ENV DCOS_CONFIG=/dcos/dcos.toml
ENV DCOS_PRODUCTION=false
RUN mkdir /dcos
RUN touch $DCOS_CONFIG
WORKDIR /dcos-cli/cli/env/bin
ENV PATH=$PATH:/dcos-cli/cli/env/bin
RUN dcos config append package.sources https://github.com/mesosphere/universe/archive/version-1.x.zip
RUN dcos config set package.cache /tmp/dcos
RUN dcos config set core.dcos_url http://foobar.com
RUN dcos service || true
RUN dcos package update
CMD dcos config set core.dcos_url ${MASTER_URI} && ${CMD} 
