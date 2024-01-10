local box = require('box')

-- Создание пространства (таблицы) в базе данных
local space = box.schema.space.create('NemBD')
space:format({
    {name = 'id', type = 'unsigned'},
    {name = 'name', type = 'string'}
})
space:create_index('primary', {parts = {'id'}, unique = true})

-- Создание пользователя с идентификатором 1
space:insert{1, 'John Doe'}

-- Создание пользователя с идентификатором 2
space:insert{2, 'Jane Smith'}

-- Завершение работы с базой данных
box.space.NemBD:close()
