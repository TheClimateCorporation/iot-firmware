local inpin = 6
gpio.mode(inpin, gpio.INT)

local PORT = 8080
local URI = "/iot/v1/rosie/motion"
local device_id = node.chipid()

function debug(message)
    print("[DEBUG - " .. tmr.time() .. "] " .. message)
end

function build_request(d, start)
    local duration_since_start = tmr.time() - start
    debug("duration since start " .. duration_since_start)
    local body = '{"duration-s": ' .. d .. ', "duration-since-start-s": ' .. duration_since_start ..
            ', "device-id": "' .. device_id .. '"}'

    local request = "POST " .. URI .. " HTTP/1.1\r\n" ..
            "Host: " .. HOST .. "\r\n" ..
            "Connection: close\r\n" ..
            "Content-Type: application/json\r\n" ..
            "x-http-caller-id: " .. device_id .. "\r\n" ..
            "Content-Length: " .. string.len(body) .. "\r\n\r\n" ..
            body .. "\r\n"

    debug(request)

    return request
end

function on_receive(_, payload)
    debug("Response " .. payload)
end

function send_duration(duration, start)
    debug("duration " .. duration .. " start " .. start)

    if wifi.sta.status() < 5 then
        debug("wifi not connected " .. wifi.sta.status())
        tmr.alarm(0, 5000, 0, function() send_duration(duration, start) end)
        debug("alarm set")
    else
        local conn = net.createConnection(net.TCP, 0)

        conn:on("connection", function(conn)
            local request = build_request(duration, start)

            debug("sending")
            conn:send(request)
            debug("sent")
        end)
        conn:on("receive", on_receive)

        debug("connecting to http://" .. HOST .. ":" .. PORT .. URI)
        conn:connect(PORT, HOST)
        debug("connected")
    end
end

function motion_start()
    if stopwatch.started then
        debug("stopwatch already started")
    else
        stopwatch.started = true
        stopwatch.start = tmr.time()
        debug("Motion detected!")
        debug("start: " .. stopwatch.start)
        gpio.trig(inpin, "down", motion_stop)
    end
end

function motion_stop()
    if not stopwatch.started then
        debug("stopwatch already stopped")
    else
        local last_end = tmr.time()
        local last_start = stopwatch.start
        local duration = last_end - last_start
        debug("motion started " .. last_start .. " ended " .. last_end .. " after " .. duration .. " seconds.")
        debug("after delay")
        debug("sending duration")
        send_duration(duration, last_start)
        debug("duration sent")
        stopwatch.started = false
        gpio.trig(inpin, "up", motion_start)
        debug("resetting pin")
    end
end

stopwatch = {}
stopwatch.started = false
stopwatch.start = tmr.time()

gpio.trig(inpin, "up", motion_start)
