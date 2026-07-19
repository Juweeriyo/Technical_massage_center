import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_model.dart';
import '../data/users_repository.dart';

final doctorsProvider = FutureProvider<List<User>>((ref) async {
  return await usersRepository.getDoctors();
});
