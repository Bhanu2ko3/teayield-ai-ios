# Tea Yield Prediction & Plucking Optimization

**Project Title:** An Offline-Enabled Deep Learning and Genetic Algorithm Framework for Temporal Tea Yield Prediction and Plucking Schedule Optimization in Sri Lankan Tea Estates

**Student Name:** Bhanuka Bandara

**Student ID:** 082 | **Coventry ID:** 16604375

**Degree Programme:** BSc (Hons) in Computing

**Affiliation:** National Institute of Business Management (NIBM) / Coventry University

---

### 1. Introduction & Background

The tea industry is a cornerstone of Sri Lanka's economy, accounting for a significant share of agricultural exports and providing livelihoods for hundreds of thousands of workers. Managing tea estates efficiently, however, requires precise planning of agricultural operations—most notably, the scheduling of tea leaf plucking (harvesting). The growth rate of tea leaves is highly sensitive to micro-climatic factors such as daily rainfall, temperature fluctuations, and soil moisture levels, causing weekly tea yields to vary dynamically.

In traditional Sri Lankan tea estates, plucking schedules and labor allocation are managed manually using historical heuristics. Supervisors decide which fields to harvest based on visual inspection and general intuition. This manual scheduling frequently leads to three major operational inefficiencies:
1. **Labor Mismatch:** Over-allocating workers to low-yield fields (causing high labor costs and low productivity) or under-allocating workers to high-yield fields (leading to overgrown leaves that degrade tea quality).
2. **Factory Processing Bottlenecks:** Sudden spikes in harvested volumes that exceed the processing capacity of the estate's factory, leading to leaf spoilage.
3. **Harvest Quality Dilution at Weighing Checkpoints:** Because pluckers are compensated on a piece-rate basis per kilogram, pluckers often pluck coarse, mature foliage and heavy stalks to artificially boost bag weight. Without an objective, on-site quality verification mechanism at field weighing sheds, high proportions of coarse leaves pass into factory processing, severely reducing Ceylon tea auction grade and export market prices.

To address these challenges, precision agriculture utilizes predictive modeling and mathematical optimization. By predicting weekly tea yields in advance and automatically generating optimized plucking schedules, tea estates can stabilize their supply chain, minimize labor costs, and maintain high-quality leaf harvesting.

---

### 2. Research Problem Statement

Existing digital agricultural management frameworks fail to support Sri Lankan tea estates due to three fundamental limitations:

1. **High Dependency on Heavy IoT Infrastructure:** Current smart agricultural systems rely heavily on expensive, in-situ Internet of Things (IoT) sensors (e.g., ground-based soil moisture and weather stations). For local tea smallholders and large estates, deploying and maintaining thousands of IoT devices across vast, mountainous terrains is financially and logistically unfeasible.
2. **Static Yield Forecasting:** Traditional regression models fail to capture the complex, non-linear temporal dependencies of crop growth over time. Yield is not just a function of today's weather, but the cumulative history of weather patterns over the preceding weeks.
3. **Lack of Integration Between Prediction and Action:** Existing research focuses purely on predicting crop yield as a number. However, predicting a high yield is useless unless the estate manager has an automated tool to translate that prediction into an optimal daily work schedule for the labor force.

Therefore, there is an urgent need for a unified, data-driven framework that predicts weekly tea yields using free remote sensing and climate data, and optimizes labor allocation schedules without relying on costly on-site IoT hardware.

---

### 3. Research Gap

A rigorous review of academic literature indicates that while crop yield prediction has been widely studied, most research is focused on grain crops (like wheat, rice, and maize) using static machine learning models (such as Support Vector Regression or Random Forests). 

In the context of tea cultivation:
* Existing local studies are primarily focused on manual disease identification or basic statistical yield tracking.
* While international studies have utilized Deep Learning models like **Long Short-Term Memory (LSTM)** networks for temporal yield prediction, they treat yield forecasting as an isolated problem. 
* There is a **definitive gap in research combining satellite-derived temporal indices (NDVI) and meteorological data with optimization heuristics (such as Genetic Algorithms) to solve the labor scheduling problem in tea estates**. 

This research addresses this gap by developing an integrated **Prediction-Optimization framework** that uses remote sensing data to predict tea yields and automatically schedules harvesting rosters.

---

### 4. Research Objectives

* **Objective 1:** To retrieve and preprocess multi-temporal satellite imagery (specifically **NDVI** values from Sentinel-2) and meteorological datasets (rainfall, temperature, humidity) for a targeted Sri Lankan tea estate.
* **Objective 2:** To design and train a **Long Short-Term Memory (LSTM)** deep learning model to forecast weekly tea leaf yield based on temporal environmental patterns.
* **Objective 3:** To formulate a **Genetic Algorithm (GA)** to optimize the weekly plucking roster, allocating the workforce across different fields to minimize labor costs while maximizing leaf quality.
* **Objective 4:** To develop an offline-enabled native iOS mobile application backed by a Python FastAPI engine that presents predicted yields, optimized work schedules, and on-device leaf maturity inspection to estate managers.

