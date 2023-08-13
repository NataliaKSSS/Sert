﻿
#Область ПрограммныйИнтерфейс
Процедура ПроверкаПодключенияСервер(Отказ) ЭКСПОРТ
	
	ПараметрыПодключения = ПараметрыПодключения(); 
	ТекстОшибки = "";
	КлиентКомпоненты = КомпонентаСервер(Отказ, ТекстОшибки);
	
	Попытка
		КлиентКомпоненты.Connect(
		ПараметрыПодключения.Адрес,
		ПараметрыПодключения.Порт,
		ПараметрыПодключения.Логин,
		ПараметрыПодключения.Пароль,
		ПараметрыПодключения.ВиртуальныйХост);   
		Сообщить(НСтр("ru = 'Подключение успешно выполнено!'"));
	Исключение
		СистемнаяОшибка = ОписаниеОшибки(); 
		ТекстСообщения = "ru = 'Ошибка подключения!%СистемнаяОшибка%'";
		ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СистемнаяОшибка%", СистемнаяОшибка);
		Сообщить(СистемнаяОшибка);
	КонецПопытки;
	
КонецПроцедуры  

Процедура ОтправкаОбъектов() ЭКСПОРТ
	Если НЕ TrierRabbitMQОбщийМодульВызовСервера.ОбменСКроликомВозможен() Тогда
		Возврат;
	КонецЕсли;
	
	МассивСообщенийКОтправке      = Новый Массив;
	МассивОтправленныхОбъектов    = Новый Массив;
	МассивСертификатовКОтправке   = Новый Массив; 
	МассивПрисоединенныхКОтправке = Новый Массив;  
	ТекстОшибки                   = "";
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	TrierRabbitMQОбъектыКОтправке.Объект КАК Объект,
	|	ТИПЗНАЧЕНИЯ(TrierRabbitMQОбъектыКОтправке.Объект) КАК ТипЗначения
	|ИЗ
	|	РегистрСведений.TrierRabbitMQОбъектыКОтправке КАК TrierRabbitMQОбъектыКОтправке";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаОбъектыКОтправке = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаОбъектыКОтправке.Следующий() Цикл
		КлючиОтправки = РегистрыСведений.TrierRabbitMQСинхронизируемыеОбъекты.Получить(Новый Структура("ИмяТипаОбъекта,НаправлениеСинхронизации",XMLТип(ВыборкаОбъектыКОтправке.ТипЗначения).ИмяТипа,Перечисления.TrierRabbitMQПеречислениеНаправленияСинхронизации.Исходящая));
		Если НЕ ЗначениеЗаполнено(КлючиОтправки.ПроцедураОбработки) Тогда
			ТекстОшибки = "Не определена процедура обработки";   
			ЗаписьОписанияОшибки(ВыборкаОбъектыКОтправке.Объект,ТекстОшибки);
			Продолжить;	
		КонецЕсли;	 
		Отказ = Ложь;
		Объект = ВыборкаОбъектыКОтправке.Объект;
		
		МассивСообщений = Новый Массив;
		Выполнить(КлючиОтправки.ПроцедураОбработки);       ///сформируем массив сообщений
		
		Попытка
			ОтправкаСообщений(Отказ, МассивСообщений, КлючиОтправки, ТекстОшибки);
		Исключение
			ТекстОшибки = ОписаниеОшибки();
		КонецПопытки;
		
		Если Не Отказ Тогда
			МассивОтправленныхОбъектов.Добавить(ВыборкаОбъектыКОтправке.Объект);
		Иначе 
			ЗаписьОписанияОшибки(Объект,ТекстОшибки);
		КонецЕсли;
	КонецЦикла;
	
	Для каждого ОтправленныйОбъект Из МассивОтправленныхОбъектов  Цикл
		УдалениеЗаписиРегистра(ОтправленныйОбъект);	
	КонецЦикла;
	
КонецПроцедуры

Процедура ПолучениеОбъектов() ЭКСПОРТ
	Отказ = Ложь;
	ТекстОшибки = "";
	
	Если НЕ TrierRabbitMQОбщийМодульСервер.ОбменСКроликомВозможен() Тогда
		Возврат;
	КонецЕсли; 
	ПараметрыПодключенияККомпоненте = ПараметрыПодключения();
	СообщениеКролика = "";
	ЧтениеСообщения(ПараметрыПодключенияККомпоненте, Отказ, ТекстОшибки, СообщениеКролика);
	Если Отказ Тогда
		ЗаписьЖурналаРегистрации("ru = 'Ошибка получения сообщений от Кролика '"+ТекстОшибки,УровеньЖурналаРегистрации.Ошибка);
	КонецЕсли;
	Если СообщениеКролика = "" Тогда 
		Возврат;
	КонецЕсли;
	ОбработкаПолученногоСообщения(СообщениеКролика,Отказ,ТекстОшибки);
