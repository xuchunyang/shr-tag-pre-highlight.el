;;; shr-tag-pre-highlight.el --- Syntax highlighting code block in HTML -*- lexical-binding: t; -*-

;; Copyright (C) 2017  Chunyang Xu

;; Author: Chunyang Xu <mail@xuchunyang.me>
;; Package-Requires: ((emacs "24") (language-detection "0.1.0"))
;; Keywords: html
;; Version: 0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package adds syntax highlighting support for code block in
;; HTML, rendered by `shr.el'.  The probably most famous user of
;; `shr.el' is EWW (the Emacs Web Wowser).

;; Installation:
;;
;; Place this package somewhere in Emacs `load-path' and add the
;; following lines to a suitable init file:
;;
;; (autoload 'shr-tag-pre-highlight "shr-tag-pre-highlight")
;; (with-eval-after-load 'shr
;;   (add-to-list 'shr-external-rendering-functions
;;                '(pre . shr-tag-pre-highlight)))
;;
;; If you use `use-package' to manage your init file, you can use
;; something like this:
;;
;; (use-package shr-tag-pre-highlight
;;   :load-path "~/src/shr-tag-pre-highlight.el"
;;   :after shr
;;   :config
;;   (add-to-list 'shr-external-rendering-functions
;;                '(pre . shr-tag-pre-highlight)))

;; Warning:
;;
;; Unfortunately, EWW always overrides
;; `shr-external-rendering-functions' until
;; [this commit](http://git.savannah.gnu.org/cgit/emacs.git/commit/?id=45ebbc0301c8514a5f3215f45981c787cb26f915)
;; (2015-12), but Emacs 25.2 (latest release - 2017-4) doesn't include
;; this commit.  Thus you have to use devel version of Emacs if you
;; want syntax highlighting in EWW.

;;; Code:

(require 'shr)
(require 'dom)
(require 'language-detection)

(defvar shr-tag-pre-highlight-lang-modes
  '(("ocaml" . tuareg) ("elisp" . emacs-lisp) ("ditaa" . artist)
    ("asymptote" . asy) ("dot" . fundamental) ("sqlite" . sql)
    ("calc" . fundamental) ("C" . c) ("cpp" . c++) ("C++" . c++)
    ("screen" . shell-script) ("shell" . sh) ("bash" . sh)
    ;; Used by language-detection.el
    ("emacslisp" . emacs-lisp))
  "Adapted from `org-src-lang-modes'.")

(defun shr-tag-pre-highlight--get-lang-mode (lang)
  "Return major mode that should be used for LANG.
LANG is a string, and the returned major mode is a symbol.

Adapted from `org-src--get-lang-mode'."
  (intern
   (concat
    (let ((l (or (cdr (assoc lang shr-tag-pre-highlight-lang-modes)) lang)))
      (if (symbolp l) (symbol-name l) l))
    "-mode")))

(defun shr-tag-pre-highlight--match (regexp n-group string)
  (when (string-match regexp string)
    (match-string n-group string)))

(defun shr-tag-pre-highlight-guess-language-attr (pre)
  "Guess programming language base on the attributes of PRE."
  (let* ((pre-class (dom-attr pre 'class))
         (pre-attrs (dom-attributes pre))
         (code (car (dom-by-tag pre 'code)))
         (code-class (dom-attr code 'class))
         (code-attrs (dom-attributes code))
         lang)
    (cond
     ;; <pre class="src src-C"> (Org mode)
     ;; <pre class="brush: js"> (http://alexgorbatchev.com/SyntaxHighlighter)
     ;; <pre class="sh_cpp"> (http://shjs.sourceforge.net/)
     ((and pre-class
           (setq lang (shr-tag-pre-highlight--match
                       "\\(?:src src-\\|brush: \\|sh_\\)\\([-+a-zA-Z0-9]+\\)" 1 pre-class))))
     ;; <pre><code data-language="python" class="rainbow"> (https://craig.is/making/rainbows)
     ((and code
           (setq lang (dom-attr code 'data-language))))
     ;; <pre><code class="hljs clojure"> (https://highlightjs.org)
     ;; <pre><code class="lang-csharp">
     ;; <pre><code class="language-pascal">
     ((and code-class
           (setq lang (shr-tag-pre-highlight--match
                       "\\(?:hljs \\|lang-\\|language-\\)\\([-+a-zA-Z0-9]+\\)" 1 code-class)))))
    (setq lang (and lang (downcase lang)))
    (cond ((equal "auto" lang) nil)
          (lang lang)
          ;; XXX Provide a generic fallback?
          ((or (string-match "elisp" (format "%s" pre-attrs))
               (string-match "elisp" (format "%s" code-attrs)))
           "elisp")
          ((or (string-match "lisp" (format "%s" pre-attrs))
               (string-match "lisp" (format "%s" code-attrs)))
           "lisp")
          ((or (string-match "python" (format "%s" pre-attrs))
               (string-match "python" (format "%s" code-attrs)))
           "python")
          ((or (string-match "ruby" (format "%s" pre-attrs))
               (string-match "ruby" (format "%s" code-attrs)))
           "ruby")
          (t nil))))

(defun shr-tag-pre-highlight-fontify (code mode)
  "Fontify CODE with Major MODE."
  (with-temp-buffer
    (insert code)
    (delay-mode-hooks (funcall mode))
    (if (fboundp 'font-lock-ensure)
        (font-lock-ensure)
      (with-no-warnings
        (font-lock-fontify-buffer)))
    (buffer-string)))

(defun shr-tag-pre-highlight (pre)
  "Highlighting code in PRE."
  (let* ((shr-folding-mode 'none)
         (shr-current-font 'default)
         (code (with-temp-buffer
                 (shr-generic pre)
                 (buffer-string)))
         (lang (or (shr-tag-pre-highlight-guess-language-attr pre)
                   (language-detection-string code)))
         (mode (and lang
                    (shr-tag-pre-highlight--get-lang-mode lang))))
    (shr-ensure-newline)
    (insert
     (if (fboundp mode)
         (shr-tag-pre-highlight-fontify code mode)
       code))
    (shr-ensure-newline)))

(provide 'shr-tag-pre-highlight)
;;; shr-tag-pre-highlight.el ends here
