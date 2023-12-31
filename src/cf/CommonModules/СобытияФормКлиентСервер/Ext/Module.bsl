﻿////////////////////////////////////////////////////////////////////////////////
// Модуль "СобытияФормКлиентСервер" содержит процедуры и функции, работающие на клиенте и сервер
// для событий формы.
//
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// КлиентСерверная переопределяемая процедура, вызываемая из обработчика события элемента.
//
// Параметры:
//   Форма                   - ФормаКлиентскогоПриложения - форма, из которой происходит вызов процедуры.
//   Элемент                 - Строка           - имя элемента-источника события "При изменении".
//   ДополнительныеПараметры - Структура        - значения дополнительных параметров влияющих на обработку.
//
Процедура ПриИзмененииЭлемента(Форма, Элемент, ДополнительныеПараметры = Неопределено) Экспорт
	
	СобытияФормКлиентСерверЛокализация.ПриИзмененииЭлемента(Форма, Элемент, ДополнительныеПараметры);
	
КонецПроцедуры

#КонецОбласти