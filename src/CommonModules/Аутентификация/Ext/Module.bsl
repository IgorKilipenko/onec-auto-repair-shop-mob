﻿#Область ПрограммныйИнтерфейс

// Выполняет регистрацию или вход пользователя в зависимости от переданных параметров
// Параметры:
//  логин - Строка
//  телефон - Строка, Неопределено
//  регистрация - Булево - Если Истина будет выполнятся регистрация пользователя, иначе вход зарегистрированного пользователя
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * АвторизованныйПользователь - СправочникСсылка.Пользователи, Неопределено
Функция ВыполнитьАутентификациюПользователя(Знач логин, телефон = Неопределено, Знач регистрация = Истина) Экспорт
    результат = Новый Структура("Успех, АвторизованныйПользователь", Истина);

    // Проверка наличия зарегистрированного пользователя а основной базе
    результатПоискаПользователя = ПолучитьВнешнегоПользователя(логин);
    внешнийПользователь = результатПоискаПользователя.Пользователь;

    // Если ошибка запроса пользователя
    Если результатПоискаПользователя.Успех = Ложь Тогда
        Если результатПоискаПользователя.Сообщение <> Неопределено Тогда
            результатПоискаПользователя.Сообщение.Сообщить();
        КонецЕсли;

        результат.Успех = Ложь;
        Возврат результат; // Ошибка соединения
    КонецЕсли;
    
    // Если пользователь существует и это режим регистрации нового пользователя
    Если регистрация = Истина И внешнийПользователь <> Неопределено Тогда
        сообщение = Новый СообщениеПользователю;
        сообщение.Текст =
            "Пользователь с таким логином уже зарегистрирован.
            |Выполните вход.";
        сообщение.Сообщить();
        результат.Успех = Ложь;

        Возврат результат; // Ошибка регистрации - Пользователь существует
    КонецЕсли;

    Если внешнийПользователь = Неопределено Тогда
        Если регистрация = Ложь Тогда
            сообщение = Новый СообщениеПользователю;
            сообщение.Текст =
                "Пользователь с таким логином не зарегистрирован.
                |Сначала выполните регистрацию.";
            сообщение.Сообщить();
            результат.Успех = Ложь;

            Возврат результат;
        КонецЕсли;

        результатСозданияПользователя = РегистрацияНовогоПользователя(логин, телефон);
        Если результатСозданияПользователя.Успех = Ложь Тогда
            сообщение = Новый СообщениеПользователю;
            сообщение.Текст = "Ошибка аутентификацию пользователя.";
            сообщение.Сообщить();
            результат.Успех = Ложь;

            Возврат результат;
        Иначе
            внешнийПользователь = результатСозданияПользователя.Пользователь;
        КонецЕсли;
    КонецЕсли;

    результат.АвторизованныйПользователь = АвторизоватьПользователя(внешнийПользователь);
    Возврат результат;
КонецФункции

Процедура ДеавторизоватьПользователя() Экспорт
    Если ПользователиИнформационнойБазы.ПолучитьПользователей().Количество() > 0 Тогда
        ПользователиИнформационнойБазы.ТекущийПользователь().Удалить();
    КонецЕсли;
    ПараметрыСеанса.ТекущийПользователь = Справочники.Пользователи.ПустаяСсылка();
КонецПроцедуры

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныйПрограммныйИнтерфейс

// Параметры:
//  логин - Строка
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево - Если Истина, ошибки при выполнении запроса отсутствуют
//      * Сообщение - СообщениеПользователю, Неопределено - Сообщение об ошибке
//      * КодСостояния - Число
//      * Пользователь - Неопределено, Структура - Если пользователь отсутствует в основной базе возвращает `Неопределено`
//          ** Имя - Строка
//          ** УникальныйИдентификатор - Строка
Функция ПолучитьВнешнегоПользователя(Знач логин) Экспорт
    результат = Новый Структура("Успех, Сообщение, Пользователь, КодСостояния", Истина);

    соединение = создатьHttpСоединение();
    запрос = Новый HTTPЗапрос(СтрШаблон("%1?name=%2", получитьМаршрутПользователей(), логин));
    ответ = соединение.Получить(запрос);

    результат.КодСостояния = ответ.КодСостояния;

    Если ответ.КодСостояния <> 200 Тогда
        результат.Сообщение = Новый СообщениеПользователю;
        результат.Сообщение.Текст = "При попытке аутентификации произошла ошибка!";
        результат.Успех = Ложь;

        Возврат результат;
    КонецЕсли;

    результатЗапроса = ПрочитатьЗначениеJSON(ответ.ПолучитьТелоКакСтроку());
    Если результатЗапроса.Пользователь = Неопределено Тогда
        результат.Сообщение = Новый СообщениеПользователю;
        результат.Сообщение.Текст = "По логину " + логин + " пользователь не найден!";

        Возврат результат;
    КонецЕсли;

    результат.Пользователь = результатЗапроса.Пользователь;
    Возврат результат;
КонецФункции

