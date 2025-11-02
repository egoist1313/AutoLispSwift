(defun c:PLSTR (/ textheight ent hatch area textpt textstyle)
  ;; Устанавливаем обработчик ошибок
  (vl-load-com)
  (defun *error* (msg)
    (if (not (wcmatch (strcase msg T) "*break,*cancel*,*exit*"))
      (princ (strcat "\nОшибка: " msg))
    )
    (princ)
  )
  
  ;; Запрашиваем высоту текста
  (initget 1)
  (setq textheight (getreal "\nВведите высоту текста: "))
  
  ;; Получаем текущий текстовый стиль
  (setq textstyle (getvar "TEXTSTYLE"))
  
  ;; Цикл для выбора штриховки и вставки текста
  (while (setq ent (car (entsel "\nВыберите штриховку (или нажмите Enter для выхода): ")))
    (if (and ent
             (= (cdr (assoc 0 (entget ent))) "HATCH") ; Проверяем, что объект — штриховка
             (setq hatch (vlax-ename->vla-object ent))
             (vlax-property-available-p hatch 'Area)
        )
      (progn
        ;; Попытка пересчёта площади штриховки через ActiveX
        (vl-catch-all-apply
          (function
            (lambda ()
              (vla-Evaluate hatch) ; Пересчитываем штриховку
              (setq area (vla-get-Area hatch)) ; Получаем площадь
            )
          )
        )
        (if (and area (> area 0)) ; Проверяем, что площадь больше 0
          (progn
            ;; Запрашиваем точку для вставки текста
            (initget 1)
            (setq textpt (getpoint "\nУкажите точку для текста: "))
            ;; Создаем текст с использованием entmake, применяя текущий стиль
            (entmake
              (list
                '(0 . "TEXT")
                '(100 . "AcDbEntity")
                '(100 . "AcDbText")
                (cons 10 textpt) ; Точка вставки
                (cons 40 textheight) ; Высота текста
                (cons 1 (strcat "S=" (rtos area 2 2) " м²")) ; Текст
                '(50 . 0.0) ; Угол поворота
                (cons 7 textstyle) ; Текущий текстовый стиль
                '(71 . 0) ; Выравнивание
                '(72 . 0) ; Горизонтальное выравнивание
                '(73 . 0) ; Вертикальное выравнивание
              )
            )
          )
          (princ "\nОшибка: Площадь штриховки равна 0 или не может быть вычислена. Проверьте штриховку."))
      )
      (princ "\nВыбранный объект не является штриховкой или не имеет площади.")
    )
  )
  (princ)
)