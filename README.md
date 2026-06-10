# TrailGauge 4x4 🧭

TrailGauge 4x4 is a tactical, high-performance Flutter application designed for off-road enthusiasts and overlanding professionals. It provides real-time telemetry, inertial monitoring, and environmental awareness to ensure safety and precision during off-grid driving.

## ✨ Features

### 📐 Active Clinometer (Pitch & Roll)
- **Real-Time Attitude Monitoring:** Precise measurement of your vehicle's pitch and roll angles.
- **Artificial Horizon:** Visual representation of the vehicle's inclination with dynamic wireframe styling.
- **Dynamic Safety States:** Visual alerts (Safe, Warning, Critical Danger) that adapt based on the current inclination and user-defined thresholds.

### 🛰️ Advanced Telemetry & GPS
- **Speed & Altitude Tracking:** Real-time speed and altitude readouts (with fallback between GPS and topographic APIs).
- **Rescue Transmission (DMS):** Critical location data formatted in Degrees, Minutes, Seconds (DMS) for quick relay to emergency rescue protocols.
- **Topographic Elevation Profile:** A dynamic, smoothly scrolling `fl_chart` that visualizes the terrain's elevation profile in real-time using a 25-point rolling circular buffer.

### ⚙️ Calibration & Settings
- **Inertial Module Calibration:** Reset the clinometer to a strict 0° artificial horizon when on level ground.
- **Custom Safety Limits:** Adjustable Pitch and Roll warning limits via intuitive sliders.
- **Suspension Geometry Algorithms:** Select between 'OEM Stock' and 'Modified (Elevated)' modes to automatically adjust the center of gravity calculations for safer limit estimation on modified rigs.

## 🎨 Visual Identity & UI
TrailGauge utilizes a custom **"Titanium & Sahara Gold"** high-end dark mode aesthetic optimized for tactical and high-contrast interfaces:
- **Neutral Scaffold:** Titanium Black (`#090A0C`)
- **Secondary Surfaces:** Deep Charcoal (`#14171C`)
- **Primary Accents:** Sahara Gold (`#C5A059`)
- **Tertiary UI:** Blue-Grey (`#64748B`)

Modern card interfaces (12px radius) and sophisticated typographies create a premium off-road dashboard feel.

## 🛠️ Architecture & Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [Riverpod](https://riverpod.dev/) (`flutter_riverpod`) utilizing clean state boundaries.
- **Data Visualization:** `fl_chart` for dynamic sensor streams.
- **Architecture:** Clean Architecture separation (Presentation, Domain, and Data layers). 

### 🏛️ Global System Architecture
The application follows a strict Clean Architecture pattern, segregating hardware interactions from business logic and UI states using Riverpod for dependency injection and reactive state management.

```mermaid
graph TD
    subgraph Data Layer
        GPS[GPS/Location API] -.-> TelemetryRepo(TelemetryRepositoryImpl)
        IMU[Gyro & Accelerometer] -.-> ClinometerRepo(ClinometerRepositoryImpl)
        Prefs[Local Storage] -.-> SettingsRepo(SettingsRepositoryImpl)
    end

    subgraph Domain Layer
        TelemetryRepo --> GeoEntity{GeoCoordinates}
        ClinometerRepo --> AttEntity{VehicleAttitude}
        SettingsRepo --> SettingsEntity{Limits & Algorithms}
    end

    subgraph Presentation Layer [Riverpod State Management]
        GeoEntity --> TelemetryProv[Telemetry Providers]
        AttEntity --> ClinometerProv[Clinometer Providers]
        SettingsEntity --> SettingsProv[Settings Providers]
        
        SettingsProv -.->|Dynamic Modifiers| ClinometerProv
    end

    subgraph User Interface
        TelemetryProv --> TelemetryUI[Telemetry Screen]
        ClinometerProv --> ClinometerUI[Clinometer Screen]
        SettingsProv --> SettingsUI[Settings Screen]
        
        TelemetryUI --- Nav(Bottom Navigation)
        ClinometerUI --- Nav
        SettingsUI --- Nav
    end
    
    style GPS fill:#090A0C,stroke:#64748B,color:#FFFFFF
    style IMU fill:#090A0C,stroke:#64748B,color:#FFFFFF
    style Prefs fill:#090A0C,stroke:#64748B,color:#FFFFFF
    
    style TelemetryRepo fill:#14171C,stroke:#C5A059,color:#C5A059
    style ClinometerRepo fill:#14171C,stroke:#C5A059,color:#C5A059
    style SettingsRepo fill:#14171C,stroke:#C5A059,color:#C5A059
    
    style GeoEntity fill:#090A0C,stroke:#C5A059,color:#FFFFFF
    style AttEntity fill:#090A0C,stroke:#C5A059,color:#FFFFFF
    style SettingsEntity fill:#090A0C,stroke:#C5A059,color:#FFFFFF
    
    style TelemetryProv fill:#C5A059,stroke:#090A0C,color:#090A0C
    style ClinometerProv fill:#C5A059,stroke:#090A0C,color:#090A0C
    style SettingsProv fill:#C5A059,stroke:#090A0C,color:#090A0C
    
    style TelemetryUI fill:#14171C,stroke:#64748B,color:#FFFFFF
    style ClinometerUI fill:#14171C,stroke:#64748B,color:#FFFFFF
    style SettingsUI fill:#14171C,stroke:#64748B,color:#FFFFFF
    style Nav fill:#090A0C,stroke:#C5A059,color:#C5A059
```

### 🧠 Telemetry Data Flow
The following diagram illustrates how real-time GPS telemetry is processed through Riverpod to create the dynamic elevation profile:

```mermaid
graph TD
    GPS[GPS Hardware Sensor] -->|Stream of GeoCoordinates| Repo(Telemetry Repository)
    Repo -->|Yields AsyncValue| StreamProv{locationStreamProvider}
    
    StreamProv -->|Listens & Extracts Altitude| HistoryNotif[ElevationHistoryNotifier]
    HistoryNotif -->|Adds to List & Removes Oldest| Buffer[(25-Point Circular Buffer)]
    
    Buffer -->|State Change Triggers UI Rebuild| UI[TelemetryScreen]
    UI -->|Maps to FlSpot Vectors| Chart[fl_chart LineChart]
    
    style GPS fill:#14171C,stroke:#C5A059,color:#FFFFFF
    style Repo fill:#090A0C,stroke:#64748B,color:#FFFFFF
    style StreamProv fill:#14171C,stroke:#C5A059,color:#C5A059
    style HistoryNotif fill:#14171C,stroke:#64748B,color:#FFFFFF
    style Buffer fill:#090A0C,stroke:#C5A059,color:#FFFFFF
    style UI fill:#14171C,stroke:#64748B,color:#FFFFFF
    style Chart fill:#C5A059,stroke:#090A0C,color:#090A0C
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK
- Android Studio / Xcode for deployment

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/AlvinSanchezO/TrailGauge4x4.git
   ```
2. Navigate to the project directory:
   ```bash
   cd trail_gauge_4x4
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/AlvinSanchezO/TrailGauge4x4/issues) if you want to contribute.

## 📝 License

This project is licensed under the MIT License.
