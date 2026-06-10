# Casos de Prueba Tácticos y Reglas de Negocio: TrailGauge 4x4
## Sistema de Telemetría de Precisión y Seguridad Activa

Este documento establece los criterios de aceptación, reglas de negocio y especificaciones de pruebas de caja negra/funcionales para validar la correcta implementación del sistema en Flutter, tomando como referencia los diagramas funcionales en `Navegacion.png`, `wireframe 1.png`, `wireframe 2.png` y `wireframe 3.png`[cite: 1, 2].

---

## REGLAS DE NEGOCIO DEL SISTEMA (BR)

### BR-01: Frecuencia y Filtro de Sensores Inerciales
*   **Especificación:** Las lecturas crudas del giroscopio y acelerómetro provistas por la API de sensores deben ser procesadas mediante un algoritmo de Filtro de Paso Bajo (Low-Pass Filter) antes de ser enviadas a la interfaz de usuario[cite: 1, 2].
*   **Lógica del Filtro:** 
    *   alpha = delta_t / (tau + delta_t)
    *   Y[n] = alpha * X[n] + (1 - alpha) * Y[n-1]
    *   Donde X[n] es la lectura actual del sensor, Y[n] es el valor filtrado, y alpha es el factor de suavizado calibrado para una frecuencia objetivo estable (entre 45Hz y 100Hz) en entornos de alta vibración mecánica o terracería agresiva[cite: 1, 2].
*   **Propósito:** Aislar y eliminar las frecuencias parásitas generadas por el motor del chasis off-road y las sacudidas bruscas de la ruta, garantizando un movimiento suave y legible de la silueta del vehículo en pantalla[cite: 1, 2].

### BR-02: Compensador Inteligente de Orientación (Matriz de Tara)
*   **Especificación:** El sistema debe permitir la calibración a cero absoluto (0°) sin importar el ángulo físico en el que el usuario fije el soporte del teléfono en el tablero[cite: 1, 2].
*   **Lógica:** Al presionar "CALIBRAR A CERO (0°)", se captura la orientación actual como offsets (pitch_offset, roll_offset)[cite: 1, 2]. Las mediciones subsecuentes se calcularán como:
    *   Pitch_Desplegado = Pitch_Filtrado - pitch_offset
    *   Roll_Desplegado = Roll_Filtrado - roll_offset
*   **Persistencia:** Este offset de calibración debe almacenarse de forma permanente en el almacenamiento local del dispositivo para evitar re-calibraciones en cada inicio del sistema[cite: 2].

### BR-03: Geometría Adaptativa según Perfil de Suspensión
*   **Especificación:** Las tolerancias de riesgo y la sensibilidad del algoritmo de estabilidad deben modificarse dinámicamente según la geometría física declarada del vehículo off-road[cite: 1, 2].
*   **Modo OEM Stock de Fábrica:** Utiliza los límites de peligro estándar definidos por el usuario de forma directa mediante los controles analógicos (sliders)[cite: 1, 2].
*   **Modo Modificada (Elevada):** Diseñado para vehículos con kits de elevación de suspensión de +3 pulgadas o superiores[cite: 2]. El sistema reduce de forma automática un 15% los umbrales máximos tolerados de Roll y Pitch configurados en los sliders debido al desplazamiento ascendente del centro de gravedad, haciendo que las alertas de seguridad se disparen de manera más estricta y preventiva[cite: 1, 2].

### BR-04: Persistencia de Procesamiento en Segundo Plano (Background Streams)
*   **Especificación:** La captura de datos satelitales (GPS) y la evaluación inercial del estado de riesgo del chasis son procesos críticos que pertenecen a la capa de dominio/servicios y no a la capa de presentación[cite: 2].
*   **Comportamiento:** Si el usuario conmuta a las pantallas de Telemetría o Configuración, los streams de datos inerciales de Pitch y Roll deben continuar abiertos y procesándose en segundo plano[cite: 2]. Si ocurre una violación de los límites de riesgo configurados mientras la UI muestra otra pantalla, el sistema debe disparar la advertencia sonora y forzar la alerta visual de cabina de inmediato[cite: 1, 2].

