#lang racket

(provide 
  basic-lang
  (all-from-out "./rune-description-lang.rkt")
  (all-from-out "./editor/main.rkt"))

(require (except-in "./rune-description-lang.rkt" q)
	 "./editor/main.rkt")

;A test
(require webapp/js 
	 (only-in 2htdp/image
		  circle
		  rectangle
		  square
		  ;text
		  triangle
		  above
		  beside
		  overlay
		  scale
		  rotate
		  ))

(define (square-donut [color 'cyan])
  (overlay
    (square 20 'solid 'black)
    (square 40 'solid color)))

(define (pipe [color 'cyan])
  (rectangle 5 100 'solid color))

(define (letter-C [color 'yellow])
  (overlay
    (beside
      (square 10 'solid 'transparent)
      (circle 20 'solid 'black))
    (circle 25 'solid color)))

(define (clover i) 
  (above 
    (beside i i)
    (beside i i)))

(define (bool-true)
  (circle 20 'solid 'magenta))

(define (bool-false)
  (circle 20 'outline 'magenta))

(define (and-desc)
  (above
    (beside 
      (bool-true)
      (bool-false))
    (rotate 90 (pipe))
    (bool-false)))

(define (or-desc)
  (above
    (beside 
      (bool-true)
      (bool-false))
    (rotate 90 (pipe))
    (bool-true)))

(define (not-desc)
  (above
    (bool-true)
    (rotate 90 (pipe))
    (bool-false)))

(define (open-paren [color 'cyan])
  (letter-C color))

(define (close-paren [color 'cyan])
  (rotate 180
	  (letter-C color)))

(define (open-paren-rune [color 'cyan])
  (parameterize ([rune-width 50])
    (svg-rune-description
      (rune-background
	#:color "#4169E1"
	(rune-image
	  (scale 0.5
		 (open-paren color)))))))

(define (close-paren-rune [color 'cyan])
  (parameterize ([rune-width 50])
    (svg-rune-description 
      (rune-background
	#:color "#4169E1"
	(rune-image
	  (scale 0.5
		 (close-paren color)))))))

(define (bool-true-rune)
  (svg-rune-description
    (rune-background
      #:color "#4169E1"
      (rune-image 
	(bool-true)))))

(define (bool-false-rune)
  (svg-rune-description
    (rune-background
      #:color "#4169E1"
      (rune-image 
	(bool-false)))))

(define (list-rune)
  (svg-rune-description
    (rune-background
      #:color "cyan"
      (rune-image 
	(beside
	  (circle 10 'solid 'green)
	  (circle 10 'solid 'green)
	  (circle 10 'solid 'green))))))


(define (basic-lang)
  (define lang-name 'codespells-runes/basic-lang)

  ;TODO: Probably useful.  Move elsewhere if there's a good place
  ; Tries to discover if the datum is some provided identifier in the Racket language
  ; named by lang-name
  (define (->provided-identifier lang-name datum)
    (cond
      [(symbol? datum)
       (let ()
	 (define thing (dynamic-require lang-name datum (thunk #f)))

	 datum)]
      [(procedure? datum)
       (let ()
	 (define func-name (object-name datum ))

	 (define thing (dynamic-require lang-name 
					func-name
					(thunk #f)))
	 func-name)]
      [else #f]
      ))

  (rune-lang lang-name 
	     (parameterize
	       ([rune-width 100])
	       (list

		 (html-rune element?
			    (lambda (data)
			      data))

		 (html-rune (curry ->provided-identifier lang-name)
			    (lambda (data)
			      ;Assumes that identifiers provided from the Racket lang
			      ;  are also specified in the Rune lang...
			      (id->html (basic-lang) 
					(->provided-identifier lang-name data))))

		 (html-rune string?
			    (lambda (data)
			      ;Maybe if provided by language's module, use that rune?
			      ;  Same with procedure
			      (local-require website/svg)
			      (svg-rune-description
				(rune-background
				  #:color "turquoise"
				    (text 
				      fill: "turquoise"
				      x: "40%" ;Not sure why this isn't working at 50%.  Border?
				      y: "40%"
				      'text-anchor: "middle"
				      'dominant-baseline: "middle"
				      (~a "\"" data "\""))))))

		 (html-rune symbol?
			    (lambda (data)
			      ;Maybe if provided by language's module, use that rune?
			      ;  Same with procedure
			      (local-require website/svg)
			      (svg-rune-description
				(rune-background
				  #:color "lime"
				    (text 
				      fill: "lime"
				      x: "40%" ;Not sure why this isn't working at 50%.  Border?
				      y: "40%"
				      'text-anchor: "middle"
				      'dominant-baseline: "middle"
				      'font-size: "2em"
				      (~a "'" data) )
				  ))))

		 (html-rune boolean?
			    (lambda (data)
			      (if data
				  (bool-true-rune)
				  (bool-false-rune))))

		 (html-rune list?
			    (lambda (data)
			      (list
				(open-paren-rune)
				(list-rune)
				(map
				  (curry datum->html (basic-lang))	
				  data)
				(close-paren-rune))))

		 (html-rune 'build 
			    (svg-rune-description
			      (rune-background
				#:color "#FFA500"
				(rune-stroke
				  #:color "#FFA500"
				  M 10 25 h 10 v 2 h -10)
				(rune-stroke
				  #:color "#FFA500"
				  M 20 25 c 0 -10 10 -10 10 0)
				(rune-stroke
				  #:color "#FFA500"
				  M 30 25 h 10 v 2 h -10))))

		 (html-rune 'small 
			    (svg-rune-description
			      (rune-background
				#:color "#DA70D6"
				(rune-image
				  (above
				    (rectangle 50 5 'solid 'pink))))))

		 (html-rune 'medium 
			    (svg-rune-description
			      (rune-background
				#:color "#DA70D6"
				(rune-image
				  (above
				    (rectangle 50 5 'solid 'pink)
				    (square 10 'solid 'transparent)
				    (rectangle 50 5 'solid 'pink))))))
		 (html-rune 'large 
			    (svg-rune-description
			      (rune-background
				#:color "#DA70D6"
				(rune-image
				  (above
				    (rectangle 50 5 'solid 'pink)
				    (square 10 'solid 'transparent)
				    (rectangle 50 5 'solid 'pink)
				    (square 10 'solid 'transparent)
				    (rectangle 50 5 'solid 'pink))))))

		 (html-rune 'define 
			    (svg-rune-description
			      (rune-background
				#:color "#4169E1"
				(rune-image 
				  (square-donut)))))

		 (html-rune 'if 
			    (svg-rune-description
			      (rune-background
				#:color "#4169E1"
				(rune-image 
				  (rotate -90
					  (scale 0.9
						 (beside
						   (letter-C 'cyan)
						   (above
						     (square-donut 'red)
						     (square 10 'solid 'transparent)
						     (square-donut 'green)))))))))

		 (html-rune 'and 
			    (svg-rune-description
			      (rune-background
				#:color "#4169E1"
				(rune-image 
				  (scale 0.7
					 (and-desc))
				  ))))

		 (html-rune 'or 
			    (svg-rune-description
			      (rune-background
				#:color "#4169E1"
				(rune-image 
				  (scale 0.7
					 (or-desc))))))

		 (html-rune 'not
			    (svg-rune-description
			      (rune-background
				#:color "#4169E1"
				(rune-image 
				  (scale 0.8 (not-desc))
				  ))))

		 (html-rune '#t
			    (bool-true-rune))

		 (html-rune '#f
			    (bool-false-rune))

		 (html-rune 'A
			    (svg-rune-description
			      (rune-background
				#:color "#4169E1"
				(rune-image 
				  (triangle 40 'solid 'red)))))

		 (html-rune 'B
			    (svg-rune-description
			      (rune-background
				#:color "#4169E1"
				(rune-image 
				  (above
				    (circle 20 'solid 'cyan)
				    (circle 20 'solid 'cyan))))))

		 (html-rune 'C
			    (svg-rune-description
			      (rune-background
				#:color "#4169E1"
				(rune-image 
				  (letter-C)
				  ))))

		 (html-rune 'list
			    (list-rune))

		   (html-rune '|(| 
				  (open-paren-rune)
				)

		   (html-rune '|)|
				(close-paren-rune))
		 ))))

(module+ main
	 (define test
	   (page index.html
		 (content
		   (div
		     (typeset-runes
		       (basic-lang)
		       #;
		       (not (and (or #t #f)))

		       #;
		       (define C 
			 (build small))

		       (define C 
			 (if (not (and (or #t #f)))
			     (build small)
			     (build small)))

		       ))

		   (rune-surface-component
		     basic-lang
		     '(|(| build small |)|)))))

	 (render (list 
		   (bootstrap-files)
		   test)
		 #:to "out"))

