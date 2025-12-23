enum MessageType { text, image, call }

enum CallType { audio, video }

enum CallDirection { outgoing, incoming }

enum CallStatus { ringing, accepted, missed, rejected, canceled, ended }

extension CallTypeX on CallType {
  String get value => this == CallType.audio ? "audio" : "video";
}

extension CallDirectionX on CallDirection {
  String get value => this == CallDirection.outgoing ? "outgoing" : "incoming";
}

extension CallStatusX on CallStatus {
  String get value {
    switch (this) {
      case CallStatus.ringing:
        return "ringing";
      case CallStatus.accepted:
        return "accepted";
      case CallStatus.missed:
        return "missed";
      case CallStatus.rejected:
        return "rejected";
      case CallStatus.canceled:
        return "canceled";
      case CallStatus.ended:
        return "ended";
    }
  }
}
