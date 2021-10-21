package en;

import dn.heaps.filter.PixelOutline;
import dn.heaps.assets.Aseprite;

/**
 * Commander that boosts your overal
 * power by 2.
 */
class Commander extends Vassal {
  public function new(x:Int, y:Int) {
    super(x, y);
    talent = COMMANDER;
  }

  override function setSprite() {
    var ase = hxd.Res.img.commander_ase.toAseprite();
    var commander = Aseprite.convertToSLib(Const.FPS, ase);
    commander.tmod = Game.ME.tmod;
    spr.set(commander);
    spr.anim.playAndLoop('idle');
    spr.filter = new PixelOutline();
  }
}