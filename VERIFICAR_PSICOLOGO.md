# 🔍 Verificar Por Qué No Aparecen Psicólogos

## Paso 1: Verificar en Firebase Console

### A. Ir a Firestore Database
1. Abre Firebase Console: https://console.firebase.google.com
2. Selecciona tu proyecto
3. Ve a **Firestore Database**
4. Busca la collection **usuarios**

### B. Verificar el Documento del Psicólogo

El documento del psicólogo debe tener EXACTAMENTE estos campos:

```json
{
  "email": "jperez@ucss.edu.pe",
  "tipo": "psicologo",         ← IMPORTANTE: minúsculas, sin espacios
  "activo": true,               ← IMPORTANTE: boolean true, NO string "true"
  "nombres": "Juan",            ← Puede estar vacío ""
  "apellidos": "Pérez",         ← Puede estar vacío ""
  "fechaCreacion": [Timestamp]
}
```

### C. Errores Comunes

❌ **Error 1**: `tipo: "Psicologo"` (con mayúscula)
✅ **Correcto**: `tipo: "psicologo"` (todo minúsculas)

❌ **Error 2**: `activo: "true"` (string)
✅ **Correcto**: `activo: true` (boolean)

❌ **Error 3**: `tipo: " psicologo"` (con espacio)
✅ **Correcto**: `tipo: "psicologo"` (sin espacios)

---

## Paso 2: Crear Psicólogo Correctamente

### Opción A: Desde Firebase Console (Manual)

1. **Authentication** > **Users** > **Add User**
   - Email: `jperez@ucss.edu.pe`
   - Password: `temporal123`
   - **Copiar el UID generado**

2. **Firestore Database** > **usuarios** > **Add Document**
   - **Document ID**: Pegar el UID copiado
   - **Agregar campos** (uno por uno):

   | Campo | Tipo | Valor |
   |-------|------|-------|
   | email | string | `jperez@ucss.edu.pe` |
   | tipo | string | `psicologo` |
   | activo | boolean | `true` ← Usa el selector boolean! |
   | nombres | string | `` (vacío) |
   | apellidos | string | `` (vacío) |
   | fechaCreacion | timestamp | (fecha actual) |

   **IMPORTANTE**:
   - Para `activo`, haz clic en el tipo de dato y selecciona **"boolean"**, luego marca `true`
   - NO uses string "true"
   - Para `tipo`, asegúrate de escribir exactamente `psicologo` en minúsculas

---

### Opción B: Desde la App (Usando Script)

1. Ejecuta este comando en la terminal:
   ```bash
   dart run lib/tools/crear_psicologo_prueba.dart
   ```

2. O agrega temporalmente este código en `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'features/autenticacion/servicios/auth_servicio.dart';

// Agregar este botón flotante en alguna pantalla
FloatingActionButton(
  onPressed: () async {
    final authServicio = AuthServicio();
    try {
      final psicologo = await authServicio.registrarPsicologo(
        email: 'jperez@ucss.edu.pe',
        password: 'temporal123',
      );

      print('✅ Psicólogo creado: ${psicologo.email}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Psicólogo creado: ${psicologo.email}')),
      );
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  },
  child: Icon(Icons.add),
)
```

---

## Paso 3: Ver Logs de Debug

Cuando intentes crear una reserva, abre la consola de debug de Flutter.

Verás mensajes como:
```
🔍 Buscando psicólogos en Firestore...
📊 Total de psicólogos encontrados: 0
❌ Error al obtener psicólogos: ...
```

O si funciona:
```
🔍 Buscando psicólogos en Firestore...
📊 Total de psicólogos encontrados: 1
📄 Doc ID: xyz123, Datos: {email: jperez@ucss.edu.pe, tipo: psicologo, ...}
✅ Psicólogos activos: 1
```

---

## Paso 4: Verificar Reglas de Firestore

Ve a **Firestore Database** > **Rules**

Asegúrate de tener algo como:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /usuarios/{userId} {
      // Permitir lectura a usuarios autenticados
      allow read: if request.auth != null;

      // Permitir escritura al propio usuario o admin
      allow write: if request.auth != null &&
        (request.auth.uid == userId ||
         get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.tipo == 'administrador');
    }
  }
}
```

---

## Paso 5: Verificar Índices

Si ves un error como:
```
The query requires an index
```

1. Ve a **Firestore Database** > **Indexes**
2. Busca un mensaje de error en la consola con un link
3. Haz clic en el link para crear el índice automáticamente

O crea manualmente un índice compuesto:
- Collection: `usuarios`
- Campos:
  - `tipo` (Ascending)
  - `activo` (Ascending)

---

## 🎯 Prueba Rápida

Ejecuta esto en la consola de Firebase:

### Opción 1: Console de Firestore (Query)
```
Colección: usuarios
Filtros:
- tipo == "psicologo"
- activo == true
```

Debe mostrar al menos 1 resultado.

### Opción 2: Console del Navegador (F12)
```javascript
// Pega esto en la consola del navegador mientras estás en la app
firebase.firestore().collection('usuarios')
  .where('tipo', '==', 'psicologo')
  .where('activo', '==', true)
  .get()
  .then(snapshot => {
    console.log('Psicólogos encontrados:', snapshot.size);
    snapshot.forEach(doc => {
      console.log(doc.id, doc.data());
    });
  });
```

---

## ✅ Checklist Final

Antes de intentar de nuevo, verifica:

- [ ] El documento existe en Firestore > usuarios
- [ ] El campo `tipo` es exactamente `"psicologo"` (minúsculas)
- [ ] El campo `activo` es boolean `true` (NO string)
- [ ] El usuario existe en Authentication
- [ ] El UID en Firestore coincide con el UID en Authentication
- [ ] Las reglas de Firestore permiten lectura
- [ ] Los índices están creados (si es necesario)
- [ ] La app tiene conexión a internet
- [ ] Firebase está inicializado correctamente

---

## 🆘 Si Nada Funciona

1. **Elimina el psicólogo** (tanto de Authentication como de Firestore)
2. **Créalo de nuevo** usando el script `crear_psicologo_prueba.dart`
3. **Verifica en tiempo real** que se creó correctamente
4. **Reinicia la app** y prueba de nuevo

Si el problema persiste, comparte:
- Screenshot del documento en Firestore
- Los logs de la consola
- El error exacto que aparece

---

## 📝 Ejemplo de Documento Correcto

Así debe verse en Firebase Console:

```
Document: abc123xyz456
├─ email: "jperez@ucss.edu.pe" (string)
├─ tipo: "psicologo" (string)
├─ activo: true (boolean) ← ¡NO "true" como string!
├─ nombres: "" (string)
├─ apellidos: "" (string)
└─ fechaCreacion: October 8, 2024 at 10:30:00 AM UTC-5 (timestamp)
```

¡NO debe verse así!:

```
Document: abc123xyz456
├─ email: "jperez@ucss.edu.pe" (string)
├─ tipo: "Psicologo" (string) ← ❌ Mayúscula incorrecta
├─ activo: "true" (string) ← ❌ String en lugar de boolean
├─ nombres: "" (string)
├─ apellidos: "" (string)
└─ fechaCreacion: October 8, 2024 at 10:30:00 AM UTC-5 (timestamp)
```
