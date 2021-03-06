// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'calculator_logic.dart';

class Calculator extends StatefulWidget {
  Calculator({Key key}) : super(key: key);

  static const String routeName = '/calculator';

  @override
  _CalculatorState createState() => new _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  /// As the user taps keys we update the current `_expression` and we also
  /// keep a stack of previous expressions so we can return to earlier states
  /// when the user hits the DEL key.
  final List<CalcExpression> _expressionStack = <CalcExpression>[];
  CalcExpression _expression = new CalcExpression.Empty();

  // Make `expression` the current expression and push the previous current
  // expression onto the stack.
  void pushExpression(CalcExpression expression) {
    _expressionStack.add(_expression);
    _expression = expression;
  }

  /// Pop the top expression off of the stack and make it the current expression.
  void popCalcExpression() {
    if (_expressionStack.length > 0) {
      _expression = _expressionStack.removeLast();
    } else {
      _expression = new CalcExpression.Empty();
    }
  }

  /// Set `resultExpression` to the currrent expression and clear the stack.
  void setResult(CalcExpression resultExpression) {
    _expressionStack.clear();
    _expression = resultExpression;
  }

  void handleNumberTap(int n) {
    final CalcExpression expression = _expression.appendDigit(n);
    if (expression != null) {
      setState(() {
        pushExpression(expression);
      });
    }
  }

  void handlePointTap() {
    final CalcExpression expression = _expression.appendPoint();
    if (expression != null) {
      setState(() {
        pushExpression(expression);
      });
    }
  }

  void handlePlusTap() {
    final CalcExpression expression = _expression.appendOperation(Operation.Addition);
    if (expression != null) {
      setState(() {
        pushExpression(expression);
      });
    }
  }

  void handleMinusTap() {
    final CalcExpression expression = _expression.appendMinus();
    if (expression != null) {
      setState(() {
        pushExpression(expression);
      });
    }
  }

  void handleMultTap() {
    final CalcExpression expression = _expression.appendOperation(Operation.Multiplication);
    if (expression != null) {
      setState(() {
        pushExpression(expression);
      });
    }
  }

  void handleDivTap() {
    final CalcExpression expression = _expression.appendOperation(Operation.Division);
    if (expression != null) {
      setState(() {
        pushExpression(expression);
      });
    }
  }

  void handleEqualsTap() {
    final CalcExpression resultExpression = _expression.computeResult();
    if (resultExpression != null) {
      setState(() {
        setResult(resultExpression);
      });
    }
  }

  void handleDelTap() {
    setState(() {
      popCalcExpression();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Calculator')),
      body: new Column(
        children: <Widget>[
          // Give the key-pad 3/5 of the vertical space and the display 2/5.
          new CalcDisplay(2, _expression.toString()),
          new Divider(height: 1.0),
          new KeyPad(3, calcState: this)
        ]
      )
    );
  }
}

class CalcDisplay extends StatelessWidget {
  CalcDisplay(this._flex, this._contents);

  final int _flex;
  final String _contents;

  @override
  Widget build(BuildContext context) {
    return new Flexible(
      flex: _flex,
      child: new Center(
        child: new Text(
          _contents,
          style: const TextStyle(fontSize: 24.0)
        )
      )
    );
  }
}

class KeyPad extends StatelessWidget {
  KeyPad(this._flex, {this.calcState});

  final int _flex;
  final _CalculatorState calcState;

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark
      ),
      child: new Flexible(
        flex: _flex,
        child: new Material(
          child: new Row(
            children: <Widget>[
              new MainKeyPad(calcState: calcState),
              new OpKeyPad(calcState: calcState),
            ]
          )
        )
      )
    );
  }
}

class MainKeyPad extends StatelessWidget {
  MainKeyPad({this.calcState});

  final _CalculatorState calcState;

  @override
  Widget build(BuildContext context) {
    return new Flexible(
      // We set flex equal to the number of columns so that the main keypad
      // and the op keypad have sizes proportional to their number of
      // columns.
      flex: 3,
      child: new Column(
        children: <Widget>[
          new KeyRow(<Widget>[
            new NumberKey(7, calcState),
            new NumberKey(8, calcState),
            new NumberKey(9, calcState)
          ]),
          new KeyRow(<Widget>[
            new NumberKey(4, calcState),
            new NumberKey(5, calcState),
            new NumberKey(6, calcState)
          ]),
          new KeyRow(<Widget>[
            new NumberKey(1, calcState),
            new NumberKey(2, calcState),
            new NumberKey(3, calcState)
          ]),
          new KeyRow(<Widget>[
            new CalcKey('.', calcState.handlePointTap),
            new NumberKey(0, calcState),
            new CalcKey('=', calcState.handleEqualsTap),
          ])
        ]
      )
    );
  }
}

class OpKeyPad extends StatelessWidget {
  OpKeyPad({this.calcState});

  final _CalculatorState calcState;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return new Flexible(
      child: new Material(
        color: themeData.backgroundColor,
        child: new Column(
          children: <Widget>[
            new CalcKey('\u232B', calcState.handleDelTap),
            new CalcKey('\u00F7', calcState.handleDivTap),
            new CalcKey('\u00D7', calcState.handleMultTap),
            new CalcKey('-', calcState.handleMinusTap),
            new CalcKey('+', calcState.handlePlusTap)
          ]
        )
      )
    );
  }
}

class KeyRow extends StatelessWidget {
  KeyRow(this.keys);

  final List<Widget> keys;

  @override
  Widget build(BuildContext context) {
    return new Flexible(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center, children: this.keys
      )
    );
  }
}

class CalcKey extends StatelessWidget {
  CalcKey(this.text, this.onTap);

  final String text;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return new Flexible(
      child: new InkResponse(
        onTap: this.onTap,
        child: new Center(
          child: new Text(
            this.text,
            style: new TextStyle(
              fontSize: (orientation == Orientation.portrait) ? 32.0 : 24.0
            )
          )
        )
      )
    );
  }
}

class NumberKey extends CalcKey {
  NumberKey(int value, _CalculatorState calcState)
    : super('$value', () {
        calcState.handleNumberTap(value);
      });
}