КонецПроцедуры

Функция ОбменСКроликомВозможен() ЭКСПОРТ
    ОбменВозможен = Истина;   
	Если НЕ Константы.TrierRabbitMQИспользоватьОбменСКроликом.Получить() Тогда
		Возврат Ложь;
	КонецЕсли;
	Если TrierRabbitMQОбщийМодульВызовСервера.ПолучитьСтруктуруАдресаИБ().ИмяБазы <> Константы.TrierRabbitMQИдентификаторБазы.Получить() Тогда
		ЗаписьЖурналаРегистрации("ru = 'Рассинхронизация идентификаторов ИБ.Обмен с кроликом выполнен не будет'",УровеньЖурналаРегистрации.Ошибка);
		Возврат Ложь;
	КонецЕсли;

	Возврат ОбменВозможен;
КонецФункции

Процедура ОбработкаПолученногоСообщения(СообщениеКролика, Отказ, ТекстОшибки) ЭКСПОРТ
	Чтение = Новый ЧтениеJSON;
	Чтение.УстановитьСтроку(СообщениеКролика);
	Попытка
		Данные = СериализаторXDTO.ПрочитатьJSON(Чтение);
	Исключение 
		ТекстОшибки = ОписаниеОшибки();
		ЗаписьОшибок(СообщениеКролика,ТекстОшибки);
		Отказ = Истина; 
		Возврат;
	КонецПопытки;
	Чтение.Закрыть();	
	
	Если НЕ Данные.Свойство("ИмяТипаОбъекта") Тогда  
		ТекстОшибки = "ru = 'Не указано свойство Имя типа объекта'";
		ЗаписьОшибок(СообщениеКролика,ТекстОшибки);
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("ИмяТипаОбъекта",Данные.ИмяТипаОбъекта);
	СтруктураОтбора.Вставить("НаправлениеСинхронизации",Перечисления.TrierRabbitMQПеречислениеНаправленияСинхронизации.Входящая);
	
	ПроцедураОбработки = РегистрыСведений.TrierRabbitMQСинхронизируемыеОбъекты.Получить(СтруктураОтбора).ПроцедураОбработки;
	
	Если Не ЗначениеЗаполнено(ПроцедураОбработки) Тогда
		ТекстОшибки = "ru = 'Для '"+Данные.ИмяТипаОбъекта+" не определена процедура обработки";
		ЗаписьОшибок(СообщениеКролика,ТекстОшибки);
		Отказ = Истина;
		Возврат;	
	КонецЕсли;
	Попытка 
		Выполнить(ПроцедураОбработки);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		ЗаписьОшибок(СообщениеКролика,ТекстОшибки);
		ЗаписьЖурналаРегистрации(ТекстОшибки,УровеньЖурналаРегистрации.Ошибка);
		Отказ = Истина;
	КонецПопытки;      
	
КонецПроцедуры 

Процедура СозданиеОчередиНаСервере(Отказ) ЭКСПОРТ
	
	ИмяОчереди  = Константы.TrierRabbitMQИдентификаторБазы.Получить();
	Если Не ЗначениеЗаполнено(ИмяОчереди) Тогда
		СистемнаяОшибка = ОписаниеОшибки();
		ТекстСообщения = "ru = 'Не указан идентификатор базы'";
		ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СистемнаяОшибка%", СистемнаяОшибка);
		Сообщить(ТекстСообщения);
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	ПараметрыПодключения = ПараметрыПодключения(); 
	ТекстОшибки = "";
	КлиентКомпоненты = КомпонентаСервер(Отказ, ТекстОшибки);

	
	Попытка
		КлиентКомпоненты.Connect(
		ПараметрыПодключения.Адрес,
		ПараметрыПодключения.Порт,
		ПараметрыПодключения.Логин,
		ПараметрыПодключения.Пароль,
		ПараметрыПодключения.ВиртуальныйХост);   

			
		
		
		КлиентКомпоненты.DeclareQueue(ИмяОчереди, Ложь, Ложь, Ложь, Ложь);
		Сообщить("Очередь создана");

	Исключение
		СистемнаяОшибка = ОписаниеОшибки();
		ТекстСообщения = "ru = 'Ошибка создания точек и очередей!%СистемнаяОшибка%'";
		ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СистемнаяОшибка%", СистемнаяОшибка);
		Сообщить(ТекстСообщения);
		Отказ = Истина;
	КонецПопытки;

