library stitch.sprite;

import 'dart:math';
import 'package:image/image.dart';

class Sprite {
  final String name;
  final Image image;
  final Point position;

  Rectangle get bounds => new Rectangle(position.x, position.y, image.width, image.height);

  Sprite(this.name, this.image, this.position);

  Map toMap() => {
      "name": name,
      "x": position.x,
      "y": position.y,
      "width": image.width,
      "height": image.height
  };
}
