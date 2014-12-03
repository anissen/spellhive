
package entities;

import luxe.Visual;
import luxe.Vector;
import phoenix.geometry.Geometry;
import luxe.Color;
import luxe.Text;

import structures.HexMap;

class LetterHexagon extends Hexagon {
    public var hex(default, default) :Hex;
    public var foreground :Hexagon;
    var text :Text;

    public function new(_hex :Hex, _pos :Vector, _size :Float, letter :String) {
        super(_pos, _size, new Color().rgb(0xe5ab46));

        hex = _hex;

        var foregroundColor = new Color().rgb(0xf9d578);
        foregroundColor.r += Math.random() * 0.05;
        foregroundColor.g += Math.random() * 0.05;
        foregroundColor.b += Math.random() * 0.05;
        foreground = new Hexagon(new Vector(), _size - 5, foregroundColor);
        foreground.parent = this;

        text = new Text({
            text: letter,
            pos: this.pos,
            color: new Color().rgb(0x080602),
            point_size: 42,
            align: center, 
            align_vertical: center
        });
        this.transform.listen_pos(function(v) {
            text.pos = v.clone();
        });
    }

    public function kill() {
        text.visible = false;
        luxe.tween.Actuate
            .tween(scale, 0.3, { x: 0, y: 0 })
            .ease(luxe.tween.easing.Elastic.easeInOut)
            .onComplete(function() { 
                destroy(true);
            });
    }

    public override function ondestroy() {
        text.destroy();
    }
}
