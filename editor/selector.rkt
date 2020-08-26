#lang at-exp racket

(provide rune-selector)

(require website-js
	 codespells-runes/rune-util
	 (prefix-in html:
		    (only-in website
			     script)))

(define (js-round var num)
  @js{Math.round(@var / @num)*@num})

(define (rune-selector component-with-rune-surface)
  (enclose
    (div id: (id 'id)
	 ;TODO: Delay load this...
	 (html:script
	   src:
	   "https://cdn.jsdelivr.net/npm/interactjs/dist/interact.min.js")
	 @style/inline{
	   .selectedRune{
	     border: 2px solid yellow;
	     border-radius: 5px;
	   }
	 }
      component-with-rune-surface) 

    (script ([construct (call 'constructor)])
	    (function (constructor)
		      @js{
                        $(@(~j "#NAMESPACE_id .runeSurface")).click((e)=>@(call 'click 'e))

                        interact(@(~j "#NAMESPACE_id .runeSurface"))
			.draggable({inertia: true})
			.on('dragmove',
			    function(event){
			    var x = event.dx
			    var y = event.dy

			    $(@(~j "#NAMESPACE_id .runeSurface .selectedRune"))
			    .css({top: "+="+y,
				  left: "+="+x})

			    })
			.on('dragend',
			    function(event){
			    @(call 'snapSelected)

			    var runeContainer = document.querySelector(@(~j "#NAMESPACE_id .runeContainer"));

			    @(call-method
			       'runeContainer
			       'compile);
			    @(call-method
			       'runeContainer
			       'storeState)
			    })
			})

	    (function (click e)
		      @js{
		        var rune = @(call 'getRuneParent 'e.target)
			if(rune){
                          if(!e.shiftKey) @(call 'unselectAll)
                          @(call 'select 'rune)
			} else { 
			  //Maybe unselect here?
                          console.log("You didn't click a Rune")
			}
		      })
	    (function (snapSelected f)
		      @js{
		       var selected = $(@(~j "#NAMESPACE_id .runeSurface .selectedRune"))
		       $.each(selected,
			       (i,s)=>{
			       var top = parseInt(s.style.top.replace("px",""))
			       var left = parseInt(s.style.left.replace("px",""))
			       $(s).css({top: @(js-round 'top 50),
					 left: @(js-round 'left 50)})
			       })})
	    (function (select target)
		      @js{
		      $(target).addClass("selectedRune")
		      })
	    (function (unselectAll target)
		      @js{
                      $(@(~j "#NAMESPACE_id .runeSurface .rune")).removeClass("selectedRune")
		      })
	    (function (getRuneParent target)
		      @js{
		      if(target == null)
		        return null
			
		      if($(target).hasClass("rune"))
		        return target
			
		      return @(call 'getRuneParent 'target.parentNode) 
		      }))))
