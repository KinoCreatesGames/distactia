package ui;

class Hud extends dn.Process {
  public var game(get, never):Game;

  inline function get_game()
    return Game.ME;

  public var fx(get, never):Fx;

  inline function get_fx()
    return Game.ME.fx;

  public var level(get, never):Level;

  inline function get_level()
    return Game.ME.level;

  var flow:h2d.Flow;
  var invalidated = true;
  var powerText:h2d.Text;
  var timerText:h2d.Text;

  public function new() {
    super(Game.ME);

    createRootInLayers(game.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

    flow = new h2d.Flow(root);
    flow.layout = Vertical;
    flow.padding = 8;
    flow.horizontalSpacing = Std.int(w() / 3);
    setupUI();
  }

  public function setupUI() {
    powerText = new h2d.Text(Assets.fontSmall, flow);
    powerText.textColor = 0xffffff;
    powerText.text = '0';

    timerText = new h2d.Text(Assets.fontSmall, flow);
    timerText.textColor = 0xffffff;
    timerText.text = 'Time 0';
  }

  override function onResize() {
    super.onResize();
    root.setScale(Const.UI_SCALE);
  }

  public inline function invalidate()
    invalidated = true;

  function render() {
    renderPower();
    renderGameTime();
  }

  public function renderPower() {
    // Updates the power text in game
    if (level != null && level.player != null) {
      powerText.text = 'Power ${level.player.power}';
    }
  }

  public function renderGameTime() {
    if (level != null) {
      timerText.text = 'Time ${level.levelTime}';
    }
  }

  override function postUpdate() {
    super.postUpdate();

    if (invalidated) {
      invalidated = false;
      render();
    }
  }

  public function hide() {
    flow.visible = false;
  }

  public function show() {
    flow.visible = true;
  }
}