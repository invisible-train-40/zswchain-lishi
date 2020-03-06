#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

main() {
  current_dir="`pwd`"
  trap "cd \"$current_dir\"" EXIT
  pushd "$ROOT" &> /dev/null

  build_type="Debug"

  while getopts "ho:" opt; do
    case $opt in
      h) usage && exit 0;;
      o) build_type="$OPTARG";;
      \?) usage_error "Invalid option: -$OPTARG";;
    esac
  done
  shift $((OPTIND-1))

  if [[ $build_type != "Debug" && $build_type != "Release" ]]; then
      usage_error "Build type must be Debug or Release, got '$build_type'"
  fi

  build_suffix="$1"; shift
  if [[ $build_suffix == "" ]]; then
    usage_error "argument <build_suffix> is required"
  fi

  build_suffix=`printf "$build_type-$build_suffix" | tr '[A-Z]' '[a-z]'`

  build_target="$1"; [[ $build_target != "" ]] && shift
  build_dir="build-$build_suffix"
  let "cpu_cores = $(grep -c ^processor /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu)"

  echo "Building in ${build_dir} (${build_type}) with ${cpu_cores} CPU cores in 3s..."
  [[ $QUICK == "true" ]] || sleep 3

  if [[ ! -d "$build_dir" ]]; then
    ./configure_project.sh "$build_suffix" "$build_type"
  fi

  if [[ ! -L "./build" ]]; then
    rm -rf "./build" &> /dev/null || true
    ln -s $build_dir build
  elif [[ -L "./build" ]]; then
    rm "./build"
    ln -s $build_dir build
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
  echo "usage: build_project [-o (Debug|Release)] <build_suffix> [target]"
  echo ""
  echo "Build the project with the following 'build_suffix', configuring"
  echo "the project initially if the build directory does not exist".
}

main $@