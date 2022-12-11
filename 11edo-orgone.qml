import QtQuick 2.1
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import MuseScore 3.0

MuseScore {
      version: "1.0"
      description: "Retune selection to 11EDO Orgone[7]"
      menuPath: "Plugins.11EDO_Orgone.Tune"
      pluginType: "dialog"
      width: 320
      height: 240

      // WARNING! This doesn't validate the accidental code!
      property variant customKeySigRegex: /\.(.*)\.(.*)\.(.*)\.(.*)\.(.*)\.(.*)\.(.*)/g

      property variant centOffsets: {
        'a': {
          '-2': 200 - 2 * 1200/11, // Abb
          '-1': 100 - 1 * 1200/11, // Ab
           0: 0,         // A
           1: 1 * 1200/11 - 100,   // A#
           2: 2 * 1200/11 - 200    // Ax
        },
        'b': {
              '-2': 0, // Bbb
              '-1': 1200/11 - 100, // Bb
               0: 2 * 1200/11 - 200,         // B
               1: 3 * 1200/11 - 300,   // B#
               2: 4 * 1200/11 - 400    // Bx
        },
        'c': {
              '-2': 1 * 1200/11 - 100, // Cbb
              '-1': 2 * 1200/11 - 200, // Cb
               0: 3 * 1200/11 - 300,         // C
               1: 4 * 1200/11 - 400,   // C#
               2: 5 * 1200/11 - 500    // Cx
        },
        'd': {
              '-2': 3 * 1200/11 - 300, // Dbb
              '-1': 4 * 1200/11 - 400, // Db
               0: 5 * 1200/11 - 500,         // D
               1: 6 * 1200/11 - 600,   // D#
               2: 7 * 1200/11 - 700    // Dx
        },
        'e': {
              '-2': 5 * 1200/11 - 500, // Ebb
              '-1': 6 * 1200/11 - 600, // Eb
               0: 7 * 1200/11 - 700,         // E
               1: 8 * 1200/11 - 800,   // E#
               2: 9 * 1200/11 - 900    // Ex
        },
        'f': {
              '-2': 6 * 1200/11 - 600, // Fbb
              '-1': 7 * 1200/11 - 700, // Fb
               0: 8 * 1200/11 - 800,         // F
               1: 9 * 1200/11 - 900,   // F#
               2: 10 * 1200/11 - 1000    // Fx
        },
        'g': {
              '-2': 8 * 1200/11 - 800, // Gbb
              '-1': 9 * 1200/11 - 900, // Gb
               0: 10 * 1200/11 - 1000,         // G
               1: 11 * 1200/11 - 1100,   // G#
               2: 12 * 1200/11 - 1200    // Gx
        }
      }

      Rectangle {
          color: "white"
          anchors.fill: parent

          Text {
            text: "11EDO Orgone[7] Retune"
            x: 95
            y: 75
          }


          Button {
            x: 70
            y: 150
            width: 200
            height: 75
            text: "Retune!"
            onClicked: {
              var parms = {};
              parms.keySig = {
                'c': 0,
                'd': 0,
                'e': 0,
                'f': 0,
                'g': 0,
                'a': 0,
                'b': 0,
              };
              parms.currKeySig = parms.keySig

              parms.accidentals = {};

              applyToNotesInSelection(tuneNote, parms);
              Qt.quit();
            }
          }
      }

      function convertAccidentalToSteps(acc) {
        switch(acc.trim()) {
        case 'bb':
          return -2;
        case 'b':
          return -1;
        case '':
          return 0;
        case '#':
          return 1;
        case 'x':
          return 2;
        default:
          return 0;
        }
      }
      function convertAccidentalToStepsOrNull(acc) {
        switch(acc.trim()) {
        case 'bb':
          return -2;
        case 'b':
          return -1;
        case '':
          return 0;
        case '#':
          return 1;
        case 'x':
          return 2;
        default:
          return null;
        }
      }

      // Takes in annotations[].text and returns either
      // a key signature object if str is a valid custom key sig code or null.
      //
      // Valid key sig code is denoted as such:
      //  .c.d.e.f.g.a.b
      // where identifiers c thru b denote a valid accidental code of which
      // will apply to the respective notes.
      //
      // For example, this is F-down major: .v.v.v.v.v.v.bv
      //
      // whitespace can be placed between dots and accidentals for readability.
      //
      // For the natural accidental, blank or whitespace will both work.
      //
      // Assign the key signature object to the parms.currKeySig field!
      function scanCustomKeySig(str) {
          str = str.trim();
          var keySig = {};
          var res = str.match(customKeySigRegex);
          if (res === null)
            return null;
          var acc = convertAccidentalToStepsOrNull(res[1].trim());
          if (acc !== null)
            keySig.c = acc;
          else
            return null;
          acc = convertAccidentalToStepsOrNull(res[2].trim());
          if (acc !== null)
            keySig.d = acc;
          else
            return null;
          acc = convertAccidentalToStepsOrNull(res[3].trim());
          if (acc !== null)
            keySig.e = acc;
          else
            return null;
          acc = convertAccidentalToStepsOrNull(res[4].trim());
          if (acc !== null)
            keySig.f = acc;
          else
            return null;
          acc = convertAccidentalToStepsOrNull(res[5].trim());
          if (acc !== null)
            keySig.g = acc;
          else
            return null;
          acc = convertAccidentalToStepsOrNull(res[6].trim());
          if (acc !== null)
            keySig.a = acc;
          else
            return null;
          acc = convertAccidentalToStepsOrNull(res[7].trim());
          if (acc !== null)
            keySig.b = acc;
          else
            return null;

          return keySig;
      }

      // Apply the given function to all notes in selection
      // or, if nothing is selected, in the entire score

      function applyToNotesInSelection(func, parms) {
        var cursor = curScore.newCursor();
        cursor.rewind(1);
        var startStaff;
        var endStaff;
        var endTick;
        var fullScore = false;
        if (!cursor.segment) { // no selection
          fullScore = true;
          startStaff = 0; // start with 1st staff
          endStaff = curScore.nstaves - 1; // and end with last
        } else {
          startStaff = cursor.staffIdx;
          cursor.rewind(2);
          if (cursor.tick == 0) {
            // this happens when the selection includes
            // the last measure of the score.
            // rewind(2) goes behind the last segment (where
            // there's none) and sets tick=0
            endTick = curScore.lastSegment.tick + 1;
          } else {
            endTick = cursor.tick;
          }
          endStaff = cursor.staffIdx;
        }
        console.log(startStaff + " - " + endStaff + " - " + endTick)
        // -------------- Actual thing here -----------------------


        for (var staff = startStaff; staff <= endStaff; staff++) {
          for (var voice = 0; voice < 4; voice++) {
            cursor.rewind(1); // sets voice to 0
            cursor.voice = voice; //voice has to be set after goTo
            cursor.staffIdx = staff;

            if (fullScore)
              cursor.rewind(0) // if no selection, beginning of score

            var measureCount = 0;

            // After every track/voice, reset the currKeySig back to the original keySig

            parms.currKeySig = parms.keySig;
            console.log("currKeySig reset");

            // Loop elements of a voice
            while (cursor.segment && (fullScore || cursor.tick < endTick)) {
              // Reset accidentals if new measure.
              if (cursor.segment.tick == cursor.measure.firstSegment.tick) {
                parms.accidentals = {};
                measureCount ++;
                console.log("Reset accidentals - " + measureCount);
              }

              /* Check for StaffText key signature changes.
              for (var i = 0, annotation = cursor.segment.annotations[i]; i < cursor.segment.annotations.length; i++) {
                var maybeKeySig = scanCustomKeySig(annotation.text);
                if (maybeKeySig !== null) {
                  parms.currKeySig = maybeKeySig;
                  console.log("detected new customer keySig: " + annotation.text);
                }
              }*/

              if (cursor.element) {

                if (cursor.element.type == Element.CHORD) {
                  var graceChords = cursor.element.graceNotes;
                  for (var i = 0; i < graceChords.length; i++) {
                    // iterate through all grace chords
                    var notes = graceChords[i].notes;
                    for (var j = 0; j < notes.length; j++)
                      func(notes[j], parms);
                  }
                  var notes = cursor.element.notes;
                  for (var i = 0; i < notes.length; i++) {
                    var note = notes[i];
                    func(note, parms);
                  }
                }
              }
              cursor.next();
            }
          }
        }
      }

      function tuneNote(note, parms) {
        var tpc = note.tpc;
        var acc = note.accidental;

        // If tpc is non-natural, there's no need to go through additional steps,
        // since accidentals and key sig are already taken into consideration
        // to produce a non-screw-up tpc.

        // However, if tpc is natural, it would need to be checked against acc and
        // the key signature, but ti will always be null in Orgone[7] 11-EDO.

        switch(tpc) {
        case -1: //Fbb
          note.tuning = centOffsets['f'][-2];
          return;
        case 0: //Cbb
          note.tuning = centOffsets['c'][-2];
          return;
        case 1: //Gbb
          note.tuning = centOffsets['g'][-2];
          return;
        case 2: //Dbb
          note.tuning = centOffsets['d'][-2];
          return;
        case 3: //Abb
          note.tuning = centOffsets['a'][-2];
          return;
        case 4: //Ebb
          note.tuning = centOffsets['e'][-2];
          return;
        case 5: //Bbb
          note.tuning = centOffsets['b'][-2];
          return;

        case 6: //Fb
          note.tuning = centOffsets['f'][-1];
          return;
        case 7: //Cb
          note.tuning = centOffsets['c'][-1];
          return;
        case 8: //Gb
          note.tuning = centOffsets['g'][-1];
          return;
        case 9: //Db
          note.tuning = centOffsets['d'][-1];
          return;
        case 10: //Ab
          note.tuning = centOffsets['a'][-1];
          return;
        case 11: //Eb
          note.tuning = centOffsets['e'][-1];
          return;
        case 12: //Bb
          note.tuning = centOffsets['b'][-1];
          return;

        case 13: //F
          note.tuning = centOffsets['f'][0];
          return;
        case 14: //C
          note.tuning = centOffsets['c'][0];
          return;
        case 15: //G
          note.tuning = centOffsets['g'][0];
          return;
        case 16: //D
          note.tuning = centOffsets['d'][0];
          return;
        case 17: //A
          note.tuning = centOffsets['a'][0];
          return;
        case 18: //E
          note.tuning = centOffsets['e'][0];
          return;
        case 19: //B
          note.tuning = centOffsets['b'][0];
          return;

        case 20: //F#
          note.tuning = centOffsets['f'][1];
          return;
        case 21: //C#
          note.tuning = centOffsets['c'][1];
          return;
        case 22: //G#
          note.tuning = centOffsets['g'][1];
          return;
        case 23: //D#
          note.tuning = centOffsets['d'][1];
          return;
        case 24: //A#
          note.tuning = centOffsets['a'][1];
          return;
        case 25: //E#
          note.tuning = centOffsets['e'][1];
          return;
        case 26: //B#
          note.tuning = centOffsets['b'][1];
          return;

        case 27: //Fx
          note.tuning = centOffsets['f'][2];
          return;
        case 28: //Cx
          note.tuning = centOffsets['c'][2];
          return;
        case 29: //Gx
          note.tuning = centOffsets['g'][2];
          return;
        case 30: //Dx
          note.tuning = centOffsets['d'][2];
          return;
        case 31: //Ax
          note.tuning = centOffsets['a'][2];
          return;
        case 32: //Ex
          note.tuning = centOffsets['e'][2];
          return;
        case 33: //Bx
          note.tuning = centOffsets['b'][2];
          return;
        }     
      }

      onRun: {
        console.log("hello 11edo orgone");

        if (typeof curScore === 'undefined')
              Qt.quit();
      }
}
