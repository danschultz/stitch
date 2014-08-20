part of stitch.transformers;

class Stitcher extends Transformer {
  Iterable<Output> _supportedOutputs;

  Stitcher(this._supportedOutputs);

  Stitcher.allFormats() : this([new PngOutput(), new CssOutput()]);

  String get allowedExtensions => ".stitch .stitch.yaml";

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((contents) {
      // Don't include the stitch file in the build.
      transform.consumePrimary();

      var outputExtensions = _determineOutputExtension(transform.primaryInput.id);
      var stitch = new Stitch.fromYaml(contents);

      var outputs = _supportedOutputs.where((output) => outputExtensions.contains(output.extension));
      var stopwatch = new Stopwatch()..start();

      return Future.wait(outputs.map((output) => output.render(stitch, transform)))
          .then((outputs) {
            outputs.forEach((output) => transform.addOutput(output));
            stopwatch.stop();
            transform.logger.info("Took ${stopwatch.elapsed.toString()} "
                "to generate: ${outputs.map((output) => output.id).join(", ")}");
          });
    });
  }

  Set<String> _determineOutputExtension(AssetId assetId) {
    var name = pathos.basename(assetId.path);
    var extensions = name.split(".");

    if (extensions.last == "yaml") {
      extensions.removeLast();
    }

    if (extensions.last == "stitch") {
      extensions.removeLast();
    }

    return new Set.from([".png", ".${extensions.last}"]);
  }
}
