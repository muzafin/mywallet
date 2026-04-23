// lib/widgets/daily_summary_card.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'transaction_form.dart';

class DailySummaryCard extends StatefulWidget {
  final String date;
  final List<DocumentSnapshot> transactions;

  const DailySummaryCard({
    super.key,
    required this.date,
    required this.transactions,
  });

  @override
  State<DailySummaryCard> createState() => _DailySummaryCardState();
}

class _DailySummaryCardState extends State<DailySummaryCard> {
  bool _isExpanded = false;

  final Map<String, IconData> categoryIcons = {
    'Makanan': Icons.fastfood_outlined,
    'Minuman': Icons.local_cafe_outlined,
    'Transportasi': Icons.directions_bus_outlined,
    'Belanja': Icons.shopping_bag_outlined,
    'Tagihan': Icons.receipt_long_outlined,
    'Hiburan': Icons.movie_outlined,
    'Transfer': Icons.swap_horiz_outlined,
    'Lainnya...': Icons.more_horiz_outlined,
  };

  // Fungsi hapus satu transaksi
  Future<void> _deleteTransaction(
    DocumentSnapshot document,
    String description,
  ) async {
    // Konfirmasi sebelum hapus
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Transaksi'),
            content: Text('Apakah Anda yakin ingin menghapus "$description"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await document.reference.delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$description dihapus'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error menghapus: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus transaksi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Fungsi hapus semua transaksi di hari ini
  Future<void> _deleteAllTransactions() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Semua Transaksi'),
            content: Text(
              'Apakah Anda yakin ingin menghapus SEMUA transaksi pada tanggal ${widget.date}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus Semua'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        for (var doc in widget.transactions) {
          await doc.reference.delete();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Semua transaksi dihapus'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error menghapus: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus transaksi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    double dailyIncome = 0;
    double dailyExpense = 0;
    for (var doc in widget.transactions) {
      var data = doc.data() as Map<String, dynamic>;
      if (data['type'] == 'PEMASUKAN') {
        dailyIncome += (data['amount'] as num).toDouble();
      } else if (data['type'] == 'PENGELUARAN') {
        dailyExpense += (data['amount'] as num).toDouble();
      }
    }
    double dailyBalance = dailyIncome - dailyExpense;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      color: cardColor,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.date,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      Row(
                        children: [
                          // Tombol Hapus Semua
                          IconButton(
                            icon: const Icon(
                              Icons.delete_sweep,
                              color: Colors.red,
                            ),
                            onPressed: _deleteAllTransactions,
                            iconSize: 22,
                            tooltip: 'Hapus semua transaksi hari ini',
                          ),
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.expand_more,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Pemasukan',
                    dailyIncome,
                    Colors.green,
                    currencyFormatter,
                  ),
                  const SizedBox(height: 4),
                  _buildSummaryRow(
                    'Pengeluaran',
                    dailyExpense,
                    Colors.red,
                    currencyFormatter,
                  ),
                  const Divider(height: 20, thickness: 1),
                  _buildSummaryRow(
                    'Saldo Hari Ini',
                    dailyBalance,
                    dailyBalance < 0
                        ? Colors.red
                        : (isDark ? Colors.white : Colors.black87),
                    currencyFormatter,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              height: _isExpanded ? null : 0,
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              child: Column(
                children:
                    widget.transactions.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      bool isPengeluaran = data['type'] == 'PENGELUARAN';
                      IconData icon =
                          categoryIcons[data['category']] ??
                          Icons.more_horiz_outlined;
                      String description =
                          data['description'] ?? 'Tanpa deskripsi';

                      return Dismissible(
                        key: Key(document.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) async {
                          await document.reference.delete();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$description dihapus'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        background: Container(
                          color: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          onTap:
                              () => showTransactionFormSheet(
                                context,
                                document: document,
                              ),
                          leading: Icon(icon, color: Colors.grey[600]),
                          title: Text(
                            description,
                            style: TextStyle(color: textColor),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currencyFormatter.format(data['amount'] ?? 0),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isPengeluaran ? Colors.red : Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Tombol Delete per item
                              InkWell(
                                onTap:
                                    () => _deleteTransaction(
                                      document,
                                      description,
                                    ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount,
    Color color,
    NumberFormat formatter, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? null : Colors.grey[600],
          ),
        ),
        Text(
          formatter.format(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}
