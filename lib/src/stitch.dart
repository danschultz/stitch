library stitch.stitch;

import 'package:yaml/yaml.dart';

class Stitch {
  final Iterable<String> assetPaths;
  final String format;

  String get formatExtension => format[0] == "." ? format : ".$format";

  Stitch(this.assetPaths, this.format);

  factory Stitch.fromYaml(String yaml) {
    var data = loadYaml(yaml);
    var assetPaths = data["asset_paths"].toSet();
    var format = data["format"];
    return new Stitch(assetPaths, format);
  }

  String toYaml() {
    var yaml = new StringBuffer();

    // Write the format
    yaml.writeln("format: $format");

    // Write assets
    yaml.writeln("asset_paths:");
    assetPaths.forEach((assetPath) => yaml.writeln("  - ${assetPath}"));

    return yaml.toString();
  }
}
