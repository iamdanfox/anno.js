(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("jQuery"));
	else if(typeof define === 'function' && define.amd)
		define(["jQuery"], factory);
	else {
		var a = typeof exports === 'object' ? factory(require("jQuery")) : factory(root["jQuery"]);
		for(var i in a) (typeof exports === 'object' ? exports : root)[i] = a[i];
	}
})(this, function(__WEBPACK_EXTERNAL_MODULE_1__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	var $, Anno, AnnoButton,
	  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

	$ = __webpack_require__(1);

	__webpack_require__(2);

	exports.Anno = Anno = (function() {
	  var _returnFromOnShow;

	  function Anno(arg) {
	    var key, options, others, val;
	    if (arg.__proto__ === Array.prototype) {
	      options = arg.shift();
	      others = arg;
	    } else {
	      options = arg;
	    }
	    if (options instanceof Anno) {
	      console.warn('Anno constructor parameter is already an Anno object.');
	    }
	    if (options == null) {
	      console.warn("new Anno() created with no options. It's recommended" + " to supply at least target and content.");
	    }
	    for (key in options) {
	      val = options[key];
	      if (key === 'chainTo' || key === 'start' || key === 'show' || key === 'hide' || key === 'hideAnno' || key === 'chainSize' || key === 'chainIndex' || key === 'version') {
	        console.warn(("Anno: Overriding '" + key + "' is not recommended. Can ") + "you override a delegated function instead?");
	      }
	    }
	    for (key in options) {
	      val = options[key];
	      this[key] = val;
	    }
	    if ((others != null ? others.length : void 0) > 0) {
	      this.chainTo(new Anno(others));
	    }
	    return;
	  }

	  Anno.setDefaults = function(options) {
	    var key, val, _results;
	    _results = [];
	    for (key in options) {
	      val = options[key];
	      _results.push(Anno.prototype[key] = val);
	    }
	    return _results;
	  };

	  Anno.prototype.chainTo = function(obj) {
	    if (obj != null) {
	      if (this._chainNext == null) {
	        this._chainNext = obj instanceof Anno ? obj : new Anno(obj);
	        this._chainNext._chainPrev = this;
	      } else {
	        this._chainNext.chainTo(obj);
	      }
	    } else {
	      console.error("Can't chainTo a null object.");
	    }
	    return this;
	  };

	  Anno.prototype._chainNext = null;

	  Anno.prototype._chainPrev = null;

	  Anno.chain = function(array) {
	    console.warn('Anno.chain([...]) is deprecated. Use ' + '`new Anno([...])` instead.');
	    return new Anno(array);
	  };

	  Anno.prototype.chainSize = function() {
	    if (this._chainNext != null) {
	      return this._chainNext.chainSize();
	    } else {
	      return 1 + this.chainIndex();
	    }
	  };

	  Anno.prototype.chainIndex = function(index) {
	    var find;
	    if (index != null) {
	      return (find = function(curr, i, u) {
	        var ci;
	        if (curr != null) {
	          ci = curr.chainIndex();
	          if ((0 <= ci && ci < i)) {
	            return find(curr._chainNext, i, u);
	          } else if ((i < ci && ci <= u)) {
	            return find(curr._chainPrev, i, u);
	          } else if (ci === i) {
	            return curr;
	          }
	        } else {
	          return console.error(("Couldn't switch to index '" + i + "'. Chain size ") + ("is '" + u + "'"));
	        }
	      })(this, index, this.chainSize());
	    } else {
	      if (this._chainPrev != null) {
	        return 1 + this._chainPrev.chainIndex();
	      } else {
	        return 0;
	      }
	    }
	  };

	  Anno.prototype.show = function() {
	    var $target, lastButton;
	    $target = this.targetFn();
	    if (this._annoElem != null) {
	      console.warn(("Anno elem for '" + this.target + "' has already been ") + "generated.  Did you call show() twice?");
	    }
	    this._annoElem = this.annoElem();
	    this.emphasiseTarget();
	    this.showOverlay();
	    $target.after(this._annoElem);
	    this._annoElem.addClass('anno-target-' + this.arrowPositionFn());
	    this.positionAnnoElem();
	    setTimeout(((function(_this) {
	      return function() {
	        return _this._annoElem.removeClass('anno-hidden');
	      };
	    })(this)), 50);
	    $target.scrollintoview();
	    setTimeout(((function(_this) {
	      return function() {
	        return _this._annoElem.scrollintoview();
	      };
	    })(this)), 300);
	    lastButton = this._annoElem.find('button').last();
	    if (this.rightArrowClicksLastButton) {
	      lastButton.keydown(function(evt) {
	        if (evt.keyCode === 39) {
	          return $(this).click();
	        }
	      });
	    }
	    if (this.autoFocusLastButton && $target.find(':focus').length === 0) {
	      lastButton.focus();
	    }
	    this._returnFromOnShow = this.onShow(this, $target, this._annoElem);
	    return this;
	  };

	  Anno.prototype.start = function() {
	    return this.show();
	  };

	  Anno.prototype.rightArrowClicksLastButton = true;

	  Anno.prototype.autoFocusLastButton = true;

	  Anno.prototype.onShow = function(anno, $target, $annoElem) {};

	  _returnFromOnShow = null;

	  Anno.prototype.hide = function() {
	    this.hideAnno();
	    setTimeout(this.hideOverlay, 50);
	    return this;
	  };

	  Anno.prototype.hideAnno = function() {
	    if (this._annoElem != null) {
	      this._annoElem.addClass('anno-hidden');
	      this.deemphasiseTarget();
	      this.onHide(this, this.targetFn(), this._annoElem, this._returnFromOnShow);
	      (function(annoEl) {
	        return setTimeout((function() {
	          return annoEl.remove();
	        }), 300);
	      })(this._annoElem);
	      this._annoElem = null;
	    } else {
	      console.warn(("Can't hideAnno() for '" + this.target + "' when @_annoElem ") + "is null.  Did you call hideAnno() twice?");
	    }
	    return this;
	  };

	  Anno.prototype.onHide = function(anno, $target, $annoElem, returnFromOnShow) {};

	  Anno.prototype.switchTo = function(otherAnno) {
	    if (otherAnno != null) {
	      this.hideAnno();
	      return otherAnno.show();
	    } else {
	      console.warn("Can't switchTo a null object. Hiding instead.");
	      return this.hide();
	    }
	  };

	  Anno.prototype.switchToChainNext = function() {
	    return this.switchTo(this._chainNext);
	  };

	  Anno.prototype.switchToChainPrev = function() {
	    return this.switchTo(this._chainPrev);
	  };

	  Anno.prototype.target = 'h1';

	  Anno.prototype.targetFn = function() {
	    var r;
	    if (typeof this.target === 'string') {
	      r = $(this.target).filter(':not(.anno-placeholder)');
	      if (r.length === 0) {
	        console.error("Couldn't find Anno.target '" + this.target + "'.");
	      }
	      if (r.length > 1) {
	        console.warn(("Anno target '" + this.target + "' matched " + r.length + " ") + "elements. Targeting the first one.");
	      }
	      return r.first();
	    } else if (this.target instanceof jQuery) {
	      if (this.target.length > 1) {
	        console.warn(("Anno jQuery target matched " + this.target.length + " ") + "elements. Targeting the first one.");
	      }
	      return this.target.first();
	    } else if (this.target instanceof HTMLElement) {
	      return $(this.target);
	    } else if (typeof this.target === 'function') {
	      return this.target();
	    } else {
	      console.error("Unrecognised Anno.target. Please supply a jQuery " + "selector string, a jQuery object, a raw DOM element or a " + "function returning a jQuery element. target:");
	      return console.error(this.target);
	    }
	  };

	  Anno.prototype.annoElem = function() {
	    this._annoElem = $("<div class='anno anno-hidden " + this.className + "'>\n<div class='anno-inner'>  <div class='anno-arrow'></div>  </div>\n</div>");
	    this._annoElem.find('.anno-inner').append(this.contentElem()).append(this.buttonsElem());
	    return this._annoElem;
	  };

	  Anno.prototype._annoElem = null;

	  Anno.prototype.className = '';

	  Anno.prototype.content = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

	  Anno.prototype.contentFn = function() {
	    return this.content;
	  };

	  Anno.prototype.contentElem = function() {
	    return $("<div class='anno-content'>" + this.contentFn() + "</div>");
	  };

	  Anno.prototype.showOverlay = function() {
	    var $e;
	    if ($('.anno-overlay').length === 0) {
	      $('body').append($e = this.overlayElem().addClass('anno-hidden'));
	      return setTimeout((function() {
	        return $e.removeClass('anno-hidden');
	      }), 10);
	    } else {
	      return $('.anno-overlay').replaceWith(this.overlayElem());
	    }
	  };

	  Anno.prototype.overlayElem = function() {
	    return $("<div class='anno-overlay " + this.overlayClassName + "'></div>").click((function(_this) {
	      return function(evt) {
	        return _this.overlayClick.call(_this, _this, evt);
	      };
	    })(this));
	  };

	  Anno.prototype.overlayClassName = '';

	  Anno.prototype.overlayClick = function(anno, evt) {
	    return anno.hide();
	  };

	  Anno.prototype.hideOverlay = function() {
	    $('.anno-overlay').addClass('anno-hidden');
	    return setTimeout((function() {
	      return $('.anno-overlay').remove();
	    }), 300);
	  };

	  Anno.prototype.emphasiseTarget = function($target) {
	    var origbg, origheight, origleft, origtop, origwidth, origzindex, placeholder, ppos, startposition, tpos;
	    if ($target == null) {
	      $target = this.targetFn();
	    }
	    this._undoEmphasise = [];
	    $target.closest(':scrollable').on('mousewheel', function(evt) {
	      evt.preventDefault();
	      return evt.stopPropagation();
	    });
	    this._undoEmphasise.push(function($t) {
	      return $t.closest(':scrollable').off('mousewheel');
	    });
	    if ($target.css('position') === 'static') {
	      $target.after(placeholder = $target.clone().addClass('anno-placeholder'));
	      (function(_this) {
	        return (function(placeholder) {
	          return _this._undoEmphasise.push(function() {
	            return placeholder.remove();
	          });
	        });
	      })(this)(placeholder);
	      startposition = $target.prop('style').position;
	      (function(_this) {
	        return (function(startposition) {
	          return _this._undoEmphasise.push(function($t) {
	            return $t.css({
	              position: startposition
	            });
	          });
	        });
	      })(this)(startposition);
	      $target.css({
	        position: 'absolute'
	      });
	      if ($target.outerWidth() !== placeholder.outerWidth()) {
	        origwidth = $target.prop('style').width;
	        (function(_this) {
	          return (function(origwidth) {
	            return _this._undoEmphasise.push(function($t) {
	              return $t.css({
	                width: origwidth
	              });
	            });
	          });
	        })(this)(origwidth);
	        $target.css('width', placeholder.outerWidth());
	      }
	      if ($target.outerHeight() !== placeholder.outerHeight()) {
	        origheight = $target.prop('style').height;
	        (function(_this) {
	          return (function(origheight) {
	            return _this._undoEmphasise.push(function($t) {
	              return $t.css({
	                height: origheight
	              });
	            });
	          });
	        })(this)(origheight);
	        $target.css('height', placeholder.outerHeight());
	      }
	      ppos = placeholder.position();
	      tpos = $target.position();
	      if (tpos.top !== ppos.top) {
	        origtop = $target.prop('style').top;
	        (function(_this) {
	          return (function(origtop) {
	            return _this._undoEmphasise.push(function($t) {
	              return $t.css({
	                top: origtop
	              });
	            });
	          });
	        })(this)(origtop);
	        $target.css('top', ppos.top);
	      }
	      if (tpos.left !== ppos.left) {
	        origleft = $target.prop('style').left;
	        (function(_this) {
	          return (function(origleft) {
	            return _this._undoEmphasise.push(function($t) {
	              return $t.css({
	                left: origleft
	              });
	            });
	          });
	        })(this)(origleft);
	        $target.css('left', ppos.left);
	      }
	    }
	    if ($target.css('backgroundColor') === 'rgba(0, 0, 0, 0)' || $target.css('backgroundColor') === 'transparent') {
	      console.warn(("Anno.js target '" + this.target + "' has a transparent bg; ") + "filling it white temporarily.");
	      origbg = $target.prop('style').background;
	      (function(_this) {
	        return (function(origbg) {
	          return _this._undoEmphasise.push(function($t) {
	            return $t.css({
	              background: origbg
	            });
	          });
	        });
	      })(this)(origbg);
	      $target.css({
	        background: 'white'
	      });
	    }
	    origzindex = $target.prop('style').zIndex;
	    (function(_this) {
	      return (function(origzindex) {
	        return _this._undoEmphasise.push(function($t) {
	          return $t.css({
	            zIndex: origzindex
	          });
	        });
	      });
	    })(this)(origzindex);
	    $target.css({
	      zIndex: '1001'
	    });
	    return $target;
	  };

	  Anno.prototype._undoEmphasise = [];

	  Anno.prototype.deemphasiseTarget = function() {
	    var $target, fn, _i, _len, _ref;
	    $target = this.targetFn();
	    _ref = this._undoEmphasise;
	    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
	      fn = _ref[_i];
	      fn($target);
	    }
	    return $target;
	  };

	  Anno.prototype.position = null;

	  Anno.prototype.positionAnnoElem = function(annoEl) {
	    var $targetEl, offset, pos;
	    if (annoEl == null) {
	      annoEl = this._annoElem;
	    }
	    pos = this.positionFn();
	    $targetEl = this.targetFn();
	    offset = $targetEl.position();
	    switch (pos) {
	      case 'top':
	      case 'bottom':
	        annoEl.css({
	          left: offset.left + 'px'
	        });
	        break;
	      case 'center-top':
	      case 'center-bottom':
	        annoEl.css({
	          left: offset.left + ($targetEl.outerWidth() / 2 - annoEl.outerWidth() / 2) + 'px'
	        });
	        break;
	      case 'left':
	      case 'right':
	        annoEl.css({
	          top: offset.top + 'px'
	        });
	        break;
	      case 'center-left':
	      case 'center-right':
	        annoEl.css({
	          top: offset.top + ($targetEl.outerHeight() / 2 - annoEl.outerHeight() / 2) + 'px'
	        });
	    }
	    switch (pos) {
	      case 'top':
	      case 'center-top':
	        annoEl.css({
	          top: offset.top - annoEl.outerHeight() + 'px'
	        });
	        break;
	      case 'bottom':
	      case 'center-bottom':
	        annoEl.css({
	          top: offset.top + $targetEl.outerHeight() + 'px'
	        });
	        break;
	      case 'left':
	      case 'center-left':
	        annoEl.css({
	          left: offset.left - annoEl.outerWidth() + 'px'
	        });
	        break;
	      case 'right':
	      case 'center-right':
	        annoEl.css({
	          left: offset.left + $targetEl.outerWidth() + 'px'
	        });
	        break;
	      default:
	        if ((pos.left != null) || (pos.right != null) || (pos.top != null) || (pos.bottom != null)) {
	          annoEl.css(pos);
	        } else {
	          console.error("Unrecognised position: '" + pos + "'");
	        }
	    }
	    return annoEl;
	  };

	  Anno.prototype.positionFn = function() {
	    var $container, $target, allowed, annoBounds, bad, containerOffset, targetBounds, targetOffset, viewBounds;
	    if (this.position != null) {
	      return this.position;
	    } else if (this._annoElem != null) {
	      $target = this.targetFn();
	      $container = $target.closest(':scrollable');
	      if ($container.length === 0) {
	        $container = $('body');
	      }
	      targetOffset = $target.offset();
	      containerOffset = $container.offset();
	      targetBounds = {
	        left: targetOffset.left - containerOffset.left,
	        top: targetOffset.top - containerOffset.top
	      };
	      targetBounds.right = targetBounds.left + $target.outerWidth();
	      targetBounds.bottom = targetBounds.top + $target.outerHeight();
	      viewBounds = {
	        w: $container.width() || $container.width(),
	        h: $container.height() || $container.height()
	      };
	      annoBounds = {
	        w: this._annoElem.outerWidth(),
	        h: this._annoElem.outerHeight()
	      };
	      bad = [];
	      if (annoBounds.w > targetBounds.left) {
	        bad = bad.concat(['left', 'center-left']);
	      }
	      if (annoBounds.h > targetBounds.top) {
	        bad = bad.concat(['top', 'center-top']);
	      }
	      if (annoBounds.w + targetBounds.right > viewBounds.w) {
	        bad = bad.concat(['right', 'center-right']);
	      }
	      if (annoBounds.h + targetBounds.bottom > viewBounds.h) {
	        bad = bad.concat(['bottom', 'center-bottom']);
	      }
	      allowed = Anno.preferredPositions.filter(function(p) {
	        return __indexOf.call(bad, p) < 0;
	      });
	      if (allowed.length === 0) {
	        console.error(("Anno couldn't guess a position for '" + this.target + "'. ") + "Please supply one in the constructor.");
	      } else {
	        console.warn(("Anno: guessing position:'" + allowed[0] + "' for ") + ("'" + this.target + "'. Possible Anno.preferredPositions: [" + allowed + "]."));
	      }
	      return this.position = allowed[0];
	    }
	  };

	  Anno.preferredPositions = ['bottom', 'right', 'left', 'top', 'center-bottom', 'center-right', 'center-left', 'center-top'];

	  Anno.prototype.arrowPositionFn = function() {
	    var pos, r;
	    if (this.arrowPosition != null) {
	      return this.arrowPosition;
	    } else if (typeof this.positionFn() === 'string') {
	      return {
	        'top': 'bottom',
	        'center-top': 'center-bottom',
	        'left': 'right',
	        'center-left': 'center-right',
	        'right': 'left',
	        'center-right': 'center-left',
	        'bottom': 'top',
	        'center-bottom': 'center-top'
	      }[this.positionFn()];
	    } else {
	      pos = {
	        l: parseInt(this.positionFn().left, 10),
	        t: parseInt(this.positionFn().top, 10)
	      };
	      if (Math.abs(pos.l) > Math.abs(pos.t)) {
	        r = pos.l < 0 ? 'center-right' : 'center-left';
	      } else {
	        r = pos.t < 0 ? 'center-bottom' : 'center-top';
	      }
	      console.warn(("Guessing arrowPosition:'" + r + "' for " + this.target + ". ") + "Include this in your constructor for consistency.");
	      return r;
	    }
	  };

	  Anno.prototype.arrowPosition = null;

	  Anno.prototype.buttons = [{}];

	  Anno.prototype.buttonsFn = function() {
	    if (this.buttons instanceof Array) {
	      return this.buttons.map(function(b) {
	        return new AnnoButton(b);
	      });
	    } else {
	      return [new AnnoButton(this.buttons)];
	    }
	  };

	  Anno.prototype.buttonsElem = function() {
	    var b;
	    return $("<div class='anno-btn-container'></div>").append((function() {
	      var _i, _len, _ref, _results;
	      _ref = this.buttonsFn();
	      _results = [];
	      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
	        b = _ref[_i];
	        _results.push(b.buttonElem(this));
	      }
	      return _results;
	    }).call(this));
	  };

	  return Anno;

	})();

	exports.AnnoButton = AnnoButton = (function() {
	  function AnnoButton(options) {
	    var key, val;
	    for (key in options) {
	      val = options[key];
	      this[key] = val;
	    }
	  }

	  AnnoButton.prototype.buttonElem = function(anno) {
	    return $("<button class='anno-btn'></button>").html(this.textFn(anno)).addClass(this.className).click((function(_this) {
	      return function(evt) {
	        return _this.click.call(anno, anno, evt);
	      };
	    })(this));
	  };

	  AnnoButton.prototype.textFn = function(anno) {
	    if (this.text != null) {
	      return this.text;
	    } else if (anno._chainNext != null) {
	      return 'Next';
	    } else {
	      return 'Done';
	    }
	  };

	  AnnoButton.prototype.text = null;

	  AnnoButton.prototype.className = '';

	  AnnoButton.prototype.click = function(anno, evt) {
	    if (anno._chainNext != null) {
	      return anno.switchToChainNext();
	    } else {
	      return anno.hide();
	    }
	  };

	  AnnoButton.NextButton = new AnnoButton({
	    text: 'Next',
	    click: function() {
	      return this.switchToChainNext();
	    }
	  });

	  AnnoButton.DoneButton = new AnnoButton({
	    text: 'Done',
	    click: function() {
	      return this.hide();
	    }
	  });

	  AnnoButton.BackButton = new AnnoButton({
	    text: 'Back',
	    className: 'anno-btn-low-importance',
	    click: function() {
	      return this.switchToChainPrev();
	    }
	  });

	  return AnnoButton;

	})();


