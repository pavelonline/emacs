(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)

(add-to-list 'default-frame-alist
             '(font . "JetBrainsMono Nerd Font Mono-12"))

(setq
   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.saves/"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)       ; use versioned backups

(use-package kubernetes
  :ensure t
  :commands (kubernetes-overview))

(use-package fira-code-mode
  :ensure t
  :hook prog-mode
  :config
  (fira-code-mode-set-font))

(use-package undo-tree
  :ensure t
  :config (global-undo-tree-mode))

;; (use-package flymake-grammarly
;;   :hook ((text-mode . flymake-grammarly-load)
;; 	 (latex-mode . flymake-grammarly-load)
;; 	 (org-mode . flymake-grammarly-load)
;; 	 (markdown-mode . flymake-grammarly-load)))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
	 ("C->" . mc/mark-next-like-this)
	 ("C-<" . mc/mark-previous-like-this)
	 ("C-c C-<" . mc/mark-all-like-this)))

(use-package ivy
  :ensure t
  :config
  (ivy-mode)
  :custom
  (ivy-use-virtual-buffers t)
  (enable-recursive-minibuffers t))


(use-package dap-mode
  :ensure t
  :config
  (dap-mode 1)
  (dap-ui-mode 1)
  (dap-tooltip-mode 1)
  (dap-ui-controls-mode 1)
  (require 'dap-lldb)
  :custom
  (dap-lldb-debug-program "lldb-vscode")
  )

(use-package counsel
  :ensure t
  :config (counsel-mode)
  :bind (("M-g a". counsel-ag)))

(use-package swiper
  :ensure t
  :config (counsel-mode))

(use-package avy
  :ensure t
  :bind (("M-s" . avy-goto-word-1)))

(defun svrg/load-theme-hook (frame)
  (select-frame frame)
  (load-theme 'nord t))

(use-package nord-theme
  :ensure t
  :no-require t
  :config (if (daemonp)
	      (add-hook 'after-make-frame-functions #'svrg/load-theme-hook)
	    (load-theme 'nord t)))

(use-package magit
  :ensure t)

(use-package json-mode
  :ensure t)

(use-package which-key
  :ensure t
  :config
  (which-key-mode)
  (which-key-setup-side-window-right))

(defvar-local svrg/lsp-enabled nil)

(defun svrg/maybe-start-lsp ()
  (if svrg/lsp-enabled
      (lsp)))

(defun svrg/enable-lsp ()
  (setq-local svrg/lsp-enabled t))

;; (setenv "PATH"
;; 	(concat "@cmakeLanguageServer@/bin" ":"
;; 		(getenv "PATH")))

(defcustom svrg/project-build-dirs ()
  "Relations between source and build directories"
  :type '(alist :key-type directory :value-type directory)
  :group 'svrg)

(defun svrg/build-directory ()
  (if (projectile-project-p)
      (let ((root (projectile-project-root)))
	(alist-get (projectile-project-root) svrg/project-build-dirs nil nil 'equal))
    (error "Not a projectile project")))

(defun svrg/compile-commands-json ()
  (let ((build-dir (svrg/build-directory)))
    (if build-dir
	(let ((json-file (concat build-dir "compile_commands.json")))
	  (with-temp-buffer
	    (insert-file-contents json-file)
	    (json-parse-buffer)))
      (error "Could not find build directory"))))

(defun svrg/ccj-find-current ()
  (let ((json (svrg/compile-commands-json))
	(fname (buffer-file-name)))
    (seq-find (lambda (ccjs-item)
		(equal (gethash "file" ccjs-item) fname))
	      json)))


(defun svrg/compile-file ()
  (interactive)
  (let ((ccj-item (svrg/ccj-find-current)))
    (let ((default-directory (gethash "directory" ccj-item)))
      (compile (gethash "command" ccj-item)))))


(defun svrg/lsp-format-paragraph ()
  (interactive)
  (save-mark-and-excursion
    (mark-paragraph)
    (lsp-format-region (region-beginning) (region-end))))


(define-key c++-mode-map (kbd "C-M-p p c") 'svrg/compile-file)
(define-key c++-mode-map (kbd "TAB") 'svrg/lsp-format-paragraph)

(use-package company
  :ensure t
  :init
  (add-hook 'after-init-hook 'global-company-mode))

(use-package cmake-mode
  :ensure t)

(use-package nix-mode
  :ensure t)

(use-package terraform-mode
  :ensure t)

(use-package lsp-mode
  :ensure t
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
	 (python-mode . svrg/enable-lsp)
	 (terraform-mode . svrg/enable-lsp)
         (lsp-mode . lsp-enable-which-key-integration)
	 (lsp-mode . lsp-ui-mode))
  :commands lsp
  :custom
  ;; (lsp-gopls-server-path "@gopls@/bin/gopls")
  ;; (lsp-nix-server-path "@rnixLsp@/bin/rnix-lsp")
  (lsp-eldoc-render-all t)
  (lsp-idle-delay 0.6)
  (lsp-rust-analyzer-server-display-inlay-hints t)
  (lsp-modeline-code-actions-mode t)
  (lsp-enable-on-type-formatting t)
  )

;; (use-package lsp-rust
;;   :custom
;;   ;; what to use when checking on-save. "check" is default, I prefer clippy
;;   (lsp-rust-analyzer-cargo-watch-command "@clippy@/bin/cargo-clippy"))

;; (use-package plantuml-mode
;;   :custom
;;   (plantuml-executable-path "@plantuml@/bin/plantuml")
;;   (plantuml-default-exec-mode 'executable))


;; (use-package lsp-metals
;;   :hook (scala-mode . lsp)
;;   :custom
;;   (lsp-metals-server-command "@metalsServer@/bin/metals"))

(use-package envrc
  :ensure t
  :config
  (envrc-global-mode))

;; (use-package lsp-bash
;;   :ensure t)

(use-package lsp-latex
  :ensure t)

;; (use-package lsp-json
;;   :ensure t)

;; (use-package lsp-jedi
;;   :hook (python-mode . (lambda ()
;;                          (require 'lsp-jedi)
;;                          (lsp)))
;;   :config
;;   (with-eval-after-load "lsp-mode"
;;     (add-to-list 'lsp-disabled-clients 'pyls))
;;   :init
;;   (setq lsp-jedi-executable-command "@jediLanguageServer@/bin/jedi-language-server"))

;; (use-package sql
;;   :custom
;;   (sql-connection-alist
;;    '(("k8s"
;;       (sql-product 'mysql)
;;       (sql-server "default.minikube.local")
;;       (sql-user "hiqprimary_auto")
;;       (sql-password "mnfprod07")
;;       (sql-database "hiqtrading_autotest")))))

;; (use-package lsp-sqls
;;   :custom
;;   (lsp-sqls-server "@sqlsServer@/bin/sqls")
;;   (lsp-sqls-connections
;;    '(
;;      ((driver . "mysql") (dataSourceName . "hiqprimary_auto:mnfprod07@tcp(default.minikube.local)/hiqtrading_autotest"))
;;      )
;;    ))


;; (use-package python-black
;;   :after python
;;   :hook (python-mode . python-black-on-save-mode-enable-dwim))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable nil))
(use-package lsp-ivy :ensure t :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :ensure t :commands lsp-treemacs-errors-list)

(use-package projectile
  :ensure t
  :config
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map))

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode))

(use-package yaml-mode
  :ensure t
  :mode "\\.yml\\'")

;; (use-package rustic
;;   :bind (:map rustic-mode-map
;;               ("M-j" . lsp-ui-imenu)
;;               ("M-?" . lsp-find-references)
;;               ("C-c C-c l" . flycheck-list-errors)
;;               ("C-c C-c a" . lsp-execute-code-action)
;;               ("C-c C-c r" . lsp-rename)
;;               ("C-c C-c q" . lsp-workspace-restart)
;;               ("C-c C-c Q" . lsp-workspace-shutdown)
;;               ("C-c C-c s" . lsp-rust-analyzer-status))
;;   :custom
;;   (rustic-analyzer-command '("@rustAnalyzer@/bin/rust-analyzer"))
;;   :config
;;   ;; uncomment for less flashiness
;;   ;; (setq lsp-eldoc-hook nil)
;;   ;; (setq lsp-enable-symbol-highlighting nil)
;;   ;; (setq lsp-signature-auto-activate nil)

;;   ;; comment to disable rustfmt on save
;;   (setq rustic-format-on-save t)
;;   (add-hook 'rustic-mode-hook 'svrg/rustic-mode-hook))

;; (defun svrg/rustic-mode-hook ()
;;   ;; so that run C-c C-c C-r works without having to confirm, but don't try to
;;   ;; save rust buffers that are not file visiting. Once
;;   ;; https://github.com/brotzeit/rustic/issues/253 has been resolved this should
;;   ;; no longer be necessary.
;;   (when buffer-file-name
;;     (setq-local buffer-save-without-query t)))
