#lang racket/base

(require ffi/vector
         racket/class
         voxel-engine/gl-drawable
         voxel-engine/gl-shader)

(provide (all-defined-out))

(define vertex-shader
  (gl-shader
   #:version "300 es"
   #:in-buf  '([mediump vec3 pos]
               [mediump vec3 color])
   #:out     '([mediump vec3 fragmentColor])
   #:uniform '([mat4 mvp])
   #<<END

void main () {
  gl_Position = mvp * vec4(pos, 1);
  fragmentColor = color;
}

END
   ))

(define fragment-shader
  (gl-shader
   #:version "300 es"
   #:in  '([mediump vec3 fragmentColor])
   #:out '([mediump vec3 color])
   #<<END

void main () {
  color = fragmentColor;
}

END
   ))

(define (gl-cube canvas)
  (gl-drawable
   canvas vertex-shader fragment-shader
   `(vertices 3 ,(f32vector
                  ;; triangle 1: left-bottom
                  -1.0 -1.0 -1.0
                  -1.0 -1.0  1.0
                  -1.0  1.0  1.0
                  ;; triangle 2: left-top
                  -1.0 -1.0 -1.0
                  -1.0  1.0  1.0
                  -1.0  1.0 -1.0
                  ;; triangle 2: back-top
                  1.0  1.0 -1.0
                  -1.0 -1.0 -1.0
                  -1.0  1.0 -1.0
                  ;; triangle 3: bottom-right
                  1.0 -1.0  1.0
                  -1.0 -1.0 -1.0
                  1.0 -1.0 -1.0
                  ;; triangle 4: back-bottom
                  1.0  1.0 -1.0
                  1.0 -1.0 -1.0
                  -1.0 -1.0 -1.0
                  ;; triangle 6: bottom-left
                  1.0 -1.0  1.0
                  -1.0 -1.0  1.0
                  -1.0 -1.0 -1.0
                  ;; triangle 7: front-left
                  -1.0  1.0  1.0
                  -1.0 -1.0  1.0
                  1.0 -1.0  1.0
                  ;; triangle 8: right-top
                  1.0  1.0  1.0
                  1.0 -1.0 -1.0
                  1.0  1.0 -1.0
                  ;; triamgle 9: right-bottom
                  1.0 -1.0 -1.0
                  1.0  1.0  1.0
                  1.0 -1.0  1.0
                  ;; triangle 10: top-right
                  1.0  1.0  1.0
                  1.0  1.0 -1.0
                  -1.0  1.0 -1.0
                  ;; triangle 11: top-left
                  1.0  1.0  1.0
                  -1.0  1.0 -1.0
                  -1.0  1.0  1.0
                  ;; triangle 12: front-right
                  1.0  1.0  1.0
                  -1.0  1.0  1.0
                  1.0 -1.0  1.0
                  ))

   ;; One color for each vertex. They were generated randomly.
   `(colors 3 ,(f32vector 0.583 0.771 0.014
                          0.609 0.115 0.436
                          0.327 0.483 0.844
                          0.822 0.569 0.201
                          0.435 0.602 0.223
                          0.310 0.747 0.185
                          0.597 0.770 0.761
                          0.559 0.436 0.730
                          0.359 0.583 0.152
                          0.483 0.596 0.789
                          0.559 0.861 0.639
                          0.195 0.548 0.859
                          0.014 0.184 0.576
                          0.771 0.328 0.970
                          0.406 0.615 0.116
                          0.676 0.977 0.133
                          0.971 0.572 0.833
                          0.140 0.616 0.489
                          0.997 0.513 0.064
                          0.945 0.719 0.592
                          0.543 0.021 0.978
                          0.279 0.317 0.505
                          0.167 0.620 0.077
                          0.347 0.857 0.137
                          0.055 0.953 0.042
                          0.714 0.505 0.345
                          0.783 0.290 0.734
                          0.722 0.645 0.174
                          0.302 0.455 0.848
                          0.225 0.587 0.040
                          0.517 0.713 0.338
                          0.053 0.959 0.120
                          0.393 0.621 0.362
                          0.673 0.211 0.457
                          0.820 0.883 0.371
                          0.982 0.099 0.879))))
