package ui.transition;

/**
 * A transition that runs whenever 
 * you exit a level in game to hide the screen loading
 * for a brief period of time.
 */
class Transition extends dn.Process {
  public var mask:h2d.Bitmap;

  /**
   * 1.5 second trasnition timer.
   */
  public static inline var TRANSITION_TIME:Float = 1.5;

  public var transitionTween:Tweenie;

  public function new() {
    super(Game.ME);
    // Hide the root with a giant black box
    createRootInLayers(Game.ME.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix();
    mask = new h2d.Bitmap(h2d.Tile.fromColor(0x0, 1, 1, 1), root);

    root.under(mask);

    transitionTween = new Tweenie(Const.FPS);
    var tween = transitionTween.createS(mask.alpha, 0, TEase, TRANSITION_TIME);
    // var tween = new Tween(tweenie);
    // tween.from = mask.alpha;
    // tween.to = 0;
    tween.end(() -> {
      #if debug
      trace('Transition complete');
      #end
      this.destroy();
    });
    tween.start(() -> {
      #if debug
      trace('Start transition');
      #end
    });
    dn.Process.resizeAll();
  }

  public function startTransition() {}

  override function update() {
    super.update();
    transitionTween.update();
  }

  override function onResize() {
    super.onResize();
    if (mask != null) {
      var w = M.ceil(w());
      var h = M.ceil(h());
      mask.scaleX = w;
      mask.scaleY = h;
    }
  }
}