### BR-05: Protocolo de Rescate y Geolocalización Dual
*   **Especificación:** El procesamiento de la geolocalización debe exponer simultáneamente dos formatos de salida de datos a partir de la misma trama satelital[cite: 1, 2]:
    1.  **Formato Decimal:** Para visualización e integración estándar con mapas digitales (ej. Lat 32.5149° N / Lon 117.0382° W)[cite: 1, 2].
    2.  **Formato DMS (Grados, Minutos, Segundos):** Calculado matemáticamente en tiempo real (ej. 32°30'53" N / 117°02'17" W)[cite: 1, 2]. Este formato se renderiza en una tarjeta de alto contraste dedicada para dictarse por radio de banda VHF/UHF en situaciones de rescate o pérdida de conectividad de datos[cite: 1, 2].
*   **Altitud Real:** El sistema debe ignorar los datos de altitud barométrica del teléfono debido a su inestabilidad frente a cambios climáticos y, en su lugar, priorizar la resolución del relieve haciendo peticiones asíncronas a la API de Open-Elevation cruzando las coordenadas GPS[cite: 1, 2].

---

## CASOS DE PRUEBA ASOCIADOS

### 1. Módulo de Navegación Global (Persistencia y Flujo)
**Referencia:** `Navegacion.png`[cite: 1, 2]

#### TC-NAV-01: Inicialización Rápida del Sistema
*   **Objetivo:** Validar que la aplicación inicie directamente en el modo operativo crítico[cite: 2].
*   **Precondiciones:** Aplicación cerrada por completo.
*   **Pasos:**
    1. Iniciar la aplicación TrailGauge 4x4.
*   **Resultado Esperado:** La aplicación debe renderizar de forma inmediata la **Pantalla 1: Clinómetro** sin pantallas de carga prolongadas, activando los escuchas de los sensores inerciales en segundo plano[cite: 1, 2].

#### TC-NAV-02: Navegación Indexada Fija (1-Tap)
*   **Objetivo:** Verificar la conmutación instantánea entre los tres módulos principales[cite: 2].
*   **Precondiciones:** Aplicación en pantalla de inicio.
*   **Pasos:**
    1. Presionar el segundo ícono ("Telemetría") en la Bottom Navigation Bar (`Navegacion.png`)[cite: 1, 2].
    2. Presionar el tercer ícono ("Configuración") en la Bottom Navigation Bar[cite: 1, 2].
    3. Presionar el primer ícono ("Clinómetro") en la Bottom Navigation Bar[cite: 1, 2].
*   **Resultado Esperado:** El cambio de interfaz debe ser fluido e instantáneo[cite: 2]. La barra de navegación debe permanecer fija en la base en todo momento[cite: 1, 2].

#### TC-NAV-03: Persistencia de Estado en Segundo Plano (Cumplimiento BR-04)
*   **Objetivo:** Garantizar que el cambio de interfaz no destruya el flujo de datos de los sensores[cite: 2].
*   **Precondiciones:** Vehículo en movimiento o dispositivo simulando inclinación/desplazamiento.
*   **Pasos:**
    1. Estar en la pantalla de *Clinómetro* visualizando cambios de ángulos[cite: 1, 2].
    2. Cambiar a la pantalla de *Configuración*[cite: 1, 2].
    3. Permanecer 5 segundos en configuración y regresar a la pantalla de *Clinómetro*[cite: 2].
*   **Resultado Esperado:** Al regresar, el horizonte artificial y los datos numéricos de Pitch y Roll deben actualizarse instantáneamente sin retrasos ni pérdidas de paquetes de datos (el Stream de datos no debe cerrarse)[cite: 2].

---

### 2. Pantalla 1: Clinómetro y Seguridad Activa
**Referencia:** `wireframe 1.png`[cite: 1, 2]

#### TC-CLIN-01: Fusión de Sensores (Pitch & Roll)
*   **Objetivo:** Verificar la correcta lectura y renderizado matemático de la orientación del chasis[cite: 1, 2].
*   **Pasos:**
    1. Inclinar el dispositivo hacia adelante (Cabeceo / Pitch)[cite: 1, 2].
    2. Inclinar el dispositivo hacia la derecha (Inclinación lateral / Roll)[cite: 1, 2].
*   **Resultado Esperado:** 
    *   El indicador de **PITCH** debe marcar "X° UP" o "X° DOWN" según corresponda[cite: 1, 2].
    *   El indicador de **ROLL** debe marcar "X° R" o "X° L"[cite: 1, 2].
    *   La silueta del vehículo off-road en el área central circular debe rotar de forma fluida reflejando el ángulo real filtrado a la frecuencia objetivo de la interfaz (ej. 45Hz)[cite: 1, 2].

#### TC-CLIN-02: Filtro de Paso Bajo (Cumplimiento BR-01)
*   **Objetivo:** Evitar que las vibraciones del motor afecten la lectura visual[cite: 1, 2].
*   **Pasos:**
    1. Someter el dispositivo a micro-vibraciones rápidas e intensas (simulando un motor diésel o terracería agresiva)[cite: 1, 2].
*   **Resultado Esperado:** Los indicadores numéricos y la silueta del vehículo deben amortiguar el ruido mecánico, mostrando un movimiento suave y legible en lugar de oscilaciones erráticas en la interfaz[cite: 1, 2].

#### TC-CLIN-03: Alertas Dinámicas de Riesgo
*   **Objetivo:** Validar el cambio de estado de seguridad ante límites superados[cite: 1, 2].
*   **Precondiciones:** Límites configurados en 30° para Roll y 35° para Pitch[cite: 2].
*   **Pasos:**
    1. Inclinar lateralmente el dispositivo hasta alcanzar los 31° de Roll[cite: 2].
*   **Resultado Esperado:** El contenedor de texto destacado inferior debe cambiar inmediatamente de estatus: de `[ESTADO: SEGURO]` a un mensaje de alerta de alta prioridad visual en cabina, activando de forma paralela la advertencia acústica intermitente de alta frecuencia[cite: 1, 2].

---

### 3. Pantalla 2: Telemetría Geoespacial Dual
**Referencia:** `wireframe 2.png`[cite: 1, 2]

#### TC-TELEM-01: Doble Formato de Coordenadas Satelitales (Cumplimiento BR-05)
*   **Objetivo:** Validar la disponibilidad simultánea de formatos de geolocalización[cite: 1, 2].
*   **Precondiciones:** Conexión de GPS (Satélite) activa[cite: 2].
*   **Pasos:**
    1. Visualizar la sección media de la pantalla de Telemetría[cite: 1, 2].
*   **Resultado Esperado:** 
    *   La tarjeta superior de geolocalización debe mostrar la Latitud/Longitud en formato **Decimal** (ej. `Lat 32.5149° N / Lon 117.0382° W`)[cite: 1, 2].
    *   La tarjeta de alto contraste inferior debe mostrar exactamente la misma posición traducida en tiempo real a formato **DMS (Grados, Minutos, Segundos)** para transmisiones por radio VHF/UHF de emergencia[cite: 1, 2].

#### TC-TELEM-02: Consumo de Altitud por API (Filtro Barométrico / BR-05)
*   **Objetivo:** Validar que la altitud provenga de la API cartográfica y no del sensor barométrico interno del teléfono[cite: 1, 2].
*   **Pasos:**
    1. Simular un cambio de coordenadas GPS en una zona montañosa[cite: 2].
*   **Resultado Esperado:** El bloque de "ALTITUD (API)" debe cruzar los datos de Lat/Lon con el servidor externo de Open-Elevation para desplegar la altitud exacta en metros sobre el nivel del mar (msnm), ignorando los cambios de presión atmosférica local causados por el clima[cite: 1, 2].

#### TC-TELEM-03: Stream del Perfil de Ruta
*   **Objetivo:** Verificar la renderización bidimensional del relieve topográfico[cite: 2].
*   **Pasos:**
    1. Avanzar por una ruta de expedición predefinida[cite: 2].
*   **Resultado Esperado:** El panel gráfico inferior "Elevation Data Stream" debe dibujar de forma progresiva e interactiva el relieve topográfico acumulado en el plano dimensional (Eje X: Distancia en km, Eje Y: Altitud en metros)[cite: 1, 2].

---

## 4. Pantalla 3: Ajustes, Calibración y Geometría
**Referencia:** `wireframe 3.png`[cite: 1, 2]

#### TC-CAL-01: Compensador Inteligente (Calibración en Cero / Tara / BR-02)
*   **Objetivo:** Validar la neutralización del ángulo del soporte físico en el tablero del vehículo[cite: 1, 2].
*   **Precondiciones:** Colocar el teléfono de forma arbitraria e inclinada sobre una superficie fija (ej. simulando un soporte descentrado en el tablero)[cite: 1, 2].
*   **Pasos:**
    1. Presionar el botón destacado **`CALIBRAR A CERO (0°)`**[cite: 1, 2].
*   **Resultado Esperado:** El software debe guardar la orientación actual de la matriz de sensores como el nuevo punto de origen[cite: 1, 2]. De inmediato, los contadores de Pitch y Roll en la Pantalla 1 deben pasar a marcar `0°`, alineando el horizonte artificial con el chasis del vehículo a nivel horizontal[cite: 1, 2].

#### TC-CAL-02: Modificación Dinámica de Umbrales (Sliders)
*   **Objetivo:** Ajustar los límites de activación de las alertas acústicas y visuales[cite: 1, 2].
*   **Pasos:**
    1. Deslizar el control analógico de "Límite Roll" hasta fijarlo en `30°`[cite: 1, 2].
    2. Deslizar el control analógico de "Límite Pitch" hasta fijarlo en `35°`[cite: 1, 2].
*   **Resultado Esperado:** Los nuevos valores límite deben actualizarse instantáneamente en la memoria local del dispositivo y reflejarse en las etiquetas numéricas a la derecha de cada slider[cite: 1, 2].

#### TC-CAL-03: Conmutación de Perfiles de Suspensión (Algoritmo Adaptativo / BR-03)
*   **Objetivo:** Adaptar las tolerancias de riesgo según el centro de gravedad físico del vehículo[cite: 1, 2].
*   **Pasos:**
    1. Seleccionar mediante el Radio Button la opción **`MODIFICADA (ELEVADA)`**[cite: 1, 2].
*   **Resultado Esperado:** El sistema debe conmutar internamente al algoritmo restrictivo de transferencia de masas[cite: 2]. Si el usuario fijó los sliders en 30° de Roll y 35° de Pitch, el umbral real de disparo interno pasará automáticamente a ser de 25.5° y 29.75° respectivamente (reducción predictiva del 15% por centro de gravedad elevado)[cite: 2].