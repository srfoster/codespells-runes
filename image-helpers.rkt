#lang racket

(require 2htdp/image)

(provide padding arrow square-donut pipe letter-C clover bool-true bool-false and-desc
         or-desc not-desc open-paren close-paren)

(define (padding num)
  (square num 'solid 'transparent))

(define (arrow)
    (above
     (triangle 20 'solid 'blue)
     (rectangle 5 20 'solid 'blue)))


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
