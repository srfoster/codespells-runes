#lang at-exp racket

(provide
  half
  svg-rune-description

  rune-background
  rune-stroke
  rune-image

  (all-from-out "./rune-util.rkt"))

(require "./rune-util.rkt"
	 website/svg
	 webapp/js)

(define-syntax-rule (svg-rune-description stuff ...)
  (enclose
    (svg
      class: "rune"
      id: (id 'id)
      width: (rune-width) 
      height: (rune-width)
      'onmouseenter: (call 'distort)
      'onmouseleave: (call 'unDistort)
      'viewBox: (~a 
		  (- (/ (rune-width) 10))
		  " " 
		  (- (/ (rune-width) 10))
		  " " 
		  (+ (rune-width) (/ (rune-width) 5))
		  " "
		  (+ (rune-width) (/ (rune-width) 5))
		  ) 
      style: (properties vertical-align: 'middle)

      (defs
	(van-gogh)
	(crunchy-van-gogh)
	(blurry))

      stuff ...)
    (script ()
	    (function (distort)
		      @js{
		        $("#" + "@(id 'id)".trim())
			.animate({baseFrequency: 0.005}, 
						 {duration: 500, 
						 step: function(now){
						 $("#" + "@(id 'id)".trim() + " .turbulence")
						 .attr("baseFrequency", now)
						 }})
		      }) 
	    
	    (function (unDistort)
		      @js{
		        $("#" + "@(id 'id)".trim())
			.animate({baseFrequency: 0}, 
						 {duration: 500, 
						 step: function(now){
						 $("#" + "@(id 'id)".trim() + " .turbulence")
						 .attr("baseFrequency", now)
						 }})
		      }
		      ) 
	    )))

;Must be syntax rule or else the enclosure won't protect things that call (id '___)
(define (rune-background 
	  #:color [color "gray"]
	  #:size  [size (rune-width)]
	  . stuff )
  (list
    (rect 
      style: (properties 'filter: (~a "url(#"
				      (id 'crunchy-vg)
				      ")"))
      stroke: color
      stroke-width: 10
      fill: "black"
      rx: 5
      width: size
      height: size)
    stuff))

