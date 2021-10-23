package scn;

import hxd.SceneEvents;
import dn.heaps.Controller.ControllerAccess;
import hxd.snd.Channel;
import h2d.Flow.FlowAlign;

class Title extends dn.Process {
  var game(get, never):Game;

  inline function get_game() {
    return Game.ME;
  }

  public var complete:Bool;
  public var title:h2d.Text;
  public var win:h2d.Flow;
  public var bgm:Channel;
  public var mask:h2d.Bitmap;
  public var bg:h2d.Bitmap;
  public var ca:ControllerAccess;
  public var events:SceneEvents;
  public var selectionIndex:Int = 0;
  public var optionList:Array<h2d.Interactive>;

  public function new() {
    super(Game.ME);
    ca = Main.ME.controller.createAccess("title");
    ca.setLeftDeadZone(0.2);
    ca.setRightDeadZone(0.2);
    events = new SceneEvents();
    optionList = [];
    createRootInLayers(Game.ME.root, Const.DP_UI);
    complete = false;
    mask = new h2d.Bitmap(h2d.Tile.fromColor(0x0, 1, 1, 0.6), root);
    root.under(mask);

    // Play music

    bgm = hxd.Res.music.juhani_title.play(true);
    #if debug
    // if (bgm != null) {
    //   bgm.stop();
    // }
    #end

    // Start of the title sequence
    setupTitle();
  }

  public function setupTitle() {
    title = new h2d.Text(Assets.fontLarge, root);
    title.text = Lang.t._('Distactia');
    title.textColor = 0xffffff;
    setupTitleWindow();
  }

  public function setupTitleWindow() {
    win = new h2d.Flow(root);
    var width = Std.int(w() / 3);
    win.backgroundTile = h2d.Tile.fromColor(0xFF0000, width, 100, 0.);
    win.borderHeight = 6;
    win.borderWidth = 6;

    win.layout = Vertical;
    win.verticalAlign = FlowAlign.Middle;

    win.padding = 24;
    // Center at the bottom
    // win.x = ((w() / 2) - win.outerWidth / 2);
    setupTitleOptions();
    dn.Process.resizeAll();
  }

  public function setupTitleOptions() {
    var newGame = new h2d.Text(Assets.fontMedium, win);
    newGame.text = Lang.t._('New Game');
    newGame.textColor = 0xffffff;
    newGame.center();
    var ngInt = new h2d.Interactive(win.outerWidth, newGame.textHeight,
      newGame);
    // Handles the relocation of the x coordinate thanks to the alignment change
    ngInt.x = newGame.getSize().xMin;
    ngInt.onClick = (event) -> {
      if (bgm != null) {
        bgm.stop();
      }
      hxd.Res.sound.confirm.play();
      // this.destroy();
      complete = true;
    }
    ngInt.onOver = (event) -> {
      newGame.alpha = 0.5;
      // Trigger sound
      hxd.Res.sound.select.play();
    }
    ngInt.onOut = (event) -> {
      newGame.alpha = 1;
    }

    // // Settings Screen
    // var settings = new h2d.Text(Assets.fontMedium, win);
    // settings.text = Lang.t._('Settings');
    // settings.textColor = 0xffffff;
    // settings.center();
    // var sInt = new h2d.Interactive(win.outerWidth, settings.textHeight,
    //   settings);
    // // Handles the relocation of the x coordinate thanks to the alignment change
    // sInt.x = settings.getSize().xMin;
    // sInt.onClick = (event) -> {
    //   if (bgm != null) {
    //     bgm.stop();
    //   }
    //   hxd.Res.sound.confirm.play();
    //   this.destroy();
    //   new scn.Settings();
    // }
    // sInt.onOver = (event) -> {
    //   settings.alpha = 0.5;
    //   // Trigger sound
    //   hxd.Res.sound.select.play();
    // }
    // sInt.onOut = (event) -> {
    //   settings.alpha = 1;
    // }

    var credits = new h2d.Text(Assets.fontMedium, win);
    credits.text = Lang.t._('Credits');
    credits.textColor = 0xffffff;
    credits.center();
    var crInt = new h2d.Interactive(win.outerWidth, credits.textHeight,
      credits);
    crInt.x = credits.getSize().xMin;
    crInt.onOver = (event) -> {
      credits.alpha = 0.5;
      hxd.Res.sound.select.play();
    }
    crInt.onOut = (event) -> {
      credits.alpha = 1;
    }
    crInt.onClick = (event) -> {
      // Go to credits scene
      // Stop music on the start of the next scene
      if (bgm != null) {
        bgm.stop();
      }
      hxd.Res.sound.confirm.play();
      this.destroy();
      new Credits();
    }

    #if hl
    var exit = new h2d.Text(Assets.fontMedium, win);
    exit.text = 'Exit';
    exit.textColor = 0xffffff;
    exit.center();
    var exitInt = new h2d.Interactive(win.outerWidth, exit.textHeight, exit);
    exitInt.x = exit.getSize().xMin;
    exitInt.onClick = (event) -> {
      if (bgm != null) {
        bgm.stop();
      }
      hxd.Res.sound.confirm.play();
      this.destroy();
      hxd.System.exit();
    }
    exitInt.onOver = (event) -> {
      exit.alpha = 0.5;
      hxd.Res.sound.select.play();
    }
    exitInt.onOut = (event) -> {
      exit.alpha = 1;
    }
    #end
    optionList.push(ngInt);
    // optionList.push(sInt);
    optionList.push(crInt);
    #if hl
    optionList.push(exitInt);
    #end
  }

  override public function update() {
    super.update();
    updateMouseToControls();
    if (complete) {
      // var allText = depot.DepotData.Dialogue_Intro.text.map((text) -> text.str);
      // new IntroScene(() -> {
      Game.ME.startInitialGame();
      // }, allText);
      destroy();
    }
  }

  /**
   * Handles mapping the arrow keys to the mouse interactables.
   */
  public function updateMouseToControls() {
    if (ca.downPressed()) {
      selectionIndex++;
      moveSelection();
    } else if (ca.upPressed()) {
      selectionIndex = M.iclamp(selectionIndex - 1, 0, M.T_INT32_MAX);
      moveSelection();
    }

    // If a or b is pressed create synthetic event
    if (ca.aPressed() || ca.bPressed()) {
      // Send event to current interactable
      var currentSelection = optionList[selectionIndex % optionList.length];
      currentSelection.onClick(new hxd.Event(hxd.Event.EventKind.ERelease,
        currentSelection.x, currentSelection.y));
    }
  }

  public function moveSelection() {
    var currentSelection = optionList[selectionIndex % optionList.length];
    // Place Mouse
    optionList.iter((option) -> {
      option.onOut(new hxd.Event(EOut, option.x, option.y));
    });
    if (currentSelection != null) {
      currentSelection.onOver(new hxd.Event(hxd.Event.EventKind.EOver));
    }
  }

  override public function onResize() {
    super.onResize();
    if (mask != null) {
      var w = M.ceil(w());
      var h = M.ceil(h());
      mask.scaleX = w;
      mask.scaleY = h;
    }
    title.x = (w() * 0.5 - (title.getSize().width * 0.5));
    title.y = (h() * 0.5 - (h() / 3));
    win.x = (w() * 0.5 - (win.outerWidth * 0.2));
    win.y = (h() * 0.5 - (win.outerHeight * 0.3));
  }

  override function onDispose() {
    super.onDispose();
    ca.dispose();
    if (bgm != null) {
      bgm.stop();
    }
  }
}