// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/src/dart/analysis/experiments.dart';
import 'package:analyzer/src/error/codes.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dart/resolution/driver_resolution.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(InvalidUseOfNeverTest);
    defineReflectiveTests(InvalidUseOfNeverTest_Legacy);
  });
}

@reflectiveTest
class InvalidUseOfNeverTest extends DriverResolutionTest {
  @override
  AnalysisOptionsImpl get analysisOptions => AnalysisOptionsImpl()
    ..contextFeatures = FeatureSet.fromEnableFlags(
      [EnableString.non_nullable],
    );

  @override
  bool get typeToStringWithNullability => true;

  test_binaryExpression_never_eqEq() async {
    await assertErrorsInCode(r'''
void main(Never x) {
  x == 1 + 2;
}
''', [
      error(HintCode.RECEIVER_OF_TYPE_NEVER, 23, 1),
      error(HintCode.DEAD_CODE, 28, 6),
    ]);

    assertBinaryExpression(
      findNode.binary('x =='),
      element: null,
      type: 'Never',
    );

    assertType(findNode.binary('1 + 2'), 'int');
  }

  test_binaryExpression_never_plus() async {
    await assertErrorsInCode(r'''
void main(Never x) {
  x + (1 + 2);
}
''', [
      error(HintCode.RECEIVER_OF_TYPE_NEVER, 23, 1),
      error(HintCode.DEAD_CODE, 27, 8),
    ]);

    assertBinaryExpression(
      findNode.binary('x +'),
      element: null,
      type: 'Never',
    );

    assertType(findNode.binary('1 + 2'), 'int');
  }

  test_binaryExpression_neverQ_eqEq() async {
    await assertNoErrorsInCode(r'''
void main(Never? x) {
  x == 1 + 2;
}
''');

    assertBinaryExpression(
      findNode.binary('x =='),
      element: objectElement.getMethod('=='),
      type: 'bool',
    );

    assertType(findNode.binary('1 + 2'), 'int');
  }

  test_binaryExpression_neverQ_plus() async {
    await assertErrorsInCode(r'''
void main(Never? x) {
  x + (1 + 2);
}
''', [
      error(StaticWarningCode.UNCHECKED_USE_OF_NULLABLE_VALUE, 24, 1),
    ]);

    assertBinaryExpression(
      findNode.binary('x +'),
      element: null,
      type: 'dynamic',
    );

    assertType(findNode.binary('1 + 2'), 'int');
  }

  test_conditionalExpression_falseBranch() async {
    await assertNoErrorsInCode(r'''
void main(bool c, Never x) {
  c ? 0 : x;
}
''');
  }

  test_conditionalExpression_trueBranch() async {
    await assertNoErrorsInCode(r'''
void main(bool c, Never x) {
  c ? x : 0;
}
''');
  }

  test_functionExpressionInvocation_never() async {
    await assertErrorsInCode(r'''
void main(Never x) {
  x();
}
''', [
      error(HintCode.RECEIVER_OF_TYPE_NEVER, 23, 1),
    ]);
  }

  test_functionExpressionInvocation_neverQ() async {
    await assertErrorsInCode(r'''
void main(Never? x) {
  x();
}
''', [
      error(StaticWarningCode.UNCHECKED_USE_OF_NULLABLE_VALUE, 24, 1),
    ]);
  }

  test_indexExpression_never_read() async {
    await assertErrorsInCode(r'''
void main(Never x) {
  x[0];
}
''', [
      error(HintCode.RECEIVER_OF_TYPE_NEVER, 23, 1),
      error(HintCode.DEAD_CODE, 25, 3),
    ]);

    assertIndexExpression(
      findNode.index('x[0]'),
      readElement: null,
      writeElement: null,
      type: 'Never',
    );
  }

  test_indexExpression_never_readWrite() async {
    await assertErrorsInCode(r'''
void main(Never x) {
  x[0] += 1 + 2;
}
''', [
      error(HintCode.RECEIVER_OF_TYPE_NEVER, 23, 1),
      error(HintCode.DEAD_CODE, 25, 12),
    ]);

    assertIndexExpression(
      findNode.index('x[0]'),
      readElement: null,
      writeElement: null,
      type: 'Never',
    );

    assertType(findNode.binary('1 + 2'), 'int');
  }

  test_indexExpression_never_write() async {
    await assertErrorsInCode(r'''
void main(Never x) {
  x[0] = 1 + 2;
}
''', [
      error(HintCode.RECEIVER_OF_TYPE_NEVER, 23, 1),
      error(HintCode.DEAD_CODE, 25, 11),
    ]);

    assertIndexExpression(
      findNode.index('x[0]'),
      readElement: null,
      writeElement: null,
      type: 'Never',
    );

    assertType(findNode.binary('1 + 2'), 'int');
  }

