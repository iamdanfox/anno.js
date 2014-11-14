
Anno.js
=======
Interactive step-by-step guides for web apps.

Anno.js is built to be absurdly extensible, but still works great out of the
box (and looks damn fine doing it).


The MIT License (MIT)
---------------------

Copyright (c) 2013 Dan Fox

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    $ = require 'jquery'
    require 'scrollintoview/jquery.scrollintoview.js'

    exports.Anno = class Anno

Creating an Anno object
-----------------------

An Anno object represents a single annotation on your page.  Each Anno has a
`target` jQuery selector and a `content` string as well as many other
properties. For example:
```
  pizzaAnno = new Anno({
    target: '#pizza-list',
    content: 'Choose your pizza from the list below.'
  })
  pizzaAnno.show()
```
This constructor lets you override these properties and uses defaults for
anything you don't specify.

You can supply either a single object, or a list of objects.

      constructor: (arg) ->
        if arg.__proto__ is Array.prototype
          options = arg.shift() # remove the first element from arg.
          others = arg
        else
          options = arg

        if options instanceof Anno # first argument is an object
          console.warn 'Anno constructor parameter is already an Anno object.'
        if not options?
          console.warn "new Anno() created with no options. It's recommended"+
           " to supply at least target and content."
        for key,val of options when key in ['chainTo', 'start', 'show',
        'hide', 'hideAnno', 'chainSize', 'chainIndex', 'version']
          console.warn "Anno: Overriding '#{key}' is not recommended. Can "+
            "you override a delegated function instead?"

        for key,val of options
          this[key]=val

        if others?.length > 0
          @chainTo( new Anno(others) )

        return

In practise, I usually like to specify `buttons` and `position`. You may
also want to override `onShow` and `onHide` callbacks, `className` and even
`overlayElem()` for complete control.

If you find yourself setting the same property on every Anno object you
create, you can set default values at the top of your script that will apply
to every Anno object from then onwards.

      @setDefaults: (options) ->
        for key,val of options
          Anno::[key] = val

Making a step-by-step tour
--------------------------

Individual Anno objects can be chained together to make a sequential tour.

      chainTo: (obj) ->
        if obj?
          if not @_chainNext? # end of the chain, add obj to the end.
            @_chainNext = if obj instanceof Anno then obj else new Anno(obj)
            @_chainNext._chainPrev = this
          else # pass the obj further along
            @_chainNext.chainTo(obj)
        else
          console.error "Can't chainTo a null object."
        return this

      _chainNext: null
      _chainPrev: null

Long Anno chains can also be made by passing a list to the constructor:
```
 var annoTour = new Anno([
   {
     target: '.pizza-list',
     content: 'Choose your pizza from the list below.'
   }, {
     target: '#address-form',
     content: "Enter your address and we'll deliver your pizza",
     position: 'left'
   }
 ])
```
Note, the `annoTour` variable still only points to the single Anno object
(for `.pizza-list`), we've just chained another one onto it anonymously.

      @chain: (array) ->
        console.warn 'Anno.chain([...]) is deprecated. Use '+
          '`new Anno([...])` instead.'
        return new Anno(array)

      chainSize: () ->
        if @_chainNext? then @_chainNext.chainSize() else 1+@chainIndex()

`anno.chainIndex(x)` gets the xth object in the chain, `anno.chainIndex()`
gets the current index.

      chainIndex: (index) ->
        if index?
          (find = (curr, i, u) ->
            if curr?
              ci = curr.chainIndex()
              if      0 <= ci < i  then find(curr._chainNext, i, u)
              else if i <  ci <= u then find(curr._chainPrev, i, u)
              else if   ci is i    then curr
            else console.error "Couldn't switch to index '#{i}'. Chain size "+
                   "is '#{u}'"
          )(this, index, @chainSize())
        else
          if @_chainPrev? then 1+@_chainPrev.chainIndex() else 0


