# indramodoro (Flutter)

Temporizador Pomodoro minimalista. Sin dependencias extra: solo Flutter.

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x (con `flutter doctor` sin errores para tu plataforma)

## Instalar y ejecutar

Estando dentro de esta carpeta:

```bash
# 1. Generar las carpetas de plataforma (android/, ios/) una sola vez.
#    No sobrescribe lib/ ni pubspec.yaml.
flutter create . --project-name indramodoro_flutter --platforms=android,ios

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar (con un emulador abierto o un celular conectado)
flutter run
```

Pruebas de la lógica del temporizador (opcional):

```bash
flutter test
```

## Estructura

- `lib/pomodoro_timer.dart`: lógica (etapas, pausa, reinicio, cambio automático). Sin UI.
- `lib/main.dart`: la pantalla.
- `test/widget_test.dart`: pruebas de la lógica con un reloj simulado.

## Cómo evita desincronizarse

Mientras corre, el temporizador guarda la hora exacta en la que termina la etapa y
el tiempo restante es siempre `hora de fin - hora actual`. El `Timer.periodic` solo
sirve para refrescar la pantalla y detectar el fin; si un tick llega tarde, el
resultado sigue siendo correcto. Al pausar se guarda lo que faltaba, y al reanudar
se calcula una nueva hora de fin.
