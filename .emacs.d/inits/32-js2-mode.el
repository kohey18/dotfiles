(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(setq-default js2-basic-offset 2 tab-width 2 indent-tabs-mode nil)

(add-hook 'js2-mode-hook 'ac-js2-mode)
