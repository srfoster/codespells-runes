#lang at-exp racket

(provide 
  store-state
  restore-state
  rune-surface-component)

(require "./rune-util.rkt"
	 webapp/js
	 (prefix-in html:
		    (only-in website
			     script)))

(define (rune-surface-component 
	  #:store-state [store-state store-state]
	  #:restore-state [restore-state restore-state]
	  lang program)
  (enclose
    (div
     class: 'runeContainer
     (html:script
       src:
       "https://cdn.jsdelivr.net/npm/interactjs/dist/interact.min.js")
   (div
     id: (id 'runeContainer)
     ;'onmouseleave: (~a (call 'storeState) ";" (call 'compile))
     style: (properties width: "100%" height: 500
			background-color: "rgba(0,0,0,0.5)"
			; border: "1px solid black"
			; border-radius: 10
			position: "relative"
			)

     ;TODO: Make work with nested program, or syntax...
     ;      Maybe program plus whitespace can be the data we store...
     #;
     (map (curry id->html lang) program)
     (typeset-runes-syntax lang program)
     ))
   (script
    ([construct (call 'construct)])

    (function (addRune rf)
	      @js{
	      var r = rf();

	      @(id 'runeContainer).append(r[0])
	      @(id 'runeContainer).append(r[1])

	      //var pr = $.parseHTML(r, document, true)

	      //@(id 'runeContainer).append(pr[0])
	      //@(id 'runeContainer).append(pr[1])

	      //console.log(pr)
	      console.log("Hi")
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
 var runeImages = Array.prototype.slice.call(document.querySelectorAll("@(id# 'runeContainer) .rune"))

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
  var alt = i.getAttribute("data-id")                                        
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


