#lang racket/base

(require glm
         racket/struct)

(provide (all-defined-out))

(define UP    (vec3 0 1 0))
(define RIGHT (vec3 1 0 0))

(struct camera (position forward up right speed look-speed zoom view-matrix)
  #:transparent
  #:mutable
  #:name vx:camera
  #:constructor-name make-camera)

(define (camera #:position   [position   (vec3 0 0 0)]
                #:forward    [forward    (- position (vec3 0 0 1))]
                #:up         [up         UP]
                #:speed      [speed      0.05]
                #:look-speed [look-speed 0.5]
                #:zoom       [zoom       80])
  (make-camera position forward up (cross up forward) speed look-speed zoom
               (look-at position forward up)))

(define (camera-perspective cam aspect z-near z-far)
  (perspective (radians (camera-zoom cam)) aspect z-near z-far))

(define (move-camera-forward! cam)
  (vec+= (camera-position cam) (* (camera-speed cam) (camera-forward cam)))
  (update-camera-view-matrix! cam))

(define (move-camera-backward! cam)
  (vec-= (camera-position cam) (* (camera-speed cam) (camera-forward cam)))
  (update-camera-view-matrix! cam))

(define (move-camera-up! cam)
  (vec+= (camera-position cam) (* (camera-speed cam) (camera-up cam)))
  (update-camera-view-matrix! cam))

(define (move-camera-down! cam)
  (vec-= (camera-position cam) (* (camera-speed cam) (camera-up cam)))
  (update-camera-view-matrix! cam))

(define (strafe-camera-right! cam)
  (vec+= (camera-position cam) (* (camera-speed cam) (camera-right cam)))
  (update-camera-view-matrix! cam))

(define (strafe-camera-left! cam)
  (vec-= (camera-position cam) (* (camera-speed cam) (camera-right cam)))
  (update-camera-view-matrix! cam))

(define (rotate-camera-right! cam)
  (camera-mouse-update! cam (camera-look-speed cam) 0)
  (update-camera-view-matrix! cam))

(define (rotate-camera-left! cam)
  (camera-mouse-update! cam (- 0 (camera-look-speed cam)) 0)
  (update-camera-view-matrix! cam))

(define (camera-mouse-update! cam Δx Δy)
  (define angle (vec3 (radians Δx) (radians Δy)))
  (set-camera-forward! cam (normalize
                            (* (mat3 (rotate (mat4) (radians Δx) UP))
                               (mat3 (rotate (mat4) (radians Δy) RIGHT))
                               (camera-forward cam))))
  (set-camera-up! cam (normalize
                       (* (mat3 (rotate (mat4) (radians Δx) UP))
                          (mat3 (rotate (mat4) (radians Δy) RIGHT))
                          (camera-up cam))))
  (set-camera-right! cam (cross (camera-up cam) (camera-forward cam)))
  (update-camera-view-matrix! cam))

(define (update-camera-view-matrix! cam)
  (mat=! (camera-view-matrix cam)
         (look-at (camera-position cam)
                  (+ (camera-position cam) (camera-forward cam))
                  (camera-up cam))))