КонецПроцедуры

Процедура СозданиеТочкиОбменаНаСервере(Отказ,ИмяТочкиОбмена, КлючМаршрутизации) ЭКСПОРТ
	Если НЕ ЗначениеЗаполнено(ИмяТочкиОбмена) ИЛИ НЕ ЗначениеЗаполнено(КлючМаршрутизации) Тогда
		СистемнаяОшибка = ОписаниеОшибки();
		ТекстСообщения = "Не указано имя точки обмена или ключ маршрутизации";
		ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СистемнаяОшибка%", СистемнаяОшибка);
		Сообщить(ТекстСообщения);
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	ПараметрыПодключения = ПараметрыПодключения(); 
	ТекстОшибки = "";
	КлиентКомпоненты = КомпонентаСервер(Отказ, ТекстОшибки);

	
	Попытка
		КлиентКомпоненты.Connect(
		ПараметрыПодключения.Адрес,
		ПараметрыПодключения.Порт,
		ПараметрыПодключения.Логин,
		ПараметрыПодключения.Пароль,
		ПараметрыПодключения.ВиртуальныйХост);  			
		ТочкаОбмена = ИмяТочкиОбмена;
		
		КлиентКомпоненты.DeclareExchange(ТочкаОбмена, "topic", Ложь, Истина, Ложь);
		КлиентКомпоненты.BindQueue(ПараметрыПодключения.ИмяОчереди, ТочкаОбмена, "#" + КлючМаршрутизации + "#");

		Сообщить("Точка создана, очередь привязана!");

	Исключение
		СистемнаяОшибка = ОписаниеОшибки();
		ТекстСообщения = "ru = 'Ошибка создания точек и очередей!%СистемнаяОшибка%'";
		ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СистемнаяОшибка%", СистемнаяОшибка);
		Сообщить(ТекстСообщения);
		Отказ = Истина;
	КонецПопытки;

	
КонецПроцедуры


#КонецОбласти


#Область СлужебныйПрограммныйИнтерфейс
Функция ПолучитьСтруктуруАдресаИБ() Экспорт
	
	ДанныеСтрокиСоединения = СтрРазделить(СтрокаСоединенияИнформационнойБазы(), ";");
	Если Не ДанныеСтрокиСоединения.Количество() >= 2 Тогда
		ВызватьИсключение "ru = 'Работа с файловыми информационными базами не поддерживается'"; 
	КонецЕсли;
	
	ИмяБазы      = Сред(ДанныеСтрокиСоединения[1], 6, СтрДлина(ДанныеСтрокиСоединения[1]) - 6);
	АдресСервера = Сред(ДанныеСтрокиСоединения[0], 7, СтрДлина(ДанныеСтрокиСоединения[0]) - 7);
	
	ДанныеАдресаСервера = СтрРазделить(АдресСервера, ":");
	
	Результат = Новый Структура;
	Результат.Вставить("Адрес", ИмяКомпьютера());
	Если ДанныеАдресаСервера.Количество() > 1 Тогда
		Результат.Вставить("Порт", XMLЗначение(Тип("Число"), СокрЛП(ДанныеАдресаСервера[1]))) 
	Иначе 
		Результат.Вставить("Порт", 1541);
	КонецЕсли;	
	Результат.Вставить("ИмяБазы", СокрЛП(ИмяБазы));
	
	Возврат Результат;
	
КонецФункции  

Функция УстановитьЗначениеКонстанты(ИмяКонстанты, ЗначениеКонстанты) Экспорт
	
	ТекущееЗначение = ПолучитьЗначениеКонстанты(ИмяКонстанты);
	
	Если Не ТекущееЗначение = ЗначениеКонстанты Тогда
		
		Константы[ИмяКонстанты].Установить(ЗначениеКонстанты);
		Возврат Истина;
		
	Иначе
		
		Возврат Ложь;
		
	КонецЕсли;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
// Функция - Получить значение константы
//
// Параметры:
//	ИмяКонстанты - имя константы, значение которой нужно получить.
//
// Возвращаемое значение:
//	Значение константы, определенной по имени.
//
Функция ПолучитьЗначениеКонстанты(ИмяКонстанты)
	
	Возврат Константы[ИмяКонстанты].Получить();
	
КонецФункции

