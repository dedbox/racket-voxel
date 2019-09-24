#lang at-exp racket/base

;;; ----------------------------------------------------------------------------
;;; Drawable - OpenGL API Wrapper

(require ffi/vector
         glm
         opengl
         opengl/util
         racket/class
         racket/format
         racket/list
         racket/pretty
         racket/struct
         racket/string
         voxel-engine/gl-shader)

(provide (all-defined-out))

(define-syntax-rule (GL> canvas body ...)
  (send canvas with-gl-context (λ () body ...)))

(struct gl-drawable (canvas args program buffers)
  #:transparent
  #:name vx:gl-drawable
  #:constructor-name make-gl-drawable)

(define (gl-drawable canvas vertex-shader fragment-shader . buffer-defs)
  (define buffers
    (GL> canvas
      (for/list ([def (in-list buffer-defs)])
        (define-values (name size data) (apply values def))
        (define buf (u32vector-ref (glGenBuffers 1) 0))
        (define elem-size (gl-vector-sizeof data))
        (glBindBuffer GL_ARRAY_BUFFER buf)
        (glBufferData GL_ARRAY_BUFFER elem-size data GL_STATIC_DRAW)
        (list name buf size (f32vector-length data)))))
  (define program
    (GL> canvas
      (create-program
       (load-shader (gl-shader->port vertex-shader  ) GL_VERTEX_SHADER)
       (load-shader (gl-shader->port fragment-shader) GL_FRAGMENT_SHADER))))
  (make-gl-drawable canvas (gl-shader-args vertex-shader) program buffers))

(define (gl-draw drawable . arg-vals)
  (define-values (canvas args program buffers)
    (apply values (struct->list drawable)))
  (GL> canvas
    (glUseProgram program)
    ;; arguments
    (for ([arg (in-list (map symbol->string args))]
          [val (in-list arg-vals)])
      (glUniformMatrix4fv
       (glGetUniformLocation program arg) 1 #f (mat->f32vector val)))
    ;; buffers
    (for ([buf-info (in-list buffers)]
          [i (in-naturals)])
      (define-values (name buf size len) (apply values buf-info))
      (glEnableVertexAttribArray i)
      (glBindBuffer GL_ARRAY_BUFFER buf)
      (glVertexAttribPointer i size GL_FLOAT #f 0 0))
    ;; draw the first buffer named "vertices"
    (for/first ([buf-info (in-list buffers)]
                #:when (equal? (car buf-info) 'vertices))
      (define-values (name buf size len) (apply values buf-info))
      (glDrawArrays GL_TRIANGLES 0 len))
    ;; clean up
    (for ([_ (in-list buffers)]
          [i (in-naturals)])
      (glDisableVertexAttribArray i))))
