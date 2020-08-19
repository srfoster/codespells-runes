#lang at-exp racket

(provide typeset-runes
	 id->html

	 (struct-out image-binding)
	 (struct-out rune-lang)
	 html-rune
	 
	 ;Styling
	 rune-width)

(require webapp/js
	 syntax/parse/define
	 )

(define rune-width 
  (make-parameter 50))


;A path is either a path or an element...
;  If path, rendered as img tag, else directly dumped
(struct image-binding (id path))
(struct rune-lang (name image-bindings))


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

  (define path
    (image-binding-path binding))

  (if (path? path)
      (img width: (rune-width)
	   src: (~a "/" path))
      path ))

(define (typeset-runes-syntax lang prog-stx)
  (local-require "./indent.rkt")

  (define line 0)
  (define col 0)
  (define id 0)
  (define ret '())
  (define (spanify id)
    (span

      'data-stx:  (~a prog-stx) 

      'data-col:  col

      'data-line: line 

      'data-rune-width: (rune-width)
      style: (properties 
	       display: "inline-block"
	       position: 'absolute

	       top:  (* line 
			(* 2 (rune-width)))
	       left: (* col
			(rune-width)))

      (id->html lang id) ))

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
	       (ret! (spanify 'OPEN-PAREN))
	       (col!)]
	      [(string=? ")" curr-char)
	       (col!)
	       (ret! (spanify 'CLOSE-PAREN)) ]
	      [(string=? " " curr-char)
	       (col!)]
	      [(string=? "\n" curr-char)
	       (col! 0)
	       (line!)]
	      [(string=? "_" curr-char)
	       (ret! (spanify (list-ref values id)))
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

