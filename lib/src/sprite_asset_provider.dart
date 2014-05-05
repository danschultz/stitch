library stitch.sprite_asset_provider;

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as pathos;
import 'package:barback/barback.dart';

abstract class SpriteAssetProvider {
  Future<List<Asset>> call(AssetId asset, Transform transform);
}

class StitchAssetProvider extends SpriteAssetProvider {
  Future<List<Asset>> call(AssetId asset, Transform transform) {
    var spriteDirectory = _spriteDirectoryForAsset(asset, transform);

    return spriteDirectory.exists()
        .then((exists) => exists ? _readPngFilesAsAssets(spriteDirectory, transform) : []);
  }

  Directory _spriteDirectoryForAsset(AssetId id, Transform transform) {
    return new Directory(pathos.withoutExtension(id.path));
  }

  Stream<File> _listPngFiles(Directory directory) => directory.list()
      .where((file) => pathos.extension(file.path).toLowerCase() == ".png");

  Future<List<Asset>> _readPngFilesAsAssets(Directory directory, Transform transform) => _listPngFiles(directory)
      .asyncMap((file) => transform.getInput(new AssetId(transform.primaryInput.id.package, file.path)))
      .toList();
}