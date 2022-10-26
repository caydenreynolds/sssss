# SSSSS
S ystem
  for
S ecurely
S toring
S ome
S hit

## Wasm profiling findings
* wasm is one order of magnitude faster than dart for file compression
* wasm is significantly (2x) slower than dart for serializing small json messages
* Creating the dart bindings sucks, that needs to be automated
* May want to init the wasm module once on app startup so that we don't have to async everything

## Web GRPC
* Connecting to GRPC from web requires a proxy
* Currently using grpcwebproxy