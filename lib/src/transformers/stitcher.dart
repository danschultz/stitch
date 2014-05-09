part of stitch.transformers;

class Stitcher extends Transformer implements LazyTransformer {
  Iterable<Output> _supportedOutputs;

  Stitcher(this._supportedOutputs);

  Stitcher.allFormats() : this([new PngOutput(), new CssOutput()]);

  String get allowedExtensions => ".stitch";

  Future declareOutputs(DeclaringTransform transform) {
    return transform.primaryInput.readAsString().then((yaml) {
      var stitch = new Stitch.fromYaml(yaml);
      transform.declareOutput(transform.primaryInput.id.changeExtension(".png"));
      stitch.formats
          .map((format) => transform.primaryInput.id.changeExtension(".$format"))
          .forEach((id) => transform.declareOutput(id));
    });
  }

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((contents) {
      // Don't include the stitch file in the build.
      transform.consumePrimary();

      var stitch = new Stitch.fromYaml(contents);
      var outputs = _supportedOutputs.where((output) => stitch.formats.contains(output.extension));
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
}
