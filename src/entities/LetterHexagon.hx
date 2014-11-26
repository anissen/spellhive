
package entities;

import luxe.Visual;
import luxe.Vector;
import phoenix.geometry.Geometry;
import luxe.Color;

import HexMap.Hex;

class LetterHexagon extends Hexagon {
    public var hex(default, default) :Hex;
    // var background :Hexagon;
    var foreground :Hexagon;

    public function new(_hex :Hex, _pos :Vector, _size :Float) {
        super(_pos, _size, new Color().rgb(0x222222));

        hex = _hex;

        // background = new Hexagon(_pos, _size, new Color().rgb(0x111111));
        foreground = new Hexagon(new Vector(), _size - 10);
        foreground.parent = this;

        // add(Background);
        // add(Text);
    }
}
