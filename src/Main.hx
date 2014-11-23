
import entities.HexLevel;
import luxe.Input;

import luxe.Parcel;
import luxe.ParcelProgress;

class Main extends luxe.Game {
    var hexLevel :HexLevel;

    override function ready() {
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
        hexLevel = new HexLevel();
    }

    override function onkeyup(e :KeyEvent) {
        switch (e.keycode) {
            case Key.key_f: app.app.window.fullscreen = !app.app.window.fullscreen;
            case Key.key_r: hexLevel.reset();
            case Key.escape: Luxe.shutdown();
        }
    } //onkeyup

} //Main
