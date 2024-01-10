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

-- Авторизация
local function authenticate(req)
    local auth_header = req:headers()['authorization']
    if not auth_header or auth_header ~= 'Bearer my_token' then
        req:response({status = 401}):write('Unauthorized')
        return false
    end
    return true
end

-- Получение данных из URL
local url = 'https://data.id/'
local max_retries = 3
local retry_delay = 1
local data = nil
for i = 1, max_retries do
    local response, status = http_client.request(url)
    if status == 200 then
        data = json.decode(response)
        break
    else
        box.error('Failed to retrieve data from URL (' .. status .. '). Retrying in ' .. retry_delay .. ' seconds...')
        box.delay(retry_delay * 1000)
    end
end
if not data then
    box.error('Failed to retrieve data from URL after ' .. max_retries .. ' retries.')
end

-- Добавление данных в базу данных
for _, user in ipairs(data) do
    space:insert{user.id, user.name}
end

-- Создание сервера приложений
local server = http.new()

-- Обработчик для эндпоинта '/'
server:route({path = '/'}, function(req, res)
    if not authenticate(req) then
        return
    end
    res:write('Hello, world!')
end)

-- Обработчик для эндпоинта '/users'
server:route({path = '/users'}, function(req, res)
    if not authenticate(req) then
        return
    end
    local users = space:select()
    res:json(users)
end)

-- Обработчик для эндпоинта '/user' с методом POST
server:route({path = '/user', method = 'POST'}, function(req, res)
    if not authenticate(req) then
        return
    end
    local data = req:json()
    space:insert{data.id, data.name}
    res:write('User created successfully')
end)

-- Запуск сервера на порту 8080
server:listen(8080)
