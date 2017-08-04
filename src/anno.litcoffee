
Anno.js
=======
Powerful step-by-step guides, interactive tutorials or just plain ol' annotations.

Anno.js is built to be absurdly extensible, but still works great out of the box (and looks damn fine doing it). 


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



    class Anno
      @version: '1.4.7' 
      
@version: BreakingAPIChange.NewCompatibleFeatures.Bugfix 


Constructing an Anno object
---------------------------

An Anno object represents a single annotation on your page.  Each Anno has a `target` jQuery selector
and a `content` string. For example:
```
  pizzaAnno = new Anno({
    target: '.pizza-list',
    content: 'Choose your pizza from the list below.'
  })
  pizzaAnno.show()
```
This creates a plain Anno object and overrides the `target` and `content` properties.  It uses defaults
for everything else.

      constructor: (options) ->
        if options instanceof Anno
          console.warn 'Anno constructor parameter is already an Anno object.'
        if not options?
          console.warn "new Anno() created with no options.  It's recommended to supply at least target and content." 
        for key,val of options when key in ['chainTo', 'start', 'show', 'hide', 'hideAnno', 'chainSize', 'chainIndex', 'version']
          console.warn "Anno: Overriding '#{key}' is not recommended.  Can you override a delegated function instead?"
        
        for key,val of options
          this[key]=val

Note, you can customize *anything* in your Anno object by overriding the method or property when you construct it.
In addition to `target` and `content`, I usually like to specify `buttons` and `position`.  You might
also like to try specifying `onShow` or `onHide` callbacks, `className` or maybe `overlayElem()`.  

Read on to find out more.

Making step-by-step tours using chaining
----------------------------------------

Naturally, you can chain Anno objects together to make a sequential tour. For example: 
```
  deliveryAnno = new Anno({
    target: '#address-form',
    content: "Enter your address and we'll deliver your pizza"
    position: 'left'
  })
  pizzaAnno.chainTo(deliveryAnno)
```
The `pizzaAnno` object now has a `_chainNext` property and will switch to the 
`deliveryAnno` when you click Next.

      chainTo: (obj) ->
        if obj?
          if not @_chainNext? # this is the end of the chain, add obj to the end.  
            @_chainNext = if obj instanceof Anno then obj else new Anno(obj)
            @_chainNext._chainPrev = this
          else # pass the obj further along
            @_chainNext.chainTo(obj)
        else
          console.error "Can't chainTo a null object."
        return this

Anything that starts with an underscore is probably a bad idea to change. By all means read 
these, but don't come crying to me if you overwrote something and your entire website blew up.

      _chainNext: null 
      _chainPrev: null

You can also make long Anno chains without having to write `chainTo` every time using
`Anno.chain()`. We can rewrite the two step example above like this:
```
 annoTour = Anno.chain([
   {
     target: '.pizza-list',
     content: 'Choose your pizza from the list below.'
   }, 
   {
     target: '#address-form',
     content: "Enter your address and we'll deliver your pizza"
     position: 'left'
   }
 ])
```
Note, the `annoTour` variable still only points to the single Anno object (for `.pizza-list`), 
we've just chained another one onto it anonymously.

      @chain: (array) ->
        head = new Anno( array.shift() )
        if array.length >= 1 # array is now the tail.
          head.chainTo( Anno.chain(array) ) 
        return head
      
      chainSize: () -> 
        if @_chainNext? then @_chainNext.chainSize() else 1+@chainIndex()

      chainIndex: (index) ->
        # `anno.chainIndex(x)` gets the xth object in the chain
        if index?
          (find = (curr, i, u) ->
            if curr?
              ci = curr.chainIndex()
              if      0 <= ci < i  then find(curr._chainNext, i, u)
              else if i <  ci <= u then find(curr._chainPrev, i, u)
              else if   ci is i    then curr
            else console.error "Couldn't switch to index '#{i}'. Chain size is '#{u}'"
          )(this, index, @chainSize())
        # `anno.chainIndex()` gets the current index; 
        else
          if @_chainPrev? then 1+@_chainPrev.chainIndex() else 0


