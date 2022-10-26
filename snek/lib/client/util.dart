import 'package:grpc/grpc_web.dart';

final grpcChannel = GrpcWebClientChannel.xhr(Uri.http('localhost:8080', ''));
final callOptions = CallOptions(timeout: const Duration(hours: 4));