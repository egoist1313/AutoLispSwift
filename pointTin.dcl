surface_select : dialog {
  label = "Выбор TIN-поверхности";
  : popup_list {  // Заменяем list_box на popup_list
    key = "surface_list";
    label = "Выберите поверхность:";
    width = 40;
    height = 10;
  }
  : toggle {
    key = "use_custom_points";
    label = "Использовать свой набор точек";
    value = "1"; // По умолчанию включено
  }
  : edit_box {
    key = "point_step";
    label = "Шаг точек:";
    value = "10"; // Значение по умолчанию
    width = 10;
  }
  : toggle {
    key = "random_height";
    label = "Разброс по высоте";
  }
  : row {
    : edit_box {
      key = "height_min";
      label = "Нижняя граница:";
      value = "-1.0"; // Значение по умолчанию
      width = 10;
    }
    : edit_box {
      key = "height_max";
      label = "Верхняя граница:";
      value = "1.0"; // Значение по умолчанию
      width = 10;
    }
  }
  : toggle {
    key = "random_coords";
    label = "Разброс по координатам";
  }
  : row {
    : edit_box {
      key = "coords_min";
      label = "Нижняя граница:";
      value = "-1.0"; // Значение по умолчанию
      width = 10;
    }
    : edit_box {
      key = "coords_max";
      label = "Верхняя граница:";
      value = "1.0"; // Значение по умолчанию
      width = 10;
    }
  }
  : row {
    : button {
      key = "accept";
      label = "Выбрать";
      is_default = true;
    }
    : button {
      key = "cancel";
      label = "Отмена";
      is_cancel = true;
    }
  }
}