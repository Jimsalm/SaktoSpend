import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
    if (!isListening) {
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
    backgroundColor: const Color(0xFFF8F7F4),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setModalState) {
          final theme = Theme.of(sheetContext);
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Voice Entry',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 30,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Text(
                    'Hold the mic button, speak item name and price, then release.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF66635C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEAE4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      transcript.isEmpty
                          ? 'Example: Organic Almond Milk 69.75'
                          : transcript,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: transcript.isEmpty
                            ? const Color(0xFF928C82)
                            : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  if (errorText.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFB61C1C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTapDown: (_) {
                        isPressing = true;
                        startListening(setModalState);
                      },
                      onTapCancel: () async {
                        isPressing = false;
                        await stopListening(setModalState);
                      },
                      onTapUp: (_) async {
                        isPressing = false;
                        await stopListening(setModalState);
                        final draft = _parseVoiceDraft(transcript);
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
                        duration: const Duration(milliseconds: 120),
                        width: 94,
                        height: 94,
                        decoration: BoxDecoration(
                          color: isListening
                              ? Colors.black
                              : const Color(0xFFE4E1DC),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.mic,
                          size: 34,
                          color: isListening ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      isListening ? 'Listening...' : 'Press and hold to talk',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF615C54),
                      ),
                    ),
                  ),
                ],
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
      .replaceAll(',', '')
      .replaceAll(RegExp(r'\b(pesos|peso|php)\b'), '')
      .replaceAllMapped(
        RegExp(r'(\d+)\s+point\s+(\d{1,2})'),
        (match) => '${match.group(1)}.${match.group(2)}',
      );
  final matches = RegExp(r'\d+(?:\.\d{1,2})?').allMatches(normalized).toList();
  if (matches.isEmpty) {
    return null;
  }
  return MoneyUtils.parseCurrencyToCentavos(matches.last.group(0)!);
}

String _extractVoiceName(String transcript) {
  var working = transcript;
  final matches = RegExp(r'\d+(?:\.\d{1,2})?').allMatches(working).toList();
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
  return working;
}
