#lang racket

(provide
  build small medium large
  (all-from-out racket))

;Provide some minimal identifiers so that some basic spells work out of the box
; TODO: Should this whole (basic-lang) go in a different package??   I think so...

(define (build size)
  (local-require website)
  (video 'autoplay: #t 'loop: #t 'muted: #t
	 'width: 200 
    (source src: "https://codespells.org/videos/build-sphere-demo.webm")))

(define small 'small)
(define medium 'medium)
(define large 'large)
