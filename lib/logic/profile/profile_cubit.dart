import 'package:dysch_mobile/core/services/storage_service.dart';
import 'package:dysch_mobile/data/models/user_model.dart';
import 'package:dysch_mobile/data/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ESTADOS
abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  ProfileLoaded(this.user);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileCubit extends Cubit<ProfileState> {
  final UserRepository repository;
  final StorageService storage;

  ProfileCubit(this.repository, this.storage) : super(ProfileLoading());

  void loadProfile() async {
    emit(ProfileLoading());
    // 1. Sacamos el ID de la "caja fuerte" (SharedPreferences)
    final userId = await storage.getUserId();

    if (userId != null) {
      try {
        // 2. Se lo pedimos al repositorio
        final user = await repository.getUser(userId);
        emit(ProfileLoaded(user));
      } catch (e) {
        emit(ProfileError("Error de conexión"));
      }
    }
  }
}
