import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/my_transaction.dart';

class TransactionProvider with ChangeNotifier {
  static const String _dbName = 'expenses.db';
  static const String _tableName = 'transactions';
  Database? _database;
  List<MyTransaction> _transactions = [];

  List<MyTransaction> get transactions => [..._transactions];

  TransactionProvider() {
    fetchAndSetTransactions();
  }

  // เปิด/สร้างฐานข้อมูล
  Future<void> _initDatabase() async {
    if (_database != null) return;
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, amount REAL, date TEXT, type TEXT)',
          );
        },
      );
    } catch (e) {
      debugPrint('Error initializing database: $e');
    }
  }

  // ดึงข้อมูลทั้งหมด
  Future<void> fetchAndSetTransactions() async {
    await _initDatabase();
    if (_database == null) return;
    final dataList = await _database!.query(_tableName, orderBy: 'date DESC');
    _transactions = dataList
        .map((item) => MyTransaction.fromMap(item))
        .toList();
    notifyListeners(); // แจ้งเตือน UI ให้วาดใหม่
  }

  // เพิ่มข้อมูลใหม่
  Future<void> addTransaction(
    String title,
    double amount,
    DateTime date,
    TransactionType type,
  ) async {
    await _initDatabase();
    if (_database == null) return;

    final newTransaction = MyTransaction(
      title: title,
      amount: amount,
      date: date,
      type: type,
    );

    await _database!.insert(_tableName, newTransaction.toMap());
    await fetchAndSetTransactions(); // รีเฟรชข้อมูลและสั่ง notifyListeners()
  }

  // แก้ไขข้อมูลเดิม
  Future<void> updateTransaction(int id, MyTransaction newTransaction) async {
    await _initDatabase();
    if (_database == null) return;
    await _database!.update(
      _tableName,
      newTransaction.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    await fetchAndSetTransactions();
  }

  // ลบข้อมูล
  Future<void> deleteTransaction(int id) async {
    await _initDatabase();
    if (_database == null) return;
    await _database!.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    await fetchAndSetTransactions();
  }
}
