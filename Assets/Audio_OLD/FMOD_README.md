# Guía de FMOD - Project III

Esta guía explica cómo está integrada la solución de audio **FMOD** en el proyecto, cubriendo desde la estructura básica hasta el uso en código mediante C#.

---

## 1. Flujo de Trabajo (Studio -> Unity)

Para que todo funcione "bien", sigue siempre este orden:
1. **En FMOD Studio**: Diseña tus eventos, asígnalos a los Bancos (Banks) y dale a `File -> Build`.
2. **En Unity**: Asegúrate de que los bancos se hayan copiado a la carpeta de StreamingAssets (o según tu configuración).
3. **Vincular**: Usa el tipo `EventReference` en tus scripts para poder elegir el sonido desde el Inspector con la lupa.
4. **Reproducir**: Decide si necesitas un `OneShot` (simple) o una `Instance` (si quieres cambiar parámetros mientras suena).

---

Los assets y scripts relacionados con el audio se encuentran en:
- `Assets/Audio/`: Contiene los bancos de FMOD, eventos y esta guía.
- `Assets/Plugins/FMOD/`: Integración oficial de FMOD para Unity.
- `Assets/Scripts/Audio/`: Scripts de control de audio (`AudioManager.cs`, `PlayerAudio.cs`, etc.).

---

## 2. AudioManager (Singleton Global)

El `AudioManager` es el punto central para sonidos globales como música, ambiente y UI. Permanece activo entre escenas (`DontDestroyOnLoad`).

### Funcionalidades Principales:
- **Gestión de Zonas**: Utiliza `SetZone(ZoneType zone)` para cambiar entre Beach, Forest, Volcano, etc. Esto detiene la música anterior e inicia la nueva automáticamente.
- **Parámetros Globales**: Controla parámetros que afectan a múltiples eventos simultáneamente:
    - `Zone`: Indica la bioma actual.
    - `InkState`: Cambia el tono del audio según el estado de la tinta.
    - `UnderInk`: Aplica filtros de audio cuando el jugador está sumergido.
- **Snapshots de Pausa**: Al pausar el juego mediante `SetPaused(bool)`, se activa un snapshot de FMOD que puede atenuar la música o aplicar filtros (low-pass) de forma no destructiva.

---

## 3. PlayerAudio (Audio del Jugador)

Este componente gestiona todos los sonidos producidos por el personaje y sus mecánicas (salto, pintura, natación).

### Eventos y Parámetros:
- **OneShots**: Sonidos rápidos como el salto o impactos. Se ejecutan con `RuntimeManager.PlayOneShot(eventReference, position)`.
- **Event Instances (Loops)**: Sonidos continuos como el caminar o el nado.
    - Se crean en el `Start()` con `RuntimeManager.CreateInstance()`.
    - Se controlan con `.start()` y `.stop(STOP_MODE.ALLOWFADEOUT)`.
- **Pasos Dinámicos**: La función `UpdateFootsteps` utiliza parámetros para ajustar el audio:
    - `PlayerSpeed`: Velocidad del jugador.
    - `SurfaceType`: Cambia la textura del sonido según el suelo (Madera, Arena, etc.).

---

## 4. Uso en Código (C#)

### Conceptos Clave:
1. **EventReference**: Es el "selector" que ves en el Inspector de Unity. Permite elegir eventos de FMOD visualmente.
2. **EventInstance**: Una instancia de un sonido que puedes manipular mientras suena (cambiar volumen, parámetros o detenerlo).
3. **RuntimeManager**: La clase principal para interactuar con el motor de FMOD desde Unity.

### Ejemplo de Reproducción Simple:
```csharp
[SerializeField] private EventReference miSonido;

void Reproducir() {
    RuntimeManager.PlayOneShot(miSonido, transform.position);
}
```

### Ejemplo de Sonido con Parámetros y Auto-Liberación:
```csharp
void ReproducirConParametro(float valor) {
    EventInstance instance = RuntimeManager.CreateInstance(miSonido);
    instance.setParameterByName("MiParametro", valor);
    instance.start();
    
    // Al llamar a release() justo después de start(), FMOD marcará la 
    // instancia para destruirse automáticamente en cuanto termine de sonar.
    instance.release(); 
}
```

