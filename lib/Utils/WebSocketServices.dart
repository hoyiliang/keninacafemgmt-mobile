import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketServices {
  final String _baseUrl;
  WebSocketChannel? _channel;

  WebSocketServices(this._baseUrl);

  void connect() {
    print('Connecting to $_baseUrl');
    _channel = IOWebSocketChannel.connect(Uri.parse(_baseUrl));
  }

  void disconnect() {
    _channel?.sink.close();
  }

  void listen(Function(dynamic) onData, {Function? onError, void Function()? onDone, bool? cancelOnError = false}) {
    _channel?.stream.listen(onData);
  }

  void send(String data) {
    _channel?.sink.add(data);
  }
}