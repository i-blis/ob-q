;;; ob-q.el --- org-babel functions for q and k evaluation

;; version: 0.1

(require 'ob)
(require 'q-mode nil 'noerror)

(defcustom inferior-q-babel-program-name "q"
  "Program name for invoking an inferior q."
  :type 'file
  :group 'ob-q)

(define-derived-mode inferior-q-babel-mode comint-mode "ob-q-shell"
  "Major mode for org-babel to interact with a q interpreter."
  (set (make-local-variable 'comint-process-echoes) nil)
  (when (featurep 'q-mode)
    (set-syntax-table q-mode-syntax-table)
    (set (make-local-variable 'font-lock-defaults) q-font-lock-defaults)
    (font-lock-mode t)
    ;; (setq truncate-lines t)
    ))

(defun org-babel-q-shell ()
  (let* ((buffer (get-buffer-create "*q-babel*")))
    (if (not (comint-check-proc buffer))
      (with-current-buffer buffer
        (message "Starting q with: \"%s\"" inferior-q-babel-program-name)
        (inferior-q-babel-mode)
        (let ((process (get-buffer-process
                         (comint-exec buffer
                                      "q-babel"
                                      inferior-q-babel-program-name
                                      nil
                                      (list "-q")))))
          (set-process-sentinel process 'q-babel-process-sentinel)
          process))
      (get-buffer-process buffer))))

(defun org-babel-q-eval-string (s)
  (let ((session (org-babel-q-shell)))
    (with-current-buffer (process-buffer session)
      (erase-buffer)
      (comint-simple-send (get-buffer-process (current-buffer)) s)
      (sit-for 0.2)
      (buffer-substring-no-properties (point-min) (- (point-max) 1)))))

(defun org-babel-execute:q (body params)
  (org-babel-q-eval-string body))

(defun org-babel-q-prefix-k (s)
  (mapconcat (lambda (x) (concat "k)" x))
           (split-string s "\n")
           "\n"))

(defun org-babel-execute:k (body params)
  (org-babel-q-eval-string (org-babel-q-prefix-k body)))

(provide 'ob-q)

;;; ob-q.el ends here
