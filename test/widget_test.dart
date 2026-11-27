import 'package:flutter_test/flutter_test.dart';
import 'package:indramodoro_flutter/pomodoro_timer.dart';

void main() {
  test('pausar y reanudar no pierde ni gana tiempo', () {
    var now = DateTime(2026, 1, 1, 9, 0, 0);
    final t = PomodoroTimer(clock: () => now);

    t.start();
    now = now.add(const Duration(minutes: 10));
    t.pause();
    expect(t.remaining, const Duration(minutes: 15));

    now = now.add(const Duration(hours: 1)); // tiempo en pausa
    t.start();
    now = now.add(const Duration(minutes: 5));
    t.tick();
    expect(t.remaining, const Duration(minutes: 10));
    t.dispose();
  });

  test('ciclo completo: 4 concentraciones, descansos cortos y largo', () {
    var now = DateTime(2026, 1, 1, 9, 0, 0);
    final t = PomodoroTimer(clock: () => now);
    t.start();

    for (var i = 1; i <= 4; i++) {
      now = now.add(PomodoroTimer.focusDuration);
      t.tick();
      expect(t.totalCompleted, i);
      expect(t.phase, i < 4 ? Phase.shortBreak : Phase.longBreak);
      if (i < 4) {
        now = now.add(PomodoroTimer.shortBreakDuration);
        t.tick();
        expect(t.phase, Phase.focus);
      }
    }
    expect(t.cycleSessions, 4);

    now = now.add(PomodoroTimer.longBreakDuration);
    t.tick();
    expect(t.phase, Phase.focus);
    expect(t.cycleSessions, 0);
    expect(t.totalCompleted, 4);
    t.dispose();
  });

  test('reiniciar vuelve al inicio de la etapa actual y pausa', () {
    var now = DateTime(2026, 1, 1, 9, 0, 0);
    final t = PomodoroTimer(clock: () => now);
    t.start();
    now = now.add(const Duration(minutes: 3));
    t.tick();
    t.reset();
    expect(t.running, false);
    expect(t.remaining, PomodoroTimer.focusDuration);
    t.dispose();
  });
}
