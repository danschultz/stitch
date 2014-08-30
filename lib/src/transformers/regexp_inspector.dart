part of stitch.transformers;

class RegExpInspector extends InspectorTransformer {
  RegExp _matcher;

  RegExpInspector(this._matcher, SpriteAssetProvider spriteAssetProvider, String outputExtension) :
    super(spriteAssetProvider, outputExtension);

  Iterable<AssetId> findUsageAssets(Transform transform, String assetContents) {
    return _matcher.allMatches(assetContents).map((match) {
      var groups = new List.generate(match.groupCount, (i) => i + 1);
      var url = match.groups(groups).lastWhere((group) => group != null && group.isNotEmpty);
      return uriToAssetId(transform.primaryInput.id, url, transform.logger, null);
    });
  }
}