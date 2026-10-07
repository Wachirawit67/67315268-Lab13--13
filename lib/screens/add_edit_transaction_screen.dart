import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/my_transaction.dart';
import '../providers/transaction_provider.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final MyTransaction? transactionToEdit;

  const AddEditTransactionScreen({super.key, this.transactionToEdit});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  late DateTime _selectedDate;
  late TransactionType _selectedType;

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      // โหมดแก้ไข: ดึงข้อมูลเดิมมาแสดง
      _titleController.text = widget.transactionToEdit!.title;
      _amountController.text = widget.transactionToEdit!.amount.toString();
      _selectedDate = widget.transactionToEdit!.date;
      _selectedType = widget.transactionToEdit!.type;
    } else {
      // โหมดเพิ่มใหม่: กำหนดค่าเริ่มต้น
      _selectedDate = DateTime.now();
      _selectedType = TransactionType.expense;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final provider = context.read<TransactionProvider>();

    if (widget.transactionToEdit == null) {
      // เพิ่มข้อมูลใหม่
      await provider.addTransaction(
        title,
        amount,
        _selectedDate,
        _selectedType,
      );
    } else {
      // แก้ไขข้อมูลเดิม
      final updatedTx = MyTransaction(
        id: widget.transactionToEdit!.id,
        title: title,
        amount: amount,
        date: _selectedDate,
        type: _selectedType,
      );
      await provider.updateTransaction(
        widget.transactionToEdit!.id!,
        updatedTx,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop(); // ปิดหน้าฟอร์ม
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transactionToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขรายการ' : 'เพิ่มรายการใหม่'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // สลับเลือกประเภท รายรับ / รายจ่าย
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('รายจ่าย'),
                      icon: Icon(Icons.arrow_downward, color: Colors.red),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('รายรับ'),
                      icon: Icon(Icons.arrow_upward, color: Colors.green),
                    ),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _selectedType = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // ช่องกรอกชื่อรายการ
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อรายการ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกชื่อรายการ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ช่องกรอกจำนวนเงิน
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'จำนวนเงิน (บาท)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกจำนวนเงิน';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return 'กรุณากรอกตัวเลขที่มากกว่า 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // เลือกวันที่
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'วันที่: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _presentDatePicker,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('เลือกวันที่'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ปุ่มบันทึก
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    isEditing ? 'บันทึกการแก้ไข' : 'บันทึกรายการ',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
