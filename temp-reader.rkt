#lang racket

(require syntax/readerr)

(provide read read-syntax)

(define (read in)
  (syntax->datum (read-syntax #f in)))

(define (read-syntax src in)
  (skip-whitespace in)
  (read-expr src in))

(define (skip-whitespace in)
  (regexp-match #px"^\\s*" in))

(define (read-expr src in)
  )
