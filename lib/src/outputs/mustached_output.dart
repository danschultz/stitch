part of stitch.outputs;

abstract class MustachedOutput extends Output {
  String get template;

  @override
  Asset buildAsset(Asset stitchAsset, Iterable<Sprite> sprites) {
    var name = pathos.basenameWithoutExtension(stitchAsset.id.path).split(".").first;
    var renderedTemplate = _renderTemplate(mustache.parse(template), name, sprites);
    return new Asset.fromString(stitchAsset.id, renderedTemplate);
  }

  String _renderTemplate(mustache.Template template, String sheetName, Iterable<Sprite> sprites) {
    var context = {
      "sheet_name": sheetName,
      "sprites": sprites.map((sprite) => sprite.toMap())
    };
    return template.renderString(context);
  }
}