Hiding and showing annotations
------------------------------

`anno.show()` displays your annotation on top of a nice overlay and executes
a callback. All methods used here can be overridden in the same way we
changed the `content` property.

Animations are all done with 300ms CSS transitions, so you can change your
UI without touching any javascript.

      show: () ->
        $target = @targetFn()
        if @_annoElem?
          console.warn "Anno elem for '#{@target}' has already been "+
            "generated.  Did you call show() twice?"
        @_annoElem = @annoElem()

        @emphasiseTarget()
        @showOverlay()

        # insert into DOM!
        $target.after(@_annoElem) # TODO warn if already inserted once

        @_annoElem.addClass('anno-target-'+@arrowPositionFn())
        @positionAnnoElem()

        setTimeout (() => @_annoElem.removeClass('anno-hidden')), 50

        $target.scrollintoview()
        setTimeout (() => @_annoElem.scrollintoview()) , 300

        lastButton = @_annoElem.find('button').last()
        if @rightArrowClicksLastButton
          lastButton.keydown( (evt) ->
            if evt.keyCode is 39 then $(this).click()   # right arrow
          )
        if @autoFocusLastButton and $target.find(':focus').length is 0
          lastButton.focus()

        @_returnFromOnShow = @onShow(this, $target, @_annoElem)
        return this

      start: () -> @show() # `tour.start()` sounds nicer than `tour.show()`

      rightArrowClicksLastButton: true
      autoFocusLastButton: true

The `onShow` callback does nothing by default, but can be very useful when
overridden (e.g. to register a click listener on the target element.)
Whatever value you return from the `onShow` function will get passed to the
`onHide` callback.  This can be used to unbind event listeners.

      onShow: (anno, $target, $annoElem) ->

      _returnFromOnShow = null

Hiding is done in two stages so that you can re-use one overlay element for
a long chain of Anno's.

      hide: () ->
        @hideAnno()
        setTimeout @hideOverlay, 50
        return this

      hideAnno: () ->
        if @_annoElem?
          @_annoElem.addClass('anno-hidden')
          @deemphasiseTarget()
          @onHide(this, @targetFn(), @_annoElem, @_returnFromOnShow)

          ((annoEl) ->
            setTimeout (() -> annoEl.remove()), 300
          )(@_annoElem) # captures @_annoElem in the timeout function only

          @_annoElem = null
        else
          console.warn "Can't hideAnno() for '#{@target}' when @_annoElem "+
            "is null.  Did you call hideAnno() twice?"

        return this

      onHide: (anno, $target, $annoElem, returnFromOnShow) ->

`switchTo` displays another Anno and reuses the old overlay.

      switchTo: (otherAnno) ->
        if otherAnno?
          @hideAnno() # TODO: prevent this call if current Anno isn't shown
          otherAnno.show()
        else
          console.warn "Can't switchTo a null object. Hiding instead."
          @hide() # removes overlay to recover from a programmer mistake

      switchToChainNext: () -> @switchTo @_chainNext

      switchToChainPrev: () -> @switchTo @_chainPrev


Customizing target
------------------

Specify a `target` jQuery selector to link your annotation to the DOM.

      target: 'h1'

`targetFn()` is used internally to return the first element matching your
`target` selector (wrapped as a jQuery object).

      targetFn: () ->
        if typeof @target is 'string'
          # .anno-placeholder is a clone to prevent text wrapping
          r = $(@target).filter(':not(.anno-placeholder)')
          if r.length is 0
            console.error "Couldn't find Anno.target '#{@target}'."
          if r.length > 1
            console.warn "Anno target '#{@target}' matched #{r.length} "+
              "elements. Targeting the first one."
          r.first()
        else if @target instanceof jQuery
          if @target.length > 1
            console.warn "Anno jQuery target matched #{@target.length} "+
              "elements. Targeting the first one."
          return @target.first()
        else if @target instanceof HTMLElement
          $(@target)
        else if typeof @target is 'function'
          @target()
        else
          console.error "Unrecognised Anno.target. Please supply a jQuery "+
            "selector string, a jQuery object, a raw DOM element or a "+
            "function returning a jQuery element. target:"
          console.error @target

