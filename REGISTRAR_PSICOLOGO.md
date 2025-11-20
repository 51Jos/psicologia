# 📋 Cómo Registrar un Psicólogo

## Método 1: Usando Firebase Console (Recomendado)

### Paso 1: Crear Usuario en Firebase Authentication
1. Abre Firebase Console: https://console.firebase.google.com
2. Selecciona tu proyecto
3. Ve a **Authentication** > **Users**
4. Click en **Add User**
5. Ingresa:
   - **Email**: Formato `primeraLetraNombre+apellido@ucss.edu.pe`
     - Ejemplo: `jperez@ucss.edu.pe` (Juan Pérez)
   - **Password**: Una contraseña temporal (el psicólogo podrá cambiarla después)
6. Click en **Add User**
7. **Copia el UID** del usuario creado

### Paso 2: Crear Documento en Firestore
1. Ve a **Firestore Database** > **usuarios** collection
2. Click en **Add Document**
3. **Document ID**: Pega el **UID** copiado en el paso anterior
4. Agrega los siguientes campos:

```json
{
  "email": "jperez@ucss.edu.pe",
  "nombres": "",
  "apellidos": "",
  "tipo": "psicologo",
  "activo": true,
  "fechaCreacion": [Timestamp - Click "Add field" > selecciona "timestamp" > usa la fecha actual]
}
```

5. Click en **Save**

### Paso 3: El Psicólogo Completa su Perfil
1. El psicólogo inicia sesión con su email y contraseña temporal
2. Será redirigido automáticamente a la página de perfil
3. Completa sus datos: nombres, apellidos, teléfono (opcional), especialidad (opcional)
4. Cambia su contraseña desde el perfil
5. ¡Listo! Ya puede usar el sistema

---

## Método 2: Usando la Consola de Firebase (Firestore Directamente)

Si ya creaste el usuario en Authentication y solo necesitas el documento de Firestore:

```javascript
// En la consola de Firestore, agrega este documento
{
  "email": "jperez@ucss.edu.pe",
  "nombres": "",
  "apellidos": "",
  "tipo": "psicologo",
  "activo": true,
  "fechaCreacion": firebase.firestore.FieldValue.serverTimestamp()
}
```

---

## Método 3: Usando Código (Para Desarrolladores)

Puedes crear un script temporal o usar la función `registrarPsicologo` desde la consola de desarrollador:

### Opción A: Desde la Consola del Navegador

1. Inicia sesión como administrador
2. Abre la consola del navegador (F12)
3. Ejecuta:

```javascript
// Importa Firebase
import { getAuth } from 'firebase/auth';
import { getFirestore, doc, setDoc, Timestamp } from 'firebase/firestore';

const auth = getAuth();
const db = getFirestore();

async function crearPsicologo(email, password) {
  try {
    // Crear en Authentication
    const userCredential = await auth.createUserWithEmailAndPassword(email, password);
    const uid = userCredential.user.uid;

    // Crear en Firestore
    await setDoc(doc(db, 'usuarios', uid), {
      email: email,
      nombres: '',
      apellidos: '',
      tipo: 'psicologo',
      activo: true,
      fechaCreacion: Timestamp.now()
    });

    console.log('Psicólogo creado exitosamente. UID:', uid);
  } catch (error) {
    console.error('Error:', error);
  }
}

// Usar la función
crearPsicologo('jperez@ucss.edu.pe', 'temporal123');
```

### Opción B: Script Dart (Desarrollo)

Crea un archivo temporal `tools/crear_psicologo.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import '../lib/features/autenticacion/servicios/auth_servicio.dart';
import '../lib/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authServicio = AuthServicio();

  try {
    final psicologo = await authServicio.registrarPsicologo(
      email: 'jperez@ucss.edu.pe',
      password: 'temporal123',
    );

    print('✅ Psicólogo creado exitosamente!');
    print('Email: ${psicologo.email}');
    print('UID: ${psicologo.id}');
    print('\nEl psicólogo debe completar su perfil al iniciar sesión.');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

Ejecutar:
```bash
dart run tools/crear_psicologo.dart
```

---

## 🔒 Credenciales de Ejemplo

Para pruebas, puedes crear psicólogos con estos formatos:

| Nombre Completo | Email | Password Temporal |
|-----------------|-------|-------------------|
| Juan Pérez | jperez@ucss.edu.pe | temporal123 |
| María García | mgarcia@ucss.edu.pe | temporal123 |
| Carlos Rodríguez | crodriguez@ucss.edu.pe | temporal123 |

> **Importante**: Todos los psicólogos deben cambiar su contraseña después del primer inicio de sesión.

---

## ✅ Verificación

Después de crear el psicólogo, verifica:

1. ✅ Usuario existe en **Firebase Authentication**
2. ✅ Documento existe en **Firestore** > **usuarios** collection
3. ✅ Campo `tipo` tiene valor `"psicologo"`
4. ✅ Campo `activo` tiene valor `true`
5. ✅ El psicólogo puede iniciar sesión
6. ✅ Es redirigido a la página de perfil para completar datos

---

## 🎯 Flujo Completo

```
1. Admin crea usuario en Firebase
        ↓
2. Documento creado en Firestore (nombres y apellidos vacíos)
        ↓
3. Psicólogo inicia sesión
        ↓
4. Sistema detecta perfil incompleto
        ↓
5. Redirige a /perfil automáticamente
        ↓
6. Psicólogo completa sus datos
        ↓
7. Psicólogo cambia contraseña
        ↓
8. Cierra sesión y vuelve a iniciar
        ↓
9. Redirige a /atenciones (dashboard principal)
```

---

## 📝 Notas Importantes

- Los emails de psicólogos DEBEN terminar en `@ucss.edu.pe`
- Los emails de estudiantes terminan en `@ucss.pe`
- El perfil se considera incompleto si `nombres` o `apellidos` están vacíos
- El teléfono y especialidad son opcionales
- El psicólogo puede cambiar su contraseña desde el perfil
- El psicólogo puede cerrar sesión desde el perfil

---

## 🐛 Solución de Problemas

**Problema**: "El correo debe ser un email institucional válido"
- **Solución**: Asegúrate de usar `@ucss.edu.pe` (no `@ucss.pe`)

**Problema**: El psicólogo no puede iniciar sesión
- **Solución**: Verifica que el documento en Firestore tenga el mismo UID que en Authentication

**Problema**: El psicólogo es redirigido al perfil aunque completó sus datos
- **Solución**: Verifica que los campos `nombres` y `apellidos` no estén vacíos en Firestore

**Problema**: Error de permisos
- **Solución**: Asegúrate de tener las reglas de Firestore configuradas correctamente

---

## 📧 Soporte

Para más ayuda, contacta al equipo de desarrollo.
