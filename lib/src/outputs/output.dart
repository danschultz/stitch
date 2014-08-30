part of stitch.outputs;

abstract class Output {
  String get extension;

  Iterable<Asset> generate(Asset stitchAsset, Iterable<Sprite> sprites) {
    var usageOutputId = buildUsageOutputId(stitchAsset);
    var pngOutputId = buildPngOutputId(usageOutputId);

    var usageAsset = new Asset.fromStream(usageOutputId, buildAsset(stitchAsset, sprites).read());
    var pngAsset = _buildPngAsset(pngOutputId, sprites);

    return [usageAsset, pngAsset];
  }

  Asset buildAsset(Asset stitchAsset, Iterable<Sprite> sprites);

  AssetId buildUsageOutputId(Asset stitchAsset) {
    // The most verbose input could be: icons.css.stitch.yaml
    var directory = pathos.dirname(stitchAsset.id.path);
    var spriteName = pathos.basename(stitchAsset.id.path).split(".").first;
    return new AssetId(stitchAsset.id.package, pathos.join(directory, spriteName)).changeExtension(extension);
  }

  AssetId buildPngOutputId(AssetId usageOutputId) => usageOutputId.addExtension(".png");

  Asset _buildPngAsset(AssetId outputId, Iterable<Sprite> sprites) {
    var size = sprites.map((sprite) => sprite.bounds)
        .reduce((Rectangle value, Rectangle current) => value.boundingBox(current)) as Rectangle;

    var image = new Image(size.width, size.height);
    for (var sprite in sprites) {
      copyInto(image, sprite.image, dstX: sprite.position.x, dstY: sprite.position.y, blend: false);
    }

    return new Asset.fromBytes(outputId, encodePng(image));
  }
}
