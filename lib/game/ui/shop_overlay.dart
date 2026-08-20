import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flutter/material.dart';

class ShopOverlay extends StatefulWidget {
  final BroskieGame game;

  const ShopOverlay({super.key, required this.game});

  @override
  State<ShopOverlay> createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay> {
  void _tryBuy(int cost, bool Function() apply) {
    final wallet = widget.game.scoreCoins;
    BroskieAudio.playUiClick();
    if (wallet.value >= cost && apply()) {
      wallet.value -= cost;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 360,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92),
        padding: const EdgeInsets.all(20),
        decoration: broskiePanel(border: BroskieColors.cap),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("BLACK MARKET",
                      style: broskieHeadline(color: BroskieColors.cap)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: widget.game.scoreCoins,
                        builder: (context, coins, _) => Text("\$$coins",
                            style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          BroskieAudio.playUiClick();
                          widget.game.dismissOverlay('Shop');
                        },
                        child: const Icon(Icons.close,
                            color: Colors.white70, size: 22),
                      ),
                    ],
                  ),
                ],
              ),
            const Divider(color: Colors.white24, height: 20),

            // Item 1: the golden 2x4
            _buildShopItem(
              title: "Juggernaut Volt-Cola",
              description: "Size up + golden aura + absorbs one hit",
              cost: 100,
              icon: Icons.shield,
              onBuy: () => _tryBuy(
                  100, () => widget.game.player.grow(PowerUpType.juggernaut)),
            ),

            const SizedBox(height: 10),

            // Item 2: the cyan thunder
            _buildShopItem(
              title: "Shockwave Volt-Cola",
              description: "Size up + cyan aura + absorbs one hit",
              cost: 150,
              icon: Icons.disc_full,
              onBuy: () => _tryBuy(
                  150, () => widget.game.player.grow(PowerUpType.shockwave)),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: BroskieColors.amber,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
              onPressed: () {
                BroskieAudio.playUiClick();
                widget.game.dismissOverlay('Shop');
              },
              child: const Text("CLOSE SHOP",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            ],
          ),
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
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(description,
                    style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 10)),
            onPressed: onBuy,
            child: Text("\$$cost",
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
