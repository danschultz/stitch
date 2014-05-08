library stitch.hop_runner;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:guinness/guinness.dart';
import '../test/tests.dart' as tests;

void main(List args) {
  addTask("test", createUnitTestTask(() {
    tests.main();

    // Hop doesn't work with Guinness's auto-run behavior. We need to initialize
    // it manually. Hop will run any specs that are found since Guinness is using
    // the unittest package.
    guinness.initSpecs();
  }));

  runHop(args);
}