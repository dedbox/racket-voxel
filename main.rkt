#lang racket/gui

(require glm
         racket/class
         voxel-engine/gl-cube
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

  (define cube (new gl-cube% [canvas canvas]))

  (define view (translate (mat4 1.0) (vec3 0.0 0.0 -9.0)))
  (define projection (perspective (radians 45.0) (/ 4.0 3.0) 0.1 100.0))

  (letrec
      ([t (thread
           (λ ()
             (collect-garbage)
             (let loop ()
               (unless (get-field stopping? canvas)
                 (collect-garbage 'incremental)
                 ;; setup

                 ;; draw
                 (send canvas clear)

                 (for* ([i (in-range -1.0 2.0)]
                        [j (in-range -1.0 2.0)]
                        [k (in-range -1.0 2.0)])
                   (define modelRot (rotate (mat4 1.0)
                                            (/ (current-inexact-milliseconds) 1000.0)
                                            (vec3 1.0 0.5 0.25)))
                   (define modelTrans (translate (mat4 1.0) (vec3 i j k)))
                   (define modelScale
                     (scale (mat4 1.0)
                            (vec3 (+ 0.995
                                     (* 0.05
                                        (sin (/ (current-inexact-milliseconds) 75.0)))))))
                   (send cube draw modelRot modelTrans modelScale view projection))

                 ;; commit
                 (send canvas swap-gl-buffers)
                 (sleep)
                 (loop))
               (send canvas terminate)
               (exit))))])
    (void t)))