If you find yourself setting the same property on every Anno object you create, you can
set default values at the top of your script that will apply to every Anno object from then onwards. 

      @setDefaults: (options) ->
        for key,val of options
          Anno::[key] = val
      

Hiding and showing annotations
------------------------------

`anno.show()` displays your annotation on top of a nice overlay and executes a callback.
All methods used here can be overridden in the same way we changed the `content` property.

Animations are all done with 300ms CSS transitions, so you can change your UI without touching any javascript.

      start: () -> @show()

      show: () -> # TODO warn if this Anno has already been shown.
        $target = @targetFn()
        if @_annoElem? then console.warn "Anno elem for '#{@target}' has already been generated.  Did you call show() twice?"
        @_annoElem = @annoElem()
        lastButton = @_annoElem.find('button').last()

        @showOverlay()
        @emphasiseTarget()
        
        $target.after(@_annoElem) # insert into DOM
        
        @_annoElem.addClass('anno-target-'+@arrowPositionFn())
        @positionAnnoElem()

        setTimeout (() => @_annoElem.removeClass('anno-hidden')), 10 # hack to make Chrome render the opacity:0 state.
          
        $target.scrollintoview()
        setTimeout (() => @_annoElem.scrollintoview()) , 300 #TODO fix jumpiness

        if @rightArrowClicksLastButton 
          lastButton.keydown( (evt) -> if evt.keyCode is 39 then $(this).click()  ) # right arrow    
        if @autoFocusLastButton
          lastButton.focus() if $target.find(':focus').length is 0 # don't steal focus from inside target element

        @_returnFromOnShow = @onShow(this, $target, @_annoElem)
        return this

      rightArrowClicksLastButton: true
      autoFocusLastButton: true

The `onShow` callback is incredibly useful; by default, it does nothing, but you can override it to set 
up click listeners, adjust your page html and generally provide lots of interactivity.  

The most common use of this method is to register a click listener on the target element.  Whatever 
value you return from the `onShow` function will get passed to the `onHide` callback.  You can use this 
to unbind event listeners.

      onShow: (anno, $target, $annoElem) -> # Both `$target` and `$annoElem` are already jQuery objects

Note: whatever you return from your `onShow` function will be passed into the `onHide` function as the fourth argument.

      _returnFromOnShow = null

Hiding is done in two stages so that you can re-use one overlay element for a long chain of Anno's.

      hide: () ->
        @hideAnno()
        @hideOverlay()
        return this

`hideAnno()` hides the Anno element and restores the `target` element, leaving the overlay behind.
It also calls the `onHide` listener and passes in the result of the `onShow` method.

      hideAnno: () ->
        @deemphasiseTarget()

        if @_annoElem? 
          @_annoElem.addClass('anno-hidden')
          setTimeout () => 
            @_annoElem.remove() # this method causes hideAnno to get called twice sometimes -> bad.
            @_annoElem = null
          , 300

          @onHide(this, @targetFn(), @_annoElem, @_returnFromOnShow)
        else
          console.warn "Can't hideAnno() for '#{@target}' when @_annoElem is null.  Did you call hideAnno() twice?"

        return this

      onHide: (anno, $target, $annoElem, returnFromOnShow) ->

`switchTo` hides the current Anno and displays the next one in the chain without animating out the old overlay.
Note: `otherAnno.show()` will probably replace the overlay, but it won't do a weird fade flicker.

      switchTo: (otherAnno) -> 
        if otherAnno?
          @hideAnno() # TODO: prevent this calling `hideAnno()` if the current Anno isn't currently shown. 
          otherAnno.show()
        else 
          console.warn "Can't switchTo a null object. Hiding completely instead. "
          @hide() # end of the line, need to remove the overlay too

      switchToChainNext: () -> @switchTo @_chainNext

      switchToChainPrev: () -> @switchTo @_chainPrev


