FROM ubuntu:latest

RUN apt update
RUN apt install -y xterm bash git python3 python3-pip python3-venv build-essential python3-dev xpra dbus-x11 libxkbcommon-x11-0 libxcb-* curl

ENV HOME=/home/ubuntu
WORKDIR $HOME

RUN curl -O 'https://isabelle.in.tum.de/dist/Isabelle2025-2_linux.tar.gz'

RUN tar xvf Isabelle2025-2_linux.tar.gz

ENV ISABELLE_HOME=$HOME/Isabelle2025-2
ENV PROJECT_DIR=$HOME/project

RUN mkdir -p $PROJECT_DIR

RUN curl -O 'https://www.isa-afp.org/release/afp-current.tar.gz'

RUN tar xvf afp-current.tar.gz

RUN mv afp-202* afp

RUN $ISABELLE_HOME/bin/isabelle components -u $HOME/afp/thys

RUN git clone https://github.com/awslabs/AutoCorrode/
WORKDIR $HOME/AutoCorrode/iq/
RUN make 
RUN make install

RUN curl -fsSL https://opencode.ai/install | bash

WORKDIR $PROJECT_DIR

ENTRYPOINT ["./entrypoint.sh"]
