(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(setq-default tab-width 4 indent-tabs-mode nil)

(add-hook 'js2-mode-hook 'ac-js2-mode)
