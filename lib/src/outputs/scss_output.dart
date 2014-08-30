part of stitch.outputs;

class ScssOutput extends MustachedOutput {
  String get extension => ".scss";

  String get template => '''
\${{sheet_name}}-sprite: (
{{#sprites}}
  {{name}}: (x: {{x}}px, y: {{y}}px, width: {{width}}px, height: {{height}}px, url: '{{sheet_name}}.scss.png'),
{{/sprites}}
);

@function get-{{sheet_name}}-sprite-value(\$name, \$property) {
  @return map-get(map-get(\${{sheet_name}}-sprite, \$name), \$property);
}

@function sprite-url(\$sprite) {
  @return "#{\$__sprite-dir}/#{\$sprite}";
}

@mixin {{sheet_name}}-dimensions(\$name) {
  width: get-{{sheet_name}}-sprite-value(\$name, width);
  height: get-{{sheet_name}}-sprite-value(\$name, height);
}

@mixin {{sheet_name}}-position(\$name) {
  background-position: get-{{sheet_name}}-sprite-value(\$name, x) -1 * get-{{sheet_name}}-sprite-value(\$name, y);
}

@mixin {{sheet_name}}-background(\$name) {
  background: url(sprite-url(get-{{sheet_name}}-sprite-value(\$name, url))) no-repeat;
}

@mixin {{sheet_name}}-sprite(\$name) {
  @include {{sheet_name}}-background(\$name);
  @include {{sheet_name}}-position(\$name);
  @include {{sheet_name}}-dimensions(\$name);
}
''';

  @override
  AssetId buildUsageOutputId(Asset stitchAsset) {
    var outputId = super.buildUsageOutputId(stitchAsset);

    var directoryName = pathos.dirname(outputId.path);
    var filename = pathos.basename(outputId.path);
    return new AssetId(outputId.package, pathos.join(directoryName, "_$filename"));
  }

  @override
  AssetId buildPngOutputId(AssetId usageOutputId) {
    var outputId = super.buildPngOutputId(usageOutputId);

    var directory = pathos.dirname(outputId.path);
    var filename = pathos.basename(outputId.path);
    return new AssetId(outputId.package, pathos.join(directory, filename.substring(1)));
  }
}