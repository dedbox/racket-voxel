#lang racket/gui

(require opengl racket/class)

(provide (all-defined-out))

(define gl-canvas%
  (class canvas%
    (inherit with-gl-context)

    (init-field [active? #t]
                [verbose? #f]
                [clear-color '(0.0 0.0 1.0 1.0)])

    (field [min-gl-version '(3 0)])

    (define (info msg . args)
      (when verbose?
        (displayln (format "gl-canvas: ~a" (apply format msg args)))))

    (define-syntax-rule (GL body ...)
      (with-gl-context (λ () body ...)))

    (define/public (initialize)
      (info "initializing")
      (info "detected OpenGL version ~a" (GL (gl-version)))
      (define min-gl-version? (GL (gl-version-at-least? min-gl-version)))
      (info "OpenGL version at least ~a? ~a" min-gl-version min-gl-version?)
      min-gl-version?)

    (define/public (activate)
      (info "activating")
      (set! active? #t))

    (define/public (deactivate)
      (info "deactivating")
      (set! active? #f))

    (define/public (terminate)
      (info "terminating")
      (void))

    (define/override (on-size width height)
      (info "resizing canvas to ~ax~a" width height)
      (GL (glViewport 0 0 width height)))

    (define/override (on-char event)
      (define code (send event get-key-code))
      (define release-code (send event get-key-release-code))
      (info "key event ~a ~a" code release-code)
      (when (equal? (list code release-code) '(escape press))
        (set! active? #f)))

    (super-new [style '(gl no-autoclear)])

    (define/public (clear)
      (GL (apply glClearColor clear-color)
          (glClear (bitwise-ior GL_COLOR_BUFFER_BIT
                                GL_DEPTH_BUFFER_BIT))))))
