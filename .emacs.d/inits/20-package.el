;; Package
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/")) ;; MELPAを追加
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/")) ;; Marmaladeを追加
;;(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(package-initialize) ;; 初期化;