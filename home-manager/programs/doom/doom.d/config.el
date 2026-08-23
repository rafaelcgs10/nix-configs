;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;;
;; Personal Doom configuration. Home Manager rebuilds Doom and its packages.


;;; Identity
(setq user-full-name "Rafael Castro Gonçalves Silva"
      user-mail-address "me@rafaelcgs.com")


;;; Appearance
;; Match the Hack Nerd Font installed by Stylix/Home Manager. A missing font
;; errors in Doom's frame hook before theme and late keybindings are applied,
;; which also makes daemon-created emacsclient frames immediately close.
(setq doom-font (font-spec :family "Hack Nerd Font Mono" :height 120))

;; Hide the native compositor/GTK title bar on Emacs frames only. The default
;; list covers daemon-created `emacsclient -c' frames; the initial list covers a
;; direct GUI launch.
(add-to-list 'default-frame-alist '(undecorated . t))
(add-to-list 'initial-frame-alist '(undecorated . t))
(when (display-graphic-p)
  (modify-frame-parameters nil '((undecorated . t))))

;; Keep font caches resident across GC. With doom-modeline's nerd-icons on a 4K
;; display (plus Isabelle/LaTeX unicode), compacting the font cache on every GC
;; forces redisplay to re-open fonts, causing scroll/redraw stutter. The only
;; cost is a larger memory footprint. See the variable's docstring.
(setq inhibit-compacting-font-caches t)

;; doom-themes-based Rosé Pine ships separate dark/light theme *symbols*
;; (doom-rose-pine = dark, doom-rose-pine-dawn = light); toggle by swapping.
;; load-theme searches `custom-theme-load-path', and an external doom-theme
;; package's directory isn't added there automatically, which caused the
;; "Unable to find theme file for 'doom-rose-pine'" startup error. Add it
;; explicitly (the package is on load-path, so locate-library finds it).
(setq custom-safe-themes t)
(dolist (thm '("doom-rose-pine-theme" "doom-rose-pine-dawn-theme"))
  (when-let ((lib (locate-library thm)))
    (add-to-list 'custom-theme-load-path (file-name-directory lib))))
(setq doom-theme 'doom-rose-pine)        ; dark default

(defun my/toggle-rose-pine ()
  "Toggle Rosé Pine between dark and light (dawn)."
  (interactive)
  (if (custom-theme-enabled-p 'doom-rose-pine)
      (progn (disable-theme 'doom-rose-pine) (load-theme 'doom-rose-pine-dawn t))
    (progn (disable-theme 'doom-rose-pine-dawn) (load-theme 'doom-rose-pine t)))
  (message "Rosé Pine: %s"
           (if (custom-theme-enabled-p 'doom-rose-pine) "dark" "dawn (light)")))

;; Bind C-c C-t on a *global minor-mode* keymap, not the global map. Minor-mode
;; maps override major-mode maps, so the key keeps working in org-mode,
;; prog-modes, etc. (which bind C-c C-t themselves). This is how the old
;; cycle-themes-mode kept the key live in every buffer; plain global-set-key
;; gets shadowed by those major modes.
(defvar my/theme-toggle-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-t") #'my/toggle-rose-pine)
    map)
  "Keymap holding the global theme-toggle binding.")

(define-minor-mode my/theme-toggle-mode
  "Global minor mode that provides the Rosé Pine dark/light toggle key."
  :global t
  :keymap my/theme-toggle-map)
(my/theme-toggle-mode 1)

;; doom-themes is loaded and configured by the `:ui doom' module, which already
;; hooks `doom-themes-org-config' and enables bold/italic by default. Only add
;; the extra it does not turn on: a flashing mode-line on errors.
(after! doom-themes
  (doom-themes-visual-bell-config))

;; A big, hard-to-miss ace-window leading character.
(custom-set-faces!
  '(aw-leading-char-face
    :foreground "white" :background "red"
    :weight bold :height 2.5 :box (:line-width 10 :color "red")))

;; Full-width line-number gutter, and a fill-column indicator in prose buffers
;; (fill-column already defaults to 80, set by Doom in doom-editor.el).
(setq-default display-line-numbers-width 0)
(add-hook 'text-mode-hook  #'display-fill-column-indicator-mode)
(add-hook 'LaTeX-mode-hook #'display-fill-column-indicator-mode)

;; Straight underline instead of the wavy default for flycheck highlights.
(custom-set-faces!
  '(flycheck-error   :underline (:style line))
  '(flycheck-warning :underline (:style line))
  '(flycheck-info    :underline (:style line)))


;;; Modeline & workspaces
;; Always show the Doom workspace list in the mode-line (bottom of the frame),
;; instead of only transiently in the echo area when switching with M-<number>.
;; init.el uses plain `modeline' (the `doom-modeline' package). Its default
;; `main' layout already carries a `persp-name' segment on the right-hand side,
;; but Doom sets `doom-modeline-persp-name' to nil (suppressed). We re-enable it
;; and redefine what the segment renders: the full workspace tabline (every
;; workspace, active one highlighted) via Doom's own `+workspace--tabline'.
(after! doom-modeline
  (setq doom-modeline-persp-name t
        doom-modeline-display-default-persp-name t)
  (doom-modeline-def-segment persp-name
    (when (and (bound-and-true-p persp-mode)
               (fboundp '+workspace--tabline))
      (concat (doom-modeline-spc)
              (+workspace--tabline)
              (doom-modeline-spc)))))

;; The workspace list now lives permanently in the modeline (above), so Doom's
;; transient echo-area copy -- printed on every switch by `+workspace/display'
;; (called from `+workspace/switch-to' at workspaces.el:375) -- is redundant and
;; shows the list a second time in the minibuffer. Silence it when it's fired by
;; a switch/cycle command, but keep the manual `+workspace/display' (SPC TAB TAB)
;; working. We key off `this-command' rather than `called-interactively-p', which
;; is unreliable when queried from inside advice.
(defadvice! +workspaces-quiet-transient-display-a (orig-fn &rest args)
  "Suppress the echo-area workspace tabline except on a direct `+workspace/display'."
  :around #'+workspace/display
  (if (eq this-command '+workspace/display)
      (apply orig-fn args)
    nil))


;;; Editor behaviour
;; Scroll line by line with the wheel.
(setq scroll-step 1
      scroll-conservatively 10000
      mouse-wheel-scroll-amount '(1 ((shift) . 1))
      mouse-wheel-progressive-speed nil)

(after! which-key
  (setq which-key-idle-delay 0.5))

;; Route files through their tree-sitter major modes (this is what makes .java
;; open in java-ts-mode, which drives the eglot-java hook further down).
(setq major-mode-remap-alist major-mode-remap-defaults)

;; custom.el (written by `M-x customize') loads AFTER config.el and silently
;; overrides it -- that is what caused the fill-column=120 surprise. Point
;; `custom-file' at a throwaway in the cache dir: once custom-file no longer
;; equals its startup value, Doom skips loading doom.d/custom.el entirely (see
;; profiles.el:410), so Customize can never clobber this file again.
(setq custom-file (expand-file-name "custom.el" doom-cache-dir))
(setq warning-suppress-log-types '((lsp-mode))
      warning-suppress-types     '((doom-init-ui-hook) (defvaralias)))


;;; Completion (company)
(setq company-idle-delay 2
      company-minimum-prefix-length 2)
(set-company-backend! 'text-mode
  '(:separate company-dabbrev company-yasnippet company-files company-ispell))
(add-to-list '+latex--company-backends #'company-ispell)


;;; Keybindings
;; Window movement with C-<arrow>. Use Doom's `map!' instead of global-set-key
;; so evil and major-mode maps don't shadow the bindings.
(map! "C-<down>"  #'windmove-down
      "C-<up>"    #'windmove-up
      "C-<right>" #'windmove-right
      "C-<left>"  #'windmove-left)
(global-unset-key (kbd "C-x C-b"))


;;; Projects & Treemacs
(setq projectile-project-search-path '("~/Documents"))

(use-package! treemacs
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs))
  :config
  (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
        treemacs-deferred-git-apply-delay      1.0
        treemacs-directory-name-transformer    #'identity
        treemacs-display-in-side-window        t
        treemacs-eldoc-display                 t
        treemacs-file-event-delay              5000
        treemacs-file-extension-regex          treemacs-last-period-regex-value
        treemacs-file-follow-delay             0.8
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
        treemacs-tag-follow-delay              0.8
        treemacs-width                         35)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode t)
  (pcase (cons (not (null (executable-find "git")))
               (not (null treemacs-python-executable)))
    (`(t . t)
     (treemacs-git-mode 'deferred))
    (`(t . _)
     (treemacs-git-mode 'simple)))
  :bind
  (:map global-map
        ("M-0"       . treemacs)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

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


;;; Languages & LSP
(add-hook 'java-ts-mode-hook 'eglot-java-mode)

;; Inlay hints off everywhere, except C/C++ where seeing inferred types inline
;; is genuinely useful. Decided here (not in a mode hook) so it runs only once
;; eglot has actually attached to the buffer.
(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (eglot-inlay-hints-mode
             (if (derived-mode-p 'c-mode 'c-ts-mode 'c++-mode 'c++-ts-mode)
                 1 -1))))

;; C/C++ (darktable et al.) via eglot + clangd. Doom's (cc +lsp) module runs
;; eglot in c/c++ buffers; override the default clangd invocation so
;; goto-definition works across the whole project (background index) and
;; clang-tidy diagnostics show up inline.
(after! eglot
  (add-to-list 'eglot-server-programs
               '((c-mode c-ts-mode c++-mode c++-ts-mode)
                 . ("clangd"
                    "--background-index"
                    "--clang-tidy"
                    "--completion-style=detailed"
                    "--header-insertion=never"
                    "--pch-storage=memory"
                    "-j=4"))))


;;; C# / .NET via eglot + csharp-ls. The server binary is not installed
;; globally; it comes from each project's nix flake devshell, which the
;; direnv module puts on the buffer's PATH before eglot starts.
(after! eglot
  (add-to-list 'eglot-server-programs
               '((csharp-mode csharp-ts-mode) . ("csharp-ls"))))

(use-package! nix-drv-mode
  :mode "\\.drv\\'")


;;; Org
;; `org-directory' must be set before org loads, so keep it at top level.
(setq org-directory "~/org/")
(after! org
  (setq org-agenda-files '("~/Documents/rafaelcgs10.github.io/todo.org")))


;;; Writing & spell-checking
(setq ispell-alternate-dictionary
      (expand-file-name "doom/american-english-exhaustive.txt"
                        (or (getenv "XDG_DATA_HOME") "~/.local/share"))
      ispell-personal-dictionary
      (expand-file-name "doom/ispell.dict"
                        (or (getenv "XDG_DATA_HOME") "~/.local/share")))

;; writegood-mode highlights weasel words, passive voice and duplicated words
;; in prose buffers.
(use-package! writegood-mode
  :hook ((text-mode org-mode markdown-mode LaTeX-mode) . writegood-mode)
  :config
  (custom-set-faces!
    '(writegood-weasels-face       :underline (:style line))
    '(writegood-passive-voice-face :underline (:style line))
    '(writegood-duplicates-face    :underline (:style line))))


;;; Platform (Wayland/pgtk on Nvidia)
(when (eq window-system 'pgtk)
  (setq x-gtk-use-native-input t             ; native GTK input method under pgtk
        pgtk-wait-for-event-timeout 0.001))  ; lower event-loop latency
