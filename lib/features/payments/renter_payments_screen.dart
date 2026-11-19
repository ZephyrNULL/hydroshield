import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/session.dart';
import '../../core/utils/formatters.dart';

enum _GatewayStep { method, details, processing, success }

enum _PayMethod { upi, card, netBanking }

class RenterPaymentsScreen extends StatefulWidget {
  const RenterPaymentsScreen({super.key});

  @override
  State<RenterPaymentsScreen> createState() => _RenterPaymentsScreenState();
}

class _RenterPaymentsScreenState extends State<RenterPaymentsScreen> {
  // Demo bill
  final double _amountDue = 294.00;
  final String _billPeriod = 'Nov 2026';
  bool _isPaid = false;

  _GatewayStep _step = _GatewayStep.method;
  _PayMethod _method = _PayMethod.upi;
  String _processingLabel = 'Initializing secure session...';
  String? _txnId;
  DateTime? _paidAt;
  String? _paidVia;

  final List<_PaymentRecord> _history = [
    _PaymentRecord(
        period: 'Oct 2026',
        amount: 1250.00,
        status: 'Paid',
        method: 'Bank transfer',
        date: DateTime(2026, 10, 28),
        txnId: 'HS-TXN-839201'),
    _PaymentRecord(
        period: 'Sep 2026',
        amount: 1180.00,
        status: 'Paid',
        method: 'Cash',
        date: DateTime(2026, 9, 27),
        txnId: 'HS-TXN-774110'),
  ];

  void _startPayment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => _PaymentGatewaySheet(
        amount: _amountDue,
        billPeriod: _billPeriod,
        onSuccess: (txnId, methodLabel, at) {
          setState(() {
            _isPaid = true;
            _txnId = txnId;
            _paidAt = at;
            _paidVia = methodLabel;
            _history.insert(
              0,
              _PaymentRecord(
                period: _billPeriod,
                amount: _amountDue,
                status: 'Paid',
                method: methodLabel,
                date: at,
                txnId: txnId,
              ),
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Owner Payment Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.account_balance),
                    title: Text('Bank: Hydro Bank'),
                    subtitle: Text('Account: 1234 5678 9012\nBranch: Main City\nIFSC: HYDR0001234')),
                const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.phone_android),
                    title: Text('UPI / Other'),
                    subtitle: Text('UPI: hydroshield.owner@bank\nCash / Bank transfer also accepted')),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Current Bill',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    _StatusChip(paid: _isPaid),
                  ],
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    child: Icon(Icons.water_drop, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text('Water charges • $_billPeriod'),
                  subtitle: Text(session.propertyName.value ?? 'Greenview Residence'),
                  trailing: Text(formatMoney(_amountDue),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const Divider(),
                _row('Consumption (recorded)', '2,450 L'),
                _row('Rate', '\$0.12 / L'),
                _row('Convenience fee', '\$0.00'),
                const SizedBox(height: 4),
                _row('Total payable', formatMoney(_amountDue), bold: true),
                const SizedBox(height: 12),
                if (_isPaid) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Payment successful', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 6),
                      Text('Transaction ID: ${_txnId ?? '-'}'),
                      Text('Paid via: ${_paidVia ?? '-'}'),
                      if (_paidAt != null) Text('Date: ${formatDateTime(_paidAt!)}'),
                    ]),
                  ),
                ] else ...[
                  FilledButton.icon(
                    onPressed: _startPayment,
                    icon: const Icon(Icons.lock_outline),
                    label: Text('Pay ${formatMoney(_amountDue)} Securely'),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user, size: 14, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('Demo secure payment gateway • 256-bit SSL (simulated)',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Payment History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (final r in _history) _HistoryTile(record: r),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String a, String b, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(a),
          Text(b, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
        ]),
      );
}

class _PaymentGatewaySheet extends StatefulWidget {
  final double amount;
  final String billPeriod;
  final void Function(String txnId, String methodLabel, DateTime at) onSuccess;
  const _PaymentGatewaySheet({required this.amount, required this.billPeriod, required this.onSuccess});

  @override
  State<_PaymentGatewaySheet> createState() => _PaymentGatewaySheetState();
}

