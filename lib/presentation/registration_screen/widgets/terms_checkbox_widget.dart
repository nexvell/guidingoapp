import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Terms and privacy policy checkbox with linked text
class TermsCheckboxWidget extends StatelessWidget {
  final bool isAccepted;
  final ValueChanged<bool?> onChanged;

  const TermsCheckboxWidget({
    super.key,
    required this.isAccepted,
    required this.onChanged,
  });

  void _openInAppBrowser(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(url)),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 6.w,
          height: 6.w,
          child: Checkbox(
            value: isAccepted,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 0.3.h),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Accetto i '),
                  TextSpan(
                    text: 'Termini di Servizio',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _openInAppBrowser(
                        context,
                        'https://www.example.com/terms',
                        'Termini di Servizio',
                      ),
                  ),
                  const TextSpan(text: ' e la '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _openInAppBrowser(
                        context,
                        'https://www.example.com/privacy',
                        'Privacy Policy',
                      ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
