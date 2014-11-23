
package entities;

import components.*;

import luxe.Entity;
import luxe.Input;
import luxe.Text;
import luxe.Vector;
import luxe.Color;

import HexMap;
import HexMap.Point;
import HexMap.Hex;

using Lambda;

class HexLevel extends Entity {
    var hexmap :HexMap<Hexagon>;
    var hexSize = 50;
    var hexMargin = 3;
    var wordlist :Map<String, Int>; // TODO: Map type?
    var word :String = "";
    var activeHexagon :Hexagon;
    var hexChain :Array<Hexagon>;

    override function init() {
        wordlist = new Map<String, Int>();
        hexChain = new Array<Hexagon>();
        var words = Luxe.resources.find_text('assets/wordlists/en.txt');
        for (word in words.text.split("\n")) {
            wordlist.set(word, 0);
        }

        reset();
    } //ready

    function getRandomLetter() :String {
        var letters = "ABCDEFGHIJKLMNOPQRSTUVWX";
        return letters.charAt(Math.floor(Math.random() * letters.length));
    }

    public function reset() {
        hexmap = new HexMap<Hexagon>();
        for (x in -2 ... 3) {
            for (y in -3 ... 3) {
                var key = { x: x - Math.floor(y / 2), y: y };
                var pos = Vector.Add(Luxe.screen.mid, getHexPosition(key));
                var hexagon = create_hexagon(key, pos, hexSize, getRandomLetter());
                hexmap.setTile(key, hexagon);
            }
        }
    }

    function getHexPosition(hex :Hex) :Vector {
        var height = hexSize * 2;
        var width = Math.sqrt(3) / 2 * height;
        var horiz_dist = width;
        var vert_dist = (3 / 4) * height;
        var x = (hex.x + Math.floor(hex.y / 2)) * (horiz_dist + hexMargin) + Math.abs(hex.y % 2) * (horiz_dist + hexMargin) / 2;
        var y = hex.y * (vert_dist + hexMargin);
        return new Vector(x, y);
    }

    function getRing(hex :Hex, range :Int) :Array<Hexagon> {
        return hexmap.getRing(hex, range)
                .map(hexmap.getTile)
                .filter(function(hex) { return hex != null; });
    }

    function create_hexagon(key: Hex, pos :Vector, size :Int, text :String) :Hexagon {
        var hexagon = new Hexagon(key, pos, size);
        hexagon.add(new VisualInputEvents());
        hexagon.add(new Highlighter());
        hexagon.events.listen('mouse_down', function(e) {
            activeHexagon = hexagon;
            word = text.toLowerCase();
            hexChain.push(hexagon);
            // for (h in getRing(hexagon.hex, 1)) {
                hexagon.events.fire('highlight');
            // }
        });
        hexagon.events.listen('mouse_move', function(e) {
            if (hexagon != activeHexagon) {
                activeHexagon = hexagon;
                hexChain.push(hexagon);
                word += text.toLowerCase();
                // for (h in getRing(hexagon.hex, 1)) {
                    hexagon.events.fire('highlight');
                // }
            }
        });
        hexagon.events.listen('mouse_up', function(e) {
            // trace('clicked on letter: $text'); // TODO: Make a LetterHexagon entity
            if (activeHexagon == null) return;

            while (!hexChain.empty()) {
                hexChain.shift().events.fire('unhighlight');
            }

            activeHexagon = null;
            var inWordlist = (wordlist.get(word) != null);
            trace('Is $word in the word list; $inWordlist');

            events.fire('guessed_word', { word: '$word', correct: inWordlist });
        });

        new Text({
            // no_scene: true,
            text: text,
            pos: new Vector(0, -20),
            color: new Color().rgb(0x000000),
            size: 36,
            align: center, 
            align_vertical: center,
            parent: hexagon
        });

        return hexagon;
    }


} //Main