  test_indexExpression_neverQ_read() async {
    await assertErrorsInCode(r'''
void main(Never? x) {
  x[0];
}
''', [
      error(StaticWarningCode.UNCHECKED_USE_OF_NULLABLE_VALUE, 24, 1),
      error(StaticTypeWarningCode.UNDEFINED_OPERATOR, 25, 3),
    ]);

    assertIndexExpression(
      findNode.index('x[0]'),
      readElement: null,
      writeElement: null,
      type: 'dynamic',
    );
  }

  test_indexExpression_neverQ_readWrite() async {
    await assertErrorsInCode(r'''
void main(Never? x) {
  x[0] += 1 + 2;
}
''', [
      error(StaticWarningCode.UNCHECKED_USE_OF_NULLABLE_VALUE, 24, 1),
      error(StaticTypeWarningCode.UNDEFINED_OPERATOR, 25, 3),
      error(StaticTypeWarningCode.UNDEFINED_OPERATOR, 25, 3),
    ]);

    assertIndexExpression(
      findNode.index('x[0]'),
      readElement: null,
      writeElement: null,
      type: 'dynamic',
    );

    assertType(findNode.binary('1 + 2'), 'int');
  }

  test_indexExpression_neverQ_write() async {
    await assertErrorsInCode(r'''
void main(Never? x) {
  x[0] = 1 + 2;
}
''', [
      error(StaticWarningCode.UNCHECKED_USE_OF_NULLABLE_VALUE, 24, 1),
      error(StaticTypeWarningCode.UNDEFINED_OPERATOR, 25, 3),
    ]);

    assertIndexExpression(
      findNode.index('x[0]'),
      readElement: null,
      writeElement: null,
      type: 'dynamic',
    );

    assertType(findNode.binary('1 + 2'), 'int');
  }

  test_invocationArgument() async {
    await assertNoErrorsInCode(r'''
void main(f, Never x) {
  f(x);
}
''');
  }

  test_methodInvocation_never() async {
    await assertErrorsInCode(r'''
void main(Never x) {
  x.foo(1 + 2);
}
''', [
      error(HintCode.RECEIVER_OF_TYPE_NEVER, 23, 1),
      error(HintCode.DEAD_CODE, 28, 8),
    ]);

    assertMethodInvocation(
      findNode.methodInvocation('.foo(1 + 2)'),
      null,
      'dynamic',
      expectedType: 'Never',
    );

    // Verify that arguments are resolved.
    assertType(findNode.binary('1 + 2'), 'int');
  }

  test_methodInvocation_never_toString() async {
    await assertErrorsInCode(r'''
void main(Never x) {
  x.toString(1 + 2);
}
''', [
      error(HintCode.RECEIVER_OF_TYPE_NEVER, 23, 1),
      error(HintCode.DEAD_CODE, 33, 8),
    ]);

    assertMethodInvocation(
      findNode.methodInvocation('.toString(1 + 2)'),
      null,
      'dynamic',
      expectedType: 'Never',
    );

    // Verify that arguments are resolved.
    assertType(findNode.binary('1 + 2'), 'int');
  }

  test_methodInvocation_neverQ_toString() async {
    await assertErrorsInCode(r'''
void main(Never? x) {
  x.toString(1 + 2);
}
''', [
      error(CompileTimeErrorCode.EXTRA_POSITIONAL_ARGUMENTS, 34, 7),
    ]);

    assertMethodInvocation(
      findNode.methodInvocation('.toString(1 + 2)'),
      objectElement.getMethod('toString'),
      'String Function()',
      expectedType: 'String',
    );

    // Verify that arguments are resolved.
    assertType(findNode.binary('1 + 2'), 'int');
  }

  test_postfixExpression_never_plusPlus() async {
    await assertErrorsInCode(r'''
void main(Never x) {
  x++;
}
''', [
      error(HintCode.RECEIVER_OF_TYPE_NEVER, 23, 1),
    ]);

    assertPostfixExpression(
      findNode.postfix('x++'),
      element: null,
      type: 'Never',
    );
  }

  test_postfixExpression_neverQ_plusPlus() async {
    await assertErrorsInCode(r'''
void main(Never? x) {
  x++;
}
''', [
      error(StaticWarningCode.UNCHECKED_USE_OF_NULLABLE_VALUE, 24, 1),
    ]);

    assertPostfixExpression(
      findNode.postfix('x++'),
      element: null,
      type: 'Never?',
    );
  }

  test_prefixExpression_never_plusPlus() async {
    // Reports 'undefined operator'
    await assertErrorsInCode(r'''
void main(Never x) {
  ++x;
}
''', [
      error(HintCode.RECEIVER_OF_TYPE_NEVER, 25, 1),
    ]);

    assertPrefixExpression(
      findNode.prefix('++x'),
      element: null,
      type: 'Never',
    );
  }

  test_prefixExpression_neverQ_plusPlus() async {
    await assertErrorsInCode(r'''
void main(Never? x) {
  ++x;
}
''', [
      error(StaticWarningCode.UNCHECKED_USE_OF_NULLABLE_VALUE, 26, 1),
    ]);

    assertPrefixExpression(
      findNode.prefix('++x'),
      element: null,
      type: 'dynamic',
    );
  }

