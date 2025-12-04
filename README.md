# flutter_application_doctor_appointment

Aplicación Flutter para agendar y gestionar citas médicas con autenticación Firebase y datos en Firestore. Incluye panel de dashboard para médicos, gestión de citas para pacientes y navegación multiplataforma (web/móvil/escritorio).

## Requisitos
- Flutter 3.9.2 o superior
- Cuenta de Firebase configurada (Auth + Firestore) y `firebase_options.dart` generado

## Ejecución
```bash
flutter pub get
flutter run
```

## Estructura breve
- `lib/main.dart`: inicialización Firebase, providers de repositorios/BLoCs y rutas.
- `lib/repositories`: acceso a Firebase Auth y colecciones Firestore.
- `lib/bloc`: lógica de negocio para auth, usuarios, citas y dashboard.
- `lib/views`: pantallas de autenticación, home, citas, dashboard, perfil, ajustes.
- `lib/widgets/dashboard`: componentes de gráficas (fl_chart).

## Pruebas
```bash
flutter test
```
