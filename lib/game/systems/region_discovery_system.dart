import 'package:fish_growth_rpg/domain/models/region_definition.dart';
import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:flame/components.dart';

class RegionDiscoverySystem extends Component {
  RegionDiscoverySystem({
    required this.region,
    required this.player,
    required this.onDiscovered,
  });

  final RegionDefinition region;
  final PlayerFishComponent player;
  final void Function(RegionDiscoveryEvent event) onDiscovered;

  @override
  void update(double dt) {
    super.update(dt);
    for (final point in region.discoveryPoints) {
      if (player.progress.hasDiscoveredPoint(region.id, point.id)) {
        continue;
      }
      final delta = player.position - Vector2(point.x, point.y);
      if (delta.length2 > point.radius * point.radius) {
        continue;
      }
      final didDiscover = player.progress.discoverPoint(region.id, point.id);
      if (!didDiscover) {
        continue;
      }
      final completedRegion = region.discoveryPoints.every(
        (item) => player.progress.hasDiscoveredPoint(region.id, item.id),
      );
      player.progressChanges.value++;
      onDiscovered(
        RegionDiscoveryEvent(
          regionId: region.id,
          pointId: point.id,
          pointName: point.displayName,
          completedRegion: completedRegion,
        ),
      );
    }
  }
}
