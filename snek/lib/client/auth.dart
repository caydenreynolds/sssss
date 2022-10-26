import 'package:snek/client/util.dart';
import 'package:snek/fang.dart';
import 'package:snek/proto/auth.pb.dart';
import 'package:snek/proto/auth.pbgrpc.dart';
import 'package:grpc/grpc_web.dart';

import '../except.dart';

final authStub = AuthServiceClient(grpcChannel);

Future<AuthToken> login(String username, String password) async {
  // Hashing the password client-side grants us 2 advantages:
  //   1. We can ensure the password fits in the 72 bytes required by bcrypt
  //   2. We can protect plaintext passwords in the case of a man-in-the-middle
  var cryptoPass = crypto_hash(password);
  final credentials = Credentials(username: username, password: cryptoPass);
  try {
    var response = await authStub.login(credentials);
    return response;
  } on GrpcError catch (e) {
    throw UserException(e.message!);
  }
}

Future<AuthToken> signup(String username, String password) async {
  var cryptoPass = crypto_hash(password);
  final credentials = Credentials(username: username, password: cryptoPass);
  try {
    var response = await authStub.newUser(credentials);
    return response;
  } on GrpcError catch (e) {
    throw UserException(e.message!);
  }
}
