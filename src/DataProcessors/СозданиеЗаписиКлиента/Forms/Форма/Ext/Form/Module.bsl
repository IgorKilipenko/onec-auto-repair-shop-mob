﻿#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Записаться(_)
    Если проверитьЗаполнениеПолейФормы() = Ложь Тогда
        Возврат;
    КонецЕсли;

    результатЗаписи = создатьЗаписьКлиентаНаСервере();
    Если результатЗаписи.Успех Тогда
        сообщение = Новый СообщениеПользователю;
        сообщение.Текст = СтрШаблон("Вы записаны на %1 ""%2"" к мастеру ""%3"" на дату ""%4""",
                ?(ЭтотОбъект.Объект.Услуги.Количество() > 1, "услуги:", "услугу"),
                результатЗаписи.СписокУслуг,
                Строка(ЭтотОбъект.Объект.Сотрудник),
                Формат(ЭтотОбъект.Объект.ДатаЗаписи, "ДФ=dd.MM.yyyy HH.mm"));

        ЭтотОбъект.Закрыть();
        ПерейтиПоНавигационнойСсылке("e1cib/navigationpoint/startpage");
        Оповестить("НоваяЗаписьКлиента", , ЭтотОбъект);
        сообщение.Сообщить();
    КонецЕсли;

КонецПроцедуры

#КонецОбласти // ОбработчикиКомандФормы

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(_, __)
    ЭтотОбъект.Объект.ДатаЗаписи = получитьБлижайшуюДатуЗаписи() + 5 * 60;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ДатаЗаписиПриИзменении(_)
    результатПроверки = проверитьЗаполнениеДатыЗаписи();
    Если результатПроверки.Успех = Ложь Тогда
        ЭтотОбъект.Объект.ДатаЗаписи = результатПроверки.БлижайшаяДата;
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура УслугиПослеУдаления(_)
    обновитьОбщуюСтоимостьУслуг();
КонецПроцедуры

&НаКлиенте
Процедура УслугиУслугаПриИзменении(_)
    текущаяСтрокаУслуг = ЭтотОбъект.Элементы.Услуги.ТекущиеДанные;
    обновитьСуммуПоСтроке(текущаяСтрокаУслуг);
    обновитьОбщуюСтоимостьУслуг();
КонецПроцедуры

&НаКлиенте
Процедура УслугиКоличествоПриИзменении(_)
    текущаяСтрокаУслуг = ЭтотОбъект.Элементы.Услуги.ТекущиеДанные;
    обновитьСуммуПоСтроке(текущаяСтрокаУслуг);
    обновитьОбщуюСтоимостьУслуг();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийЭлементовШапкиФормы

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Функция получитьБлижайшуюДатуЗаписи(Знач дата = Неопределено)
    текущаяДата = НачалоМинуты(ТекущаяДатаСеанса());
    базоваяДата = ?(дата = Неопределено, текущаяДата, дата);
    Возврат Макс(НачалоМинуты(базоваяДата), текущаяДата + 60);
КонецФункции

&НаКлиенте
Функция проверитьЗаполнениеДатыЗаписи(Знач выводитьСообщение = Истина)
    результат = Новый Структура("Успех, БлижайшаяДата", Истина);

    ближайшаяДоступнаяДата = получитьБлижайшуюДатуЗаписи(ЭтотОбъект.Объект.ДатаЗаписи);
    результат.БлижайшаяДата = ближайшаяДоступнаяДата;
    Если ближайшаяДоступнаяДата > ЭтотОбъект.Объект.ДатаЗаписи Тогда
        Если выводитьСообщение Тогда
            сообщение = Новый СообщениеПользователю;
            сообщение.Текст = СтрШаблон("Ближайшая доступная для записи дата: ""%1"".",
                    Формат(ближайшаяДоступнаяДата, "ДФ=dd.MM.yyyy HH.mm"));
            сообщение.Поле = "ДатаЗаписи";
            сообщение.УстановитьДанные(ЭтотОбъект.Объект);
            сообщение.Сообщить();
        КонецЕсли;

        результат.Успех = Ложь;
    КонецЕсли;

    Возврат результат;
КонецФункции

&НаКлиенте
Функция проверитьЗаполнениеОбязательногоПоля(Знач имяРеквизита)
    результат = Новый Структура("Успех", Истина);

    Если ЗначениеЗаполнено(ЭтотОбъект.Объект[имяРеквизита]) = Ложь Тогда
        сообщение = Новый СообщениеПользователю;
        сообщение.Текст = СтрШаблон("Поле ""%1"" должно быть заполнено.", имяРеквизита);
        сообщение.Поле = "Сотрудник";
        сообщение.УстановитьДанные(ЭтотОбъект.Объект);
        сообщение.Сообщить();

        результат.Успех = Ложь;
    КонецЕсли;

    Возврат результат;
КонецФункции

