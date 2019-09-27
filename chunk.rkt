#lang racket/base

(require glm
         voxel-engine/block
         voxel-engine/gl-drawable)

(provide (all-defined-out))

(struct chunk (layers)
  #:transparent
  #:name vx:chunk
  #:constructor-name make-chunk)

(define (chunk make-block #:width width #:height [height #f] #:depth [depth #f])
  (make-chunk (for/list ([i (in-range width)])
                (for/list ([j (in-range (or height width))])
                  (for/list ([k (in-range (or depth width))])
                    (make-block i j k))))))

(define (draw-chunk C cube projection view position #:size [size 1])
  (define-values (num-layers num-rows num-columns)
    (values (length (chunk-layers C))
            (length (car (chunk-layers C)))
            (length (caar (chunk-layers C)))))
  (for ([layer (in-list (chunk-layers C))]
        [i     (in-naturals)])
    (for ([row (in-list layer)]
          [j   (in-naturals)])
      (for ([B (in-list row)]
            [k (in-naturals)])
        (define position* (+ position (vec3 i j k)))
        (define model (* (translate (mat4) position*)
                         (scale (mat4) (* size (vec3 1)))))
        (draw-block B cube (* projection (transpose view) model))))))

(define (draw-block B cube mvp)
  (gl-draw cube mvp))
