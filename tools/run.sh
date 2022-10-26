#!/bin/bash
set -e

function cleanup {
  pushd -0
  echo "Done!"
}
trap cleanup EXIT INT

echo "Running run.sh"
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd $script_dir/../

./tools/build.sh
./sssssserver/target/sssssserver.exe $(cat ./tools/gland_dev.credentials) --datadir "$(dirname "$0")/../data" &
sssssserver_pid=$!

#TODO: Import certs, enable tls
grpcwebproxy --backend_addr=localhost:42069 --run_tls_server=false --allow_all_origins --server_http_max_write_timeout 1h &
proxy_pid=$!

pushd snek
flutter run -d chrome
snek_pid=$!
popd

popd
