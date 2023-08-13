﻿#language: ru

@tree

Функционал: Создание элементов НСИ

Как Администратор НСИ я хочу
создать элемент номенклатуры
чтобы вести аналитичский учет   


Сценарий: Создание элементов НСИ
Дано Я запускаю сценарий открытия TestClient или подключаю уже существующий
	Создание элемента справочника товары
		И В командном интерфейсе я выбираю 'Главное' 'Товары'
		Тогда открылось окно 'Товары'
		И я нажимаю на кнопку с именем 'ФормаСоздать'
		Тогда открылось окно 'Товар (создание)'
		И в поле с именем 'Наименование' я ввожу текст 'Тестовый товар'
		И я нажимаю кнопку выбора у поля с именем "ВидНоменклатуры"
		Тогда открылось окно 'Виды номенклатуры'
		И в таблице "Список" я выбираю текущую строку
		Тогда открылось окно 'Товар (создание) *'
		И я нажимаю кнопку выбора у поля с именем "ГруппаДоступа"
		Тогда открылось окно 'Группы доступа номенклатуры'
		И я нажимаю на кнопку с именем 'ФормаСоздать'
		Тогда открылось окно 'Группы доступа номенклатуры (создание)'
		И в таблице "СписокГруппДоступа" я нажимаю на кнопку с именем 'СписокГруппДоступаДобавить'
		И в таблице "СписокГруппДоступа" в поле с именем 'СписокГруппДоступаЗначение' я ввожу текст 'ДК1'
		И в таблице "СписокГруппДоступа" я завершаю редактирование строки
		И я нажимаю на кнопку с именем 'ФормаЗаписатьИЗакрыть'
		И я жду закрытия окна 'Группы доступа номенклатуры (создание)' в течение 20 секунд
		Тогда открылось окно 'Группы доступа номенклатуры'
		И в таблице "Список" я выбираю текущую строку
		Тогда открылось окно 'Товар (создание) *'
		И я изменяю флаг с именем 'ВестиУчетСертификатовНоменклатуры'
		И я нажимаю на кнопку с именем 'ФормаЗаписатьИЗакрыть'
		И я жду закрытия окна 'Товар (создание) *' в течение 20 секунд
