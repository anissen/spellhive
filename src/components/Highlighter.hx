
package components;

import luxe.Component;
import luxe.Visual;

import luxe.tween.Actuate;
import luxe.tween.easing.*;

class Highlighter extends Component {
    var visual :Visual;

    public function new() {
        super({ name: 'highlighter' });
    }

    override function init() {
        visual = cast entity;
        visual.events.listen('highlight', function(e) {
            visual.rotation_z = 0;
            Actuate
                .tween(visual, 1.5, { rotation_z: visual.rotation_z + 360 })
                .ease(luxe.tween.easing.Elastic.easeOut);
        });
    }
}
