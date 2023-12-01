import 'package:flutter/material.dart';
import 'package:keninacafe/Utils/WebSocketServices.dart';

class WebSocketManager extends ChangeNotifier {
  late WebSocketServices _webSocketServices;

  WebSocketManager(String baseUrl) {
    _webSocketServices = WebSocketServices(baseUrl);
  }

  void connectToWebSocket() {
    _webSocketServices.connect();
  }

  void disconnectFromWebSocket() {
    _webSocketServices.disconnect();
  }

  void listenToWebSocket(void Function(dynamic) onData) {
    _webSocketServices.listen(onData);
  }

  void sendToWebSocket(String data) {
    _webSocketServices.send(data);
  }
}