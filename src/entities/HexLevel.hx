
package entities;

import components.*;

import luxe.Entity;
import luxe.Input;
import phoenix.geometry.LineGeometry;
import luxe.options.GeometryOptions.LineGeometryOptions;
import luxe.Text;
import luxe.Vector;
import luxe.Color;
import luxe.tween.Actuate;

import HexMap;
import HexMap.Point;
import HexMap.Hex;

using Lambda;

class HexLevel extends Entity {
    var letterFrequencies :LetterFrequencies;
    var hexmap :HexMap<LetterHexagon>;
    var hexSize = 50;
    var hexMargin = 5;
    var wordlist :Map<String, Int>; // TODO: Map type?
    var word :String = "";
    var activeHexagon :LetterHexagon;
    var hexChain :Array<LetterHexagon>;
    var hexChainLine :Array<LineGeometry>;

    override function init() {
        letterFrequencies = new LetterFrequencies();
        wordlist = new Map<String, Int>();
        hexChain = new Array<LetterHexagon>();
        hexChainLine = new Array<LineGeometry>();
        var words = Luxe.resources.find_text('assets/wordlists/en.txt');
        for (word in words.text.split("\n")) {
            wordlist.set(word, 0);
        }

        reset();
    } //ready

    function getRandomLetter() :String {
        // var letters = "ABCDEFGHIJKLMNOPQRSTUVWX";
        // return letters.charAt(Math.floor(Math.random() * letters.length));
        return letterFrequencies.randomLetter();
    }

    public function reset() {
        if (hexmap != null) {
            for (h in hexmap.getTiles()) {
                if (h != null) {
                    h.destroy();
                }
            }
        }
        hexmap = new HexMap<LetterHexagon>();
        for (x in -2 ... 3) {
            for (y in -3 ... 3) {
                var key = { x: x - Math.floor(y / 2), y: y };
                var pos = getHexPosition(key);
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
        return Vector.Add(Luxe.screen.mid, new Vector(x, y));
    }

    function getRing(hex :Hex, range :Int) :Array<LetterHexagon> {
        return hexmap.getRing(hex, range)
                .map(hexmap.getTile)
                .filter(function(hex) { return hex != null; });
    }

    function create_hexagon(key: Hex, pos :Vector, size :Int, text :String) :LetterHexagon {
        var hexagon = new LetterHexagon(key, pos, size);
        hexagon.add(new VisualInputEvents());
        hexagon.add(new Highlighter());
        hexagon.events.listen('mouse_down', function(e) {
            activeHexagon = hexagon;
            word = text.toLowerCase();
            hexChain.push(hexagon);
            hexagon.events.fire('highlight');
        });
        hexagon.events.listen('mouse_move', function(e) {
            if (hexagon != activeHexagon) {
                activeHexagon = hexagon;
                hexChain.push(hexagon);
                word += text.toLowerCase();
                hexagon.events.fire('highlight');

                var line = Luxe.draw.line({ 
                    p0: hexChain[hexChain.length-2].pos, 
                    p1: hexChain[hexChain.length-1].pos, 
                    color0: new Color().rgb(0xFF00FF), 
                    color1: new Color().rgb(0x0000FF)
                });
                hexChainLine.push(line);
            }
        });

        // TODO: The hexagon is made smaller, thus failing mouse up. Make the hexagon geometry scale static + add various components for foreground, text etc..
        hexagon.events.listen('mouse_up', function(e) {
            if (activeHexagon == null) return;

            while (!hexChainLine.empty()) {
                hexChainLine.shift().drop();
            }

            activeHexagon = null;
            var fromWordlist = wordlist.get(word);
            var inWordlist   = (fromWordlist != null);
            var alreadyUsed  = false;
            if (inWordlist) {
                alreadyUsed = (fromWordlist > 0);
                wordlist.set(word, 1);
            }

            events.fire('guessed_word', { word: '$word', correct: inWordlist, alreadyUsed: alreadyUsed });

            while (!hexChain.empty()) {
                var h = hexChain.shift();
                if (!inWordlist) {
                    h.events.fire('unhighlight');
                } else {
                    hexmap.setTile(h.hex, null);
                    Actuate
                        .tween(h.scale, 0.3, { x: 0, y: 0 })
                        .ease(luxe.tween.easing.Elastic.easeInOut)
                        .onComplete(function() { h.destroy(true); });
                }
            }

            fillGaps();
        });

        new Text({
            // no_scene: false,
            text: text,
            pos: new Vector(0, -25),
            color: new Color().rgb(0x080602),
            size: 42,
            align: center, 
            align_vertical: center,
            parent: hexagon
        });

        return hexagon;
    }

    var delay :Float = 0;
    function fillGaps() {
        var emptySortedKeys = hexmap.getKeys().filter(function(h) { return hexmap.getTile(h) == null; });
        emptySortedKeys.sort(function(a, b) { return b.y - a.y; });
        emptySortedKeys.sort(function(a, b) { return b.x - a.x; });
        for (hex in emptySortedKeys) {
            delay = 0;
            fillGap(hex);
        }
    }

    function fillGap(hex :Hex) {
        var directions = switch (Math.random() < 0.5) {
            case true:  [Direction.NW, Direction.NE];
            case false: [Direction.NE, Direction.NW];
        };
        for (direction in directions) {
            var neighbor = hexmap.getNeighbor(hex, direction);
            var newH = hexmap.getTile(neighbor);
            if (newH != null) {
                var pos = getHexPosition(hex);
                var oldHex = newH.hex.clone();
                hexmap.setTile(newH.hex, null);
                newH.hex = hex.clone();
                hexmap.setTile(hex, newH);
                var newRotation = newH.rotation_z + ((direction == Direction.NE) ? -60 : 60);
                Actuate
                    .tween(newH, 0.2, { rotation_z: newRotation })
                    .ease(luxe.tween.easing.Quad.easeInOut)
                    .delay(delay);
                Actuate
                    .tween(newH.pos, 0.3, { x: pos.x, y: pos.y })
                    .ease(luxe.tween.easing.Bounce.easeOut)
                    .delay(delay);
                delay += 0.25;

                fillGap(oldHex);
                break;
            }
        }
    }

} //Main
