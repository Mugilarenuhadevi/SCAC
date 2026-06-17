#include <WiFi.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <Firebase_ESP_Client.h>
#include <time.h>

// ================= OLED =================
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

// ================= WIFI =================
const char* ssid = "DHARSH";
const char* password = "Theriyadhu";

// ================= FIREBASE =================
#define DATABASE_URL "https://smartairaqi-default-rtdb.firebaseio.com"
#define DATABASE_SECRET "JY9DUFE9HubH3xOkjN8m1KvRq5Mc1prydL1gpjNR"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// ================= TIME =================
const long gmtOffset_sec = 19800;
const int daylightOffset_sec = 0;

// ================= SDS011 =================
HardwareSerial sdsSerial(2);
float pm25 = 0;

// ================= FAN =================
#define FAN_PIN 25
bool fanState = true; // ALWAYS ON

// ================= TIMER =================
unsigned long lastRead = 0;
#define SENSOR_INTERVAL 2000

// ================= AQI =================
int calculateAQI(float pm)
{
  if (pm <= 30) return map(pm, 0, 30, 0, 50);
  else if (pm <= 60) return map(pm, 31, 60, 51, 100);
  else if (pm <= 100) return map(pm, 61, 100, 101, 200);
  else return map(pm, 101, 250, 201, 300);
}

String getAQIStatus(int aqi)
{
  if (aqi <= 50) return "GOOD";
  else if (aqi <= 100) return "MODERATE";
  else if (aqi <= 200) return "POOR";
  else return "BAD";
}

// ================= SDS011 READ =================
bool readSDS011(float &pm)
{
  static uint8_t buf[10];
  if (sdsSerial.available() >= 10)
  {
    if (sdsSerial.read() == 0xAA)
    {
      sdsSerial.readBytes(buf + 1, 9);
      if (buf[9] == 0xAB)
      {
        pm = (buf[3] * 256 + buf[2]) / 10.0;
        return true;
      }
    }
  }
  return false;
}

// ================= FIREBASE UPLOAD =================
void uploadToFirebase(int aqi, String status)
{
  if (!Firebase.ready()) return;

  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) return;

  char dateBuf[15];
  char timeBuf[15];
  strftime(dateBuf, sizeof(dateBuf), "%d-%m-%Y", &timeinfo);
  strftime(timeBuf, sizeof(timeBuf), "%H:%M:%S", &timeinfo);

  // ===== LIVE DATA =====
  Firebase.RTDB.setInt(&fbdo, "/AirQuality/Live/AQI", aqi);
  Firebase.RTDB.setString(&fbdo, "/AirQuality/Live/Status", status);
  Firebase.RTDB.setString(&fbdo, "/AirQuality/Live/Date", dateBuf);
  Firebase.RTDB.setString(&fbdo, "/AirQuality/Live/Time", timeBuf);

  // ===== HISTORY DATA =====
  String historyPath = "/AirQuality/History/" + String(dateBuf) + "/" + String(timeBuf);
  Firebase.RTDB.setInt(&fbdo, historyPath + "/AQI", aqi);
  Firebase.RTDB.setString(&fbdo, historyPath + "/Status", status);
}

// ================= SETUP =================
void setup()
{
  Serial.begin(115200);

  Wire.begin(21, 22);
  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);

  // ===== FAN ALWAYS ON =====
  pinMode(FAN_PIN, OUTPUT);
  digitalWrite(FAN_PIN, HIGH); // FAN PERMANENTLY ON 🔥

  sdsSerial.begin(9600, SERIAL_8N1, 16, 17);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) delay(300);

  configTime(gmtOffset_sec, daylightOffset_sec, "pool.ntp.org");

  config.database_url = DATABASE_URL;
  config.signer.tokens.legacy_token = DATABASE_SECRET;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

// ================= LOOP =================
void loop()
{
  if (millis() - lastRead > SENSOR_INTERVAL)
  {
    lastRead = millis();

    if (!readSDS011(pm25)) return;

    int aqi = calculateAQI(pm25);
    String status = getAQIStatus(aqi);

    // ===== FAN ALWAYS ON =====
    digitalWrite(FAN_PIN, HIGH);

    // Upload both LIVE + HISTORY
    uploadToFirebase(aqi, status);

    struct tm timeinfo;
    getLocalTime(&timeinfo);
    char dateBuf[15];
    char timeBuf[15];
    strftime(dateBuf, sizeof(dateBuf), "%d-%m-%Y", &timeinfo);
    strftime(timeBuf, sizeof(timeBuf), "%H:%M:%S", &timeinfo);

    // ===== DISPLAY =====
    display.clearDisplay();
    display.setCursor(0, 0);

    display.print("Date: ");
    display.println(dateBuf);

    display.print("Time: ");
    display.println(timeBuf);

    display.println();

    display.print("PM2.5: ");
    display.println(pm25);

    display.print("AQI : ");
    display.println(aqi);

    display.print("Stat : ");
    display.println(status);

    display.display();
  }
}
