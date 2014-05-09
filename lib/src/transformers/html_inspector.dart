part of stitch.transformers;

class HtmlInspector extends InspectorTransformer {
  String get allowedExtensions => ".html .htm";

  RegExp get matcher => new RegExp(r'<link .*href="(.+\.css)">');

  HtmlInspector(SpriteAssetProvider spriteAssetProvider) : super(spriteAssetProvider);
}
