import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:opus_mobile/core/api/api_exception.dart';
import 'package:opus_mobile/core/theme/opus_colors.dart';
import 'package:opus_mobile/core/theme/opus_spacing.dart';
import 'package:opus_mobile/core/theme/opus_text_styles.dart';
import 'package:opus_mobile/features/auth/services/auth_service.dart';

const int _otpLength = 6;
const int _resendCooldownSeconds = 60;

class OtpVerificationScreen extends StatefulWidget {
  final String phone;

  const OtpVerificationScreen({super.key, required this.phone});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _authService = AuthService();

  // One controller + focus node per OTP digit box.
  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = _resendCooldownSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Auto-focus first field after frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Countdown helpers
  // ---------------------------------------------------------------------------

  void _startCountdown() {
    _resendCountdown = _resendCooldownSeconds;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  // ---------------------------------------------------------------------------
  // OTP code helpers
  // ---------------------------------------------------------------------------

  String get _currentCode =>
      _controllers.map((c) => c.text).join();

  bool get _isCodeComplete => _currentCode.length == _otpLength;

  void _clearCode() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isEmpty) return;

    // Move focus forward.
    if (index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      // Last digit filled — dismiss keyboard and auto-submit.
      _focusNodes[index].unfocus();
      if (_isCodeComplete && !_isLoading) {
        _submit();
      }
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  // ---------------------------------------------------------------------------
  // API calls
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    if (!_isCodeComplete || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final response =
          await _authService.verifyOtp(widget.phone, _currentCode);
      await _authService.saveTokens(response.token, response.refreshToken);

      if (!mounted) return;

      if (response.isNewUser) {
        context.go('/profile/onboarding');
      } else {
        context.go('/gombos');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
      _clearCode();
    } catch (_) {
      if (!mounted) return;
      _showError('Une erreur inattendue est survenue. Veuillez réessayer.');
      _clearCode();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      await _authService.sendOtp(widget.phone);
      if (!mounted) return;
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code renvoyé avec succès.'),
          backgroundColor: OpusColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Impossible de renvoyer le code. Veuillez réessayer.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: OpusColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpusColors.blancChaux,
      appBar: AppBar(
        backgroundColor: OpusColors.blancChaux,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'OPUS',
          style: OpusTextStyles.h2.copyWith(
            color: OpusColors.indigoBache,
            letterSpacing: 4,
          ),
        ),
        leading: BackButton(color: OpusColors.indigoBache),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: OpusSpacing.lg,
              vertical: OpusSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vérification',
                  style: OpusTextStyles.h1.copyWith(
                    color: OpusColors.indigoBache,
                  ),
                ),
                const SizedBox(height: OpusSpacing.sm),
                RichText(
                  text: TextSpan(
                    style: OpusTextStyles.body.copyWith(
                      color: OpusColors.betonBrut,
                    ),
                    children: [
                      const TextSpan(
                          text: 'Code envoyé au\n'),
                      TextSpan(
                        text: widget.phone,
                        style: OpusTextStyles.body.copyWith(
                          color: OpusColors.indigoBache,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: OpusSpacing.xxl),
                // OTP digit boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_otpLength, (index) {
                    return _OtpDigitBox(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      onChanged: (value) => _onDigitChanged(index, value),
                      onKeyEvent: (event) => _onKeyEvent(index, event),
                      enabled: !_isLoading,
                    );
                  }),
                ),
                const SizedBox(height: OpusSpacing.xl),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        (_isCodeComplete && !_isLoading) ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OpusColors.rougeEnseigne,
                      disabledBackgroundColor:
                          OpusColors.rougeEnseigne.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(OpusSpacing.sm),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Vérifier',
                            style: OpusTextStyles.button,
                          ),
                  ),
                ),
                const SizedBox(height: OpusSpacing.lg),
                // Resend button / countdown
                Center(
                  child: _resendCountdown > 0
                      ? Text(
                          'Renvoyer dans ${_resendCountdown}s',
                          style: OpusTextStyles.body.copyWith(
                            color: OpusColors.betonBrut,
                          ),
                        )
                      : TextButton(
                          onPressed: _isResending ? null : _resendCode,
                          child: _isResending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: OpusColors.indigoBache,
                                  ),
                                )
                              : Text(
                                  'Renvoyer le code',
                                  style: OpusTextStyles.body.copyWith(
                                    color: OpusColors.indigoBache,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: OpusColors.indigoBache,
                                  ),
                                ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single OTP digit box widget
// ---------------------------------------------------------------------------

class _OtpDigitBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;
  final bool enabled;

  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyEvent,
      child: SizedBox(
        width: 44,
        height: 56,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          onChanged: onChanged,
          style: OpusTextStyles.h2.copyWith(
            color: OpusColors.indigoBache,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: enabled ? Colors.white : OpusColors.blancChaux,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(OpusSpacing.sm),
              borderSide: BorderSide(
                color: OpusColors.indigoBache.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(OpusSpacing.sm),
              borderSide: BorderSide(
                color: OpusColors.indigoBache.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(OpusSpacing.sm),
              borderSide: const BorderSide(
                color: OpusColors.indigoBache,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(OpusSpacing.sm),
              borderSide: BorderSide(
                color: OpusColors.indigoBache.withValues(alpha: 0.15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