// Параметры:
//  данныеПользователя - Структура, ФиксированнаяСтруктура - Пользователь основной базы
//      * Имя - Строка
//      * УникальныйИдентификатор - Строка
// Возвращаемое значение:
//  - СправочникСсылка.Пользователи
Функция АвторизоватьПользователя(Знач данныеПользователя) Экспорт
    пользовательИБ = создатьЛокальногоПользователяИБ(данныеПользователя.Имя);
    Если пользовательИБ = Неопределено Тогда
        ВызватьИсключение("Ошибка создания нового пользователя.");
    КонецЕсли;
    текущийПользователь = найтиПользователяПоВнешнемуИдентификатору(данныеПользователя.УникальныйИдентификатор);

    Если текущийПользователь = Неопределено Тогда
        // Создание пользователя в справочнике
        текущийПользователь = создатьЛокальногоПользователя(
                данныеПользователя.Имя,
                пользовательИБ.УникальныйИдентификатор,
                данныеПользователя.УникальныйИдентификатор);
    КонецЕсли;

    ПараметрыСеанса.ТекущийПользователь = текущийПользователь.Ссылка;

    Возврат текущийПользователь.Ссылка;
КонецФункции

Функция РегистрацияНовогоПользователя(Знач логин, Знач телефон = Неопределено) Экспорт
    результат = Новый Структура("Успех, Пользователь, Сообщение", Истина);

    соединение = создатьHttpСоединение();
    запрос = Новый HTTPЗапрос(получитьМаршрутПользователей());
    запрос.УстановитьТелоИзСтроки(ЗаписатьЗначениеJSON(Новый ФиксированнаяСтруктура("name, phone", логин, телефон)));
    ответ = соединение.ОтправитьДляОбработки(запрос);

    Если ответ.КодСостояния <> 200 Тогда
        результат.Сообщение = Новый СообщениеПользователю;
        результат.Сообщение.Текст = "Ошибка соединения с сервером.";
        результат.Успех = Ложь;

        Возврат результат;
    КонецЕсли;

    результатЗапроса = ПрочитатьЗначениеJSON(ответ.ПолучитьТелоКакСтроку());
    Если результатЗапроса.Успех = Ложь ИЛИ результатЗапроса.Пользователь = Неопределено Тогда
        результат.Сообщение = Новый СообщениеПользователю;
        результат.Сообщение.Текст = СтрШаблон("Ошибка создания пользователя. Сервер не вернул данные созданного пользователя.
                |Сообщение сервера: %1", ?(результатЗапроса.Сообщение = Неопределено, "", результатЗапроса.Сообщение));
        результат.Успех = Ложь;

        Возврат результат;
    КонецЕсли;

    результат.Пользователь = результатЗапроса.Пользователь;
    Возврат результат;
КонецФункции

#КонецОбласти // СлужебныйПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

// Параметры:
//  идентификатор - Строка
// Возвращаемое значение:
//  - Структура
//      * Ссылка - СправочникСсылка.Пользователи
//      * Код - Строка - ИдентификаторПользователяИБ
Функция найтиПользователяПоВнешнемуИдентификатору(Знач идентификатор)
    запрос = Новый Запрос;
    запрос.Текст =
        "ВЫБРАТЬ
        |   Пользователи.Ссылка КАК Ссылка,
        |   Пользователи.Код КАК Код
        |ИЗ
        |   Справочник.Пользователи КАК Пользователи
        |ГДЕ
        |   Пользователи.ВнешнийUUID = &Идентификатор
        |";
    запрос.УстановитьПараметр("Идентификатор", идентификатор);
    результатЗапроса = запрос.Выполнить();
    Если результатЗапроса.Пустой() Тогда
        Возврат Неопределено;
    КонецЕсли;

    результат = Новый Структура("Ссылка, Код");
    ЗаполнитьЗначенияСвойств(результат, результатЗапроса.Выгрузить()[0]);

    Возврат результат;
КонецФункции

Функция получитьАдресСервера()
    адресСервера = Константы.АдресСервераИБ.Получить();
    адресСервера = ?(ПустаяСтрока(адресСервера), "10.0.2.2", адресСервера);
    Возврат адресСервера;
КонецФункции

// Возвращаемое значение:
//  - HTTPСоединение
Функция создатьHttpСоединение()
    адресСервера = получитьАдресСервера();
    соединение = Новый HTTPСоединение(адресСервера, , "MobileClient", , , 1000);
    Возврат соединение;
КонецФункции

// Возвращаемое значение:
//  - Строка - Эндпоинт User
Функция получитьМаршрутПользователей()
    Возврат "auto-repair-shop/hs/users/user";
КонецФункции

// Создает локального пользователя информационной базы
// Параметры:
//  имя - Строка
// Возвращаемое значение:
//  - ПользовательИнформационнойБазы
Функция создатьЛокальногоПользователяИБ(Знач имя)
    пользовательИБ = ПользователиИнформационнойБазы.СоздатьПользователя();
    пользовательИБ.Имя = имя;
    пользовательИБ.Роли.Добавить(Метаданные.Роли.АвторизованныйПользователь);
    пользовательИБ.Записать();

    Возврат пользовательИБ;
КонецФункции

// Создает локального пользователя в справочнике
// Параметры:
//  имя - Строка
//  идентификатор - Строка - Код
//  внешнийИдентификатор - Строка - Идентификатор пользователя в основной базе
// Возвращаемое значение:
//  - СправочникОбъект.Пользователи
Функция создатьЛокальногоПользователя(Знач имя, Знач идентификатор, Знач внешнийИдентификатор)
    текущийПользователь = Справочники.Пользователи.СоздатьЭлемент();
    текущийПользователь.Код = идентификатор;
    текущийПользователь.ВнешнийUUID = внешнийИдентификатор;
    текущийПользователь.Наименование = имя;
    текущийПользователь.Записать();

    Возврат текущийПользователь;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
