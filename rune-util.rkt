#lang at-exp racket

(provide typeset-runes
	 typeset-runes-syntax
	 typeset-runes-block
	 typeset-rune-inline

	 id->html
	 id->draggable-rune
	 datum->html

	 (struct-out image-binding)
	 (struct-out rune-lang)
	 rune-lang-ids
	 rune-lang-datum-ids 
	 append-rune-langs
         add-rune-to-lang
	 html-rune
	 
	 ;Styling
	 rune-width)

(require webapp/js
	 syntax/parse/define)

(define rune-width 
  (make-parameter 100))


;A path is either a path or an element...
;  If path, rendered as img tag, else directly dumped
(struct image-binding (id path) #:transparent)
(struct rune-lang (name image-bindings) #:transparent)

(define (rune-lang-ids lang)
  (filter (not/c procedure?)
	  (map image-binding-id
	       (rune-lang-image-bindings lang))))

(define (rune-lang-datum-ids lang)
  (filter procedure?
	  (map image-binding-id
	       (rune-lang-image-bindings lang))))

(define (append-rune-langs #:name [name 'combined]
                           . ls)

  (rune-lang name
	     (apply append
                    (map rune-lang-image-bindings ls))))

(define (add-rune-to-lang r lang)
  (rune-lang (rune-lang-name lang)
             (cons r (rune-lang-image-bindings lang))))


(define padding 50)

(define (open-paren-img)
  (img
   width: (rune-width)
   src: (~a "/RuneImages/OPEN-PAREN.svg")))

(define (close-paren-img)
  (img
   width: (rune-width)
   src: (~a "/RuneImages/CLOSE-PAREN.svg")))


(define (id->html lang id)
  (define binding
    (findf 
      (lambda (b)
	(eq? id (image-binding-id b)))
      (rune-lang-image-bindings lang)))

  (when (not binding)
    (error id "No Rune binding"))

  (define path
    (image-binding-path binding))

  (if (path? path)
      (img 
	alt: id
	width: (rune-width)
	   src: (~a "/" path))
      path ))

(define (datum->html lang datum)
  (define binding
    (findf 
      (lambda (b)
	(define f? (image-binding-id b))
	(and (procedure? f?)
	     (f? datum)))
      (rune-lang-image-bindings lang)))

  (when (not binding)
    (error datum "No Rune datum binding"))

  (define func
    (image-binding-path binding))

  (func datum))

(define typesetting-rune-width 50)

(define (id->draggable-rune id lang prog-stx line col)

  (define top
    (* line 
       (* 2 typesetting-rune-width)))
  (define left
    (* col
       typesetting-rune-width))

  (span

    'data-stx:  (~a prog-stx) 
    'data-id:  (cond 
		 [(eq? id 'OPEN-PAREN) "("]
		 [(eq? id 'CLOSE-PAREN) ")"]
		 [else id])
    'data-col:  col
    'data-line: line 
    'data-rune-width: typesetting-rune-width

    class: "rune"
    style: (properties 
	     display: "inline-block"
	     position: 'absolute

	     top: top 
	     left: left)

    (id->html lang id)))

(define (typeset-runes-syntax lang prog-stx)
  (local-require "./indent.rkt")

  (define line 0)
  (define col 0)
  (define id 0)
  (define ret '())

  (define sk (->skeleton-f prog-stx))

  (define bones  (skeleton-bones sk))
  (define values (skeleton-values sk))

  (define (ret! x) (set! ret (cons x ret)))
  (define (col! [x #f]) (if x (set! col x) (set! col (add1 col))))
  (define (line! [x #f]) (if x (set! line x) (set! line (add1 line))))
  (define (id! [x #f]) (if x (set! id x) (set! id (add1 id))))
  (for ([i (string-length bones)])
       (define curr-char (substring bones i (add1 i)))
       (cond
	 [(string=? "(" curr-char)
	  (ret! (id->draggable-rune '|(| lang prog-stx line col))
	  (col!)]
	 [(string=? ")" curr-char)
	  (col!)
	  (ret! (id->draggable-rune '|)| lang prog-stx line col)) ]
	 [(string=? " " curr-char)
	  (col!)]
	 [(string=? "\n" curr-char)
	  (col! 0)
	  (line!)]
	 [(string=? "_" curr-char)
	  (ret! (id->draggable-rune (list-ref values id) lang prog-stx line col))
	  (id!)
	  (col!)]))

  ret)

(define-syntax (typeset-runes stx)
  (syntax-parse stx
		[(_ lang prog-stx)
		 #'(typeset-runes-syntax lang #'prog-stx)
		 ]))

;Image can be an html element or a path
(define (html-rune id elem-or-path)
  (image-binding id elem-or-path))

(define (lines-in prog)
  (local-require syntax/to-string)
  (length
    (string-split 
      (syntax->string prog)
      "\n")))


(define-syntax-rule (typeset-runes-block lang prog)
		    (let ([lines
			    (lines-in #'prog)])
		      (div 
			style: 
			(properties
			  position: 'relative
			  padding-bottom: 20
			  width: "100%"
			  height: (* 100 lines))
			(typeset-runes lang prog))))


(define-syntax-rule (typeset-rune-inline lang prog)
		    (span 
		      style: 
		      (properties
			position: 'relative
			display: 'inline-block
			vertical-align: 'middle
			overflow: 'hidden
			width: 50  
			height: 50)
		      (span 
			style: 
			(properties
			  position: 'relative
			  'transform: "scale(0.5)"
			  display: 'inline-block
			  vertical-align: 'middle
			  width: 100  
			  height: 100
			  top: -25  
			  left: -25  )
			(typeset-runes lang prog))))

