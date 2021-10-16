package ui;

import dn.heaps.filter.PixelOutline;

class Notification extends dn.Process {
  public var win:h2d.Flow;
  public var text:h2d.Text;
  public var padding:Int;

  var ct:dn.heaps.Controller.ControllerAccess;
  var mask:h2d.Bitmap;

  public function new() {
    super(Main.ME);
    createRootInLayers(Game.ME.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix(); // Pixel Perfect Rendering

    mask = new h2d.Bitmap(h2d.Tile.fromColor(0x0, 1, 1, 0.6), root);
    root.under(mask);

    ct = Main.ME.controller.createAccess('notify');

    padding = 16;
    win = new h2d.Flow(root);
    win.backgroundTile = h2d.Tile.fromColor(0x0, 32, 32, 0.7);
    win.borderWidth = 8;
    win.borderHeight = 8;
    win.layout = Vertical;
    win.verticalSpacing = 2;
    win.padding = padding;
    win.minHeight = Std.int(h() / 3);
    win.minWidth = Std.int(w() * 0.5);
    win.filter = new PixelOutline(0xffffff, 0.5, false);
    setupText();
    dn.Process.resizeAll();
  }

  public function setupText() {
    text = new h2d.Text(Assets.fontMedium, win);
    text.text = '';
    text.maxWidth = win.minWidth - (padding * 2);
    text.textAlign = Center;
    text.textColor = 0xffffff;
  }

  public function clearContents() {
    win.removeChildren();
  }

  public function hide() {
    win.visible = false;
    mask.visible = false;
    text.text = '';
    ct.releaseExclusivity();
  }

  public function show() {
    win.visible = true;
    mask.visible = true;
  }

  /**
   * Sends a notification message to the screen and temporarily
   * pauses the gameplay.
   * @param msg 
   */
  public function sendMsg(msg:String) {
    if (!win.visible) {
      Game.ME.pause();
      ct.takeExclusivity();
      show();
    }
    // Send a message to the screen and show the window
    text.text = msg;
  }

  override function update() {
    super.update();
    // Complete viewing notification
    if (win.visible) {
      // Makes it exclusive so that the controls work when
      // Game is paused
      if (ct.isAnyKeyPressed([K.ESCAPE, K.X, K.Z])) {
        this.hide();
        Game.ME.resume();
      }
    }
  }

  override function onResize() {
    super.onResize();
    if (mask != null) {
      mask.scaleX = w();
      mask.scaleY = h();
    }
    win.x = (w() * 0.5 - (win.outerWidth * 0.5));
    win.y = ((h() * 0.65) - win.minHeight);
    win.reflow();
  }
}