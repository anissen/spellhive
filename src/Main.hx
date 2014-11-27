
import entities.HexLevel;
import luxe.Input;
import luxe.Text;
import luxe.Vector;
import luxe.Color;

import luxe.Parcel;
import luxe.ParcelProgress;

class Main extends luxe.Game {
    var hexLevel :HexLevel;
    var wordGuessText :Text;

    override function ready() {
        Luxe.renderer.clear_color.rgb(0xCC8739);

        var json_asset = Luxe.loadJSON("assets/parcel.json");

        var preload = new Parcel();
        preload.from_json(json_asset.json);

        new ParcelProgress({
            parcel      : preload,
            background  : Luxe.renderer.clear_color,
            oncomplete  : assets_loaded
        });

        preload.load();

    } //ready

    function assets_loaded(_) {
        // var wordlist = Luxe.resources.find_text('assets/wordlists/en.txt');
        // trace('text length: ' + wordlist.text.length);

        wordGuessText = new Text({
            // no_scene: true,
            text: "",
            pos: new Vector(Luxe.screen.w / 2, Luxe.screen.h - 100),
            color: new Color().rgb(0xffffff),
            size: 46,
            align: center, 
            align_vertical: center
        });

        hexLevel = new HexLevel();
        hexLevel.events.listen('guessed_word', function(data: { word :String, correct :Bool, alreadyUsed :Bool }) {
            // trace('word: ${data.word}, correct: ${data.correct}');
            wordGuessText.text = data.word;
            
            wordGuessText.scale.set_xy(0, 0);
            luxe.tween.Actuate
                .tween(wordGuessText.scale, 0.4, { x: 1.0, y: 1.0 })
                .ease(luxe.tween.easing.Elastic.easeInOut);

            wordGuessText.color.set(0, 0, 0);
            var color :Dynamic = (data.correct ? (data.alreadyUsed ? { r: 0, g: 0, b: 200 } : { r: 0, g: 200, b: 0 } ) : { r: 200, g: 0, b: 0 });
            wordGuessText.color
                .tween(0.4, color)
                .ease(luxe.tween.easing.Quad.easeInOut);
        });
    }

    override function onkeyup(e :KeyEvent) {
        switch (e.keycode) {
            case Key.key_f: app.app.window.fullscreen = !app.app.window.fullscreen;
            case Key.key_r: hexLevel.reset();
            case Key.escape: Luxe.shutdown();
        }
    } //onkeyup

} //Main
