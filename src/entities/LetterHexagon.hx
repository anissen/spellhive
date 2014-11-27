
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
        super(_pos, _size, new Color().rgb(0xF5BB0F));

        hex = _hex;

        // background = new Hexagon(_pos, _size, new Color().rgb(0x111111));
        var foregroundColor = new Color().rgb(0xEB5E07);
        foregroundColor.r += Math.random() * 0.05;
        foregroundColor.g += Math.random() * 0.05;
        foregroundColor.b += Math.random() * 0.05;
        foreground = new Hexagon(new Vector(), _size - 7, foregroundColor);
        foreground.parent = this;

        // add(Background);
        // add(Text);
    }
}
