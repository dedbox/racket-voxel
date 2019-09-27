#lang racket/base

(provide (all-defined-out))

(define-syntax-rule (define-block-types type-id ...)
  (begin (define type-id (string->unreadable-symbol (format "~a" 'type-id))) ...))

(define-block-types
  WHITE-BLOCK
    RED-BLOCK
  GREEN-BLOCK
   BLUE-BLOCK)

(struct block (type active?)
  #:transparent
  #:mutable
  #:name wv:block
  #:constructor-name make-block)

(define (block type #:active? [active? #t])
  (make-block type active?))