`annoElem()` generates the jQuery object that will be inserted into the DOM.

      annoElem: () -> #TODO:should this encapsulate the re-use of one object?
        @_annoElem = $("""<div class='anno anno-hidden #{@className}'>
          <div class='anno-inner'>  <div class='anno-arrow'></div>  </div>
          </div>""")
        @_annoElem.find('.anno-inner').
          append( @contentElem() ).
          append( @buttonsElem() ) # <- jquery elements, not HTML strings.
        return @_annoElem

      _annoElem: null

CSS classes can be included, e.g. .anno-width-150, 175, 200, 250 (default 300)

      className: ''

Content
-------

      content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'

Override this instead of `content` if you don't know the content in advance

      contentFn: () -> @content

      contentElem: () -> $("<div class='anno-content'>"+@contentFn()+"</div>")




Semi-transparent overlay and other effects
------------------------------------------

      showOverlay: () ->
        if $('.anno-overlay').length is 0 # TODO mention pointer-events:none
          $('body').append($e = @overlayElem().addClass 'anno-hidden')
          setTimeout (() -> $e.removeClass 'anno-hidden'), 10
        else
          $('.anno-overlay').replaceWith @overlayElem()

      overlayElem: () ->
        $("<div class='anno-overlay #{@overlayClassName}'></div>").
          click( (evt) => @overlayClick.call(this, this, evt) )

`.anno-hidden` is automatically added to the HTML, then removed to give
the fade in effect.

      overlayClassName: ''
      overlayClick: (anno, evt) -> anno.hide()

      hideOverlay: () ->
        $('.anno-overlay').addClass 'anno-hidden'
        setTimeout (() -> $('.anno-overlay').remove()), 300

      emphasiseTarget: ($target = @targetFn()) ->
        @_undoEmphasise = [] # crucial.
        $target.closest(':scrollable').on 'mousewheel', (evt) ->
          evt.preventDefault()
          evt.stopPropagation()
        @_undoEmphasise.push ($t) ->
          $t.closest(':scrollable').off('mousewheel')

        if $target.css('position') is 'static'
          # ensures that the jquery :first selector in targetFn works.
          $target.after(placeholder = $target.clone()
            .addClass('anno-placeholder'))
          do (placeholder) => @_undoEmphasise.push () -> placeholder.remove()
          startposition = $target.prop('style').position
          do (startposition) =>
            @_undoEmphasise.push ($t) -> $t.css position:startposition
          $target.css( position:'absolute' )

          # If switching to `position:absolute` has caused a dimension
          # collapse, manually set H/W.
          if $target.outerWidth() isnt placeholder.outerWidth()
            # Find $target's inline style, make an undo function
            origwidth = $target.prop('style').width
            do (origwidth) =>
              @_undoEmphasise.push ($t) -> $t.css width:origwidth
            $target.css('width', placeholder.outerWidth())
          if $target.outerHeight() isnt placeholder.outerHeight()
            origheight = $target.prop('style').height
            do (origheight) =>
              @_undoEmphasise.push ($t) -> $t.css height:origheight
            $target.css('height', placeholder.outerHeight())

          # If switching to `position:absolute` has caused a position change,
          # manually set it too
          ppos = placeholder.position()
          tpos = $target.position()
          if tpos.top isnt ppos.top
            origtop = $target.prop('style').top
            do (origtop) => @_undoEmphasise.push ($t) -> $t.css top:origtop
            $target.css('top', ppos.top)
          if tpos.left isnt ppos.left
            origleft = $target.prop('style').left
            do (origleft) => @_undoEmphasise.push ($t) -> $t.css left:origleft
            $target.css('left', ppos.left)

        if $target.css('backgroundColor') is 'rgba(0, 0, 0, 0)' or
        $target.css('backgroundColor') is 'transparent'
          console.warn "Anno.js target '#{@target}' has a transparent bg; "+
            "filling it white temporarily."
          origbg = $target.prop('style').background
          do (origbg) => @_undoEmphasise.push ($t) -> $t.css background:origbg
          $target.css( background: 'white')

        origzindex = $target.prop('style').zIndex
        do (origzindex) => @_undoEmphasise.push ($t) -> $t.css zIndex:origzindex
        $target.css( zIndex:'1001' )

        return $target

      _undoEmphasise: [] # list of functions to undo emphasiseTarget()

      deemphasiseTarget: () ->
        $target = @targetFn()
        fn($target) for fn in @_undoEmphasise
        return $target


