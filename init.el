(defvar *emacs-load-start* (float-time))

;; Set to `t' to debug problems loading init.el
(setq debug-on-error nil)


;;;; General options -----------------------------------------------------------

;; (global-unset-key (kbd "C-x c"))        ; let's not accidentally kill Emacs
;; (global-unset-key (kbd "C-t"))          ; transposing characters not useful
;; (global-unset-key (kbd "C-:"))          ; changing keywords into characters not useful

(global-set-key (kbd "C-c f") 'toggle-frame-fullscreen)

;; Allows us to use `case'
(require 'cl)

(set-language-environment "UTF-8")      ; default is "English"
(prefer-coding-system 'utf-8-unix)

(setq inhibit-startup-message t
      initial-scratch-message nil)

(setq-default indicate-empty-lines t
              show-trailing-whitespace t
              indent-tabs-mode nil
              tab-width 4
              require-final-newline t
              save-place t
              fill-column 80
              comment-column 40)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode t)
(line-number-mode t)
(global-linum-mode t)
(mouse-wheel-mode t)
(show-paren-mode t)
(savehist-mode t)                       ; save minibuffer history

(add-hook 'text-mode-hook 'visual-line-mode)

(setq mouse-yank-at-point t
      x-select-enable-clipboard t
      x-select-enable-primary t
      save-interprogram-paste-before-kill t
      echo-keystrokes 0.1
      vc-follow-symlinks t)

(add-to-list 'exec-path "/usr/local/bin")

;; Avoid trying to ping some machine in Hong Kong just because you typed
;; something.hk: https://github.com/technomancy/emacs-starter-kit/issues/39
(setq ffap-machine-p-known 'reject)

(defalias 'yes-or-no-p 'y-or-n-p)

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)

(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file)

;; Use Source Code Pro when available:
;; https://github.com/adobe-fonts/source-code-pro
(when (x-list-fonts "Source Code Pro Light")
  (set-default-font "Source Code Pro Light")
  (set-face-attribute 'default nil :height (case system-type
                                             (darwin     120)
                                             (windows-nt 120)
                                             (otherwise  100))))


;;;; Platform-specific customisations ------------------------------------------

;; magit needs to use PuTTY/Pageant for remotes which connect via SSH
(when (equal system-type 'windows-nt)
  (setenv "GIT_SSH" "C:\\Program Files (x86)\\PuTTY\\plink.exe"))





;;;; Auto-saves ----------------------------------------------------------------
(defvar --backup-directory (concat user-emacs-directory "backups"))
(if (not (file-exists-p --backup-directory))
    (make-directory --backup-directory t))
(setq make-backup-files t
      vc-make-backup-files t            ; backup version-controlled files too
      backup-by-copying t               ; copy to backups dir, don't rename
                                        ; avoids clobbering symlinks
      backup-directory-alist `(("." . ,--backup-directory))
      version-control t                 ; create multiple numbered backups
      delete-old-versions t
      kept-new-versions 6               ; keep the most recent 6
      kept-old-versions 2)              ; keep the original 2


;;;; Emacs 24 Package setup ----------------------------------------------------
(require 'package)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)


;;; (add-hook 'after-init-hook 'global-company-mode)

(setq magit-last-seen-setup-instructions "1.4.0")


;;;; Helm ----------------------------------------------------------------------

(require 'helm)
(require 'helm-config)

(global-set-key "\C-ch" 'helm-command-prefix)

(global-set-key "\M-x" 'helm-M-x)
(global-set-key "\M-y" 'helm-show-kill-ring)
(global-set-key "\C-xb" 'helm-mini)
(global-set-key "\C-x\C-f" 'helm-find-files)
(global-set-key "\C-cho" 'helm-occur)

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
(define-key helm-map "\C-i" 'helm-execute-persistent-action) ; make TAB work in the terminal
(define-key helm-map "\C-z" 'helm-select-action)

(add-hook 'shell-mode-hook
          #'(lambda ()
              (define-key shell-mode-map "\C-c\C-l" 'helm-comint-input-ring)))
(define-key minibuffer-local-map "\C-c\C-l" 'helm-minibuffer-history)

(setq helm-split-window-in-side-p           t ; open helm buffer in current window
      helm-move-to-line-cycle-in-source     t
      helm-ff-file-name-history-use-recentf t
      helm-M-x-fuzzy-match                  t
      helm-buffers-fuzzy-matching           t
      helm-recentf-fuzzy-match              t
      helm-apropos-fuzzy-match              t)

(helm-mode 1)

(require 'helm-descbinds)
(helm-descbinds-mode)


;;;; Projectile ----------------------------------------------------------------
(projectile-global-mode)
(setq projectile-completion-system 'helm)
(require 'helm-projectile)
; (helm-projectile-on)



;;;; Uniquify ------------------------------------------------------------------
(require 'uniquify)                     ; make buffer names unique
(setq uniquify-buffer-name-style 'reverse
      uniquify-after-kill-buffer-p t
      uniquify-ignore-buffers-re "^\\*") ; don't screw with special buffers


;;;; god-mode ------------------------------------------------------------------

(require 'god-mode)

(global-set-key (kbd "<escape>") 'god-mode-all) ; ESC toggles on/off god-mode
(define-key god-local-mode-map (kbd ".") 'repeat)
(define-key god-local-mode-map (kbd "z") 'other-window)


(setq god-exempt-major-modes nil)
(setq god-exempt-predicates nil) ; no buffers exempt

;;;; changecolors for god-mode ------------------------------------------------

(defun my-update-cursor ()
  (setq cursor-type (if (or god-local-mode buffer-read-only)
                        'box
                      'bar)))

(add-hook 'god-mode-enabled-hook 'my-update-cursor)
(add-hook 'god-mode-disabled-hook 'my-update-cursor)


;;;; Rainbow Delimiters --------------------------------------------------------

(require 'rainbow-delimiters)

(require 'cl-lib)

(require 'color)

(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

(cl-loop
 for index from 1 to rainbow-delimiters-max-face-count
 do
 (let ((face (intern (format "rainbow-delimiters-depth-%d-face" index))))
   (cl-callf color-saturate-name (face-foreground face) 30)))


;;;; larger fonts for Bryan
(defun global-text-scale-adjust (inc)
  (interactive)
  (text-scale-set 1)
  (kill-local-variable 'text-scale-mode-amount)
  (setq-default text-scale-mode-amount (+ text-scale-mode-amount inc))
  (global-text-scale-mode 1))

(defun big-er ()
  (interactive)
  (text-scale-set 1)
  (global-text-scale-adjust 1))

(defun lil-er ()
  (interactive)
  (text-scale-set 1)
  (global-text-scale-adjust -1))

;;;; Smartparens
(require 'smartparens-config)
(add-hook 'prog-mode-hook #'smartparens-mode)
(sp-local-pair 'clojure-mode "#{" "}")
(sp-local-pair 'clojure-mode "#(" ")")

;;;; Just CLJS Things

(defun init-figwheel-repl ()
  (interactive)
  (insert
   ";; Hit enter to start the figwheel repl.
(do (require 'figwheel-sidecar.repl-api)
    (figwheel-sidecar.repl-api/cljs-repl))"))

;;;; Keybindings ---------------------------------------------------------------

;; 'C-h C' describes coding system
(global-set-key "\C-cC" 'set-buffer-file-coding-system)


;; use C-w to delete back a word to match the shortcut in the shell
;; Rebind kill-region (normally C-w) to C-x C-k
; (global-set-key "\C-w" 'backward-kill-word)
; (global-set-key "\C-x\C-k" 'kill-region)

(global-set-key "\C-cb" 'bury-buffer)

;; searches might as well be regexps

(global-set-key "\C-s" 'isearch-forward-regexp)
(global-set-key "\C-r" 'isearch-backward-regexp)

(global-set-key "\M-/" 'company-complete)

(global-set-key "\C-m" 'newline-and-indent)

(global-set-key "\C-xw" 'delete-trailing-whitespace)

(global-set-key "\C-x|" 'align-regexp)

(global-set-key "\C-cg" 'magit-status)
(global-set-key "\C-cG" 'vc-git-grep)



;;;; Registers -----------------------------------------------------------------
;; usage:  C-x r j <register-identifier>  ('register jump')
;; from http://www.emacswiki.org/cgi-bin/wiki/EmacsNiftyTricks
(set-register ?i `(file . ,(concat user-emacs-directory "init.el")))
(set-register ?c `(file . ,(concat user-emacs-directory "cheat-sheet.txt")))
(set-register ?t '(file . "~/todo.txt"))


;;;; Emacsclient ---------------------------------------------------------------
(require 'server)
(unless (server-running-p)
  (add-hook 'after-init-hook 'server-start))


;;;; Themes --------------------------------------------------------------------
(with-demoted-errors
  (load-theme 'junio))



(require 'whitespace)
(setq whitespace-line-column 100)
(setq whitespace-style '(face lines-tail))

(add-hook 'prog-mode-hook 'whitespace-mode)


(message "init.el loaded in %fs" (- (float-time) *emacs-load-start*))
