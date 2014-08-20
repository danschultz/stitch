part of stitch.transformers;

class HtmlInspector extends InspectorTransformer {
  String get allowedExtensions => ".html .htm";

  HtmlInspector(SpriteAssetProvider spriteAssetProvider) :
    super(spriteAssetProvider, new RegExp(r'<link .*href="(.+\.css)">'), ".css");
}
