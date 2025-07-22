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
      print('Error loading transactions: $e'); // Добавим для отладки
    }
  }

  Future<void> addTransaction(OmegaTransactionModel tx) async {
    try {
      await _service.addTransaction(tx);
      await loadTransactions();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to add transaction: $e'));
      print('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(String id, OmegaTransactionModel tx) async { // Используем String id
    try {
      await _service.updateTransaction(id, tx);
      await loadTransactions();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update transaction: $e'));
      print('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async { // Используем String id
    try {
      await _service.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete transaction: $e'));
      print('Error deleting transaction: $e');
    }
  }

  // Метод для получения транзакций, связанных с конкретной съемкой
  List<OmegaTransactionModel> getTransactionsForShoot(String shootId) {
    return state.transactions.where((tx) => tx.shootId == shootId).toList();
  }

  Future<void> clearAll() async {
    try {
      await _service.clearAll();
      emit(TransactionsState.initial());
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to clear all transactions: $e'));
      print('Error clearing all transactions: $e');
    }
  }
}