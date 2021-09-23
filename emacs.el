(require 'package)

;; optional. makes unpure packages archives unavailable
(setq package-archives nil)

(setq package-enable-at-startup nil)
(package-initialize)

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)

(setq
   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.saves/"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)       ; use versioned backups

;; This is only needed once, near the top of the file
(eval-when-compile
  ;; Following line is not needed if use-package.el is in ~/.emacs.d
  (require 'use-package))

(use-package telega)

(use-package fira-code-mode
  :hook prog-mode
  :config
  (fira-code-mode-set-font))

(use-package undo-tree
  :config (global-undo-tree-mode))

(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
	 ("C->" . mc/mark-next-like-this)
	 ("C-<" . mc/mark-previous-like-this)
	 ("C-c C-<" . mc/mark-all-like-this)))

(use-package ivy
  :config
  (ivy-mode)
  :custom
  (ivy-use-virtual-buffers t)
  (enable-recursive-minibuffers t))


(use-package counsel
  :config (counsel-mode)
  :bind (("M-g a". counsel-ag)))

(use-package swiper
  :config (counsel-mode))

(use-package avy
  :bind (("M-s" . avy-goto-word-1)))

(defun svrg/load-theme-hook (frame)
  (select-frame frame)
  (load-theme 'nord t))

(use-package zerodark
  :no-require t
  :config (if (daemonp)
	      (add-hook 'after-make-frame-functions #'svrg/load-theme-hook)
	    (load-theme 'nord t)))

(use-package json-mode)

(use-package which-key
  :config
  (which-key-mode)
  (which-key-setup-side-window-right))

(use-package go-mode)

(defvar-local svrg/lsp-enabled nil)

(defun svrg/maybe-start-lsp ()
  (if svrg/lsp-enabled
      (lsp)))

(defun svrg/enable-lsp ()
  (setq-local svrg/lsp-enabled t))

(setenv "PATH"
	(concat "@cmakeLanguageServer@/bin" ":"
		(getenv "PATH")))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((envrc-mode . svrg/maybe-start-lsp)
	 (nix-mode . svrg/enable-lsp)
	 (cmake-mode . svrg/enable-lsp)
	 (c++-mode . svrg/enable-lsp)
	 (yaml-mode . svrg/enable-lsp)
	 (go-mode . svrg/enable-lsp)
         (sh-mode . svrg/enable-lsp)
         (json-mode . svrg/enable-lsp)
	 (sql-mode . svrg/enable-lsp)
         (lsp-mode . lsp-enable-which-key-integration)
	 (lsp-mode . lsp-ui-mode))
  :commands lsp
  :custom
  (lsp-gopls-server-path "@gopls@/bin/gopls")
  (lsp-nix-server-path "@rnixLsp@/bin/rnix-lsp")
  (lsp-yaml-server-command '("@yamlLanguageServer@/bin/yaml-language-server" "--stdio"))
  (lsp-eldoc-render-all t)
  (lsp-idle-delay 0.6)
  (lsp-rust-analyzer-server-display-inlay-hints t))

(use-package lsp-rust
  :custom
  ;; what to use when checking on-save. "check" is default, I prefer clippy
  (lsp-rust-analyzer-cargo-watch-command "@clippy@/bin/cargo-clippy"))

(use-package plantuml-mode
  :custom
  (plantuml-executable-path "@plantuml@/bin/plantuml")
  (plantuml-default-exec-mode 'executable))


(use-package lsp-metals
  :hook (scala-mode . lsp)
  :custom
  (lsp-metals-server-command "@metalsServer@/bin/metals"))

(use-package envrc
  :config
  (envrc-global-mode))

(use-package lsp-bash
  :config
  (lsp-dependency 'bash-language-server '(:system "@bashLanguageServer@/bin/bash-language-server")))

(use-package lsp-json
  :config
  (lsp-dependency 'vscode-json-languageserver '(:system "@vscodeJsonLanguageserverBin@/bin/json-languageserver")))

(use-package lsp-jedi
  :hook (python-mode . (lambda ()
                         (require 'lsp-jedi)
                         (lsp)))
  :config
  (with-eval-after-load "lsp-mode"
    (add-to-list 'lsp-disabled-clients 'pyls))
  :init
  (setq lsp-jedi-executable-command "@jediLanguageServer@/bin/jedi-language-server"))


(use-package lsp-sqls
  :custom
  (lsp-sqls-server "@sqlsServer@/bin/sqls")
  (lsp-sqls-connections
   '(
     ((driver . "mysql") (dataSourceName . "hiqprimary_auto@tcp(default.minikube.local)"))
     )
   ))


(use-package python-black
  :after python
  :hook (python-mode . python-black-on-save-mode-enable-dwim))

(use-package lsp-ui
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable nil))
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

(use-package projectile
  :config
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map))

(use-package yasnippet
  :config
  (yas-global-mode))

(use-package rustic
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status))
  :custom
  (rustic-analyzer-command '("@rustAnalyzer@/bin/rust-analyzer"))
  :config
  ;; uncomment for less flashiness
  ;; (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-signature-auto-activate nil)

  ;; comment to disable rustfmt on save
  (setq rustic-format-on-save t)
  (add-hook 'rustic-mode-hook 'svrg/rustic-mode-hook))

(defun svrg/rustic-mode-hook ()
  ;; so that run C-c C-c C-r works without having to confirm, but don't try to
  ;; save rust buffers that are not file visiting. Once
  ;; https://github.com/brotzeit/rustic/issues/253 has been resolved this should
  ;; no longer be necessary.
  (when buffer-file-name
    (setq-local buffer-save-without-query t)))
