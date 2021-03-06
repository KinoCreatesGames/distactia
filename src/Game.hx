import hxd.snd.Channel;
import ui.transition.FadeToBlack;
import dn.Process;
import hxd.Key;
import dn.heaps.Controller.ControllerAccess;

class Game extends dn.Process {
  public static var ME:Game;

  /** Game controller (pad or keyboard) **/
  public var ca:ControllerAccess;

  /** Particles **/
  public var fx:Fx;

  /** Basic viewport control **/
  public var camera:Camera;

  /** Container of all visual game objects. Ths wrapper is moved around by Camera. **/
  public var scroller:h2d.Layers;

  /** Level data **/
  public var level:Level;

  /** UI **/
  public var hud:ui.Hud;

  public var proj:LDTkProj;

  public var transition:ui.transition.FadeToBlack;
  public var bgm:Channel;

  public function new() {
    super(Main.ME);
    ME = this;
    proj = new LDTkProj();
    ca = Main.ME.controller.createAccess("game");
    ca.setLeftDeadZone(0.2);
    ca.setRightDeadZone(0.2);
    createRootInLayers(Main.ME.root, Const.DP_BG);

    scroller = new h2d.Layers();
    root.add(scroller, Const.DP_BG);
    scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

    camera = new Camera();
    hud = new ui.Hud();
    hud.hide();
    #if debug
    new scn.Title();
    // startInitialGame();
    #else
    // Start on Title Screen
    new scn.Title();
    #end
    Process.resizeAll();
    // trace(Lang.t._("Game is ready."));
  }

  /**
   * Starts initial game when on the Title screen.
   * Pushes to the first level.
   */
  public function startInitialGame() {
    // Play Game Loop Music
    bgm = hxd.Res.music.juhani_stage.play(true, 0.5);
    level = new Level(proj.all_levels.Level_0);
    hud.show();
    fx = new Fx();
  }

  public inline function invalidateHud() {
    if (hud != null && !hud.destroyed) {
      hud.invalidate();
    }
  }

  public function startThankYou() {
    // Destroy Level && Start Thank you
    if (bgm != null) {
      bgm.stop();
    }
    level.destroy();
    hud.hide();
    new scn.ThankYou();
  }

  /** CDB file changed on disk**/
  public function onCdbReload() {}

  /**
   * Called whenever LDTk file changes on disk
   */
  @:allow(Assets)
  function onLDtkReload() {
    #if debug
    trace('LDTk file reloaded');
    #else
    #end
    reloadCurrentLevel();
  }

  // Use the below lines when using LDTk for game creation.
  public function nextLevel(levelId:Int = null) {
    // transition = new FadeToBlack();
    hud.hide();
    level.destroy();
    // var level = proj.levels[levelId];
    if (levelId == null) {
      var oldLevelId = Std.parseInt(level.data.identifier.replace('Level_',
        ''));
      levelId = oldLevelId + 1;
    }
    if (levelId != null) {
      var level = proj.levels.filter((lLevel) ->
        lLevel.identifier.contains('Level_${levelId}'))
        .first();
      if (level != null) {
        startLevel(level);
      } else {
        #if debug
        trace('Cannot find level');
        #end
      }
    }
  }

  public function reloadCurrentLevel() {
    if (level != null) {
      if (level.data != null) {
        startLevel(this.proj.getLevel(level.data.uid));
      }
    }
  }

  public function startLevel(ldtkLevel:LDTkProj_Level) {
    if (level != null) {
      level.destroy();
    }
    fx.clear();
    for (entity in Entity.ALL) {
      entity.destroy();
    }
    garbageCollectEntities();
    // Create new level
    level = new Level(ldtkLevel);
    // Will be using the looping mechanisms
  }

  /** Garbage collect any Entity marked for destruction **/
  function garbageCollectEntities() {
    if (Entity.GC == null || Entity.GC.length == 0) return;

    for (e in Entity.GC)
      e.dispose();
    Entity.GC = [];
  }

  /** Window/app resize event **/
  override function onResize() {
    super.onResize();
    scroller.setScale(Const.SCALE);
  }

  /** Garbage collect any Entity marked for destruction **/
  function gc() {
    if (Entity.GC == null || Entity.GC.length == 0) return;

    for (e in Entity.GC)
      e.dispose();
    Entity.GC = [];
  }

  /** Called if game is destroyed, but only at the end of the frame **/
  override function onDispose() {
    super.onDispose();

    fx.destroy();
    for (e in Entity.ALL)
      e.destroy();
    gc();
  }

  /** Loop that happens at the beginning of the frame **/
  override function preUpdate() {
    super.preUpdate();

    for (e in Entity.ALL)
      if (!e.destroyed) e.preUpdate();
  }

  /** Loop that happens at the end of the frame **/
  override function postUpdate() {
    super.postUpdate();

    for (e in Entity.ALL)
      if (!e.destroyed) e.postUpdate();
    gc();
  }

  /** Main loop but limited to 30fps (so it might not be called during some frames) **/
  override function fixedUpdate() {
    super.fixedUpdate();

    for (e in Entity.ALL)
      if (!e.destroyed) e.fixedUpdate();
  }

  /** Main loop **/
  override function update() {
    // if (transition != null && transition.complete) {
    //   transition.destroy();
    // }
    super.update();

    for (e in Entity.ALL)
      if (!e.destroyed) e.update();

    if (!ui.Console.ME.isActive() && !ui.Modal.hasAny()) {
      #if hl
      // Exit
      if (ca.isKeyboardPressed(Key.ESCAPE)) if (!cd.hasSetS("exitWarn",
        3)) trace(Lang.t._("Press ESCAPE again to exit.")); else
        hxd.System.exit();
      #end

      // Restart
      // Reloads the current level in the game.
      if (ca.selectPressed()) {
        hxd.Res.sound.confirm.play();
        reloadCurrentLevel();
      }
    }
  }
}