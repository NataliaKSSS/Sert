<a id="markdown-проектная-работа-otus" name="проектная-работа-otus"></a>
# Обмен сертификатами с помощью RMQ

* содержит встроенную подсистему работы с Кроликов с гибкой настройком и простым внедрением
* показан реализован пример простейшего обмена сертификатами номенклатуры с общим файловым каталогом

# Инструкция по запуску:
Загрузить конфигурацию в две базы
Назначить пользователю Администратор роль "Полные права" и "Администратор системы"
Зайти в меню Администрирование ==> Настройки работы с файлами ==> Установить параметр "Хранить файлы" в значение "В томах на диске"
Нажать ссылку "Тома хранения файлов" и указать том, на котором будут располагаться файлы. При использовании фонового задания по синхронизации доступ к этому тому должен быть у пользователя учетной записи, от имени которой запущен агент сервера 1С.
Перейти в раздел Rabbit MQ, открыть форму констант (Trier rabbit MQ) Константы. Ввести необходимые настройки, нажать кнопку "Установить идентификатор ИБ" - этот идентификатор будет использоваться в качестве очереди на сервере rabbit. После ввода настроек и проверки подключения нужно нажать кнопку "Создать очередь"
Перейти на вкладку Работа с сертификатами, открыть обработку "Установка начальных настроек синхронизации сертификатов", нажать кнопку "Установка настроек обмена сертификатами по умолчанию". Будут загружены настройки в регистр сведений синхронизируемые объекты. Далее нужно нажать кнопку "Создать точку обмена и привязать очередь".
После настройки в первой базе произвести аналогичные настройки в остальных базах. Тома хранения файлов должны вести к одной и той же папке в сети и быть доступны для всех баз.
Для демонстрации был использован простейший алгоритм формирования сообщения (сериализиция объекта). При необходимости можно внести изменения в алгоритм в регистре сведений Синхронизируемые объекты. При изменении алгоритма формирования сообщения необходимо учитывать правила синтаксического контроля платформы 1С, а также ограничения формата JSON.

Предлагаемое решение НЕ создает элементы справочника Товары, а только дополняет информацию об имеющихся сертификатах. Поэтому сообщение не будет обработано в случае, если товара нет в базе приемнике.

Для того, чтобы внести сертификат для товарных позиций необходимо указать у элемента справочника "Товары" признак "Вести учет сертификатов номенклатуры", заполнить Вид номенклатуры и Группу доступа

Далее перейти в справочник Сертификаты номенклатуры и добавить сертификат и его изображение. После записи объекты зарегистрируются к отправке.

Возможны как отправка/прием объектов вручную, так и фоновым заданием, для этого нужно включить использование регламентого задания RabbitMQПриемОтправкаСообщений