---

### 5. Proposed Methodology

The framework comprises two core computational pipelines, operating without the need for on-site IoT sensors:

```
[Satellite NDVI Data] + [Weather API Data]
                │
                ▼
   [Layer 1: LSTM Yield Predictor] ───> Predicted Yield per Field (kg)
                │
                ▼
 [Layer 2: Genetic Algorithm Scheduler] ───> Inputs: Yield, Area, Distances, Labor Capacity
                │
                ▼
   [Optimized Weekly Plucking Roster] ───> Roster Export (PDF / CSV)
```

#### 5.1 Data Acquisition & Polygon Registration
Rather than using physical sensors, the spatial boundary of each tea field is logged as a coordinate polygon (GeoJSON format) by mapping the boundaries using a smartphone GPS. 
* **Vegetation Index:** Multi-temporal satellite imagery of the target geofenced polygon is accessed via the **Copernicus Sentinel-2 API**. Instead of standard visual RGB images, the system extracts the raw values of two specific light bands:
  1. **Red Band (Band 4):** Measures chlorophyll absorption in the red wavelength.
  2. **Near-Infrared / NIR Band (Band 8):** Measures light reflection from healthy leaf cell structure.
  
  These bands are used to calculate the Normalized Difference Vegetation Index (NDVI):
  $$\text{NDVI} = \frac{\text{NIR} - \text{Red}}{\text{NIR} + \text{Red}}$$
  
  **Agricultural Interpretation:** Healthy, newly grown tea shoots and buds (දළු) exhibit high chlorophyll activity (absorbing Red light) and fresh cell density (reflecting NIR light), resulting in a high NDVI value (0.75 - 0.85). After plucking, the field consists of mature leaves and bare stems, causing the NDVI to drop to 0.50 - 0.60. Thus, temporal shifts in NDVI directly represent harvest readiness.
* **Climate Data:** Historical weather data (daily rainfall, humidity, and temperature) is extracted using the **Open-Meteo API** based on the estate's GPS coordinates.

#### 5.2 Temporal Data Alignment & Preprocessing
Aligning multi-source heterogeneous datasets with different temporal frequencies represents the primary data engineering challenge:
1. **Weather Data Resampling:** Daily weather datasets are resampled to weekly frequencies using Pandas (computing weekly cumulative rainfall and weekly average temperature).
2. **Satellite NDVI Interpolation:** Since Sentinel-2 images are captured at irregular intervals, missing weekly values are populated using **Linear Interpolation** to create a continuous weekly sequence.
3. **Data Merging:** Weather, NDVI, and historical yield datasets are merged based on a standardized weekly timeline (`[Week_ID]`) to serve as input sequences for the deep learning model.

#### 5.3 Handling Remote Sensing & Computational Limitations
To ensure real-world viability, the framework incorporates specific strategies to handle satellite sensor limitations and system hardware requirements:
* **Nighttime Limitations:** Sentinel-2 satellites operate in a Sun-synchronous orbit, meaning they capture images of Sri Lanka exclusively during daytime (approximately 10:30 AM local time). Nighttime darkness is therefore structurally avoided.
* **Cloud Cover Mitigation:** Mountainous tea estates in Sri Lanka experience frequent cloud cover. The framework resolves this using two layers of defense:
  1. *Cloud Masking:* The Sentinel-2 **QA60 quality band** is utilized to automatically identify and filter out pixels contaminated by clouds.
  2. *Temporal Compositing:* Clean pixels from multiple satellite passes over a 15-day window are averaged to construct a single, cloud-free representative composite image.
  3. *Radar Integration (Future Scope):* In monsoon seasons with persistent cloud cover, Sentinel-1 SAR (Synthetic Aperture Radar) data can be integrated, as radar wavelengths penetrate clouds and operate independently of solar illumination.
* **Computational Hardware Efficiency:** Because the raw satellite images are pre-aggregated into a single average numeric NDVI value per field rather than feeding massive 3D image arrays directly into the neural network, the model is computationally lightweight. The LSTM network trains on numerical CSV tables, making it highly efficient. It can be trained on standard consumer GPUs (such as an NVIDIA RTX 3050 6GB) or free cloud platforms (Google Colab) in a matter of seconds.

#### 5.4 Temporal Yield Prediction (Layer 1)
An **LSTM network** is trained on the historical sequence of weather and NDVI data. The temporal memory of the LSTM captures the delayed effects of rain and sun on leaf shoot growth. The input features consist of a rolling window of the past 4 weeks of data, outputting the expected yield (in kg) for each estate field for the upcoming week.

