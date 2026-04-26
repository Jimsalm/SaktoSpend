import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

const _voiceAmountPattern =
    r'\d{1,3}(?:[,\s]\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?';

class VoiceEntryDraft {
  const VoiceEntryDraft({required this.name, required this.unitPrice});

  final String name;
  final int unitPrice;
}

Future<VoiceEntryDraft?> showVoiceCaptureSheet(BuildContext context) async {
  final speech = stt.SpeechToText();
  var sheetOpen = true;
  var isInitialized = false;
  var isListening = false;
  var isPressing = false;
  var transcript = '';
  var finalTranscript = '';
  var errorText = '';

  Future<void> ensureInitialized(StateSetter setModalState) async {
    if (isInitialized) {
      return;
    }

    final available = await speech.initialize(
      onError: (error) {
        if (!sheetOpen) {
          return;
        }
        setModalState(() {
          isListening = false;
          errorText = error.errorMsg;
        });
      },
      onStatus: (status) {
        if (!sheetOpen) {
          return;
        }
        if (status == 'done' || status == 'notListening') {
          setModalState(() => isListening = false);
        }
      },
    );
    if (!sheetOpen) {
      return;
    }
    if (!available) {
      setModalState(() {
        errorText = 'Voice recognition is not available on this device.';
      });
      return;
    }
    setModalState(() {
      isInitialized = true;
      errorText = '';
    });
  }

  Future<void> startListening(StateSetter setModalState) async {
    await ensureInitialized(setModalState);
    if (!isInitialized || isListening || !isPressing) {
      return;
    }

    await speech.listen(
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
      ),
      onResult: (result) {
        if (!sheetOpen) {
          return;
        }
        setModalState(() {
          transcript = result.recognizedWords.trim();
          if (result.finalResult) {
            finalTranscript = transcript;
          }
          errorText = '';
        });
      },
    );
    if (!sheetOpen) {
      return;
    }
    if (!isPressing) {
      await speech.stop();
      return;
    }
    setModalState(() => isListening = true);
  }

  Future<void> stopListening(StateSetter setModalState) async {
    if (!isInitialized) {
      return;
    }
    await speech.stop();
    if (!sheetOpen) {
      return;
    }
    setModalState(() => isListening = false);
  }

  final result = await showModalBottomSheet<VoiceEntryDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setModalState) {
          final theme = Theme.of(sheetContext);
          final tokens = sheetContext.appThemeTokens;
          return SafeArea(
            top: false,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetContext).size.height * 0.88,
              ),
              decoration: BoxDecoration(
                color: tokens.backgroundCanvas,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: tokens.shadowColor,
                    blurRadius: 28,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: tokens.borderSubtle,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Voice Entry',
                                style: theme.textTheme.headlineMedium
                                    ?.copyWith(
                                      fontSize: 34,
                                      color: tokens.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Hold the mic button, say the item name and price, then release to parse the draft.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        _VoiceIconButton(
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                      decoration: BoxDecoration(
                        color: tokens.surfacePrimary,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: tokens.borderSubtle),
                        boxShadow: [
                          BoxShadow(
                            color: tokens.shadowColor,
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                        gradient: RadialGradient(
                          center: const Alignment(0.88, -0.08),
                          radius: 1.1,
                          colors: [
                            tokens.accentSoft.withValues(alpha: 0.95),
                            Colors.white.withValues(alpha: 0.97),
                            Colors.white,
                          ],
                          stops: const [0.0, 0.42, 1.0],
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'VOICE CAPTURE',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    letterSpacing: 1.8,
                                    color: tokens.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  isListening
                                      ? 'Listening now. Keep speaking until the item name and price are complete.'
                                      : 'Tap and hold the mic to create a quick item draft without typing.',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: 24,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _VoiceTag(
                                      icon: Icons.mic_none_rounded,
                                      label: isListening
                                          ? 'Listening'
                                          : 'Ready',
                                    ),
                                    const _VoiceTag(
                                      icon:
                                          Icons.receipt_long_rounded,
                                      label: 'Name + Price',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              shape: BoxShape.circle,
                              border: Border.all(color: tokens.borderSubtle),
                            ),
                            child: Icon(
                              Icons.keyboard_voice_rounded,
                              color: tokens.accentStrong,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      decoration: BoxDecoration(
                        color: tokens.surfacePrimary,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: tokens.borderSubtle),
                        boxShadow: [
                          BoxShadow(
                            color: tokens.shadowColor,
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Transcript',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              color: tokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Example: Organic Almond Milk 69.75',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: tokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: tokens.surfaceSecondary,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: tokens.borderSubtle),
                            ),
                            child: Text(
                              transcript.isEmpty
                                  ? 'Press and hold the mic to start capturing your item.'
                                  : transcript,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: transcript.isEmpty
                                    ? tokens.textTertiary
                                    : tokens.textPrimary,
                              ),
                            ),
                          ),
                          if (errorText.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              errorText,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: tokens.warningStrong,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: GestureDetector(
                        onTapDown: (_) {
                          setModalState(() {
                            isPressing = true;
                            transcript = '';
                            finalTranscript = '';
                            errorText = '';
                          });
                          startListening(setModalState);
                        },
                        onTapCancel: () async {
                          isPressing = false;
                          await stopListening(setModalState);
                        },
                        onTapUp: (_) async {
                          isPressing = false;
                          await stopListening(setModalState);
                          await Future<void>.delayed(
                            const Duration(milliseconds: 220),
                          );

                          final candidates = <String>[
                            finalTranscript.trim(),
                            transcript.trim(),
                          ].where((entry) => entry.isNotEmpty).toSet().toList();

                          VoiceEntryDraft? draft;
                          for (final candidate in candidates) {
                            draft = _parseVoiceDraft(candidate);
                            if (draft != null) {
                              break;
                            }
                          }

                          if (draft == null) {
                            setModalState(() {
                              errorText =
                                  'Could not detect both name and price. Try again.';
                            });
                            return;
                          }
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext, draft);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            color: isListening
                                ? tokens.textPrimary
                                : tokens.accentStrong,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.7),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: tokens.shadowColor,
                                blurRadius: isListening ? 24 : 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.mic_rounded,
                            size: 40,
                            color: isListening
                                ? Colors.white
                                : tokens.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        isListening ? 'Listening...' : 'Press and hold to talk',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );

  sheetOpen = false;
  await speech.stop();
  await speech.cancel();
  return result;
}

VoiceEntryDraft? _parseVoiceDraft(String transcript) {
  final trimmed = transcript.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final price = _extractVoicePrice(trimmed);
  if (price == null || price < 0) {
    return null;
  }
  final name = _extractVoiceName(trimmed);
  if (name.isEmpty) {
    return null;
  }

  return VoiceEntryDraft(name: name, unitPrice: price);
}

int? _extractVoicePrice(String transcript) {
  final normalized = transcript
      .toLowerCase()
      .replaceAll(RegExp(r'\b(pesos|peso|php)\b'), '')
      .replaceAll('₱', '')
      .replaceAllMapped(
        RegExp(r'(\d+)\s+point\s+(\d{1,2})'),
        (match) => '${match.group(1)}.${match.group(2)}',
      );
  final matches = RegExp(_voiceAmountPattern).allMatches(normalized).toList();
  if (matches.isEmpty) {
    return null;
  }
  final amountText = matches.last.group(0)!.replaceAll(RegExp(r'[,\s]'), '');
  return MoneyUtils.parseCurrencyToCentavos(amountText);
}

String _extractVoiceName(String transcript) {
  var working = transcript;
  final matches = RegExp(_voiceAmountPattern).allMatches(working).toList();
  if (matches.isNotEmpty) {
    final last = matches.last;
    working =
        '${working.substring(0, last.start)} ${working.substring(last.end)}';
  }
  working = working
      .replaceAll(RegExp(r'\b(pesos|peso|php)\b', caseSensitive: false), ' ')
      .replaceAll(
        RegExp(
          r'\b(add|item|price|cost|for|at|amount|is)\b',
          caseSensitive: false,
        ),
        ' ',
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  working = working.replaceAll(RegExp(r'^[,.\-\s]+|[,.\-\s]+$'), '');
  return working;
}

class _VoiceIconButton extends StatelessWidget {
  const _VoiceIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: tokens.surfacePrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tokens.borderSubtle),
          ),
          child: Icon(icon, color: tokens.textPrimary, size: 22),
        ),
      ),
    );
  }
}

class _VoiceTag extends StatelessWidget {
  const _VoiceTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tokens.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
