class RuntimeAssets {
  static const greyZoneBackground = 'runtime/grey_zone_background.png';
  static const factoryBackground = 'runtime/factory_background.png';
  static const neonSlumsBackground = 'runtime/neon_slums_background.png';
  static const monopolyCoreBackground = 'runtime/monopoly_core_background.png';
  static const player = 'runtime/broskie_player.png';
  static const playerWalk = 'runtime/broskie_walk_sheet.png';
  static const playerVoltWalk = 'runtime/broskie_volt_walk_sheet.png';
  static const corporateCube = 'runtime/corporate_cube.png';
  static const foreman = 'runtime/foreman_boss.png';
  static const dataBroker = 'runtime/data_broker_boss.png';

  static const all = [
    greyZoneBackground,
    factoryBackground,
    neonSlumsBackground,
    monopolyCoreBackground,
    player,
    playerWalk,
    playerVoltWalk,
    corporateCube,
    foreman,
    dataBroker,
  ];

  static String backgroundForStage(int index) {
    switch (index) {
      case 0:
        return greyZoneBackground;
      case 1:
        return factoryBackground;
      case 2:
        return neonSlumsBackground;
      default:
        return monopolyCoreBackground;
    }
  }
}
