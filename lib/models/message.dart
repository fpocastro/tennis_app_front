class Message {
  int id;
  String text;
  String senderId;
  String receiverId;
  DateTime time;

  Message.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    text = data['text'];
    senderId = data['senderId'];
    receiverId = data['receiverId'];
    time = data['time'] == null || data['time'] is DateTime ? data['time'] : DateTime.parse(data['time'].toString());
  }
}