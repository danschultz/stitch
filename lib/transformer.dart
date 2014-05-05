library spritely.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:path/path.dart' as pathos;
import 'package:spritely/src/sprite_sheet_engine.dart';
import 'package:spritely/src/sprite_sheet.dart';
import 'package:code_transformers/assets.dart';
import 'package:spritely/src/sprite_asset_provider.dart';

part 'src/transformers/inspector_transformer.dart';
part 'src/transformers/html_inspector.dart';

class SpritelyTransformer extends TransformerGroup {
  SpritelyTransformer() : super([
    [new HtmlInspector(new SpritelySpriteSheetEngine(), new SpritelyAssetProvider())]
  ]);
  SpritelyTransformer.asPlugin() : this();
}
