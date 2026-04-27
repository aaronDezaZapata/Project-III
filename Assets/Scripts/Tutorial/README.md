# Tutorial Scripts

Esta carpeta contiene los scripts necesarios para gestionar el sistema de tutoriales en el juego. El sistema se basa en un gestor de interfaz de usuario (UI) y activadores (triggers) colocados en el mundo.

## Scripts

### 1. [TutorialUIManager.cs](file:///c:/Users/gemma/Documents/Project-III/Assets/Scripts/Tutorial/TutorialUIManager.cs)
Este script es un **Singleton** que gestiona la visualización de los mensajes de tutorial en la pantalla.

*   **Funcionalidad**:
    *   Mueve una caja de texto (tutorialBox) entre una posición oculta y una visible usando una animación suave (`Lerp`).
    *   Actualiza el contenido del texto dinámicamente.
*   **Configuración en el Inspector**:
    *   `Tutorial Box`: El RectTransform del panel que contiene el tutorial.
    *   `Tutorial Text`: El componente TextMeshPro que mostrará el mensaje.
    *   `Hidden/Visible Position`: Las coordenadas locales para las posiciones de oculto y visible.
    *   `Animation Speed`: Velocidad a la que aparece/desaparece el mensaje.

### 2. [TutorialTrigger.cs](file:///c:/Users/gemma/Documents/Project-III/Assets/Scripts/Tutorial/TutorialTrigger.cs)
Este script se coloca en objetos con un componente **Collider** configurado como **Is Trigger**.

*   **Funcionalidad**:
    *   Cuando el jugador entra en el área del trigger, llama a `TutorialUIManager` para mostrar un mensaje específico.
    *   Cuando el jugador sale del área, oculta el mensaje.
*   **Configuración en el Inspector**:
    *   `Tutorial Message`: El texto que quieres que aparezca (soporta múltiples líneas).
    *   `Player Tag`: El tag que debe tener el objeto para activar el tutorial (por defecto "Player").

## Cómo usar el sistema

1.  **Configurar el Manager**:
    *   Crea un objeto en tu escena (normalmente dentro del Canvas) y añádele el componente `TutorialUIManager`.
    *   Configura las referencias y las posiciones en el Inspector.
2.  **Crear Triggers**:
    *   Crea un objeto vacío en la escena con un Collider (ej. Box Collider) y marca `Is Trigger`.
    *   Añade el componente `TutorialTrigger`.
    *   Escribe el mensaje que quieres mostrar en el campo `Tutorial Message`.
3.  **Asegurar Tags**:
    *   Asegúrate de que el objeto del jugador tenga el tag "Player".
