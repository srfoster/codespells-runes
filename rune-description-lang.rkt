#lang at-exp racket

(provide
  half
  svg-rune-description
  svg-filter

  crunchy
  crunchier
  van-gogh
  blurry

  rune-background
  rune-stroke
  rune-image

  (all-from-out "./rune-util.rkt"))

(require "./rune-util.rkt"
	 website/svg
	 webapp/js
	 website-js)

(define-syntax-rule (svg-rune-description stuff ...)
  (enclose
  (svg
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
		(+ (rune-width) (/ (rune-width) 5))) 
    style: (properties vertical-align: 'middle)

    (defs
      ((svg-filter) (id 'rune-filter)))

    stuff ...)
  (script ()
	  ;TODO: Make a way to configure 
	  ; the mouseenter/leave effects
	    (function (distort)
		      @js{
		        var elem = @(~j "#NAMESPACE_id")
		        $(elem)
			.animate({gray: 50},
				 {duration: 100,
				  step: function(now){
				    $(elem).css({filter: "grayscale(" + now + "%)"})
				  }})
		      }) 
	    (function (unDistort)
		      @js{
		        var elem = @(~j "#NAMESPACE_id")
		        $(elem)
			.animate({gray: 0},
				 {duration: 100,
				  step: function(now){
				    $(elem).css({filter: "grayscale(" + now + "%)"})
				  }})
		      }) 
	  ))

  #;
  (enclose
    (svg
      class: "rune"
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
	(crunchier-van-gogh))

      stuff )
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
				      (id 'rune-filter)
				      ")"))
      stroke: color
      stroke-width: 5
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
    style: (~a "fill:none;stroke:" color ";stroke-width:5;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;filter:url(#"(id 'rune-filter)")")))

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
		 (id 'rune-filter)
		 ")"))
    (html->element svg-s ns)))


(define (half n) (/ n 2))

(define (blurry id)
  (filter id: id
	  (feGaussianBlur stdDeviation: "1")))

(define (van-gogh id)
    (filter
       height: 1.3
       width: 1.3
       y: "-0.15000001"
       x: "-0.15000001"
       style: "color-interpolation-filters:sRGB" 
       id: id 
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

(define (crunchy id)
    (filter
       height: "1.3"
       width: "1.3"
       y: "-0.15000001"
       x: "-0.15000001"
       style: "color-interpolation-filters:sRGB"
       id: id
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

(define (crunchier id)
    (filter
       id: id
       x: "-0.15000001"
       width: "1.3"
       y: "-0.15000001"
       height: "1.3"
      (feSpecularLighting
         in: "SourceAlpha"
         surfaceScale: "1"
         specularConstant: "2"
         specularExponent: "18.5"
         id: "feSpecularLighting24923"
        (feDistantLight
           elevation: "30"
           azimuth: "225"
           id: "feDistantLight24921" ))
      (feComposite
         result: "result0"
         operator: "atop"
         in2: "SourceGraphic"
         id: "feComposite24925" )
      (feMorphology
         radius: "2"
         result: "result1"
         in: "SourceAlpha"
         operator: "dilate"
         id: "feMorphology24927" )
      (feComposite
         in: "result0"
         in2: "result1"
         id: "feComposite24929"
         result: "fbSourceGraphic" )
      (feColorMatrix
         result: "fbSourceGraphicAlpha"
         in: "fbSourceGraphic"
         values: "0 0 0 -1 0 0 0 0 -1 0 0 0 0 -1 0 0 0 0 1 0"
         id: "feColorMatrix24933" )
      (feTurbulence
         id: "feTurbulence24935"
         type: "turbulence"
         numOctaves: "5"
         baseFrequency: "0.08 0.175"
         seed: "25" )
      (feColorMatrix
         id: "feColorMatrix24937"
         result: "result5"
         values: "1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 2 0 " )
      (feComposite
         in2: "result5"
         id: "feComposite24939"
         in: "fbSourceGraphic"
         operator: "in" )
      (feMorphology
         id: "feMorphology24941"
         operator: "dilate"
         radius: "0.65"
         result: "result3" )
      (feTurbulence
         id: "feTurbulence24943"
         numOctaves: "7"
         baseFrequency: "0.05 0.09"
         type: "fractalNoise"
         seed: "25" )
      (feGaussianBlur
         id: "feGaussianBlur24945"
         stdDeviation: "2"
         result: "result7" )
      (feDisplacementMap
         in2: "result7"
         id: "feDisplacementMap24947"
         in: "result3"
         xChannelSelector: "R"
         yChannelSelector: "G"
         scale: "5"
         result: "result4" )
      (feFlood
         id: "feFlood24949"
         flood-opacity: "1"
         flood-color: "rgb(255,255,255)"
         result: "result8" )
      (feComposite
         in2: "result4"
         id: "feComposite24951"
         k3: "0.7"
         k1: "0.7"
         result: "result2"
         operator: "arithmetic"
         k2: "0"
         k4: "0" )
      (feComposite
         in2: "fbSourceGraphicAlpha"
         id: "feComposite24953"
         k2: "1"
         in: "result2"
         operator: "arithmetic"
         k1: "1"
         result: "result6"
         k3: "0"
         k4: "0" )
      (feBlend
         in2: "result6"
         id: "feBlend24955"
         mode: "multiply"
         in: "result6" )) )

(define svg-filter 
  (make-parameter
    crunchier))





