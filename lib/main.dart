import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import 'pomodoro_timer.dart';

const _background = Color(0xFFFAF7F2);
const _textColor = Color(0xFF2B2B2B);
const _mutedText = Color(0xFF7A756E);
const _accent = Color(0xFFC0392B);

void main() => runApp(const IndramodoroApp());

class IndramodoroApp extends StatelessWidget {
  const IndramodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'indramodoro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _background,
        colorScheme: ColorScheme.fromSeed(seedColor: _accent).copyWith(primary: _accent),
      ),
      home: const TimerScreen(),
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final _timer = PomodoroTimer();

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  String _formatTime(Duration d) {
    // Se redondea hacia arriba: muestra 25:00 al inicio y 00:01 hasta terminar.
    final total = (d.inMilliseconds / 1000).ceil();
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _timer,
          builder: (context, _) {
            final isFocus = _timer.phase == Phase.focus;
            final primaryLabel = _timer.running
                ? 'Pausar'
                : (_timer.hasProgress ? 'Reanudar' : 'Iniciar');

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                children: [
                  const Text(
                    'indramodoro',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isFocus ? 'CONCENTRACIÓN' : 'DESCANSO',
                          style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: 1,
                            color: _mutedText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _formatTime(_timer.remaining),
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w600,
                            color: _textColor,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _Tomatoes(
                          completed: _timer.cycleSessions,
                          current: isFocus ? _timer.cycleSessions : null,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _timer.toggle,
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      child: Text(primaryLabel),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _timer.reset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textColor,
                        side: const BorderSide(color: Color(0xFFD9D4CC)),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Reiniciar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sesiones completadas: ${_timer.totalCompleted}',
                    style: const TextStyle(fontSize: 14, color: _mutedText),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Cuatro tomates: completados con opacidad total, pendientes atenuados y
/// un puntito rojo debajo del tomate de la sesión actual.
class _Tomatoes extends StatelessWidget {
  const _Tomatoes({required this.completed, required this.current});

  final int completed;
  final int? current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(PomodoroTimer.sessionsPerCycle, (i) {
        final done = i < completed;
        final isCurrent = i == current;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Opacity(
                opacity: (done || isCurrent) ? 1.0 : 0.3,
                child: const Text('🍅', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? _accent : Colors.transparent,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
