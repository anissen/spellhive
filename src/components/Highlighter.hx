
package components;

import entities.LetterHexagon;

import luxe.Component;
import luxe.Visual;
import luxe.Color;

import luxe.tween.Actuate;
import luxe.tween.easing.*;

class Highlighter extends Component {
    var visual :LetterHexagon;
    var bgcolor :Color;

    public function new() {
        super({ name: 'highlighter' });
    }

    override function init() {
        visual = cast entity;
        bgcolor = visual.color.clone();

        visual.events.listen('highlight', function(e) {
            visual.color.rgb(0x7D3101);
            visual.foreground.scale.set_xy(1.0, 1.0);
            Actuate
                .tween(visual.foreground.scale, 0.5, { x: 0.95, y: 0.95 })
                .ease(luxe.tween.easing.Elastic.easeOut);
        });

        visual.events.listen('unhighlight', function(e) {
            visual.color.set(bgcolor.r, bgcolor.g, bgcolor.b);
            visual.foreground.scale.set_xy(0.95, 0.95);
            Actuate
                .tween(visual.foreground.scale, 0.8, { x: 1.0, y: 1.0 })
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
