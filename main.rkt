#lang racket/gui

(require glm
         racket/class
         racket/struct
         voxel-engine/camera
         voxel-engine/gl-cube
         voxel-engine/gl-canvas
         voxel-engine/gl-drawable)

(define invert-mouse? #t)

(module+ main
  (define frame (new frame% [label "Voxel Engine"]))

  ;; camera

  (define cam (camera))
  (define sign (if invert-mouse? 1 -1))

  ;; canvas

  (define main-gl-canvas%
    (class gl-canvas%
      (super-new)
      (inherit-field active?)
      (inherit deactivate)

      ;; keyboard
      (define/override (on-char event)
        (match* ((send event get-key-code)
                 (send event get-key-release-code))
          [('escape 'press) (deactivate)]
          [(#\w 'press) (move-camera-forward! cam)]
          [(#\s 'press) (move-camera-backward! cam)]
          [(#\a 'press) (strafe-camera-right! cam)]
          [(#\d 'press) (strafe-camera-left! cam)]
          [(#\e 'press) (move-camera-up! cam)]
          [(#\c 'press) (move-camera-down! cam)]
          [(#\x 'press) (rotate-camera-right! cam)]
          [(#\z 'press) (rotate-camera-left! cam)]
          [('release _) (void)]
          [(_ _) (super on-char event)]))

      ;; mouse
      (define/override (on-event event)
        (match* ((send event get-event-type)
                 (send event get-x)
                 (send event get-y))
          [('motion x y)
           (define-values (x-mid y-mid) (get-canvas-center))
           (unless (and (= x x-mid) (= y y-mid))
             (camera-mouse-update! cam (- x-mid x) (* sign (- y-mid y)))
             (warp-pointer-to-center))]
          [(_ _ _) (super on-event event)]))))

  (define canvas
    (new main-gl-canvas%
         [parent frame]
         [min-width 800]
         [min-height 600]
         [clear-color '(0.2 0.3 0.3 1.0)]
         [verbose? #t]))

  (unless (send canvas initialize)
    (error "OpenGL failed to initialize!"))

  ;; timing

  ;; (define Δ-time 0.0)
  ;; (define last-frame 0.0)

  ;; GUI

  (define (get-canvas-center)
    (let-values ([(width height) (send canvas get-gl-client-size)])
      (values (/ width 2) (/ height 2))))

  (define (warp-pointer-to-center)
    (let-values ([(x y) (get-canvas-center)]) (send canvas warp-pointer x y)))

  (send frame show #t)
  (send canvas focus)
  (send canvas set-cursor (make-object cursor% 'blank))
  (warp-pointer-to-center)

  ;; scene

  (define cube (gl-cube canvas))

  (define projection (perspective (radians 80) (send canvas aspect-ratio) 1 15))

  ;; main loop

  (letrec
      ([t (thread
           (λ ()
             (collect-garbage)
             (let loop ()
               (unless (get-field stopping? canvas)
                 (collect-garbage 'incremental)
                 (send canvas clear)

                 ;; ;; timing
                 ;; (define current-frame (current-inexact-milliseconds))
                 ;; (set! Δ-time (- current-frame last-frame))
                 ;; (set! last-frame current-frame)

                 ;; draw
                 (for* ([x (in-range 3)]
                        [y (in-range 3)]
                        [z (in-range 3)])
                   (define model (* (translate (mat4) (vec3 (- x 3/2) (- y 3/2) (- z 6)))
                                    (scale (mat4) (vec3 1/2))))
                   (gl-draw cube (* projection (transpose (camera-view-matrix cam)) model)))

                 ;; commit
                 (send canvas swap-gl-buffers)
                 (sleep)
                 (loop))

               ;; shut down
               (send canvas terminate)
               (exit))))])
    (void t)))
