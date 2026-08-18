import 'package:flutter/material.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';

class ShopOverlay extends StatefulWidget {
  final BroskieGame game;

  const ShopOverlay({super.key, required this.game});

  @override
  State<ShopOverlay> createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay> {
  void _tryBuy(int cost, void Function() apply) {
    final wallet = widget.game.scoreCoins;
    BroskieAudio.playUiClick();
    if (wallet.value >= cost) {
      wallet.value -= cost;
      apply();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          border: Border.all(color: Colors.magentaAccent, width: 4),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.magentaAccent, blurRadius: 15)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("BLACK MARKET", style: broskieHeadline(color: BroskieColors.magenta)),
                ValueListenableBuilder<int>(
                  valueListenable: widget.game.scoreCoins,
                  builder: (context, coins, _) =>
                      Text("\$$coins", style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 20),

            // Item 1: Shadow Broskie Skin
            _buildShopItem(
              title: "Juggernaut Volt-Cola",
              description: "Size up + golden aura + absorbs one hit
              cost: 100,
              icon: Icons.shield,
              onBuy: () => _tryBuy(100, () => widget.game.player.grow(PowerUpType.juggernaut)),
            ),

            const SizedBox(height: 10),

            // Item 2: Boomerang Piercing Upgrade
            _buildShopItem(
              title: "Shockwave Volt-Cola",
              description: "Size up + cyan aura + absorbs one hit
              cost: 150,
              icon: Icons.disc_full,
              onBuy: () => _tryBuy(150, () => widget.game.player.grow(PowerUpType.shockwave)),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
              onPressed: () {
                BroskieAudio.playUiClick();
                widget.game.overlays.remove('Shop');
              },
              child: const Text("CLOSE SHOP", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopItem({
    required String title,
    required String description,
    required int cost,
    required IconData icon,
    required VoidCallback onBuy,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(description, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(horizontal: 10)),
            onPressed: onBuy,
            child: Text("\$$cost", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
