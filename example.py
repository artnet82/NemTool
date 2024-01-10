from nemtoolapi import NemToolAPI

# Параметры подключения к PostgreSQL базе данных
host = 'localhost'
port = 5432
database = 'mydatabase'
user = 'myuser'
password = 'mypassword'

# Создание экземпляра NemToolAPI
api = NemToolAPI(host, port, database, user, password)

# Создание таблицы
table_name = 'my_table'
columns = ['id INT', 'name TEXT']
api.create_table(table_name, columns)

# Вставка данных
data = {'id': 1, 'name': 'John'}
api.insert_data(table_name, data)

# Выборка данных
result = api.select_data(table_name)
print(result)

# Закрытие соединения
api.close_connection()
