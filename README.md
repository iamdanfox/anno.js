anno.js
=======

Anno.js lets you add powerful step-by-step guides, interactive tutorials or just plain ol' annotations to your webapp.

Anno.js is built to be absurdly extensible, but still works great out of the box (and looks damn fine doing it). 


Usage
-----

### Constructing an Anno object

An Anno object represents a single annotation on your page.  Each Anno has a `target` jQuery selector
and a `content` string. For example:

    pizzaAnno = new Anno({
      target: '.pizza-list',
      content: 'Choose your pizza from the list below.'
    })
    pizzaAnno.show()

This creates a plain Anno object and overrides the `target` and `content` properties.  It uses defaults
for everything else.


### Making step-by-step tours using chaining

Naturally, you can chain Anno objects together to make a sequential tour. For example: 

    deliveryAnno = new Anno({
      target: '#address-form',
      content: "Enter your address and we'll deliver your pizza"
      position: 'left'
    })
    pizzaAnno.chainTo(deliveryAnno)

The `pizzaAnno` object now has a `_chainNext` property and will switch to the 
`deliveryAnno` when you click Next.

#### Anno.chain Shorthand

You can also make long Anno chains without having to write `chainTo` every time using
`Anno.chain()`. We can rewrite the two step example above like this:

    annoTour = Anno.chain([
      {
        target: '.pizza-list',
        content: 'Choose your pizza from the list below.'
      }, 
      {
        target: '#address-form',
        content: "Enter your address and we'll deliver your pizza",
        position: 'left'
      }
    ])

Note, the `annoTour` variable still only points to the single Anno object (for `.pizza-list`), 
we've just chained another one onto it anonymously.