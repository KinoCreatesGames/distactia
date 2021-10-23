package en;

import dn.heaps.assets.Aseprite;
import dn.heaps.filter.PixelOutline;
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

  public var powerBonus(get, never):Int;

  public inline function get_powerBonus() {
    return vassals.map((vassal) -> vassal.talent == COMMANDER ? 2 : 0)
      .fold((el, result) -> result + el, 0);
  }

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
    var ase = hxd.Res.img.demon_lord_ase_small.toAseprite();
    var player = Aseprite.convertToSLib(Const.FPS, ase);
    player.tmod = Game.ME.tmod;
    spr.set(player);
    spr.anim.playAndLoop('idle');
    // spr.filter = new PixelOutline(0x0, 1);
  }

  override function update() {
    super.update();
    updateControls();
    entityCollissions();
    obstacleCollisions();
    goalCollisions();
    portalCollisions();
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
      } else if (ct.upPressed() && canMove(cx, cy - MOVE_SPD)) {
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
        case en.obstacles.Tree:
          // check
          return talents.contains(CUT);
        case en.obstacles.Gate:
          return talents.contains(LOCKPICK);
        case _:
          return true;
      }
    }

    if (level.hasAnyCollision(x, y)) {
      return false;
    }

    if (level.hasAnyWaterCollision(x, y) && !talents.contains(SWIM)) {
      return false;
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
      vassal.saved();
      addFollower(vassal);
    }

    var enemy = level.collidedEnemy(cx, cy);
    if (enemy != null) {
      // Remove latest vassal and lower power
      removeFollower();
      enemy.destroy();
      Game.ME.camera.shakeS(0.5, 1);
    }
  }

  public function removeFollower() {
    // Remove latest vassal and update current followers
    var vassal = vassals.shift();
    // Delete them
    vassal.destroy();
    updateFollowers(cx, cy);
    power = vassals.length * powerBonus;
    updateHUD();
  }

  public function addFollower(vassal:Vassal) {
    vassals.push(vassal);
    vassal.cx = lastPrevX;
    vassal.cy = lastPrevY;
    power = vassals.length * powerBonus;
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
        case en.obstacles.Tree:
          // Cut down tree if have cutting talent
          if (talents.contains(CUT)) {
            obstacle.destroy();
            setSquashX(0.6);
          }
        case en.obstacles.Gate:
          if (talents.contains(LOCKPICK)) {
            obstacle.destroy();
            setSquashX(0.6);
          }
        case _:
          // Do nothing
      }
    }
  }

  public function goalCollisions() {
    var goal = level.collidedGoal(cx, cy);
    if (goal != null) {
      // Go to the next level and do only next level processing
      Game.ME.nextLevel();
    }
  }

  public function portalCollisions() {
    var portal = level.collidedFinalPortal(cx, cy);
    if (portal != null) {
      // Trigger game complete
      Game.ME.startThankYou();
    }
  }

  // TODO: Dispose of the controller access
}