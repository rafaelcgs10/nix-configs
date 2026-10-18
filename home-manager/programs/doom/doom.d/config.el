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


;;; C# / .NET via eglot + csharp-ls. `csharp-ls' and the .NET SDK are
;; installed by home-manager (programs/languages); a project flake devshell
;; that ships its own versions wins because the direnv module prepends it to
;; the buffer's PATH before eglot starts. csharp-ls finds the .sln/.csproj
;; from the project root on its own; a restored project (obj/ present, i.e.
;; `dotnet build' or `dotnet restore' ran once) is needed for references to
;; resolve. Doom's (csharp +lsp) runs `lsp!' (-> eglot-ensure) in C# buffers.
(after! eglot
  (add-to-list 'eglot-server-programs
               '((csharp-mode csharp-ts-mode) . ("csharp-ls"))))

;; sharper: transient menu over the dotnet CLI (run, build, test, add
;; package/reference, manage the solution). Doom binds it to C-c d; also put
;; it on the local leader.
(map! :after csharp-mode
      :localleader
      :map (csharp-mode-map csharp-ts-mode-map)
      :desc "dotnet CLI (sharper)" "d" #'sharper-main-transient)

(use-package! nix-drv-mode
  :mode "\\.drv\\'")


;;; APL (Dyalog)
;; dyalog-mode for Dyalog source files; the `dyalog' interpreter comes from
;; home-manager (programs/languages). Glyphs are typed with the "dyalog-apl"
;; input method below, which uses Dyalog's standard backtick prefix, the same
;; map RIDE uses on a US keyboard: `r -> ⍴, `i -> ⍳, `` -> ⋄. A backtick
;; followed by a key with no glyph inserts both characters. C-\ toggles the
;; input method off/on and `SPC m k' lists every key.
;;
;; The REPL is dyalog-mode's RIDE client: `SPC m r' starts `dyalog' as a RIDE
;; server on localhost and connects the *Dyalog-session* buffer to it.

;; Hack Nerd Font has no APL glyphs; fall back to DejaVu Sans Mono (installed
;; system-wide) for the APL symbols block (⌶ through ⎕) so ⍳⍴⌹⍉⎕ render
;; instead of boxes.
(add-hook 'doom-init-ui-hook
          (lambda ()
            (set-fontset-font t '(#x2336 . #x2395) "DejaVu Sans Mono" nil 'prepend)))

;; Generated from the en_US layout in RIDE's src/kbds.js (github.com/Dyalog/ride).
(defconst +dyalog-apl-keys
  '(("``" . "⋄") ("`1" . "¨") ("`2" . "¯") ("`3" . "<") ("`4" . "≤") ("`5" . "=")
    ("`6" . "≥") ("`7" . ">") ("`8" . "≠") ("`9" . "∨") ("`0" . "∧") ("`-" . "×")
    ("`=" . "÷") ("`q" . "?") ("`w" . "⍵") ("`e" . "∊") ("`r" . "⍴") ("`t" . "~")
    ("`y" . "↑") ("`u" . "↓") ("`i" . "⍳") ("`o" . "○") ("`p" . "*") ("`[" . "←")
    ("`]" . "→") ("`\\" . "⊢") ("`a" . "⍺") ("`s" . "⌈") ("`d" . "⌊") ("`f" . "_")
    ("`g" . "∇") ("`h" . "∆") ("`j" . "∘") ("`k" . "'") ("`l" . "⎕") ("`;" . "⍎")
    ("`'" . "⍕") ("`z" . "⊂") ("`x" . "⊃") ("`c" . "∩") ("`v" . "∪") ("`b" . "⊥")
    ("`n" . "⊤") ("`m" . "|") ("`," . "⍝") ("`." . "⍀") ("`/" . "⌿") ("`~" . "⌺")
    ("`!" . "⌶") ("`@" . "⍫") ("`#" . "⍒") ("`$" . "⍋") ("`%" . "⌽") ("`^" . "⍉")
    ("`&" . "⊖") ("`*" . "⍟") ("`(" . "⍱") ("`)" . "⍲") ("`_" . "!") ("`+" . "⌹")
    ("`E" . "⍷") ("`T" . "⍨") ("`I" . "⍸") ("`O" . "⍥") ("`P" . "⍣") ("`{" . "⍞")
    ("`}" . "⍬") ("`|" . "⊣") ("`F" . "⍛") ("`J" . "⍤") ("`K" . "⌸") ("`L" . "⌷")
    ("`:" . "≡") ("`\"" . "≢") ("`Z" . "⊆") ("`<" . "⍪") ("`>" . "⍙") ("`?" . "⍠"))
  "Backtick key sequences of the dyalog-apl input method, mapped to glyphs.")

(with-eval-after-load 'quail
  (quail-define-package
   "dyalog-apl" "UTF-8" "⍺" t
   "Dyalog APL glyphs on a backtick prefix, as in RIDE (US layout)."
   nil t t nil nil nil nil nil nil nil t)
  (dolist (key +dyalog-apl-keys)
    (quail-defrule (car key) (cdr key) "dyalog-apl")))

(defun +dyalog--enable-input-method ()
  (require 'quail)
  (setq-local default-input-method "dyalog-apl")
  (activate-input-method "dyalog-apl"))

(defun +dyalog/show-keymap ()
  "List the keys of the dyalog-apl input method."
  (interactive)
  (require 'quail)
  (describe-input-method "dyalog-apl"))

;; `SPC m ?': every glyph with its keys, its Dyalog name and meaning, and the
;; nearest functional-programming (Haskell) equivalent. Names and help text
;; come from the languagebar.json that ships with Dyalog (RIDE's hover help).
(defconst +dyalog-fp-equivalents
  '(("←" . "let binding, but rebindable; x f← y is x ← x f y")
    ("+" . "zipWith (+). Scalar functions are pervasive: they map/zipWith over arrays, nested ones too")
    ("-" . "negate / zipWith (-)")
    ("×" . "signum / zipWith (*)")
    ("÷" . "recip / zipWith (/)")
    ("*" . "exp / zipWith (**)")
    ("⍟" . "log / logBase (same argument order: 2⍟8 = logBase 2 8)")
    ("○" . "(pi *) / trig function picked by the left argument")
    ("!" . "factorial / binomial: ⍺!⍵ = ⍵ `choose` ⍺")
    ("?" . "randomRIO (1,⍵) / ⍺ random picks without replacement")
    ("|" . "abs / flip mod: ⍺|⍵ = ⍵ `mod` ⍺")
    ("⌈" . "ceiling / max")
    ("⌊" . "floor / min")
    ("⊥" . "base decode: foldl (\\acc d -> acc*⍺ + d) 0")
    ("⊤" . "base encode: digits via repeated divMod (unfoldr)")
    ("⊣" . "id / const: ⍺⊣⍵ = const ⍺ ⍵")
    ("⊢" . "id / flip const: ⍺⊢⍵ = ⍵")
    ("=" . "zipWith (==)")
    ("≠" . "zipWith (/=); monadic: mask of first occurrences (nub as a mask)")
    ("≤" . "zipWith (<=)")
    ("<" . "zipWith (<)")
    (">" . "zipWith (>)")
    ("≥" . "zipWith (>=)")
    ("≡" . "nesting depth / (==) on whole values")
    ("≢" . "length / (/=) on whole values")
    ("∨" . "gcd / (||) on booleans")
    ("∧" . "lcm / (&&) on booleans")
    ("⍲" . "not . (&&)")
    ("⍱" . "not . (||)")
    ("↑" . "list of lists to matrix / take n (pads when n > length)")
    ("↓" . "matrix to list of rows / drop n")
    ("⊂" . "pure (wrap as a scalar) / split at marks")
    ("⊃" . "head / (!!) path (1-based)")
    ("⊆" . "groupBy on a mask: keep runs marked non-zero")
    ("⌷" . "(!!) indexing (1-based)")
    ("⍋" . "argsort: map snd (sort (zip xs [1..]))")
    ("⍒" . "argsort, descending")
    ("⍳" . "[1..n] / elemIndex (1-based; not found = 1 + length)")
    ("⍸" . "findIndices (/= 0) on booleans (1-based) / interval index, like binary search")
    ("∊" . "concat, fully flattened / elem")
    ("⍷" . "isInfixOf, giving a mask of where matches start")
    ("∪" . "nub / union")
    ("∩" . "intersect")
    ("~" . "not / (\\\\) list difference")
    ("/" . "f/ is foldr1 f (a right fold!); ⍺/⍵ is concat (zipWith replicate ⍺ ⍵), i.e. filter by mask")
    ("\\" . "f\\ is scanl1 f for associative f (each prefix is a right fold)")
    ("⌿" . "foldr1 / filter along the first axis (down columns)")
    ("⍀" . "scanl1 along the first axis")
    ("," . "concat (ravel) / (++)")
    ("⍪" . "one column per item / (++) along the first axis")
    ("⍴" . "shape (dimensions) / reshape: take n (cycle xs)")
    ("⌽" . "reverse / rotate: drop n xs ++ take n xs")
    ("⊖" . "reverse / rotate along the first axis")
    ("⍉" . "transpose")
    ("¨" . "map f / zipWith f")
    ("⍨" . "f⍨⍵ = f ⍵ ⍵ (join f); ⍺ f⍨ ⍵ = flip f ⍺ ⍵; A⍨ = const A")
    ("⍣" . "f⍣n = iterate f !! n; f⍣= is a fixpoint (until)")
    ("." . "f.g inner product: foldr1 f (zipWith g ⍺ ⍵), so +.× is a dot product; ∘.g outer product: [g x y | x <- ⍺, y <- ⍵]")
    ("∘" . "f∘g: f . g (dyadic: ⍺ f (g ⍵)); A∘f and f∘A: partial application (sections)")
    ("⍛" . "f⍛g: (f ⍺) g ⍵, the mirror of ∘")
    ("⍤" . "f⍤g atop: f . g on the result; f⍤k rank: map f over rank-k cells")
    ("⍥" . "on (Data.Function): ⍺ f⍥g ⍵ = (g ⍺) f (g ⍵)")
    ("@" . "update at indices, like Data.Map.adjust or (//) on arrays")
    ("⌸" . "group by key: Map.fromListWith, then f key indices")
    ("⌺" . "map f over sliding windows (convolution)")
    ("⍎" . "eval")
    ("⍕" . "show")
    ("⍵" . "the lambda's right argument: \\⍺ ⍵ -> …")
    ("⍺" . "the lambda's left argument: \\⍺ ⍵ -> …")
    ("∇" . "self-reference for recursion (like fix)")
    ("⍬" . "[] (empty numeric vector)")
    ("⎕" . "readLn / print")
    ("⍞" . "getLine / putStr")
    ("&" . "forkIO"))
  "Nearest functional-programming equivalents, keyed by glyph.")

(defvar +dyalog--symbols nil
  "Cached glyph entries: (GLYPH NAME SUMMARY HELP-TEXT).")

(defun +dyalog--symbols ()
  (or +dyalog--symbols
      (let* ((exe (or (executable-find "dyalog")
                      (user-error "dyalog is not on PATH")))
             (file (expand-file-name "../lib/dyalog/languagebar.json"
                                     (file-name-directory (file-truename exe))))
             (bar (with-temp-buffer
                    (insert-file-contents file)
                    (json-parse-buffer :array-type 'list :object-type 'alist))))
        (setq +dyalog--symbols
              (cl-loop
               for entry in bar
               for glyph = (string-trim (alist-get 'avchar entry))
               for lines = (alist-get 'helptext entry)
               unless (string-empty-p glyph)
               collect (list glyph (alist-get 'name entry)
                             (pcase glyph
                               ("←" "Assignment")
                               ("¯" "Negative number sign: ¯3")
                               (_ (+dyalog--summary lines)))
                             (string-join lines "\n")))))))

(defun +dyalog--summary (lines)
  "One-line meaning from help LINES, e.g. \"m: Shape  d: Reshape\"."
  (string-join
   (cl-loop for line in lines
            when (string-match
                  (rx bol (group (or "Monadic" "Dyadic" "Niladic"
                                     (seq (? (+ (any alpha ?-)) " ") "Syntax")))
                      (* (not (any ?:))) ":" (+ blank) (group (+? nonl)) (* blank) eol)
                  line)
            collect (concat (pcase (match-string 1 line)
                              ("Monadic" (if (string-search "operator" line) "op: " "m: "))
                              ("Dyadic" (if (string-search "operator" line) "op: " "d: "))
                              (_ ""))
                            (match-string 2 line)))
   "  "))

(defun +dyalog--glyph-keys (glyph)
  (let ((keys (cl-loop for (key . g) in +dyalog-apl-keys
                       when (equal g glyph) collect key)))
    (string-join (if (string-match-p "\\`[[:ascii:]]\\'" glyph)
                     (cons glyph keys)
                   keys)
                 " ")))

