
package entities;

import luxe.Visual;
import luxe.Vector;
import phoenix.geometry.Geometry;
import luxe.Color;

import HexMap.Hex;

class Hexagon extends Visual {
    public var hex(default, null) :Hex;
    var shape :Geometry;

    public function new(_hex :Hex, _pos :Vector, _size :Float) {
        hex = _hex;

        shape = Luxe.draw.ngon({
            r: _size,
            angle: 90,
            sides: 6,
            solid: true
        });

        super({
            name: 'hexagon.' + Luxe.utils.uniqueid(),
            pos: _pos,
            color: new Color().rgb(Math.floor(0xf00000 + 0x00ffff * Math.random())),
            geometry: shape,
        });
    }
}
