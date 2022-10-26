#!/bin/bash
set -e

function cleanup {
  pushd -0
  echo "Done!"
}
trap cleanup EXIT INT

# **********************************************************************************************************************
# *                                               BUILD FUNCTIONS                                                      *
# **********************************************************************************************************************
function build_venom_func() {
  echo "Building venom"

  echo "Cleaning proto directories"
  mkdir -p \
  venom/dart \
  venom/go
  rm -rf \
    venom/dart/* \
    venom/go/* \
    snek/lib/proto/* \
    sssssserver/pkg/venom/*

  echo "Running protoc"
  pushd venom
  protoc -I proto/ --go_out go/ --go-grpc_out go/ --dart_out grpc:dart/ proto/*
  popd

  set +e
  echo "Copying files"
  cp venom/dart/* snek/lib/proto/
  cp -r venom/go/sssssserver/pkg/venom/* sssssserver/pkg/venom/

  echo "Done!"
}

function build_fang_func() {
  echo "Building fang"
  pushd fang
  wasm-pack build --color=always -t web --release
  popd

  echo "Copying files"
  cp fang/pkg/*.wasm snek/web/

  echo "Fixing glue code"
  # wasm-pack gives us ES6 JS, but flutter requires ES5. Fortunately, that's an easy conversion
  # Of course, this is a super hacky way to do it
  head fang/pkg/fang.js -n -3 | \
    sed \
      -e "s|export ||g" \
      -e "s|input = new URL('fang_bg.wasm', import.meta.url)|input = 'fang_bg.wasm'|g" \
      -e "s|async function init(input)|async function init()|g" \
    > snek/web/fang.js

  echo "Done!"
}

function build_sssssserver_func {
  echo "Building sssssserver"
  echo "Preparing target directory"
  pushd sssssserver
  mkdir -p target/
  rm -f target/*

  if [ "$release" == "TRUE" ]; then
    tag="release"
  else
    tag="debug"
  fi

  echo "Building..."
  for dir in cmd/*; do
    echo "Build $(basename "$dir")"
    go build -tags $tag "./$dir/"
  done

  echo "Moving to target directory"
  mv *.exe target/
  popd

  echo "Done!"
}

function build_snek_func {
  echo "Building snek"
  pushd snek
  flutter build web

  popd
  echo "Done!"
}

# **********************************************************************************************************************
# *                                                    MAIN                                                            *
# **********************************************************************************************************************

# Parse cmd line args
usage="build.sh [options]
  Options:
    --release : Build snek too
"
release="FALSE"
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --release)
      release="TRUE"
      shift
      ;;
    *)
      echo "$usage"
      exit 1
      ;;
  esac
done

echo "Running build"
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd $script_dir/../

build_venom_func
build_fang_func
build_sssssserver_func

if [ "$release" == "TRUE" ]; then
  build_snek_func
fi

popd
