(defun c:POINTTIN (/ surfaces surface ss ptList pt elev ptData newPtData x y z dcl_id surfaceNames selectedIndex result surfaceObj
                    useCustomPoints pointStep randomHeight heightMin heightMax randomCoords coordsMin coordsMax boundary boundaryObj
                    boundaryPoints minPt maxPt param endParam)
  ;; Загрузка библиотек Civil 3D API
  (vl-load-com)

  ;; Функция для генерации случайного числа в диапазоне [min, max]
  (defun random-between (min max / seed random-value)
    ;; Используем комбинацию DATE и CPUTICKS для создания уникального seed
    (setq seed (* (getvar "DATE") (getvar "CPUTICKS")))
    ;; Преобразуем seed в псевдослучайное число
    (setq random-value (rem (+ seed (getvar "MILLISECS")) 1000000)) ; Добавляем миллисекунды
    (setq random-value (/ (rem random-value 10000) 10000.0)) ; Нормализуем к [0, 1)
    (+ min (* random-value (- max min))) ; Масштабируем к [min, max]
  )

  ;; Получение списка всех TIN-поверхностей на чертеже
  (setq surfaces (vl-remove-if-not
                   '(lambda (ent)
                      (eq (cdr (assoc 0 (entget ent))) "AECC_TIN_SURFACE"))
                   (vl-remove-if 'listp (mapcar 'cadr (ssnamex (ssget "_X" '((0 . "AECC_TIN_SURFACE"))))))))

  ;; Проверка наличия поверхностей
  (if (null surfaces)
    (progn
      ;; Если поверхностей нет, выводим сообщение в диалоговом окне
      (setq dclFile "pointTin.dcl") ; Указываем правильное имя файла
      (setq dcl_id (load_dialog dclFile))
      (if (not (new_dialog "error_dialog" dcl_id)) ; Используем новое диалоговое окно для ошибки
        (progn
          (princ "\nОшибка загрузки DCL-файла.")
          (exit)
        )
      )
      ;; Устанавливаем текст сообщения
      (set_tile "error_message" "Ошибка: на чертеже нет TIN-поверхностей!")
      ;; Обработка нажатия кнопки "OK"
      (action_tile "accept" "(done_dialog 1)")
      ;; Отображение диалогового окна
      (start_dialog)
      (unload_dialog dcl_id)
      (exit) ; Завершаем выполнение
    )
    (progn
      ;; Формируем список имен поверхностей
      (setq surfaceNames (mapcar '(lambda (ent)
                                    (setq surfaceObj (vlax-ename->vla-object ent))
                                    (vla-get-Name surfaceObj)
                                  )
                                  surfaces))
      ;; Отладочное сообщение: список имен поверхностей
      (princ "\nСписок имен поверхностей:")
      (foreach name surfaceNames
        (princ (strcat "\n- " name))
      )

      ;; Загружаем DCL-файл
      (setq dclFile "pointTin.dcl") ; Указываем правильное имя файла
      (princ (strcat "\nПоиск DCL-файла: " dclFile))
      (setq dcl_id (load_dialog dclFile))
      (if (not (new_dialog "surface_select" dcl_id))
        (progn
          (princ "\nОшибка загрузки DCL-файла.")
          (exit)
        )
      )
      ;; Заполняем выпадающий список поверхностей
      (start_list "surface_list")
      (mapcar 'add_list surfaceNames)
      (end_list)
      ;; Устанавливаем начальное значение (первый элемент)
      (set_tile "surface_list" "0")  ;; Индекс первого элемента (0)

      ;; Загружаем сохранённые значения из переменных среды
      (set_tile "use_custom_points" (if (getenv "POINTTIN_USE_CUSTOM_POINTS") (getenv "POINTTIN_USE_CUSTOM_POINTS") "1"))  ;; По умолчанию включено
      (set_tile "point_step" (if (getenv "POINTTIN_POINT_STEP") (getenv "POINTTIN_POINT_STEP") "10"))        ;; Значение по умолчанию
      (set_tile "height_min" (if (getenv "POINTTIN_HEIGHT_MIN") (getenv "POINTTIN_HEIGHT_MIN") "-1.0"))      ;; Нижняя граница по высоте
      (set_tile "height_max" (if (getenv "POINTTIN_HEIGHT_MAX") (getenv "POINTTIN_HEIGHT_MAX") "1.0"))       ;; Верхняя граница по высоте
      (set_tile "coords_min" (if (getenv "POINTTIN_COORDS_MIN") (getenv "POINTTIN_COORDS_MIN") "-1.0"))      ;; Нижняя граница по координатам
      (set_tile "coords_max" (if (getenv "POINTTIN_COORDS_MAX") (getenv "POINTTIN_COORDS_MAX") "1.0"))       ;; Верхняя граница по координатам

      ;; Обработка действий пользователя
      (action_tile "accept"
        "(setq useCustomPoints (get_tile \"use_custom_points\"))
         (setq pointStep (get_tile \"point_step\"))
         (setq randomHeight (get_tile \"random_height\"))
         (setq heightMin (get_tile \"height_min\"))
         (setq heightMax (get_tile \"height_max\"))
         (setq randomCoords (get_tile \"random_coords\"))
         (setq coordsMin (get_tile \"coords_min\"))
         (setq coordsMax (get_tile \"coords_max\"))
         (setq selectedIndex (get_tile \"surface_list\"))  ;; Получаем индекс выбранного элемента
         ;; Сохраняем настройки в переменные среды
         (setenv \"POINTTIN_USE_CUSTOM_POINTS\" useCustomPoints)
         (setenv \"POINTTIN_POINT_STEP\" pointStep)
         (setenv \"POINTTIN_HEIGHT_MIN\" heightMin)
         (setenv \"POINTTIN_HEIGHT_MAX\" heightMax)
         (setenv \"POINTTIN_COORDS_MIN\" coordsMin)
         (setenv \"POINTTIN_COORDS_MAX\" coordsMax)
         (done_dialog 1)")
      (action_tile "cancel" "(done_dialog 0)")
      ;; Отображение диалогового окна
      (setq result (start_dialog))
      (unload_dialog dcl_id)
      ;; Отладочное сообщение: результат диалога
      (princ (strcat "\nРезультат диалога: " (itoa result)))
      (princ (strcat "\nВыбранный индекс: " selectedIndex))
      ;; Обработка выбора пользователя
      (if (and (= result 1) selectedIndex)
        (progn
          (setq surface (nth (atoi selectedIndex) surfaces))
          (setq surfaceObj (vlax-ename->vla-object surface))
          ;; Проверка на nil перед выводом имени
          (if (vla-get-Name surfaceObj)
            (princ (strcat "\nВыбрана поверхность: " (vla-get-Name surfaceObj)))
            (princ "\nВыбрана поверхность с неопределенным именем.")
          )
        )
        (princ "\nВыбор отменен.")
      )
    )
  )

  ;; Если поверхность выбрана
  (if surface
    (progn
      (princ "\nTIN поверхность выбрана успешно.")
      ;; Проверяем, используется ли пользовательский набор точек
      (if (= useCustomPoints "1")
        (progn
          (princ "\nИспользование пользовательского набора точек.")
          (setq ss (ssget '((0 . "POINT")))) ; Запрос выбора точек
          (if (not ss)
            (progn
              (princ "\нТочки не выбраны или на чертеже нет точек.")
              (exit) ; Завершаем выполнение
            )
          )
          (setq ptList (vl-remove-if 'listp (mapcar 'cadr (ssnamex ss)))) ; Получение списка точек
        )
        (progn
          (princ "\nИспользование сетки точек.")
          ;; Получаем шаг точек из диалога
          (setq pointStep (atof pointStep))
          ;; Создаем сетку точек с указанным шагом
          (if (and pointStep (> pointStep 0))
            (progn
              (princ (strcat "\nСоздание сетки точек с шагом: " (rtos pointStep 2 2)))
              ;; Запрос выбора полилинии (границы)
              (while (not boundary)
                (setq boundary (car (entsel "\nВыберите полилинию (границу): ")))
                (if (and boundary
                         (or (eq (cdr (assoc 0 (entget boundary))) "LWPOLYLINE")
                             (eq (cdr (assoc 0 (entget boundary))) "POLYLINE")))
                  (progn
                    ;; Получаем точки полилинии
                    (setq boundaryObj (vlax-ename->vla-object boundary))
                    (setq boundaryPoints '())
                    (setq param 0)
                    (setq endParam (vlax-curve-getEndParam boundaryObj))
                    (while (<= param endParam)
                      (setq boundaryPoints (cons (vlax-curve-getPointAtParam boundaryObj param) boundaryPoints))
                      (setq param (1+ param))
                    )
                    ;; Преобразуем координаты границы в текущую ПСК
                    (setq boundaryPoints (mapcar '(lambda (pt) (trans pt 0 1)) boundaryPoints))
                    ;; Получаем минимальные и максимальные координаты полилинии
                    (setq minPt (apply 'mapcar (cons 'min boundaryPoints)))
                    (setq maxPt (apply 'mapcar (cons 'max boundaryPoints)))
                    ;; Отладочные сообщения
                    (princ (strcat "\nМинимальные координаты: " (rtos (car minPt) 2 2) ", " (rtos (cadr minPt) 2 2)))
                    (princ (strcat "\nМаксимальные координаты: " (rtos (car maxPt) 2 2) ", " (rtos (cadr maxPt) 2 2)))
                    ;; Создаем точки с шагом внутри полилинии
                    (setq x (car minPt))
                    (while (<= x (car maxPt))
                      (setq y (cadr minPt))
                      (while (<= y (cadr maxPt))
                        ;; Проверяем, находится ли точка внутри полилинии
                        (if (is-point-inside-polygon (list x y) boundaryPoints)
                          (progn
                            ;; Преобразуем координаты точки в мировую систему координат
                            (setq ptUCS (list x y 0.0))
                            (setq ptWCS (trans ptUCS 1 0))
                            ;; Создаем точку
                            (entmake (list (cons 0 "POINT") (cons 10 ptWCS)))
                          )
                        )
                        (setq y (+ y pointStep))
                      )
                      (setq x (+ x pointStep))
                    )
                  )
                  (progn
                    (princ "\nВыбранный объект не является полилинией. Попробуйте снова.")
                    (setq boundary nil) ; Сброс выбора, чтобы повторить запрос
                  )
                )
              )
            )
            (princ "\nШаг точек не указан или указан неверно.")
          )
          ;; Получаем список созданных точек
          (setq ss (ssget "_X" '((0 . "POINT"))))
          (setq ptList (vl-remove-if 'listp (mapcar 'cadr (ssnamex ss))))
        )
      )
      ;; Обработка точек
      (if ptList
        (progn
          (princ (strcat "\nНайдено точек: " (itoa (length ptList))))
          ;; Шаг 1: Назначение отметок от поверхности
          (foreach pt ptList
            ;; Получаем координаты точки
            (setq ptData (entget pt))
            (setq x (car (cdr (assoc 10 ptData))))
            (setq y (cadr (cdr (assoc 10 ptData))))
            ;; Получаем Z-координату из поверхности
            (if (vlax-method-applicable-p surfaceObj 'FindElevationAtXY)
              (progn
                (setq ptWCS (trans (list x y 0.0) 1 0))
                ;; Пытаемся получить высоту с перехватом ошибок
                (setq elevResult (vl-catch-all-apply
                                   'vlax-invoke
                                   (list surfaceObj 'FindElevationAtXY (car ptWCS) (cadr ptWCS))))
                (if (not (vl-catch-all-error-p elevResult))
                  (progn
                    ;; Высота успешно получена
                    (setq z elevResult)
                    ;; Обновляем координаты точки
                    (setq newPtData (subst (cons 10 (trans (list x y z) 1 0)) (assoc 10 ptData) ptData))
                    (entmod newPtData)
                  )
                  (progn
                    ;; Ошибка: точка вне поверхности, красим в красный цвет
                    (princ (strcat "\nТочка (" (rtos x 2 2) ", " (rtos y 2 2) ") вне поверхности, окрашена в красный."))
                    (setq newPtData (append ptData (list (cons 62 1)))) ; Код цвета ACI 1 (красный)
                    (entmod newPtData)
                  )
                )
              )
              (princ "\nМетод FindElevationAtXY недоступен.")
            )
          )
          ;; Шаг 2: Применение разброса (если включено)
          (if (or (= randomCoords "1") (= randomHeight "1"))
            (progn
              (foreach pt ptList
                ;; Получаем координаты точки
                (setq ptData (entget pt))
                (setq x (car (cdr (assoc 10 ptData))))
                (setq y (cadr (cdr (assoc 10 ptData))))
                (setq z (caddr (cdr (assoc 10 ptData))))
                ;; Применяем разброс по координатам, если включен
                (if (= randomCoords "1")
                  (progn
                    (princ (strcat "\nИсходные координаты: " (rtos x 2 2) ", " (rtos y 2 2)))
                    (setq x (+ x (random-between (atof coordsMin) (atof coordsMax))))
                    (setq y (+ y (random-between (atof coordsMin) (atof coordsMax))))
                    (princ (strcat "\nНовые координаты: " (rtos x 2 2) ", " (rtos y 2 2)))
                  )
                )
                ;; Применяем разброс по высоте, если включен
                (if (= randomHeight "1")
                  (progn
                    ;; Проверяем, была ли точка окрашена в красный (т.е. вне поверхности)
                    (if (not (assoc 62 ptData)) ; Если цвет не изменён (точка на поверхности)
                      (setq z (+ z (random-between (atof heightMin) (atof heightMax))))
                    )
                  )
                )
                ;; Обновляем координаты точки
                (setq newPtData (subst (cons 10 (list x y z)) (assoc 10 ptData) ptData))
                (entmod newPtData)
              )
              (princ (strcat "\nРазброс применен для " (itoa (length ptList)) " точек."))
            )
            (princ "\nРазброс не применен (настройки отключены).")
          )
        )
        (princ "\nТочки не найдены.")
      )
    )
    (princ "\nTIN поверхность не выбрана.")
  )
  (princ)
)

;; Функция для проверки, находится ли точка внутри полилинии (алгоритм ray-casting)
(defun is-point-inside-polygon (pt polygon / x y n i j inside)
  (setq x (car pt)
        y (cadr pt)
        n (length polygon)
        inside nil
        i 0
        j (1- n))
  (while (< i n)
    (setq xi (car (nth i polygon))
          yi (cadr (nth i polygon))
          xj (car (nth j polygon))
          yj (cadr (nth j polygon)))
    (if (and (or (and (< yi y) (>= yj y))
                 (and (< yj y) (>= yi y)))
             (<= x (+ xi (* (/ (- xj xi) (- yj yi)) (- y yi)))))
      (setq inside (not inside)))
    (setq j i
          i (1+ i)))
  inside
)