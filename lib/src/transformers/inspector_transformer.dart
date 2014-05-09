part of stitch.transformers;

abstract class InspectorTransformer extends Transformer {
  SpriteSheetEngine _spriteSheetEngine;
  SpriteAssetProvider _spriteAssetProvider;

  InspectorTransformer(this._spriteSheetEngine, this._spriteAssetProvider);

  /// The matcher that's run on an asset's contents, where the matcher's
  /// first group is expected to be a reference to a helper file.
  RegExp get matcher;

  Asset generateHelper(AssetId id, SpriteSheet spriteSheet);

  Future apply(Transform transform) => transform.primaryInput.readAsString().then((contents) {
    var helperAssets = matcher.allMatches(contents).map((match) {
      return uriToAssetId(transform.primaryInput.id, match[1], transform.logger, null);
    });

    return Future.forEach(helperAssets, (asset) => _spriteAssetProvider(asset, transform).then((assets) {
      if (assets.isNotEmpty) {
        return _spriteSheetEngine.generate(asset, assets).then((spriteSheet) {
          // Generate the PNG for the sprite sheet.
          _addOutput(transform, _generateImage(asset, spriteSheet));

          // Generate the sprite sheet helper.
          _addOutput(transform, generateHelper(asset, spriteSheet));
        });
      }
    }));
  });

  Asset _generateImage(AssetId id, SpriteSheet spriteSheet) {
    return new Asset.fromBytes(id.changeExtension(".png"), spriteSheet.generatePng());
  }

  void _addOutput(Transform transform, Asset asset) {
    transform
        ..logger.info("Generated ${asset.id}", asset: asset.id)
        ..addOutput(asset);
  }
}