Customizing Anno and contents
-----------------------------

Specify a `target` jQuery selector to link your annotation to the DOM.

      target: 'h1'

`targetFn()` returns the first DOM element it can find matching your `target` selector (wrapped as a jQuery object). 

      targetFn: () ->
        if typeof @target is 'string'
          r = $(@target).filter(':not(.anno-placeholder)')
          if r.length is 0 then console.error "Couldn't find Anno.target '#{@target}'."
          if r.length > 1 then console.warn "Anno target '#{@target}' matched #{r.length} elements. Targeting the first one."
          r.first()
        else if @target instanceof jQuery
          if @target.length > 1 then console.warn "Anno jQuery target matched #{@target.length} elements. Targeting the first one."
          return @target.first()
        else if @target instanceof HTMLElement
          $(@target)
        else if typeof @target is 'function'
          @target()
        else 
          console.error "Unrecognised Anno.target. Please supply a jQuery selector string, a jQuery "+
              "object, a raw DOM element or a function returning a jQuery element. target:"
          console.error @target



`annoElem()` generates the jQuery object that will be inserted into the DOM.  It relies on 
`@contentElem()` and `buttonsElem()` to generate the interesting bits. 

This method is ripe for overriding. Just copy the code below and tinker with the HTML. For example
you could add some extra `div`s to display the current step number (by calling `chainIndex() + 1`).

      annoElem: () -> 
        @_annoElem = $("""<div class='anno anno-hidden #{@className}'>
                    <div class='anno-inner'>  <div class='anno-arrow'></div>  </div>
                  </div>""")
        @_annoElem.find('.anno-inner').
          append( @contentElem() ).
          append( @buttonsElem() ) # these a jquery elements, not HTML strings.
        return @_annoElem # NB: returning the original pointer each time breaks button click events...

      _annoElem: null

      className: '' # TODO useful classes .anno-width-150, 175, 200, 250 (default 300)

`contentElem()` is called by `annoElem()` to produce a jQuery object.  

      contentElem: () -> $("<div class='anno-content'>"+@contentFn()+"</div>") # TODO: evaluate how easy it would be to change Anno content while its displayed.

Most of the time it will suffice to override the `content` property when you construct your Anno.  
However, if you want to generate the content when `showAnno()` is called (perhaps the text you display
depends on an earlier step) you can override `contentFn()` instead.

      contentFn: () -> @content
      content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'


`buttonsElem()` produces the HTML for all those buttons (as a jQuery object).  Just like `contentElem()`
above, it delegates to `buttonFn()`.

      buttonsElem: () ->
        return $("<div class='anno-btn-container'></div>").
          append (b.buttonElem(this) for b in @buttonsFn())

`buttonsFn()` returns a list of `AnnoButton` objects based on whatever you put in the `buttons` parameter.

      buttonsFn: () -> 
        if @buttons instanceof Array
          @buttons.map (b) -> new AnnoButton(b)
        else 
          [new AnnoButton(@buttons)] # in the else branch `@buttons` is a single hash

By default, Anno will construct a single button for you, using defaults provided by the `AnnoButton` class.
You can supply a single object, a list of objects or even a list of `AnnoButtons`.

      buttons:  [ {} ] 



