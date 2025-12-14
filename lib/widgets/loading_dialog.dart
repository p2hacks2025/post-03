import 'package:flutter/material.dart';

class LoadingDialog {
  static bool _isShowing = false;

  /// 表示
  static void show(BuildContext context, {String message = '処理中...'}) {
    if (_isShowing) return; // 二重表示防止
    _isShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false, // 戻る操作を無効化
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 非表示
  static void hide(BuildContext context) {
    if (_isShowing && Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    _isShowing = false;
  }
}
