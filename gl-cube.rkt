#lang at-exp racket/base

(require ffi/vector
         glm
         opengl
         opengl/util
         racket/class
         racket/format)

(provide (all-defined-out))

(define gl-cube%
  (class object%
    (super-new)
    (init canvas)

    (define-syntax-rule (GL canvas body ...)
      (send canvas with-gl-context (λ () body ...)))

    (define vertices
      (f32vector
       ;; triangle 1
       -0.5 -0.5 -0.5
       -0.5 -0.5  0.5
       -0.5  0.5  0.5
       ;; triangle 2
        0.5  0.5 -0.5
       -0.5 -0.5 -0.5
       -0.5  0.5 -0.5
       ;; triangle 3
        0.5 -0.5  0.5
       -0.5 -0.5 -0.5
        0.5 -0.5 -0.5
       ;; triangle 4
        0.5  0.5 -0.5
        0.5 -0.5 -0.5
       -0.5 -0.5 -0.5
       ;; triangle 5
       -0.5 -0.5 -0.5
       -0.5  0.5  0.5
       -0.5  0.5 -0.5
       ;; triangle 6
        0.5 -0.5  0.5
       -0.5 -0.5  0.5
       -0.5 -0.5 -0.5
       ;; triangle 7
       -0.5  0.5  0.5
       -0.5 -0.5  0.5
        0.5 -0.5  0.5
       ;; triangle 8
        0.5  0.5  0.5
        0.5 -0.5 -0.5
        0.5  0.5 -0.5
       ;; triamgle 9
        0.5 -0.5 -0.5
        0.5  0.5  0.5
        0.5 -0.5  0.5
       ;; triangle 10
        0.5  0.5  0.5
        0.5  0.5 -0.5
       -0.5  0.5 -0.5
       ;; triangle 11
        0.5  0.5  0.5
       -0.5  0.5 -0.5
       -0.5  0.5  0.5
       ;; triangle 12
        0.5  0.5  0.5
       -0.5  0.5  0.5
        0.5 -0.5  0.5))

    ;; One color for each vertex. They were generated randomly.
    (define colors
      (f32vector
       0.583 0.771 0.014
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
       0.982 0.099 0.879))

    (define vertex-shader
      @~a{#version 300 es
          layout (location = 0) in mediump vec3 pos;
          layout (location = 1) in mediump vec3 color;
          out mediump vec3 fragmentColor;
          uniform mat4 model;
          uniform mat4 view;
          uniform mat4 projection;
          void main() {
            gl_Position = projection * view * model * vec4(pos, 1);
            fragmentColor = color;
          }})

    (define fragment-shader
      @~a{#version 300 es
          in mediump vec3 fragmentColor;
          out mediump vec3 color;
          void main () {
            color = fragmentColor;
          }})

    (define-values (vertex-buffer color-buffer program)
      (GL canvas
        (let ()
          (define vertex-buffer (u32vector-ref (glGenBuffers 1) 0))
          (glBindBuffer GL_ARRAY_BUFFER vertex-buffer)
          (glBufferData GL_ARRAY_BUFFER
                        (gl-vector-sizeof vertices) vertices GL_STATIC_DRAW)
          (define color-buffer (u32vector-ref (glGenBuffers 1) 0))
          (glBindBuffer GL_ARRAY_BUFFER color-buffer)
          (glBufferData GL_ARRAY_BUFFER
                        (gl-vector-sizeof colors) colors GL_STATIC_DRAW)
          (define program
            (create-program
             (load-shader (open-input-string   vertex-shader)   GL_VERTEX_SHADER)
             (load-shader (open-input-string fragment-shader) GL_FRAGMENT_SHADER)))
          (values vertex-buffer color-buffer program))))

    (define/public (draw canvas model view projection)
      (GL canvas
        (glUseProgram program)

        ;; load mvp
        (glUniformMatrix4fv (glGetUniformLocation program "model")
                            1 #f (mat->f32vector model))
        (glUniformMatrix4fv (glGetUniformLocation program "view")
                            1 #f (mat->f32vector view))
        (glUniformMatrix4fv (glGetUniformLocation program "projection")
                            1 #f (mat->f32vector projection))

        ;; load vertices
        (glEnableVertexAttribArray 0)
        (glBindBuffer GL_ARRAY_BUFFER vertex-buffer)
        (glVertexAttribPointer 0 3 GL_FLOAT #f 0 0)

        ;; load colors
        (glEnableVertexAttribArray 1)
        (glBindBuffer GL_ARRAY_BUFFER color-buffer)
        (glVertexAttribPointer 1 3 GL_FLOAT #f 0 0)

        ;; draw the object
        (glDrawArrays GL_TRIANGLES 0 (* 12 3))

        ;; clean up
        (glDisableVertexAttribArray 1)
        (glDisableVertexAttribArray 0)))))
