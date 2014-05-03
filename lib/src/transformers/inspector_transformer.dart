part of spritely.transformer;

abstract class InspectorTransformer extends Transformer {
  /// The matcher that's run on an asset's contents, where the matcher's
  /// first group is expected to be a reference to a helper file.
  RegExp get matcher;

  Future generateHelper(Transform transform, SpriteSheet spriteSheet);

  Future apply(Transform transform) => transform.primaryInput.readAsString().then((contents) {
    var helperMatches = matcher.allMatches(contents);

    return Future.forEach(helperMatches, (match) => _isSupported(match, transform).then((isSupported) {
      if (isSupported) {
        return _generateSpriteSheet(match, transform).then((spriteSheet) => Future.wait([
          // Generate the PNG for the sprite sheet.
          spriteSheet.generatePng()
              .then((bytes) => new Asset.fromBytes(spriteSheet.id, bytes))
              .then((asset) => _addOutput(transform, asset)),
          // Generate the sprite sheet helper.
          generateHelper(transform, spriteSheet)
              .then((asset) => _addOutput(transform, asset))
        ]));
      }
    }));
  });

  void _addOutput(Transform transform, Asset asset) {
    transform
        ..logger.info("Generated ${asset.id}", asset: asset.id)
        ..addOutput(asset);
  }

  Future<bool> _isSupported(Match match, Transform transform) {
    return _generateSpriteSheet(match, transform)
        .then((spriteSheet) => spriteSheet.assets.isNotEmpty)
        .catchError((error) => false);

  }

  Future<SpriteSheet> _generateSpriteSheet(Match match, Transform transform) {
    var asset = uriToAssetId(transform.primaryInput.id, match[1], transform.logger, null);
    var path = pathos.withoutExtension(asset.path);
    return SpriteSheet.fromPath(path, transform);
  }
}
