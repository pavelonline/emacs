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

(use-package fira-code-mode
  :hook prog-mode)

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
  (load-theme 'zerodark t))

(use-package zerodark
  :no-require t
  :config (if (daemonp)
	      (add-hook 'after-make-frame-functions #'svrg/load-theme-hook)
	    (load-theme 'zerodark t)))

(use-package json-mode)

(use-package which-key
  :config
  (which-key-mode)
  (which-key-setup-side-window-right))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((nix-mode . lsp)
	 (c++-mode . lsp)
	 (yaml-mode . lsp)
         (sh-mode . lsp)
         (json-mode . lsp)
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp
  :custom
  (lsp-nix-server-path "@rnixLsp@/bin/rnix-lsp")
  (lsp-yaml-server-command '("@yamlLanguageServer@/bin/yaml-language-server" "--stdio")))

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

(use-package lsp-ui :commands lsp-ui-mode)
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

(use-package projectile
  :config
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map))
