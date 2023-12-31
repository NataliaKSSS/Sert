﻿
#Область ПрограммныйИнтерфейс
Процедура TrierRabbitMQ_ПриЗаписиСправочников(Источник, Отказ) Экспорт 
	
	Если НЕ TrierRabbitMQОбщийМодульВызовСервера.ОбменСКроликомВозможен() Тогда
		Возврат;
	КонецЕсли;

	Если Источник.ДополнительныеСвойства.Свойство("НеОтправлятьКролику") Тогда
		Возврат;
	КонецЕсли;  
	ИмяТипаОбъекта = XMLТип(ТипЗнч(Источник.Ссылка)).ИмяТипа;
	Если Не ЗначениеЗаполнено(РегистрыСведений.TrierRabbitMQСинхронизируемыеОбъекты.Получить(Новый Структура("ИмяТипаОбъекта, НаправлениеСинхронизации",ИмяТипаОбъекта, Перечисления.TrierRabbitMQПеречислениеНаправленияСинхронизации.Исходящая)).ТочкаОбмена) Тогда
		Возврат;	
	КонецЕсли;	
	ЗаписьКОтправке = РегистрыСведений.TrierRabbitMQОбъектыКОтправке.СоздатьМенеджерЗаписи();
	ЗаписьКОтправке.Объект = Источник.Ссылка;
	ЗаписьКОтправке.Записать(Истина);
		
КонецПроцедуры 

#КонецОбласти
