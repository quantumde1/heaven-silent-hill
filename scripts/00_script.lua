
--[[ НАЧАЛО ОБЪЯВЛЕНИЯ ФУНКЦИЙ LUA ]]--


-- Функция для сравнения двух таблиц
function tablesEqual(table1, table2)
    if #table1 ~= #table2 then
        return false
    end
    for i = 1, #table1 do
        if table1[i] ~= table2[i] then
            return false
        end
    end
    return true
end

function checkCoordinatesEquality(x_current, y_current, z_current, x_needed, y_needed, z_needed)
    local deviation = 4
    if (x_current >= x_needed - deviation and x_current <= x_needed + deviation) then
        if (y_current >= y_needed - deviation and y_current <= y_needed + deviation) then
            if (z_current >= z_needed - deviation and z_current <= z_needed + deviation) then
                return true
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
    return false
end

--[[ КОНЕЦ ОБЪЯВЛЕНИЯ ФУНКЦИЙ LUA ]]--


--[[ НАЧАЛО ОБЪЯВЛЕНИЙ ГЛОБАЛЬНЫХ ПЕРЕМЕННЫХ ]]--

local globalDialogForNPC1 = {""}
local globalDialogForNPC2 = {""}
local answerValue
local dialogCoroutine
previousDialogName = ""
-- первоначальная позиция-триггер
local neededPosition = { 4.0, 0.0, 10.0 }
local currentStage = 0 -- Переменная для отслеживания текущего этапа

--[[ КОНЕЦ ОБЪЯВЛЕНИЯ ГЛОБАЛЬНЫХ ПЕРЕМЕННЫХ]]--


--[[ НАЧАЛО СИСТЕМНЫХ ФУНКЦИЙ ДВИЖКА ]]--

-- loadMusic и loadMusicExternal. Первый грузит из res/data.bin, второй откуда скажете в файловой системе.
loadMusicExternal("./res/silent.mp3")
playMusic()

function _2dEventLoopCoroutine()
    dialogCoroutine = coroutine.create(function()
        if currentStage == 0 then
            disallowControl()
            startTime = getTime()
            while getTime() - startTime < 1.0 do
                coroutine.yield() -- Wait for 2 seconds
            end
            rotateCamera(50, 40)
            while isCameraRotating() do
                coroutine.yield() -- Wait for 2 seconds
            end
            startTime = getTime()
            while getTime() - startTime < 0.5 do
                coroutine.yield() -- Wait for 2 seconds
            end
            rotateCamera(130, 40)
            while isCameraRotating() do
                coroutine.yield() -- Wait for 2 seconds
            end
            startTime = getTime()
            while getTime() - startTime < 0.5 do
                coroutine.yield() -- Wait for 2 seconds
            end
            rotateCamera(90, 40)
            while isCameraRotating() do
                coroutine.yield() -- Wait for 2 seconds
            end
            showHint("Where... where am I?...")
            startTime = getTime()
            while getTime() - startTime < 2.0 do
                coroutine.yield() -- Wait for 2 seconds
            end
            hideHint()
            showHint("I guess i need to look around. Maybe, i'll find something useful...")
            startTime = getTime()
            while getTime() - startTime < 2.0 do
                coroutine.yield() -- Wait for 2 seconds
            end
            hideHint()
            allowControl()
            currentStage = 1
        end
        if currentStage == 2 then
            hideHint()
            showHint("Picked up a \"Old key.\"")
            startTime = getTime()
            while getTime() - startTime < 2.0 do
                coroutine.yield() -- Wait for 2 seconds
            end
            hideHint()
        end
    end)
end

function _3dEventLoop()
    if currentStage == 1 then
        if checkCoordinatesEquality(getPlayerX(), getPlayerY(), getPlayerZ(), 0, 0, -10) == true then
            showHint("Key is lying here.")
            if isKeyPressed(getButtonName("dialog")) then
                startTime = getTime()
                currentStage = 2
                addToInventoryTab("Old key", 0)
                _2dEventLoopCoroutine()
            end
        else
            hideHint()
        end
    end
end

-- Функция для обновления диалога
function _2dEventLoop()
    if dialogCoroutine and coroutine.status(dialogCoroutine) ~= "dead" then
        coroutine.resume(dialogCoroutine) -- Возобновление выполнения корутины
    end
end

--[[ КОНЕЦ СИСТЕМНЫХ ФУНКЦИЙ ДВИЖКА ]]--


--[[ НАЧАЛО ФУНКЦИЙ ОБЪЯВЛЕНИЯ ОСНОВНЫХ КОМПОНЕНТОВ ]]--

-- Установка безопасной зоны
setFriendlyZone(1) -- 1 - дружелюбно, 0 - враждебно, т.е появляются случайные встречи с врагами
-- Установка модели игрока
-- 1 аргумент путь, второй - размер
setPlayerModel("res/mc.glb", 1.0)
setCameraRotationSpeed(1.16)
addPartyMember(120, 0, "quantumde1", 1, 0, 0)
walkAnimationValue(10)
idleAnimationValue(2)
runAnimationValue(6)
-- Настройка позиции камеры
-- установка камеры и ее возможости по X Y Z
changeCameraPosition(0.0, 10.0, 15.0)
changeCameraTarget(0.0, 4.0, 0.0)
changeCameraUp(0.0, 1.0, 0.0)
-- 0 значит скрыть модель гг, 1 - показать
drawPlayerModel(1);
-- Добавление кубов
-- необходимо, так как движок статически инициализирует количество моделей на экране.
-- adding objects to inventory
configureInventoryTabs({"Items", "System"})
addToInventoryTab("Exit game", 1)
loadScene("res/scene1.json")
fogSwitcher(1)
-- инициализация событий
_2dEventLoopCoroutine()

--[[ КОНЕЦ ФУНКЦИЙ ОБЪЯВЛЕНИЯ ОСНОВНЫХ КОМПОНЕНТОВ ]]--