library stitch.stitch;

import 'package:barback/barback.dart';
import 'package:yaml/yaml.dart';

class Stitch {
  final Iterable<AssetId> assets;
  final Iterable<String> formats;

  Stitch(Iterable<AssetId> assets, Iterable<String> formats) :
    assets = assets,
    formats = formats.toSet()..add(".png");

  factory Stitch.fromYaml(String yaml) {
    var data = loadYaml(yaml);
    var assets = data["assets"].map((path) => new AssetId.parse(path)).toSet();
    var formats = data["formats"] == "all" ? allFormats : data["formats"].map((format) => ".$format").toSet();
    return new Stitch(assets, formats);
  }

  Stitch addFormat(String format) => new Stitch(assets, formats.toSet()..add(format));

  String toYaml() {
    var yaml = new StringBuffer();

    // Write assets
    yaml.writeln("assets:");
    assets.forEach((asset) => yaml.writeln("  - ${asset.toString()}"));

    // Write formats
    yaml.writeln("formats:");
    formats.forEach((format) => yaml.writeln("  - ${format.substring(1)}"));

    return yaml.toString();
  }
}

final Set allFormats = new Set.from([".css"]);