library stitch.tests.barback_helpers;

import 'package:barback/barback.dart';
import 'package:mock/mock.dart';

class TransformMock extends Mock implements Transform {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}