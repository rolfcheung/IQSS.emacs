(when (< (string-to-number 
          (concat 
           (number-to-string emacs-major-version) 
           "." 
           (number-to-string emacs-minor-version)))
         25.3)
  (error "Your version of emacs is old and must be upgraded before you can use these packages! Version >= 25.3 is required."))

;; start maximized 
(setq frame-resize-pixelwise t
      x-frame-normalize-before-maximize t)
(add-to-list 'initial-frame-alist '(fullscreen . fullheight))

;; set coding system so emacs doesn't choke on melpa file listings
(set-language-environment 'utf-8)
(setq locale-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(unless (eq system-type 'windows-nt)
  (set-selection-coding-system 'utf-8))
(prefer-coding-system 'utf-8)
(setq buffer-file-coding-system 'utf-8)
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

(require 'cl)

;; set things that need to be set before packages load
(setq outline-minor-mode-prefix "\C-c\C-o")
(add-hook 'outline-minor-mode-hook
          (lambda () (local-set-key "\C-c\C-o"
                                    outline-mode-prefix-map)))
(setq save-abbrevs 'silently)
(setq max-specpdl-size 10000
      max-lisp-eval-depth 5000)

;; load the package manager
(require 'package)
(when (< emacs-major-version 27)
  (package-initialize t))

;; Add additional package sources
(add-to-list 'package-archives 
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives
             '("org" . "http://orgmode.org/elpa/") t)

;; Make a list of the packages you want
(setq package-selected-packages
      '(;; gnu packages
        auctex
        windresize
        diff-hl
        adaptive-wrap
        ;; melpa packages
        ;; mode-icons ; slows things down, can be buggy
        pdf-tools
        yasnippet
        yasnippet-snippets
        visual-regexp
        command-log-mode
        undo-tree
        better-defaults
        minions
        ace-window
        howdoi
        multi-term
        with-editor
        git-commit
        magit
        eyebrowse
        anzu
        counsel
        flx-ido
        smex
        ivy-bibtex
        hydra
        ivy-hydra
        which-key
        outline-magic
        outshine
        smooth-scroll
        unfill
        company
        company-math
        ess
        web-mode
        markdown-mode
        pandoc-mode
        polymode
        eval-in-repl
        haskell-mode
        intero
        company-ghci
        flycheck
        scala-mode
        ensime
        sbt-mode
        exec-path-from-shell
        dumb-jump
        htmlize
        dictionary
        ox-pandoc
        untitled-new-buffer))

;; hide compilation buffer when complete
;; from http://emacs.stackexchange.com/questions/62/hide-compilation-window
(add-hook 'compilation-finish-functions
          (lambda (buf str)
            (if (null (string-match ".*exited abnormally.*" str))
                ;;no errors, make the compilation window go away in a few seconds
                (progn
                  (let ((win  (get-buffer-window buf 'visible)))
                    (when win (delete-window win)))))))

;; install packages if needed
(unless (every 'package-installed-p package-selected-packages)
  (message "Missing packages detected, please wait...")
  ;; org needs to be installed first
  (package-refresh-contents)
  (package-install (cadr (assq 'org package-archive-contents)))
  (package-install-selected-packages))
(when (< emacs-major-version 27)
  (package-initialize))

;; add custom lisp directory to path
(unless
    (file-exists-p (concat user-emacs-directory "lisp"))
  (make-directory (concat user-emacs-directory "lisp")))

;; add custom lisp directory to path
(let ((default-directory (concat user-emacs-directory "lisp/")))
  (setq load-path
        (append
         (let ((load-path (copy-sequence load-path))) ;; Shadow
           (append 
            (copy-sequence (normal-top-level-add-to-load-path '(".")))
            (normal-top-level-add-subdirs-to-load-path)))
         load-path)))

;; on OSX Emacs needs help setting up the system paths
(when (memq window-system '(mac ns))
  (require 'exec-path-from-shell)
  ;; From https://github.com/aculich/.emacs.d/blob/master/init.el
  ;; Import additional environment variables beyond just $PATH
  (dolist (var '("PYTHONPATH"         ; Python modules
                 "INFOPATH"           ; Info directories
                 "JAVA_OPTS"          ; Options for java processes
                 "SBT_OPTS"           ; Options for SBT
                 "RUST_SRC_PATH"      ; Rust sources, for racer
                 "CARGO_HOME"         ; Cargo home, for racer
                 "EMAIL"              ; My personal email
                 "GPG_TTY"
                 "GPG_AGENT_INFO"
                 "SSH_AUTH_SOCK"
                 "SSH_AGENT_PID"
                 ))
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

;; ;; clean up the mode line
(setq minions-mode-line-lighter "☰")
(minions-mode 1)

;; No, we do not need the splash screen
(setq inhibit-startup-screen t)

(require 'better-defaults)
;; better defaults are well, better... but we don't always agree
(menu-bar-mode 1)
(scroll-bar-mode 1)

(setq select-active-regions 'only)

;; from https://github.com/bbatsov/prelude/
;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
;; autosave the undo-tree history
(setq undo-tree-history-directory-alist
      `((".*" . ,temporary-file-directory)))

;; scrolling behavior
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ; one line at a time
(setq mouse-wheel-progressive-speed nil) ; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ; scroll window under mouse
(setq scroll-preserve-screen-position t)
(setq scroll-conservatively 100000)
(setq scroll-error-top-bottom t)
(setq scroll-preserve-screen-position t)
;; scroll without moving point
(require 'smooth-scroll)
(global-set-key [(control down)] 'scroll-up-1)
(global-set-key [(control up)] 'scroll-down-1)
(global-set-key [(control left)] 'scroll-right-1)
(global-set-key [(control right)] 'scroll-left-1)

  ;; Use y/n instead of yes/no
  (fset 'yes-or-no-p 'y-or-n-p)

  (transient-mark-mode 1) ; makes the region visible
  (line-number-mode 1)    ; makes the line number show up
  (column-number-mode 1)  ; makes the column number show up

  ;; make home and end behave
  (global-set-key (kbd "<home>") 'move-beginning-of-line)
  (global-set-key (kbd "<end>") 'move-end-of-line)

  ;; enable toggling paragraph un-fill
  (define-key global-map "\M-Q" 'unfill-paragraph)

  ;;; line wrapping
  ;; neck beards be damned, we don't need to hard wrap. The editor can soft wrap for us.
  (remove-hook 'text-mode-hook 'turn-on-auto-fill)
  (add-hook 'visual-line-mode-hook 'adaptive-wrap-prefix-mode)
  (add-hook 'text-mode-hook 'visual-line-mode 1)
  (add-hook 'prog-mode-hook
            (lambda()
              (toggle-truncate-lines t)
              (outline-minor-mode t)))

  ;; indicate visual-line-mode wrap
  (setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))
  (setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))
  ;; but be gentle
  (defface visual-line-wrap-face
    '((t (:foreground "gray")))
    "Face for visual line indicators.")
  (set-fringe-bitmap-face 'left-curly-arrow 'visual-line-wrap-face)
  (set-fringe-bitmap-face 'right-curly-arrow 'visual-line-wrap-face)

  ;; don't require two spaces for sentence end.
  (setq sentence-end-double-space nil)

  ;; The beeping can be annoying--turn it off
  (setq visible-bell t
        ring-bell-function #'ignore)

  ;; save place -- move to the place I was last time I visited this file
  (save-place-mode t)

  ;; regular cursor
  (setq-default cursor-type '(bar . 3))
  (setq-default blink-cursor-blinks 0)
  (add-hook 'after-init-hook
            (lambda()
              (setq cursor-type '(bar . 3)
                    blink-cursor-blinks 0)))

  ;; easy navigation in read-only buffers
  (setq view-read-only t)
  (with-eval-after-load "view-mode"
    (define-key view-mode-map (kbd "s") 'isearch-forward-regexp))


  ;; set up read-only buffers
  (add-hook 'read-only-mode-hook 
            (lambda()
              (cond
               ((and (not buffer-read-only)
                     (not (eq (get major-mode 'mode-class) 'special)))
                (hl-line-mode -1)
                (setq-local blink-cursor-blinks 0)
                (setq-local cursor-type '(bar . 3))
                (company-mode t))
               ((and buffer-read-only
                     (not (eq (get major-mode 'mode-class) 'special)))
                (hl-line-mode t)
                (setq-local blink-cursor-blinks 1)
                (setq-local cursor-type 'box)
                (company-mode -1)))))

  ;; show parentheses
  (show-paren-mode 1)
  (setq show-paren-delay 0)

;; Use CUA mode to make life easier. We do _not__ use standard copy/paste etc. (see below).
(cua-mode t)

(cua-selection-mode t) ;; cua goodness without copy/paste etc.

;; load windows-style keys using windows key instead of control.
(require 'win-win)

;; ;; Make control-z undo
(global-undo-tree-mode t)
(global-set-key (kbd "C-z") 'undo)
(define-key undo-tree-map (kbd "C-S-z") 'undo-tree-redo)
(define-key undo-tree-map (kbd "C-x u") 'undo)
(define-key undo-tree-map (kbd "C-x U") 'undo-tree-visualize)
(define-key undo-tree-map (kbd "M-z") 'undo-tree-visualize)
;; Make C-g quit undo tree
(define-key undo-tree-visualizer-mode-map (kbd "C-g") 'undo-tree-visualizer-quit)
(define-key undo-tree-visualizer-mode-map (kbd "<escape> <escape> <escape>") 'undo-tree-visualizer-quit)

;;
;; Make right-click do something close to what people expect
(require 'mouse3)
(global-set-key (kbd "<mouse-3>") 'mouse3-popup-menu)
;; (global-set-key (kbd "C-f") 'isearch-forward)
;; (global-set-key (kbd "C-s") 'save-buffer)
;; (global-set-key (kbd "C-o") 'counsel-find-file)
(define-key cua-global-keymap (kbd "<C-S-SPC>") nil)
(define-key cua-global-keymap (kbd "<C-return>") nil)
(setq cua-rectangle-mark-key (kbd "<C-S-SPC>"))
(define-key cua-global-keymap (kbd "<C-S-SPC>") 'cua-rectangle-mark-mode)

;; zoom in/out like we do everywhere else.
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-mouse-5>") 'text-scale-decrease)
(global-set-key (kbd "<C-mouse-4>") 'text-scale-increase)
;; page up/down
(global-set-key (kbd "<C-prior>") 'beginning-of-buffer)
(global-set-key (kbd "<C-next>") 'end-of-buffer)

;; NOTE: keep an eye on ivy-views -- currently it doesn't remember window size, but if it gains that ability it will serve this purpose without additional dependancies.
;; Work spaces
(setq eyebrowse-keymap-prefix (kbd "C-c C-l"))
(eyebrowse-mode t)

;; Undo/redo window changes
(winner-mode 1)

;; windmove 
(global-set-key (kbd "C-x <S-left>") 'windmove-left)
(global-set-key (kbd "C-x <S-right>") 'windmove-right)
(global-set-key (kbd "C-x <S-up>") 'windmove-up)
(global-set-key (kbd "C-x <S-down>") 'windmove-down)

;; use ace-window for navigating windows
(global-set-key (kbd "C-x O") 'ace-window)
(with-eval-after-load "ace-window"
  (set-face-attribute 'aw-leading-char-face nil :height 2.5))

;; modified from https://github.com/aculich/.emacs.d/blob/master/init.el
(setq frame-title-format
      '(:eval (if (buffer-file-name)
                  (abbreviate-file-name (buffer-file-name)) "%b"))
      ;; Size new windows proportionally wrt other windows
      ;;window-combination-resize t
      )

;; enable on-the-fly spell checking
(setq flyspell-use-meta-tab nil)
(add-hook 'text-mode-hook
          (lambda ()
            (flyspell-mode 1)))
;; prevent flyspell from finding misspellings in code
(add-hook 'prog-mode-hook
          (lambda ()
            ;; `ispell-comments-and-strings'
            (flyspell-prog-mode)))

;; ispell should not check code blocks in org mode
(add-to-list 'ispell-skip-region-alist '(":\\(PROPERTIES\\|LOGBOOK\\):" . ":END:"))
(add-to-list 'ispell-skip-region-alist '("#\\+BEGIN_SRC" . "#\\+END_SRC"))
(add-to-list 'ispell-skip-region-alist '("#\\+begin_src" . "#\\+end_src"))
(add-to-list 'ispell-skip-region-alist '("^#\\+begin_example " . "#\\+end_example$"))
(add-to-list 'ispell-skip-region-alist '("^#\\+BEGIN_EXAMPLE " . "#\\+END_EXAMPLE$"))

;; Dictionaries
(global-set-key (kbd "C-c d") 'dictionary-search)
(global-set-key (kbd "C-c D") 'dictionary-match-words)

(when (eq system-type 'gnu/linux)
  (setq hfyview-quick-print-in-files-menu t)
  (require 'hfyview)
  (setq mygtklp (executable-find "gtklp"))
  (when mygtklp
    (setq lpr-command "gtklp")
    (setq ps-lpr-command "gtklp")))

(when (eq system-type 'darwin)
  (setq hfyview-quick-print-in-files-menu t)
  (require 'hfyview))

;; use ivy instead of ido
(ido-mode nil)
(ivy-mode 1)
(counsel-mode 1)
(require 'ivy-hydra)

;; make sure we wrap in the minibuffer
(setq ivy-truncate-lines nil)

;; more obvious separator for yank-pop
(setq counsel-yank-pop-separator "

-%<-%<-%<-%<-%<-%<-%<-%<-%<-%<-%<-%<

")

(setq counsel-find-file-ignore-regexp "\\`\\.")
(setq ivy-use-virtual-buffers t)
(setq ivy-count-format "(%d/%d) ")
;; (setq ivy-display-style nil)

;; Ivy-based interface to describe keybindings
(global-set-key (kbd "C-h b") 'counsel-descbinds)

;; isearch
(setq enable-recursive-minibuffers t
      isearch-allow-scroll t)
(require 'hl-line)
(require 'anzu)
(global-anzu-mode +1)
(global-set-key (kbd "C-s") 'isearch-forward)
(global-set-key (kbd "C-S-s") 'isearch-forward-regexp)
(defun my-turn-on-hl-line ()
  (setq old-hl-line-mode-value hl-line-mode)
  (hl-line-mode 1))
(defun my-toggle-hl-line ()
  (unless old-hl-line-mode-value (hl-line-mode -1)))
(add-hook 'isearch-mode-hook 'my-turn-on-hl-line)
(add-hook 'isearch-mode-end-hook 'my-toggle-hl-line)
;; from https://emacs.stackexchange.com/questions/10307/how-to-center-the-current-line-vertically-during-isearch
(defadvice isearch-update (before my-isearch-reposite activate)
   (sit-for 0)
   (recenter))
(define-key isearch-mode-map (kbd "C-'") 'avy-isearch)
(define-key isearch-mode-map (kbd "C-n") 'isearch-repeat-forward)
(define-key isearch-mode-map (kbd "C-p") 'isearch-repeat-backward)
(define-key isearch-mode-map (kbd "C-p") 'isearch-repeat-backward)
(define-key isearch-mode-map (kbd "C-o") 'isearch-occur)

;; visual query replace
(global-set-key (kbd "C-r") 'vr/query-replace)
(global-set-key (kbd "C-S-r") 'vr/replace)
;; default file searcher if we don't find something better
(global-set-key (kbd "C-c f") 'find-grep-dired)
(global-set-key (kbd "C-c f") 'find-grep-dired)
;; use better searching tool if available
(cond
 ((executable-find "rg") ; search with ripgrep if we have it
  (global-set-key (kbd "C-c f") 'counsel-rg)
  (global-set-key (kbd "C-c s") 'counsel-rg))
 ((executable-find "ag") ; otherwise search with ag if we have it
  (global-set-key (kbd "C-c f") 'counsel-ag)
  (global-set-key (kbd "C-c s") 'counsel-ag))
 ((executable-find "pt") ; otherwise search with pt if we have it
  (global-set-key (kbd "C-c f") 'counsel-pt)
  (global-set-key (kbd "C-c f") 'counsel-pt)))
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "M-y") 'counsel-yank-pop)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "C-o") 'counsel-find-file)
;; search for files to open with "C-O=
(when (memq window-system '(mac ns)) ; use mdfind on Mac. TODO: what about windows?
  (setq locate-command "mdfind")
  (setq counsel-locate-cmd 'counsel-locate-cmd-mdfind))
;; default file-finding in case we don't have something better
(global-set-key (kbd "C-x C-S-F") 'find-name-dired)
(global-set-key (kbd "C-c l") 'find-name-dired)
;; use locate if we have it.
(when (executable-find "locate")
  (global-set-key (kbd "C-c l") 'counsel-locate)
  ;;(global-set-key (kbd "C-x C-S-F") 'counsel-locate) ;; FIXME -- need better key
  )
(global-set-key (kbd "C-x C-r") 'counsel-recentf)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-load-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
;; Ivy-based interface to shell and system tools
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c k") 'counsel-ag)

;; Ivy-resume and other commands

(global-set-key (kbd "C-c i") 'ivy-resume)

;; Make Ivy more like ido
(define-key ivy-minibuffer-map (kbd "<return>") 'ivy-alt-done)
(define-key ivy-minibuffer-map (kbd "C-d") 'ivy-done)
(define-key ivy-minibuffer-map (kbd "C-b") 'ivy-immediate-done)
(define-key ivy-minibuffer-map (kbd "C-f") 'ivy-immediate-done)

(defun my-toggle-truncate-lines ()
  "Toggle truncate lines in quietly."
  (interactive)
  (let ((inhibit-message t))
    (toggle-truncate-lines)))
(define-key ivy-minibuffer-map (kbd "C-l") 'my-toggle-truncate-lines)
(define-key swiper-map (kbd "C-l") 'my-toggle-truncate-lines)

;; show recently opened files
(with-eval-after-load "recentf"
  (setq recentf-max-menu-items 50)
  (add-to-list 'recentf-exclude "/\\.git/.*\\'")
  (add-to-list 'recentf-exclude "/elpa/.*\\'")
  (add-to-list 'recentf-exclude "/tramp.*\\'")
  (add-to-list 'recentf-exclude "/sudo.*\\'"))
(recentf-mode 1)

;; better occur mode
(add-hook 'occur-mode-hook
          (lambda()
            (toggle-truncate-lines t)
            (setq-local cursor-type 'box)
            (setq-local blink-cursor-blinks 1)
            (company-mode -1)
            (hl-line-mode t)
            (next-error-follow-minor-mode t)))

;; Jump easy to definition
(setq dumb-jump-selector 'ivy
      dumb-jump-aggressive nil
      dumb-jump-default-project "./")

(require 'company)
;; cancel if input doesn't match, be patient, and don't complete automatically.
(setq company-require-match nil
      company-async-timeout 6
      company-idle-delay 5
      company-minimum-prefix-length 1
      company-global-modes '(not term-mode))
;; use C-n and C-p to cycle through completions
(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "<tab>") 'company-complete-common)
(define-key company-active-map (kbd "C-p") 'company-select-previous)
(define-key company-active-map (kbd "<backtab>") 'company-select-previous)

(require 'company-capf)
;; put company-capf and company-files at the beginning of the list
(push 'company-keywords company-backends)
(push 'company-capf company-backends)
(push 'company-files company-backends)
(setq-default company-backends company-backends)

;; completion key bindings
(define-key company-mode-map (kbd "C-M-i") 'company-complete)
(define-key company-mode-map (kbd "C-M-S-i") 'counsel-company)

 ;; make company use pcomplete (via capf)
 (add-hook 'completion-at-point-functions 'pcomplete-completions-at-point)

 ;; not sure why this should be set in a hook, but that is how the manual says to do it.
 (add-hook 'after-init-hook 'global-company-mode)

;; which-key settings taken mostly from https://github.com/aculich/.emacs.d/blob/master/init.el
(with-eval-after-load "which-key"
  (setq which-key-sort-order 'which-key-prefix-then-key-order
        ;; Let's go unicode :)
        which-key-key-replacement-alist
        '(("<\\([[:alnum:]-]+\\)>" . "\\1")
          ("up"                    . "↑")
          ("right"                 . "→")
          ("down"                  . "↓")
          ("left"                  . "←")
          ("DEL"                   . "⌫")
          ("deletechar"            . "⌦")
          ("RET"                   . "⏎"))
        which-key-description-replacement-alist
        '(("Prefix Command" . "prefix")
          ;; Lambdas
          ("\\`\\?\\?\\'"   . "λ")
          ;; Prettify hydra entry points
          ("/body\\'"       . "|=")
          ;; Drop/shorten package prefixes
          ("eyebrowse-"     . "")
          ("magit-"         . "ma-")))

  (which-key-declare-prefixes
   ;; Prefixes for global prefixes and minor modes
   "C-c C-o" "outline"
   "C-c C-l" "window/layouts"
   "C-c !" "flycheck")

  ;; Prefixes for major modes
  (which-key-declare-prefixes-for-mode 'markdown-mode
                                       "C-c TAB" "markdown/images"
                                       "C-c C-a" "markdown/links"
                                       "C-c C-c" "markdown/process"
                                       "C-c C-s" "markdown/style"
                                       "C-c C-t" "markdown/header"
                                       "C-c C-x" "markdown/structure"
                                       "C-c m" "markdown/personal")

  (which-key-declare-prefixes-for-mode 'emacs-lisp-mode
                                       "C-c m" "elisp"
                                       "C-c m e" "eval")

  (which-key-declare-prefixes-for-mode 'scala-mode
                                       "C-c C-b" "ensime/build"
                                       "C-c C-d" "ensime/debug"
                                       "C-c C-r" "ensime/refactor"
                                       "C-c C-v" "ensime/misc"
                                       "C-c m" "scala/personal"
                                       "C-c m b" "scala/build")

  (which-key-declare-prefixes-for-mode 'haskell-mode
                                       "C-c m" "haskell/personal"
                                       "C-c m i" "haskell/imports")

  (which-key-declare-prefixes-for-mode 'web-mode
                                       "C-c C-a" "web/attributes"
                                       "C-c C-b" "web/blocks"
                                       "C-c C-d" "web/dom"
                                       "C-c C-e" "web/element"
                                       "C-c C-t" "web/tags"))

(which-key-mode t)

;; (require 'flycheck)
;; (global-flycheck-mode)

;;; Configure outline minor modes
;; Less crazy key bindings for outline-minor-mode
(setq outline-minor-mode-prefix "\C-c\C-o")
;; load outline-magic along with outline-minor-mode
(add-hook 'outline-minor-mode-hook 
          (lambda ()
            (require 'outline-magic)
             ;; (when (derived-mode-p 'prog-mode)
             ;;   (outshine-hook-function))
             ;; ;; outshine messes with keybindings :-(
             ;; (define-key
             ;;   outline-minor-mode-map (kbd "C-M-i") 'company-complete)
             ;; (define-key
             ;;   outline-minor-mode-map (kbd "M-TAB") 'company-complete)
             ;; (define-key outline-minor-mode-map "\C-c\C-o\t" 'outline-cycle)
             ))

(with-eval-after-load "outshine"
  (define-key
    outline-minor-mode-map
    (kbd "<backtab>")
    'outshine-cycle-buffer))

(setq command-log-mode-auto-show t)
(global-set-key (kbd "C-x cl") 'global-command-log-mode)

;; require the main file containing common functions
(require 'eval-in-repl)
(setq comint-process-echoes t
      eir-repl-placement 'below)

;; truncate lines in comint buffers
(add-hook 'comint-mode-hook
          (lambda()
            (setq truncate-lines 1)))

;; Scroll down for input and output
(setq comint-scroll-to-bottom-on-input t)
(setq comint-scroll-to-bottom-on-output t)
(setq comint-move-point-for-output t)

;;;  ESS (Emacs Speaks Statistics)

;; Make sure ESS is loaded before we configure it
(autoload 'julia "ess-julia" "Start a Julia REPL." t)
(with-eval-after-load "ess-site"
  (ess-toggle-underscore nil) ; Don't convert underscores to assignment
  ;; function to set output width based on window size
  (defun my-ess-execute-screen-options (foo)
    "cycle through windows whose major mode is inferior-ess-mode and fix width"
    (interactive)
    (setq my-windows-list (window-list))
    (while my-windows-list
      (when (with-selected-window (car my-windows-list) (string= "inferior-ess-mode" major-mode))
        (with-selected-window (car my-windows-list) (ess-execute-screen-options t)))
      (setq my-windows-list (cdr my-windows-list))))
  (add-to-list 'window-size-change-functions 'my-ess-execute-screen-options)

  ;; standard control-enter evaluation
  (define-key ess-mode-map (kbd "<C-return>") 'ess-eval-region-or-function-or-paragraph-and-step)
  (define-key ess-mode-map (kbd "<C-S-return>") 'ess-eval-buffer)

  ;; set up when entering ess-mode
  (add-hook 'ess-mode-hook
            (lambda()
              ;; don't indent comments
              (setq ess-indent-with-fancy-comments nil)
              ;; don't wrap long lines
              (toggle-truncate-lines t)
              ;; turn on outline mode
              (outline-minor-mode t)))

  ;; Set ESS options
  (setq
   ess-use-auto-complete nil
   ess-use-company 't
   ;; ess-r-package-auto-set-evaluation-env nil
   inferior-ess-same-window nil
   ess-indent-with-fancy-comments nil   ; don't indent comments
   ess-eval-visibly t                   ; enable echoing input
   ess-eval-empty t                     ; don't skip non-code lines.
   ess-ask-for-ess-directory nil        ; start R in the working directory by default
   ess-ask-for-ess-directory nil        ; start R in the working directory by default
   ess-R-font-lock-keywords             ; font-lock, but not too much
   (quote
    ((ess-R-fl-keyword:modifiers)
     (ess-R-fl-keyword:fun-defs . t)
     (ess-R-fl-keyword:keywords . t)
     (ess-R-fl-keyword:assign-ops  . t)
     (ess-R-fl-keyword:constants . 1)
     (ess-fl-keyword:fun-calls . t)
     (ess-fl-keyword:numbers)
     (ess-fl-keyword:operators . t)
     (ess-fl-keyword:delimiters)
     (ess-fl-keyword:=)
     (ess-R-fl-keyword:F&T)))))

(defalias 'python 'run-python)

(with-eval-after-load "python"
  ;; try to get indent/completion working nicely
  ;; readline support is wonky at the moment
  (setq python-shell-completion-native-enable nil)
  ;; simple evaluation with C-ret
  (require 'eval-in-repl-python)
  (add-hook 'python-mode-hook
            '(lambda()
               (setq-local company-backends company-backends)
               (setq-local company-backends
                           (delete-dups (push 'company-capf company-backends)))))
  (add-hook 'inferior-python-mode-hook
            '(lambda()
               (setq-local company-backends company-backends)
               (setq-local company-backends
                           (delete-dups (push 'company-capf company-backends)))))
  ;;(setq eir-use-python-shell-send-string nil)
  (define-key python-mode-map (kbd "C-c C-c") 'eir-eval-in-python)
  (define-key python-mode-map (kbd "<C-return>") 'eir-eval-in-python)
  (define-key python-mode-map (kbd "C-c C-b") 'python-shell-send-buffer)
  (define-key python-mode-map (kbd "<C-S-return>") 'python-shell-send-buffer))

;; make outline work
(add-hook 'python-mode-hook
          (lambda()
            ;;(setq-local outline-regexp "[#]+")
            (outline-minor-mode t)))

(with-eval-after-load "elisp-mode"
  (require 'company-elisp)
  ;; ielm
  (require 'eval-in-repl-ielm)
  ;; For .el files
  (define-key emacs-lisp-mode-map (kbd "C-c C-c") 'eir-eval-in-ielm)
  (define-key emacs-lisp-mode-map (kbd "<C-return>") 'eir-eval-in-ielm)
  (define-key emacs-lisp-mode-map (kbd "C-c C-b") 'eval-buffer)
  (define-key emacs-lisp-mode-map (kbd "<C-S-return>") 'eval-buffer)
  ;; For *scratch*
  (define-key lisp-interaction-mode-map "\C-c\C-c" 'eir-eval-in-ielm)
  (define-key lisp-interaction-mode-map (kbd "<C-return>") 'eir-eval-in-ielm)
  (define-key lisp-interaction-mode-map (kbd "C-c C-b") 'eval-buffer)
  (define-key lisp-interaction-mode-map (kbd "<C-S-return>") 'eval-buffer)
  ;; For M-x info
  (define-key Info-mode-map (kbd "C-c C-c") 'eir-eval-in-ielm)
  ;; Set up completions
  (add-hook 'emacs-lisp-mode-hook
            (lambda()
              ;; make sure completion calls company-elisp first
              (require 'company-elisp)
              (setq-local company-backends
                          (delete-dups (cons 'company-elisp (cons 'company-files company-backends)))))))

(with-eval-after-load "haskell-mode"
  (defalias 'haskell 'haskell-interactive-bring)
  (add-hook 'haskell-mode-hook
            '(lambda ()
               (push 'company-capf company-backends)
               (setq-local company-backends
                           (delete-dups (push 'company-ghci company-backends)))))
  (add-hook 'haskell-interactive-mode-hook 'company-mode)
  (when (executable-find "stack")
    (intero-global-mode 1)))

;; Use markdown-mode for files with .markdown or .md extensions
(setq
 markdown-enable-math t
 markdown-fontify-code-blocks-natively t)
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
(add-hook 'markdown-mode-hook 'turn-on-orgtbl)
(when (executable-find "pandoc")
  (add-hook 'markdown-mode-hook 'pandoc-mode))

(add-to-list 'auto-mode-alist `("\\.html?\\'" . web-mode))

;;; AucTeX config

;; Modified from https://emacs.stackexchange.com/questions/33198/how-to-get-auctex-to-automatically-generate-atex-engineluatex-file-variable-d/33204
 (defun iqss-prompt-tex-engine ()
   (when (eq major-mode 'latex-mode)
     ;; Check if we are looking at a new or shared file that doesn't specify a TeX engine.
     (when (and (not buffer-read-only)
                (not (member 'TeX-engine (mapcar 'car file-local-variables-alist))))
       (save-excursion
         (add-file-local-variable
          'TeX-engine
          (intern (completing-read "TeX engine not set, how should this document be typeset?: "
                                   (mapcar 'car (TeX-engine-alist)) nil nil nil nil "default"))))
       (TeX-normal-mode t)
       (blink-cursor-start))))

(add-hook
 'find-file-hook
 (lambda() (run-at-time "0.5 sec" nil 'iqss-prompt-tex-engine)))

(with-eval-after-load "Latex"
  ;; Highlight beamer alert
  (setq font-latex-user-keyword-classes
        '(("beamer-alert" (("alert" "{")
                           ("alerta" "{")
                           ("alertb" "{")
                           ("alertc" "{")
                           ("alertd" "{")
                           ("alerte" "{"))
           font-latex-bold-face command)))
  ;; Easy compile key
  (define-key LaTeX-mode-map (kbd "<C-return>") 'TeX-command-run-all)
  (defun my-tex-quit ()
    (interactive)
    "Kill any running tex jobs, and cancel other operations."
    (TeX-kill-job)
    (keyboard-quit))

  (define-key LaTeX-mode-map (kbd "C-g")
    'my-tex-quit)
  ;; Allow paragraph filling in tables
  (setq LaTeX-indent-environment-list
        (delq (assoc "table" LaTeX-indent-environment-list)
              LaTeX-indent-environment-list))
  (setq LaTeX-indent-environment-list
        (delq (assoc "table*" LaTeX-indent-environment-list)
              LaTeX-indent-environment-list))
  ;; Misc. latex settings
  (setq TeX-parse-self t
        TeX-auto-save t)
  ;; (setq TeX-master 'dwim)
  (setq TeX-save-query nil)
  (setq-default TeX-master 'dwim)
  ;; Add beamer frames to outline list
  (setq TeX-outline-extra
        '((".*\\\\begin{frame}\n\\|.*\\\\begin{frame}\\[.*\\]\\|.*\\\\begin{frame}.*{.*}\\|.*[       ]*\\\\frametitle\\b" 3)))
  ;; reftex settings
  (setq reftex-enable-partial-scans t)
  (setq reftex-save-parse-info t)
  (setq reftex-use-multiple-selection-buffers t)
  (setq reftex-plug-into-AUCTeX t)
  (add-hook 'TeX-mode-hook
            (lambda ()
              (turn-on-reftex)
              (TeX-PDF-mode t)
              (LaTeX-math-mode)
              (TeX-source-correlate-mode t)
              (imenu-add-to-menubar "Index")
              (outline-minor-mode)
              (require 'company-math)
              (setq-local company-backends (delete-dups
                                            (cons '(company-capf company-math-symbols-latex)
                                                  (cons 'company-files company-backends))))
              ;; (reftex-toc)
              ;; (reftex-toc-goto-line)
              ;; (run-at-time 1 nil (lambda()
              ;;                      (reftex-toc)
              ;;                      (reftex-toc-goto-line)))
              ))
  ;; Use pdf-tools to open PDF files
  (when (eq system-type 'gnu/linux)
    (pdf-tools-install)
    (setq TeX-view-program-selection '((output-pdf "PDF Tools")))
    TeX-source-correlate-start-server t
    ;; Update PDF buffers after successful LaTeX runs
    (add-hook 'TeX-after-compilation-finished-functions
              #'TeX-revert-document-buffer))

  ;; Count words in latex
  ;; see http://app.uio.no/ifi/texcount/faq.html#emacs
  ;; TeXcount setup for TeXcount version 2.3 and later
  ;;
  (when (executable-find "texcount")
    (defun texcount ()
      (interactive)
      (let*
          ((this-file (buffer-file-name))
           (enc-str (symbol-name buffer-file-coding-system))
           (enc-opt
            (cond
             ((string-match "utf-8" enc-str) "-utf8")
             ((string-match "latin" enc-str) "-latin1")
             ("-encoding=guess")))
           (word-count
            (with-output-to-string
              (with-current-buffer standard-output
                (call-process "texcount" nil t nil "-0" enc-opt this-file)))))
        (message word-count)))
    (defalias 'tex-count-words 'texcount "Count the number of words in the buffer."))
  (define-key LaTeX-mode-map "\C-cw" 'tex-count-words)
  (add-to-list 'TeX-command-list
               (list "TeX-count-words" "tex-count-words" 'TeX-run-function nil t)))

(with-eval-after-load "reftex"
  (add-to-list 'reftex-section-levels '("frametitle" . 2))
  (setq reftex-toc-split-windows-horizontally t)
  (add-hook 'reftex-toc-mode-hook (lambda() (company-mode -1))))

(with-eval-after-load "bibtex"
  (add-hook 'bibtex-mode-hook
            (lambda ()
              (define-key bibtex-mode-map "\M-q" 'bibtex-fill-entry))))

(setq ivy-bibtex-default-action 'ivy-bibtex-insert-citation)
(global-set-key (kbd "C-c r") 'ivy-bibtex)

(with-eval-after-load "org"
  (setq org-replace-disputed-keys t
        org-support-shift-select t)
  (setf (alist-get ':eval org-babel-default-header-args) "never-export"
        (alist-get ':exports org-babel-default-header-args) "both")
  ;; (setq org-startup-indented t)
  ;; increase imenu depth to include third level headings
  (setq org-imenu-depth 3)
  ;; Set sensible mode for editing dot files
  (add-to-list 'org-src-lang-modes '("dot" . graphviz-dot))
  ;; Update images from babel code blocks automatically
  (add-hook 'org-babel-after-execute-hook 'org-display-inline-images)
  ;; configure org-mode when opening first org-mode file
  ;; Load additional export formats
  (require 'ox-ascii)
  (require 'ox-md)
  (require 'ox-html)
  (require 'ox-latex)
  (require 'ox-odt)
  (when (executable-find "pandoc")
    (require 'ox-pandoc))

  (require 'org-capture)
  (require 'org-protocol)

  ;; Enable common programming language support in org-mode
  (require 'ob-shell)
  (require 'ob-emacs-lisp)
  (require 'ob-org)
  (when (executable-find "R") 
      (require 'ess-site)
      (require 'ob-R))
  (when (executable-find "python") (require 'ob-python))
  (when (executable-find "matlab") (require 'ob-matlab))
  (when (executable-find "octave") (require 'ob-octave))
  (when (executable-find "perl") (require 'ob-perl))
  (when (executable-find "dot") (require 'ob-dot))
  (when (executable-find "ghci") (require 'ob-haskell))
  (when (executable-find "ditaa") (require 'ob-ditaa))

  ;; Fontify code blocks in org-mode
  (setq org-src-fontify-natively t)
  (setq org-src-tab-acts-natively t)
  (setq org-confirm-babel-evaluate nil))

;;; polymode
;; polymode requires emacs >= 24.3, does not work on the RCE. 
(when (>= (string-to-number 
           (concat 
            (number-to-string emacs-major-version) 
            "." 
            (number-to-string emacs-minor-version)))
          24.3)
  (with-eval-after-load "polymode"
    ;; make it work for knitr with julia blocks
    (add-to-list 'polymode-mode-name-override-alist '(julia . ess-julia)))

  ;; Activate polymode for files with the .md extension
  (add-to-list 'auto-mode-alist '("\\.md" . poly-markdown-mode))
  ;; Activate polymode for R related modes
  (add-to-list 'auto-mode-alist '("\\.Snw" . poly-noweb+r-mode))
  (add-to-list 'auto-mode-alist '("\\.Rnw" . poly-noweb+r-mode))
  (add-to-list 'auto-mode-alist '("\\.Rmd" . poly-markdown+r-mode))
  (add-to-list 'auto-mode-alist '("\\.rapport" . poly-rapport-mode))
  (add-to-list 'auto-mode-alist '("\\.Rhtml" . poly-html+r-mode))
  (add-to-list 'auto-mode-alist '("\\.Rbrew" . poly-brew+r-mode))
  (add-to-list 'auto-mode-alist '("\\.Rcpp" . poly-r+c++-mode))
  (add-to-list 'auto-mode-alist '("\\.cppR" . poly-c++r-mode))
  ;; polymode doesn't play nice with adaptive-wrap, turn it off
  (add-hook 'polymode-init-host-hook
            '(lambda()
               (adaptive-wrap-prefix-mode -1)
               (electric-indent-local-mode -1)
               (unless (featurep 'ess-site)
                 (require 'ess-site)))))

(when (executable-find "mu")
  (autoload 'mu4e "mu4e" "Read your mail." t)
  (with-eval-after-load "mu4e"
    (require 'mu4e)
    (require 'mu4e-headers)
    (setq mu4e-headers-include-related t
          mu4e-headers-show-threads nil
          mu4e-headers-skip-duplicates t
          ;; don't keep message buffers around
          message-kill-buffer-on-exit t
          ;; enable notifications
          mu4e-enable-mode-line t
          mu4e-headers-fields '(
                                (:human-date . 12)
                                (:flags . 6)
                                ;; (:mailing-list . 10)
                                (:from-or-to . 22)
                                (:subject)))
    ;; ;; use org for composing rich text emails
    ;; (require 'org-mu4e)
    ;; (setq org-mu4e-convert-to-html t)
    ;; (define-key mu4e-headers-mode-map (kbd "C-c c") 'org-mu4e-store-and-capture)
    ;; (define-key mu4e-view-mode-map    (kbd "C-c c") 'org-mu4e-store-and-capture)
    ;; 
    ;; rerender html
    (require 'mu4e-contrib)
    (setq mu4e-html2text-command 'mu4e-shr2text)
    (add-hook 'mu4e-view-mode-hook 'visual-line-mode)))

;;; Dired configuration
(add-hook 'dired-mode-hook 
          (lambda()
            (diff-hl-dired-mode)
            (diff-hl-margin-mode)))

;; show details by default
(setq diredp-hide-details-initially-flag nil)

;; set dired listing options
(if (eq system-type 'gnu/linux)
    (setq dired-listing-switches "-alDhp"))

;; make sure dired buffers end in a slash so we can identify them easily
(defun ensure-buffer-name-ends-in-slash ()
  "change buffer name to end with slash"
  (let ((name (buffer-name)))
    (if (not (string-match "/$" name))
        (rename-buffer (concat name "/") t))))
(add-hook 'dired-mode-hook 'ensure-buffer-name-ends-in-slash)
(add-hook 'dired-mode-hook
          (lambda()
             (setq truncate-lines 1)))

;; open files in external programs
;; (from http://ergoemacs.org/emacs/emacs_dired_open_file_in_ext_apps.html
;; consider replacing with https://github.com/thamer/runner
(defun xah-open-in-external-app (&optional file)
  "Open the current file or dired marked files in external app.

The app is chosen from your OS's preference."
  (interactive)
  (let (doIt
        (myFileList
         (cond
          ((string-equal major-mode "dired-mode")
           (dired-get-marked-files))
          ((not file) (list (buffer-file-name)))
          (file (list file)))))
    (setq doIt (if (<= (length myFileList) 5)
                   t
                 (y-or-n-p "Open more than 5 files? "))) 
    (when doIt
      (cond
       ((string-equal system-type "windows-nt")
        (mapc
         (lambda (fPath)
           (w32-shell-execute "open" (replace-regexp-in-string "/" "\\" fPath t t)))
         myFileList))
       ((string-equal system-type "darwin")
        (mapc
         (lambda (fPath)
           (shell-command (format "open \"%s\"" fPath)))
         myFileList))
       ((string-equal system-type "gnu/linux")
        (mapc
         (lambda (fPath)
           (let ((process-connection-type nil))
             (start-process "" nil "xdg-open" fPath))) myFileList))))))
;; use zip/unzip to compress/uncompress zip archives
(with-eval-after-load "dired-aux"
  (add-to-list 'dired-compress-file-suffixes 
               '("\\.zip\\'" "" "unzip"))
  ;; open files from dired with "E"
  (define-key dired-mode-map (kbd "E") 'xah-open-in-external-app))

(with-eval-after-load "git-commit"
  (require 'magit))

;; term
(with-eval-after-load "term"
  (define-key term-mode-map (kbd "C-j") 'term-char-mode)
  (define-key term-raw-map (kbd "C-j") 'term-line-mode)
  (require 'with-editor)
  (when (executable-find "git") (require 'git-commit))
  (shell-command-with-editor-mode t))

;; multi-term
(defun terminal ()
  "Create new term buffer.
Will prompt you shell name when you type `C-u' before this command."
  (interactive)
  (require 'multi-term)
  (let (term-buffer)
    ;; Set buffer.
    (setq term-buffer (multi-term-get-buffer current-prefix-arg))
    (setq multi-term-buffer-list (nconc multi-term-buffer-list (list term-buffer)))
    (set-buffer term-buffer)
    ;; Internal handle for `multi-term' buffer.
    (multi-term-internal)
    (with-editor-export-editor)
    (with-editor-export-git-editor)
    (call-interactively 'comint-clear-buffer)
    ;; Switch buffer
    ;;(display-buffer term-buffer t)
    (pop-to-buffer term-buffer)
    ))

(with-eval-after-load "multi-term"
  (define-key term-mode-map (kbd "C-j") 'term-char-mode)
  (define-key term-raw-map (kbd "C-j") 'term-line-mode)
  (require 'with-editor)
  (when (executable-find "git") (require 'git-commit))
  (setq multi-term-switch-after-close nil)
  (shell-command-with-editor-mode t))

;; shell
(with-eval-after-load "sh-script"
  (require 'essh) ; if not done elsewhere; essh is in the local lisp folder
  (require 'eval-in-repl-shell)
  (define-key sh-mode-map "\C-c\C-c" 'eir-eval-in-shell)
  (define-key sh-mode-map (kbd "<C-return>") 'eir-eval-in-shell)
  (define-key sh-mode-map (kbd "<C-S-return>") 'executable-interpret))
(with-eval-after-load "shell"
  (require 'with-editor)
  (when (executable-find "git") (require 'git-commit))
  (shell-command-with-editor-mode t))

(with-eval-after-load "eshell"
  (require 'with-editor)
  (when (executable-find "git") (require 'git-commit))
  (shell-command-with-editor-mode t))

;; Automatically adjust output width in commint buffers
;; from http://stackoverflow.com/questions/7987494/emacs-shell-mode-display-is-too-wide-after-splitting-window
(defun comint-fix-window-size ()
  "Change process window size."
  (when (derived-mode-p 'comint-mode)
    (let ((process (get-buffer-process (current-buffer))))
      (unless (eq nil process)
        (set-process-window-size process (window-height) (window-width))))))

(defun my-shell-mode-hook ()
  ;; add this hook as buffer local, so it runs once per window.
  (add-hook 'window-configuration-change-hook 'comint-fix-window-size nil t))

(add-hook 'shell-mode-hook
          (lambda()
            ;; add this hook as buffer local, so it runs once per window.
            (add-hook 'window-configuration-change-hook 'comint-fix-window-size nil t)))

;; Use emacs as editor when running external processes or using shells in emacs
(when (and (string-match-p "remacs" (prin1-to-string (frame-list)))
           (executable-find "remacsclient"))
  (setq with-editor-emacsclient-executable (executable-find "remacsclient")))


(add-hook 'shell-mode-hook
          (lambda()
            (with-editor-export-editor)
            (with-editor-export-git-editor)
            ;;(sleep-for 0.5) ; this is bad, but thinking hurts and it works.
            (call-interactively 'comint-clear-buffer)))

;; (add-hook 'term-exec-hook
;;           (lambda()            
;;             (with-editor-export-editor)
;;             (with-editor-export-git-editor)
;;             (call-interactively 'comint-clear-buffer)
;;             ;; (term-send-return)
;;             ;; (term-send-return)
;;             ;; (term-send-return)
;;             ;; (call-interactively 'comint-clear-buffer)
;;             ))

(add-hook 'eshell-mode-hook
          (lambda()
            ;; programs that don't work well in eshell and should be run in visual mode
            (add-to-list 'eshell-visual-commands "ssh")
            (add-to-list 'eshell-visual-commands "tail")
            (add-to-list 'eshell-visual-commands "htop")
            ;; git editor support
            (with-editor-export-editor)
            (with-editor-export-git-editor)))

;; save settings made using the customize interface to a sparate file
(setq custom-file (concat user-emacs-directory "custom.el"))
(unless (file-exists-p custom-file)
  (write-region ";; Put user configuration here" nil custom-file))
(load custom-file 'noerror)

;; start with untitled new buffer
(add-hook 'after-init-hook
          (lambda()
            (setq inhibit-startup-screen t) ;; yes, we really want to do this!
            (delete-other-windows)
            (untitled-new-buffer-with-select-major-mode 'text-mode)))

(setq untitled-new-buffer-major-modes '(text-mode python-mode r-mode markdown-mode LaTeX-mode emacs-lisp-mode))
;; Change default buffer name.
(setq untitled-new-buffer-default-name "*Untitled*")

;; Start the server if it is not already running
(require 'server)
(unless (server-running-p) (server-start))
