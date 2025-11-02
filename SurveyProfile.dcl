survey_profile : dialog {
  label = "Survey Profile Processing";
  : text {
    label = "Шаги выполнения команды PPP";
    alignment = centered;
  }
  : list_box {
    key = "step_list";
    height = 20;
    width = 80;
    fixed_width = true;
    multiple_select = false;
  }
  : row {
    : button {
      key = "next";
      label = "Далее";
      is_default = true;
    }
    : button {
      key = "cancel";
      label = "Отмена";
      is_cancel = true;
    }
  }
}