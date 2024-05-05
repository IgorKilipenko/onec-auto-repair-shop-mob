﻿#Область ПрограммныйИнтерфейс

Функция СоздатьНовуюЗаписьКлиента(Знач данныеДокумента) Экспорт
    результат = Новый Структура("Успех, ИдентификаторДокумента, Сообщение", Истина);

    структураТелаЗапроса = Новый Структура;
    структураТелаЗапроса.Вставить("ДатаЗаписи", ЗаписатьДатуJSON(данныеДокумента.ДатаЗаписи, ФорматДатыJSON.ISO));
    структураТелаЗапроса.Вставить("ИдентификаторПользователя", данныеДокумента.ИдентификаторПользователя);
    структураТелаЗапроса.Вставить("Сотрудник", данныеДокумента.Сотрудник);
    структураТелаЗапроса.Вставить("Услуги", Новый Массив);

    Для Каждого строкаУслуг Из данныеДокумента.Услуги Цикл
        структураТелаЗапроса.Услуги.Добавить(Новый ФиксированнаяСтруктура("Наименование, Количество, Стоимость",
                Строка(строкаУслуг.Услуга), строкаУслуг.Количество, строкаУслуг.Услуга.Стоимость));
    КонецЦикла;

    соединение = создатьHttpСоединение();
    запрос = Новый HTTPЗапрос(получитьМаршрутЗаказов());
    запрос.УстановитьТелоИзСтроки(ЗаписатьЗначениеJSON(структураТелаЗапроса));
    ответ = соединение.ОтправитьДляОбработки(запрос);

    Если ответ.КодСостояния <> 200 Тогда
        результат.Сообщение = Новый СообщениеПользователю;
        результат.Сообщение.Текст = "Ошибка соединения с сервером.";
        результат.Успех = Ложь;

        Возврат результат;
    КонецЕсли;

    результатЗапроса = ПрочитатьЗначениеJSON(ответ.ПолучитьТелоКакСтроку());
    Если результатЗапроса.Успех = Ложь ИЛИ результатЗапроса.ИдентификаторДокумента = Неопределено Тогда
        результат.Сообщение = Новый СообщениеПользователю;
        результат.Сообщение.Текст = СтрШаблон("Ошибка создания записи клиента. Сервер не вернул данные созданного документа.
                |Сообщение сервера: %1", ?(результатЗапроса.Сообщение = Неопределено, "", результатЗапроса.Сообщение));
        результат.Успех = Ложь;

        Возврат результат;
    КонецЕсли;

    результат.ИдентификаторДокумента = результатЗапроса.ИдентификаторДокумента;
    Возврат результат;
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

// Возвращаемое значение:
//  - HTTPСоединение
Функция создатьHttpСоединение()
    адресСервера = получитьАдресСервера();
    соединение = Новый HTTPСоединение(адресСервера, , "MobileClient", , , 1000);
    Возврат соединение;
КонецФункции

// Возвращаемое значение:
//  - Строка
Функция получитьАдресСервера()
    адресСервера = Константы.АдресСервераИБ.Получить();
    адресСервера = ?(ПустаяСтрока(адресСервера), "10.0.2.2", адресСервера);
    Возврат адресСервера;
КонецФункции

// Возвращаемое значение:
//  - Строка - Эндпоинт Order
Функция получитьМаршрутЗаказов()
    Возврат "auto-repair-shop/hs/orders/order";
КонецФункции

#КонецОбласти
