#lang racket/base

(require glm)

(provide (all-defined-out))

(define UP (vec3 0.0 1.0 0.0))

(struct camera (position view-dir)
  #:mutable
  #:name vx:camera
  #:constructor-name make-camera)

(define (camera)
  (make-camera (vec3 0 0 0) (vec3 0 0 -1)))

;; (define (camera-mouse-update! cam new-mouse)
;;   (define mouse-Δ (vec- (camera-old-mouse cam) new-mouse))
;;   (define-values (mouse-Δ.x mouse-Δ.y) (apply values (vec->list mouse-Δ)))
;;   (define new-dir (mat* (mat3 (rotate mouse-Δ.x UP)) (camera-view-dir cam)))
;;   )

(define (camera-view-matrix cam)
  (define position (camera-position cam))
  (look-at position (vec+ position (camera-view-dir cam)) UP))
