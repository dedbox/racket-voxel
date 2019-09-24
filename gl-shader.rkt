#lang racket/base

(require racket/format
         racket/list
         racket/pretty
         racket/string
         racket/struct)

(provide (all-defined-out))

(struct gl-shader (version in-bufs in-vars out-vars uniform-vars body)
  #:transparent
  #:name vx:gl-shader
  #:constructor-name make-gl-shader
  #:methods gen:custom-write
  [(define (write-proc shader port mode)
     (case mode
       [(#t #f) (fprintf port "#<gl-shader>")]
       [(1) ((if (pretty-printing) pretty-print print)
             `(make-gl-shader ,@(struct->list shader)))]
       [(0) (fprintf port (gl-shader->string shader))]))])

(define (gl-shader #:version [version     "330"]
                   #:in-buf  [in-bufs      null]
                   #:in      [in-vars      null]
                   #:out     [out-vars     null]
                   #:uniform [uniform-vars null]
                   body)
  (make-gl-shader version in-bufs in-vars out-vars uniform-vars body))

(define (gl-shader-args shader)
  (map last (gl-shader-uniform-vars shader)))

(define (gl-shader->string shader)
  (define (to-string xs)
    (string-join (map ~a xs)))
  (define port (open-output-string))
  (define-values (version in-bufs in-vars out-vars uniform-vars body)
    (apply values (struct->list shader)))
  (fprintf port "#version ~a\n" version)
  (for ([var (in-list in-bufs)]
        [i (in-naturals)])
    (fprintf port "layout (location = ~a) in ~a;\n" i (to-string var)))
  (for ([var (in-list in-vars)])
    (fprintf port "in ~a;\n" (to-string var)))
  (for ([var (in-list out-vars)])
    (fprintf port "out ~a;\n" (to-string var)))
  (for ([var (in-list uniform-vars)])
    (fprintf port "uniform ~a;\n" (to-string var)))
  (fprintf port body)
  (get-output-string port))

(define (gl-shader->port shader)
  (open-input-string (gl-shader->string shader)))
