;;; init.el --- My emacs config -*- coding: utf-8; lexical-binding: t; -*-

;; Garbage collection
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)

(defvar startup/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(defun startup/revert-file-name-handler-alist ()
  (setq file-name-handler-alist startup/file-name-handler-alist))

(defun startup/reset-gc ()
  (setq gc-cons-threshold 16777216
	gc-cons-percentage 0.1))

(add-hook 'emacs-startup-hook 'startup/revert-file-name-handler-alist)
(add-hook 'emacs-startup-hook 'startup/reset-gc)

;; Avoid outdated bytecode
(setq load-prefer-newer t)

;; Disable legacy algorithms like 3DES
(setq gnutls-min-prime-bits 2048)
(setq gnutls-algorithm-priority "SECURE128")

;; Fix scratch
(setq initial-scratch-message "")
(setq initial-major-mode 'emacs-lisp-mode)

;; MELPA
(require 'package)
(setq package-archives '(("ELPA"  . "http://tromey.com/elpa/")
			 ("gnu"   . "http://elpa.gnu.org/packages/")
			 ("melpa" . "https://melpa.org/packages/")
			 ("org"   . "https://orgmode.org/elpa/")))
(package-initialize)

;; Get use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Move custom-set-variables out
(setq custom-file "~/.emacs.d/custom.el")

;; Theme
;; Now upstream in emacs 28
(use-package gruvbox-theme
  :ensure t
  :init
  (add-hook 'after-init-hook
          (lambda () (load-theme 'gruvbox t))))

;; Set Font
(when (member "Terminus" (font-family-list))
  (set-frame-font "Terminus-18" t t))

;; Eshell and sudo config
;;(require 'esh-module)
;;(add-to-list 'eshell-modules-list 'eshell-tramp)

;; Diminish
(use-package diminish
  :ensure t)

;; Evil mode
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1))
;; Choose default states for Evil mode
(setq evil-default-state 'emacs
      evil-emacs-state-modes nil
      evil-insert-state-modes nil
      evil-motion-state-modes nil
      evil-normal-state-modes '(text-mode prog-mode fundamental-mode
                                          css-mode conf-mode
                                          TeX-mode LaTeX-mode
                                          diff-mode))
(add-hook 'org-capture-mode-hook 'evil-insert-state)
(add-hook 'with-editor-mode-hook 'evil-insert-state)
(add-hook 'view-mode-hook 'evil-emacs-state)
;; Make cursor movement feel better
(setq evil-cross-lines t
      evil-move-beyond-eol t
      evil-want-fine-undo t
      evil-symbol-word-search t)

;; Fix C-w for insert state
(with-eval-after-load 'evil-maps
  (define-key evil-insert-state-map (kbd "C-w") 'evil-window-map))

;; Switch-Window
(use-package switch-window
  :ensure t
  :config
  (setq switch-window-input-style 'minibuffer)
  (setq switch-window-increase 4)
  (setq switch-window-threshold 2)
  (setq switch-window-shortcut-style 'qwerty)
  (setq switch-window-qwerty-shortcuts
        '("a" "r" "s" "t" "n" "e" "i" "o"))
  :bind
  ([remap other-window] . switch-window))

;; Window splitting functions to balance
(defun split-and-follow-horizontally ()
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))
(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))
(defun delete-and-balance-window ()
  (interactive)
  (delete-window)
  (balance-windows))
(global-set-key (kbd "C-1") 'delete-other-windows)
(global-set-key (kbd "C-2") 'split-and-follow-horizontally)
(global-set-key (kbd "C-3") 'split-and-follow-vertically)
(global-set-key (kbd "C-0") 'delete-and-balance-window)

;; Avy
(use-package avy
  :ensure t
  :config
  ;; Fix homerow for Colemak Mod-DHm
  (setq avy-keys '(?a ?r ?s ?t ?n ?e ?i ?o ?g ?m))
  :bind
  ("C-;" . avy-goto-word-0))

;; Matching parantheses
(use-package rainbow-delimiters
  :ensure t
  :init
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

;; Fix Emacs looks
(line-number-mode 1)
(column-number-mode 1)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(fringe-mode 1)
(setq ring-bell-function 'ignore)
(setq scroll-conservatively 100)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-message t)
(setq inhibit-startup-screen t)
(when window-system (add-hook 'prog-mode-hook 'hl-line-mode))
(when window-system (global-prettify-symbols-mode t))

;; y-or-n
(defalias 'yes-or-no-p 'y-or-n-p)

;; No backups
(setq make-backup-files nil)
(setq auto-save-default nil)

;; UTF-8
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Indenting
(use-package aggressive-indent
  :ensure t)

;; Electric Pairs
(setq electric-pair-pairs
      '(
        (?\( . ?\))
        (?\[ . ?\])
        (?\{ . ?\})))
(electric-pair-mode 1)

;; Sudo editing
(use-package sudo-edit
  :ensure t
  :bind
  ("s-e" . sudo-edit))

;; default to /bin/bash
(defvar my-term-shell "/bin/bash")
(defadvice ansi-term (before force-bash)
  (interactive (list my-term-shell)))
(ad-activate 'ansi-term)
(setq ad-redefinition-action 'accept)

;; which-key
(use-package which-key
  :ensure t
  :init
  (which-key-mode)
  :diminish which-key-mode)

;; company
(use-package company
  :ensure t
  :init
  (add-hook 'after-init-hook 'global-company-mode)
  :diminish company-mode)

;; Counsel, Swiper
(use-package counsel
  :ensure t
  :init
  (counsel-mode 1)
  :diminish
  (counsel-mode)
  :bind
  ("M-x" . counsel-M-x)
  ("C-x C-f" . counsel-find-file)
  ("M-y" . counsel-yank-pop)
  ("<f1> f" . counsel-describe-function)
  ("<f1> v" . counsel-describe-variable)
  ("<f1> l" . counsel-find-library)
  ("<f2> i" . counsel-info-lookup-symbol)
  ("<f2> u" . counsel-unicode-char)
  ("<f2> j" . counsel-set-variable)
  ("C-s" . swiper-isearch))
;; Ivy
(use-package ivy
  :ensure t
  :init
  (ivy-mode 1)
  :config
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  :diminish
  (ivy-mode)
  :bind
  ("C-x b" . ivy-switch-buffer)
  ("C-c v" . ivy-push-view)
  ("C-c V" . ivy-pop-view)
  ("C-c C-r" . ivy-resume))

;; Org
(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode))))
;; Same Window for org
(setq org-src-window-setup 'current-window)

;; Dired
;; Async
(use-package async
  :ensure t
  :diminish dired-async-mode
  :init
  (dired-async-mode 1))
;; Prevent many buffers
(put 'dired-find-alternate-file 'disabled nil)
(define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)
(define-key dired-mode-map (kbd "^") (lambda () (interactive) (find-alternate-file "..")))
;; Subtree
(use-package dired-subtree
  :ensure t
  :bind
  (:map dired-mode-map
        ("<tab>" . dired-subtree-toggle)
        ("<S-iso-lefttab>" . dired-subtree-cycle)))

;; Vterm
(use-package vterm
  :ensure t)

;; magit
(use-package magit
  :ensure t
  :config
  (setq git-commit-summary-max-length 50))

;; erc
;; Handle clutter / set name
(setq erc-nick "nosolls")
(setq erc-prompt (lambda () (concat "[" (buffer-name) "]")))
(setq erc-hide-list '("JOIN" "PART" "QUIT"))
;; server list
(setq erc-server-history-list '("irc.libera.chat"
                                "localhost"))
;; Highlight nicknames
(use-package erc-hl-nicks
  :ensure t
  :config
  (erc-update-modules))

;; PDF-tools
(use-package pdf-tools
   :ensure t
   :config
   (pdf-tools-install)
   (setq-default pdf-view-display-size 'fit-page))

;; Config handling
;; Edit config
(defun config-visit ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))
(global-set-key (kbd "C-c e") 'config-visit)
;; Reload config
(defun config-reload ()
  (interactive)
  (load-file "~/.emacs.d/init.el"))
(global-set-key (kbd "C-c r") 'config-reload)

;; Always kill buffer
(defun kill-current-buffer ()
  "Kills the current buffer."
  (interactive)
  (kill-buffer (current-buffer)))
(global-set-key (kbd "C-x k") 'kill-current-buffer)
