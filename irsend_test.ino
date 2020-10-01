#include <IRremote.h>

IRsend IRsender;

void setup() {
  pinMode(9, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(9600);
  delay(2000);

  Serial.println(F("START " __FILE__ " from " __DATE__));
  Serial.print(F("Ready to send IR signals at pin "));
  Serial.println(IR_SEND_PIN);
  delay(2000);
}

void loop() {
  //IRsender.sendNEC(0x30DFA857, 32, 0);
  //IRsender.sendNEC(0x20DF10EF, 32, 0);
  IRsender.sendNEC(0x30DFA857, 32, 0);
  
  Serial.println("sent code");
  delay(5000);
}
