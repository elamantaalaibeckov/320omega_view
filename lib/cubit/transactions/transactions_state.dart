// lib/cubit/transactions/transactions_state.dart

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import '../../model/omega_transaction_model.dart';

@immutable
class TransactionsState {
  final List<OmegaTransactionModel> transactions;
  final bool isLoading;
  final String? errorMessage;

  const TransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory TransactionsState.initial() => const TransactionsState();

  TransactionsState copyWith({
    List<OmegaTransactionModel>? transactions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TransactionsState &&
            const ListEquality().equals(transactions, other.transactions) &&
            isLoading == other.isLoading &&
            errorMessage == other.errorMessage);
  }

  @override
  int get hashCode => Object.hash(
        const ListEquality().hash(transactions),
        isLoading,
        errorMessage,
      );
}