Positioning
-----------

The `position` property decides where your annotation will be displayed.
It may be any of `top`, `left`, `bottom`, `right`, `center-top`,
`center-left`, `center-bottom` or `center-right`.

Alternatively, you can supply a hash of CSS attributes:
```
  position = {
    top: '10px',
    left: '57px'
  }
```
If you omit the `position` attribute entirely, Anno will use its best guess.

      position: null

`positionAnnoElem()` sets the CSS of the Anno element so that it appears
next to your target in a sensible way. Must be called after DOM insertion.

      positionAnnoElem: (annoEl = @_annoElem) ->
        pos = @positionFn()

        $targetEl = @targetFn()

        offset = $targetEl.position()
        switch pos
          when 'top', 'bottom'
            annoEl.css(left: offset.left+'px')
          when 'center-top', 'center-bottom'
            annoEl.css(left: offset.left+($targetEl.outerWidth()/2 -
              annoEl.outerWidth()/2)+'px')
          when 'left', 'right'
            annoEl.css(top: offset.top+'px')
          when 'center-left', 'center-right'
            annoEl.css(top: offset.top+($targetEl.outerHeight()/2 -
              annoEl.outerHeight()/2)+'px')

        switch pos
          when 'top', 'center-top'
            annoEl.css( top: offset.top-annoEl.outerHeight()+'px')
          when 'bottom', 'center-bottom'
            annoEl.css( top: offset.top+$targetEl.outerHeight()+'px')
          when 'left', 'center-left'
            annoEl.css(left: offset.left-annoEl.outerWidth()+'px')
          when 'right', 'center-right'
            annoEl.css(left: offset.left+$targetEl.outerWidth()+'px')
          else
            if pos.left? or pos.right? or pos.top? or pos.bottom?
              annoEl.css(pos)
            else
              console.error "Unrecognised position: '#{pos}'"

        return annoEl


`positionFn()` returns the `position` property or tries to guess one if you
left it blank.

      positionFn: () -> # Must be called after DOM insertion.
        if @position?
          return @position
        else if @_annoElem?
          $target = @targetFn()

          $container = $target.closest(':scrollable')
          $container = $('body') if $container.length is 0

          targetOffset = $target.offset()         # both relative to document
          containerOffset = $container.offset()
          targetBounds =
            left: targetOffset.left - containerOffset.left
            top:  targetOffset.top - containerOffset.top
          # targetBounds = dist from edge of $container to side of elem
          targetBounds.right = targetBounds.left + $target.outerWidth()
          targetBounds.bottom = targetBounds.top + $target.outerHeight()

          viewBounds = # TODO: why is the `or` keyword there??
            w: $container.width() or $container.width()
            h: $container.height() or $container.height()

          annoBounds =
            w: @_annoElem.outerWidth()
            h: @_annoElem.outerHeight()

          bad = []

          if annoBounds.w > targetBounds.left
            bad = bad.concat ['left', 'center-left']
          if annoBounds.h > targetBounds.top
            bad = bad.concat ['top', 'center-top']
          if annoBounds.w + targetBounds.right  > viewBounds.w
            bad = bad.concat ['right', 'center-right']
          if annoBounds.h + targetBounds.bottom > viewBounds.h
            bad = bad.concat ['bottom', 'center-bottom']

          allowed = Anno.preferredPositions.filter (p) -> p not in bad
          if allowed.length is 0
            console.error "Anno couldn't guess a position for '#{@target}'. "+
              "Please supply one in the constructor."
          else
            console.warn "Anno: guessing position:'#{allowed[0]}' for "+
              "'#{@target}'. Possible Anno.preferredPositions: [#{allowed}]."
          return @position = allowed[0] # store this value for later

