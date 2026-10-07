import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/my_transaction.dart';
import 'add_edit_transaction_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายรับ-รายจ่าย')),
      body: Consumer<TransactionProvider>(
        builder: (context, txProvider, child) {
          if (txProvider.transactions.isEmpty) {
            return const Center(
              child: Text(
                'ยังไม่มีรายการ\nกดปุ่ม + ด้านล่างเพื่อเพิ่มรายการ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: txProvider.transactions.length,
            itemBuilder: (ctx, i) {
              final tx = txProvider.transactions[i];
              final isIncome = tx.type == TransactionType.income;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isIncome
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    tx.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(DateFormat.yMMMd().format(tx.date)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${tx.amount.toStringAsFixed(2)} ฿',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isIncome ? Colors.green : Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // เปิดหน้าแก้ไขรายการ
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => AddEditTransactionScreen(
                                transactionToEdit: tx,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () {
                          // กล่องยืนยันการลบ
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('ยืนยันการลบ'),
                              content: Text(
                                'คุณต้องการลบรายการ "${tx.title}" หรือไม่?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('ยกเลิก'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<TransactionProvider>()
                                        .deleteTransaction(tx.id!);
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text(
                                    'ลบ',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // เปิดหน้าเพิ่มรายการใหม่
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const AddEditTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
