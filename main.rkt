#lang racket

(provide 
  basic-lang
  (all-from-out "./rune-description-lang.rkt"))

(require (except-in "./rune-description-lang.rkt" q)
	 "./rune-editor.rkt")

;A test
(require webapp/js 
	 (only-in 2htdp/image
		  circle
		  rectangle
		  square
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

(define (open-paren)
  (rotate 90
	  (triangle 30 'solid 'cyan)))

(define (close-paren)
  (rotate -90
	  (triangle 30 'solid 'cyan)))

(define basic-lang
  (rune-lang 'basic-lang
	     (parameterize
	       ([rune-width 100])
	       (list
		 ;Shouldn't be called svg-rune anymore...
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
				(rune-stroke
				  #:color "#DA70D6"
				  M 10 25 h 30 v 2 h -30))))

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
			    (svg-rune-description
			      (rune-background
				#:color "#4169E1"
				(rune-image 
				  (bool-true) 
				  ))))

		 (html-rune '#f
			    (svg-rune-description
			      (rune-background
				#:color "#4169E1"
				(rune-image 
				  (bool-false) ))))

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

		 (parameterize ([rune-width 50])
		   (html-rune 'OPEN-PAREN 
			      (svg-rune-description
				(rune-background
				  #:color "#4169E1"
				  (rune-image
				    (scale 0.5
					   (open-paren)))))))

		 (parameterize ([rune-width 50])
		   (html-rune 'CLOSE-PAREN 
			      (svg-rune-description 
				(rune-background
				  #:color "#4169E1"
				  (rune-image
				    (scale 0.5
					   (close-paren)))))))
		 ))))

(module+ main
	 (define test
	   (page index.html
		 (content
		   (div
		     (typeset-runes
		       basic-lang
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
		     '(OPEN-PAREN build small CLOSE-PAREN)))))

	 (render (list 
		   (bootstrap-files)
		   test)
		 #:to "out"))