---

## 5. Mejores Prácticas y Gestión de Memoria

### El uso de `instance.release()`
Es fundamental para evitar fugas de memoria (memory leaks). Tienes dos estrategias principales:

1. **Fire & Forget (Disparar y Olvidar)**: 
   Si creas una instancia solo para dispararla una vez (por ejemplo, para ponerle un parámetro inicial), llama a `release()` inmediatamente después de `start()`. El sonido se reproducirá completo y FMOD limpiará los recursos al finalizar.
1. **Instancias Persistentes (Loops/Pasos)**:
   Si mantienes una referencia a la instancia para usarla varias veces (como los pasos del jugador), **no** llames a `release()` hasta que el objeto de Unity sea destruido.
   ```csharp
   private void OnDestroy() {
       if (instance.isValid()) {
           instance.stop(STOP_MODE.IMMEDIATE);
           instance.release();
       }
   }
   ```

### Liberar memoria sin cortar el sonido (Fire & Forget)
Si quieres disparar un sonido y que FMOD lo limpie solo **sin cortarlo**, simplemente llama a `release()` justo después de `start()`:
```csharp
instance.start();
instance.release(); // El sonido NO se detiene. Se liberará AL ACABAR.
```

### Liberar memoria con Fadeout (Muerte suave)
Si quieres detener el sonido con un desvanecimiento y liberar la memoria, puedes hacer las dos cosas a la vez. FMOD esperará a que el fadeout termine antes de liberar la instancia:
```csharp
instance.stop(STOP_MODE.ALLOWFADEOUT);
instance.release(); // El sonido hará el fadeout completo y luego se liberará.
```

---

## 5. Mejores Prácticas (Uso Correcto)

- **Regla de Oro**: Si haces un `CreateInstance`, tiene que haber un `release`. Si no, tendrás "fugas de memoria" (el juego irá cada vez más lento).
- **No repitas**: No crees instancias dentro de un `Update()`. Crea la instancia una vez en `Start()` y guárdala en una variable.
- **Seguridad**: Comprueba siempre `!eventReference.IsNull` antes de intentar reproducir un sonido para evitar errores en consola si el evento no está asignado.
- **Snapshots**: Utiliza Snapshots para cambios globales (mezcla de audio en menús o momentos de baja vida) en lugar de modificar volúmenes individuales.
- **Limpieza**: Si un objeto de Unity se destruye pero su sonido sigue sonando (un loop), ese sonido se quedará "huérfano" y gastando recursos si no lo detienes y liberas en `OnDestroy`.

---

## 6. Errores Comunes (¡Evítalos!)

> [!CAUTION]
> **Crear instancias en el Update**: NUNCA uses `RuntimeManager.CreateInstance` dentro de un `Update()`. Esto creará miles de instancias por segundo y colapsará el motor de audio y la memoria.
> 
> **Reutilizar Instancias Detenidas**: Si una instancia ya se ha detenido y liberado, no puedes volver a llamarla con `start()`. Debes crear una nueva o mantenerla viva sin liberarla hasta el final.
> 
> **Olvidar el Listener**: Si no escuchas nada en 3D, asegúrate de que solo haya UN `FMOD Unity Listener` en tu escena (normalmente en la cámara principal).
> 
> **Falta de Release**: Olvidar `instance.release()` es el error #1. Cada vez que creas una instancia, FMOD reserva memoria que no se libera sola aunque el sonido termine, a menos que uses OneShot o llames a release.

---

- **"Bank not loaded"**: Asegúrate de que los bancos de FMOD estén en la carpeta `StreamingAssets` y configurados correctamente en *FMOD -> Settings*.
- **Sin Sonido**: Verifica que el `FMOD Unity Listener` esté presente en la cámara principal.
- **Parámetros no funcionan**: Revisa que el nombre del parámetro en el código coincida EXACTAMENTE con el nombre definido en el FMOD Studio (mayúsculas y minúsculas importan).
