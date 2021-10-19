package en;

import dn.heaps.filter.PixelOutline;

/**
 * Vassal with the talent that allows them to cut down trees.
 */
class Thief extends Vassal {
  public function new(x:Int, y:Int) {
    super(x, y);
    talent = LOCKPICK;
  }

  override function setSprite() {
    var tile = hxd.Res.img.thief.toTile();
    var g = new h2d.Graphics(spr);
    spr.filter = new PixelOutline(0x0, 1);
    g.beginTileFill(0, 0, 1, 1, tile);
    // g.beginFill(0x0000aa);
    g.drawRect(0, 0, 16, 16);
    g.endFill();
    g.x -= 8;
    g.y -= 16;
  }
}