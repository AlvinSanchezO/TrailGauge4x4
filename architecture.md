# Documentación Arquitectónica y Patrones de Diseño: TrailGauge 4x4
## Sistema de Telemetría de Precisión y Seguridad Activa

Este documento establece los lineamientos técnicos, la arquitectura de software y la estructura de directorios para el desarrollo de TrailGauge 4x4 en Flutter. El objetivo de esta arquitectura es aislar el procesamiento matemático intensivo de los sensores físicos para garantizar una interfaz de usuario (UI) fluida y libre de bloqueos durante la navegación off-road.

---

## 1. Patrón Arquitectónico: Clean Architecture (Feature-First)

El proyecto adopta un enfoque de **Clean Architecture** organizado por funcionalidades (Feature-First). Dado que el sistema depende de hardware específico (giroscopio, acelerómetro, antena GPS) y servicios externos (Open-Elevation API), es obligatorio desacoplar la interfaz gráfica de la recolección de datos.

Cada "Feature" (módulo) se dividirá estrictamente en tres capas:

1.  **Capa de Datos (Data):**
    *   **Responsabilidad:** Única capa autorizada para comunicarse con el hardware (paquetes como `sensors_plus`, `geolocator`) o hacer peticiones de red (API de altitud).
    *   **Componentes:** Data Sources (orígenes de datos crudos) y Repositories (implementación de los contratos).
2.  **Capa de Dominio (Domain):**
    *   **Responsabilidad:** El cerebro del sistema. Contiene la lógica de negocio pura y agnóstica al framework.
    *   **Componentes:** Entidades (ej. `VehicleAttitude`, `GeoCoordinates`), Casos de Uso, y los algoritmos matemáticos críticos (Filtro de Paso Bajo, compensador de matriz de tara, y cálculo predictivo del 15% para suspensiones elevadas)[cite: 1, 2].
3.  **Capa de Presentación (Presentation):**
    *   **Responsabilidad:** Mostrar información al usuario y capturar sus interacciones. Debe ser lo más "tonta" posible.
    *   **Componentes:** Widgets de Flutter (ej. el horizonte artificial, las tarjetas numéricas) y Gestores de Estado[cite: 1, 2].

---

## 2. Patrones de Diseño y Gestión de Estado

*   **Gestor de Estado (Riverpod):** Se utilizará Riverpod como motor reactivo. Al tratar con flujos continuos de datos (Streams) generados por los sensores y el GPS, Riverpod permite escuchar estos eventos en segundo plano y reconstruir únicamente los widgets necesarios (como el texto numérico de Pitch/Roll o la rotación del carro) a frecuencias de 45Hz-100Hz sin afectar el rendimiento global de la aplicación[cite: 1, 2].
*   **Patrón de Repositorio (Repository Pattern):** Define interfaces estrictas en la capa de Dominio. La Presentación pide "dame las coordenadas" sin saber si vienen del hardware del teléfono o de un simulador de pruebas, lo que facilita enormemente el testing[cite: 1, 2].
*   **Inyección de Dependencias:** Todos los servicios, repositorios y casos de uso serán inyectados a través de los Providers de Riverpod, manteniendo el código modular y acoplado de forma débil.

---

## 3. Estructura de Directorios

El código fuente dentro de `lib/` seguirá la siguiente jerarquía para reflejar el flujo de navegación descentralizado (Clinómetro, Telemetría y Configuración)[cite: 2]:

```text
.
├── assets/
│   └── images/                         # Recursos gráficos (logos, iconos nativos)
│
├── lib/
│   ├── main.dart
├── core/                               # Utilidades y configuraciones globales
│   ├── errors/                         # Clases para manejo de excepciones (ej. GPS sin señal)
│   ├── theme/                          # UI táctica, colores de alto contraste y tipografía
│   ├── constants/                      # Keys de APIs y umbrales globales por defecto
│   └── utils/                          # Funciones matemáticas puras compartidas
│
└── features/                           # Módulos independientes del sistema
    │
    ├── navigation_menu/                # Bottom Navigation Bar (Persistencia 1-Tap)
    │   └── presentation/               # Controlador de índices y persistencia de UI
    │
    ├── clinometer/                     # Pantalla 1: Estabilidad
    │   ├── data/                       # Lectura cruda de giroscopio y acelerómetro
    │   ├── domain/                     # Aplicación del Filtro de Paso Bajo y alertas dinámicas
    │   └── presentation/               # Widgets: Horizonte artificial, contadores Pitch/Roll
    │
    ├── telemetry/                      # Pantalla 2: Geoespacial
    │   ├── data/                       # Geolocalizador satelital y Open-Elevation API
    │   ├── domain/                     # Traducción GPS a formato DMS y filtro de altitud
    │   └── presentation/               # Tarjetas duales y renderizado del Stream topográfico
    │
    └── settings/                       # Pantalla 3: Ajustes y Calibración
        ├── data/                       # Almacenamiento local (SharedPreferences/Hive)
        ├── domain/                     # Lógica de Tara (0°) y modificación de límites (suspensión)
        └── presentation/               # Sliders analógicos, radio buttons y panel de diagnóstico