// models/user_profile.dart
class UserProfile {
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String nombres;
  final String tipoDoc;
  final String numDoc;
  final String celular;
  final String email;

  UserProfile({
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.nombres,
    required this.tipoDoc,
    required this.numDoc,
    required this.celular,
    required this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      apellidoPaterno: json['apellido_paterno'] ?? '',
      apellidoMaterno: json['apellido_materno'] ?? '',
      nombres: json['nombres'] ?? '',
      tipoDoc: json['tipo_doc'] ?? '',
      numDoc: json['num_doc'] ?? '',
      celular: json['celular'] ?? '',
      email: json['email'] ?? '',
    );
  }

  String get nombreCompleto => '$nombres $apellidoPaterno $apellidoMaterno';
}
