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

  ;; (define cube-positions
  ;;   (list (vec3  0.0  0.0   0.0)
  ;;         (vec3  2.0  5.0 -15.0)
  ;;         (vec3 -1.5 -2.2  -2.5)
  ;;         (vec3 -3.8 -2.0 -12.3)
  ;;         (vec3  2.4 -0.4  -3.5)
  ;;         (vec3 -1.7  3.0  -7.5)
  ;;         (vec3  1.3 -2.0  -2.5)
  ;;         (vec3  1.5  2.0  -2.5)
  ;;         (vec3  1.5  0.2  -1.5)
  ;;         (vec3 -1.3  1.0  -1.5)))

  (letrec
      ([t (thread
           (λ ()
             (collect-garbage)
             (let loop ()
               (unless (get-field stopping? canvas)
                 (collect-garbage 'incremental)

                 ;; setup
                 (define model (rotate (mat4 1.0) (/ (current-inexact-milliseconds) 1000.0)
                                       (vec3 1.0 0.5 0.25)))
                 (define view (translate (mat4 1.0) (vec3 0.0 0.0 -3.0)))
                 (define projection (perspective (radians 45.0) (/ 4.0 3.0) 0.1 100.0))

                 ;; draw
                 (send canvas clear)
                 (send cube draw canvas model view projection)

                 ;; (for ([v (in-list cube-positions)]
                 ;;       [k (in-naturals)])
                 ;;   (define model
                 ;;     (rotate (translate (mat4 1.0) v)
                 ;;             (radians (* 20.0 k))
                 ;;             (vec3 1.0 0.3 0.5)))
                 ;;   (send cube draw canvas model view projection))

                 ;; commit
                 (send canvas swap-gl-buffers)
                 (sleep)
                 (loop))
               (send canvas terminate)
               (exit))))])
    (void t)))
