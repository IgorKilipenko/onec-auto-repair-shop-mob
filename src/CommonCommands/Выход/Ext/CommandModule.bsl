﻿#Область Команды

&НаКлиенте
Процедура ОбработкаКоманды(_, __)
    деавторизоватьПользователяНаСервере();
    ЗавершитьРаботуСистемы(Ложь, Истина);
КонецПроцедуры

#КонецОбласти // Команды

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура деавторизоватьПользователяНаСервере()
    Аутентификация.ДеавторизоватьПользователя();
КонецПроцедуры

#КонецОбласти // СлужебныеПроцедурыИФункции
