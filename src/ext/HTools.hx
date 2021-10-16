package ext;

import dn.heaps.Controller.ControllerAccess;
import h2d.Text.Align;

inline function center(text:h2d.Text) {
  text.textAlign = Align.Center;
}

inline function left(text:h2d.Text) {
  text.textAlign = Align.Left;
}

inline function right(text:h2d.Text) {
  text.textAlign = Align.Right;
}

/**
 * Gets the alignment xMin value 
 * @param text 
 */
inline function alignCalcX(text:h2d.Text) {
  return text.getSize().xMin;
}

/**
 * Process multiple keys rather than one for convenience.
 * @param ct 
 * @param keys 
 */
inline function isAnyKeyPressed(ct:ControllerAccess, keys:Array<Int>) {
  return keys.exists((key) -> ct.isKeyboardPressed(key));
}

/**
 * Process multiple keys down rather than one for convenience.
 * @param ct 
 * @param keys 
 */
inline function isAnyKeyDown(ct:ControllerAccess, keys:Array<Int>) {
  return keys.exists((key) -> ct.isKeyboardDown(key));
}