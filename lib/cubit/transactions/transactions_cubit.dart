// lib/cubit/transactions/transactions_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/omega_transaction_model.dart';
import '../../model/service/transaction_hive_service.dart';
import 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionHiveService _service;

  TransactionsCubit(this._service) : super(TransactionsState.initial());

  Future<void> loadTransactions() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final all = _service.getAll();
      emit(state.copyWith(transactions: all, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> addTransaction(OmegaTransactionModel tx) async {
    await _service.addTransaction(tx);
    await loadTransactions();
  }

  Future<void> updateTransaction(int key, OmegaTransactionModel tx) async {
    await _service.updateTransaction(key, tx);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int key) async {
    await _service.deleteTransaction(key);
    await loadTransactions();
  }

  Future<void> clearAll() async {
    await _service.clearAll();
    emit(TransactionsState.initial());
  }
}
