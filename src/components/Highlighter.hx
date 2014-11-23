
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
            Actuate
                .tween(visual.scale, 0.5, { x: 0.8, y: 0.8 })
                .ease(luxe.tween.easing.Elastic.easeOut);
        });

        visual.events.listen('unhighlight', function(e) {
            Actuate
                .tween(visual.scale, 0.8, { x: 1.0, y: 1.0 })
                .ease(luxe.tween.easing.Elastic.easeOut);
        });
    }
}
