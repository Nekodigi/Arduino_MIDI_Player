import ddf.minim.*;
import ddf.minim.signals.*;
import javax.sound.midi.*;

int NOTE_ON = 0x90;
int NOTE_OFF = 0x80;
int SET_TEMPO = 0x51;

int prevNote = 0;//previous note and tick
long prevTick = 0;
//String[] NOTE_NAMES = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
float msptick = 0;//micro second per tick
Sequence sequence = null;

try {
  sequence = MidiSystem.getSequence(createInput("paganini-etude_3_la_campanella_444_r_(nc)smythe.mid"));
}
catch(Exception e) {
  print(e);
}
float ppq = sequence.getResolution();//get pulse per quarter note
//println(ppq);
int trackNumber = 0;
for (Track track : sequence.getTracks()) {
  trackNumber++;
  System.out.println("Track " + trackNumber + ": size = " + track.size()+"\n");
  for (int i=0; i < track.size(); i++) { 
    MidiEvent event = track.get(i);

    MidiMessage message = event.getMessage();
    if (message instanceof MetaMessage) {
      MetaMessage mm = (MetaMessage)message;
      if (mm.getType()==SET_TEMPO) {
        byte[] data = mm.getData();
        int tempo = (data[0] & 0xff) << 16 | (data[1] & 0xff) << 8 | (data[2] & 0xff);
        int bpm = 60000000 / tempo;//beats per minute
        msptick = 60000 / (bpm * ppq);//micro second per tick
        //println();println(bpm, msptick);//60000 / (BPM * PPQ)
      }
    }

    if (message instanceof ShortMessage) {
      ShortMessage sm = (ShortMessage) message;
      //System.out.print("Channel: " + sm.getChannel() + " ");
      if (sm.getCommand() == NOTE_ON) {
        int key = sm.getData1();
        long tick = event.getTick();
        if (key > prevNote) {
          prevNote = key;
        }
        if (tick-prevTick > 10) {
          System.out.print(key + ",");
          long ms = (long)((tick-prevTick)*msptick);//calculate time diff and convert to milli second
          System.out.print(ms + ",");
          prevTick = tick;
        }
        //int octave = (key / 12)-1;
        //int note = key % 12;
        //String noteName = NOTE_NAMES[note];
        //int velocity = sm.getData2();
        //System.out.println("Note on, " + noteName + octave + " key=" + key + " velocity: " + velocity);
      } else if (sm.getCommand() == NOTE_OFF) {
        int key = sm.getData1();
        if (prevNote == key)prevNote = 0;
        //int octave = (key / 12)-1;
        //int note = key % 12;
        //String noteName = NOTE_NAMES[note];
        //int velocity = sm.getData2();
        //System.out.println("Note off, " + noteName + octave + " key=" + key + " velocity: " + velocity);
      } else {
        //System.out.println("Command:" + sm.getCommand());
      }
    } else {
      //System.out.println("Other message: " + message.getClass());
    }
  }
  println("\n");
  prevTick = 0;
  //System.out.println();
}
