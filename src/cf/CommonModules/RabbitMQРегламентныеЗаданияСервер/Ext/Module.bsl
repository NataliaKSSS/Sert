﻿   #Область ПрограммныйИнтерфейс
Процедура ФоноваяОтправкаСообщенийКролику() ЭКСПОРТ
	TrierRabbitMQОбщийМодульВызовСервера.ОтправкаОбъектов();	
КонецПроцедуры

Процедура ФоновоеПолучениеСообщенийОтКролика() ЭКСПОРТ
	TrierRabbitMQОбщийМодульВызовСервера.ПолучениеОбъектов();	
КонецПроцедуры

Процедура ФоноваяОтправкаИПолучениеСообщенийОтКролика() ЭКСПОРТ
	ФоноваяОтправкаСообщенийКролику();
	ФоновоеПолучениеСообщенийОтКролика();
КонецПроцедуры
#КонецОбласти
