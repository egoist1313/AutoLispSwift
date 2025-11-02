(vl-load-com)

(defun save-and-close-all-documents ()
  (setq acad-app (vlax-get-acad-object))
  (setq documents (vlax-get-property acad-app 'Documents))
  
  ;; Создаем меню с выбором "Да" или "Нет"
  (initget "Да Нет")
  (setq save-option (getkword "\nСохранить ВСЕ документы? [Да/Нет]: "))
  
  (if (or (null save-option) (eq save-option "Нет"))
      (setq save-option "Нет")
      (setq save-option "Да")
  )
  
  (vlax-for document documents
    (if (eq save-option "Да")
        ;; Сохраняем и закрываем документ через VLA
        (progn

          (vla-Save document)
        )
        ;; Сохраняем в папку C:\Windows\Temp и закрываем через VLA
        (progn
          (setq temp-path "C:\\Windows\\Temp\\")
          (setq file-name (strcat temp-path (vla-get-Name document)))
          (vla-SaveAs document file-name acR12_dwg)  ;; Сохраняем в формате DWG
        )
    )
  )
  
  (princ "\nВсе документы были обработаны.")
  (command "_quit")
)

(defun c:zac ()
  (save-and-close-all-documents)
  (princ)
)

(princ)