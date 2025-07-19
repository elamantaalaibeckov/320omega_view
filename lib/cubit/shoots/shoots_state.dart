// lib/cubit/shoots/shoots_state.dart

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import '../../model/omega_shoot_model.dart';

@immutable
class ShootsState {
  final List<OmegaShootModel> shoots;
  final bool isLoading;
  final String? errorMessage;

  const ShootsState({
    this.shoots = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory ShootsState.initial() => const ShootsState();

  ShootsState copyWith({
    List<OmegaShootModel>? shoots,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ShootsState(
      shoots: shoots ?? this.shoots,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShootsState &&
            const ListEquality().equals(shoots, other.shoots) &&
            isLoading == other.isLoading &&
            errorMessage == other.errorMessage);
  }

  @override
  int get hashCode => Object.hash(
        const ListEquality().hash(shoots),
        isLoading,
        errorMessage,
      );
}
