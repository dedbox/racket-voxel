#lang racket/gui

(require racket/class
         voxel-engine/cube
         voxel-engine/gl-canvas)

(module+ main
  (define frame (new frame% [label "Voxel Engine"]))

  (define main-gl-canvas%
    (class gl-canvas%
      (super-new)
      (inherit-field active?)
      (inherit deactivate)
      (define/overment (on-char event)
        (match* ((send event get-key-code)
                 (send event get-key-release-code))
          [('escape 'press) (deactivate)]
          [(_ _) (void)]))))

  (define canvas
    (new main-gl-canvas%
         [parent frame]
         [min-width 800]
         [min-height 600]
         [clear-color '(0.2 0.3 0.3 1.0)]
         [verbose? #t]))

  (unless (send canvas initialize)
    (error "OpenGL failed to initialize!"))

  (send frame show #t)
  (send canvas focus)

  (define a-cube (make-cube canvas))

  (void (thread (λ ()
                  (collect-garbage)
                  (let loop ()
                    (when (get-field active? canvas)
                      (collect-garbage 'incremental)
                      (send canvas clear)
                      (draw-cube a-cube canvas)
                      (send canvas swap-gl-buffers)
                      (sleep)
                      (loop))
                    (send canvas terminate)
                    (exit))))))
