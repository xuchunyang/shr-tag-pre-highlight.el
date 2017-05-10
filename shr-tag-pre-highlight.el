;;; shr-tag-pre-highlight.el --- Syntax highlighting code block in HTML -*- lexical-binding: t; -*-

;; Copyright (C) 2017  Chunyang Xu

;; Author: Chunyang Xu <mail@xuchunyang.me>
;; Package-Requires: ((emacs "24"))
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
;; HTML, rendered by `shr.el'. The probably most famous user of
;; `shr.el' is (info "(emacs) EWW")

;; Usage:
;;
;; Add the following lines to a suitable init file:
;;
;; (with-eval-after-load 'shr
;;   (add-to-list 'shr-external-rendering-functions
;;                '(pre . shr-tag-pre-highlight)))

;;; Code:

(require 'shr)

(defun shr-tag-pre-highlight (dom)
  (let ((shr-folding-mode 'none)
        (shr-current-font 'default))
    (shr-ensure-newline)
    (insert
     ;; TODO: Don't assume Emacs Lisp, guess Programming Language
     (shr-tag-pre-highlight-fontify
      (with-temp-buffer
        (shr-generic dom)
        (buffer-string))
      'emacs-lisp-mode))
    (shr-ensure-newline)))

(defun shr-tag-pre-highlight-fontify (string mode)
  "Fontify STRING with major-mode MODE."
  (with-temp-buffer
    (insert string)
    (delay-mode-hooks (funcall mode))
    (if (fboundp 'font-lock-ensure)
        (font-lock-ensure)
      (with-no-warnings
        (font-lock-fontify-buffer)))
    (buffer-string)))

(provide 'shr-tag-pre-highlight)
;;; shr-tag-pre-highlight.el ends here
