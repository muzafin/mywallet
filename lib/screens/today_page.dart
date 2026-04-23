// lib/screens/today_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/transaction_form.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
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

  // Helper untuk mendapatkan userId saat ini
  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  Future<double> _getTotalBalance() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_userId)
              .collection('transactions')
              .get();

      double totalPemasukan = 0, totalPengeluaran = 0;
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['type'] == 'PEMASUKAN') {
          totalPemasukan += (data['amount'] as num).toDouble();
        } else if (data['type'] == 'PENGELUARAN') {
          totalPengeluaran += (data['amount'] as num).toDouble();
        }
      }
      return totalPemasukan - totalPengeluaran;
    } catch (e) {
      print('Error getting total balance: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor = isDark ? Colors.grey[900] : Colors.grey[100];
    final cardColor = isDark ? Colors.grey[850] : Colors.white;

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final Stream<QuerySnapshot> transactionsStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('transactions')
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .where('timestamp', isLessThanOrEqualTo: endOfDay)
            .orderBy('timestamp', descending: true)
            .snapshots();

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Ringkasan Keuangan'),
        backgroundColor: bgColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kartu Ringkasan
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade700, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Sisa Uang Total',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                FutureBuilder<double>(
                  future: _getTotalBalance(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: 28,
                          width: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Rp 0',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      );
                    }
                    double totalBalance = snapshot.data ?? 0;
                    return Text(
                      currencyFormatter.format(totalBalance),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    );
                  },
                ),
                const Divider(
                  height: 32,
                  thickness: 0.5,
                  color: Colors.white24,
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: transactionsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    if (snapshot.hasError) {
                      return const Text(
                        'Gagal memuat aktivitas',
                        style: TextStyle(color: Colors.white70),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const SizedBox.shrink();
                    }

                    double dailyIncome = 0, dailyExpense = 0;
                    for (var doc in snapshot.data!.docs) {
                      var data = doc.data() as Map<String, dynamic>;
                      if (data['type'] == 'PEMASUKAN') {
                        dailyIncome += (data['amount'] ?? 0 as num).toDouble();
                      } else if (data['type'] == 'PENGELUARAN') {
                        dailyExpense += (data['amount'] ?? 0 as num).toDouble();
                      }
                    }
                    double dailyBalance = dailyIncome - dailyExpense;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDailyActivityColumn(
                              icon: Icons.arrow_circle_up_rounded,
                              label: 'Pemasukan Hari Ini',
                              amount: dailyIncome,
                              color: Colors.greenAccent,
                              formatter: currencyFormatter,
                            ),
                            _buildDailyActivityColumn(
                              icon: Icons.arrow_circle_down_rounded,
                              label: 'Pengeluaran Hari Ini',
                              amount: dailyExpense,
                              color: Colors.redAccent,
                              formatter: currencyFormatter,
                              isRightAligned: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Perubahan Hari Ini: ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              currencyFormatter.format(dailyBalance),
                              style: TextStyle(
                                color:
                                    dailyBalance == 0
                                        ? Colors.white
                                        : (dailyBalance < 0
                                            ? Colors.redAccent
                                            : Colors.greenAccent),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'Detail Transaksi Hari Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: transactionsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Terjadi kesalahan saat memuat data.',
                      style: TextStyle(color: textColor),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada transaksi hari ini.',
                      style: TextStyle(color: textColor),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        bool isPengeluaran = data['type'] == 'PENGELUARAN';
                        IconData icon =
                            categoryIcons[data['category']] ??
                            Icons.more_horiz_outlined;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: cardColor,
                          child: ListTile(
                            onTap:
                                () => showTransactionFormSheet(
                                  context,
                                  document: document,
                                ),
                            leading: Icon(
                              icon,
                              color: Colors.grey[600],
                              size: 30,
                            ),
                            title: Text(
                              data['description'] ?? 'Tanpa deskripsi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            trailing: Text(
                              currencyFormatter.format(data['amount'] ?? 0),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isPengeluaran ? Colors.red : Colors.green,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTransactionFormSheet(context),
        tooltip: 'Tambah Transaksi',
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDailyActivityColumn({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    required NumberFormat formatter,
    bool isRightAligned = false,
  }) {
    return Column(
      crossAxisAlignment:
          isRightAligned ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          formatter.format(amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
