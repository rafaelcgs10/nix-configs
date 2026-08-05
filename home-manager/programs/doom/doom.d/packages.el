;; (package! isar-mode)
;; (package! isar-goal-mode)
;; (package! lsp-isar)
;; (package! lsp-isar-parse-args)
(package! session-async)
(package! academic-phrases)
;; (package! flycheck-languagetool)
;; doom-themes-based Rosé Pine (proper syntax highlighting/contrast), with dark
;; (doom-rose-pine) and light (doom-rose-pine-dawn) variants.
(package! doom-rose-pine-theme
  :recipe (:host github :repo "donniebreve/rose-pine-doom-emacs" :files ("*.el")))
(package! quail :disable t)
;; (package! lsp-ltex)
;; (package! company-posframe)

(package! gptel)

(package! eglot-java)

(package! eglot-ltex
  :recipe (:host github :repo "emacs-languagetool/eglot-ltex"))
