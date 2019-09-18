#lang at-exp racket/base

;;; ----------------------------------------------------------------------------
;;; Drawable - OpenGL API Wrapper

(require ffi/vector
         glm
         opengl
         opengl/util
         racket/class
         racket/format)

(provide (all-defined-out))

(define gl-drawable%
  (class object%
    (super-new)

    (init-field canvas uniform-vars)

    (define-syntax-rule (GL> canvas body ...)
      (send canvas with-gl-context (λ () body ...)))

    (init-field vertex-shader fragment-shader vertices colors)

    (define-values (vertex-buffer color-buffer program)
      (GL> canvas
        (let ()
          (define v-buf (u32vector-ref (glGenBuffers 1) 0))
          (glBindBuffer GL_ARRAY_BUFFER v-buf)
          (glBufferData GL_ARRAY_BUFFER
                        (gl-vector-sizeof vertices) vertices GL_STATIC_DRAW)
          (define c-buf (u32vector-ref (glGenBuffers 1) 0))
          (glBindBuffer GL_ARRAY_BUFFER c-buf)
          (glBufferData GL_ARRAY_BUFFER
                        (gl-vector-sizeof colors) colors GL_STATIC_DRAW)
          (define pgm
            (create-program
             (load-shader (open-input-string   vertex-shader)   GL_VERTEX_SHADER)
             (load-shader (open-input-string fragment-shader) GL_FRAGMENT_SHADER)))
          (values v-buf c-buf pgm))))

    (define/public (draw . args)
      (GL> canvas
        (glUseProgram program)

        (for ([var (in-list (map symbol->string uniform-vars))]
              [arg (in-list args)])
          (glUniformMatrix4fv (glGetUniformLocation program var)
                              1 #f (mat->f32vector arg)))

        ;; load vertices
        (glEnableVertexAttribArray 0)
        (glBindBuffer GL_ARRAY_BUFFER vertex-buffer)
        (glVertexAttribPointer 0 3 GL_FLOAT #f 0 0)

        ;; load colors
        (glEnableVertexAttribArray 1)
        (glBindBuffer GL_ARRAY_BUFFER color-buffer)
        (glVertexAttribPointer 1 3 GL_FLOAT #f 0 0)

        ;; draw the object
        (glDrawArrays GL_TRIANGLES 0 (f32vector-length vertices))

        ;; clean up
        (glDisableVertexAttribArray 1)
        (glDisableVertexAttribArray 0)))))
