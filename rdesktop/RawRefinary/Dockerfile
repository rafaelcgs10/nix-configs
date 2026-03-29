FROM ubuntu:latest

RUN apt update
RUN apt install -y git python3 python3-pip python3-venv build-essential python3-dev xpra dbus-x11 libxkbcommon-x11-0 libxcb-*

RUN git clone https://github.com/rymuelle/RawRefinery.git

WORKDIR /RawRefinery

RUN git checkout v1.3.0-alpha

RUN python3 -m venv .venv

ENV PATH="/RawRefinery/.venv/bin:$PATH"

RUN pip install torch~=2.8

RUN python -m pip install rawrefinery

COPY entrypoint.sh entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
