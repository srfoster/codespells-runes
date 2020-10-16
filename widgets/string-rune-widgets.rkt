#lang at-exp racket

(provide string-rune-widget
         (rename-out [raw-code-rune-widget modal-editor-rune-widget]) ;Use this name instead of raw-code-rune-widget now
         raw-code-rune-widget
         )

(require website-js
         (only-in webapp/js late-include-js)
         
	 codespells-runes/rune-util
         codespells-runes/widgets/util
         (only-in codespells-runes/rune-description-lang svg-rune-description rune-background)         )

(define (editor-component initial-value
			  #:editor-enabled? (editor-enabled? #t)
			  #:on-change (on-change #f))
  (enclose
    (span id: (ns "main")
          class: "editorComponent"
	  (include-js "https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.32.0/codemirror.min.js")
	  (include-js "https://codemirror.net/mode/scheme/scheme.js")
	  (include-css "https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.32.0/codemirror.min.css")

	  (textarea id: (ns "input")
		    initial-value))
    (script ([input  (ns "input")]
	     [main   (ns "main")]
	     [editor
	       @js{
	       function(){
	          if(!window.CodeMirror){ //Load it if the include-js above didn't work, which happens if the component is injected after the page loads.  The script tag doesn't run
  

		  @(late-include-js "https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.32.0/codemirror.min.js"
				    (late-include-js
				      "https://codemirror.net/mode/scheme/scheme.js"
				      (call 'setupEditor)))


		  } else {
		    return @(call 'setupEditor)
		  }
		}()
	       }])

       (function (setupEditor)
         @js{		 
	  @(id 'editor) = CodeMirror.fromTextArea(@getEl{@input}, 
						         { lineNumbers: true,
							   readOnly: @(if editor-enabled?
									  @js{false}
									  @js{"nocursor"}
									  )
							 });

	  @(if on-change
	     @js{
	     @(id 'editor).on("change",
		       ()=>@(on-change @js{editor.getValue()}))}
	     @js{})

	  @(id 'editor).setOption("mode", "scheme");

	  return @(id 'editor) })

       (function (refresh)
                 @js{
                     @(id 'editor).refresh()

 })

       (function (getString)
                 @js{
                     return @(id 'editor).getValue()

 })
       (function (getEditor)
                 @js{
                     return @(id 'editor)

 }))))


(require website/svg)

;One for editing "raw code" in a CodeMirror text area,
;  now updated to be more general:
;Manages a component shown in a model, and a Rune.
;  Click the Rune and see the component.
;Use the js snippet params to customize how the state of the widget component
; is reflected in the Rune component.
;For extra clean code -- make both the widget component and the Rune be enclosures,
;  make the js snippets just call-method on them.
(define (raw-code-rune-widget
         #:initial-rune [initial-rune (svg-rune-description
                                       (rune-background
                                        #:color "gray"
                                        (text
                                         class: "displayString"
                                         fill: "gray"
                                         x: "40%" ;Not sure why this isn't working at 50%.  Border?
                                         y: "40%"
                                         'text-anchor: "middle"
                                         'dominant-baseline: "middle"
                                         (~a "()"))))]
         #:editor [inside-modal-component (editor-component "()")]
         #:on-show-editor [on-show-js (lambda (component)
                                 (call-method component 'refresh))]
         #:compile-editor [on-compile-js (lambda (component)
                                       (call-method component 'getString))]

         #:update-rune-preview [update-rune-js
                        (lambda (rune-component val)
                          ;TODO: make this a method on the Rune that controls the CodeMirror
                          @js{
                          $(@rune-component).find(".displayString").html("\""+ @val .substring(0,3)+"...\"");
                         })])
  
  
  (enclose
   (div id: (id 'id) 'data-id: "(list)"
        data-toggle: "modal" data-target: (~a "#" (id 'modal))
        initial-rune
        )
   (script ([construct (call 'constructor)])
           (function (constructor)
                     @js{
                       @(register-modal-widget
                         (raw-code-widget-modal
                          #:inside-modal-component inside-modal-component))
                       $(@(~j "#NAMESPACE_modal")).on("shown.bs.modal",()=>@(call 'onShowModal))
                     })
           (function (onShowModal)
                     ;Gotta call refresh on the editor because CodeMirror needs to do a relayout
                     @js{
                         var editor = document.querySelector(@(~j "#NAMESPACE_modalBody > :first-of-type"));
                         @(on-show-js 'editor) })
           (function (done)
                     @js{
                       var editor = document.querySelector(@(~j "#NAMESPACE_modalBody > :first-of-type"));
                       var val = @(on-compile-js 'editor)

                       $(@(~j "#NAMESPACE_id")).attr("data-id", val)

                       var rune = document.querySelector(@(~j "#NAMESPACE_id > :first-of-type"));

                       @(update-rune-js 'rune 'val)
                     }))))

(define (raw-code-widget-modal
         #:inside-modal-component [inside-modal-component (editor-component "()")])
  (modal id: (id 'modal) role: "dialog"
         (modal-dialog class: "modal-lg" style: "max-width: 80% !important"
          (modal-content
           (modal-body id: (id 'modalBody)
            inside-modal-component  
            (modal-footer
             (button-primary
              'data-dismiss: "modal"
              on-click: (call 'done)
              "Done"))))))

 )

(define (string-widget-modal)
  (modal id: (id 'modal) role: "dialog"
         (modal-dialog
          (modal-content
           (modal-body
            (div class: "form-group"
                 (input id: (id 'stringInput)
                        type: "text"
                        class: "form-control"
                        'value: "Hello, World"))  
            (modal-footer
             (button-primary
              'data-dismiss: "modal"
              on-click: (call 'done)
              "Done")))))))

(define (register-modal-widget modal-widget)
  @js{
 var injector = @(html->js-injector modal-widget)

 injector(document.body)
 })


;A bit of a hack for now: Quoted.  Make a better raw editor soon!
(define (string-rune-widget #:quoted? [quoted? #t])
  (let ()
    (local-require website/svg)
    (string-rune-widget-wrapper #:quoted? quoted?
     (svg-rune-description
      (rune-background
       #:color "turquoise"
       (text
        class: "displayString"
        fill: "turquoise"
        x: "40%" ;Not sure why this isn't working at 50%.  Border?
        y: "40%"
        'text-anchor: "middle"
        'dominant-baseline: "middle"
        (~a "\"Hello, World\"")))))))

(define (string-rune-widget-wrapper #:quoted? quoted? rune-apppearance)

  (enclose
   (div id: (id 'id) 'data-id: "\"Hello, World\""
        data-toggle: "modal" data-target: (~a "#" (id 'modal))
        rune-apppearance)
   (script ([construct (call 'constructor)])
           (function (constructor)
                     @js{
                       @(register-modal-widget (string-widget-modal))
                     })
           (function (done)
                     @js{
                       var val = $(@(~j "#NAMESPACE_stringInput")).val()
                       $(@(~j "#NAMESPACE_id")).attr("data-id", @(if quoted?
                                                                     @js{"\""+val+"\""}
                                                                     @js{val}))

                       $(@(~j "#NAMESPACE_id .displayString")).html("\""+val.substring(0,3)+"...\"")
                     }))))