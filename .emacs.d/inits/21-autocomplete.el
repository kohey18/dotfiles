(require 'auto-complete)
(require 'auto-complete-config)
(setq ac-auto-start t)
(global-auto-complete-mode t)
(ac-config-default)
;; customize
(setq ac-auto-start 2)  ;; n文字以上の単語の時に補完を開始
(setq ac-delay 0.05)  ;; n秒後に補完開始
(setq ac-use-comphist t)  ;; 補完推測機能有効
(setq ac-auto-show-menu 0.05)  ;; n秒後に補完メニューを表示
(setq ac-quick-help-delay 0.5)  ;; n秒後にクイックヘルプを表示
(setq ac-ignore-case nil)  ;; 大文字・小文字を区別する
(setq ac-use-menu-map t) ;; C-n/C-pで補完候補を選択
(ac-set-trigger-key "TAB")
