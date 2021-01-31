#include <SPI.h>
#include <SD.h>

File myFile;
#include<EEPROM.h>
#define speaker 2
int i=0;

void setup() {
  pinMode(speaker, OUTPUT);
  SD.begin(10);//cs pin == 10!
  myFile = SD.open("data.txt");
}

void loop() {
  String a = myFile.readStringUntil(',');
  String b = myFile.readStringUntil(',');
  tone(2, note(a.toInt()), b.toInt());
  delay(b.toInt());
}

int note(int i){
  return 440*pow(2, (i-60)/12.);
}
