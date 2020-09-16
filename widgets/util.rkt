#lang at-exp racket

(provide on-rune-click-call)

(require website-js
	 codespells-runes/rune-util)

(define (on-rune-click-call js-f-name)
  @js{
 var pos = null
 var me = $(@(~j "#NAMESPACE_id"))

 //Hack to make sure we only open when the rune is not being dragged
 me.mousedown((e)=>
 {
  pos = me.position()
  })
   
 me.mouseup((e)=>{
  var newPos = me.position()
  if(!e.shiftKey && newPos.left == pos.left && newPos.top == pos.top)
   @(call js-f-name)
  })
   
 })