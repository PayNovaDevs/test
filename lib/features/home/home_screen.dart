import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(homeProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        title: Row(children: [const Text('NOVA Wallet'), const Spacer(), IconButton(icon: const Icon(Icons.qr_code), onPressed: () {})]),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _walletHeader(),
              const SizedBox(height: 16),
              _balanceCard(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionButton(Icons.send, 'Enviar'),
                  _actionButton(Icons.call_received, 'Recibir'),
                  _actionButton(Icons.swap_horiz, 'Swap'),
                  _actionButton(Icons.credit_card, 'Comprar'),
                ],
              ),
              const SizedBox(height: 16),
              _tokensList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => ref.read(homeProvider.notifier).state = i,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_calls), label: 'Swap'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Actividad'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }

  Widget _walletHeader() {
    return Row(
      children: [
        const CircleAvatar(radius: 28, child: Text('N')),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Mi Wallet Principal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('0x3f82...9a7b', style: TextStyle(color: Colors.grey[400])),
          ]),
        ),
        IconButton(icon: const Icon(Icons.copy), onPressed: () {}),
      ],
    );
  }

  Widget _balanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0B1020), Color(0xFF0B1530)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Saldo total'), Icon(Icons.remove_red_eye)]),
        const SizedBox(height: 12),
        const Text('\$12,458.75', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(height: 64, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.black12)),
      ]),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Column(children: [
      CircleAvatar(radius: 28, backgroundColor: Colors.green[700], child: Icon(icon, color: Colors.white)),
      const SizedBox(height: 6),
      Text(label)
    ]);
  }

  Widget _tokensList() {
    return Column(children: [
      ListTile(leading: const CircleAvatar(child: Icon(Icons.currency_bitcoin)), title: const Text('Ethereum'), subtitle: const Text('ETH'), trailing: Column(crossAxisAlignment: CrossAxisAlignment.end, children: const [Text('\$3,565.21'), Text('2.342 ETH', style: TextStyle(color: Colors.grey))])),
      const Divider(),
      ListTile(leading: const CircleAvatar(child: Icon(Icons.monetization_on)), title: const Text('USD Coin'), subtitle: const Text('USDC'), trailing: Column(crossAxisAlignment: CrossAxisAlignment.end, children: const [Text('\$1.00'), Text('1,250.00 USDC', style: TextStyle(color: Colors.grey))])),
    ]);
  }
}
