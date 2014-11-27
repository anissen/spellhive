
package components;

import luxe.Component;
import luxe.Visual;
import luxe.Color;

import luxe.tween.Actuate;
import luxe.tween.easing.*;

class Highlighter extends Component {
    var visual :Visual;
    var bgcolor :Color;

    public function new() {
        super({ name: 'highlighter' });
    }

    override function init() {
        visual = cast entity;
        bgcolor = visual.color.clone();

        visual.events.listen('highlight', function(e) {
            visual.color.rgb(0x7D3101);
            Actuate
                .tween(visual.scale, 0.5, { x: 0.9, y: 0.9 })
                .ease(luxe.tween.easing.Elastic.easeOut);
        });

        visual.events.listen('unhighlight', function(e) {
            visual.color = bgcolor;
            Actuate
                .tween(visual.scale, 0.8, { x: 1.0, y: 1.0 })
                .ease(luxe.tween.easing.Elastic.easeOut);
        });

        // visual.events.listen('highlight-minor', function(e) {
        //     Actuate
        //         .tween(visual.scale, 0.5, { x: 0.9, y: 0.9 })
        //         .ease(luxe.tween.easing.Elastic.easeOut);
        // });

        // visual.events.listen('unhighlight-minor', function(e) {
        //     Actuate
        //         .tween(visual.scale, 0.8, { x: 1.0, y: 1.0 })
        //         .ease(luxe.tween.easing.Elastic.easeOut);
        // });
    }
}
