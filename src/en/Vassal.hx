package en;

import GameTypes.Talent;

class Vassal extends Entity {
  public var talent:Talent;
  public var statusGraphic:h2d.Graphics;

  public function new(x:Int, y:Int) {
    super(x, y);
    setSprite();
    setupStatusGraphic();
  }

  public function setSprite() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0xffffff);
    g.drawRect(0, 0, 16, 16);
    g.endFill();
    g.x -= 8;
    g.y -= 16;
  }

  public function setupStatusGraphic() {
    statusGraphic = new h2d.Graphics(spr);
    statusGraphic.x -= 8;
    statusGraphic.y -= (16 * 2);
    // On initial start up set to help
    var help = hxd.Res.img.help.toTile();
    statusGraphic.beginTileFill(0, 0, 1, 1, help);
    statusGraphic.drawRect(0, 0, 16, 16);
    statusGraphic.endFill();
  }

  public function saved() {
    var tile = hxd.Res.img.save.toTile();
    statusGraphic.clear();
    statusGraphic.tile.switchTexture(tile);
    statusGraphic.beginTileFill(0, 0, 1, 1, tile);
    statusGraphic.drawRect(0, 0, 16, 16);
    statusGraphic.endFill();
    cd.setS('completeSave', 0.5, () -> {
      // Once it's over remove the graphics completely
      statusGraphic.clear();
    });
  }
}