Semi-transparent overlay and other effects
------------------------------------------

      showOverlay: () ->
        if $('.anno-overlay').length is 0
          $('body').append(e = @overlayElem().addClass 'anno-hidden') # TODO: write about pointer-events: none
          setTimeout (() -> e.removeClass 'anno-hidden'), 10
        else
          $('.anno-overlay').replaceWith @overlayElem() # TODO try to mutate classNames & listeners rather than replacing the DOM node -> smooth animation

      overlayElem: () -> 
        $("<div class='anno-overlay #{@overlayClassName}'></div>").
          click( (evt) => @overlayClick.call(this, this, evt) )

      overlayClassName: '' # TODO talk about .anno-hidden
      overlayClick: (anno, evt) -> anno.hide()

      hideOverlay: () ->
        $('.anno-overlay').addClass 'anno-hidden'
        setTimeout (() -> $('.anno-overlay').remove()), 300





      emphasiseTarget: ($target = @targetFn()) ->
        if $target.attr('style')? then _oldTargetCSS = $target.attr('style')

        $target.closest(':scrollable').on 'mousewheel', (evt) ->  # TODO: register & remove a specific listener ... would this ruin existing jQuery scroll functions?
          evt.preventDefault()
          evt.stopPropagation()

        if $target.css('position')  is 'static'
          $target.after(@_placeholder = $target.clone().addClass('anno-placeholder')) # ensures that the jquery :first selector in targetFn works.
          $target.css( position:'absolute' )

          # if switching to position absolute has caused a dimension collapse, manually set H/W.
          if $target.outerWidth() isnt @_placeholder.outerWidth() 
            $target.css('width', @_placeholder.outerWidth())
          if $target.outerHeight() isnt @_placeholder.outerHeight() 
            $target.css('height', @_placeholder.outerHeight())

          # if switching to position absolute has caused a position change, manually set it too
          ppos = @_placeholder.position()
          tpos = $target.position()
          $target.css('top', ppos.top)   if tpos.top  isnt ppos.top 
          $target.css('left', ppos.left) if tpos.left isnt ppos.left

        if $target.css('background') is 'rgba(0, 0, 0, 0) none repeat scroll 0% 0% / auto padding-box border-box'
          $target.css( background: 'white')

        $target.css( zIndex:'1001' ) 

        return $target

      _oldTargetCSS: ''
      _placeholder: null

      deemphasiseTarget: () ->
        @_placeholder?.remove()
        $target = @targetFn()
        $target.closest(':scrollable').off('mousewheel')
        return $target.attr('style',@_oldTargetCSS)


Positioning
-----------

`positionAnnoElem()` sets the CSS of the Anno element so that it appears next to your target in a sensible way.
It positions the Anno element based on a string from `positionFn()`. It can also use a hash containing any
of the properties `top`, `left`, `right` or `bottom`.

Must be called after DOM insertion.

      positionAnnoElem: (annoEl = @_annoElem) ->
        pos = @positionFn()

        $targetEl = @targetFn()

        offset = $targetEl.position() 
        switch pos 
          when 'top', 'bottom'
            annoEl.css(left: offset.left+'px')
          when 'center-top', 'center-bottom'
            annoEl.css(left: offset.left+($targetEl.outerWidth()/2 - annoEl.outerWidth()/2)+'px')
          when 'left', 'right'
            annoEl.css(top: offset.top+'px')
          when 'center-left', 'center-right'
            annoEl.css(top: offset.top+($targetEl.outerHeight()/2 - annoEl.outerHeight()/2)+'px')

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

`positionFn()` simply returns whatever you put in the `position` property (see below for options).  
If you left it blank, `positionFn()` will try to guess which side of your target you would like your
annotation to be displayed on (based on `Anno.preferredPositions`). 

Must be called after DOM insertion.

      positionFn: () -> 
        if @position? 
          @position
        else if @_annoElem?
          # time to guess!!
          $target = @targetFn()

          $container = $target.closest(':scrollable')
          $container = $('body') if $container.length is 0

          targetOffset = $target.offset()         # both relative to document
          containerOffset = $container.offset() 
          targetBounds = 
            left: targetOffset.left - containerOffset.left
            top:  targetOffset.top - containerOffset.top
          targetBounds.right = targetBounds.left + $target.outerWidth() # dist from left edge of $container to right of elem
          targetBounds.bottom = targetBounds.top + $target.outerHeight()

          viewBounds = 
            w: $container.width() or $container.width()
            h: $container.height() or $container.height()

          annoBounds = 
            w: @_annoElem.outerWidth()
            h: @_annoElem.outerHeight()

          bad = []

          if annoBounds.w > targetBounds.left then bad = bad.concat ['left', 'center-left']
          if annoBounds.h > targetBounds.top  then bad = bad.concat ['top', 'center-top']
          if annoBounds.w + targetBounds.right  > viewBounds.w  then bad = bad.concat ['right', 'center-right']
          if annoBounds.h + targetBounds.bottom > viewBounds.h then bad = bad.concat ['bottom', 'center-bottom']

          allowed = Anno.preferredPositions.filter (p) -> p not in bad 
          if allowed.length is 0
            console.error "Anno couldn't guess a position for '#{@target}'. Please supply one in the constructor."
          else
            console.warn "Anno: guessing position:'#{allowed[0]}' for '#{@target}'. "+
              "Possible Anno.preferredPositions: [#{allowed}]."
          @position = allowed[0] # store this value for later - saves recomputing.

