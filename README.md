# Smart Community Air Quality Monitoring System

## Overview

The Smart Community Air Quality Monitoring System is an IoT-based environmental monitoring solution designed to measure, analyze, and display real-time air quality data. The system uses an SDS011 dust sensor and ESP32 microcontroller to monitor PM2.5 concentration, calculate the Air Quality Index (AQI), and store data in Firebase Realtime Database for cloud-based monitoring. A web dashboard and mobile application provide real-time visualization, historical analysis, alerts, and health recommendations.

---

## Objectives

- Monitor air quality in real time.
- Calculate AQI based on PM2.5 concentration.
- Store environmental data in the cloud.
- Provide live and historical air quality information.
- Generate alerts when pollution levels become unsafe.
- Improve public awareness of environmental conditions.
- Support future AI-based pollution prediction and health advisory systems.

---

## Features

### Real-Time Air Quality Monitoring
- Continuous PM2.5 monitoring using SDS011 sensor.
- Real-time AQI calculation.
- Automatic air quality classification.

### Cloud Integration
- Data stored in Firebase Realtime Database.
- Remote access from web and mobile platforms.

### Live Dashboard
- Displays current AQI value.
- Shows pollution status.
- Displays date and time of measurement.
- Real-time updates without manual refresh.

### Historical Data Analysis
- Date-wise data retrieval.
- Historical AQI records.
- Trend analysis for pollution monitoring.

### Smart Fan Automation
- Fan automatically turns ON when AQI exceeds the threshold.
- Fan automatically turns OFF when AQI returns to safe levels.

### Voice Alert System
- Voice-based warning alerts for high pollution conditions.
- Immediate notification when air quality becomes unsafe.

### Health Recommendation System
- Provides health-related recommendations based on AQI level.
- Helps users take preventive actions during poor air quality conditions.

### AI Chatbot Assistant
- Interactive chatbot for air quality information.
- Explains AQI values and pollution status.
- Provides safety suggestions based on current conditions.

### Future Enhancements
- AI-based pollution prediction.
- Weather and pollution correlation analysis.
- Multi-location air quality monitoring.
- Smart city integration.

---

## Hardware Components

- ESP32 Development Board
- SDS011 PM2.5 Dust Sensor
- OLED Display
- DC Fan
- Power Supply Module

---

## Software Components

- Arduino IDE
- Firebase Realtime Database
- HTML
- CSS
- JavaScript
- MIT App Inventor
- GitHub

---

## System Architecture

SDS011 Sensor → ESP32 → AQI Calculation → Firebase Realtime Database → Web Dashboard / Mobile App → Alerts & Recommendations

---

## Working Procedure

### Step 1: Data Collection
The SDS011 sensor continuously measures PM2.5 concentration in the environment.

### Step 2: AQI Calculation
ESP32 processes the sensor readings and calculates the Air Quality Index (AQI).

### Step 3: Air Quality Classification
Based on AQI values, air quality is categorized as:
- Good
- Moderate
- Poor
- Bad

### Step 4: Cloud Storage
The calculated AQI, status, date, and time are uploaded to Firebase Realtime Database.

### Step 5: Live Monitoring
The web dashboard and mobile application fetch and display live air quality data.

### Step 6: Historical Storage
AQI records are stored date-wise and time-wise for future analysis.

### Step 7: Fan Automation
The fan is automatically controlled according to pollution levels.

### Step 8: Voice Alerts
A voice alert is generated whenever AQI exceeds the safe threshold.

### Step 9: Health Recommendations
Users receive pollution-related safety recommendations.

### Step 10: Chatbot Assistance
Users can interact with the chatbot to understand air quality conditions and recommended actions.

---

## AQI Categories

| AQI Range | Status |
|------------|----------|
| 0 – 50 | Good |
| 51 – 100 | Moderate |
| 101 – 200 | Poor |
| Above 200 | Bad |

---

## Project Outcomes

- Real-time environmental monitoring.
- Cloud-based data management.
- Historical pollution tracking.
- Automated pollution control.
- Voice-based alert mechanism.
- Enhanced public health awareness.
- Foundation for AI-powered smart city solutions.

---

## Future Scope

- AI-based pollution forecasting.
- Weather-integrated pollution analysis.
- Multi-location monitoring system.
- Smart city deployment.
- Advanced chatbot with generative AI support.

