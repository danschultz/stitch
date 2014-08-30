part of stitch.transformers;

class StitchTransformer extends Transformer {
  Iterable<Output> _supportedOutputs;

  StitchTransformer(this._supportedOutputs);

  StitchTransformer.allFormats() : this([new CssOutput(), new ScssOutput()]);

  String get allowedExtensions => ".stitch .stitch.yaml";

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((contents) {
      var stopwatch = new Stopwatch()..start();

      // Don't include the stitch file in the build.
      transform.consumePrimary();

      var stitch = new Stitch.fromYaml(contents);
      var assets = _sortAssetsByName(stitch.assetPaths.map((asset) =>
          uriToAssetId(transform.primaryInput.id, asset, transform.logger, null)));

      // Create a Sprite for each of the images.
      var sprites = new Stream.fromIterable(assets)
          .asyncMap((asset) => transform.readInput(asset).single)
          .map((bytes) => decodePng(bytes))
          .toList().then((images) => _layoutImages(new Map.fromIterables(assets, images)));

      return sprites.then((sprites) {
        // Generate the usage file and image file.
        var outputs = _supportedOutputs
            .singleWhere((output) => output.extension == stitch.formatExtension)
            .generate(transform.primaryInput, sprites);

        outputs.forEach((output) => transform.addOutput(output));

        stopwatch.stop();
        transform.logger.info("Took ${stopwatch.elapsed.toString()} "
            "to generate: ${outputs.map((output) => output.id).join(", ")}");
      });
    });
  }

  Iterable<AssetId> _sortAssetsByName(Iterable<AssetId> assets) => assets.toList()..sort((a, b) {
    return Comparable.compare(pathos.basename(a.path), pathos.basename(b.path));
  });

  List<Sprite> _layoutImages(Map<AssetId, Image> images) {
    var sprites = [];
    var y = 0;

    images.forEach((asset, image) {
      var name = pathos.basenameWithoutExtension(asset.path);
      var sprite = new Sprite(name, image, new Point(0, y));
      sprites.add(sprite);
      y += image.height;
    });

    return sprites;
  }
}
