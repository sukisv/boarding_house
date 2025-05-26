import 'package:flutter/material.dart';
import 'package:mobile_application/components/custom_button.dart';

class ButtonGroupComponent extends StatelessWidget {
  final List<Widget> children;
  const ButtonGroupComponent({required this.children, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }
}
