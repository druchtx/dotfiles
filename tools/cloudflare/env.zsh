#!/bin/zsh
# read the cloudflare.cfg file for email and api key
if [ -f ~/.cloudflare/cloudflare.cfg ]; then
    export CLOUDFLARE_EMAIL=$(grep email ~/.cloudflare/cloudflare.cfg | cut -d '=' -f2 | tr -d '[:space:]')
    export CLOUDFLARE_API_TOKEN=$(grep key ~/.cloudflare/cloudflare.cfg | cut -d '=' -f2 | tr -d '[:space:]')
fi
