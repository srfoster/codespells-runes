#lang at-exp racket

(provide rune-injector
	 rune-adder)

(require website-js
	 codespells-runes/rune-util)

(define (rune-adder parent-id lang rune-id)
  (define r (id->html lang rune-id))
  
  (enclose
    (span 
      on-click: (call 'add)
      style: (properties
	       'display: 'inline-block)
      (span 
	style: (properties
		 'pointer-events: 'none)
	r))
    (script ()
	    (function (add)
		      @js{
		        var parent = document.querySelector(@(~j "#~a .runeContainer" parent-id))
		        var runeBox = document.querySelector(@(~j "#~a .runeBox" parent-id))

			var pos = $(runeBox).position()
			$(runeBox).fadeOut()

			if(!pos) pos = {top: 0, left: 0}


			console.log("Calling addRune", parent);
			@(call-method 'parent 'addRune 
				      (~s rune-id)
				      (html->js-injector r)
				      'pos.left 'pos.top) }))))

(define (js-round var num)
  @js{Math.round(@var / @num)*@num})

(define (rune-injector lang component-with-rune-surface)
  (enclose 
    (define parent-id (id 'id))
    (div id: (id 'id)
	 (enclose
	   (define runeBox (id 'runeBox))
	   (div
	     id: (id 'toolboxManager)
	     style: (properties 
		      position: "relative")
	     (div id: (id 'runeBox)
		  class: 'runeBox
		  style: (properties display: "none"
				     position: "absolute"
				     'pointer-events: 'none
				     z-index: "100")
		  (div 
		    class: "injectionLocation"
		    style: (properties background-color: "rgba(255,255,255,0.5)"
				       'pointer-events: 'all
				       width: 100
				       height: 100))
		  (div
		    style: (properties 
			     background-color: "white"
			     height: 400
			     width: 400
			     'overflow-y: 'scroll
			     'overflow-x: 'hidden
			     padding: 5
			     border: "1px solid black"
			     'pointer-events: 'all
			     )
		    (map (curry rune-adder parent-id lang)
			 (rune-lang-ids lang))))
	     component-with-rune-surface)
	   (script ([construct (call 'constructor)])
		   (function (constructor)
			     @js{
			     $(@(~j "#~a" (id 'toolboxManager))).click((e)=>{if(e.shiftKey){@(call 'showToolbox 'e)}})
			     $(@(~j "#~a" (id 'toolboxManager))).dblclick((e)=>@(call 'showToolbox 'e))
                             
			     $(@(~j "#~a" runeBox)).contextmenu(()=>@(call 'hideToolbox))
			     })
		   (function (showToolbox event)
			     @js{

			     var surfaceP = $(@(~j "#~a .runeSurface" (id 'toolboxManager))).offset()

			     var x = @event .pageX - surfaceP.left
			     var y = @event .pageY - surfaceP.top

			     $(@(~j "#~a" runeBox)).css({left: @(js-round 'x 50)-50, top: @(js-round 'y 50)-50})
			     $(@(~j "#~a" runeBox)).fadeIn(100) })
		   (function (hideToolbox)
			     @js{
			     $(@(~j "#~a" runeBox)).fadeOut(100)
			     return false
			     }))))
    (script ())))
