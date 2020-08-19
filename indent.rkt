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
  ;Such a dumb hack for the racket/gui/base bs...  
  ; https://www.mail-archive.com/racket-users@googlegroups.com/msg40123.html
  (define temp (make-temporary-file))
  (with-output-to-file 
    #:exists 'replace
    temp 
    (thunk (display s)))

  (read
    (open-input-string
      (with-output-to-string
	(thunk
	  (system (~a "racket " me " " temp)))))))

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


