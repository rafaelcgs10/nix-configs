#!/bin/bash
xpra start \
  --bind-tcp=0.0.0.0:14500 \
  --html=on \
  --daemon=no \
  --start=rawrefinery
