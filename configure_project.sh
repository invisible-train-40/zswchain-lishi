#!/usr/bin/env sh

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

    echo "Configuring project in 3s (Type: $build_type, Dir: build-$build_suffix)..."
    [[ $QUICK == "true" ]] || sleep 3

    BUILD_DIR_SUFFIX=$build_suffix $ROOT/scripts/eosio_build.sh -n -o $build_type -i $HOME/eosio/1.8 -y $@
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
  echo "usage: ./configure_project <build_suffix> [Debug|Release]"
  echo ""
  echo "Configure the project ready to be build. The build directory used is always suffixed"
  echo "with <build_type>-<build_suffix> (like 'build-debug-2.0.x') so it's possible to easily"
  echo "keep multiple build variants, making it easier to work on concurrent branches."
}

main "$@"