/***/ },
/* 1 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_1__;

/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	/*!
	 * jQuery scrollintoview() plugin and :scrollable selector filter
	 *
	 * Version 1.8 (14 Jul 2011)
	 * Requires jQuery 1.4 or newer
	 *
	 * Copyright (c) 2011 Robert Koritnik
	 * Licensed under the terms of the MIT license
	 * http://www.opensource.org/licenses/mit-license.php
	 */

	(function ($) {
		var converter = {
			vertical: { x: false, y: true },
			horizontal: { x: true, y: false },
			both: { x: true, y: true },
			x: { x: true, y: false },
			y: { x: false, y: true }
		};

		var settings = {
			duration: "fast",
			direction: "both"
		};

		var rootrx = /^(?:html)$/i;

		// gets border dimensions
		var borders = function (domElement, styles) {
			styles = styles || (document.defaultView && document.defaultView.getComputedStyle ? document.defaultView.getComputedStyle(domElement, null) : domElement.currentStyle);
			var px = document.defaultView && document.defaultView.getComputedStyle ? true : false;
			var b = {
				top: (parseFloat(px ? styles.borderTopWidth : $.css(domElement, "borderTopWidth")) || 0),
				left: (parseFloat(px ? styles.borderLeftWidth : $.css(domElement, "borderLeftWidth")) || 0),
				bottom: (parseFloat(px ? styles.borderBottomWidth : $.css(domElement, "borderBottomWidth")) || 0),
				right: (parseFloat(px ? styles.borderRightWidth : $.css(domElement, "borderRightWidth")) || 0)
			};
			return {
				top: b.top,
				left: b.left,
				bottom: b.bottom,
				right: b.right,
				vertical: b.top + b.bottom,
				horizontal: b.left + b.right
			};
		};

		var dimensions = function ($element) {
			var win = $(window);
			var isRoot = rootrx.test($element[0].nodeName);
			return {
				border: isRoot ? { top: 0, left: 0, bottom: 0, right: 0} : borders($element[0]),
				scroll: {
					top: (isRoot ? win : $element).scrollTop(),
					left: (isRoot ? win : $element).scrollLeft()
				},
				scrollbar: {
					right: isRoot ? 0 : $element.innerWidth() - $element[0].clientWidth,
					bottom: isRoot ? 0 : $element.innerHeight() - $element[0].clientHeight
				},
				rect: (function () {
					var r = $element[0].getBoundingClientRect();
					return {
						top: isRoot ? 0 : r.top,
						left: isRoot ? 0 : r.left,
						bottom: isRoot ? $element[0].clientHeight : r.bottom,
						right: isRoot ? $element[0].clientWidth : r.right
					};
				})()
			};
		};

		$.fn.extend({
			scrollintoview: function (options) {
				/// <summary>Scrolls the first element in the set into view by scrolling its closest scrollable parent.</summary>
				/// <param name="options" type="Object">Additional options that can configure scrolling:
				///        duration (default: "fast") - jQuery animation speed (can be a duration string or number of milliseconds)
				///        direction (default: "both") - select possible scrollings ("vertical" or "y", "horizontal" or "x", "both")
				///        complete (default: none) - a function to call when scrolling completes (called in context of the DOM element being scrolled)
				/// </param>
				/// <return type="jQuery">Returns the same jQuery set that this function was run on.</return>

				options = $.extend({}, settings, options);
				options.direction = converter[typeof (options.direction) === "string" && options.direction.toLowerCase()] || converter.both;

				var dirStr = "";
				if (options.direction.x === true) dirStr = "horizontal";
				if (options.direction.y === true) dirStr = dirStr ? "both" : "vertical";

				var el = this.eq(0);
				var scroller = el.closest(":scrollable(" + dirStr + ")");

				// check if there's anything to scroll in the first place
				if (scroller.length > 0)
				{
					scroller = scroller.eq(0);

					var dim = {
						e: dimensions(el),
						s: dimensions(scroller)
					};

					var rel = {
						top: dim.e.rect.top - (dim.s.rect.top + dim.s.border.top),
						bottom: dim.s.rect.bottom - dim.s.border.bottom - dim.s.scrollbar.bottom - dim.e.rect.bottom,
						left: dim.e.rect.left - (dim.s.rect.left + dim.s.border.left),
						right: dim.s.rect.right - dim.s.border.right - dim.s.scrollbar.right - dim.e.rect.right
					};

					var animOptions = {};

					// vertical scroll
					if (options.direction.y === true)
					{
						if (rel.top < 0)
						{
							animOptions.scrollTop = dim.s.scroll.top + rel.top;
						}
						else if (rel.top > 0 && rel.bottom < 0)
						{
							animOptions.scrollTop = dim.s.scroll.top + Math.min(rel.top, -rel.bottom);
						}
					}

					// horizontal scroll
					if (options.direction.x === true)
					{
						if (rel.left < 0)
						{
							animOptions.scrollLeft = dim.s.scroll.left + rel.left;
						}
						else if (rel.left > 0 && rel.right < 0)
						{
							animOptions.scrollLeft = dim.s.scroll.left + Math.min(rel.left, -rel.right);
						}
					}

					// scroll if needed
					if (!$.isEmptyObject(animOptions))
					{
						if (rootrx.test(scroller[0].nodeName))
						{
							scroller = $("html,body");
						}
						scroller
							.animate(animOptions, options.duration)
							.eq(0) // we want function to be called just once (ref. "html,body")
							.queue(function (next) {
								$.isFunction(options.complete) && options.complete.call(scroller[0]);
								next();
							});
					}
					else
					{
						// when there's nothing to scroll, just call the "complete" function
						$.isFunction(options.complete) && options.complete.call(scroller[0]);
					}
				}

				// return set back
				return this;
			}
		});

		var scrollValue = {
			auto: true,
			scroll: true,
			visible: false,
			hidden: false
		};

		$.extend($.expr[":"], {
			scrollable: function (element, index, meta, stack) {
				var direction = converter[typeof (meta[3]) === "string" && meta[3].toLowerCase()] || converter.both;
				var styles = (document.defaultView && document.defaultView.getComputedStyle ? document.defaultView.getComputedStyle(element, null) : element.currentStyle);
				var overflow = {
					x: scrollValue[styles.overflowX.toLowerCase()] || false,
					y: scrollValue[styles.overflowY.toLowerCase()] || false,
					isRoot: rootrx.test(element.nodeName)
				};

				// check if completely unscrollable (exclude HTML element because it's special)
				if (!overflow.x && !overflow.y && !overflow.isRoot)
				{
					return false;
				}

				var size = {
					height: {
						scroll: element.scrollHeight,
						client: element.clientHeight
					},
					width: {
						scroll: element.scrollWidth,
						client: element.clientWidth
					},
					// check overflow.x/y because iPad (and possibly other tablets) don't dislay scrollbars
					scrollableX: function () {
						return (overflow.x || overflow.isRoot) && this.width.scroll > this.width.client;
					},
					scrollableY: function () {
						return (overflow.y || overflow.isRoot) && this.height.scroll > this.height.client;
					}
				};
				return direction.y && size.scrollableY() || direction.x && size.scrollableX();
			}
		});
	})(jQuery);


/***/ }
/******/ ])
});
