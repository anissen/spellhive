
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
    var hexmap :HexMap<LetterHexagon>;
    var hexSize = 50;
    var hexMargin = 3;
    var wordlist :Map<String, Int>; // TODO: Map type?
    var word :String = "";
    var activeHexagon :LetterHexagon;
    // var neighbors :Array<Hexagon>;
    var hexChain :Array<LetterHexagon>;
    var hexChainLine :Array<LineGeometry>;

    override function init() {
        wordlist = new Map<String, Int>();
        // neighbors = new Array<Hexagon>();
        hexChain = new Array<LetterHexagon>();
        hexChainLine = new Array<LineGeometry>();
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
            // neighbors = getRing(hexagon.hex, 1);
            // for (h in neighbors) {
            //     h.events.fire('highlight-minor');
            // }
        });
        hexagon.events.listen('mouse_move', function(e) {
            if (hexagon != activeHexagon) {
                activeHexagon = hexagon;
                hexChain.push(hexagon);
                word += text.toLowerCase();
                hexagon.events.fire('highlight');
                // for (h in neighbors) {
                //     if (hexChain.indexOf(h) == -1) {
                //         h.events.fire('unhighlight-minor');
                //     }
                // }
                // neighbors = getRing(hexagon.hex, 1);
                // for (h in neighbors) {
                //     h.events.fire('highlight-minor');
                // }

                var line = Luxe.draw.line({ 
                    p0: hexChain[hexChain.length-2].pos, 
                    p1: hexChain[hexChain.length-1].pos, 
                    color0: new Color().rgb(0xFF0000), 
                    color1: new Color().rgb(0x0000FF)
                });
                hexChainLine.push(line);
            }
        });

        // TODO: The hexagon is made smaller, thus failing mouse up. Make the hexagon geometry scale static + add various components for foreground, text etc..
        hexagon.events.listen('mouse_up', function(e) {
            // trace('clicked on letter: $text'); // TODO: Make a LetterHexagon entity
            if (activeHexagon == null) return;

            // for (h in neighbors) {
            //     h.events.fire('unhighlight-minor');
            // }

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
            // trace('Is $word in the word list; $inWordlist');

            events.fire('guessed_word', { word: '$word', correct: inWordlist, alreadyUsed: alreadyUsed });

            while (!hexChain.empty()) {
                var h = hexChain.shift();
                if (!inWordlist) {
                    h.events.fire('unhighlight');
                } else {
                    hexmap.setTile(h.hex, null);
                    fillGap(h.hex, h.pos);
                    h.destroy(true);
                }
            }
        });

        new Text({
            // no_scene: false,
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

    function fillGap(hex :Hex, pos: Vector) {
        // for (h in hexmap.getTiles()) {
            // hexagon removed
            // if (h == null) {
                trace('fillGap for ${hex}');
                // TODO: Pick random direction array
                for (direction in [/*Direction.NW,*/ Direction.NE]) {
                    // trace('direction: ${direction}');
                    var neighbor = hexmap.getNeighbor(hex, direction);
                    trace('neighbor: ${neighbor}');
                    var newH = hexmap.getTile(neighbor);
                    trace('newH is null: ${newH == null}');
                    if (newH != null) {
                        newH.color.set(0, 255, 0);
                        var oldHex = newH.hex.clone();
                        var oldPos = newH.pos.clone();
                        hexmap.setTile(oldHex, null); 
                        hexmap.setTile(hex, newH);
                        newH.hex = hex.clone();
                        Actuate
                            .tween(newH.pos, 2.5, { x: pos.x, y: pos.y })
                            .ease(luxe.tween.easing.Elastic.easeInOut)
                            .onComplete(function() { fillGap(oldHex, oldPos); });
                        break;
                    }
                }
            // }
        // }
    }

} //Main
