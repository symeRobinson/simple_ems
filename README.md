# simple_ems
Simple EMS Simulation and Duty system for FiveM
# Basic EMS Script for FiveM

This EMS script for FiveM provides a configurable EMS menu system that allows players to toggle on-duty status, view and manage civilian injuries, and check and treat patient vital signs. Created by Syme Robinson.

## Features

- **Duty Management**: Toggle EMS duty status with selectable units and stations.
- **Injury & Vital Signs Tracking**: Select injuries by body part, which affect vital signs dynamically.
- **Medical Conditions & Treatment**: Manage medical conditions (e.g., asthma, COPD) and perform treatments.
- **Civilian & Medic Interaction**: Allows medics to assess and treat civilian players based on their injury profiles and vital signs.

## Dependency

This script uses [NativeUI by FrazzIe](https://github.com/FrazzIe/NativeUILua) for the menu system. Ensure you have **NativeUI** installed and added as a dependency in your FiveM server.

### Installation of NativeUI

1. Download the **NativeUI** resource from the [GitHub repository](https://github.com/FrazzIe/NativeUILua).
2. Place the **NativeUI** folder in your FiveM `resources` directory.
3. Start **NativeUI** in your `server.cfg` before this EMS script:
   ```plaintext
   start NativeUI
