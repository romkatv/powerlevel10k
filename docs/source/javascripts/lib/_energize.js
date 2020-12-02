/**
 * energize.js v0.1.0
 *
 * Speeds up click events on mobile devices.
 * https://github.com/davidcalhoun/energize.js
 */

(function() {  // Sandbox
  /**
   * Don't add to non-touch devices, which don't need to be sped up
   */
  if(!('ontouchstart' in window)) return;

  var lastClick = {},
      isThresholdReached, touchstart, touchmove, touchend,
      click, closest;
  
  /**
   * isThresholdReached
   *
   * Compare touchstart with touchend xy coordinates,
   * and only fire simulated click event if the coordinates
   * are nearby. (don't want clicking to be confused with a swipe)
   */
  isThresholdReached = function(startXY, xy) {
    return Math.abs(startXY[0] - xy[0]) > 5 || Math.abs(startXY[1] - xy[1]) > 5;
  };

  /**
   * touchstart
   *
   * Save xy coordinates when the user starts touching the screen
   */
  touchstart = function(e) {
    this.startXY = [e.touches[0].clientX, e.touches[0].clientY];
    this.threshold = false;
  };

  /**
   * touchmove
   *
   * Check if the user is scrolling past the threshold.
   * Have to check here because touchend will not always fire
   * on some tested devices (Kindle Fire?)
   */
  touchmove = function(e) {
    // NOOP if the threshold has already been reached
    if(this.threshold) return false;

    this.threshold = isThresholdReached(this.startXY, [e.touches[0].clientX, e.touches[0].clientY]);
  };

  /**
   * touchend
   *
   * If the user didn't scroll past the threshold between
   * touchstart and touchend, fire a simulated click.
   *
   * (This will fire before a native click)
   */
  touchend = function(e) {
    // Don't fire a click if the user scrolled past the threshold
    if(this.threshold || isThresholdReached(this.startXY, [e.changedTouches[0].clientX, e.changedTouches[0].clientY])) {
      return;
    }
    
    /**
     * Create and fire a click event on the target element
     * https://developer.mozilla.org/en/DOM/event.initMouseEvent
     */
    var touch = e.changedTouches[0],
        evt = document.createEvent('MouseEvents');
    evt.initMouseEvent('click', true, true, window, 0, touch.screenX, touch.screenY, touch.clientX, touch.clientY, false, false, false, false, 0, null);
    evt.simulated = true;   // distinguish from a normal (nonsimulated) click
    e.target.dispatchEvent(evt);
  };
  
  /**
   * click
   *
   * Because we've already fired a click event in touchend,
   * we need to listed for all native click events here
   * and suppress them as necessary.
   */  
  click = function(e) {
    /**
     * Prevent ghost clicks by only allowing clicks we created
     * in the click event we fired (look for e.simulated)
     */
    var time = Date.now(),
        timeDiff = time - lastClick.time,
        x = e.clientX,
        y = e.clientY,
        xyDiff = [Math.abs(lastClick.x - x), Math.abs(lastClick.y - y)],
        target = closest(e.target, 'A') || e.target,  // needed for standalone apps
        nodeName = target.nodeName,
        isLink = nodeName === 'A',
        standAlone = window.navigator.standalone && isLink && e.target.getAttribute("href");
    
    lastClick.time = time;
    lastClick.x = x;
    lastClick.y = y;

    /**
     * Unfortunately Android sometimes fires click events without touch events (seen on Kindle Fire),
     * so we have to add more logic to determine the time of the last click.  Not perfect...
     *
     * Older, simpler check: if((!e.simulated) || standAlone)
     */
    if((!e.simulated && (timeDiff < 500 || (timeDiff < 1500 && xyDiff[0] < 50 && xyDiff[1] < 50))) || standAlone) {
      e.preventDefault();
      e.stopPropagation();
      if(!standAlone) return false;
    }

    /** 
     * Special logic for standalone web apps
     * See http://stackoverflow.com/questions/2898740/iphone-safari-web-app-opens-links-in-new-window
     */
    if(standAlone) {
      window.location = target.getAttribute("href");
    }

    /**
     * Add an energize-focus class to the targeted link (mimics :focus behavior)
     * TODO: test and/or remove?  Does this work?
     */
    if(!target || !target.classList) return;
    target.classList.add("energize-focus");
    window.setTimeout(function(){
      target.classList.remove("energize-focus");
    }, 150);
  };

  /**
   * closest
   * @param {HTMLElement} node current node to start searching from.
   * @param {string} tagName the (uppercase) name of the tag you're looking for.
   *
   * Find the closest ancestor tag of a given node.
   *
   * Starts at node and goes up the DOM tree looking for a
   * matching nodeName, continuing until hitting document.body
   */
  closest = function(node, tagName){
    var curNode = node;

    while(curNode !== document.body) {  // go up the dom until we find the tag we're after
      if(!curNode || curNode.nodeName === tagName) { return curNode; } // found
      curNode = curNode.parentNode;     // not found, so keep going up
    }
    
    return null;  // not found
  };

  /**
   * Add all delegated event listeners
   * 
   * All the events we care about bubble up to document,
   * so we can take advantage of event delegation.
   *
   * Note: no need to wait for DOMContentLoaded here
   */
  document.addEventListener('touchstart', touchstart, false);
  document.addEventListener('touchmove', touchmove, false);
  document.addEventListener('touchend', touchend, false);
  document.addEventListener('click', click, true);  // TODO: why does this use capture?
  
})();