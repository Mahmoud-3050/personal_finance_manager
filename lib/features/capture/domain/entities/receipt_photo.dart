import 'package:equatable/equatable.dart';

final class ReceiptPhoto extends Equatable {
  const ReceiptPhoto({required this.path});

  final String path;

  @override
  List<Object?> get props => <Object?>[path];
}
