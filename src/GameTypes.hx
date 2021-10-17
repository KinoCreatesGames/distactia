/**
 * Abilities that each vassal has in the game.
 */
enum abstract Talent(String) from String to String {
  var CUT:String = 'cut';
  var LOCKPICK:String = 'lockpick';
}

enum abstract Facing(String) from String to String {
  var LEFT:String = 'left';
  var RIGHT:String = 'right';
  var DOWN:String = 'down';
  var UP:String = 'up';
}