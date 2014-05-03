library spritely.sprite_sheet;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:barback/barback.dart';
import 'package:path/path.dart' as pathos;
import 'package:image/image.dart';

class SpriteSheet {
  final AssetId id;
  final List<Asset> assets;

  String get name => pathos.basenameWithoutExtension(id.path);

  SpriteSheet(this.id, List<Asset> assets) :
    assets = assets.toList()..sort((a, b) => Comparable.compare(a.id.path, b.id.path));

  static Future<SpriteSheet> fromDirectory(Directory directory, Transform transform) {
    return directory.list().where((file) => pathos.extension(file.path) == ".png")
        .asyncMap((file) => transform.getInput(new AssetId(transform.primaryInput.id.package, file.path)))
        .toList().then((assets) {
          var path = pathos.join(directory.parent.path, "${pathos.basename(directory.path)}.png");
          var id = new AssetId(transform.primaryInput.id.package, path);
          return new SpriteSheet(id, assets);
        });
  }

  static Future<SpriteSheet> fromPath(String path, Transform transform) {
    return fromDirectory(new Directory(path), transform);
  }

  Future<Image> generateImage() {
    return readAssetsAsSprites().toList().then((sprites) {
      var size = sprites.map((sprite) => sprite.bounds)
          .reduce((Rectangle value, Rectangle current) => value.boundingBox(current)) as Rectangle;

      var image = new Image(size.width, size.height);
      for (var sprite in sprites) {
        copyInto(image, sprite.image, dstX: sprite.position.x, dstY: sprite.position.y);
      }
      return image;
    });
  }

  Future<List<int>> generatePng() => generateImage().then((image) => encodePng(image));

  Stream<Image> readAssetsAsImages() => new Stream.fromIterable(assets)
      .asyncMap((Asset image) => image.read().first)
      .map((bytes) => decodePng(bytes));

  Stream<Sprite> readAssetsAsSprites() {
    return readAssetsAsImages().toList().then((images) {
      var sprites = [];
      var y = 0;
      for (var i = 0; i < images.length; i++) {
        var sprite = new Sprite(pathos.basenameWithoutExtension(assets[i].id.path), images[i], new Point(0, y));
        sprites.add(sprite);
        y += images[i].height;
      }

      return sprites;
    }).asStream().expand((sprites) => sprites);
  }
}

class Sprite {
  final String name;
  final Image image;
  final Point position;

  Rectangle get bounds => new Rectangle(position.x, position.y, image.width, image.height);

  Sprite(this.name, this.image, this.position);
}
