# E-Ink Waveform Visualizer - Technical Roadmap

This document outlines the strategic development plan to evolve the project from a **Passive Analyzer** into an **Active Authoring & Simulation Suite**.

## 📍 Current Status (v1.0.0)
- **Core**: PVI/RKF binary parsing & voltage decoding.
- **Vis**: Dynamic voltage charts & 16x16 LUT matrix heatmap.
- **Meta**: Header analysis, temperature segmentation, and CSV data export.

---

## 🚀 Phase 2: Optical Simulation (The "Physics" Layer)
*Objective: Move beyond showing "Voltage" to showing "Resulting Color".*

### 2.1 Electrophoretic Particle Model (EPM)
instead of just seeing `+15V` or `-15V`, we simulate the physical movement of Black/White particles inside the microcapsule.
- **Viscosity Model**: Implement a friction coefficient that changes with the `Temperature` index (colder = slower movement).
- **Integration**: Calculate the integral of `Voltage * Time` to estimate particle position.
- **Reflectance Mapping**: Map the particle position (0.0 - 1.0) to an estimated L* (Lightness) value.

### 2.2 Visual Preview Widget
- Add a **"Virtual Pixel"** preview box next to the waveform chart.
- As the animation plays, this pixel continuously changes shade (White -> Gray -> Black) based on the EPM model.
- Allows engineers to see if a waveform is "over-driving" (hitting walls) or "under-driving" (not reaching target gray).

---

## 🛠 Phase 3: Waveform Authoring (The "Editor" Layer)
*Objective: Allow modification of waveform logic and binary repackaging.*

### 3.1 Interactive Editor
- **Voltage Painter**: Allow users to "draw" on the chart.
  - Left click: Toggle `+15V` / `0V` / `-15V`.
  - Right click: Set frame duration.
- **Matrix Bulk Edit**: Right-click a cell in the LUT Matrix to copy/paste entire transition sequences.

### 3.2 Binary Encoder (The Hardest Part)
- Implement `PviWaveformBuilder` class.
- Reverse the bit-packing logic: `List<VoltageLevel> -> Uint8List`.
- Re-calculate Checksums (CRC/Sum).
- **Save As...**: Export modified data as a valid `.bin` or `.wbf` file that can be flashed to a TCON.

---

## 🖼 Phase 4: Image Fidelity Simulator (The "Application" Layer)
*Objective: Preview real-world image rendering performance.*

### 4.1 Image Pipeline
- **Input**: Load standard PNG/JPG images.
- **Preprocessing**: Grayscale conversion -> Gamma correction.
- **Quantization**: Map 256 gray levels to the 16 native E-Ink levels (4-bit).

### 4.2 Dithering Preview
- Implement **Floyd-Steinberg** and **Ordered Dithering** algorithms.
- Simulate the "Previous Frame" vs "Current Frame" transition using the loaded LUT.

### 4.3 Ghosting Simulation
- Maintain a "Screen Buffer" state.
- If a transition sequence is imperfect (e.g., White -> Black doesn't fully move particles), calculate the **Residual DC**.
- Overlay this residue on the next frame to simulate **Ghosting Artifacts**.

---

## 📅 Milestones Summary

| Milestone | Key Features | Complexity |
|-----------|--------------|------------|
| **v1.1** | Optical Model (EPM), Virtual Pixel Preview | ⭐⭐ |
| **v1.2** | Basic Waveform Editing (Memory only) | ⭐⭐⭐ |
| **v1.3** | Binary Encoder (Save to .bin) | ⭐⭐⭐⭐⭐ |
| **v2.0** | Image Dithering & Ghosting Simulator | ⭐⭐⭐⭐ |
