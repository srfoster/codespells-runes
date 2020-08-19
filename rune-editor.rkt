#lang at-exp racket

(provide rune-surface-component)

(require "./rune-util.rkt"
	 webapp/js
	 (prefix-in html:
		    (only-in website
			     script)))

(define (rune-surface-component lang program)
  (enclose
   (div
     id: "rune-container"
     'onmouseleave: (~a (call 'storeState) ";" (call 'compile))
     style: (properties width: "100%" height: 500
			background-color: "rgba(0,0,0,0.5)"
			; border: "1px solid black"
			; border-radius: 10
			)

     (html:script
       src:
       "https://cdn.jsdelivr.net/npm/interactjs/dist/interact.min.js")
     ;TODO: Make work with nested program, or syntax...
     ;      Maybe program plus whitespace can be the data we store...
     (map (curry id->html lang) program)
     )
   (script
    ([construct (call 'construct)])

    (function (construct)
              @js{
 var element = document.getElementById('grid-snap')
 var x = 0; var y = 0

 interact(".rune")
 .draggable({
  modifiers: [
  interact.modifiers.snap({
   targets: [
     interact.createSnapGrid({ x: 50, y: 50 })
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
    console.log(@(call 'compile))
    console.log(@(call 'storeState))
  })

   @(call 'restoreState)
 })

  (function (compile)
            @js{
 var runeImages = Array.prototype.slice.call(document.querySelectorAll(".rune"))

 var sortedRuneImages = runeImages.sort(function (a, b) {
  var aY = parseFloat(a.getAttribute("data-y"));
  var bY = parseFloat(b.getAttribute("data-y"));
  var aX = parseFloat(a.getAttribute("data-x"));
  var bX = parseFloat(b.getAttribute("data-x"));

  if(aY == bY)
  {
   return (aX < bX) ? -1 : (aX > bX) ? 1 : 0;
  }
  else
  {
   return (aY < bY) ? -1 : 1;
  }
})

 var program = sortedRuneImages.map((i)=>{
  var alt = i.getAttribute("alt")                                        
  if(alt != "literal"){
   return alt
  } else {
   return i.innerHTML
  }
  }).join(" ")

 //Abstract this fetch.  Not all editors will do ajax
 //fetch("/set-last-script?script="+program)
})

  (function (storeState)
            @js{



  localStorage.setItem("last-program", document.getElementById('rune-container').innerHTML)
  
})

  (function (restoreState)
            @js{
  console.log("RESTORING")

  var prog = localStorage.getItem("last-program") 

  if(prog != "")
    document.getElementById('rune-container').innerHTML = localStorage.getItem("last-program")

 
})
  )))
