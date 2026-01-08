import 'package:flutter/material.dart';

/// 개선된 로딩 다이얼로그
class LoadingDialog extends StatelessWidget {
  final String message;
  final double? progress;
  final VoidCallback? onCancel;
  final bool isDismissible;

  const LoadingDialog({
    super.key,
    required this.message,
    this.progress,
    this.onCancel,
    this.isDismissible = false,
  });

  /// 다이얼로그 표시
  static Future<void> show(
    BuildContext context, {
    required String message,
    double? progress,
    VoidCallback? onCancel,
    bool isDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => LoadingDialog(
        message: message,
        progress: progress,
        onCancel: onCancel,
        isDismissible: isDismissible,
      ),
    );
  }

  /// 다이얼로그 닫기
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isDismissible,
      child: AlertDialog(
        backgroundColor: const Color(0xFF2a1520),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (progress != null) ...[
              CircularProgressIndicator(
                value: progress,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                '${(progress! * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ],
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
                child: const Text(
                  '취소',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 진행률이 있는 로딩 다이얼로그
class ProgressLoadingDialog extends StatefulWidget {
  final String message;
  final Stream<double>? progressStream;
  final VoidCallback? onCancel;

  const ProgressLoadingDialog({
    super.key,
    required this.message,
    this.progressStream,
    this.onCancel,
  });

  @override
  State<ProgressLoadingDialog> createState() => _ProgressLoadingDialogState();
}

class _ProgressLoadingDialogState extends State<ProgressLoadingDialog> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.progressStream != null) {
      widget.progressStream!.listen((progress) {
        if (mounted) {
          setState(() {
            _progress = progress;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2a1520),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            value: widget.progressStream != null ? _progress : null,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          if (widget.progressStream != null)
            Text(
              '${(_progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            widget.message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.onCancel != null) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCancel?.call();
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
