﻿#Область ПрограммныйИнтерфейс

Процедура ВыполнитьАутентификацию(Логин) Экспорт
    Соединение = Новый HTTPСоединение("localhost", , "MobileClient");
    запрос = Новый HTTPЗапрос("auto-repair-shop/hs/users/user?name=" + Логин);
    ответ = Соединение.Получить(запрос);

    Если ответ.КодСостояния <> 200 Тогда
        сообщение = Новый СообщениеПользователю;
        сообщение.Текст = "При попытке аутентификации произошла ошибка!";
        сообщение.Сообщить();

        Возврат;
    КонецЕсли;

    результатЗапроса = ПрочитатьЗначениеJSON(ответ.ПолучитьТелоКакСтроку());
    Если результатЗапроса.Пользователь = Неопределено Тогда
        сообщение = Новый СообщениеПользователю;
        сообщение.Текст = "По логину " + Логин + " пользователь не найден!";
        сообщение.Сообщить();
    ИначеЕсли ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(
            результатЗапроса.Пользователь.ВнешнийUUID) = Неопределено Тогда
        АвторизоватьПользователя(результатЗапроса.Пользователь);
    КонецЕсли;
КонецПроцедуры

// Параметры:
//  данныеПользователя - Структура, ФиксированнаяСтруктура
//      * Имя - Строка
//      * УникальныйИдентификатор - Строка
// Возвращаемое значение:
//  - СправочникСсылка.Пользователи
Функция АвторизоватьПользователя(Знач данныеПользователя) Экспорт
    пользовательИБ = Неопределено;
    текущийПользователь = Справочники.Пользователи.НайтиПоНаименованию(данныеПользователя.Имя); //!

    Если текущийПользователь.Пустая() Тогда
        // Создание пользователя ИБ
        пользовательИБ = ПользователиИнформационнойБазы.СоздатьПользователя();
        пользовательИБ.Имя = данныеПользователя.Имя;
        пользовательИБ.Роли.Добавить(Метаданные.Роли.АвторизованныйПользователь);
        пользовательИБ.Записать();

        // Создание элемента справочника Пользователи
        текущийПользователь = Справочники.Пользователи.СоздатьЭлемент();
        текущийПользователь.Код = пользовательИБ.УникальныйИдентификатор;
        текущийПользователь.ВнешнийUUID = данныеПользователя.УникальныйИдентификатор;
        текущийПользователь.Наименование = данныеПользователя.Имя;
        текущийПользователь.Записать();

    Иначе
        пользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(
                текущийПользователь.УникальныйИдентификатор);
    КонецЕсли;

    Если пользовательИБ = Неопределено Тогда
        ВызватьИсключение("Ошибка создания нового пользователя.");
	КонецЕсли;
	
    ПараметрыСеанса.ТекущийПользователь = текущийПользователь;

    Возврат текущийПользователь.Ссылка;
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс
