library spritely.sprite_sheet_engine;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:barback/barback.dart';
import 'package:path/path.dart' as pathos;
import 'package:spritely/src/sprite_sheet.dart';
import 'package:image/image.dart';

abstract class SpriteSheetEngine {
  Future<bool> isSpriteable(AssetId id, Transform transform);
  Future<SpriteSheet> generate(AssetId id, Transform transform);
}

class SpritelySpriteSheetEngine extends SpriteSheetEngine {
  Future<bool> isSpriteable(AssetId id, Transform transform) {
    return _listPngFiles(_spriteDirectoryForAsset(id, transform)).toList()
        .then((files) => files.isNotEmpty)
        .catchError((_) => false);
  }

  Future<SpriteSheet> generate(AssetId id, Transform transform) {
    var spriteDirectory = _spriteDirectoryForAsset(id, transform);

    return _readPngFilesAsAssets(spriteDirectory, transform)
        .then((assets) => _layoutAssetsAsSprites(assets))
        .then((sprites) => new SpriteSheet(pathos.basenameWithoutExtension(id.path), sprites));
  }

  Directory _spriteDirectoryForAsset(AssetId id, Transform transform) {
    return new Directory(pathos.withoutExtension(id.path));
  }

  Stream<File> _listPngFiles(Directory directory) => directory.list()
      .where((file) => pathos.extension(file.path).toLowerCase() == ".png");

  Future<List<Asset>> _readPngFilesAsAssets(Directory directory, Transform transform) => _listPngFiles(directory)
      .asyncMap((file) => transform.getInput(new AssetId(transform.primaryInput.id.package, file.path)))
      .toList();

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
