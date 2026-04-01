#!/bin/bash
xpra start --bind-tcp=0.0.0.0:14500 --html=on --daemon=no --start="/home/ubuntu/Isabelle2025-2/bin/isabelle jedit -d . -R Dataplane"
