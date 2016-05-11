(setq default-input-method "MacOSX")
(set-language-environment 'Japanese)
(prefer-coding-system 'utf-8)
(package-initialize)
(setq init-loader-show-log-after-init 'error-only)
;; backup and auto-save-file
(setq backup-directory-alist
      (cons (cons ".*" (expand-file-name "~/.emacs.d/backup")) backup-directory-alist))
(setq auto-save-file-name-transforms
      (cons (cons ".*" (expand-file-name "~/.emacs.d/backup")) backup-directory-alist))
;; cask
;;(require 'cask "~/.emacs.d/.cask/cask.el")
(require 'cask)
(cask-initialize)
(pallet-mode t)

;; Color
;;(if window-system (progn
;;     (set-background-color "Black")
;;     (set-foreground-color "LightGray")
;;     (set-cursor-color "Gray")
;;     (set-frame-parameter nil 'alpha 70) ;透明度
;;     ))

;; init-loader
(require 'init-loader)
(init-loader-load "~/.emacs.d/inits")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; tab space
(global-whitespace-mode 1)
(setq whitespace-space-regexp "\\(\u3000\\)")
(setq whitespace-style '(face tabs tab-mark spaces space-mark))
(setq whitespace-display-mappings ())
(set-face-foreground 'whitespace-tab "yellow")
(set-face-underline  'whitespace-tab t)
(set-face-foreground 'whitespace-space "yellow")
(set-face-background 'whitespace-space "red")
(set-face-underline  'whitespace-space t)

;; click board
(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))

(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))

(setq interprogram-cut-function 'paste-to-osx)
(setq interprogram-paste-function 'copy-from-osx)
(put 'upcase-region 'disabled nil)

;; flymake
(require 'flymake)
;; undo-tree
(require 'undo-tree)
(global-undo-tree-mode)
;; neotree
(require 'neotree)
(global-set-key [f8] 'neotree-toggle)
;; menu-barの削除
(menu-bar-mode -1)
;; 行番号の表示
(global-linum-mode t)
(setq linum-format "%3d ")
(add-hook 'linum-mode-hook
          '(lambda ()
             (set-face-foreground 'linum "#FFFFFF")
             (set-face-background 'linum "#000000")))
