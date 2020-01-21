#!/usr/bin/env sh

build_suffix="$1"; shift
if [[ $build_suffix == "" ]]; then
    usage_error "argument <build_suffix> is required"
fi

BUILD_DIR_SUFFIX=$build_suffix ./scripts/eosio_build.sh -n -o Debug -i $HOME/eosio/1.8 -y $@