class _PaymentGatewaySheetState extends State<_PaymentGatewaySheet> {
  _GatewayStep _step = _GatewayStep.method;
  _PayMethod _method = _PayMethod.upi;
  String _processingLabel = 'Connecting to secure gateway...';
  String? _error;

  // inputs
  final _upiCtrl = TextEditingController();
  final _cardNumCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String _selectedBank = 'Hydro Bank';

  final _banks = const ['Hydro Bank', 'Aqua National Bank', 'City Trust Bank', 'BlueWave Bank'];

  @override
  void dispose() {
    _upiCtrl.dispose();
    _cardNumCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  String get _methodLabel => switch (_method) {
        _PayMethod.upi => 'UPI',
        _PayMethod.card => 'Card',
        _PayMethod.netBanking => 'Net Banking ($_selectedBank)',
      };

  Future<void> _pay() async {
    setState(() => _error = null);
    final err = _validate();
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _step = _GatewayStep.processing;
      _processingLabel = 'Connecting to secure gateway...';
    });
    final steps = [
      'Connecting to secure gateway...',
      'Verifying payment details...',
      'Authorizing ${formatMoney(widget.amount)}...',
      'Confirming with bank...',
    ];
    for (final s in steps) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _processingLabel = s);
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final txnId = 'HS${DateTime.now().millisecondsSinceEpoch % 100000000}${Random().nextInt(900) + 100}';
    widget.onSuccess(txnId, _methodLabel, DateTime.now());
    setState(() => _step = _GatewayStep.success);
    // store txnId for display
    _successTxnId = txnId;
  }

  String? _successTxnId;

  String? _validate() {
    switch (_method) {
      case _PayMethod.upi:
        final v = _upiCtrl.text.trim();
        if (v.isEmpty || !v.contains('@')) return 'Enter a valid UPI ID (e.g. name@bank).';
        return null;
      case _PayMethod.card:
        final num = _cardNumCtrl.text.replaceAll(' ', '');
        if (num.length < 12) return 'Enter a valid card number.';
        if (_expiryCtrl.text.trim().length < 4) return 'Enter expiry (MM/YY).';
        if (_cvvCtrl.text.trim().length < 3) return 'Enter CVV.';
        if (_nameCtrl.text.trim().isEmpty) return 'Enter name on card.';
        return null;
      case _PayMethod.netBanking:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: switch (_step) {
          _GatewayStep.method || _GatewayStep.details => _detailsView(context),
          _GatewayStep.processing => _processingView(context),
          _GatewayStep.success => _successView(context),
        },
      ),
    );
  }

  Widget _detailsView(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('details'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        _gatewayHeader(context),
        const SizedBox(height: 12),
        _orderSummary(context),
        const SizedBox(height: 12),
        Text('Select payment method', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SegmentedButton<_PayMethod>(
          segments: const [
            ButtonSegment(value: _PayMethod.upi, label: Text('UPI'), icon: Icon(Icons.account_balance_wallet_outlined)),
            ButtonSegment(value: _PayMethod.card, label: Text('Card'), icon: Icon(Icons.credit_card)),
            ButtonSegment(value: _PayMethod.netBanking, label: Text('Net Banking'), icon: Icon(Icons.account_balance)),
          ],
          selected: {_method},
          onSelectionChanged: (s) => setState(() { _method = s.first; _error = null; }),
        ),
        const SizedBox(height: 12),
        if (_method == _PayMethod.upi) ...[
          TextField(
            controller: _upiCtrl,
            decoration: const InputDecoration(labelText: 'UPI ID', hintText: 'yourname@bank', prefixIcon: Icon(Icons.alternate_email)),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: ['tenant@upi', 'user@okbank', 'name@ybl']
              .map((s) => ActionChip(label: Text(s), onPressed: () => setState(() => _upiCtrl.text = s)))
              .toList()),
        ] else if (_method == _PayMethod.card) ...[
          TextField(
            controller: _cardNumCtrl,
            decoration: const InputDecoration(labelText: 'Card number', hintText: '4111 1111 1111 1111', prefixIcon: Icon(Icons.credit_card)),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _expiryCtrl, decoration: const InputDecoration(labelText: 'Expiry (MM/YY)', hintText: '09/29'), keyboardType: TextInputType.datetime)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _cvvCtrl, decoration: const InputDecoration(labelText: 'CVV', hintText: '123'), keyboardType: TextInputType.number, obscureText: true)),
          ]),
          const SizedBox(height: 8),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name on card', prefixIcon: Icon(Icons.person_outline))),
        ] else ...[
          DropdownButtonFormField<String>(
            value: _selectedBank,
            decoration: const InputDecoration(labelText: 'Select bank', prefixIcon: Icon(Icons.account_balance)),
            items: _banks.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            onChanged: (v) => setState(() => _selectedBank = v ?? _selectedBank),
          ),
          const SizedBox(height: 8),
          const Text('You will be securely redirected to your bank to authorize this payment (simulated).',
              style: TextStyle(fontSize: 12)),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _pay,
          icon: const Icon(Icons.lock),
          label: Text('Pay ${formatMoney(widget.amount)}'),
        ),
        const SizedBox(height: 8),
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.shield, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Flexible(child: Text('Secured by HydroShield Demo Gateway • No real money charged', style: TextStyle(fontSize: 12))),
        ]),
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _processingView(BuildContext context) {
    return Padding(
      key: const ValueKey('processing'),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        const SizedBox(width: 64, height: 64, child: CircularProgressIndicator(strokeWidth: 5)),
        const SizedBox(height: 20),
        Text('Processing Payment', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(_processingLabel, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(formatMoney(widget.amount), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const LinearProgressIndicator(),
        const SizedBox(height: 12),
        const Text('Please do not close this window.', style: TextStyle(fontSize: 12)),
      ]),
    );
  }

  Widget _successView(BuildContext context) {
    return Padding(
      key: const ValueKey('success'),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircleAvatar(radius: 34, backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.check_rounded, color: Colors.green, size: 40)),
        const SizedBox(height: 12),
        Text('Payment Successful', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
        const SizedBox(height: 4),
        Text(formatMoney(widget.amount), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              _kv('Transaction ID', _successTxnId ?? '-'),
              _kv('Bill period', widget.billPeriod),
              _kv('Payment method', _methodLabel),
              _kv('Date & time', formatDateTime(DateTime.now())),
              _kv('Status', 'SUCCESS'),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.done), label: const Text('Done')),
        const SizedBox(height: 4),
        TextButton.icon(onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt saved (demo).')));
        }, icon: const Icon(Icons.receipt_long), label: const Text('Download Receipt (demo)')),
      ]),
    );
  }

  Widget _gatewayHeader(BuildContext context) => Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.shield_outlined, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('HydroShield SecurePay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Demo payment gateway', style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: const Text('DEMO', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ]);

  Widget _orderSummary(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          _kv('Merchant', 'HydroShield Water Services'),
          _kv('Bill period', widget.billPeriod),
          _kv('Amount', formatMoney(widget.amount)),
        ]),
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: const TextStyle(color: Colors.black54)),
          Flexible(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600))),
        ]),
      );
}

class _PaymentRecord {
  final String period;
  final double amount;
  final String status;
  final String method;
  final DateTime date;
  final String txnId;
  const _PaymentRecord({required this.period, required this.amount, required this.status, required this.method, required this.date, required this.txnId});
}

class _HistoryTile extends StatelessWidget {
  final _PaymentRecord record;
  const _HistoryTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final paid = record.status == 'Paid';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(paid ? Icons.check_circle : Icons.pending_actions, color: paid ? Colors.green : Colors.orange),
      title: Text('${record.period} • ${record.status}'),
      subtitle: Text('${formatMoney(record.amount)} • ${record.method}\n${formatDate(record.date)} • ${record.txnId}'),
      isThreeLine: true,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool paid;
  const _StatusChip({required this.paid});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (paid ? Colors.green : Colors.orange).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(paid ? 'Paid' : 'Pending',
          style: TextStyle(color: paid ? Colors.green : Colors.orange, fontWeight: FontWeight.w700)),
    );
  }
}
