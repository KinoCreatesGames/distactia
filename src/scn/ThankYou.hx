package scn;

import ui.transition.FadeToBlack;
import hxd.res.DynamicText.Key;
import h2d.Flow.FlowAlign;

class ThankYou extends dn.Process {
  var game(get, never):Game;

  inline function get_game() {
    return Game.ME;
  }

  public var ca:dn.heaps.Controller.ControllerAccess;

  public var complete:Bool;
  public var win:h2d.Flow;
  public var backgroundArt:h2d.Bitmap;
  public var background:h2d.Bitmap;
  public var transition:FadeToBlack;
  public var exitCredits:Bool;

  public function new() {
    super(Game.ME);
    createRootInLayers(Game.ME.root, Const.DP_UI);
    complete = false;
    exitCredits = false;
    ca = Main.ME.controller.createAccess("ThankYou");

    setupThankYou();
    dn.Process.resizeAll();
  }

  public function setupThankYou() {
    // Add background  + Art
    background = new h2d.Bitmap(h2d.Tile.fromColor(0x0, 1, 1, 1), root);
    // var tile = hxd.Res.img.thankyou.toTile();
    // backgroundArt = new h2d.Bitmap(tile, root);
    win = new h2d.Flow(root);
    var width = Std.int(w() / 3);
    win.backgroundTile = h2d.Tile.fromColor(0xff0000, width, 100, 0);
    win.borderHeight = 6;
    win.borderWidth = 6;
    win.verticalSpacing = 16;

    win.layout = Vertical;
    win.verticalAlign = FlowAlign.Middle;
    win.alpha = 0;

    // Create Screen Interactable
    var interactive = new h2d.Interactive(w(), h(), root);
    interactive.onClick = (_) -> {
      exitCredits = true;
    };
    setupText();
  }

  public function setupText() {
    var thanks = new h2d.Text(Assets.fontLarge, win);
    thanks.text = Lang.t._('Thank You For Playing!');
    thanks.center();
    var kino = new h2d.Text(Assets.fontMedium, win);
    kino.text = Lang.t._('KinoCreatesGames - Kino');
    kino.center();
  }

  override public function onResize() {
    super.onResize();
    background.scaleX = w();
    background.scaleY = h();
    if (backgroundArt != null) {
      backgroundArt.x = (w() * 0.3);
      backgroundArt.y = 0;
      backgroundArt.scaleX = 0.5;
      backgroundArt.scaleY = 0.5;
    }
    win.x = (w() * 0.6 - (win.outerWidth * 0.5));
    win.y = (h() * 0.75 - (win.outerHeight * 0.15));
  }

  override public function update() {
    super.update();
    // Hit Escape to exit the credits screen
    if (win.alpha < 1) {
      win.alpha = M.lerp(win.alpha, 1.2, 0.05);
    }

    if (!exitCredits) {
      exitCredits = ca.isKeyboardPressed(K.ESCAPE);
    }
    if (exitCredits && transition == null) {
      // new Title();
      transition = new FadeToBlack();
    }
    if (transition != null && transition.complete) {
      this.destroy();
      transition.destroy();
      new Title();
    }
  }
}