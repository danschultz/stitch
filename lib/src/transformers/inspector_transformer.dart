part of stitch.transformers;

class InspectorTransformer extends Transformer {
  SpriteAssetProvider _spriteAssetProvider;

  /// The matcher that's run on an asset's contents, where the matcher's
  /// first group is expected to be a reference to a helper file.
  RegExp _matcher;

  /// The type of format that the generated Stitch file will output. Should
  /// be one of [CSS, SCSS].
  String _outputExtension;

  InspectorTransformer(this._spriteAssetProvider, this._matcher, this._outputExtension);

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((contents) {
      var helperAssets = _matcher.allMatches(contents).map((match) {
        return uriToAssetId(transform.primaryInput.id, match[1], transform.logger, null);
      });

      var assets = new Stream.fromIterable(helperAssets)
          .asyncMap((asset) => _spriteAssetProvider(asset, transform).then((assets) {
            var paths = assets.map((providedAsset) =>
                pathos.relative(providedAsset.path, from: pathos.dirname(asset.path)));
            return [asset, paths];
          }))
          .where((tuple) => tuple.last.isNotEmpty)
          .map((tuple) {
            var stitch = new Stitch(tuple.last);
            var id = tuple.first.changeExtension("$_outputExtension.stitch");
            return new Asset.fromString(id, stitch.toYaml());
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