&НаСервере
Функция создатьЗаписьКлиентаНаСервере()
    результат = Новый Структура("Успех, Ссылка, СписокУслуг", Истина,
            Документы.ЗаписьКлиента.ПустаяСсылка(), " ,");

    пользовательСсылка = ПараметрыСеанса.ТекущийПользователь;
    Если ЗначениеЗаполнено(пользовательСсылка) = Ложь Тогда
        сообщение = Новый СообщениеПользователю;
        сообщение.Текст = "Текущий пользователь не авторизован.";
        сообщение.Сообщить();

        результат.Успех = Ложь;
        Возврат результат;
    КонецЕсли;

    документЗаписи = Документы.ЗаписьКлиента.СоздатьДокумент();
    документЗаписи.Дата = ЭтотОбъект.Объект.ДатаЗаписи;
    документЗаписи.Сотрудник = ЭтотОбъект.Объект.Сотрудник;

    Для Каждого строкаУслуг Из ЭтотОбъект.Объект.Услуги Цикл
        новаяСтрокаУслуг = документЗаписи.Услуги.Добавить();
        новаяСтрокаУслуг.Услуга = строкаУслуг.Услуга;
        новаяСтрокаУслуг.Стоимость = строкаУслуг.Сумма;

        результат.СписокУслуг = СтрШаблон("%1, %2", результат.СписокУслуг, Строка(строкаУслуг.Услуга));
    КонецЦикла;

    результатСинхронизации = СинхронизацияДанных.СоздатьНовуюЗаписьКлиента(Новый ФиксированнаяСтруктура(
                "ДатаЗаписи, Сотрудник, Услуги, ИдентификаторПользователя",
                ЭтотОбъект.Объект.ДатаЗаписи,
                Строка(ЭтотОбъект.Объект.Сотрудник),
                ЭтотОбъект.Объект.Услуги,
                пользовательСсылка.ВнешнийUUID));

    Если результатСинхронизации.Успех = Ложь Тогда
        Если результатСинхронизации.Сообщение <> Неопределено Тогда
            результатСинхронизации.Сообщение.Сообщить();
        КонецЕсли;

        результат.Успех = Ложь;
        Возврат результат;
    КонецЕсли;

    документЗаписи.Проведен = Истина;
    документЗаписи.Записать();

    результат.СписокУслуг = Прав(результат.СписокУслуг, СтрДлина(результат.СписокУслуг) - 3);
    результат.Ссылка = документЗаписи.Ссылка;

    Возврат результат;
КонецФункции

&НаКлиенте
Функция проверитьЗаполнениеПолейФормы()
    результатПроверки = проверитьЗаполнениеДатыЗаписи(Истина);
    Если результатПроверки.Успех = Ложь Тогда
        Возврат Ложь;
    КонецЕсли;

    обязательныеПоля = Новый Массив;
    обязательныеПоля.Добавить("Сотрудник");
    обязательныеПоля.Добавить("Услуги");
    Для Каждого имяПоля Из обязательныеПоля Цикл
        результатПроверки = проверитьЗаполнениеОбязательногоПоля(имяПоля);
        Если результатПроверки.Успех = Ложь Тогда
            Возврат Ложь;
        КонецЕсли;
    КонецЦикла;

    Для Каждого строкаУслуг Из ЭтотОбъект.Объект.Услуги Цикл
        Если ЗначениеЗаполнено(строкаУслуг.Услуга) = Ложь Тогда
            сообщение = Новый СообщениеПользователю;
            сообщение.Текст = "Для списка услуг нужно указать все наименования услуг.";
            сообщение.Сообщить();

            Возврат Ложь;
        КонецЕсли;
    КонецЦикла;

    Возврат Истина;
КонецФункции

&НаКлиенте
Процедура обновитьСуммуПоСтроке(Знач строкаУслуг)
    Если ЗначениеЗаполнено(строкаУслуг.Услуга) = Ложь Тогда
        строкаУслуг.Сумма = 0;
    Иначе
        строкаУслуг.Сумма = строкаУслуг.Количество * получитьЦенуУслугиНаСервере(строкаУслуг.Услуга);
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура обновитьОбщуюСтоимостьУслуг()
    ЭтотОбъект.Объект.ОбщаяСтоимость = ЭтотОбъект.Объект.Услуги.Итог("Сумма");
КонецПроцедуры

&НаСервереБезКонтекста
Функция получитьЦенуУслугиНаСервере(Знач услугаСсылка)
    запрос = Новый Запрос;
    запрос.Текст =
        "ВЫБРАТЬ
        |   Услуги.Стоимость КАК Цена
        |ИЗ
        |   Справочник.Услуги КАК Услуги
        |ГДЕ
        |   Услуги.Ссылка = &Ссылка
        |";
    запрос.УстановитьПараметр("Ссылка", услугаСсылка);
    результатЗапроса = запрос.Выполнить();

    выборка = результатЗапроса.Выбрать();
    выборка.Следующий();
    Возврат выборка.Цена;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
