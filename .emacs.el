(setq-default user-full-name "Jorge Dodsworth"
              user-email-address "jorgepumar@hotmail.com")


; Upgrade or install remote packages.
(package-initialize)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/"))

; General settings.
(setq-default colon-double-space t
              fill-column 76
              indent-tabs-mode nil
              inhibit-startup-echo-area-message "jorge"
              inhibit-startup-screen  t
              initial-scratch-message ""
              require-final-newline t
              visible-bell t)

(auto-fill-mode 1)
(blink-cursor-mode 0)
(column-number-mode 1)
(display-time-mode 1)
(show-paren-mode 1)
(transient-mark-mode 1)
(winner-mode 1)


; Backups.
(setq backup-dir "~/.emacs.d/backups"
      delete-old-versions t
      make-backup-files t
      version-control t)
(make-directory backup-dir t)
(add-to-list 'backup-directory-alist `(".*" . ,backup-dir))


; Key-bindings.
(global-set-key (kbd "M-h") 'backward-kill-word)
(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "M-n") 'forward-paragraph)
(global-set-key (kbd "M-[") 'backward-page)
(global-set-key (kbd "M-]") 'forward-page)
(global-set-key (kbd "M-<left>") 'windmove-left)
(global-set-key (kbd "M-<down>") 'windmove-down)
(global-set-key (kbd "M-<up>") 'windmove-up)
(global-set-key (kbd "M-<right>") 'windmove-right)
(global-unset-key (kbd "C-;"))
(global-unset-key (kbd "C-z"))


; Input method.
(prefer-coding-system 'utf-8)
(setq default-input-method "portuguese-prefix")

(defun my-toggle-input-method-and-dictionary ()
  "Toggles default input method and dictionary."
  (interactive)
  (toggle-input-method)
  (if (equal current-input-method default-input-method)
      (ispell-change-dictionary "brasileiro")
    (ispell-change-dictionary "default")))

(add-to-list 'safe-local-variable-values
             '(eval my-toggle-input-method-and-dictionary))
(global-set-key (kbd "C-M-\\") 'my-toggle-input-method-and-dictionary)


; Hooks.
(defun my-text-mode-startup ()
  (flyspell-mode 1)
  (writegood-mode 1))

(add-hook 'latex-mode-hook 'my-text-mode-startup)
(add-hook 'latex-extra-mode-hook 'my-text-mode-startup)
(add-hook 'org-mode-hook 'my-text-mode-startup)
(add-hook 'tex-mode-hook 'my-text-mode-startup)
(add-hook 'text-mode-hook 'my-text-mode-startup)

(add-hook 'bibtex-mode-hook
          (lambda ()
            (progn (auto-fill-mode -1)
                   (delq 'lines-tail whitespace-style)
                   (flyspell-mode 1))))

(defun my-prog-mode-startup ()
  (flyspell-prog-mode))

(add-hook 'conf-colon-mode-hook 'my-prog-mode-startup)
(add-hook 'conf-space-mode-hook 'my-prog-mode-startup)
(add-hook 'conf-unix-mode-hook 'my-prog-mode-startup)
(add-hook 'conf-xdefaults-mode-hook 'my-prog-mode-startup)
(add-hook 'prog-mode-hook 'my-prog-mode-startup)


; Mode-specific setup.

; ansi-color
(when (require 'ansi-color)
  (add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
  (add-to-list 'comint-output-filter-functions 'ansi-color-process-output)
  (defun colorize-compilation-buffer ()
    (toggle-read-only)
    (ansi-color-apply-on-region compilation-filter-start (point))
    (toggle-read-only))
  (add-hook 'compilation-filter-hook 'colorize-compilation-buffer))

; battery
(when (require 'battery nil 'no-error)
  (when (and battery-status-function
             (not (string-match-p
                   "N/A"
                   (battery-format "%B"
                                   (funcall battery-status-function)))))
    (display-battery-mode 1)))

; compile
(global-set-key (kbd "C-c m") 'compile)

; dictionary
(autoload 'dictionary-search "dictionary"
  "Search word in all dictionaries" t)
(autoload 'dictionary-match-words "dictionary"
  "Search for matching words in the dictionaries" t)
(setq dictionary-server "localhost")
(global-set-key (kbd "C-c s") 'dictionary-search)
(global-set-key (kbd "C-c S") 'dictionary-match-words)

; doc-view
(setq doc-view-resolution 300)

; elisp
(add-hook 'emacs-lisp-mode-hook
          (lambda () (electric-indent-mode -1)))

; flyspell
(setq flyspell-auto-correct-binding (kbd "C-:")
      flyspell-prog-text-faces
      '(font-lock-comment-face font-lock-doc-face))

; latex
(when (require 'tex nil 'no-error)
  (setq
   TeX-auto-save t
   TeX-master nil
   TeX-parse-self t)
  (load "auctex.el" t t t))

(when (require 'latex nil 'no-error)
  (add-hook 'LaTeX-mode-hook 'latex-extra-mode))

(define-skeleton skel-latex
  "Inserts a LaTeX skeleton."
  ""
  "\\documentclass[a4paper]{" (skeleton-read "Class? " "article") "}" \n
  "\\usepackage[T1]" \n
  "\\usepackage[utf8]{inputenc}" \n)

; magit
(global-set-key (kbd "C-c i") 'magit-status)

; nobreak-fade
(autoload 'nobreak-fade-single-letter-p "nobreak-fade")
(add-hook 'fill-nobreak-predicate 'nobreak-fade-single-letter-p)

; org-mode: Ensure that M-h deletes the previous word.
(when (require 'org-mode nil 'no-error)
  (define-key org-mode-map (kbd "M-h") 'backward-kill-word))

; sh-mode
(setq sh-basic-offset 2
      sh-indentation 2)

; shell
(defun my-clear-shell ()
   (interactive)
   (let ((old-max comint-buffer-maximum-size))
     (setq comint-buffer-maximum-size 0)
     (comint-truncate-buffer)
     (setq comint-buffer-maximum-size old-max)))
(add-hook 'shell-mode-hook
          (lambda ()
            (local-set-key (kbd "C-l") 'my-clear-shell)))

; whitespace
(when (require 'whitespace nil 'no-error)
  (setq whitespace-line-column nil
        whitespace-style
        '(face trailing tabs lines-tail empty tab-mark))
  (set-face-attribute 'whitespace-line nil
                      :foreground 'unspecified
                      :background 'unspecified
                      :inherit 'whitespace-indentation)
  (global-whitespace-mode 1))


; Local stuff.
(defun sort-words (reverse beg end)
  "Sort words in region alphabetically, in REVERSE if negative.
Prefixed with negative \\[universal-argument], sorts in reverse.
The variable `sort-fold-case' determines whether alphabetic case
affects the sort order.
    See `sort-regexp-fields'."
  (interactive "*P\nr")
  (sort-regexp-fields reverse "\[^\s]+" "\\&" beg end))

(defun sort-symbols (reverse beg end)
  "Sort symbols in region alphabetically, in REVERSE if negative.
See `sort-words'."
  (interactive "*P\nr")
  (sort-regexp-fields reverse "\\(\\sw\\|\\s_\\)+" "\\&" beg end))

(defun today (prefix)
  "Insert current date.  With one prefix-argument, use ISO
   format. With two prefix arguments, write day and month name."
  (interactive "P")
  (let ((format (cond
                 ((not prefix) "%Y-%m-%d")
                 ((equal prefix '(4)) "%m/%d/%Y")
                 ((equal prefix '(16)) "%B %d, %Y"))))
    (insert (format-time-string format))))


; Visuals.
(defun my-hide-widgets ()
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (tool-bar-mode -1))
(my-hide-widgets)
(add-to-list 'after-make-frame-functions
             '(lambda (frame) (my-hide-widgets)))

 (setq default-frame-alist
       '((foreground-color . "white")
         (background-color . "black")
         (cursor-color . "green")))

;; (setq my-face-attributes                ; face :foreground :bold :underline
;;       '((error "red" t)
;;         (font-lock-builtin-face 'unspecified)
;;         (font-lock-comment-face "dark gray")
;;         (font-lock-constant-face "light gray")
;;         (font-lock-doc-face "dark gray")
;;         (font-lock-function-name-face 'unspecified t)
;;         (font-lock-keyword-face 'unspecified t)
;;         (font-lock-preprocessor-face 'unspecified t)
;;         (font-lock-string-face "dark gray")
;;         (font-lock-type-face 'unspecified t)
;;         (font-lock-variable-name-face 'unspecified)
;;         ))

;; (setq my-latex-face-attributes
;;       '((font-latex-bold-face "dark gray" t)
;;         (font-latex-italic-face "dark gray")
;;         (font-latex-math-face "dark gray")
;;         (font-latex-sectioning-0-face "dark gray" t)
;;         (font-latex-sectioning-1-face "dark gray" t)
;;         (font-latex-sectioning-2-face "dark gray" t)
;;         (font-latex-sectioning-3-face "dark gray" t)
;;         (font-latex-sectioning-4-face "dark gray" t)
;;         (font-latex-sectioning-5-face "dark gray" t)
;;         (font-latex-string-face "dark gray")))

;; (defun my-face-apply-attributes (list)
;;   (dolist (entry list)
;;     (set-face-attribute (nth 0 entry) nil
;;                         :foreground (eval (nth 1 entry))
;;                         :bold (nth 2 entry)
;;                         :inverse-video (nth 3 entry))))

;; (my-face-apply-attributes my-face-attributes)
;; (when (require 'font-latex nil 'no-error)
;;   (my-face-apply-attributes my-latex-face-attributes))

;; (set-face-attribute 'default nil :family "terminus" :height 140)
;;(set-face-attribute 'fixed-pitch nil :family "terminus")
;; (set-face-attribute 'mode-line nil :family "terminus" :height .8)
;; (set-face-attribute 'variable-pitch nil :family "terminus")
