import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

class LndhubIoServer {
  HttpServer? _server;
  late String url;

  Future<void> start() async {
    final router = Router()
      ..get('/balance', (Request req) {
        return Response.ok('{"balance":42000}',
            headers: {'Content-Type': 'application/json'});
      });

    _server = await io.serve(router, InternetAddress.loopbackIPv4, 0);
    url = 'http://${_server!.address.host}:${_server!.port}';
    print('Mock server running on $url');
  }

  Future<void> stop() async {
    await _server?.close();
    print('Mock server stopped');
  }
}
