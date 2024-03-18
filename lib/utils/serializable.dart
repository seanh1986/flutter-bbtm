abstract class Serializable {
  Map<String, dynamic> toJson();
}

abstract class Deserializable {
  void fromJson(Map<String, dynamic> json);
}
