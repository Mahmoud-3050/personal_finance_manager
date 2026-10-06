import '../../../../core/database/finance_store.dart';
import '../../../../shared/domain/finance_records.dart';

abstract interface class BookSnapshotDataSource {
  Future<FinanceRecords> read();

  Future<void> replace(FinanceRecords records);
}

class FinanceStoreBookSnapshotDataSource implements BookSnapshotDataSource {
  FinanceStoreBookSnapshotDataSource(this._store);

  final FinanceStore _store;

  @override
  Future<FinanceRecords> read() => _store.load();

  @override
  Future<void> replace(FinanceRecords records) => _store.save(records);
}
