part of stitch.transformers;

abstract class InspectorTransformer extends Transformer {
  SpriteAssetProvider _spriteAssetProvider;

  /// The type of format that the generated Stitch file will output. Should
  /// be one of [.css, .scss].
  String _outputExtension;

  InspectorTransformer(this._spriteAssetProvider, this._outputExtension);

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((contents) {
      var usageAssets = findUsageAssets(transform, contents);

      var assets = new Stream.fromIterable(usageAssets)
          .asyncMap((asset) {
            return _spriteAssetProvider(asset, transform).then((assets) {
              var paths = assets.map((providedAsset) =>
              pathos.relative(providedAsset.path, from: pathos.dirname(asset.path)));
              return [asset, paths];
            });
          })
          .where((tuple) => tuple.last.isNotEmpty)
          .map((tuple) {
            var stitch = new Stitch(tuple.last, _outputExtension.substring(1));
            var id = tuple.first.changeExtension("$_outputExtension.stitch.yaml");
            return new Asset.fromString(id, stitch.toYaml());
          })
          .asBroadcastStream();

      assets.forEach((asset) => _addOutput(transform, asset));

      // Subclasses may rewrite the input. For instance, the SCSS inspector rewrites the
      // imports to imported usage files.
      return transformInput(transform, contents)
          .then((_) => assets.toList());
    });
  }

  Iterable<AssetId> findUsageAssets(Transform transform, String assetContents);

  Future transformInput(Transform transform, String contents) => new Future.value();

  void _addOutput(Transform transform, Asset asset) {
    transform
        ..logger.info("Outputting ${asset.id}", asset: asset.id)
        ..addOutput(asset);
  }
}
