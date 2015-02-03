(setq default-input-method "MacOSX")
(set-language-environment 'Japanese)
(prefer-coding-system 'utf-8)

(package-initialize)
(setq init-loader-show-log-after-init 'error-only)
;; backupファイル格納場所
(setq backup-directory-alist
      (cons (cons ".*" (expand-file-name "~/.emacs.d/backup"))
	            backup-directory-alist))
;; cask
(require 'cask "~/.emacs.d/.cask/cask.el")
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
