(require 'powerline)
(powerline-default-theme)

(defconst color1 "#ff66ff")
(defconst color2 "#6699ff")
(defconst color3 "#696969")

(set-face-background 'modeline-buffer-id nil)

(set-face-attribute 'mode-line nil
                    :foreground "#fff"
                    :background color1
                    :box nil)

(set-face-attribute 'powerline-active1 nil
                    :foreground "#fff"
                    :background color2
                    :inherit 'mode-line)

(set-face-attribute 'powerline-active2 nil
                    :foreground "#fff"
                    :background color3
                    :inherit 'mode-line)
