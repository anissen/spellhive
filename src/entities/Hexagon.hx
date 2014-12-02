
package entities;

import luxe.Visual;
import luxe.Vector;
import phoenix.geometry.Geometry;
import luxe.Color;

class Hexagon extends Visual {
    var shape :Geometry;

    public function new(_pos :Vector, _size :Float, _depth :Int = 0, ?_color :Color) {
        shape = Luxe.draw.ngon({
            r: _size,
            angle: 90,
            sides: 6,
            solid: true
        });

        super({
            name: 'hexagon.' + Luxe.utils.uniqueid(),
            pos: _pos,
            color: (_color != null ? _color : new Color().rgb(Math.floor(0xf00000 + 0x00ffff * Math.random()))),
            geometry: shape,
            depth: _depth
        });
    }
}
