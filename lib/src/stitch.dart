library stitch.stitch;

import 'package:yaml/yaml.dart';

class Stitch {
  final Iterable<String> assetPaths;
  final Iterable<String> formats;

  Stitch(Iterable<String> assetPaths, Iterable<String> formats) :
    assetPaths = assetPaths,
    formats = formats.toSet()..add(".png");

  factory Stitch.fromYaml(String yaml) {
    var data = loadYaml(yaml);
    var assetPaths = data["asset_paths"].toSet();
    var formats = data["formats"] == "all" ? allFormats : data["formats"].map((format) => ".$format").toSet();
    return new Stitch(assetPaths, formats);
  }

  Stitch addFormat(String format) => new Stitch(assetPaths, formats.toSet()..add(format));

  String toYaml() {
    var yaml = new StringBuffer();

    // Write assets
    yaml.writeln("asset_paths:");
    assetPaths.forEach((assetPath) => yaml.writeln("  - ${assetPath}"));

    // Write formats
    yaml.writeln("formats:");
    formats.forEach((format) => yaml.writeln("  - ${format.substring(1)}"));

    return yaml.toString();
  }
}

final Set allFormats = new Set.from([".css"]);