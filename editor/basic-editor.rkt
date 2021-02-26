#lang at-exp racket

;TODO: Make rune-surface-component much simpler.  Things like store/restore should be in wrapping components, like with injection and selection.

(provide 
  store-state
  restore-state
  rune-surface-component
  rune-surface-height
  demo-editor)

(require codespells-runes/rune-util
	 webapp/js
	 website-js
	 (prefix-in html:
		    (only-in website
			     script)))

(define rune-surface-height
  (make-parameter 500))

(define (rune-surface-component 
	  #:store-state [store-state store-state]
	  #:restore-state [restore-state restore-state]
	  lang [program #f])
  (enclose
    (div
     class: 'runeContainer
     'oncontextmenu: "return false;" 
     (html:script
       src:
       "https://cdn.jsdelivr.net/npm/interactjs/dist/interact.min.js")
     
   (div
     id: (id 'runeContainer)
     class: 'runeSurface
     style: (properties width: "100%" height: (rune-surface-height)
			background-color: "rgba(0,0,0,0.5)"
			position: "relative")

     (when program
       (typeset-runes-syntax lang program))
     ))
   (script
    ([construct (call 'construct)])

    (function (currentLanguage)
	      @js{
	      return "@(if (path? (rune-lang-name lang))
                           (string-replace (~a (rune-lang-name lang)) "\\" "\\\\") ;preserves racket paths with backslashes
                           (rune-lang-name lang))".trim()  
	      })

    (function (addRune runeId injectRune x y)
	      @js{
	      var injected = injectRune(document.getElementById(@(~j "NAMESPACE_runeContainer")))

	      $(injected).addClass("rune")

              //Editor runes will always set their own values
              if(!runeId.includes("editor:"))
	        $(injected).attr("data-id", runeId)
              
	      $(injected).css(
			      {display: "inline-block",
			      position: "absolute",
			      transform: "translate("+ x + "px," + y +"px)"} ) 
	      
              $(injected).attr("data-x", x)
              $(injected).attr("data-y", y)

	      $(injected).contextmenu(
				      ()=>{
				      $(injected).remove()
				      @(call 'compile)
				      @(call 'storeState)
				      return false
				      })

	      console.log(runeId)
	      if(runeId == "|(|")
	        @(call 'addRune "|)|"
		      (html->js-injector 
			(id->html lang
				  '|)|))
		      @js{x+50} 'y)

	      @(call 'compile)
	      @(call 'storeState)
	      })

    (function (construct)
              @js{
 var element = document.getElementById('grid-snap')
 var x = 0; var y = 0

 interact("@(id# 'runeContainer) .rune")
 .draggable({
  modifiers: [
  interact.modifiers.snap({
   targets: [
   //  interact.createSnapGrid({ x: 50, y: 50 })
   ],
   range: Infinity,
   relativePoints: [ { x: 0, y: 0 } ]
   }),
  interact.modifiers.restrict({
   restriction: document.getElementById("rune-container"),
   elementRect: { top: 0, left: 0, bottom: 1, right: 1 },
   endOnly: true
   })
  ],
  inertia: true
  })
 .on('dragmove', function (event) {
  var target = event.target
  // keep the dragged position in the data-x/data-y attributes
  var x = (parseFloat(target.getAttribute('data-x')) || 0) + event.dx
  var y = (parseFloat(target.getAttribute('data-y')) || 0) + event.dy

  // translate the element
  target.style.webkitTransform =
  target.style.transform =
  'translate(' + x + 'px, ' + y + 'px)'

  // update the posiion attributes
  target.setAttribute('data-x', x)
  target.setAttribute('data-y', y)

  })
  .on('dragend', function(event){
      var target = event.target

      var x = (parseFloat(target.getAttribute('data-x')) || 0) + event.dx
      var y = (parseFloat(target.getAttribute('data-y')) || 0) + event.dy

      x = Math.round(x / 50) * 50
      y = Math.round(y / 50) * 50

      // translate the element
      target.style.webkitTransform =
      target.style.transform = 'translate(' + x + 'px, ' + y + 'px)'

      // update the posiion attributes
      target.setAttribute('data-x', x)
      target.setAttribute('data-y', y)
      
      @(call 'compile)
      @(call 'storeState)

      
      })

   @(call 'restoreState)
 })

  (function (compile)
            @js{
	    var me = document.getElementById(@(~j "NAMESPACE_runeContainer"))
	    var runeImages = Array.prototype.slice.call(me.querySelectorAll(":scope > .rune"))
	    console.log(runeImages)

	    var sortedRuneImages = runeImages.sort(function (a, b) {
							    var aP = $(a).offset()
							    var bP = $(b).offset()

							    var aY = aP.top
							    var bY = bP.top
							    var aX = aP.left
							    var bX = bP.left

							    if(aY == bY)
							    {
							    return (aX < bX) ? -1 : (aX > bX) ? 1 : 0;
							    }
							    else
							    {
							    return (aY < bY) ? -1 : 1;
							    }
							    })

	    var grid = function(len,width){
	    var ret = []

	    for(var i = 0; i < len; i++){
		    var line = Array(width).fill("")
		    ret.push(line)
		    }

		    return ret
		    }

 var lastY = false
 var programGrid = sortedRuneImages.map((i)=>{
  var alt = i.getAttribute("data-id").replace(/\|/g,"")
  var p = $(i).offset()

  var y = Math.round($(i).offset().top / 50)
  var x = Math.round($(i).offset().left / 50)

  return {id: alt, x: x, y: y}
  }).reduce(
    function(acc,val){
      acc[val.y][val.x] = val.id //+ ":" + val.x + ":" + val.y

      //Backfill whitespace on the line
      for(var i = val.x-1; i >= 0; i--){
        if(acc[val.y][i] == ""){
          acc[val.y][i] = " " 
	} else{
	  break
	}
      }

      return acc
    },
    //Grid size should maybe be calculated from rune surface size??  Unless that's infinite.
    //Just picking some big numbers for now...
    grid(1000 , 1000 )
  )

 var program = programGrid.map((line) => line.join(""))
 .filter((line)=>line.length>0).join("\n")

 //Abstract this fetch.  Not all editors will do ajax
 //fetch("/set-last-script?script="+program)

 return program
})

  (function (storeState)
	    @(store-state (id 'runeContainer))

)

  (function (restoreState)
	    @(restore-state (id 'runeContainer)))

  )))


(define (restore-state surface)
  ;not sure why the id is magically a div element....
  ; but it sure is nice...
  @js{
  var prog = localStorage.getItem("@(id 'lastProgram)") 

  if(prog != "")
  @surface .innerHTML = localStorage.getItem("@(id 'lastProgram)")
  })

(define (store-state surface)
  @js{localStorage.setItem("@(id 'lastProgram)", @surface .innerHTML) })



(define (demo-editor lang [prog-stx #f])
  (enclose
    (define out (id 'out))
    (card-group
      (card
	(rune-surface-component 
	  #:restore-state
	  (lambda (surface)
	    @js{
	    setTimeout(function(){
			var prog = @(call 'compile)
			@out .innerHTML = prog
			}, 1000)
	    })
	  #:store-state
	  (lambda (surface)
	    @js{
	    //@(store-state surface)
	    var prog = @(call 'compile)
	    @out .innerHTML = prog
	    })
	  lang
	  prog-stx
	  ))
      (card
	(card-body
	  (card-text
	    (code
	      (pre
		id: (id 'out)))))))
    (script ())))


