part of stitch.transformers;

abstract class InspectorTransformer extends Transformer {
  SpriteAssetProvider _spriteAssetProvider;

  InspectorTransformer(this._spriteAssetProvider);

  /// The matcher that's run on an asset's contents, where the matcher's
  /// first group is expected to be a reference to a helper file.
  RegExp get matcher;

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((contents) {
      var helperAssets = matcher.allMatches(contents).map((match) {
        return uriToAssetId(transform.primaryInput.id, match[1], transform.logger, null);
      });

      var assets = new Stream.fromIterable(helperAssets)
          .asyncMap((asset) => _spriteAssetProvider(asset, transform).then((assets) => [asset, assets]))
          .where((tuple) => tuple.last.isNotEmpty)
          .map((tuple) {
            var stitch = new Stitch(tuple.last, allFormats);
            return new Asset.fromString(tuple.first.changeExtension(".stitch"), stitch.toYaml());
          })
          .asBroadcastStream();

      assets.forEach((asset) => _addOutput(transform, asset));
      return assets.toList();
    });
  }

  void _addOutput(Transform transform, Asset asset) {
    transform
        ..logger.fine("Outputting ${asset.id}", asset: asset.id)
        ..addOutput(asset);
  }
}
