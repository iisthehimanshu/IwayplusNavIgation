//define the requirement in order to control the stream
abstract class BaseSensor {
  void startListening();
  void stopListening();
  Stream<dynamic> get stream;
}