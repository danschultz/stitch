library stitch.sprite_sheet_engine;

import 'dart:async';
import 'dart:math';
import 'package:barback/barback.dart';
import 'package:path/path.dart' as pathos;
import 'package:stitch/src/sprite_sheet.dart';
import 'package:image/image.dart';

abstract class SpriteSheetEngine {
  Future<SpriteSheet> generate(AssetId id, Iterable<Asset> assets);
}

class StitchSpriteSheetEngine extends SpriteSheetEngine {
  Future<SpriteSheet> generate(AssetId id, Iterable<Asset> assets) => _layoutAssetsAsSprites(assets)
      .then((sprites) => new SpriteSheet(pathos.basenameWithoutExtension(id.path), sprites));

  Stream<Image> _convertAssetsToImages(List<Asset> assets) => new Stream.fromIterable(assets)
      .asyncMap((Asset image) => image.read().first)
      .map((bytes) => decodePng(bytes));

  Future<List<Sprite>> _layoutAssetsAsSprites(List<Asset> assets) => _convertAssetsToImages(assets).toList()
      .then((images) {
        var sprites = [];
        var y = 0;
        for (var i = 0; i < images.length; i++) {
          var name = pathos.basenameWithoutExtension(assets[i].id.path);
          var sprite = new Sprite(name, images[i], new Point(0, y));
          sprites.add(sprite);
          y += images[i].height;
        }

        return sprites;
      });
}
