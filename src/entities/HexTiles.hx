
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

class HexTiles extends Entity {
    public var hexmap :HexMap<LetterHexagon>;
    var hexSize :Float = 50;
    var hexMargin :Float = 5;
    var activeHexagon :LetterHexagon;
    var hexChain :Array<LetterHexagon>;
    var tilesX :Int;
    var tilesY :Int;

    public function new(_tilesX :Int, _tilesY :Int) {
        super({ name: 'HexTiles' });
        hexmap = new HexMap<LetterHexagon>();
        hexChain = new Array<LetterHexagon>();
        tilesX = _tilesX;
        tilesY = _tilesY;

        var ratio = Math.min(Luxe.screen.w / tilesX, Luxe.screen.h / tilesY);
        hexSize   = ratio * 0.6 * 0.95; // TODO: Fix this. 0.5 because height = hexSize * 2
        hexMargin = ratio * 0.6 * 0.05;
    }

    override function init() {
        forEachHex(function(data) {
            new Hexagon(data.pos, hexSize + hexMargin, -1, new Color().rgb(0xf3c467)); // background hex
        });

        // reset();
    } //ready

    // TODO: Iterate over hexmap instead of loops
    public function forEachHex(f :{ key: Hex, pos: Vector } -> Void) {
        for (x in -Math.floor(tilesX / 2) ... Math.ceil(tilesX / 2)) {
            for (y in -Math.floor(tilesY / 2) ... Math.ceil(tilesY / 2)) {
                if (Math.abs(y) % 2 == 1 && x == Math.floor(tilesX / 2)) continue;
                var key = { x: x - Math.floor(y / 2), y: y };
                var pos = getHexPosition(key);
                f({ key: key, pos: pos });
            }
        }
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
    }

    public function getHexPosition(hex :Hex) :Vector {
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

    public function clearTile(hex :Hex) {
        hexmap.setTile(hex, null);
    }

    public function getTilesWhere(f :Hex -> Bool) {
        return hexmap.getKeys().filter(f);
    }

    public function create_hexagon(key: Hex, pos :Vector, text :String) :LetterHexagon {
        var hexagon = new LetterHexagon(key, pos, hexSize, text);
        // trace('create_hexagon, ${hexagon}');
        hexagon.add(new VisualInputEvents());
        hexagon.add(new Highlighter());

        hexagon.events.listen('mouse_down', function(e) {
            // trace('mouse_down');
            activeHexagon = hexagon;
            hexChain.push(hexagon);
            events.fire('chain', { hexagon: hexagon, text: text });
        });

        hexagon.events.listen('mouse_move', function(e) {
            // trace('mouse_move');
            if (hexagon != activeHexagon) {
                activeHexagon = hexagon;
                hexChain.push(hexagon);
                events.fire('chain', { hexagon: hexagon, text: text });
            }
        });

        hexagon.events.listen('mouse_up', function(e) {
            // trace('mouse_up');
            activeHexagon = null;
            events.fire('finish_chain', hexChain);
            hexChain.splice(0, hexChain.length);
        });

        return hexagon;
    }

} //Main
