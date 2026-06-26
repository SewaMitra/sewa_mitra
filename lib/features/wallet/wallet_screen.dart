import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import '../../shared/models/backend_models.dart';
import 'transaction_screen.dart';
import 'add_money_screen.dart';
import 'send_money_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off the initial load once, after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletViewModel>().loadWalletData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WalletViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text(
          'Wallet',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkText),
        ),
        backgroundColor: AppTheme.bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => viewModel.refresh(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryOrange, Color(0xFFEA580C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Available Balance',
                            style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Icon(Icons.account_balance_wallet_outlined,
                            color: Colors.white.withOpacity(0.5)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (viewModel.isLoading)
                      const SizedBox(
                        height: 36,
                        width: 36,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    else
                      Text('Rs. ${viewModel.balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Quick Actions
              Row(
                children: [
                  _WalletAction(
                    icon: Icons.add_circle_rounded,
                    label: 'Add Money',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddMoneyScreen()),
                      );
                      if (context.mounted) viewModel.refresh();
                    },
                  ),
                  const SizedBox(width: 12),
                  _WalletAction(
                    icon: Icons.send_rounded,
                    label: 'Send Money',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SendMoneyScreen()),
                      );
                      if (context.mounted) viewModel.refresh();
                    },
                  ),
                  const SizedBox(width: 12),
                  _WalletAction(
                    icon: Icons.history_rounded,
                    label: 'History',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TransactionScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Recent Activity Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkText),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TransactionScreen()),
                      );
                    },
                    child: const Text('View All',
                        style: TextStyle(
                            color: AppTheme.primaryOrange, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (viewModel.isLoading && viewModel.transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (viewModel.transactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(color: AppTheme.greyText),
                    ),
                  ),
                )
              else
                ...viewModel.transactions.take(5).map(
                      (t) => _buildRecentActivityItem(t),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityItem(TransactionModel transaction) {
    final isDebit = transaction.amount < 0;
    final icon = _iconForType(transaction.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cardShadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDebit ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: isDebit ? Colors.red : Colors.green, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.description ?? transaction.type,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.darkText)),
                const SizedBox(height: 4),
                Text(_formatDate(transaction.createdAt),
                    style: const TextStyle(color: AppTheme.greyText, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isDebit ? '-' : '+'}Rs. ${transaction.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: isDebit ? AppTheme.darkText : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'add_money':
        return Icons.add_circle_outline_rounded;
      case 'send_money':
        return Icons.arrow_upward_rounded;
      case 'receive_money':
        return Icons.arrow_downward_rounded;
      case 'refund':
        return Icons.replay_rounded;
      case 'payment':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _WalletAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _WalletAction({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cardShadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: AppTheme.primaryOrange, size: 30),
                const SizedBox(height: 8),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
