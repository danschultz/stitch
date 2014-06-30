part of stitch.outputs;

class PngOutput extends Output {
  String get extension => ".png";

  @override
  Asset renderSprites(List<Sprite> sprites, Asset primaryInput) {
    var size = sprites.map((sprite) => sprite.bounds)
        .reduce((Rectangle value, Rectangle current) => value.boundingBox(current)) as Rectangle;

    var image = new Image(size.width, size.height);
    for (var sprite in sprites) {
      copyInto(image, sprite.image, dstX: sprite.position.x, dstY: sprite.position.y, blend: false);
    }

    return new Asset.fromBytes(primaryInput.id.changeExtension(extension), encodePng(image));
  }
}