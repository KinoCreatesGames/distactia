package ui;

import dn.Process;

/**
 * Message window for displaying text within the game
 */
class MsgWindow extends dn.Process {
  public var win:h2d.Flow;
  public var text:h2d.Text;
  public var padding:Int;
  public var textBuffer:String;
  public var allText:Array<String>;
  public var textIndex:Int;
  public var ct:dn.heaps.Controller.ControllerAccess;

  public function new() {
    super(Main.ME);

    createRootInLayers(Game.ME.root, Const.DP_UI);
    // Pixel Perfect Rendering
    root.filter = new h2d.filter.ColorMatrix();
    ct = Main.ME.controller.createAccess('msg');
    textIndex = -1;
    setupWindow();
    Process.resizeAll();
  }

  public function setupWindow() {
    win = new h2d.Flow(root);
    win.backgroundTile = h2d.Tile.fromColor(0x0f0f0f, 200, 200, 0.5);
    win.borderWidth = 7;
    win.borderHeight = 7;
    win.enableInteractive = true;

    win.layout = Vertical;
    win.verticalSpacing = 2;
    padding = 24;

    // Setup window to be the size of the screen size
    win.minHeight = Std.int((h() / 3));
    win.minWidth = Std.int(w() * 0.75);
    setupText();
    win.interactive.onClick = (event) -> {
      advanceText();
    };

    win.padding = padding;
    win.x = 0;
    win.y = (h() - win.minHeight);
  }

  public function setupText() {
    // Add Text
    text = new h2d.Text(Assets.fontMedium, win);
    text.x = padding;
    text.text = '';
    text.maxWidth = win.minWidth - (padding * 2);
    text.textColor = 0xffffff;
  }

  public function sendMsg(text:String) {
    this.text.text = text;
  }

  public function sendMsgs(textData:Array<String>) {
    allText = textData;
  }

  public function advanceText() {
    // Move to the next text String
    if (allText != null && allText.length > 0) {
      textIndex = M.iclamp(textIndex + 1, 0, allText.length - 1);
      var currentText = allText[textIndex];
      if (currentText != text.text) {
        sendMsg(currentText);
      } else {
        // We should be finished processing all the available text
        // Close the window
        resetIndex();
        hide();
        Game.ME.resume();
      }
    }
  }

  public function resetIndex() {
    textIndex = -1;
  }

  public function clearWindow() {
    win.removeChildren();
  }

  public inline function add(e:h2d.Flow) {
    win.addChild(e);
    onResize();
  }

  override function update() {
    if (ct.bPressed() || ct.isAnyKeyPressed([K.ESCAPE, K.X, K.Z])) {
      advanceText();
    }
    super.update();
  }

  override function onResize() {
    super.onResize();
    // Scales the root with the UI
    // This would scale the entire components within as well
    // if (root.scaleX != Const.UI_SCALE) {
    // root.scale(Const.UI_SCALE);

    // var w = M.ceil(w() / Const.UI_SCALE);
    // var h = M.ceil(h() / Const.UI_SCALE);
    // win.x = Std.int(w * 0.5 - win.outerWidth * 0.5);
    // win.y = Std.int(h * 0.5 - win.outerHeight * 0.5);
    // win.minHeight = Std.int((h() / 3));
    // win.minWidth = Std.int(w());
    var padding = 60;
    win.x = (w() * 0.5 - (win.outerWidth * 0.5));
    win.y = (h() - (win.minHeight + padding));
    win.reflow();
  }

  public function hide() {
    this.win.visible = false;
    ct.releaseExclusivity();
  }

  public function show() {
    this.win.visible = true;
    ct.takeExclusivity();
  }

  function onClose() {}

  public function close() {
    if (!destroyed) {
      ct.releaseExclusivity();
      destroy();
      onClose();
    }
  }
}