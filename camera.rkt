#lang racket/base

(require glm
         racket/struct)

(provide (all-defined-out))

(define UP    (vec3 0 1 0))
(define RIGHT (vec3 1 0 0))

(struct camera (position forward up speed view-matrix)
  #:transparent
  #:mutable
  #:name vx:camera
  #:constructor-name make-camera)

(define (camera)
  (make-camera (vec3 0 0 0) (vec3 0 0 -1) (vec3 0 1 0) 0.05
               (look-at (vec3 0 0 0) (vec3 0 0 -1) (vec3 0 1 0))))

(define (move-camera-forward! cam)
  (define-values (position forward up speed view-matrix)
    (apply values (struct->list cam)))
  (vec+= position (* speed forward))
  (update-camera-view-matrix! cam))

(define (move-camera-backward! cam)
  (define-values (position forward up speed view-matrix)
    (apply values (struct->list cam)))
  (vec-= position (* speed forward))
  (update-camera-view-matrix! cam))

(define (strafe-camera-right! cam)
  (define-values (position forward up speed view-matrix)
    (apply values (struct->list cam)))
  (define right (cross up forward))
  (vec+= position (* speed right))
  (update-camera-view-matrix! cam))

(define (strafe-camera-left! cam)
  (define-values (position forward up speed view-matrix)
    (apply values (struct->list cam)))
  (define right (cross up forward))
  (vec-= position (* speed right))
  (update-camera-view-matrix! cam))

(define (camera-mouse-update! cam Δx Δy)
  (define-values (position forward up speed view-matrix)
    (apply values (struct->list cam)))
  (define angle (vec3 (radians Δx) (radians Δy)))
  (set-camera-forward! cam (normalize
                            (* (mat3 (rotate (mat4) (radians Δx) UP))
                               (mat3 (rotate (mat4) (radians Δy) RIGHT))
                               forward)))
  (set-camera-up! cam (normalize
                       (* (mat3 (rotate (mat4) (radians Δx) UP))
                          (mat3 (rotate (mat4) (radians Δy) RIGHT))
                          up)))
  (update-camera-view-matrix! cam))

(define (update-camera-view-matrix! cam)
  (define-values (position forward up speed view-matrix)
    (apply values (struct->list cam)))
  (mat=! view-matrix (look-at position (+ position forward) UP)))
