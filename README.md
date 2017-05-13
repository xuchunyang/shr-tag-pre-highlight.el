# shr-tag-pre-highlight - Syntax highlighting code block in HTML

*Author:* Chunyang Xu <mail@xuchunyang.me><br>
*Version:* 0<br>

This package adds syntax highlighting support for code block in
HTML, rendered by `shr.el`.  The probably most famous user of
`shr.el` is EWW (the Emacs Web Wowser).

## Installation

Place this package somewhere in Emacs `load-path` and add the
following lines to a suitable init file:

    (autoload 'shr-tag-pre-highlight "shr-tag-pre-highlight")
    (with-eval-after-load 'shr
      (add-to-list 'shr-external-rendering-functions
                   '(pre . shr-tag-pre-highlight)))

If you use `use-package` to manage your init file, you can use
something like this:

    (use-package shr-tag-pre-highlight
      :load-path "~/src/shr-tag-pre-highlight.el"
      :after shr
      :config
      (add-to-list 'shr-external-rendering-functions
                   '(pre . shr-tag-pre-highlight)))

## Warning

Unfortunately, EWW always overrides
`shr-external-rendering-functions` until
[this commit](http://git.savannah.gnu.org/cgit/emacs.git/commit/?id=45ebbc0301c8514a5f3215f45981c787cb26f915)
(2015-12), but Emacs 25.2 (latest release - 2017-4) doesn't include
this commit.  Thus you have to use devel version of Emacs if you
want syntax highlighting in EWW.


---
Converted from `shr-tag-pre-highlight.el` by [*el2markdown*](https://github.com/Lindydancer/el2markdown).
