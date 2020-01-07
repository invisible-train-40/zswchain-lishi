#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

main() {
  current_dir="`pwd`"
  trap "cd \"$current_dir\"" EXIT
  pushd "$ROOT" &> /dev/null

  build_suffix="$1"; shift
  if [[ $build_suffix == "" ]]; then
    usage_error "argument <build_suffix> is required"
  fi

  build_target="$1"; [[ $build_target != "" ]] && shift
  build_dir="build-$build_suffix"
  let "cpu_cores = $(grep -c ^processor /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu) - 2"

  echo "Building in ${build_dir} with ${cpu_cores} CPU cores"

  if [[ ! -d $build_dir ]]; then
    BUILD_DIR_SUFFIX=$build_suffix ./configure_project.sh
  fi

  cd $build_dir
  make -j$cpu_cores $build_target
}

usage_error() {
  message="$1"
  exit_code="$2"

  echo "ERROR: $message"
  echo ""
  usage
  exit ${exit_code:-1}
}

usage() {
  echo "usage: build_project <build_suffix> [target]"
  echo ""
  echo "Build the project with the following 'build_suffix', configuring"
  echo "the project initially if the build directory does not exist".
}

main $@