import 'dart:async';

import 'package:flutter/foundation.dart';

enum Phase { focus, shortBreak, longBreak }

/// Lógica del Pomodoro, sin nada de interfaz.
///
/// El tiempo restante NO se calcula restando 1 segundo por cada tick.
/// Mientras corre, se guarda la hora exacta en la que termina la etapa
/// (`_endsAt`) y el tiempo restante siempre es `_endsAt - ahora`.
/// Así pausar, reanudar o que el tick llegue tarde no desincroniza nada.
class PomodoroTimer extends ChangeNotifier {
  PomodoroTimer({DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  static const focusDuration = Duration(minutes: 25);
  static const shortBreakDuration = Duration(minutes: 5);
  static const longBreakDuration = Duration(minutes: 15);
  static const sessionsPerCycle = 4;

  final DateTime Function() _now;

  Phase _phase = Phase.focus;
  int _cycleSessions = 0; // sesiones de concentración completadas en el ciclo (0-4)
  int _totalCompleted = 0;
  Duration _remaining = focusDuration;
  DateTime? _endsAt; // solo tiene valor mientras corre
  Timer? _ticker;

  Phase get phase => _phase;
  int get cycleSessions => _cycleSessions;
  int get totalCompleted => _totalCompleted;
  Duration get remaining => _remaining;
  bool get running => _endsAt != null;
  bool get hasProgress => _remaining < durationOf(_phase);

  static Duration durationOf(Phase phase) {
    switch (phase) {
      case Phase.focus:
        return focusDuration;
      case Phase.shortBreak:
        return shortBreakDuration;
      case Phase.longBreak:
        return longBreakDuration;
    }
  }

  void toggle() => running ? pause() : start();

  void start() {
    if (running) return;
    _endsAt = _now().add(_remaining);
    // El ticker solo refresca; el tiempo real sale de _endsAt.
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => tick());
    notifyListeners();
  }

  void pause() {
    if (!running) return;
    tick(); // actualiza _remaining (y cambia de etapa si ya había terminado)
    _stopTicker();
    notifyListeners();
  }

  /// Reinicia la etapa actual y la deja en pausa.
  void reset() {
    _stopTicker();
    _remaining = durationOf(_phase);
    notifyListeners();
  }

  /// Recalcula el tiempo restante a partir del reloj. Es público para poder
  /// probarlo con un reloj simulado.
  void tick() {
    if (!running) return;
    var left = _endsAt!.difference(_now());
    // Si pasó más de una etapa (p. ej. app en segundo plano), se ponen al día.
    while (left <= Duration.zero) {
      _advancePhase();
      _endsAt = _endsAt!.add(_remaining);
      left = _endsAt!.difference(_now());
    }
    _remaining = left;
    notifyListeners();
  }

  void _advancePhase() {
    if (_phase == Phase.focus) {
      _totalCompleted++;
      _cycleSessions++;
      _phase = _cycleSessions == sessionsPerCycle ? Phase.longBreak : Phase.shortBreak;
    } else {
      if (_phase == Phase.longBreak) _cycleSessions = 0;
      _phase = Phase.focus;
    }
    _remaining = durationOf(_phase);
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
    _endsAt = null;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
