#include <Arduino.h>
#if defined(ESP32)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#endif
#include <Firebase_ESP_Client.h>
#include "DHT.h"
#include <HTTPClient.h>

//Provide the token generation process info.
#include "addons/TokenHelper.h"
//Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"  // Real Time DataBase

#define WIFI_SSID "fatma"
#define WIFI_PASSWORD "00000000"

// Insert Firebase project API Key
#define API_KEY "AIzaSyBLfulBCWRuJMDn1CWigMW5NppPMoI8QKU"

// Insert RTDB URLefine the RTDB URL */
#define DATABASE_URL "https://sara-bdfd4-default-rtdb.firebaseio.com/"
#define FIREBASE_PROJECT_ID "sara-bdfd4"

FirebaseData fbdoS;
FirebaseData fbdoT;
FirebaseData fbdoH;
FirebaseData fbdoD;
FirebaseData fdata;
FirebaseJson json;

FirebaseAuth auth; // authntication
FirebaseConfig config;    // configuration

unsigned long sendDataPrevMillis = 0;
bool signupOK = false;


// DHT Sensor setup
#define DHTPIN 4
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// Gas sensors
const int MQ135_PIN = 34;
const int MQ135_PIN_DIGITAL = 35;

// Calibration baseline (Ro) values for each sensor in clean air
float Ro_MQ135 = 0;

// Sensor response curves
const float MQ135_CURVE[3] = {2.6, 0.5, -0.42};   // MQ-135 for smoke

// Calibration function for gas sensors
float calibrateSensor(int pin) {
  float total = 0;
  int numReadings = 100;
  for (int i = 0; i < numReadings; i++) {
    total += getAnalogValue(pin);
    delay(100);
  }
  return total / numReadings;  // Average reading in clean air
}


void setup() {
  Serial.begin(115200);
  pinMode (MQ135_PIN_DIGITAL, INPUT);
  // Calibrate each sensor in clean air
  Serial.println("Calibrating sensors in clean air...");
  Ro_MQ135 = calibrateSensor(MQ135_PIN);
  Serial.print("MQ2 Ro (clean air): ");
  Serial.println(Ro_MQ135);

  dht.begin();
  Serial.println("Calibration complete.\n");

  delay(2000);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("ok");
    signupOK = true;
  }
  else {
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);



}

float getAnalogValue(int pin) {
  return analogRead(pin);
}

// Concentration calculation for each sensor
float calculateConcentration(float analogValue, float Ro_value, const float curve[3]) {
  float ratio = Ro_value / analogValue;  // Inverse ratio since analog value drops with gas
  return pow(10, ((log10(ratio) - curve[1]) / curve[2]) + curve[0]);
}

void uploadDocument(float humidity, float temp, float smoke_conc, int is_smoke) {
  // Create a unique ID for the document (optional; Firestore can generate one automatically)
  String documentId = String(millis()); // Use the current time in milliseconds as the document ID

  // Set fields with correct Firestore types
  json.set("fields/humidity/doubleValue", humidity);
  json.set("fields/temp/doubleValue", temp);
  json.set("fields/smoke/doubleValue", smoke_conc);
  json.set("fields/is_smoke/integerValue", is_smoke);

  // Send the data to Firestore
  if (Firebase.Firestore.createDocument(&fdata, FIREBASE_PROJECT_ID, "", "sensors/" + documentId, json.raw())) {
    Serial.println("New document created successfully!");
  } else {
    Serial.println("Error creating new document: " + fdata.errorReason());
  }
}


void loop() {
  // Read DHT sensor
  float humidity = dht.readHumidity();
  float temperatureC = dht.readTemperature();
  int smoke_state = digitalRead (MQ135_PIN_DIGITAL);

  // Read MQ2 sensor for smoke
  float analogValue_MQ2 = getAnalogValue(MQ135_PIN);
  float smokePPM_MQ2 = calculateConcentration(analogValue_MQ2, Ro_MQ135, MQ135_CURVE);

  if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 1000 || sendDataPrevMillis == 0)) {
    sendDataPrevMillis = millis();
    if (Firebase.RTDB.setInt(&fbdoS, "air/smoke", smokePPM_MQ2)) {
      Serial.println ("sent");
    }    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdoS.errorReason());
    }

    if (Firebase.RTDB.setInt(&fbdoH, "dht/humidity", humidity)) {
      Serial.println ("sent");
    }    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdoH.errorReason());
    }
    if (Firebase.RTDB.setInt(&fbdoT, "dht/temp", temperatureC)) {
      Serial.println ("sent");
    }    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdoT.errorReason());
    }
    if (Firebase.RTDB.setInt(&fbdoD, "smoke/exist", smoke_state)) {
      Serial.println ("sent");
    }    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdoD.errorReason());
    }

    uploadDocument(humidity, temperatureC, smokePPM_MQ2, smoke_state);
  }

}