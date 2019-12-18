#!/usr/bin/env bash -e

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function main {
  version="$1"
  if [[ $version == "" ]]; then
    echo "First argument should be version tag to create (like 1.8.7). Don't add the 'v' prefix!"
    exit 1
  fi
  shift

  revision="v10.2"
  if [[ $1 != "" ]]; then
    revision=$1; shift
  fi

  tag_name="v${version}-dm-${revision}"

  git tag $tag_name

  echo "Tagged release '${tag_name}', pushing it to remote in 5s ..."
  sleep 5

  git push eoscanada-private $tag_name
}

main $@

