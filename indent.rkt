#lang racket

(provide ->skeleton 
	 ->skeleton-f
	 (struct-out skeleton))

(require racket/port
	 racket/class
	 ;framework
	 syntax/parse/define
	 (for-syntax
	   racket/syntax))

(struct skeleton (bones values) #:transparent)

(define (->skeleton-f stx)
  (local-require syntax/to-string)

  (define s (syntax->string #`(#,stx)))

  (skeleton (tabify
	      (regexp-replaces s
			       '([#rx"[^() \n]+" "_" ])))

	    (flatten (syntax->datum stx))))

(define-syntax (->skeleton stx)
  (syntax-parse stx
		[(_ p)
		 #`(->skeleton-f #'p) ]))

(provide tabify)


(require racket/runtime-path)
(define-runtime-path me "indent.rkt")
(define (tabify s)
  (displayln s)

  ;Turns out that simply not tabifying it is best 
  s

  ;Possible other algorithm:
  ;  current-removed-space is 0
  ;  Go line by line, 
  ;    remove current-removed-space leading spaces 
  ;    compress the rest into 1 space, add the amount compressed to current-removed-space


  ;FAILED TRY 1: This creates unnatural breaks no matter what you set 
  ; the second arg (columns) to. E.g. (define x 1) becomes
  ; (define
  ;  x
  ;  1)
  ;Plus, the extra lines added make the height calculation wrong on typeset-runes-block
  #;
  (pretty-format (read (open-input-string s))
		 1)


  ;FAILED TRY 2:
  ;  This "works" but the workaround for the racket/gui/base bug requires 
  ;  having this file run itself in another process (by calling itself on the
  ;  command line).  It is so SLOOOOW that it becomes unbearable 
  ;  to build codespells.org

  ;Such a dumb hack for the racket/gui/base bs...  
  ; https://www.mail-archive.com/racket-users@googlegroups.com/msg40123.html
  #;
  (define temp (make-temporary-file))

  #;
  (with-output-to-file 
    #:exists 'replace
    temp 
    (thunk (display s)))

  #;
  (read
    (open-input-string
      (with-output-to-string
	(thunk
	  (system (~a "racket " me " " temp))))))
  )

(module+ main
	 (define args
	   (vector->list
	     (current-command-line-arguments)) )

	 (define (dangerous-tabify s)
	   (define racket:text%
	     (dynamic-require 'framework
			      'racket:text%))
	   (define t (new racket:text%))
	   (send t insert s 0)
	   (send t tabify-all)
	   (send t get-text))

	 (when (< 0 (length args))
	   (write
	     (dangerous-tabify 
	       (file->string (first args))))))

(module+ test
	 (define s
	   (string-append
	     "(D C \n"
	     "   (I (n (a (o \"tele\\nvision\" f)))\n"
	     "      (b s)\n"  
	     "      (b s)))\n"))

	 (displayln (tabify s))
	 )


