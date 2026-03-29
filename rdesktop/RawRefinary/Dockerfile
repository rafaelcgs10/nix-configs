FROM lscr.io/linuxserver/rdesktop:ubuntu-mate

RUN sudo apt update
RUN sudo apt install -y git python3 python3-pip python3-venv build-essential python3-dev libxcb-cursor0 libxcb-xinerama0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-render-util0 libxcb-xkb1 libxkbcommon-x11-0

RUN git clone https://github.com/rymuelle/RawRefinery.git

WORKDIR /RawRefinery

RUN git checkout v1.3.0-alpha

RUN python3 -m venv .venv

ENV PATH="/RawRefinery/.venv/bin:$PATH"

RUN pip install torch~=2.8

RUN python -m pip install rawrefinery

