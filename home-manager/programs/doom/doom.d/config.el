;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Rafael Castro Gonçalves Silva"
      user-mail-address "rafaelcgs10@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq-default display-line-numbers-width 0)

;; Scroll line by line with the whell
(setq scroll-step 1
      scroll-conservatively 10000)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)


;; (setq +workspaces-on-switch-project-behavior nil)
;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Setqs
(setq projectile-project-search-path '("~/Documents"))
;;
;; LSP tweaks
(advice-add 'lsp :before (lambda (&rest _args) (eval '(setf (lsp-session-server-id->folders (lsp-session)) (ht)))))
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))
(setq lsp-idle-delay 0.800)
(setq lsp-lens-enable nil)
;; (setq lsp-completion-provider :comapany-capf)
;; (setq lsp-enable-completion-at-point t)
(setq prettify-symbols-mode t)
(setq lsp-completion-show-detail t)
(setq lsp-enable-on-type-formatting t)
(setq doom-modeline-enable-word-count nil)
(setq scroll-conservatively 101)
(setq lsp-solargraph-use-bundler nil)
;; (setq lsp-solargraph-library-directories '("/home/rafael/.gem/"))
(setq lsp-solargraph-multi-root t)
(setq company-minimum-prefix-length 1
      company-idle-delay 0.1)
;; (setq mode-require-final-newline nil)

(global-prettify-symbols-mode -1)
(prettify-symbols-mode -1)
(setq rustic-flycheck-clippy-params "--message-format=json")
(setq rustic-compile-directory-method 'rustic-buffer-workspace)
(add-hook 'haskell-mode-hook #'lsp)
(add-hook 'haskell-literate-mode-hook #'lsp)

;; Languagetool for working with nix
;; (setq langtool-java-bin "java")
(setq langtool-bin "languagetool-commandline")
(setq langtool-default-language "en-US")
;; Long line perfomance tweak
(setq bidi-inhibit-bpa t)
;; (setq global-so-long-mode t)

;; Flycheck configs
(use-package! flycheck-golangci-lint
  :ensure t
  :hook (go-mode . flycheck-golangci-lint-setup))
(setq flycheck-golangci-lint-tests t)
(setq flycheck-golangci-lint-enable-all t)

;; Minimap configs
(setq minimap-update-delay 0.1)
;; (add-hook 'prog-mode-hook 'minimap-mode)

;; Ace-window configs
(custom-set-faces!
  '(aw-leading-char-face
    :foreground "white" :background "red"
    :weight bold :height 2.5 :box (:line-width 10 :color "red")))

;; Hooks
;; (add-hook 'prog-mode-hook #'lsp)
;; (add-hook 'lsp-mode-hook 'lsp-ui-mode)
;; (add-hook 'ruby-mode-hook 'chruby-use-corresponding)
;; (add-hook 'prog-mode-hook 'origami-mode)
(add-hook 'before-save-hook 'my-prog-nuke-trailing-whitespace)
;; (add-hook 'lsp-mode-hook 'dynamic-completion-mode)
;; (add-hook 'ruby-mode-hook 'highlight-indentation-current-column-mode)

;; Keys
;; (with-eval-after-load 'evil
;;   (define-key evil-motion-state-map (kbd "z a") 'origami-toggle-all-nodes))
;; (with-eval-after-load 'evil
;;   (define-key evil-motion-state-map (kbd "z c") 'origami-close-node))
;; (with-eval-after-load 'evil
;;   (define-key evil-motion-state-map (kbd "Z c") 'origami-close-node-recursively))
;; (with-eval-after-load 'evil
;;   (define-key evil-motion-state-map (kbd "z o") 'origami-open-node))
;; (with-eval-after-load 'evil
;;   (define-key evil-motion-state-map (kbd "Z o") 'origami-open-node-recursively))
;; (defvar leader-states '(normal visual emacs)
;;   "Evil states for the leader keybinding")
;; (evil-define-key leader-states 'global (kbd "C-<down>") 'evil-window-down)
;; (evil-define-key leader-states 'global (kbd "C-<up>") 'evil-window-up)
;; (evil-define-key leader-states 'global (kbd "C-<left>") 'evil-window-left)
;; (evil-define-key leader-states 'global (kbd "C-<right>") 'evil-window-right)
(global-set-key (kbd "C-<down>") 'windmove-down)
(global-set-key (kbd "C-<up>") 'windmove-up)
(global-set-key (kbd "C-<right>") 'windmove-right)
(global-set-key (kbd "C-<left>") 'windmove-left)
(global-unset-key (kbd "C-x C-b"))
;; (global-set-key (kbd "C-x b") 'project-switch-to-buffer)
(global-set-key "\M-d" 'lsp-ui-peek-find-definitions)
(global-set-key "\M-r" 'lsp-ui-peek-find-references)
(global-set-key "\M-m" 'rinari-find-model)
(global-set-key "\M-v" 'rinari-find-view)
(global-set-key "\M-c" 'rinari-find-controller)
(map! :leader
      (:prefix-map ("l" . "lsp")
       (:desc "Restart lsp workspace" "r" #'lsp-workspace-restart)))



;; Packages configs
(use-package! treemacs
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay      0.2
          treemacs-directory-name-transformer    #'identity
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-extension-regex          treemacs-last-period-regex-value
          treemacs-file-follow-delay             0.2
          treemacs-file-name-transformer         #'identity
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          ;; treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-asc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              0.5
          treemacs-width                         35)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package! treemacs-projectile
  :after treemacs projectile
  :ensure t)

(use-package! treemacs-magit
  :after treemacs magit
  :ensure t)

(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-nord t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)

  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-colors") ; use the colorful treemacs theme
  (doom-themes-treemacs-config)

  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(defun my-prog-nuke-trailing-whitespace ()
  (when (derived-mode-p 'prog-mode)
    (delete-trailing-whitespace)))

(setq haskell-process-type 'cabal-new-repl)

(custom-set-faces '(flycheck-duplicate ((t (:underline '(:style line)))))
                  '(flycheck-incorrect ((t (:underline '(:style line)))))
                  '(flycheck-error ((t (:underline '(:style line)))))
                  '(flycheck-warning ((t (:underline '(:style line)))))
                  '(flycheck-info ((t (:background nil :foreground nil :underline '(:style line))))))


;; (use-package! lsp-isar-parse-args
;;   :custom
;;   (lsp-isar-parse-args-nollvm nil))

;; Isabelle setup
(use-package! isar-mode
  :mode "\\.thy\\'"
  :config
  ;; (add-hook 'isar-mode-hook 'turn-on-highlight-indentation-mode)
  ;; (add-hook 'isar-mode-hook 'flycheck-mode)
  (add-hook 'isar-mode-hook 'company-mode)
  (add-hook 'isar-mode-hook
            (lambda ()
              (set (make-local-variable 'company-backends)
                   '((company-dabbrev-code company-yasnippet)))))
  (add-hook 'isar-mode-hook
            (lambda ()
              (set (make-local-variable 'indent-tabs-mode) nil)))
  (add-hook 'isar-mode-hook
            (lambda ()
              (yas-minor-mode)))


  (add-hook 'isar-mode-hook (lambda () (setq unicode-tokens-mode t)))
  (add-hook 'isar-mode-hook (lambda () (setq doom-unicode-font (font-spec :family "Isabelle DejaVu Sans Mono"))))
  (add-hook 'isar-mode-hook (lambda () (face-remap-add-relative 'default :family "Isabelle DejaVu Sans Mono" :height 120)))
  (add-hook 'isar-goal-mode-hook (lambda () (face-remap-add-relative 'default :family "Isabelle DejaVu Sans Mono" :height 120)))
  (add-hook 'isar-mode-hook (lambda () (doom/reload-font)))


  (add-hook 'isar-mode-hook (lambda () (display-line-numbers-mode t )))
  )


(use-package! lsp-isar-parse-args
  :custom
  (lsp-isar-parse-args-nollvm nil))

(setq lsp-isabelle-options (list "-d" "/app/afp-2022-02-13/thys"))

(setq display-line-numbers-mode t)

(use-package! lsp-isar
  :commands lsp-isar-define-client-and-start
  :custom
  (lsp-isar-output-use-async t)
  (lsp-isar-output-time-before-printing-goal nil)
  (lsp-isar-experimental t)
  (lsp-isar-split-pattern 'lsp-isar-split-pattern-two-columns)
  (lsp-isar-decorations-delayed-printing t)
  :init
  (add-hook 'lsp-isar-init-hook 'lsp-isar-open-output-and-progress-right-spacemacs)
  (add-hook 'isar-mode-hook #'lsp-isar-define-client-and-start)

  (push (concat "~/isabelle/Isabelle2021/src/Tools/emacs-lsp/yasnippet")
        yas-snippet-dirs)
  (setq lsp-isar-path-to-isabelle "/etc/isabelle-docker/")
  )

(setq fancy-splash-image "~/nix-configs/home-manager/programs/doom/emacs.svg")

(after! lsp-mode
  (advice-remove #'lsp #'+lsp-dont-prompt-to-install-servers-maybe-a))

;; (require 'dap-cpptools)
;; (setq gdb-many-windows t)

;; (setq lsp-rust-unstable-features t)
;; (setq gdb-show-main t
;;       gdb-many-windows t)

(after! rustic
  (setq rustic-format-on-save t)
  (after! dap-mode
    (require 'dap-gdb-lldb)
    (dap-register-debug-template
     "Timely Dataflow 2 workers"
     (list :type "gdb"
           :arguments "-w2"
           :request "launch"
           :name "GDB::Run"
           :gdbpath "rust-gdb"
           :target nil
           :cwd nil))
    (dap-register-debug-template
     "Rust::GDB Run Configuration"
     (list :type "gdb"
           :request "launch"
           :name "GDB::Run"
           :gdbpath "rust-gdb"
           :target nil
           :cwd nil))
    (dap-register-debug-template
     "Rust::LLDB Run Configuration"
     (list :type "lldb"
           :request "launch"
           :name "LLDB::Run"
           :gdbpath "rust-lldb"
           :target nil
           :cwd nil))
    )
  )

(use-package dap-mode
  :ensure t
  :config
  (dap-ui-mode)
  (dap-ui-controls-mode 1)
  (require 'dap-lldb)
  (require 'dap-gdb-lldb)
  (dap-gdb-lldb-setup)
  )

(defun modi/kill-non-project-buffers (&optional kill-special)
  "Kill buffers that do not belong to a `projectile' project.

With prefix argument (`C-u'), also kill the special buffers."
  (interactive "P")
  (let ((bufs (buffer-list (selected-frame))))
    (dolist (buf bufs)
      (with-current-buffer buf
        (let ((buf-name (buffer-name buf)))
          (when (or (null (projectile-project-p))
                    (and kill-special
                         (string-match "^\*" buf-name)))
            ;; Preserve buffers with names starting with *scratch or *Messages
            (unless (string-match "^\\*\\(\\scratch\\|Messages\\)" buf-name)
              (message "Killing buffer %s" buf-name)
              (kill-buffer buf))))))))

(setq doom-font (font-spec :family "mononoki" :height 120 :weight'normal :width 'normal))
