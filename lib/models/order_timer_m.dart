import 'dart:convert';

class OrderTimerModel {
  final int orderId;
  int? secondsRemaining;

  OrderTimerModel({
    required this.orderId,
    this.secondsRemaining,
  });

  OrderTimerModel copyWith({
    int? orderId,
    int? secondsRemaining,
  }) {
    return OrderTimerModel(
      orderId: orderId ?? this.orderId,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderId': orderId,
      'secondsRemaining': secondsRemaining,
    };
  }

  factory OrderTimerModel.fromMap(Map<String, dynamic> map) {
    return OrderTimerModel(
      orderId: map['orderId'] as int,
      secondsRemaining: map['secondsRemaining'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderTimerModel.fromJson(String source) => OrderTimerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'OrderTimerModel(orderId: $orderId, secondsRemaining: $secondsRemaining)';

  @override
  bool operator ==(covariant OrderTimerModel other) {
    if (identical(this, other)) return true;

    return other.orderId == orderId && other.secondsRemaining == secondsRemaining;
  }

  @override
  int get hashCode => orderId.hashCode ^ secondsRemaining.hashCode;
}
