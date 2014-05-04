library spritely.sprite_sheet;

import 'dart:math';
import 'package:image/image.dart';

class SpriteSheet {
  final String name;
  final Iterable<Sprite> sprites;

  SpriteSheet(this.name, List<Sprite> sprites) :
    sprites = sprites.toList()..sort((a, b) => Comparable.compare(a.name, b.name));

  Image generateImage() {
    var size = sprites.map((sprite) => sprite.bounds)
        .reduce((Rectangle value, Rectangle current) => value.boundingBox(current)) as Rectangle;

    var image = new Image(size.width, size.height);
    for (var sprite in sprites) {
      copyInto(image, sprite.image, dstX: sprite.position.x, dstY: sprite.position.y);
    }

    return image;
  }

  List<int> generatePng() => encodePng(generateImage());
}

class Sprite {
  final String name;
  final Image image;
  final Point position;

  Rectangle get bounds => new Rectangle(position.x, position.y, image.width, image.height);

  Sprite(this.name, this.image, this.position);
}
