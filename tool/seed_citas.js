/**
 * Script Node para poblar 60 citas (30 en noviembre 2025, 30 en diciembre 2025)
 * variando doctores, pacientes, estados y horarios.
 *
 * Requisitos:
 * 1) Node.js instalado.
 * 2) Dependencia: npm install firebase-admin
 * 3) Service account JSON:
 *    - Argumento: node tool/seed_citas.js C:\ruta\serviceAccountKey.json
 *    - O variable: set GOOGLE_APPLICATION_CREDENTIALS=C:\ruta\serviceAccountKey.json
 *    - O archivo serviceAccountKey.json en la raíz del proyecto.
 *
 * El script respeta las reglas:
 * - No doble booking (mismo doctor, mismo día y hora).
 * - No misma combinación doctor/paciente en el mismo día.
 */

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

// Datos obtenidos de la ejecución previa de list_users.js
const doctores = [
  { id: '1lwEoUV8uRUR3GtsQ1LM', nombre: 'Dr. Cardiología 1', especialidad: 'Cardiología' },
  { id: '3yU4YCK8GChJa3vnuDWPRrSjbZs1', nombre: 'Dr. Neurología 1', especialidad: 'Neurología' },
  { id: '5BALCApgGpWsgPMhnvt2ZThli8F3', nombre: 'Dr. Roberto Sánchez', especialidad: 'Cardiología' },
  { id: 'F7v82AF9vaSH5LQz7oCmB9NKLqH2', nombre: 'Dr. Neurología 2', especialidad: 'Neurología' },
  { id: 'FpUIspZ7R0MkPI48DVTgme1ccRr2', nombre: 'Dr. Manuel Pascal', especialidad: 'Pediatría' },
  { id: 'GCs4HuGZCyXFaYWlYzj0gfwsLXM2', nombre: 'Dra. Carmen Reyes', especialidad: 'Traumatología' },
  { id: 'MyyrtH93xdQmgMpU07KJOWKUI1i2', nombre: 'Dr. Dario Gonzales', especialidad: 'Neurología' },
  { id: 'Pt8XY66YhqNlm0d0Czkj4sm89r22', nombre: 'Dr. Luis Mendoza', especialidad: 'Pediatría' },
  { id: 'byRypOr8heZBDb1yQ0mPcYJMT1u2', nombre: 'Dr. Jorge Castro', especialidad: 'Oftalmología' },
  { id: 'hWJd1Ad7K7fLoCBxgxkD4PTSbUv2', nombre: 'Dra. Ana Flores', especialidad: 'Dermatología' },
  { id: 'n3SXJNb98TZUsBm4smBNFILHsby1', nombre: 'Dr. n3SXJ', especialidad: 'Cardiología' },
  { id: 'sYbNWV9tNFedjKERO8XYrfGX4Ct1', nombre: 'Dra. Olivia Silveira', especialidad: 'Ginecología' },
];

