
package entities;

import components.*;

import luxe.Entity;
import luxe.Input;
import phoenix.geometry.LineGeometry;
import luxe.options.GeometryOptions.LineGeometryOptions;
import luxe.Vector;
import luxe.Color;
import luxe.tween.Actuate;

import structures.HexMap;
import structures.LetterFrequencies;

using Lambda;

class LetterLevel extends Entity {
    var hexTiles :HexTiles;
    var letterFrequencies :LetterFrequencies;
    var wordlist :Map<String, Int>; // TODO: Map type?
    var word :String = "";
    var tilesX = 7;
    var tilesY = 5;

    public function new() {
        super({ name: 'LetterLevel' });

        if (Luxe.screen.h > Luxe.screen.w) {
            var oldTilesX = tilesX;
            tilesX = tilesY;
            tilesY = oldTilesX;
        }
        hexTiles = new HexTiles(tilesX, tilesY);
    }

    override function init() {
        letterFrequencies = new LetterFrequencies();
        wordlist = new Map<String, Int>();
        var words = Luxe.resources.find_text('assets/wordlists/en.txt');
        for (word in words.text.split("\n")) {
            wordlist.set(word, 0);
        }

        hexTiles.events.listen('chain', function(data) {
            word += data.text.toLowerCase();
            data.hexagon.events.fire('highlight');

            var fromWordlist = wordlist.get(word);
            var inWordlist   = (fromWordlist != null);
            var alreadyUsed  = (inWordlist && fromWordlist > 0);
            events.fire('spelling_word', { word: word.toUpperCase(), correct: inWordlist, alreadyUsed: alreadyUsed });
        });

        hexTiles.events.listen('finish_chain', function(chain :Array<LetterHexagon>) {
            var fromWordlist = wordlist.get(word);
            var inWordlist   = (fromWordlist != null);
            var alreadyUsed  = false;
            if (inWordlist) {
                alreadyUsed = (fromWordlist > 0);
                wordlist.set(word, 1);
            }
            events.fire('guessed_word', { word: word.toUpperCase(), correct: inWordlist, alreadyUsed: alreadyUsed });

            for (h in chain) {
                if (!inWordlist || alreadyUsed) {
                    h.events.fire('unhighlight');
                } else {
                    hexTiles.clearTile(h.hex);
                    h.kill();
                }
            }
            word = "";

            fillGaps();
        });

        reset();
    } //ready

    function getRandomLetter() :String {
        return letterFrequencies.randomLetter();
    }

    public function reset() {
        hexTiles.reset();
        hexTiles.forEachHex(function(data) {
            var hexagon = hexTiles.create_hexagon(data.key, data.pos, getRandomLetter());
            hexTiles.hexmap.setTile(data.key, hexagon);
        });
    }

    var delay :Float = 0;
    function fillGaps() {
        var emptySortedKeys = hexTiles.getTilesWhere(function(h) { return hexTiles.hexmap.getTile(h) == null; });
        emptySortedKeys.sort(function(a, b) { return b.y - a.y; });
        emptySortedKeys.sort(function(a, b) { return b.x - a.x; });

        var changed :Bool = false;
        for (hex in emptySortedKeys) {
            delay = 0;
            changed = changed || fillGap(hex);
        }
        if (changed) fillGaps();
    }

    function fillGap(hex :Hex) :Bool {
        var directions = switch (Math.random() < 0.5) {
            case true:  [Direction.NW, Direction.NE];
            case false: [Direction.NE, Direction.NW];
        };
        // TODO: hexTiles.hexmap should be hexTiles
        for (direction in directions) {
            var neighbor = hexTiles.hexmap.getNeighbor(hex, direction);
            var newH = hexTiles.hexmap.getTile(neighbor);
            if (newH != null) {
                var pos = hexTiles.getHexPosition(hex);
                var oldHex = newH.hex.clone();
                hexTiles.hexmap.setTile(newH.hex, null);
                newH.hex = hex.clone();
                hexTiles.hexmap.setTile(hex, newH);
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
                return true;
            }
        }
        return false;
    }

} //Main
