;; lsdyna.el -- LS-DYNA mode
;;; Commentary:
;;; A mode for LS-DYNA keyword files.
;;; ______
;;;|
;;;| TailSiT GmbH
;;;| Graz, Austria
;;;  www.tailsit.com
;;;
;;;
;;;@file      
;;;@author    Lars Kielhorn, Thomas Rüberg, Jürgen Zechner
;;;@date      2023
;;;@copyright <a href="https://www.tailsit.com" >TAILSIT GmbH</a>

;;; Regular expressions defining the mode
(defvar lsdyna-mode-regex
  '(
    ("\$-.*$" . font-lock-comment-delimiter-face)   
    ("\$.*$" . font-lock-comment-face)   
    ("\*.*$" . font-lock-keyword-face) ; *KEYWORD
    ("\\(&[^[:space:]]*\\)\\($\\|\\s-\\)" 1 font-lock-variable-name-face)
    ("^\\([RI]\\)\\(\\(.\\{9\\}\\).*\\)$" (1 font-lock-constant-face) (3 font-lock-variable-name-face)) ; R or I and highlight from the 10th character onwards
    ("^\\s-*\\*INCLUDE\\s-+\\(.+\\)$" 1 font-lock-preprocessor-face)
    ("^\\s-*\\*TITLE\\s-+\\(.+\\)$" 1 font-lock-string-face)    
    ("^\\s-*\\*SET_NODE_LIST_TITLE\\s-+\\(.+\\)$" 1 font-lock-string-face)
    ("\\b<MECH\\b>" . font-lock-keyword-face)
    ("\\b<BONDED\\b>" . font-lock-keyword-face)
    )
  "Keyword- and function identifier for the LS-DYNA mode.")

(defface lsdyna-mode-keyword-face-bold
  '((t :inherit font-lock-keyword-face :slant italic))
  "Face for keyword, with bold weight"
  :group 'lsdyna-mode-faces)

(defvar lsdyna-indent-amount 0
  "Number of columns to insert for each indentation level in LS-DYNA mode.")

(defvar lsdyna-indent-relative-blocks nil
  "List of block statement descriptions recognized.")

(defvar lsdyna-font-lock-defaults
  `(lsdyna-mode-regex nil)) ;; t=case sensitive, nil=insensitive

(defvar lsdyna-comment-char "$"
  "Comment character fo LS-DYNA mode" )

(make-variable-buffer-local 'lsdyna-indent-relative-blocks)

(define-derived-mode lsdyna-mode prog-mode "lsdyna"
  "Major mode for editing LS-DYNA keyword files."
  (lsdyna-common-settings)
  (font-lock-mode 1)
  (set-syntax-table lsdyna-mode-syntax-table)
  (setq-local comment-start lsdyna-comment-char)
  (setq-local comment-start-skip (concat lsdyna-comment-char "+\\s-*"))
  (setq-local comment-use-syntax t)
  (setq-local comment-padding " ")
)

(defun lsdyna-common-settings ()
  "Common settings for LS-DYNA."
  (setq font-lock-defaults lsdyna-font-lock-defaults)
  (setq indent-tabs-mode nil)
  (setq paragraph-start "*" ) ;;; navigation between keywords
  (setq paragraph-separate "\n") ;;; navigation between keywords
  (setq whitespace-style '(face empty tabs lines-tail trailing))
  )

;;; 
(if (version-list-< (version-to-list emacs-version) '(24 0))
    (defadvice regexp-opt (after symbols activate)
      (if (eq paren 'symbols)
	  (setq ad-return-value (concat "\\_<" ad-return-value "\\_>")))))

;;; Rulers
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar lsdyna-ruler-8 "\n$--------1---------2---------3---------4---------5---------6---------7---------8"
  "*LS-DYNA default ruler with 8 columns."
)

(defvar lsdyna-ruler-10 "\n$------1-------2-------3-------4-------5-------6-------7-------8-------9------10"
  "*LS-DYNA default ruler with 10 columns."
)

;;; Insertion routines
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun lsdyna-insert-ruler-8 ()
  "Insert LS-DYNA default ruler."
  (interactive)
  (end-of-line)
  (insert lsdyna-ruler-8)
  )

(defun lsdyna-insert-ruler-10 ()
  "Insert LS-DYNA mesh ruler."
  (interactive)
  (end-of-line)
  (insert lsdyna-ruler-10)
  )

(easy-menu-define nil lsdyna-mode-map
  "Menu for LS-DYNA"
  '("LS-DYNA"
    ["Insert ruler (8 columns)" lsdyna-insert-ruler-8 t]
    ["Insert ruler (10 columns)" lsdyna-insert-ruler-10 t]
    )
  )

;;; Help from other modes
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (require 'display-fill-column-indicator nil 'noerror)
  (with-eval-after-load 'display-fill-column-indicator
    (defun lsdyna-mode-fill-column ()
      "Customize display-fill-column-indicator for LS-DYNA mode."
      (display-fill-column-indicator-mode)
      (setq display-fill-column-indicator-column 80))
    
    (add-hook 'lsdyna-mode-hook 'lsdyna-mode-fill-column )
    )
  )

(provide 'lsdyna-mode)
(add-to-list 'auto-mode-alist '("\\.k\\'" . lsdyna-mode))

;;; lsdyna.el ends here
