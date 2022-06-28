import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Adaptive Progress Indicator for iOS and Android / Fuschia
class AdaptiveProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? CupertinoActivityIndicator(
            color: Colors.white,
          )
        : CircularProgressIndicator(
            color: Colors.white,
          );
  }
}

/// ProgressIndicator with non dismissible ModalBarrier
class BarrierProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
            opacity: 0.5,
            child: const ModalBarrier(dismissible: false, color: Colors.grey)),
        Center(child: AdaptiveProgressIndicator())
      ],
    );
  }
}
