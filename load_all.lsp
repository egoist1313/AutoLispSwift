;; Функция для загрузки всех LISP-файлов в указанной папке
(defun load-all-lisps (folder-path / file-list)
  ;; Проверяем, существует ли папка
  (if (vl-file-directory-p folder-path)
    (progn
      ;; Получаем список всех файлов с расширением .lsp в папке
      (setq file-list (vl-directory-files folder-path "*.lsp" 1))  ;; 1 = только файлы, без папок

      ;; Проверяем, есть ли файлы в папке
      (if file-list
        (progn
          ;; Загружаем каждый файл, кроме самого себя (load_all.lsp)
          (foreach file file-list
            (if (/= (strcase file) (strcase "load_all.lsp"))  ;; Исключаем загрузку самого себя
              (progn
                (load (strcat folder-path "\\" file))  ;; Загружаем файл
                (princ (strcat "\nФайл " file " успешно загружен."))
              )
            )
          )
          (princ (strcat "\nВсего загружено " (itoa (length file-list)) " LISP-файлов."))
        )
        (princ "\nВ папке нет LISP-файлов для загрузки.")
      )
    )
    (princ (strcat "\nПапка " folder-path " не существует или недоступна."))
  )
)

;; Получаем путь к папке, где находится текущий LISP-файл
(setq current-path (vl-filename-directory (findfile "load_all.lsp")))

;; Проверяем, удалось ли получить путь
(if current-path
  (progn
    (princ (strcat "\nТекущая папка: " current-path))
    (load-all-lisps current-path)  ;; Загружаем все LISP-файлы в текущей папке
  )
  (princ "\nНе удалось определить текущую папку.")
)