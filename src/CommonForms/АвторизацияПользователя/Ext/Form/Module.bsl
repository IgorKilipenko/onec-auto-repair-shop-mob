﻿#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВходПользователя(_)
    Если ЗначениеЗаполнено(ЭтотОбъект.Логин) = Ложь Тогда
        сообщение = Новый СообщениеПользователю;
        сообщение.Текст = "Логин должен быть заполнен.";
        сообщение.Поле = "Логин";
        сообщение.УстановитьДанные(ЭтотОбъект);
        сообщение.Сообщить();

        Возврат;
    КонецЕсли;

    выполнитьАутентификациюПользователяНаСервере(ЭтотОбъект.Логин);
    ЗавершитьРаботуСистемы(Ложь, Истина);
КонецПроцедуры

#КонецОбласти // ОбработчикиКомандФормы

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ЛогинПриИзменении(_)
    ЭтотОбъект.Логин = СокрЛП(ЭтотОбъект.Логин);
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийЭлементовШапкиФормы

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Процедура выполнитьАутентификациюПользователяНаСервере(Знач логин)
    Аутентификация.ВыполнитьАутентификациюПользователя(логин, Неопределено, Ложь);
КонецПроцедуры

#КонецОбласти // СлужебныеПроцедурыИФункции
