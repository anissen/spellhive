
package components;

import luxe.Component;
import luxe.Visual;
import luxe.Input;

class EventOnClick extends Component {
    var visual :Visual;

    public function new() {
        super({ name: "event_on_click" });
    }

    override function init() {
        visual = cast entity;
    }

    override function onmousedown(event :MouseEvent) {
        if (event.button == luxe.MouseButton.left) {
            if (Luxe.utils.geometry.point_in_geometry(event.pos, visual.geometry)) {
                entity.events.fire('clicked');
            }
        }
    }
}
