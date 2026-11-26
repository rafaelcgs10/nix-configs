;; (package! isar-mode)
;; (package! isar-goal-mode)
;; (package! lsp-isar)
;; (package! lsp-isar-parse-args)
(package! session-async)
(package! academic-phrases)
(package! writegood-mode)
;; (package! flycheck-languagetool)
;; Catppuccin's official Emacs theme: one theme, four flavours (Latte by day,
;; Mocha by night; toggled in config.el). On MELPA (emacs-overlay), so no :pin.
(package! catppuccin-theme)
(package! quail :disable t)
;; (package! lsp-ltex)
;; (package! company-posframe)

(package! gptel)

(package! eglot-java)

;; On-demand LanguageTool client (see the Grammar section of config.el).
(package! langtool)

(package! eglot-ltex
  :recipe (:host github :repo "emacs-languagetool/eglot-ltex")
  :pin "2ae2fad68ca2520f69b8d8174afc42ca271f6146")

;; Dyalog APL: major mode and RIDE session client. On MELPA (emacs-overlay),
;; so no :pin needed.
(package! dyalog-mode)

;; Quint: the official major mode from the Quint repository (keyword
;; highlighting); not published on MELPA, so fetched from the repo and pinned.
;; The language server comes from Nix (programs/languages).
(package! quint-mode
  :recipe (:host github :repo "quint-co/quint"
           :files ("editor-plugins/emacs/quint-mode.el"))
  :pin "04cec329d28f4d28e0a025e99a0e31912258c1de")

;; :tools terraform adds company-terraform, which completes from a static,
;; outdated list and, sitting ahead of company-capf, answers in nearly every
;; context, so terraform-ls's completions (from the real provider schemas,
;; via eglot) never showed.
(package! company-terraform :disable t)
