# Rshiny-data: Disease Spread Visualization
Data visualizing using R shiny app

## Overview
This code supports visualizing disease spreading data on a worldwide map, following a specific input file structure.

## Usage Example
### Input File
The input file format can be seen from the provided example.

![Screen Shot 2025-03-09 at 10 19 05 AM](https://github.com/user-attachments/assets/69245057-98aa-4e69-8ad2-a924f2e0bd80)

### Output Map
The map supports:
- Zoom in
- Zoom out
- Free drag
![Screen Shot 2025-03-09 at 10 20 11 AM](https://github.com/user-attachments/assets/aff190aa-cc1d-4d98-b26c-19bcbe285fb0)
![Screen Shot 2025-03-09 at 10 19 48 AM](https://github.com/user-attachments/assets/9549a848-e827-42cd-a6c7-b40d6ba2c86c)

## Complete GUI Features
![Screen Shot 2025-03-09 at 10 31 08 AM](https://github.com/user-attachments/assets/7ebcc3e8-779a-40d8-a4fe-187d409e9a8d)

### Map Types
The visualization supports four different map types:
- OpenStreetMap
- OpenTopoMap
- Nsri.NatGeoWorldMap
- CartoDB.Positron
![Screen Shot 2025-03-09 at 10 20 24 AM](https://github.com/user-attachments/assets/8e193742-d4b4-4a74-be91-edc49af694c8)

### Jittering Factor
A jittering factor is added to differentiate two data points when clustering occurs. Note that a large jittering factor could result in data location inaccuracy.

![Screen Shot 2025-03-09 at 10 19 22 AM](https://github.com/user-attachments/assets/7af047c2-d434-4853-8a73-3775bd84de46)
