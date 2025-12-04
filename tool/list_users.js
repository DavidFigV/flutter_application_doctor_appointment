/**
 * Script Node para listar UIDs de doctores y pacientes usando firebase-admin.
 *
 * Requisitos:
 * 1) Tener Node.js instalado.
 * 2) Instalar firebase-admin (una sola vez en la raíz del repo):
 *      npm install firebase-admin
 *
 * Uso:
 *   node tool/list_users.js C:\ruta\serviceAccountKey.json
 *   // o define GOOGLE_APPLICATION_CREDENTIALS y omite el argumento.
 */

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

function resolveServiceAccount() {
  const argPath = process.argv[2];
  if (argPath && fs.existsSync(argPath)) return argPath;

  const envPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (envPath && fs.existsSync(envPath)) return envPath;

  const local = path.join(process.cwd(), 'serviceAccountKey.json');
  if (fs.existsSync(local)) return local;

  return null;
}

async function main() {
  const serviceAccountPath = resolveServiceAccount();
  if (!serviceAccountPath) {
    console.error(
      'Falta el service account JSON. Pasa la ruta como argumento, define GOOGLE_APPLICATION_CREDENTIALS,',
      'o coloca serviceAccountKey.json en la raíz del proyecto.'
    );
    process.exit(1);
  }

  admin.initializeApp({
    credential: admin.credential.cert(require(serviceAccountPath)),
  });

  const db = admin.firestore();

  const doctoresSnap = await db.collection('doctores').get();
  const usuariosSnap = await db.collection('usuarios').get();

  console.log(`=== DOCTORES (${doctoresSnap.size}) ===`);
  doctoresSnap.forEach((doc) => {
    const data = doc.data() || {};
    console.log(`- ${doc.id} | nombre: ${data.nombre || ''} | especialidad: ${data.especialidad || ''}`);
  });

  console.log(`\n=== PACIENTES (${usuariosSnap.size}) ===`);
  usuariosSnap.forEach((doc) => {
    const data = doc.data() || {};
    console.log(`- ${doc.id} | nombre: ${data.nombre || ''} | email: ${data.email || ''}`);
  });
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