//	Настройка работы с файлами запускать только один раз. на второй будет ошибка
//		И В командном интерфейсе я выбираю 'Администрирование' 'Настройки работы с файлами'
//		Тогда открылось окно 'Настройки работы с файлами'
//		И из выпадающего списка с именем "СпособХраненияФайлов" я выбираю точное значение 'в томах на диске'
//		И я нажимаю на кнопку с именем 'СправочникТомаХраненияФайлов'
//		Тогда открылось окно 'Тома хранения файлов'
//		И я нажимаю на кнопку с именем 'ФормаСоздать'
//		Тогда открылось окно 'Том хранения файлов (создание)'
//		И в поле с именем 'ПолныйПутьWindows' я ввожу текст '\\mfs\ОИТО\Кривова\Otus_Project\Files'
//		И в поле с именем 'Наименование' я ввожу текст '\\mfs\ОИТО\Кривова\Otus_Project\Files'
//		И я нажимаю на кнопку с именем 'ФормаЗаписатьИЗакрыть'
//		И я жду закрытия окна 'Том хранения файлов (создание) *' в течение 20 секунд
	Настройка RMQ
		Когда В панели разделов я выбираю 'Rabbit MQ'
		И В командном интерфейсе я выбираю 'Rabbit MQ' 'Rabbit MQ Константы'
		Тогда открылось окно 'Rabbit MQ Константы'
		И я нажимаю на кнопку с именем 'УстановитьИдентификаторИБ'
		Тогда открылось окно 'Rabbit MQ Константы'
		И я изменяю флаг с именем 'TrierRabbitMQИспользоватьОбменСКроликом'
		И в поле с именем 'TrierRabbitMQАдресПодключения' я ввожу текст '192.168.34.105'
		И в поле с именем 'TrierRabbitMQПорт' я ввожу текст '5 672'
		И я перехожу к следующему реквизиту
		И в поле с именем 'TrierRabbitMQЛогин' я ввожу текст 'ERP'
		И я перехожу к следующему реквизиту
		И в поле с именем 'TrierRabbitMQПароль' я ввожу текст '77766613'
		И я нажимаю на кнопку с именем 'ФормаЗаписать'
		Тогда открылось окно 'Rabbit MQ Константы'
		И я нажимаю на кнопку с именем 'ФормаПроверитьПодключение'
		И я нажимаю на кнопку с именем 'ФормаСоздатьОчередь'
		И я нажимаю на кнопку с именем 'ФормаЗаписатьИЗакрыть'
		И я жду закрытия окна 'Rabbit MQ Константы' в течение 20 секунд
	Настройка работы с сертификатами
		И В командном интерфейсе я выбираю 'Работа с сертификатами' 'Установка начальных настроек синхронизации сертификатов'
		Тогда открылось окно 'Установка начальных настроек синхронизации сертификатов'
		И я нажимаю на кнопку с именем 'ФормаУстановкаНастроекОбменаСертификатамиПоУмолчанию'
		И из выпадающего списка с именем "ГруппаДоступаДляТекущейБазы" я выбираю точное значение 'ДК1'
		И я нажимаю на кнопку с именем 'СоздатьТочкуОбменаИПривязатьОчередь'
	Добавление сертификатов номенклатуры
		И В командном интерфейсе я выбираю 'Работа с сертификатами' 'Сертификаты номенклатуры'
		Тогда открылось окно 'Сертификаты номенклатуры'
		И я нажимаю на кнопку с именем 'СертификатыНоменклатурыСоздать'
		Тогда открылось окно 'Сертификат номенклатуры (создание)'
		И из выпадающего списка с именем "ТипСертификата" я выбираю точное значение 'Декларация о соответствии'
		И в поле с именем 'Статус' я ввожу текст 'Действует'
		И я перехожу к следующему реквизиту
		И в поле с именем 'Номер' я ввожу текст '1234567'
		И я перехожу к следующему реквизиту
		И в поле с именем 'ДатаНачалаСрокаДействия' я ввожу текст '01.01.2023'
		И я изменяю флаг с именем 'Бессрочный'
		И в поле с именем 'ОрганВыдавшийДокумент' я ввожу текст 'школой магии'
		И я нажимаю кнопку выбора у поля с именем "Номенклатура"
		Тогда открылось окно 'Товары'
		И в таблице "Список" я перехожу к строке:
		| 'Код'       | 'Наименование'   |
		| '000000001' | 'Тестовый товар' |
		И в таблице "Список" я выбираю текущую строку
		Тогда открылось окно 'Сертификат номенклатуры (создание) *'
		И я нажимаю на кнопку с именем 'СтраницаПометитьНаУдалениеДобавитьИзображение'
		И я выбираю файл 'M:\Кривова\Инструкции, документы\Документация\Сертификация_BPMN.jpg'
		Тогда открылось окно 'Сертификат номенклатуры (создание) *'
		И я нажимаю на кнопку с именем 'ФормаЗаписатьИЗакрыть'
		И я жду закрытия окна 'Сертификат номенклатуры (создание) *' в течение 20 секунд
	Отправка и получение объектов 
		И В командном интерфейсе я выбираю 'Rabbit MQ' '(Trier rabbit MQ) Объекты к отправке'
		Тогда открылось окно '(Trier rabbit MQ) Объекты к отправке'
		И Я закрываю окно '(Trier rabbit MQ) Объекты к отправке'
		И В командном интерфейсе я выбираю 'Rabbit MQ' 'Прием и отправка сообщений RMQ'
		Тогда открылось окно 'Прием и отправка сообщений RMQ'
		И я нажимаю на кнопку с именем 'ОтправитьОбъекты'
		И я перехожу к закладке с именем "ПолучитьСообщение"
		И я нажимаю на кнопку с именем 'ПолучениеОбъектовОбщийМодуль'
					
							


