#lang racket

(provide
  build small
  (all-from-out racket))

;build? small? medium?  Etc??
;  These are specific to codespells. 
;  Or we provide default defs, and they can be overriden?
; TODO: Should this whole (basic-lang) go in a different package??   I think so...

(define (build size)
  (local-require website)
  (video 'autoplay: #t 'loop: #t 'muted: #t
	 'width: 200 
    (source src: "https://codespells.org/videos/build-sphere-demo.webm")))

(define small 'small)
