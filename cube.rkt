#lang at-exp racket/base

(require ffi/vector
         opengl
         opengl/util
         racket/class
         racket/format)

(provide (all-defined-out))

;; (define cube-vertices
;;   (f32vector
;;    ;; triangle 1
;;    -0.5 -0.5 -0.5
;;    -0.5 -0.5  0.5
;;    -0.5  0.5  0.5
;;    ;; triangle 2
;;     0.5  0.5 -0.5
;;    -0.5 -0.5 -0.5
;;    -0.5  0.5 -0.5
;;    ;; triangle 3
;;     0.5  0.5 -0.5
;;    -0.5 -0.5 -0.5
;;    -0.5  0.5 -0.5
;;    ;; triangle 4
;;     0.5 -0.5  0.5
;;    -0.5 -0.5 -0.5
;;     0.5 -0.5 -0.5
;;    ;; triangle 5
;;     0.5  0.5 -0.5
;;     0.5 -0.5 -0.5
;;    -0.5 -0.5 -0.5
;;    ;; triangle 6
;;    -0.5 -0.5 -0.5
;;    -0.5  0.5  0.5
;;    -0.5  0.5 -0.5
;;    ;; triangle 7
;;     0.5 -0.5  0.5
;;    -0.5 -0.5  0.5
;;    -0.5 -0.5 -0.5
;;    ;; triangle 8
;;    -0.5  0.5  0.5
;;    -0.5 -0.5  0.5
;;     0.5 -0.5  0.5
;;    ;; triangle 9
;;     0.5  0.5  0.5
;;     0.5 -0.5 -0.5
;;     0.5  0.5 -0.5
;;    ;; triamgle 10
;;     0.5 -0.5 -0.5
;;     0.5  0.5  0.5
;;     0.5 -0.5  0.5
;;    ;; triangle 11
;;     0.5  0.5  0.5
;;     0.5  0.5 -0.5
;;    -0.5  0.5 -0.5
;;    ;; triangle 12
;;     0.5  0.5  0.5
;;    -0.5  0.5 -0.5
;;    -0.5  0.5  0.5
;;    ;; triangle 13 ???
;;     0.5  0.5  0.5
;;    -0.5  0.5  0.5
;;     0.5 -0.5  0.5))

(define cube-vertex-shader
  @~a{#version 300 es
      layout (location = 0)
      in mediump vec3 vertexPosition_modelspace;
      void main() {
        gl_Position.xyz = vertexPosition_modelspace;
        gl_Position.w = 1.0;
      }})

(define cube-fragment-shader
  @~a{#version 300 es
      out mediump vec3 color;
      void main () {
        color = vec3(1,0,0);
      }})

(struct cube (buffer program))

(define (make-cube canvas)
  (call-with-values
   (λ ()
     (send
      canvas with-gl-context
      (λ ()
        (define vertices
          (f32vector
           -1.0 -1.0 0.0
            1.0 -1.0 0.0
            0.0  1.0 0.0))
        (define buffer (u32vector-ref (glGenBuffers 1) 0))
        (glBindBuffer GL_ARRAY_BUFFER buffer)
        (glBufferData GL_ARRAY_BUFFER (gl-vector-sizeof vertices) vertices GL_STATIC_DRAW)
        (define program
          (create-program
           (load-shader (open-input-string cube-vertex-shader) GL_VERTEX_SHADER)
           (load-shader (open-input-string cube-fragment-shader) GL_FRAGMENT_SHADER)))
        (values buffer program))))
   cube))

(define (draw-cube C canvas)
  (send canvas with-gl-context
        (λ ()
          (glUseProgram (cube-program C))
          (glEnableVertexAttribArray 0)
          (glBindBuffer GL_ARRAY_BUFFER (cube-buffer C))
          (glVertexAttribPointer 0 3 GL_FLOAT #f 0 0)
          (glDrawArrays GL_TRIANGLES 0 3)
          (glDisableVertexAttribArray 0))))