(defvar-local +dyalog--symbols-origin nil
  "Buffer the symbol table was opened from, for `+dyalog/symbols-insert'.")

(define-derived-mode +dyalog-symbols-mode tabulated-list-mode "APL symbols"
  "Table of Dyalog APL glyphs.
\\<+dyalog-symbols-mode-map>\\[+dyalog/symbols-describe] full help, \
\\[+dyalog/symbols-insert] insert the glyph where the table was opened from."
  (setq tabulated-list-format
        [("Glyph" 5 nil) ("Keys" 9 nil) ("Name" 24 t)
         ("Meaning" 52 nil) ("FP equivalent" 0 nil)]
        tabulated-list-padding 1)
  (tabulated-list-init-header))

(defun +dyalog/symbols ()
  "Show every APL glyph with its keys, meaning and FP equivalent."
  (interactive)
  (let ((origin (current-buffer))
        (buf (get-buffer-create "*APL symbols*")))
    (with-current-buffer buf
      (+dyalog-symbols-mode)
      (setq +dyalog--symbols-origin origin
            tabulated-list-entries
            (cl-loop for (glyph name summary) in (+dyalog--symbols)
                     collect (list glyph
                                   (vector glyph (+dyalog--glyph-keys glyph) name summary
                                           (or (alist-get glyph +dyalog-fp-equivalents
                                                          nil nil #'equal)
                                               "")))))
      (tabulated-list-print))
    (pop-to-buffer buf)))

(defun +dyalog/symbols-describe ()
  "Show the full Dyalog help for the glyph on this row."
  (interactive)
  (when-let* ((glyph (tabulated-list-get-id))
              (entry (assoc glyph (+dyalog--symbols))))
    (with-help-window "*APL symbol*"
      (princ (format "%s   %s\n\n" glyph (nth 1 entry)))
      (let ((keys (+dyalog--glyph-keys glyph))
            (fp (alist-get glyph +dyalog-fp-equivalents nil nil #'equal)))
        (unless (string-empty-p keys) (princ (format "Keys: %s\n" keys)))
        (when fp (princ (format "FP:   %s\n" fp))))
      (princ (format "\n%s\n" (nth 3 entry))))))

(defun +dyalog/symbols-insert ()
  "Insert the glyph on this row where the table was opened from."
  (interactive)
  (let ((glyph (tabulated-list-get-id))
        (origin +dyalog--symbols-origin))
    (unless (buffer-live-p origin) (user-error "The original buffer is gone"))
    (quit-window)
    (pop-to-buffer origin)
    (insert glyph)))

(map! :map +dyalog-symbols-mode-map
      :nm "RET" #'+dyalog/symbols-describe
      :nm "i"   #'+dyalog/symbols-insert
      :nm "q"   #'quit-window)

(defvar +dyalog--interpreter nil
  "The `dyalog' process started by `+dyalog--repl-buffer'.")

(defvar +dyalog--port nil
  "Port `+dyalog--interpreter' serves RIDE on, picked free at each start.")

(defvar +dyalog--queue nil
  "Lines waiting to be sent to the session, one per input prompt.")

(defvar +dyalog--ready nil
  "Non-nil while the interpreter is waiting at an input prompt.")

(defun +dyalog--session-process ()
  "Return the live RIDE connection of *Dyalog-session*, or nil."
  (when-let* ((buf (get-buffer "*Dyalog-session*"))
              (proc (buffer-local-value 'dyalog-ride-process buf)))
    (and (process-live-p proc)
         ;; comint's placeholder process; without it input can't be sent.
         (process-live-p (get-buffer-process buf))
         proc)))

(defun +dyalog--free-port ()
  (let ((probe (make-network-process :name "dyalog-port-probe" :server t
                                     :host "127.0.0.1" :service t)))
    (prog1 (process-contact probe :service)
      (delete-process probe))))

(defun +dyalog--disconnect ()
  "Drop the RIDE connection and any queued input."
  (when-let* ((buf (get-buffer "*Dyalog-session*"))
              (proc (buffer-local-value 'dyalog-ride-process buf)))
    (when (process-live-p proc) (delete-process proc)))
  (setq +dyalog--queue nil
        +dyalog--ready nil))

(defun +dyalog--kill-interpreter ()
  "Stop the interpreter outright; Dyalog ignores SIGTERM and SIGHUP."
  (when (process-live-p +dyalog--interpreter)
    (kill-process +dyalog--interpreter)))

(defun +dyalog--repl-buffer ()
  "Start Dyalog and connect to it if needed; return the session buffer."
  (interactive)                         ; Doom's REPL handlers must be commands
  (require 'dyalog-mode)
  (unless (+dyalog--session-process)
    (+dyalog--disconnect)
    ;; A broken session leaves no way to talk to the old interpreter.
    (+dyalog--kill-interpreter)
    (setq +dyalog--port (+dyalog--free-port))
    ;; Dyalog still runs its tty session on stdout, which RIDE makes
    ;; redundant, so the process output is discarded.
    (let ((process-environment
           (cons (format "RIDE_INIT=SERVE:127.0.0.1:%d" +dyalog--port)
                 process-environment))
          (process-connection-type nil))
      (setq +dyalog--interpreter
            (start-process "dyalog" nil "dyalog" "+s" "-q" "-nokbd"))
      (set-process-filter +dyalog--interpreter #'ignore)
      (set-process-sentinel +dyalog--interpreter
                            (lambda (proc event)
                              ;; Ignore a replaced interpreter dying late.
                              (when (eq proc +dyalog--interpreter)
                                (+dyalog--disconnect)
                                (message "Dyalog: %s" (string-trim event)))))
      (set-process-query-on-exit-flag +dyalog--interpreter nil))
    ;; The RIDE port opens a moment after the process starts.
    (let ((tries 0))
      (while (not (ignore-error file-error
                    (save-window-excursion
                      (dyalog-ride-session "localhost" +dyalog--port))
                    t))
        (when (or (> (cl-incf tries) 50)
                  (not (process-live-p +dyalog--interpreter)))
          (+dyalog--kill-interpreter)
          (user-error "Could not connect to Dyalog on port %d" +dyalog--port))
        (sleep-for 0.1))))
  (get-buffer "*Dyalog-session*"))

(defun +dyalog/repl ()
  "Start or switch to the Dyalog session."
  (interactive)
  (pop-to-buffer (+dyalog--repl-buffer)))

(defun +dyalog/quit ()
  "Shut the interpreter down: )OFF when it is idle, otherwise kill it."
  (interactive)
  (if (and +dyalog--ready (+dyalog--session-process))
      (with-current-buffer "*Dyalog-session*"
        (setq +dyalog--queue nil)
        (dyalog-ride-eval-input ")OFF" nil))
    (+dyalog--disconnect)
    (+dyalog--kill-interpreter)))

;; Code sent from a buffer is queued and fed to the interpreter one line per
;; prompt, so multi-line dfns and control structures work like typed input and
;; each line is echoed before its output. A Dyalog error drops the rest.
(defun +dyalog--send-next ()
  (when (and +dyalog--ready +dyalog--queue (+dyalog--session-process))
    (let ((line (pop +dyalog--queue)))
      (setq +dyalog--ready nil)
      (with-current-buffer "*Dyalog-session*"
        (comint-output-filter (get-buffer-process (current-buffer))
                              (concat line "\n"))
        (dyalog-ride-eval-input line nil)))))

(defun +dyalog--on-prompt (_cmd args _process)
  ;; Prompt types: 0 busy, 1 ready, 2 ⎕ input, 3 continuation of a
  ;; multi-line definition.
  (setq +dyalog--ready (memq (alist-get 'type args) '(1 3)))
  (+dyalog--send-next))

(defun +dyalog--on-command (_process command)
  (when (and +dyalog--queue (string-prefix-p "[\"HadError\"" command))
    (message "Dyalog error; %d queued line(s) not sent" (length +dyalog--queue))
    (setq +dyalog--queue nil)))

(defun +dyalog--send-string (string)
  (let ((lines (seq-remove #'string-blank-p (split-string string "\n"))))
    (+dyalog--repl-buffer)
    (setq +dyalog--queue (append +dyalog--queue lines))
    (+dyalog--send-next)
    (display-buffer "*Dyalog-session*")))

(defun +dyalog/send-region (beg end)
  "Send the region to the Dyalog session."
  (interactive "r")
  (+dyalog--send-string (buffer-substring-no-properties beg end)))

(defun +dyalog/send-line ()
  "Send the current line to the Dyalog session."
  (interactive)
  (+dyalog/send-region (line-beginning-position) (line-end-position)))

(defun +dyalog/send-buffer ()
  "Send the whole buffer to the Dyalog session, line by line."
  (interactive)
  (+dyalog/send-region (point-min) (point-max)))

(defun +dyalog--eval-region (beg end)
  "Eval handler for Doom's `gr' operator: send to the session."
  (+dyalog/send-region beg end)
  t)

(defun +dyalog/fix-file ()
  "Save the file and define it in the session with ⎕FIX.
For script files holding a :Namespace, :Class or functions."
  (interactive)
  (save-buffer)
  (+dyalog--send-string
   (format "⎕FIX 'file://%s'"
           (string-replace "'" "''" (expand-file-name buffer-file-name)))))

(defun +dyalog/run-file ()
  "Save the file and run it as a script with dyalogscript."
  (interactive)
  (save-buffer)
  (compile (concat "dyalogscript " (shell-quote-argument buffer-file-name))))

(use-package! dyalog-mode
  :mode "\\.\\(?:apl[acfino]?\\|dyalog\\)\\'"
  :config
  (add-hook 'dyalog-mode-hook #'+dyalog--enable-input-method)
  (add-hook 'dyalog-session-mode-hook #'+dyalog--enable-input-method)
  (add-hook 'dyalog-session-mode-hook
            (lambda () (add-hook 'kill-buffer-hook #'+dyalog/quit nil t)))
  (add-hook 'kill-emacs-hook #'+dyalog--kill-interpreter)
  (advice-add 'dyalog-ride-set-prompt-cmd :after #'+dyalog--on-prompt)
  (advice-add 'dyalog-ride-exec-command :before #'+dyalog--on-command)
  ;; comint's job-control keys would kill the session's placeholder process;
  ;; interrupt Dyalog over RIDE instead.
  (map! :map dyalog-session-mode-map
        "C-c C-c"  #'dyalog-ride-interrupt
        "C-c C-z"  #'ignore
        "C-c C-\\" #'ignore
        "C-c C-d"  #'ignore)
  ;; `SPC o r' opens the session; the evil `gr' operator sends to it.
  (set-repl-handler! 'dyalog-mode #'+dyalog--repl-buffer
    :persist t
    :send-region #'+dyalog/send-region
    :send-buffer #'+dyalog/send-buffer)
  (set-eval-handler! 'dyalog-mode #'+dyalog--eval-region)
  (map! :localleader
        :map dyalog-mode-map
        :desc "Start/switch to Dyalog REPL" "r" #'+dyalog/repl
        :desc "Quit interpreter ()OFF)"     "q" #'+dyalog/quit
        :desc "Show APL keys"               "k" #'+dyalog/show-keymap
        :desc "APL symbols table"           "?" #'+dyalog/symbols
        :desc "Help for symbol at point"    "h" #'dyalog-help-for-symbol-at-point
        :desc "Toggle APL input method"     "i" #'toggle-input-method
        :desc "Load file (⎕FIX)"            "l" #'+dyalog/fix-file
        :desc "Run file as script"          "x" #'+dyalog/run-file
        (:prefix ("s" . "send to REPL")
         :desc "Line"   "l" #'+dyalog/send-line
         :desc "Region" "r" #'+dyalog/send-region
         :desc "Buffer" "b" #'+dyalog/send-buffer)))
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
