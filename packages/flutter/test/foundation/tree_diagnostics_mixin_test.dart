// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class TestTree extends Object with TreeDiagnosticsMixin {
  TestTree({
    this.name,
    this.style,
    this.children: const <TestTree>[],
    this.properties: const <DiagnosticsNode>[],
  });

  final String name;
  final List<TestTree> children;
  final List<DiagnosticsNode> properties;
  final DiagnosticsTreeStyle style;

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];
    for (TestTree child in this.children) {
      children.add(child.toDiagnosticsNode(
        name: 'child ${child.name}',
        style: child.style,
      ));
    }
    return children;
  }

  @override
  void debugFillProperties(List<DiagnosticsNode> properties) {
    properties.addAll(this.properties);
  }
}

enum ExampleEnum {
  hello,
  world,
  deferToChild,
}

void main() {
  test('TreeDiagnosticsMixin control test', () async {
    void goldenStyleTest(String description,
        {DiagnosticsTreeStyle style,
        DiagnosticsTreeStyle lastChildStyle,
        String golden = ''}) {
      final TestTree tree = new TestTree(children: <TestTree>[
        new TestTree(name: 'node A', style: style),
        new TestTree(
          name: 'node B',
          children: <TestTree>[
            new TestTree(name: 'node B1', style: style),
            new TestTree(name: 'node B2', style: style),
            new TestTree(name: 'node B3', style: lastChildStyle ?? style),
          ],
          style: style,
        ),
        new TestTree(name: 'node C', style: lastChildStyle ?? style),
      ], style: lastChildStyle);

      expect(tree, hasAGoodToStringDeep);
      expect(
        tree.toDiagnosticsNode(style: style).toStringDeep(),
        equalsIgnoringHashCodes(golden),
        reason: description,
      );
    }

    goldenStyleTest(
      'dense',
      style: DiagnosticsTreeStyle.dense,
      golden:
      'TestTree#00000\n'
      '├child node A: TestTree#00000\n'
      '├child node B: TestTree#00000\n'
      '│├child node B1: TestTree#00000\n'
      '│├child node B2: TestTree#00000\n'
      '│└child node B3: TestTree#00000\n'
      '└child node C: TestTree#00000\n',
    );

    goldenStyleTest(
      'sparse',
      style: DiagnosticsTreeStyle.sparse,
      golden:
      'TestTree#00000\n'
      ' ├─child node A: TestTree#00000\n'
      ' ├─child node B: TestTree#00000\n'
      ' │ ├─child node B1: TestTree#00000\n'
      ' │ ├─child node B2: TestTree#00000\n'
      ' │ └─child node B3: TestTree#00000\n'
      ' └─child node C: TestTree#00000\n',
    );

    goldenStyleTest(
      'dashed',
      style: DiagnosticsTreeStyle.offstage,
      golden:
      'TestTree#00000\n'
      ' ╎╌child node A: TestTree#00000\n'
      ' ╎╌child node B: TestTree#00000\n'
      ' ╎ ╎╌child node B1: TestTree#00000\n'
      ' ╎ ╎╌child node B2: TestTree#00000\n'
      ' ╎ └╌child node B3: TestTree#00000\n'
      ' └╌child node C: TestTree#00000\n',
    );

    goldenStyleTest(
      'leaf children',
      style: DiagnosticsTreeStyle.sparse,
      lastChildStyle: DiagnosticsTreeStyle.transition,
      golden:
      'TestTree#00000\n'
      ' ├─child node A: TestTree#00000\n'
      ' ├─child node B: TestTree#00000\n'
      ' │ ├─child node B1: TestTree#00000\n'
      ' │ ├─child node B2: TestTree#00000\n'
      ' │ ╘═╦══ child node B3 ═══\n'
      ' │   ║ TestTree#00000\n'
      ' │   ╚═══════════\n'
      ' ╘═╦══ child node C ═══\n'
      '   ║ TestTree#00000\n'
      '   ╚═══════════\n',
    );

    // You would never really want to make everything a leaf child like this
    // but you can and still get a readable tree.
    // The joint between single and double lines here is a bit clunky
    // but we could correct that if there is any real use for this style.
    goldenStyleTest(
      'leaf',
      style: DiagnosticsTreeStyle.transition,
      golden:
      'TestTree#00000:\n'
      '  ╞═╦══ child node A ═══\n'
      '  │ ║ TestTree#00000\n'
      '  │ ╚═══════════\n'
      '  ╞═╦══ child node B ═══\n'
      '  │ ║ TestTree#00000:\n'
      '  │ ║   ╞═╦══ child node B1 ═══\n'
      '  │ ║   │ ║ TestTree#00000\n'
      '  │ ║   │ ╚═══════════\n'
      '  │ ║   ╞═╦══ child node B2 ═══\n'
      '  │ ║   │ ║ TestTree#00000\n'
      '  │ ║   │ ╚═══════════\n'
      '  │ ║   ╘═╦══ child node B3 ═══\n'
      '  │ ║     ║ TestTree#00000\n'
      '  │ ║     ╚═══════════\n'
      '  │ ╚═══════════\n'
      '  ╘═╦══ child node C ═══\n'
      '    ║ TestTree#00000\n'
      '    ╚═══════════\n',
    );

    goldenStyleTest(
      'whitespace',
      style: DiagnosticsTreeStyle.whitespace,
      golden:
      'TestTree#00000:\n'
      '  child node A: TestTree#00000\n'
      '  child node B: TestTree#00000:\n'
      '    child node B1: TestTree#00000\n'
      '    child node B2: TestTree#00000\n'
      '    child node B3: TestTree#00000\n'
      '  child node C: TestTree#00000\n',
    );

    // Single line mode does not display children.
    goldenStyleTest(
      'single line',
      style: DiagnosticsTreeStyle.singleLine,
      golden: 'TestTree#00000',
    );
  });

  test('TreeDiagnosticsMixin tree with properties test', () async {
    void goldenStyleTest(String description, {
      DiagnosticsTreeStyle style,
      DiagnosticsTreeStyle lastChildStyle,
      @required String golden,
    }) {
      final TestTree tree = new TestTree(
        properties: <DiagnosticsNode>[
          new StringProperty('stringProperty1', 'value1', quoted: false),
          new DoubleProperty('doubleProperty1', 42.5),
          new DoubleProperty('roundedProperty', 1.0 / 3.0),
          new StringProperty('DO_NOT_SHOW', 'DO_NOT_SHOW', hidden: true, quoted: false),
          new DiagnosticsProperty<Object>('DO_NOT_SHOW_NULL', null, defaultValue: null),
          new DiagnosticsProperty<Object>('nullProperty', null),
          new StringProperty('node_type', '<root node>', showName: false, quoted: false),
        ],
        children: <TestTree>[
          new TestTree(name: 'node A', style: style),
          new TestTree(
            name: 'node B',
            properties: <DiagnosticsNode>[
              new StringProperty('p1', 'v1', quoted: false),
              new StringProperty('p2', 'v2', quoted: false),
            ],
            children: <TestTree>[
              new TestTree(name: 'node B1', style: style),
              new TestTree(
                name: 'node B2',
                properties: <DiagnosticsNode>[new StringProperty('property1', 'value1', quoted: false)],
                style: style,
              ),
              new TestTree(
                name: 'node B3',
                properties: <DiagnosticsNode>[
                  new StringProperty('node_type', '<leaf node>', showName: false, quoted: false),
                  new IntProperty('foo', 42),
                ],
                style: lastChildStyle ?? style,
              ),
            ],
            style: style,
          ),
          new TestTree(
            name: 'node C',
            properties: <DiagnosticsNode>[
              new StringProperty('foo', 'multi\nline\nvalue!', quoted: false),
            ],
            style: lastChildStyle ?? style,
          ),
        ],
        style: lastChildStyle,
      );

      expect(tree, hasAGoodToStringDeep);
      expect(
        tree.toDiagnosticsNode(style: style).toStringDeep(),
        equalsIgnoringHashCodes(golden),
        reason: description,
      );
    }

    goldenStyleTest(
      'sparse',
      style: DiagnosticsTreeStyle.sparse,
      golden:
      'TestTree#00000\n'
      ' │ stringProperty1: value1\n'
      ' │ doubleProperty1: 42.5\n'
      ' │ roundedProperty: 0.3\n'
      ' │ nullProperty: null\n'
      ' │ <root node>\n'
      ' │\n'
      ' ├─child node A: TestTree#00000\n'
      ' ├─child node B: TestTree#00000\n'
      ' │ │ p1: v1\n'
      ' │ │ p2: v2\n'
      ' │ │\n'
      ' │ ├─child node B1: TestTree#00000\n'
      ' │ ├─child node B2: TestTree#00000\n'
      ' │ │   property1: value1\n'
      ' │ │\n'
      ' │ └─child node B3: TestTree#00000\n'
      ' │     <leaf node>\n'
      ' │     foo: 42\n'
      ' │\n'
      ' └─child node C: TestTree#00000\n'
      '     foo:\n'
      '     multi\n'
      '     line\n'
      '     value!\n',
    );

    goldenStyleTest(
      'dense',
      style: DiagnosticsTreeStyle.dense,
      golden:
      'TestTree#00000\n'
      '│stringProperty1: value1\n'
      '│doubleProperty1: 42.5\n'
      '│roundedProperty: 0.3\n'
      '│nullProperty: null\n'
      '│<root node>\n'
      '│\n'
      '├child node A: TestTree#00000\n'
      '├child node B: TestTree#00000\n'
      '││p1: v1\n'
      '││p2: v2\n'
      '││\n'
      '│├child node B1: TestTree#00000\n'
      '│├child node B2: TestTree#00000\n'
      '││ property1: value1\n'
      '│└child node B3: TestTree#00000\n'
      '│  <leaf node>\n'
      '│  foo: 42\n'
      '└child node C: TestTree#00000\n'
      '  foo:\n'
      '  multi\n'
      '  line\n'
      '  value!\n',
    );

    goldenStyleTest(
      'dashed',
      style: DiagnosticsTreeStyle.offstage,
      golden:
      'TestTree#00000\n'
      ' │ stringProperty1: value1\n'
      ' │ doubleProperty1: 42.5\n'
      ' │ roundedProperty: 0.3\n'
      ' │ nullProperty: null\n'
      ' │ <root node>\n'
      ' │\n'
      ' ╎╌child node A: TestTree#00000\n'
      ' ╎╌child node B: TestTree#00000\n'
      ' ╎ │ p1: v1\n'
      ' ╎ │ p2: v2\n'
      ' ╎ │\n'
      ' ╎ ╎╌child node B1: TestTree#00000\n'
      ' ╎ ╎╌child node B2: TestTree#00000\n'
      ' ╎ ╎   property1: value1\n'
      ' ╎ ╎\n'
      ' ╎ └╌child node B3: TestTree#00000\n'
      ' ╎     <leaf node>\n'
      ' ╎     foo: 42\n'
      ' ╎\n'
      ' └╌child node C: TestTree#00000\n'
      '     foo:\n'
      '     multi\n'
      '     line\n'
      '     value!\n',
    );

    goldenStyleTest(
      'leaf children',
      style: DiagnosticsTreeStyle.sparse,
      lastChildStyle: DiagnosticsTreeStyle.transition,
      golden:
      'TestTree#00000\n'
      ' │ stringProperty1: value1\n'
      ' │ doubleProperty1: 42.5\n'
      ' │ roundedProperty: 0.3\n'
      ' │ nullProperty: null\n'
      ' │ <root node>\n'
      ' │\n'
      ' ├─child node A: TestTree#00000\n'
      ' ├─child node B: TestTree#00000\n'
      ' │ │ p1: v1\n'
      ' │ │ p2: v2\n'
      ' │ │\n'
      ' │ ├─child node B1: TestTree#00000\n'
      ' │ ├─child node B2: TestTree#00000\n'
      ' │ │   property1: value1\n'
      ' │ │\n'
      ' │ ╘═╦══ child node B3 ═══\n'
      ' │   ║ TestTree#00000:\n'
      ' │   ║   <leaf node>\n'
      ' │   ║   foo: 42\n'
      ' │   ╚═══════════\n'
      ' ╘═╦══ child node C ═══\n'
      '   ║ TestTree#00000:\n'
      '   ║   foo:\n'
      '   ║   multi\n'
      '   ║   line\n'
      '   ║   value!\n'
      '   ╚═══════════\n',
    );

    // You would never really want to make everything a leaf child like this
    // but you can and still get a readable tree.
    // The joint between single and double lines here is a bit clunky
    // but we could correct that if there is any real use for this style.
    goldenStyleTest(
      'leaf',
      style: DiagnosticsTreeStyle.transition,
      golden:
      'TestTree#00000:\n'
      '  stringProperty1: value1\n'
      '  doubleProperty1: 42.5\n'
      '  roundedProperty: 0.3\n'
      '  nullProperty: null\n'
      '  <root node>\n'
      '  ╞═╦══ child node A ═══\n'
      '  │ ║ TestTree#00000\n'
      '  │ ╚═══════════\n'
      '  ╞═╦══ child node B ═══\n'
      '  │ ║ TestTree#00000:\n'
      '  │ ║   p1: v1\n'
      '  │ ║   p2: v2\n'
      '  │ ║   ╞═╦══ child node B1 ═══\n'
      '  │ ║   │ ║ TestTree#00000\n'
      '  │ ║   │ ╚═══════════\n'
      '  │ ║   ╞═╦══ child node B2 ═══\n'
      '  │ ║   │ ║ TestTree#00000:\n'
      '  │ ║   │ ║   property1: value1\n'
      '  │ ║   │ ╚═══════════\n'
      '  │ ║   ╘═╦══ child node B3 ═══\n'
      '  │ ║     ║ TestTree#00000:\n'
      '  │ ║     ║   <leaf node>\n'
      '  │ ║     ║   foo: 42\n'
      '  │ ║     ╚═══════════\n'
      '  │ ╚═══════════\n'
      '  ╘═╦══ child node C ═══\n'
      '    ║ TestTree#00000:\n'
      '    ║   foo:\n'
      '    ║   multi\n'
      '    ║   line\n'
      '    ║   value!\n'
      '    ╚═══════════\n',
    );

    goldenStyleTest(
      'whitespace',
      style: DiagnosticsTreeStyle.whitespace,
      golden:
        'TestTree#00000:\n'
        '  stringProperty1: value1\n'
        '  doubleProperty1: 42.5\n'
        '  roundedProperty: 0.3\n'
        '  nullProperty: null\n'
        '  <root node>\n'
        '  child node A: TestTree#00000\n'
        '  child node B: TestTree#00000:\n'
        '    p1: v1\n'
        '    p2: v2\n'
        '    child node B1: TestTree#00000\n'
        '    child node B2: TestTree#00000:\n'
        '      property1: value1\n'
        '    child node B3: TestTree#00000:\n'
        '      <leaf node>\n'
        '      foo: 42\n'
        '  child node C: TestTree#00000:\n'
        '    foo:\n'
        '    multi\n'
        '    line\n'
        '    value!\n',
    );

    // Single line mode does not display children.
    goldenStyleTest(
      'single line',
      style: DiagnosticsTreeStyle.singleLine,
      golden: 'TestTree#00000(stringProperty1: value1, doubleProperty1: 42.5, roundedProperty: 0.3, nullProperty: null, <root node>)',
    );

    // There isn't anything interesting for this case as the children look the
    // same with and without children. TODO(jacobr): this is an ugly test case.
    // only difference is odd not clearly desirable density of B3 being right
    // next to node C.
    goldenStyleTest(
      'single line last child',
      style: DiagnosticsTreeStyle.sparse,
      lastChildStyle: DiagnosticsTreeStyle.singleLine,
      golden:
      'TestTree#00000\n'
      ' │ stringProperty1: value1\n'
      ' │ doubleProperty1: 42.5\n'
      ' │ roundedProperty: 0.3\n'
      ' │ nullProperty: null\n'
      ' │ <root node>\n'
      ' │\n'
      ' ├─child node A: TestTree#00000\n'
      ' ├─child node B: TestTree#00000\n'
      ' │ │ p1: v1\n'
      ' │ │ p2: v2\n'
      ' │ │\n'
      ' │ ├─child node B1: TestTree#00000\n'
      ' │ ├─child node B2: TestTree#00000\n'
      ' │ │   property1: value1\n'
      ' │ │\n'
      ' │ └─child node B3: TestTree#00000(<leaf node>, foo: 42)\n'
      ' └─child node C: TestTree#00000(foo:\n'
      '   multi\n'
      '   line\n'
      '   value!)\n',
    );
  });

  test('transition test', () {
    // Test multiple styles integrating together in the same tree due to using
    // transition to go between styles that would otherwise be incompatible.
    final TestTree tree = new TestTree(
      style: DiagnosticsTreeStyle.sparse,
      properties: <DiagnosticsNode>[
        new StringProperty('stringProperty1', 'value1'),
      ],
      children: <TestTree>[
        new TestTree(
          style: DiagnosticsTreeStyle.transition,
          name: 'node transition',
          properties: <DiagnosticsNode>[
            new StringProperty('p1', 'v1'),
            new TestTree(
              properties: <DiagnosticsNode>[
                new DiagnosticsProperty<bool>('survived', true),
              ],
            ).toDiagnosticsNode(name: 'tree property', style: DiagnosticsTreeStyle.whitespace),
          ],
          children: <TestTree>[
            new TestTree(name: 'dense child', style: DiagnosticsTreeStyle.dense),
            new TestTree(
              name: 'dense',
              properties: <DiagnosticsNode>[new StringProperty('property1', 'value1')],
              style: DiagnosticsTreeStyle.dense,
            ),
            new TestTree(
              name: 'node B3',
              properties: <DiagnosticsNode>[
                new StringProperty('node_type', '<leaf node>', showName: false, quoted: false),
                new IntProperty('foo', 42),
              ],
              style: DiagnosticsTreeStyle.dense
            ),
          ],
        ),
        new TestTree(
          name: 'node C',
          properties: <DiagnosticsNode>[
            new StringProperty('foo', 'multi\nline\nvalue!', quoted: false),
          ],
          style: DiagnosticsTreeStyle.sparse,
        ),
      ],
    );

    expect(tree, hasAGoodToStringDeep);
    expect(
      tree.toDiagnosticsNode().toStringDeep(),
      equalsIgnoringHashCodes(
        'TestTree#00000\n'
        ' │ stringProperty1: "value1"\n'
        ' ╞═╦══ child node transition ═══\n'
        ' │ ║ TestTree#00000:\n'
        ' │ ║   p1: "v1"\n'
        ' │ ║   tree property: TestTree#00000:\n'
        ' │ ║     survived: true\n'
        ' │ ║   ├child dense child: TestTree#00000\n'
        ' │ ║   ├child dense: TestTree#00000\n'
        ' │ ║   │ property1: "value1"\n'
        ' │ ║   └child node B3: TestTree#00000\n'
        ' │ ║     <leaf node>\n'
        ' │ ║     foo: 42\n'
        ' │ ╚═══════════\n'
        ' └─child node C: TestTree#00000\n'
        '     foo:\n'
        '     multi\n'
        '     line\n'
        '     value!\n',
      ),
    );
  });

  test('describeEnum test', () {
    expect(describeEnum(ExampleEnum.hello), equals('hello'));
    expect(describeEnum(ExampleEnum.world), equals('world'));
    expect(describeEnum(ExampleEnum.deferToChild), equals('deferToChild'));
  });

  test('toHyphenedName test', () {
    expect(camelCaseToHyphenatedName(''), equals(''));
    expect(camelCaseToHyphenatedName('hello'), equals('hello'));
    expect(camelCaseToHyphenatedName('Hello'), equals('hello'));
    expect(camelCaseToHyphenatedName('HELLO'), equals('h-e-l-l-o'));
    expect(camelCaseToHyphenatedName('deferToChild'), equals('defer-to-child'));
    expect(camelCaseToHyphenatedName('DeferToChild'), equals('defer-to-child'));
    expect(camelCaseToHyphenatedName('helloWorld'), equals('hello-world'));
  });

  test('string property test', () {
    expect(
      new StringProperty('name', 'value', quoted: false).toString(),
      equals('name: value'),
    );

    expect(
      new StringProperty(
        'name',
        'value',
        description: 'VALUE',
        ifEmpty: '<hidden>',
        quoted: false,
      ).toString(),
      equals('name: VALUE'),
    );

    expect(
      new StringProperty(
        'name',
        'value',
        showName: false,
        ifEmpty: '<hidden>',
        quoted: false,
      ).toString(),
      equals('value'),
    );

    expect(
      new StringProperty('name', '', ifEmpty: '<hidden>').toString(),
      equals('name: <hidden>'),
    );

    expect(
      new StringProperty(
        'name',
        '',
        ifEmpty: '<hidden>',
        showName: false,
      ).toString(),
      equals('<hidden>'),
    );

    expect(new StringProperty('name', null).hidden, isFalse);
    expect(new StringProperty('name', 'value', hidden: true).hidden, isTrue);
    expect(new StringProperty('name', null, defaultValue: null).hidden, isTrue);
    expect(
      new StringProperty(
        'name',
        'value',
        quoted: true,
      ).toString(),
      equals('name: "value"'),
    );

    expect(
      new StringProperty('name', 'value', showName: false).toString(),
      equals('"value"'),
    );

    expect(
      new StringProperty(
        'name',
        null,
        showName: false,
        quoted: true,
      ).toString(),
      equals('null'),
    );
  });

  test('bool property test', () {
    final DiagnosticsProperty<bool> trueProperty = new DiagnosticsProperty<bool>('name', true);
    final DiagnosticsProperty<bool> falseProperty = new DiagnosticsProperty<bool>('name', false);
    expect(trueProperty.toString(), equals('name: true'));
    expect(trueProperty.hidden, isFalse);
    expect(trueProperty.value, isTrue);
    expect(falseProperty.toString(), equals('name: false'));
    expect(falseProperty.value, isFalse);
    expect(falseProperty.hidden, isFalse);
    expect(
      new DiagnosticsProperty<bool>(
        'name',
        true,
        description: 'truthy',
      ).toString(),
      equals('name: truthy'),
    );
    expect(
      new DiagnosticsProperty<bool>('name', true, showName: false).toString(),
      equals('true'),
    );

    expect(new DiagnosticsProperty<bool>('name', null).hidden, isFalse);
    expect(new DiagnosticsProperty<bool>('name', true, hidden: true).hidden, isTrue);
    expect(new DiagnosticsProperty<bool>('name', null, defaultValue: null).hidden, isTrue);
    expect(
      new DiagnosticsProperty<bool>('name', null, ifNull: 'missing').toString(),
      equals('name: missing'),
    );
  });

  test('flag property test', () {
    final FlagProperty trueFlag = new FlagProperty(
      'myFlag',
      value: true,
      ifTrue: 'myFlag',
    );
    final FlagProperty falseFlag = new FlagProperty(
      'myFlag',
      value: false,
      ifTrue: 'myFlag',
    );
    expect(trueFlag.toString(), equals('myFlag'));

    expect(trueFlag.value, isTrue);
    expect(falseFlag.value, isFalse);

    expect(trueFlag.hidden, isFalse);
    expect(falseFlag.hidden, isTrue);
  });

  test('property with tooltip test', () {
    final DiagnosticsProperty<String> withTooltip = new DiagnosticsProperty<String>(
      'name',
      'value',
      tooltip: 'tooltip',
    );
    expect(
     withTooltip.toString(),
      equals('name: value (tooltip)'),
    );
    expect(withTooltip.value, equals('value'));
    expect(withTooltip.hidden, isFalse);
  });

  test('double property test', () {
    final DoubleProperty doubleProperty = new DoubleProperty(
      'name',
      42.0,
    );
    expect(doubleProperty.toString(), equals('name: 42.0'));
    expect(doubleProperty.hidden, isFalse);
    expect(doubleProperty.value, equals(42.0));

    expect(new DoubleProperty('name', 1.3333).toString(), equals('name: 1.3'));

    expect(new DoubleProperty('name', null).toString(), equals('name: null'));
    expect(new DoubleProperty('name', null).hidden, equals(false));

    expect(
      new DoubleProperty('name', null, ifNull: 'missing').toString(),
      equals('name: missing'),
    );

    expect(
      new DoubleProperty('name', 42.0, unit: 'px',
      ).toString(),
      equals('name: 42.0px'),
    );
  });


  test('unsafe double property test', () {
    final DoubleProperty safe = new DoubleProperty.lazy(
      'name',
        () => 42.0,
    );
    expect(safe.toString(), equals('name: 42.0'));
    expect(safe.hidden, isFalse);
    expect(safe.value, equals(42.0));

    expect(
      new DoubleProperty.lazy('name', () => 1.3333).toString(),
      equals('name: 1.3'),
    );

    expect(
      new DoubleProperty.lazy('name', () => null).toString(),
      equals('name: null'),
    );
    expect(
      new DoubleProperty.lazy('name', () => null).hidden,
      equals(false),
    );

    final DoubleProperty throwingProperty = new DoubleProperty.lazy(
      'name',
      () => throw new FlutterError('Invalid constraints'),
    );
    // TODO(jacobr): it would be better if throwingProperty.object threw an
    // exception.
    expect(throwingProperty.value, isNull);
    expect(throwingProperty.hidden, isFalse);
    expect(
      throwingProperty.toString(),
      equals('name: EXCEPTION (FlutterError)'),
    );
  });

  test('percent property', () {
    expect(
      new PercentProperty('name', 0.4).toString(),
      equals('name: 40.0%'),
    );

    expect(
      new PercentProperty('name', 0.99, unit: 'invisible', tooltip: 'almost transparent').toString(),
      equals('name: 99.0% invisible (almost transparent)'),
    );

    expect(
      new PercentProperty('name', null, unit: 'invisible', tooltip: '!').toString(),
      equals('name: null (!)'),
    );

    expect(
      new PercentProperty('name', 0.4).value,
      0.4,
    );
    expect(
      new PercentProperty('name', 0.0).toString(),
      equals('name: 0.0%'),
    );
    expect(
      new PercentProperty('name', -10.0).toString(),
      equals('name: 0.0%'),
    );
    expect(
      new PercentProperty('name', 1.0).toString(),
      equals('name: 100.0%'),
    );
    expect(
      new PercentProperty('name', 3.0).toString(),
      equals('name: 100.0%'),
    );
    expect(
      new PercentProperty('name', null).toString(),
      equals('name: null'),
    );
    expect(
      new PercentProperty(
        'name',
        null,
        ifNull: 'missing',
      ).toString(),
      equals('name: missing'),
    );
    expect(
      new PercentProperty(
        'name',
        null,
        ifNull: 'missing',
        showName: false,
      ).toString(),
      equals('missing'),
    );
    expect(
      new PercentProperty(
        'name',
        0.5,
        showName: false,
      ).toString(),
      equals('50.0%'),
    );
  });

  test('callback property test', () {
    final Function onClick = () {};
    final ObjectFlagProperty<Function> present = new ObjectFlagProperty<Function>(
      'onClick',
      onClick,
      ifPresent: 'clickable',
    );
    final ObjectFlagProperty<Function> missing = new ObjectFlagProperty<Function>(
      'onClick',
      null,
      ifPresent: 'clickable',
    );

    expect(present.toString(), equals('clickable'));
    expect(present.hidden, isFalse);
    expect(present.value, equals(onClick));
    expect(missing.toString(), equals(''));
    expect(missing.hidden, isTrue);
  });

  test('missing callback property test', () {
    final Function onClick = () {};
    final ObjectFlagProperty<Function> present = new ObjectFlagProperty<Function>(
      'onClick',
      onClick,
      ifNull: 'disabled',
    );
    final ObjectFlagProperty<Function> missing = new ObjectFlagProperty<Function>(
      'onClick',
      null,
      ifNull: 'disabled',
    );

    expect(present.toString(), equals(''));
    expect(present.hidden, isTrue);
    expect(present.value, equals(onClick));
    expect(missing.toString(), equals('disabled'));
    expect(missing.hidden, isFalse);
  });

  test('describe bool property', () {
    final FlagProperty yes = new FlagProperty(
      'name',
      value: true,
      ifTrue: 'YES',
      ifFalse: 'NO',
      showName: true,
    );
    final FlagProperty no = new FlagProperty(
      'name',
      value: false,
      ifTrue: 'YES',
      ifFalse: 'NO',
      showName: true,
    );
    expect(yes.toString(), equals('name: YES'));
    expect(yes.hidden, isFalse);
    expect(yes.value, isTrue);
    expect(no.toString(), equals('name: NO'));
    expect(no.hidden, isFalse);
    expect(no.value, isFalse);

    expect(
      new FlagProperty(
        'name',
        value: true,
        ifTrue: 'YES',
        ifFalse: 'NO',
      ).toString(),
      equals('YES'),
    );

    expect(
      new FlagProperty(
        'name',
        value: false,
        ifTrue: 'YES',
        ifFalse: 'NO',
      ).toString(),
      equals('NO'),
    );

    expect(
      new FlagProperty(
        'name',
        value: true,
        ifTrue: 'YES',
        ifFalse: 'NO',
        hidden: true,
        showName: true,
      ).hidden,
      isTrue,
    );
  });

  test('enum property test', () {
    final EnumProperty<ExampleEnum> hello = new EnumProperty<ExampleEnum>(
      'name',
      ExampleEnum.hello,
    );
    final EnumProperty<ExampleEnum> world = new EnumProperty<ExampleEnum>(
      'name',
      ExampleEnum.world,
    );
    final EnumProperty<ExampleEnum> deferToChild = new EnumProperty<ExampleEnum>(
      'name',
      ExampleEnum.deferToChild,
    );
    final EnumProperty<ExampleEnum> nullEnum = new EnumProperty<ExampleEnum>(
      'name',
      null,
    );
    expect(hello.hidden, isFalse);
    expect(hello.value, equals(ExampleEnum.hello));
    expect(hello.toString(), equals('name: hello'));

    expect(world.hidden, isFalse);
    expect(world.value, equals(ExampleEnum.world));
    expect(world.toString(), equals('name: world'));

    expect(deferToChild.hidden, isFalse);
    expect(deferToChild.value, equals(ExampleEnum.deferToChild));
    expect(deferToChild.toString(), equals('name: defer-to-child'));

    expect(nullEnum.hidden, isFalse);
    expect(nullEnum.value, isNull);
    expect(nullEnum.toString(), equals('name: null'));

    final EnumProperty<ExampleEnum> matchesDefault = new EnumProperty<ExampleEnum>(
      'name',
      ExampleEnum.hello,
      defaultValue: ExampleEnum.hello,
    );
    expect(matchesDefault.toString(), equals('name: hello'));
    expect(matchesDefault.value, equals(ExampleEnum.hello));
    expect(matchesDefault.hidden, isTrue);


    expect(
      new EnumProperty<ExampleEnum>(
        'name',
        ExampleEnum.hello,
        hidden: true,
      ).hidden,
      isTrue,
    );
  });

  test('int property test', () {
    final IntProperty regular = new IntProperty(
      'name',
      42,
    );
    expect(regular.toString(), equals('name: 42'));
    expect(regular.value, equals(42));
    expect(regular.hidden, isFalse);

    final IntProperty nullValue = new IntProperty(
      'name',
      null,
    );
    expect(nullValue.toString(), equals('name: null'));
    expect(nullValue.value, isNull);
    expect(nullValue.hidden, isFalse);

    final IntProperty hideNull = new IntProperty(
      'name',
      null,
      defaultValue: null
    );
    expect(hideNull.toString(), equals('name: null'));
    expect(hideNull.value, isNull);
    expect(hideNull.hidden, isTrue);

    final IntProperty nullDescription = new IntProperty(
      'name',
      null,
      ifNull: 'missing',
    );
    expect(nullDescription.toString(), equals('name: missing'));
    expect(nullDescription.value, isNull);
    expect(nullDescription.hidden, isFalse);

    final IntProperty hideName = new IntProperty(
      'name',
      42,
      showName: false,
    );
    expect(hideName.toString(), equals('42'));
    expect(hideName.value, equals(42));
    expect(hideName.hidden, isFalse);

    final IntProperty withUnit = new IntProperty(
      'name',
      42,
      unit: 'pt',
    );
    expect(withUnit.toString(), equals('name: 42pt'));
    expect(withUnit.value, equals(42));
    expect(withUnit.hidden, isFalse);

    final IntProperty defaultValue = new IntProperty(
      'name',
      42,
      defaultValue: 42,
    );
    expect(defaultValue.toString(), equals('name: 42'));
    expect(defaultValue.value, equals(42));
    expect(defaultValue.hidden, isTrue);

    final IntProperty notDefaultValue = new IntProperty(
      'name',
      43,
      defaultValue: 42,
    );
    expect(notDefaultValue.toString(), equals('name: 43'));
    expect(notDefaultValue.value, equals(43));
    expect(notDefaultValue.hidden, isFalse);

    final IntProperty hidden = new IntProperty(
      'name',
      42,
      hidden: true,
    );
    expect(hidden.toString(), equals('name: 42'));
    expect(hidden.value, equals(42));
    expect(hidden.hidden, isTrue);
  });

  test('object property test', () {
    final Rect rect = new Rect.fromLTRB(0.0, 0.0, 20.0, 20.0);
    final DiagnosticsNode simple = new DiagnosticsProperty<Rect>(
      'name',
      rect,
    );
    expect(simple.value, equals(rect));
    expect(simple.hidden, isFalse);
    expect(simple.toString(), equals('name: Rect.fromLTRB(0.0, 0.0, 20.0, 20.0)'));

    final DiagnosticsNode withDescription = new DiagnosticsProperty<Rect>(
      'name',
      rect,
      description: 'small rect',
    );
    expect(withDescription.value, equals(rect));
    expect(withDescription.hidden, isFalse);
    expect(withDescription.toString(), equals('name: small rect'));

    final DiagnosticsProperty<Object> nullProperty = new DiagnosticsProperty<Object>(
      'name',
      null,
    );
    expect(nullProperty.value, isNull);
    expect(nullProperty.hidden, isFalse);
    expect(nullProperty.toString(), equals('name: null'));

    final DiagnosticsProperty<Object> hideNullProperty = new DiagnosticsProperty<Object>(
      'name',
      null,
      defaultValue: null,
    );
    expect(hideNullProperty.value, isNull);
    expect(hideNullProperty.hidden, isTrue);
    expect(hideNullProperty.toString(), equals('name: null'));

    final DiagnosticsNode nullDescription = new DiagnosticsProperty<Object>(
      'name',
      null,
      ifNull: 'missing',
    );
    expect(nullDescription.value, isNull);
    expect(nullDescription.hidden, isFalse);
    expect(nullDescription.toString(), equals('name: missing'));

    final DiagnosticsProperty<Rect> hideName = new DiagnosticsProperty<Rect>(
      'name',
      rect,
      showName: false,
    );
    expect(hideName.value, equals(rect));
    expect(hideName.hidden, isFalse);
    expect(hideName.toString(), equals('Rect.fromLTRB(0.0, 0.0, 20.0, 20.0)'));

    final DiagnosticsProperty<Rect> hideSeparator = new DiagnosticsProperty<Rect>(
      'Creator',
      rect,
      showSeparator: false,
    );
    expect(hideSeparator.value, equals(rect));
    expect(hideSeparator.hidden, isFalse);
    expect(
      hideSeparator.toString(),
      equals('Creator Rect.fromLTRB(0.0, 0.0, 20.0, 20.0)'),
    );
  });

  test('lazy object property test', () {
    final Rect rect = new Rect.fromLTRB(0.0, 0.0, 20.0, 20.0);
    final DiagnosticsNode simple = new DiagnosticsProperty<Rect>.lazy(
      'name',
      () => rect,
      description: 'small rect',
    );
    expect(simple.value, equals(rect));
    expect(simple.hidden, isFalse);
    expect(simple.toString(), equals('name: small rect'));

    final DiagnosticsNode nullProperty = new DiagnosticsProperty<Object>.lazy(
      'name',
      () => null,
      description: 'missing',
    );
    expect(nullProperty.value, isNull);
    expect(nullProperty.hidden, isFalse);
    expect(nullProperty.toString(), equals('name: missing'));

    final DiagnosticsNode hideNullProperty = new DiagnosticsProperty<Object>.lazy(
      'name',
      () => null,
      description: 'missing',
      defaultValue: null,
    );
    expect(hideNullProperty.value, isNull);
    expect(hideNullProperty.hidden, isTrue);
    expect(hideNullProperty.toString(), equals('name: missing'));

    final DiagnosticsNode hideName = new DiagnosticsProperty<Rect>.lazy(
      'name',
      () => rect,
      description: 'small rect',
      showName: false,
    );
    expect(hideName.value, equals(rect));
    expect(hideName.hidden, isFalse);
    expect(hideName.toString(), equals('small rect'));

    final DiagnosticsProperty<Object> throwingWithDescription = new DiagnosticsProperty<Object>.lazy(
      'name',
      () => throw new FlutterError('Property not available'),
      description: 'missing',
      defaultValue: null,
    );
    expect(throwingWithDescription.value, isNull);
    expect(throwingWithDescription.exception, isFlutterError);
    expect(throwingWithDescription.hidden, false);
    expect(throwingWithDescription.toString(), equals('name: missing'));

    final DiagnosticsProperty<Object> throwingProperty = new DiagnosticsProperty<Object>.lazy(
      'name',
      () => throw new FlutterError('Property not available'),
      defaultValue: null,
    );
    expect(throwingProperty.value, isNull);
    expect(throwingProperty.exception, isFlutterError);
    expect(throwingProperty.hidden, false);
    expect(throwingProperty.toString(), equals('name: EXCEPTION (FlutterError)'));

  });

  test('color property test', () {
    // Add more tests if colorProperty becomes more than a wrapper around
    // objectProperty.
    final Color color = const Color.fromARGB(255, 255, 255, 255);
    final DiagnosticsProperty<Color> simple = new DiagnosticsProperty<Color>(
      'name',
      color,
    );
    expect(simple.hidden, isFalse);
    expect(simple.value, equals(color));
    expect(simple.toString(), equals('name: Color(0xffffffff)'));
  });

  test('flag property test', () {
    final FlagProperty show = new FlagProperty(
      'wasLayout',
      value: true,
      ifTrue: 'layout computed',
    );
    expect(show.name, equals('wasLayout'));
    expect(show.value, isTrue);
    expect(show.hidden, isFalse);
    expect(show.toString(), equals('layout computed'));

    final FlagProperty hide = new FlagProperty(
      'wasLayout',
      value: false,
      ifTrue: 'layout computed',
    );
    expect(hide.name, equals('wasLayout'));
    expect(hide.value, isFalse);
    expect(hide.hidden, isTrue);
    expect(hide.toString(), equals(''));
  });

  test('has property test', () {
    final Function onClick = () {};
    final ObjectFlagProperty<Function> has = new ObjectFlagProperty<Function>.has(
      'onClick',
      onClick,
    );
    expect(has.name, equals('onClick'));
    expect(has.value, equals(onClick));
    expect(has.hidden, isFalse);
    expect(has.toString(), equals('has onClick'));

    final ObjectFlagProperty<Function> missing = new ObjectFlagProperty<Function>.has(
      'onClick',
      null,
    );
    expect(missing.name, equals('onClick'));
    expect(missing.value, isNull);
    expect(missing.hidden, isTrue);
    expect(missing.toString(), equals(''));
  });

  test('iterable property test', () {
    final List<int> ints = <int>[1,2,3];
    final IterableProperty<int> intsProperty = new IterableProperty<int>(
      'ints',
      ints,
    );
    expect(intsProperty.value, equals(ints));
    expect(intsProperty.hidden, isFalse);
    expect(intsProperty.toString(), equals('ints: 1, 2, 3'));

    final IterableProperty<Object> emptyProperty = new IterableProperty<Object>(
      'name',
      <Object>[],
    );
    expect(emptyProperty.value, isEmpty);
    expect(emptyProperty.hidden, isFalse);
    expect(emptyProperty.toString(), equals('name: []'));

    final IterableProperty<Object> nullProperty = new IterableProperty<Object>(
      'list',
      null,
    );
    expect(nullProperty.value, isNull);
    expect(nullProperty.hidden, isFalse);
    expect(nullProperty.toString(), equals('list: null'));

    final IterableProperty<Object> hideNullProperty = new IterableProperty<Object>(
      'list',
      null,
      defaultValue: null,
    );
    expect(hideNullProperty.value, isNull);
    expect(hideNullProperty.hidden, isTrue);
    expect(hideNullProperty.toString(), equals('list: null'));

    final List<Object> objects = <Object>[
      new Rect.fromLTRB(0.0, 0.0, 20.0, 20.0),
      const Color.fromARGB(255, 255, 255, 255),
    ];
    final IterableProperty<Object> objectsProperty = new IterableProperty<Object>(
      'objects',
      objects,
    );
    expect(objectsProperty.value, equals(objects));
    expect(objectsProperty.hidden, isFalse);
    expect(
      objectsProperty.toString(),
      equals('objects: Rect.fromLTRB(0.0, 0.0, 20.0, 20.0), Color(0xffffffff)'),
    );
    expect(
      objectsProperty.toStringDeep(),
      equals('objects: Rect.fromLTRB(0.0, 0.0, 20.0, 20.0), Color(0xffffffff)'),
    );

    final IterableProperty<Object> multiLineProperty = new IterableProperty<Object>(
      'objects',
      objects,
      style: DiagnosticsTreeStyle.whitespace,
    );
    expect(multiLineProperty.value, equals(objects));
    expect(multiLineProperty.hidden, isFalse);
    expect(
      multiLineProperty.toString(),
      equals(
        'objects:\n'
        'Rect.fromLTRB(0.0, 0.0, 20.0, 20.0)\n'
        'Color(0xffffffff)',
      ),
    );
    expect(
      multiLineProperty.toStringDeep(),
      equals(
        'objects:\n'
        '  Rect.fromLTRB(0.0, 0.0, 20.0, 20.0)\n'
        '  Color(0xffffffff)\n',
      ),
    );

    expect(
      new TestTree(
        name: 'root',
        properties: <DiagnosticsNode>[multiLineProperty],
      ).toStringDeep(),
      equalsIgnoringHashCodes(
        'TestTree#00000\n'
        '   objects:\n'
        '     Rect.fromLTRB(0.0, 0.0, 20.0, 20.0)\n'
        '     Color(0xffffffff)\n',
      ),
    );

    // Iterable with a single entry. Verify that rendering is sensible and that
    // multi line rendering isn't used even though it is not helpful.
    final List<Object> singleElementList = <Object>[const Color.fromARGB(255, 255, 255, 255)];

    final IterableProperty<Object> objectProperty = new IterableProperty<Object>(
      'object',
      singleElementList,
      style: DiagnosticsTreeStyle.whitespace,
    );
    expect(objectProperty.value, equals(singleElementList));
    expect(objectProperty.hidden, isFalse);
    expect(
      objectProperty.toString(),
      equals('object: Color(0xffffffff)'),
    );
    expect(
      objectProperty.toStringDeep(),
      equals('object: Color(0xffffffff)\n'),
    );
    expect(
      new TestTree(
        name: 'root',
        properties: <DiagnosticsNode>[objectProperty],
      ).toStringDeep(),
      equalsIgnoringHashCodes(
        'TestTree#00000\n'
        '   object: Color(0xffffffff)\n',
      ),
    );
  });

  test('message test', () {
    final DiagnosticsNode message = new DiagnosticsNode.message('hello world');
    expect(message.toString(), equals('hello world'));
    expect(message.name, isEmpty);
    expect(message.value, isNull);
    expect(message.showName, isFalse);

    final DiagnosticsNode messageProperty = new MessageProperty('diagnostics', 'hello world');
    expect(messageProperty.toString(), equals('diagnostics: hello world'));
    expect(messageProperty.name, equals('diagnostics'));
    expect(messageProperty.value, isNull);
    expect(messageProperty.showName, isTrue);

  });
}