Процедура ЧтениеСообщения(ПараметрыПодключенияККомпоненте, Отказ, ТекстОшибки, СообщениеКролика)
	КлиентКомпоненты = КомпонентаСервер(Отказ,ТекстОшибки);
	
	Попытка
		КлиентКомпоненты.Connect(
		ПараметрыПодключенияККомпоненте.Адрес,
		ПараметрыПодключенияККомпоненте.Порт,
		ПараметрыПодключенияККомпоненте.Логин,
		ПараметрыПодключенияККомпоненте.Пароль,
		ПараметрыПодключенияККомпоненте.ВиртуальныйХост);
		
		
		Попытка
			
			Потребитель = КлиентКомпоненты.BasicConsume(ПараметрыПодключенияККомпоненте.ИмяОчереди, "", Истина, Ложь, 0);
			
			ОтветноеСообщение = "";
			Если КлиентКомпоненты.BasicConsumeMessage("", ОтветноеСообщение, 5) Тогда
				КлиентКомпоненты.BasicAck();
				СообщениеКролика = ОтветноеСообщение;
			КонецЕсли;
			
			КлиентКомпоненты.BasicCancel(Потребитель);
		Исключение
			Отказ = Истина;
			ТекстОшибки = КлиентКомпоненты.GetLastError();
		КонецПопытки;
	Исключение
		СистемнаяОшибка = ОписаниеОшибки();
		ТекстСообщения = "ru = 'Ошибка чтения сообщения!%СистемнаяОшибка%'";
		ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СистемнаяОшибка%", СистемнаяОшибка);
		Отказ = Истина;
		ТекстОшибки = ТекстСообщения;
	КонецПопытки;
	КлиентКомпоненты = Неопределено;
КонецПроцедуры  

Процедура ЗаписьОшибок(СообщениеКролика, ОписаниеОшибки)
	
	ЗаписьРСОшибок = РегистрыСведений.TrierRabbitMQОшибкиОбработкиСообщений.СоздатьМенеджерЗаписи();
	ЗаписьРСОшибок.Ошибка = ОписаниеОшибки;
	ЗаписьРСОшибок.Сообщение = СообщениеКролика; 
	ЗаписьРСОшибок.ДатаОбработки = ТекущаяДата();    ///пишем дату обработки на сервере
	ЗаписьРСОшибок.Записать(Истина);
	
КонецПроцедуры

Процедура ОтправкаСообщений(Отказ, МассивСообщений, КлючиОтправки, ТекстОшибки) 
	
	КлиентКомпоненты = КомпонентаСервер(Отказ, ТекстОшибки);    
	Если Отказ Тогда
		Возврат;	
	КонецЕсли;
	КлючиОтправки.Вставить("Адрес", Константы.TrierRabbitMQАдресПодключения.Получить());
	КлючиОтправки.Вставить("Порт", Константы.TrierRabbitMQПорт.Получить());
	КлючиОтправки.Вставить("Логин", Константы.TrierRabbitMQЛогин.Получить());
	КлючиОтправки.Вставить("ВиртуальныйХост", Константы.TrierRabbitMQВиртуальныйХост.Получить());
	КлючиОтправки.Вставить("Пароль", Константы.TrierRabbitMQПароль.Получить());
	Для каждого ЭлементМассива Из МассивСообщений Цикл
		ОтправкаСообщения(КлиентКомпоненты, КлючиОтправки, Отказ, ЭлементМассива, ТекстОшибки);	
	КонецЦикла;
	
	
КонецПроцедуры   

Процедура ОтправкаСообщения(КлиентКомпоненты, КлючиОтправки,Отказ, Сообщение, ТекстОшибки)
	
	Попытка
		КлиентКомпоненты.Connect(
		КлючиОтправки.Адрес,
		КлючиОтправки.Порт,
		КлючиОтправки.Логин,
		КлючиОтправки.Пароль,
		КлючиОтправки.ВиртуальныйХост);
		
		ТочкаОбмена    = КлючиОтправки.ТочкаОбмена;
		ТекстСообщения = Сообщение;
		КлючМаршрутизации = КлючиОтправки.КлючМаршрутизации;
		КлиентКомпоненты.BasicPublish(
		ТочкаОбмена,
		КлючМаршрутизации,
		ТекстСообщения,
		1,
		Ложь); 
		
	Исключение
		СистемнаяОшибка = ОписаниеОшибки();
		ТекстСообщения = "ru = 'Ошибка отправки сообщения!%СистемнаяОшибка%'";
		ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СистемнаяОшибка%", СистемнаяОшибка);
		ТекстОшибки = ТекстСообщения;
		Отказ = Истина;
	КонецПопытки;
	
	
КонецПроцедуры

