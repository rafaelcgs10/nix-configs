;; (package! isar-mode)
;; (package! isar-goal-mode)
;; (package! lsp-isar)
;; (package! lsp-isar-parse-args)
(package! session-async)
(package! academic-phrases)
(package! writegood-mode)
;; (package! flycheck-languagetool)
;; doom-themes-based Rosé Pine (proper syntax highlighting/contrast), with dark
;; (doom-rose-pine) and light (doom-rose-pine-dawn) variants.
;; :pin required by nix-doom-emacs-unstraightened: packages not in
;; nixpkgs/emacs-overlay must be pinned to a commit (Nix can't resolve "latest"
;; reproducibly the way straight.el does). Bump the SHA to update.
(package! doom-rose-pine-theme
  :recipe (:host github :repo "donniebreve/rose-pine-doom-emacs" :files ("*.el"))
  :pin "78100823087f2fa727cdd5c06f8deb17988520b6")
(package! quail :disable t)
;; (package! lsp-ltex)
;; (package! company-posframe)

(package! gptel)

(package! eglot-java)

(package! eglot-ltex
  :recipe (:host github :repo "emacs-languagetool/eglot-ltex")
  :pin "2ae2fad68ca2520f69b8d8174afc42ca271f6146")
