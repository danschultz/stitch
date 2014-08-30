part of stitch.transformers;

class ScssInspector extends RegExpInspector {
  static final _REG_EXP = new RegExp(r"""@import\s+('(.+?)'|"(.+?)")\s*;""");

  String get allowedExtensions => ".scss";

  SpriteAssetProvider _spriteAssetProvider;

  ScssInspector(SpriteAssetProvider spriteAssetProvider) :
    _spriteAssetProvider = spriteAssetProvider,
    super(_REG_EXP, spriteAssetProvider, ".scss");

  @override
  Future transformInput(Transform transform, String contents) {
    var imports = _REG_EXP.allMatches(contents);
    var spriteImports = new Set();

    var findImportsWithSprites = Future.forEach(imports, (import) {
      var assetId = uriToAssetId(transform.primaryInput.id, _importPath(import[1]), transform.logger, null);
      return _spriteAssetProvider(assetId, transform).then((assets) {
        if (assets.isNotEmpty) {
          spriteImports.add(import[0]);
        }
      });
    });

    return findImportsWithSprites.then((_) {
      if (spriteImports.isNotEmpty) {
        var transformedAsset = new Asset.fromString(
            transform.primaryInput.id,
            contents.replaceAllMapped(_REG_EXP, (match) {
              if (spriteImports.contains(match[0])) {
                var groups = new List.generate(match.groupCount, (i) => i + 1);
                var url = match.groups(groups).lastWhere((group) => group != null && group.isNotEmpty);
                return '\$__sprite-dir: "${pathos.dirname(url)}";\n'
                    '${match[0]}';
              } else {
                return match[0];
              }
            }));

        transform.addOutput(transformedAsset);
      }
    });
  }

  String _importPath(match) {
    return match.substring(1, match.length - 1);
  }
}