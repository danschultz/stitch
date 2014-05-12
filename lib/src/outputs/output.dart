part of stitch.outputs;

abstract class Output {
  String get extension;

  Future<Asset> render(Stitch stitch, Transform transform) {
    var assets = stitch.assetPaths.map((asset) => uriToAssetId(transform.primaryInput.id, asset, transform.logger, null));
    var sortedAssets = _sortAssets(assets);
    return new Stream.fromIterable(sortedAssets)
        .asyncMap((asset) => transform.readInput(asset).first)
        .map((bytes) => decodePng(bytes))
        .toList().then((images) {
          var imageMapping = new Map.fromIterables(sortedAssets, images);
          return renderSprites(_layoutImages(imageMapping), transform.primaryInput);
        });
  }

  Asset renderSprites(Iterable<Sprite> sprites, Asset primaryInput);

  Iterable<AssetId> _sortAssets(Iterable<AssetId> assets) => assets.toList()..sort((a, b) {
    return Comparable.compare(pathos.basename(a.path), pathos.basename(b.path));
  });

  List<Sprite> _layoutImages(Map<AssetId, Image> images) {
    var sprites = [];
    var y = 0;

    images.forEach((asset, image) {
      var name = pathos.basenameWithoutExtension(asset.path);
      var sprite = new Sprite(name, image, new Point(0, y));
      sprites.add(sprite);
      y += image.height;
    });

    return sprites;
  }
}

class Sprite {
  final String name;
  final Image image;
  final Point position;

  Rectangle get bounds => new Rectangle(position.x, position.y, image.width, image.height);

  Sprite(this.name, this.image, this.position);
}
