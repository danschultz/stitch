library stitch.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:path/path.dart' as pathos;
import 'package:code_transformers/assets.dart';
import 'package:stitch/src/sprite_sheet_engine.dart';
import 'package:stitch/src/sprite_sheet.dart';
import 'package:stitch/src/sprite_asset_provider.dart';

part 'src/transformers/inspector_transformer.dart';
part 'src/transformers/html_inspector.dart';

class StitchTransformer extends TransformerGroup {
  StitchTransformer() : super([
    [new HtmlInspector(new StitchSpriteSheetEngine(), new StitchAssetProvider())]
  ]);
  StitchTransformer.asPlugin() : this();
}