#### 5.5 Plucking Schedule Optimization (Layer 2)
The predicted weekly yield (in kg) serves as the primary driver for a **Genetic Algorithm (GA)**. The GA optimizes worker distribution across fields by considering the following parameters and constraints:
* **Inputs to the GA:**
  1. *Predicted Yield:* The output of Layer 1 (expected yield in kg per field).
  2. *Field Area:* The size of each field in acres.
  3. *Yield Density:* Calculated as $\text{Yield (kg)} / \text{Area (Acres)}$ to estimate crop density and determine worker speed.
  4. *Labor Capacity:* The average daily plucking rate per worker (e.g., 25 kg/day).
  5. *Distance Matrix:* A spatial map of travel distances between different fields to minimize walking time.
  6. *Topography Index:* A difficulty multiplier for steep fields vs flat fields.
* **Genetic Operators & Constraints:**
  * *Chromosome Structure:* Represents the worker assignment schedules over a 6-day week.
  * *Constraints:* Maximum available labor limits, minimum field rest periods between pluckings (typically 7–10 days), and maximum factory daily capacity limits.
  * *Fitness Function:* Designed to maximize harvested yield and minimize transport distances and labor waste.

---

### 6. Tools, Technologies, and Libraries

* **Programming Languages:** Python (Core Engine & Backend), Swift (Native iOS Client)
* **Backend API Framework:** FastAPI (Asynchronous high-performance REST API)
* **Security & Access Control:** Role-Based Access Control (RBAC) with JWT separating Executive Manager and Field Supervisor operational scopes
* **Data Sources & APIs:** Sentinel Hub API (Satellite Imagery), Open-Meteo API (Weather data)
* **Machine Learning & Edge AI Frameworks:** TensorFlow / Keras (LSTM Model for Yield Prediction), Apple CoreML / Vision (On-Device Leaf Shoot Quality & Maturity Classification at Weighing Points)
* **Optimization Library:** DEAP (Distributed Evolutionary Algorithms in Python)
* **Data Analytics & Preprocessing:** NumPy, Pandas, Scikit-learn
* **Mobile Client Framework:** SwiftUI, SwiftData (Offline Local Caching)
* **Geospatial Mapping & Navigation:** Apple MapKit & CoreLocation (Native GPS field boundary logging and satellite overlay rendering)

---

### 7. User Workflow & System Interface (Role-Based Operational Architecture)

The system is architected as an offline-capable native iOS mobile application communicating with a local or cloud-hosted Python FastAPI backend, enforcing Role-Based Access Control (RBAC) across two distinct operational roles:

#### 7.1 Estate Manager Workflow (Executive Planning & Scheduling)
1. **Polygon Registration:** The manager registers estate field boundaries as spatial GeoJSON polygons using MapKit satellite view or GPS walking boundaries.
2. **Environmental Data Sync:** When network connectivity is available, the manager taps "Sync Data", triggering the FastAPI backend to call Sentinel-2 and Open-Meteo APIs to update weather and NDVI records up to the current date.
3. **Parameter Input & Optimization Execution:** The manager enters operational constraints for the upcoming week (e.g., available plucker workforce, 7–10 day field rest cycle, factory daily intake thresholds) and executes the optimization engine. The FastAPI backend runs the LSTM prediction model followed by the Genetic Algorithm, delivering:
   * A 7-day yield forecasting chart showing predicted kg per field.
   * An interactive satellite heatmap coloring fields green (high yield, ready to pluck), yellow (medium yield), and red (rest period).
   * An optimized weekly workforce roster assigning plucker counts to specific fields across a 6-day cycle.
4. **Roster Export & Delegation:** The manager reviews the generated roster and exports it as a PDF/CSV or delegates daily field plucking assignments directly to field supervisors.

#### 7.2 Field Supervisor Workflow (On-Field Execution & Quality Assurance)
1. **Task Assignment & Geofenced Field Alerts:** Supervisors receive their daily assigned fields on the iPhone app. As they physically enter a field boundary, native iOS geofencing (`CLCircularRegion`) dispatches arrival alerts and confirms assigned plucker headcounts.
2. **Harvest Checkpoint Quality Inspection (CoreML Edge AI):** At the field weighing station, pluckers submit harvested bags to be weighed. To prevent pluckers from inflating bag weights with coarse foliage, the supervisor captures a frame of the harvested batch using the iPhone camera. An on-device **CoreML + Vision** model classifies fine leaf ("Two Leaves and a Bud") vs. coarse leaf proportions in real time (60fps, 0-latency, 100% offline) to generate an objective Quality Score.
3. **Offline Session Logging & Auto-Sync:** The supervisor logs harvested kilograms alongside the CoreML quality score into local SwiftData storage. Once cellular network or Wi-Fi connectivity is re-established, the app automatically synchronizes plucking logs back to the central backend.

---

### 8. Expected Outcomes and Deliverables

The final submission to NIBM will include:

* Fully documented source code containing the Python FastAPI backend (data extraction scripts, pre-trained LSTM predictor, and Genetic Algorithm scheduler) alongside the native Swift/SwiftUI iOS mobile application.
* A processed dataset combining local tea estate coordinates, historical weather, and calculated NDVI values.
* An academic Research Thesis containing literature evaluation, model architecture details, and comparative performance graphs.
