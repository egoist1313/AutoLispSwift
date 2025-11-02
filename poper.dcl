poper_settings : dialog {
    label = "Настройки Swift POPER";
    : column {
        : radio_button {
            label = "Режим: По точкам";
            key = "mode_points";
            value = "1";
        }
        : radio_button {
            label = "Режим: По векторам";
            key = "mode_vectors";
        }
        : edit_box {
            label = "Масштаб по высоте:";
            key = "h_scale";
            value = "10";
            width = 10;
        }
        : edit_box {
            label = "Масштаб по длине:";
            key = "l_scale";
            value = "1";
            width = 10;
        }
        : edit_box {
            label = "Высота текста:";
            key = "text_height";
            value = "2.5";
            width = 10;
        }
        : popup_list {
            label = "Округление высоты до:";
            key = "round_to";
            width = 10;
            list = "2\n3";
        }
        : popup_list {
            label = "Округление уклона до:";
            key = "slope_round_to";
            width = 10;
            list = "0\n1\n2";
        }
        : popup_list {
            label = "Единица уклона:";
            key = "slope_unit";
            width = 10;
            list = "Промилле\nГрадусы\nСоотношение сторон";
        }
        : toggle {
            label = "Показать длины";
            key = "show_lengths";
            value = "1";
        }
        : toggle {
            label = "Показать уклоны";
            key = "show_slopes";
            value = "1";
        }
        : toggle {
            label = "Высота из текста";
            key = "use_text_height";
            value = "1";
        }
    }
    : row {
        : button {
            key = "accept";
            label = "OK";
            is_default = true;
        }
        : button {
            key = "cancel";
            label = "Отмена";
            is_cancel = true;
        }
    }
}