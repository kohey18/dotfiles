(autoload 'ruby-mode "ruby-mode"
  "Mode for editing ruby source files" t)
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))

;; --------------------------------------------------
;; ruby-end
;; endや括弧などを自動挿入する
;; --------------------------------------------------
(require 'ruby-end)
(add-hook 'ruby-mode-hook
          '(lambda ()
             (robe-mode t)
             (abbrev-mode 1)
             (electric-pair-mode t)
             (electric-indent-mode t)
             (electric-layout-mode t)))


;; --------------------------------------------------
;; ruby-block
;; endにカーソルを合わせると、そのendに対応する行をハイライトする
;; --------------------------------------------------
(require 'ruby-block)
(ruby-block-mode t)
(setq ruby-block-highlight-toggle t)
(setq ruby-insert-encoding-magic-comment nil)
