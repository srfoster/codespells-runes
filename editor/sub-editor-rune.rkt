#lang at-exp racket

(provide editor-rune
	 editor-factory)

(require website-js
	 codespells-runes/rune-util)

(define (editor-rune runeAppearance )
  (enclose 
    (div id: (id 'id) 
	 style: (properties position: 'relative)
	 (div id: (id 'wrapper)
	      runeAppearance)
	 (div 
	   class: "editorPreview"
	   style: (properties 
		    position: 'absolute
		    top: 0 
		    left: 0
		    width: 100
		    height: 100
		    ))
	 (div class: "hiddenEditor"
	      style: (properties display: 'none)))
    (script ([construct (call 'constructor)]
	     [originalId 'null] )
	    (function (constructor)
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
				 @(call 'openEditor)
				 })
		      })
	    (function (openEditor)
		      @js{
		      var me = document.querySelector(@(~j "#NAMESPACE_id"))

		      if(@(ns 'originalId) == null)
		      @(ns 'originalId) = $(me).attr("data-id")

		      var childEditor = document.querySelector(@(~j "#NAMESPACE_id .factoryEditor"))

		      var factory = document.querySelector(".editor-factory");

		      @(call-method 'factory 'pushEditor 
				    'childEditor
				    @js{@(ns 'onClose)})
		      })
	    (function (onClose childEditor)
		      @js{
		      var text = @(call-method @js{childEditor.querySelector(".runeContainer")} 'compile)

		      //For if we need to store that this expression is managed by an editor
		      //  (for when we need two-way isophorphism between text and Runes)
		      //var newText = "("+@(ns 'originalId)+" "+text+")"

		      var newText = text
		      var me = document.querySelector(@(~j "#NAMESPACE_id"))
		      $(me).attr("data-id", newText)

		      var unscaledPreview = 
		      $($(childEditor).find(".runeSurface")[0]).clone().removeAttr("id")

		      var scale = 0.2
		      var preview = unscaledPreview.css({transform: "scale("+ scale +")", 
								    transformOrigin: "top left", 
								    backgroundColor: "rgba(0,0,0,0)",
								    width: 500, 
								    height: 500,
								    overflow: "hidden"}).removeClass("runeSurface")

		      //These runes are behaving weirdly and they are just preview runes!
		      preview.find(".rune .editorPreview").remove()
		      preview.find(".rune .hiddenEditor").remove()
		      preview.find(".rune").removeClass("rune")

		      $(me).find(".editorPreview").html(preview)
		      $(me).find(".hiddenEditor").html($(childEditor))

		      var myEditor = @(call 'findEditorParent 'me) ;

		      @(call-method 'myEditor 'compile);

		      @(call-method 'myEditor 'storeState)
		      })
	    (function (findEditorParent node)
		      @js{
		      if($(node).hasClass("runeContainer")){
		      return node
		      }

		      if(node == null) return null

		      return @(call 'findEditorParent 'node.parentNode)
		      }
		      ))))

(define (editor-factory editor)
  (enclose
    (div id: (id 'id) 
	 class: "editor-factory") 
    (script ([onCloses @js{[]}])
	    (function (pushEditor editor onClose)
		      @js{

		      if(!editor){
		      var injector = @(call 'makeEditorInjector)
		      editor = injector(document.getElementById(@(~j "NAMESPACE_id")))
		      } else {
		      $(editor).show()
		      document.getElementById(@(~j "NAMESPACE_id")).appendChild(editor)
		      }

		      @(ns 'onCloses).push(onClose)
		      $(editor).css({padding: (@(ns 'onCloses).length + 1) * 10})
		      })
	    (function (popEditor)
		      @js{
		      var me = document.getElementById(@(~j "NAMESPACE_id"))
		      var child = me.lastElementChild
		      var onClose = @(ns 'onCloses).pop()

		      onClose(child)
		      //me.removeChild(child)
		      })
	    (function (makeEditorInjector)
		      @js{
		      return @(html->js-injector 
				(div 
				  class: "factoryEditor"
				  style: (properties position: 'fixed
						     z-index: "10000"
						     background-color: "rgba(255,255,255,0.5)"
						     top: 0
						     left: 0
						     width: "100vw"
						     height: "100vh"
						     padding: 10)
				  (button-primary 
				    class: "closeEditorButton"
				    on-click: (call 'popEditor)
				    "Close")
				  editor))}))))
