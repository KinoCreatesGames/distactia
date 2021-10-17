package en;

import en.obstacles.Tree;
import GameTypes.Facing;
import GameTypes.Talent;
import dn.heaps.Controller.ControllerAccess;

class Player extends Entity {
  public var ct:ControllerAccess;

  /**
   * The amount of power the overlord has 
   * with his vassals behind him.
   */
  public var power:Int;

  public var vassals:Array<Vassal>;

  public var talents(get, never):Array<Talent>;

  public var facing:Facing;
  public var lastPrevX:Int;
  public var lastPrevY:Int;

  public inline function get_talents() {
    return vassals.map((vassal) -> vassal.talent);
  }

  public static inline var MOVE_SPD:Int = 1;

  public function new(x:Int, y:Int) {
    super(x, y);
    setup();
    Game.ME.invalidateHud();
  }

  public function setup() {
    // Set Up Controllers
    ct = Main.ME.controller.createAccess('player');
    vassals = [];
    setSprite();
  }

  public function setSprite() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0xa0a0ff);
    g.drawRect(0, 0, 16, 16);
    g.endFill();
    g.x -= 8;
  }

  override function update() {
    super.update();
    updateControls();
    entityCollissions();
  }

  public function updateControls() {
    var hasInput = (ct.leftPressed()
      || ct.rightPressed()
      || ct.downPressed()
      || ct.upPressed());

    if (hasInput) {
      if (ct.leftPressed() && canMove(cx - MOVE_SPD, cy)) {
        cx -= MOVE_SPD;
        updateFollowers(-MOVE_SPD);
      } else if (ct.rightPressed() && canMove(cx + MOVE_SPD, cy)) {
        cx += MOVE_SPD;
        updateFollowers(MOVE_SPD);
      } else if (ct.downPressed() && canMove(cx, cy + MOVE_SPD)) {
        cy += MOVE_SPD;
        updateFollowers(0, MOVE_SPD);
      } else if (ct.upPressed() && canMove(cx, cy + MOVE_SPD)) {
        cy -= MOVE_SPD;
        updateFollowers(0, -MOVE_SPD);
      } else {
        Game.ME.camera.shakeS(0.5, 1);
      }
    }
  }

  public function canMove(x:Int = 0, y:Int = 0) {
    // Obstacles
    var obstacle = level.collidedObstacle(x, y);
    if (obstacle != null) {
      var obstacleType = Type.getClass(obstacle);
      switch (obstacleType) {
        case Tree:
          // check
          return talents.contains(CUT);
        case _:
          return true;
      }
    }
    return true;
  }

  public function updateFollowers(x:Int = 0, y:Int = 0) {
    var prevX = (cx + (x * -1));
    var prevY = (cy + (y * -1));
    for (i in 0...vassals.length) {
      var vassal = vassals[i];

      var moveX = (prevX - vassal.cx);
      var moveY = (prevY - vassal.cy);
      prevX = vassal.cx;
      prevY = vassal.cy;
      vassal.cx += moveX;
      vassal.cy += moveY;
    }
    lastPrevX = prevX;
    lastPrevY = prevY;
  }

  public function entityCollissions() {
    // Vassal Collisions
    var vassal = level.collidedVassal(cx, cy);
    if (vassal != null && !vassals.contains(vassal)) {
      setSquashX(0.6);
      addFollower(vassal);
    }
  }

  public function addFollower(vassal:Vassal) {
    vassals.push(vassal);
    vassal.cx = lastPrevX;
    vassal.cy = lastPrevY;
    power += 1;
    updateHUD();
  }

  /**
   * Updates the HUD with the relevant information.
   * Renders the updated player information.
   */
  public function updateHUD() {
    Game.ME.invalidateHud();
  }

  public function obstacleCollisions() {
    var obstacle = level.collidedObstacle(cx, cy);
    if (obstacle != null) {
      var obstacleType = Type.getClass(obstacle);
      switch (obstacleType) {
        case Tree:
          // Cut down tree if have cutting talent
          if (talents.contains(CUT)) {
            obstacle.destroy();
          }
        case _:
          // Do nothing
      }
    }
  }
}