const pacientes = [
  { id: '3yU4YCK8GChJa3vnuDWPRrSjbZs1', nombre: 'David Figueroa', email: 'david.figueroa@gmail.com', telefono: '5551010101' },
  { id: '4eN52R8LP8VgpjTKuQ97iDJFKQv1', nombre: 'Pedro Martínez', email: 'pedro.martinez@test.com', telefono: '5552020202' },
  { id: 'AG4rwQVU60ZwEtIUnV9HEJYA4sx2', nombre: 'Carmen Silva', email: 'carmen.silva@test.com', telefono: '5553030303' },
  { id: 'DbuMvPnxSKbQpW8vBFqzoU4O6qM2', nombre: 'José Rodríguez', email: 'jose.rodriguez@test.com', telefono: '5554040404' },
  { id: 'EaQRGeyWCSNVfSHS6RoXjm49D982', nombre: 'Miguel Torres', email: 'miguel.torres@test.com', telefono: '5555050505' },
  { id: 'FpUIspZ7R0MkPI48DVTgme1ccRr2', nombre: 'Manuel Pascal', email: 'manu.pas@gmail.com', telefono: '5556060606' },
  { id: 'GCs4HuGZCyXFaYWlYzj0gfwsLXM2', nombre: 'Dra. Carmen Reyes', email: 'dra..carmen.reyes@hospital.com', telefono: '5557070707' },
  { id: 'IjLgEGoaPCQ2lsopnEzkcEemIcv2', nombre: 'David Figueroa', email: 'tutroyano2001@gmail.com', telefono: '5558080808' },
  { id: 'JxvnCUFO9Oh6uemTxiCHBEFK25X2', nombre: 'María García', email: 'maria.garcia@test.com', telefono: '5559090909' },
  { id: 'MyyrtH93xdQmgMpU07KJOWKUI1i2', nombre: 'Dario Gonzales', email: 'dario@gmail.com', telefono: '5551111111' },
  { id: 'Pt8XY66YhqNlm0d0Czkj4sm89r22', nombre: 'Dr. Luis Mendoza', email: 'dr..luis.mendoza@hospital.com', telefono: '5551212121' },
  { id: 'X8pcui7od3QxM12mEbUQ71XMP672', nombre: 'Isabel Morales', email: 'isabel.morales@test.com', telefono: '5551313131' },
  { id: 'bcmr6k1Iq4d4LnNlsLuSlWq9Ir02', nombre: 'Laura Hernández', email: 'laura.hernández@test.com', telefono: '5551414141' },
  { id: 'byRypOr8heZBDb1yQ0mPcYJMT1u2', nombre: 'Dr. Jorge Castro', email: 'dr..jorge.castro@hospital.com', telefono: '5551515151' },
  { id: 'fcMhxQsmN9T6CsLLo8TCX39OY402', nombre: 'Ana López', email: 'ana.lópez@test.com', telefono: '5551616161' },
  { id: 'hWJd1Ad7K7fLoCBxgxkD4PTSbUv2', nombre: 'Dra. Ana Flores', email: 'dra..ana.flores@hospital.com', telefono: '5551717171' },
  { id: 'kKP9C1lOzudCej6noRXTSJuSarV2', nombre: 'Carlos Ramírez', email: 'carlos.ramirez@test.com', telefono: '5551818181' },
  { id: 'n3SXJNb98TZUsBm4smBNFILHsby1', nombre: 'Maria Cruz', email: 'mari.cruz@gmail.com', telefono: '5551919191' },
  { id: 'sYbNWV9tNFedjKERO8XYrfGX4Ct1', nombre: 'Olivia Silveira', email: 'oli.sil@gmail.com', telefono: '5552021222' },
  { id: 'sqljlAz0jlMUX3zxHhjReEmtiNl1', nombre: 'Juan Pérez', email: 'juan.perez@test.com', telefono: '5552121212' },
  { id: 'F7v82AF9vaSH5LQz7oCmB9NKLqH2', nombre: 'Oto Octavius', email: 'oto.octa@gmail.com', telefono: '5552222222' },
  { id: '5BALCApgGpWsgPMhnvt2ZThli8F3', nombre: 'Dr. Roberto Sánchez', email: 'dr.roberto.sánchez@hospital.com', telefono: '5552323232' },
];

const motivos = [
  'Chequeo general',
  'Dolor de cabeza recurrente',
  'Revisión post-operatoria',
  'Consulta de seguimiento',
  'Dolor abdominal leve',
  'Control de presión arterial',
  'Revisión de laboratorio',
  'Molestias articulares',
  'Evaluación de alergias',
  'Consulta nutricional',
  'Fatiga persistente',
  'Control de diabetes',
];

const horas = [
  '09:00 AM',
  '10:00 AM',
  '11:30 AM',
  '02:00 PM',
  '03:30 PM',
  '05:00 PM',
];

const estados = ['pendiente', 'completada', 'cancelada'];

function resolveServiceAccount() {
  const argPath = process.argv[2];
  if (argPath && fs.existsSync(argPath)) return argPath;

  const envPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (envPath && fs.existsSync(envPath)) return envPath;

  const local = path.join(process.cwd(), 'serviceAccountKey.json');
  if (fs.existsSync(local)) return local;

  return null;
}

