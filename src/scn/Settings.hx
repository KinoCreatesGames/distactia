package scn;

import dn.data.SavedData;
import hxd.snd.Manager;

/**
 * Settings screen for updating the in game settings
 */
class Settings extends dn.Process {
  var ct:dn.heaps.Controller.ControllerAccess;
  var mask:h2d.Bitmap;
  var padding:Int;
  var win:h2d.Flow;
  var volumeDisplay:h2d.Text;
  var transition:ui.transition.FadeToBlack;

  public var manager(get, never):Manager;

  public inline function get_manager() {
    return Manager.get();
  }

  public var game(get, never):Game;

  public inline function get_game() {
    return Game.ME;
  }

  public function new() {
    super(Game.ME);
    ct = Main.ME.controller.createAccess('settings');
    createRootInLayers(game.root, Const.DP_UI);
    loadSettings();
    setupSettingsWindow();
    dn.Process.resizeAll();
  }

  public function setupSettingsWindow() {
    win = new h2d.Flow(root);
    win.borderHeight = 7;
    win.borderWidth = 7;
    win.minWidth = Std.int(w() / 2);

    win.verticalSpacing = 16;
    win.layout = Horizontal;
    addOptions();
  }

  public function addOptions() {
    // Add Title Text
    var title = new h2d.Text(Assets.fontLarge, win);
    title.text = Lang.t._('Settings');
    title.center();
    // Add Volume Setting
    var volText = new h2d.Text(Assets.fontMedium, win);
    volText.text = Lang.t._('Volume');
    // Add buttons
    var volDown = new h2d.Text(Assets.fontMedium, win);
    volDown.text = Lang.t._('Down');
    var downInt = setupOption(volDown);
    volumeDisplay = new h2d.Text(Assets.fontMedium, win);

    volumeDisplay.text = Lang.t._('${manager.masterVolume * 100}');
    var volUp = new h2d.Text(Assets.fontMedium, win);
    volUp.text = Lang.t._('Up');
    var upInt = setupOption(volUp);
    upInt.onClick = (event) -> {
      manager.masterVolume = M.fclamp(manager.masterVolume + .1, 0, 1);
      volumeDisplay.text = Lang.t._('${manager.masterVolume * 100}');
      // Save Settings
      saveSettings();
    }
    downInt.onClick = (event) -> {
      manager.masterVolume = M.fclamp(manager.masterVolume - .1, 0, 1);
      volumeDisplay.text = Lang.t._('${manager.masterVolume * 100}');
      saveSettings();
    }
  }

  public function setupOption(text:h2d.Text) {
    text.center();
    var interactive = new h2d.Interactive(win.outerWidth, text.textHeight,
      text);
    interactive.onOut = (event) -> {
      text.alpha = 1;
    }
    interactive.onOver = (event) -> {
      text.alpha = 0.5;
    }
    interactive.x = text.alignCalcX();
    return interactive;
  }

  /**
   * Saves the Settings for the game which will be adjusted on game load
   * on the title screen if available.
   */
  public function saveSettings() {
    SavedData.save(Const.SETTINGS, {
      volume: manager.masterVolume
    });
  }

  public function loadSettings() {
    if (SavedData.exists(Const.SETTINGS)) {
      var data = SavedData.load(Const.SETTINGS, {volume: Float});
      manager.masterVolume = cast data.volume;
    }
  }

  override function update() {
    super.update();
    // Handle the Settings Leave
    if (ct.isAnyKeyPressed([K.ESCAPE]) && transition == null) {
      transition = new ui.transition.FadeToBlack();
    }

    if (transition != null && transition.complete) {
      this.destroy();
      transition.destroy();
      new Title();
    }
  }

  override function onResize() {
    super.onResize();
    // Resize all elements to be centered on screen
    win.x = (w() * 0.5 - (win.outerWidth * 0.5));
    win.y = (h() * 0.5 - (win.outerHeight * 0.5));
  }

  override function onDispose() {
    super.onDispose();
  }
}