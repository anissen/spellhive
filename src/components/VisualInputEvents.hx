
package components;

import luxe.Component;
import luxe.Visual;
import luxe.Input;
import luxe.Vector;

class VisualInputEvents extends Component {
    var visual :Visual;
    var leftButtonDown :Bool = false;

    public function new() {
        super({ name: "visual_input_events" });
    }

    override function init() {
        visual = cast entity;
    }

    override function onmousedown(event :MouseEvent) {
        if (event.button == luxe.MouseButton.left) {
            leftButtonDown = true;
            if (inside_geometry(event.pos)) {
                entity.events.fire('mouse_down');
            }
        }
    }

    override function onmouseup(event :MouseEvent) {
        if (event.button == luxe.MouseButton.left) {
            leftButtonDown = false;
            if (inside_geometry(event.pos)) { 
                entity.events.fire('mouse_up');
            }
        }
    }

    override function onmousemove(event :MouseEvent) {
        if (leftButtonDown && inside_geometry(event.pos)) {
            entity.events.fire('mouse_move');
        }
    }

    function inside_geometry(pos :Vector) {
        return (Luxe.utils.geometry.point_in_geometry(pos, visual.geometry));
    }
}