function randomChoice(arr, index) {
  return arr[index % arr.length];
}

function buildDateTime(year, month, day, hourStr) {
  const [time, ampm] = hourStr.split(' ');
  let [h, m] = time.split(':').map((v) => parseInt(v, 10));
  if (ampm === 'PM' && h !== 12) h += 12;
  if (ampm === 'AM' && h === 12) h = 0;
  // Ajusta zona horaria a UTC-6 si quieres coherencia con tu backend; aquí usamos UTC.
  return new Date(Date.UTC(year, month - 1, day, h, m));
}

function generateAppointments({ year, month, count, offsetSeed }) {
  const citas = [];
  let day = 1;
  for (let i = 0; i < count; i++) {
    const doctor = randomChoice(doctores, i + offsetSeed);
    const paciente = randomChoice(pacientes, i * 7 + offsetSeed); // otro offset para desalinear
    const hora = randomChoice(horas, i * 3 + offsetSeed);
    const estado = randomChoice(estados, i + offsetSeed);
    const motivo = randomChoice(motivos, i * 5 + offsetSeed);

    // Rotar días dentro del mes (1..28 para evitar edge cases)
    day = (day % 28) + 1;
    const fecha = buildDateTime(year, month, day, hora);
    const fechaCreacion = buildDateTime(year, month, Math.max(1, day - 2), '09:00 AM');

    citas.push({
      email_paciente: paciente.email,
      es_primera_cita: estado === 'pendiente', // solo para variar el campo
      especialidad_doctor: doctor.especialidad,
      estado,
      fecha,
      fecha_creacion: fechaCreacion,
      hora,
      id_doctor: doctor.id,
      id_paciente: paciente.id,
      motivo_consulta: motivo,
      nombre_doctor: doctor.nombre,
      nombre_paciente: paciente.nombre,
      telefono_paciente: paciente.telefono,
    });
  }
  return citas;
}

async function main() {
  const serviceAccountPath = resolveServiceAccount();
  if (!serviceAccountPath) {
    console.error(
      'Falta el service account JSON. Pasa la ruta como argumento, define GOOGLE_APPLICATION_CREDENTIALS,',
      'o coloca serviceAccountKey.json en la raíz.'
    );
    process.exit(1);
  }

  admin.initializeApp({
    credential: admin.credential.cert(require(serviceAccountPath)),
  });

  const db = admin.firestore();

  const citasNov = generateAppointments({ year: 2025, month: 11, count: 30, offsetSeed: 1 });
  const citasDic = generateAppointments({ year: 2025, month: 12, count: 30, offsetSeed: 101 });
  const citas = [...citasNov, ...citasDic];

  // Para respetar las reglas de no doble booking en (doctor, fecha, hora)
  // y no (doctor, paciente, día), llevamos un set de claves:
  const slotSet = new Set();
  const dayPairSet = new Set();
  const docsToWrite = [];

  for (const cita of citas) {
    const fecha = cita.fecha.toISOString().slice(0, 10); // YYYY-MM-DD
    const slotKey = `${cita.id_doctor}|${fecha}|${cita.hora}`;
    const pairKey = `${cita.id_doctor}|${cita.id_paciente}|${fecha}`;
    if (slotSet.has(slotKey) || dayPairSet.has(pairKey)) {
      continue; // salta duplicados
    }
    slotSet.add(slotKey);
    dayPairSet.add(pairKey);

    docsToWrite.push(cita);
  }

  console.log(`Insertando ${docsToWrite.length} citas...`);
  const batchSize = 250;
  for (let i = 0; i < docsToWrite.length; i += batchSize) {
    const batch = db.batch();
    const chunk = docsToWrite.slice(i, i + batchSize);
    for (const cita of chunk) {
      const ref = db.collection('citas').doc();
      batch.set(ref, cita);
    }
    await batch.commit();
    console.log(`Batch ${Math.floor(i / batchSize) + 1} listo (${chunk.length} docs)`);
  }

  console.log('Seeding completado.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
