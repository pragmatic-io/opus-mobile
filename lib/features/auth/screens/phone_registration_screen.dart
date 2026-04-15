import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:opus_mobile/core/api/api_exception.dart';
import 'package:opus_mobile/core/theme/opus_colors.dart';
import 'package:opus_mobile/core/theme/opus_spacing.dart';
import 'package:opus_mobile/core/theme/opus_text_styles.dart';
import 'package:opus_mobile/features/auth/services/auth_service.dart';

class PhoneRegistrationScreen extends StatefulWidget {
  const PhoneRegistrationScreen({super.key});

  @override
  State<PhoneRegistrationScreen> createState() =>
      _PhoneRegistrationScreenState();
}

class _PhoneRegistrationScreenState extends State<PhoneRegistrationScreen> {
  static const String _countryCode = '+225';

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  String get _fullPhone => '$_countryCode${_phoneController.text.trim()}';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.sendOtp(_fullPhone);
      if (!mounted) return;
      context.push('/auth/otp', extra: _fullPhone);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Une erreur inattendue est survenue. Veuillez réessayer.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: OpusSpacing.lg,
              vertical: OpusSpacing.xl,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Votre numéro',
                    style: OpusTextStyles.h1.copyWith(
                      color: OpusColors.indigoBache,
                    ),
                  ),
                  const SizedBox(height: OpusSpacing.sm),
                  Text(
                    'Entrez votre numéro de téléphone pour recevoir un code de vérification.',
                    style: OpusTextStyles.body.copyWith(
                      color: OpusColors.betonBrut,
                    ),
                  ),
                  const SizedBox(height: OpusSpacing.xxl),
                  Text(
                    'NUMÉRO DE TÉLÉPHONE',
                    style: OpusTextStyles.caption.copyWith(
                      color: OpusColors.indigoBache,
                    ),
                  ),
                  const SizedBox(height: OpusSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Country code prefix chip (non-editable)
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(
                          horizontal: OpusSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: OpusColors.indigoBache.withValues(alpha: 0.08),
                          border: Border.all(
                            color: OpusColors.indigoBache.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(OpusSpacing.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🇨🇮',
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: OpusSpacing.xs),
                            Text(
                              _countryCode,
                              style: OpusTextStyles.body.copyWith(
                                color: OpusColors.indigoBache,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: OpusSpacing.sm),
                      // Phone number field
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          onFieldSubmitted: (_) => _submit(),
                          style: OpusTextStyles.body.copyWith(
                            color: OpusColors.noirGoudron,
                          ),
                          decoration: InputDecoration(
                            hintText: 'XX XX XX XX XX',
                            hintStyle: OpusTextStyles.body.copyWith(
                              color: OpusColors.grisPoussiere,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: OpusSpacing.md,
                              vertical: OpusSpacing.md,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(OpusSpacing.sm),
                              borderSide: BorderSide(
                                color: OpusColors.indigoBache.withValues(alpha: 0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(OpusSpacing.sm),
                              borderSide: BorderSide(
                                color: OpusColors.indigoBache.withValues(alpha: 0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(OpusSpacing.sm),
                              borderSide: const BorderSide(
                                color: OpusColors.indigoBache,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(OpusSpacing.sm),
                              borderSide: const BorderSide(
                                color: OpusColors.error,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(OpusSpacing.sm),
                              borderSide: const BorderSide(
                                color: OpusColors.error,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Veuillez entrer votre numéro de téléphone.';
                            }
                            if (trimmed.length != 10) {
                              return 'Le numéro doit contenir exactement 10 chiffres.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: OpusSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OpusColors.rougeEnseigne,
                        disabledBackgroundColor:
                            OpusColors.rougeEnseigne.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(OpusSpacing.sm),
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
                              'Envoyer le code',
                              style: OpusTextStyles.button,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
