part of stitch.transformers;

class HtmlInspector extends RegExpInspector {
  String get allowedExtensions => ".html .htm";

  HtmlInspector(SpriteAssetProvider spriteAssetProvider) :
    super(new RegExp(r'<link .*href="(.+\.css)">'), spriteAssetProvider, ".css");
}
