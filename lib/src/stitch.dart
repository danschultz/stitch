library stitch.stitch;

import 'package:yaml/yaml.dart';

class Stitch {
  final Iterable<String> assetPaths;

  Stitch(this.assetPaths);

  factory Stitch.fromYaml(String yaml) {
    var data = loadYaml(yaml);
    var assetPaths = data["asset_paths"].toSet();
    return new Stitch(assetPaths);
  }

  String toYaml() {
    var yaml = new StringBuffer();

    // Write assets
    yaml.writeln("asset_paths:");
    assetPaths.forEach((assetPath) => yaml.writeln("  - ${assetPath}"));

    return yaml.toString();
  }
}