Функция КодВидаНоменклатурыДляУПП(ВидНоменклатуры)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	КИС_СоответствиеКодовВидовНоменклатуры.КодВидаНоменклатурыУПП КАК КодВидаНоменклатурыУПП
	|ИЗ
	|	РегистрСведений.КИС_СоответствиеКодовВидовНоменклатуры КАК КИС_СоответствиеКодовВидовНоменклатуры
	|ГДЕ
	|	КИС_СоответствиеКодовВидовНоменклатуры.ВидНоменклатуры = &ВидНоменклатуры";
	
	Запрос.УстановитьПараметр("ВидНоменклатуры", ВидНоменклатуры);
	
	ВыборкаДетальныеЗаписи = Запрос.Выполнить().Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		Возврат ВыборкаДетальныеЗаписи.КодВидаНоменклатурыУПП;
	Иначе
		Возврат "";
	КонецЕсли;
	
КонецФункции

Функция СериализованныйОбъект(Объект)   
	
	ПараметрыJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет, Символы.Таб);
	Запись = Новый ЗаписьJSON;  
	Запись.УстановитьСтроку(Новый ПараметрыЗаписиJSON());
	СериализаторXDTO.ЗаписатьJSON(Запись,Объект,НазначениеТипаXML.Явное); 
	Текст = Запись.Закрыть(); 
	Возврат Текст;	
КонецФункции    

Функция ПараметрыПодключения()
	
	Структура = Новый Структура;
	Структура.Вставить("Адрес", Константы.TrierRabbitMQАдресПодключения.Получить());
	Структура.Вставить("Порт", Константы.TrierRabbitMQПорт.Получить());
	Структура.Вставить("Логин", Константы.TrierRabbitMQЛогин.Получить());
	Структура.Вставить("Пароль", Константы.TrierRabbitMQПароль.Получить());
	Структура.Вставить("ВиртуальныйХост", Константы.TrierRabbitMQВиртуальныйХост.Получить());
	Структура.Вставить("ИмяОчереди", Константы.TrierRabbitMQИдентификаторБазы.Получить());
	Возврат Структура;
КонецФункции

Функция АдресМакетаКомпоновкиНаСервере()
	
	МакетВнешнейКомпоненты    = ПолучитьОбщийМакет("PinkRabbitMQВнешняяКомпонента");
	АдресВоВременномХранилище = ПоместитьВоВременноеХранилище(МакетВнешнейКомпоненты);
	
	Возврат АдресВоВременномХранилище;
	
КонецФункции

Процедура ПодключитьКомпонентуСервер(Отказ, ТекстОшибки)
	
	АдресВоВременномХранилище = АдресМакетаКомпоновкиНаСервере();
	КомпонентаПодключена = ПодключитьВнешнююКомпоненту(
	АдресВоВременномХранилище,
	"BITERP",
	ТипВнешнейКомпоненты.Native);
	
КонецПроцедуры


Функция КомпонентаСервер(Отказ, ТекстОшибки)
	
	КлиентКомпоненты = Неопределено;
	Если Не ИнициализацияКомпонентыКлиентСервер(КлиентКомпоненты) Тогда
		
		ПодключитьКомпонентуСервер(Отказ, ТекстОшибки);
		Если Отказ Тогда
			ТекстОшибки = "ru = 'Не удалось подключить компоненту'";
		КонецЕсли;
	КонецЕсли;
	
	Возврат КлиентКомпоненты;
КонецФункции

Функция ИнициализацияКомпонентыКлиентСервер(Компонента)
	
	Попытка
		Компонента  = Новый("AddIn.BITERP.PinkRabbitMQ");
		Возврат Истина;
	Исключение
		Возврат Ложь;
	КонецПопытки;
	
КонецФункции  

Процедура УдалениеЗаписиРегистра(Объект)
	Набор = РегистрыСведений.TrierRabbitMQОбъектыКОтправке.СоздатьНаборЗаписей();
	Набор.Отбор.Объект.Установить(Объект);
	Набор.Записать();
КонецПроцедуры

Процедура ЗаписьОписанияОшибки(Объект,ОписаниеОшибки)
	ЗаписьСОшибкой = РегистрыСведений.TrierRabbitMQОбъектыКОтправке.СоздатьМенеджерЗаписи();
	ЗаписьСОшибкой.Объект = Объект;
	ЗаписьСОшибкой.ОписаниеОшибки = ОписаниеОшибки;
	ЗаписьСОшибкой.Записать(Истина);
	
КонецПроцедуры
#КонецОбласти		








