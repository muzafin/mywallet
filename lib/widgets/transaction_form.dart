// lib/widgets/transaction_form.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- TAMBAHKAN

void showTransactionFormSheet(
  BuildContext context, {
  DocumentSnapshot? document,
}) {
  Map<String, dynamic>? existingData =
      document?.data() as Map<String, dynamic>?;

  final TextEditingController descriptionController = TextEditingController(
    text: existingData?['description'],
  );
  final TextEditingController amountController = TextEditingController(
    text: existingData?['amount']?.toString(),
  );
  final TextEditingController customCategoryController =
      TextEditingController();

  String transactionType = existingData?['type'] ?? 'PENGELUARAN';

  final List<String> categories = [
    'Makanan',
    'Minuman',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Hiburan',
    'Transfer',
    'Lainnya...',
  ];

  String? selectedCategory;
  bool isCustomCategory = false;

  if (existingData != null) {
    String existingCategory = existingData['category'] ?? '';
    if (categories.contains(existingCategory)) {
      selectedCategory = existingCategory;
    } else {
      selectedCategory = 'Lainnya...';
      isCustomCategory = true;
      customCategoryController.text = existingCategory;
    }
  }

  // Mendapatkan userId saat ini
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    document == null
                        ? 'Tambah Transaksi Baru'
                        : 'Edit Transaksi',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ToggleButtons(
                    isSelected: [
                      transactionType == 'PEMASUKAN',
                      transactionType == 'PENGELUARAN',
                    ],
                    onPressed:
                        (index) => setModalState(
                          () =>
                              transactionType =
                                  index == 0 ? 'PEMASUKAN' : 'PENGELUARAN',
                        ),
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    fillColor:
                        transactionType == 'PEMASUKAN'
                            ? Colors.green
                            : Colors.red,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Pemasukan'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Pengeluaran'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Jumlah'),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    hint: const Text('Pilih Kategori'),
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items:
                        categories
                            .map(
                              (String category) => DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                    onChanged: (String? newValue) {
                      setModalState(() {
                        selectedCategory = newValue;
                        isCustomCategory = newValue == 'Lainnya...';
                      });
                    },
                  ),
                  Visibility(
                    visible: isCustomCategory,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        controller: customCategoryController,
                        decoration: const InputDecoration(
                          labelText: 'Masukkan Kategori Lain',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final String description =
                            descriptionController.text.trim();
                        final double? amount = double.tryParse(
                          amountController.text.trim(),
                        );
                        String finalCategory =
                            (selectedCategory == 'Lainnya...')
                                ? customCategoryController.text.trim()
                                : selectedCategory ?? '';

                        if (description.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Deskripsi tidak boleh kosong!'),
                            ),
                          );
                          return;
                        }

                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Jumlah harus berupa angka positif!',
                              ),
                            ),
                          );
                          return;
                        }

                        if (finalCategory.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kategori tidak boleh kosong!'),
                            ),
                          );
                          return;
                        }

                        try {
                          final transactionData = {
                            'description': description,
                            'amount': amount,
                            'type': transactionType,
                            'category': finalCategory,
                            'timestamp': Timestamp.now(),
                          };

                          // Referensi ke collection user saat ini
                          final collectionRef = FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('transactions');

                          if (document == null) {
                            await collectionRef.add(transactionData);
                          } else {
                            await document.reference.update(transactionData);
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transaksi berhasil disimpan!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          print('Error menyimpan transaksi: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal menyimpan: ${e.toString()}',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