When there are several different positions that the Anno element could by displayed, `positionFn()` chooses
the first one available in `Anno.preferredPositions`.  Feel free to override this if you like your annotations 
to appear on top by default.

      @preferredPositions = ['bottom', 'right', 'left', 'top',  
              'center-bottom', 'center-right', 'center-left', 'center-top'] # TODO order these based on research.

The `position` property decides where your annotation will be displayed. You should supply
any of `top`, `left`, `bottom`, `right`, `center-top`, `center-left`, `center-bottom` or `center-right`.

Alternatively, you can supply a hash of CSS attributes to set. (e.g. `{ top: '10px', left: '57px' }`). This
is useful if you have a large `target` element and you want to point the arrow at something specific.

You may omit the `position` attribute entirely and Anno will use its best guess, however, this is not recommended
(and you'll get a warning on the console as punishment).

      position: null



If you manually positioned your annoElem (by supplying CSS `left` and `top` attributes), `arrowPositionFn()` 
will attempt to guess which way you want to the arrow to point.  If you'd rather not leave it to chance,
simply override the `arrowPosition` when you construct your Anno object.

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
          pos = l : parseInt(@positionFn().left, 10) ,  t : parseInt(@positionFn().top, 10) 
          if Math.abs(pos.l) > Math.abs(pos.t)
            r = if pos.l < 0 then 'center-right' else 'center-left'
          else
            r = if pos.t < 0 then 'center-bottom' else 'center-top'
          console.warn "Guessing arrowPosition='#{r}' for #{@target}. Include this in your constructor for consistency."
          return r

`arrowPosition` definitively decides which direction you want the arrow to point.  The only reason you should 
ever need to override this is if you've supplied a CSS hash as the `position` property.

      arrowPosition: null # TODO replace 'arrowPosition' with 'arrowDirection'






Buttons
=======

    class AnnoButton
      @version: '1.1.0'

      constructor: (options) ->
        for key,val of options
          this[key]=val


      buttonElem: (anno) ->
        return $("<button class='anno-btn'></button>").
          html( @textFn(anno) ).
          addClass( @className ).
          click( (evt) => { 
            evt.preventDefault();
            @click.call(anno, anno, evt)
          })

      textFn: (anno) -> 
        if @text? then @text
        else if anno._chainNext? then 'Next' else 'Done'

      text: null

      className: ''

`click` is called when your button is clicked.  Note, the `this` keyword is bound to the parent
Anno object.  If you really want to access `AnnoButton` properties, you could always use CoffeeScript's 
fat arrow.

      click: (anno, evt) -> 
        if anno._chainNext?
          anno.switchToChainNext()
        else
          anno.hide()

These are some handy presets that you can use by adding `AnnoButton.NextButton` to your Anno object's 
`buttons` list.

      @NextButton: new AnnoButton({ text: 'Next' , click: () -> @switchToChainNext()  })

      @DoneButton: new AnnoButton({ text: 'Done' , click: () -> @hide()  })

      @BackButton: new AnnoButton(
          text: 'Back'
          className: 'anno-btn-low-importance'
          click: () -> @switchToChainPrev()
        )
