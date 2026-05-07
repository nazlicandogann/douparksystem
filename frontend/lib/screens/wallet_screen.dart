import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double? balance;
  List<dynamic> history = [];
  bool isLoading = true;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final b = await ApiService.getWalletBalance();
    final h = await ApiService.getWalletHistory();
    if (!mounted) return;
    setState(() {
      balance = b != null ? double.tryParse(b['balance'].toString()) : null;
      history = h;
      isLoading = false;
    });
  }

  Future<void> _deposit() async {
    final text = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(text);
    if (amount == null || amount < 10) {
      _snack('Minimum 10 TL yukleyebilirsiniz', error: true);
      return;
    }

    setState(() => isLoading = true);
    final result = await ApiService.depositWallet(amount);
    if (!mounted) return;
    setState(() => isLoading = false);

    if (result['success'] == true) {
      _amountController.clear();
      _snack('\${amount.toStringAsFixed(0)} TL basariyla yuklendi');
      _load();
    } else {
      _snack(result['message'] ?? 'Yukleme basarisiz', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  void _showDepositDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Para Yukle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Yuklemek istediginiz tutari girin (min. 10 TL):',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Ornek: 50',
                prefixText: 'TL ',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [50.0, 100.0, 200.0, 500.0].map((v) {
                return ActionChip(
                  label: Text('${v.toInt()} TL'),
                  onPressed: () {
                    _amountController.text = v.toInt().toString();
                  },
                  backgroundColor: const Color(0xFFFDECEC),
                  labelStyle: const TextStyle(color: Color(0xFFD32F2F)),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Iptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deposit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Yukle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Cuzdan'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Bakiye kartı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD32F2F).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined,
                                color: Colors.white70, size: 20),
                            SizedBox(width: 8),
                            Text('Mevcut Bakiye',
                                style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          balance != null
                              ? '${balance!.toStringAsFixed(2)} TL'
                              : '-- TL',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showDepositDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Para Yukle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFD32F2F),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // İşlem geçmişi
                  const Text('Islem Gecmisi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  if (history.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('Henuz islem yok',
                              style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    )
                  else
                    ...history.map((tx) => _buildTxCard(tx)),
                ],
              ),
            ),
    );
  }

  Widget _buildTxCard(dynamic tx) {
    final bool isDeposit = tx['type'] == 'DEPOSIT';
    final double amount = double.tryParse(tx['amount'].toString()) ?? 0;
    final double balanceAfter = double.tryParse(tx['balanceAfter'].toString()) ?? 0;
    final String desc = tx['description'] ?? '';
    final String dateRaw = tx['createdAt'] ?? '';

    String dateStr = '';
    try {
      final dt = DateTime.parse(dateRaw);
      dateStr =
          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      dateStr = dateRaw;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDeposit
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isDeposit ? Colors.green : Colors.red,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(desc,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 3),
                Text(dateStr,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isDeposit
                    ? '+${amount.abs().toStringAsFixed(2)} TL'
                    : '-${amount.abs().toStringAsFixed(2)} TL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDeposit ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 3),
              Text('${balanceAfter.toStringAsFixed(2)} TL',
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}