(define-syntax-rule (define-provide-svg-path-cmd id)
		    (begin
		      (provide id)
		      (define id 'id)))

(define-provide-svg-path-cmd M)
(define-provide-svg-path-cmd H)
(define-provide-svg-path-cmd V)
(define-provide-svg-path-cmd C)
(define-provide-svg-path-cmd Z)
(define-provide-svg-path-cmd Q)
(define-provide-svg-path-cmd T)

(define-provide-svg-path-cmd m)
(define-provide-svg-path-cmd h)
(define-provide-svg-path-cmd v)
(define-provide-svg-path-cmd c)
(define-provide-svg-path-cmd z)
(define-provide-svg-path-cmd q)
(define-provide-svg-path-cmd t)

(define (rune-stroke #:color [color "#7eff6b"] . d-path-args)
  (define (scale-hack arg)
    (if (not (number? arg)) arg
	(exact->inexact (/ arg (/ 50 (rune-width))))))

  (path
    d: (string-join (map (compose ~a scale-hack)
			 d-path-args) " ")
    style: (~a "fill:none;stroke:" color ";stroke-width:5;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;filter:url(#"(id 'crunchy-vg)")"
	       )))

(define (rune-image unscaled-i
		    #:size [size (rune-width)]) 
  (local-require (only-in 2htdp/image
			  image-width
			  image-height
			  scale
			  square
			  overlay
			  save-svg-image)
		 website/util)


  (define iw (image-width unscaled-i))
  (define ih (image-height unscaled-i))

  (define scaled-i
    (if (or 
	  (> iw size)
	  (> ih size))
	(let ()
	  (define m (max iw ih))
	  (scale (/ size m)
		 unscaled-i))
	unscaled-i))

  (define i
    (overlay
      scaled-i
      (square
	size
	'solid
	'transparent)))

  (define temp (make-temporary-file "temp~a.svg"))


  (save-svg-image i temp 
		  (image-width i) 
		  (image-height i))

  ;2htdp saves svgs with pt units: convert to px
  (define svg-s 
    (regexp-replaces
      (string-join
	(rest (file->lines temp))
	"\n")
      '([#px"([0-9]+)pt" "\\1px"])))

  (define ns (module->namespace 'website))

  (namespace-require
    'website/svg
    ns)

  (g
    style: (properties
	     filter: 
	     (~a "url(#"
		 (id 'crunchy-vg)
		 ")"))
    (html->element svg-s ns)))


(define (half n) (/ n 2))

(define (blurry)
  (filter id: (id 'blurry)
	  (feGaussianBlur stdDeviation: "1")))


(define (van-gogh)
    (filter
       height: 1.3
       width: 1.3
       y: "-0.15000001"
       x: "-0.15000001"
       style: "color-interpolation-filters:sRGB" 
       id: (id 'vg)
      (feMorphology
         operator: "dilate"
         radius: "1.5"
         result: "result3"
         id: "feMorphology5454" )
      (feTurbulence
	 class: "turbulence"
         numOctaves: "5"
         baseFrequency: "0.002"
         type: "fractalNoise"
         seed: (~a (random 1 100))
	 )
      (feGaussianBlur
         stdDeviation: "0.5"
         result: "result91"
         id: "feGaussianBlur5458" )
      (feDisplacementMap
         in: "result3"
         xChannelSelector: "R"
         yChannelSelector: "G"
         scale: "10"
         result: "result4"
         in2: "result91"
         id: "feDisplacementMap5460" )
      (feBlend
         in2: "result2"
         mode: "screen"
         in: "result2"
         id: "feBlend5464"
         result: "fbSourceGraphic" )
      (feColorMatrix
         result: "fbSourceGraphicAlpha"
         in: "fbSourceGraphic"
         values: "0 0 0 -1 0 0 0 0 -1 0 0 0 0 -1 0 0 0 0 1 0"
         id: "feColorMatrix6503" )
      (feComposite
         in2: "offset"
         id: "feComposite6513"
         in: "fbSourceGraphic"
         operator: "over"
         result: "composite2" )))

(define (crunchy-van-gogh)
    (filter
       height: "1.3"
       width: "1.3"
       y: "-0.15000001"
       x: "-0.15000001"
       style: "color-interpolation-filters:sRGB"
       id: (id 'crunchy-vg)
      (feTurbulence
         type: "fractalNoise"
         numOctaves: "3"
         baseFrequency: "0.25 0.4"
         seed: "5")
      (feColorMatrix
         result: "result5"
         values: "1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 ")
      (feComposite
         in: "SourceGraphic"
         operator: "in"
         in2: "result5")
      (feMorphology
         operator: "dilate"
         radius: "1.5"
         result: "result3")
      (feTurbulence
	 class: "turbulence"
         numOctaves: "5"
         baseFrequency: "0"
         type: "fractalNoise"
         seed: "7")
      (feGaussianBlur
         stdDeviation: "0.5"
         result: "result91")
      (feDisplacementMap
         in: "result3"
         xChannelSelector: "R"
         yChannelSelector: "G"
         scale: "27"
         result: "result4"
         in2: "result91")
      (feComposite
         in: "result4"
         k3: "0.8"
         k1: "1.3"
         result: "result2"
         operator: "arithmetic"
         in2: "result4"
         k2: "0"
         k4: "0" )
      (feBlend
         in2: "result2"
         mode: "screen"
         in: "result2"
         result: "fbSourceGraphic" )
      (feColorMatrix
         result: "fbSourceGraphicAlpha"
         in: "fbSourceGraphic"
         values: "0 0 0 -1 0 0 0 0 -1 0 0 0 0 -1 0 0 0 0 1 0")
      (feFlood
         flood-opacity: "0.498039"
         flood-color: "rgb(255,251,0)"
         result: "flood"
         in: "fbSourceGraphic" )
      (feComposite
         in2: "fbSourceGraphic"
         in: "flood"
         operator: "in"
         result: "composite1" )
      (feGaussianBlur
         in: "composite1"
         stdDeviation: "3"
         result: "blur" )
      (feOffset
         dx: "0"
         dy: "0"
         result: "offset" )
      (feComposite
         in2: "offset"
         in: "fbSourceGraphic"
         operator: "over"
         result: "composite2" )))