When there are different positions that the Anno element could by displayed,
`positionFn()` chooses the first one available in `Anno.preferredPositions`.

      @preferredPositions = ['bottom', 'right', 'left', 'top',
              'center-bottom', 'center-right', 'center-left', 'center-top']


`arrowPositionFn()` returns which way the arrow should point.
This is normally just the opposite of the anno position.
May only be called after DOM insertion.

      arrowPositionFn: () ->
        if @arrowPosition?
          return @arrowPosition
        else if typeof @positionFn() is 'string'
          return {
            'top': 'bottom'
            'center-top': 'center-bottom'
            'left': 'right'
            'center-left' : 'center-right'
            'right' : 'left'
            'center-right' : 'center-left'
            'bottom': 'top'
            'center-bottom' : 'center-top'
          }[@positionFn()]
        else
          pos =
            l : parseInt(@positionFn().left, 10)
            t : parseInt(@positionFn().top, 10)
          if Math.abs(pos.l) > Math.abs(pos.t)
            r = if pos.l < 0 then 'center-right' else 'center-left'
          else
            r = if pos.t < 0 then 'center-bottom' else 'center-top'
          console.warn "Guessing arrowPosition:'#{r}' for #{@target}. " +
            "Include this in your constructor for consistency."
          return r

Override this if you've supplied a CSS hash as the `position` property. Can be
any of `top`, `left`, etc.

      arrowPosition: null # TODO replace 'arrowPosition' with 'arrowDirection'


Customizing Buttons
-------------------

By default, Annotations have a single button, filled with default values from
the `AnnoButton` class.

      buttons:  [ {} ]

      # returns a list of `AnnoButton` objects
      buttonsFn: () ->
        if @buttons instanceof Array
          @buttons.map (b) -> new AnnoButton(b)
        else
          [new AnnoButton(@buttons)] # `@buttons` is a single hash here

`buttonsElem()` produces the HTML for all those buttons (as a jQuery object).

      buttonsElem: () ->
        return $("<div class='anno-btn-container'></div>").
          append (b.buttonElem(this) for b in @buttonsFn())


AnnoButton
==========

    exports.AnnoButton = class AnnoButton

      constructor: (options) ->
        for key,val of options
          this[key]=val

      buttonElem: (anno) ->
        return $("<button class='anno-btn'></button>").
          html( @textFn(anno) ).
          addClass( @className ).
          click( (evt) => @click.call(anno, anno, evt) )

      textFn: (anno) ->
        if @text? then @text
        else if anno._chainNext? then 'Next' else 'Done'

      text: null

      className: ''

`click` is called when your button is clicked.  Note, the `this` keyword is
bound to the parent Anno object.

      click: (anno, evt) ->
        if anno._chainNext?
          anno.switchToChainNext()
        else
          anno.hide()

These are some handy presets that you can use by adding `AnnoButton.NextButton`
to your Anno object's `buttons` list.

      @NextButton: new AnnoButton(
        text: 'Next'
        click: () -> @switchToChainNext()
      )

      @DoneButton: new AnnoButton({ text: 'Done' , click: () -> @hide()  })

      @BackButton: new AnnoButton(
        text: 'Back'
        className: 'anno-btn-low-importance'
        click: () -> @switchToChainPrev()
      )