  test_propertyAccess_never_read() async {
    await assertNoErrorsInCode(r'''
void main(Never x) {
  x.foo;
}
''');

    assertSimpleIdentifier(
      findNode.simple('foo'),
      element: null,
      type: 'Never',
    );
  }

  test_propertyAccess_never_read_hashCode() async {
    await assertNoErrorsInCode(r'''
void main(Never x) {
  x.hashCode;
}
''');

    assertSimpleIdentifier(
      findNode.simple('hashCode'),
      element: objectElement.getGetter('hashCode'),
      type: 'Never',
    );
  }

  test_propertyAccess_never_readWrite() async {
    await assertErrorsInCode(r'''
void main(Never x) {
  x.foo += 0;
}
''', [
      error(HintCode.DEAD_CODE, 32, 2),
    ]);

    assertSimpleIdentifier(
      findNode.simple('foo'),
      element: null,
      type: 'Never',
    );

    assertAssignment(
      findNode.assignment('foo += 0'),
      operatorElement: null,
      type: 'int',
    );
  }

  test_propertyAccess_never_tearOff_toString() async {
    await assertNoErrorsInCode(r'''
void main(Never x) {
  x.toString;
}
''');

    assertSimpleIdentifier(
      findNode.simple('toString'),
      element: objectElement.getMethod('toString'),
      type: 'Never',
    );
  }

  test_propertyAccess_never_write() async {
    await assertErrorsInCode(r'''
void main(Never x) {
  x.foo = 0;
}
''', [
      error(HintCode.DEAD_CODE, 31, 2),
    ]);

    assertSimpleIdentifier(
      findNode.simple('foo'),
      element: null,
      type: 'Never',
    );

    assertAssignment(
      findNode.assignment('foo = 0'),
      operatorElement: null,
      type: 'int',
    );
  }

  test_propertyAccess_neverQ_read() async {
    await assertErrorsInCode(r'''
void main(Never? x) {
  x.foo;
}
''', [
      error(StaticWarningCode.UNCHECKED_USE_OF_NULLABLE_VALUE, 24, 1),
    ]);

    assertSimpleIdentifier(
      findNode.simple('foo'),
      element: null,
      type: 'dynamic',
    );
  }

  test_propertyAccess_neverQ_read_hashCode() async {
    await assertNoErrorsInCode(r'''
void main(Never? x) {
  x.hashCode;
}
''');

    assertSimpleIdentifier(
      findNode.simple('hashCode'),
      element: objectElement.getGetter('hashCode'),
      type: 'int',
    );
  }

  test_propertyAccess_neverQ_tearOff_toString() async {
    await assertNoErrorsInCode(r'''
void main(Never? x) {
  x.toString;
}
''');

    assertSimpleIdentifier(
      findNode.simple('toString'),
      element: objectElement.getMethod('toString'),
      type: 'String Function()',
    );
  }
}

@reflectiveTest
class InvalidUseOfNeverTest_Legacy extends DriverResolutionTest {
  test_binaryExpression_eqEq() async {
    await assertNoErrorsInCode(r'''
void main() {
  (throw '') == 1 + 2;
}
''');

    assertBinaryExpression(
      findNode.binary('=='),
      element: elementMatcher(
        objectElement.getMethod('=='),
        isLegacy: isNullSafetySdkAndLegacyLibrary,
      ),
      type: 'bool',
    );

    assertType(findNode.binary('1 + 2'), 'int');
  }

  test_binaryExpression_plus() async {
    await assertErrorsInCode(r'''
void main() {
  (throw '') + (1 + 2);
}
''', [
      error(StaticTypeWarningCode.UNDEFINED_OPERATOR, 27, 1),
    ]);

    assertBinaryExpression(
      findNode.binary('+ ('),
      element: null,
      type: 'dynamic',
    );

    assertType(findNode.binary('1 + 2'), 'int');
  }

  test_methodInvocation_toString() async {
    await assertNoErrorsInCode(r'''
void main() {
  (throw '').toString();
}
''');

    assertMethodInvocation(
      findNode.methodInvocation('toString()'),
      null,
      'dynamic',
      expectedType: 'dynamic',
    );
  }

  test_propertyAccess_toString() async {
    await assertNoErrorsInCode(r'''
void main() {
  (throw '').toString;
}
''');

    assertSimpleIdentifier(
      findNode.simple('toString'),
      element: elementMatcher(
        objectElement.getMethod('toString'),
        isLegacy: isNullSafetySdkAndLegacyLibrary,
      ),
      type: 'String Function()',
    );
  }

  test_throw_getter_hashCode() async {
    await assertNoErrorsInCode(r'''
void main() {
  (throw '').hashCode;
}
''');

    assertSimpleIdentifier(
      findNode.simple('hashCode'),
      element: elementMatcher(
        objectElement.getGetter('hashCode'),
        isLegacy: isNullSafetySdkAndLegacyLibrary,
      ),
      type: 'int',
    );
  }
}
