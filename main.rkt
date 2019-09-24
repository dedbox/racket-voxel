#lang racket/gui

(require glm
         racket/class
         voxel-engine/camera
         voxel-engine/gl-cube
         voxel-engine/gl-canvas
         voxel-engine/gl-drawable)

(module+ main
  (define frame (new frame% [label "Voxel Engine"]))

  ;; camera

  (define cam (camera))

  ;; canvas

  (define main-gl-canvas%
    (class gl-canvas%
      (super-new)
      (inherit-field active?)
      (inherit deactivate)
      (define/override (on-char event)
        (match* ((send event get-key-code)
                 (send event get-key-release-code))
          [('escape 'press) (deactivate)]
          ;; [(#\w 'press) (process-camera-key! cam FORWARD  Δ-time)]
          ;; [(#\s 'press) (process-camera-key! cam BACKWARD Δ-time)]
          ;; [(#\a 'press) (process-camera-key! cam LEFT     Δ-time)]
          ;; [(#\d 'press) (process-camera-key! cam RIGHT    Δ-time)]
          [('release _) (void)]
          [(_ _) (super on-char event)]))
      ;; mouse events
      (define/override (on-event event)
        (match* ((send event get-event-type)
                 (send event get-x)
                 (send event get-y))
          [('motion x y) (println `(mouse motion ,x ,y))]
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

  (define Δ-time 0.0)
  (define last-frame 0.0)

  ;; GUI

  (send frame show #t)
  (send canvas focus)
  (send canvas set-cursor (make-object cursor% 'blank))

  ;; scene

  (define cube (gl-cube canvas))

  ;; main loop

  (letrec
      ([t (thread
           (λ ()
             (collect-garbage)
             (let loop ()
               (unless (get-field stopping? canvas)
                 (collect-garbage 'incremental)

                 ;; timing
                 (define current-frame (current-inexact-milliseconds))
                 (set! Δ-time (- current-frame last-frame))
                 (set! last-frame current-frame)

                 ;; scene
                 (define model
                   (* (translate (mat4) (vec3 0 0 -10))
                      (rotate (mat4)
                              (/ (current-inexact-milliseconds) 500)
                              (vec3 1 1/2 1/4))
                      (scale (mat4) (vec3 5))))
                 (define view (camera-view-matrix cam))
                 (define projection
                   (perspective (radians 80) (send canvas aspect-ratio) 2 10))

                 ;; draw
                 (send canvas clear)
                 (gl-draw cube (mat* projection view model))

                 ;; commit
                 (send canvas swap-gl-buffers)
                 (sleep)
                 (loop))

               (send canvas terminate)
               (exit))))])
    (void t)))

;; (module+ test
;;   ;; (define cam (camera (vec3 0.0 0.0 3.0)))
;;   (define model (mat*
;;                  (translate (mat4 1.0) (vec3 0.0 0.0 -3.0))
;;                  ;; (rotate (mat4 1.0) (radians 3.0) (vec3 1.0 0.0 0.0))
;;                  ;; (scale (mat4 1.0) (vec3 0.5))
;;                  ))
;;   (define view (mat4 1.0))
;;   ;; (define view (look-at (vec3 0.0 0.0 1.0)
;;   ;;                       (vec3 0.0 0.0 0.0)
;;   ;;                       (vec3 0.0 1.0 0.0)))
;;   ;; (define projection (ortho -1.0 1.0 -1.0 1.0 -1.0 1.0))
;;   ;; (define projection (perspective (radians 45.0) (/ 4.0 3.0) 0.1 1.1))
;;   (define projection (perspective (radians 60.0) (/ 4.0 3.0) 0.1 10.0))
;;   (println (mat* projection view model)))
