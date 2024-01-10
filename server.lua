local http = require('http.server')
local box = require('box')
local json = require('cjson')
local http_client = require('socket.http')

-- Подключение к базе данных
box.cfg{}

-- Создание пространства (таблицы) в базе данных
local space = box.schema.space.create('my_space')
space:format({
    {name = 'id', type = 'integer'},
    {name = 'name', type = 'string'}
})
space:create_index('primary', {parts = {'id'}, unique = true})

-- Получение данных из URL
local url = 'https://data.id/'
local response, status = http_client.request(url)
if status == 200 then
    local data = json.decode(response)
    for _, user in ipairs(data) do
        space:insert{user.id, user.name}
    end
end

-- Создание сервера приложений
local server = http.new()

-- Обработчик для эндпоинта '/'
server:route({path = '/'}, function(req, res)
    res:write('Hello, world!')
end)

-- Обработчик для эндпоинта '/users'
server:route({path = '/users'}, function(req, res)
    local users = space:select()
    res:json(users)
end)

-- Обработчик для эндпоинта '/user' с методом POST
server:route({path = '/user', method = 'POST'}, function(req, res)
    local data = req:json()
    space:insert{data.id, data.name}
    res:write('User created successfully')
end)

-- Запуск сервера на порту 8080
server:listen(8080)
