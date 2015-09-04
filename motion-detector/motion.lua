local inpin = 6
gpio.mode(inpin, gpio.INT)

start = tmr.time()
lastEnd = 0

local PORT = 8080
local URI = "/iot/v1/rosie/motion"
local device_id = node.chipid()

function build_request(d)
    local body = '{"duration-s": ' .. d .. ', "device-id": "' .. device_id .. '"}'

    local request = "POST " .. URI .. " HTTP/1.1\r\n" ..
            "Host: " .. HOST .. "\r\n" ..
            "Connection: close\r\n" ..
            "Content-Type: application/json\r\n" ..
            "x-http-caller-id: " .. device_id .. "\r\n" ..
            "Content-Length: " .. string.len(body) .. "\r\n\r\n" ..
            body .. "\r\n"

    print(request)

    return request
end

function on_receive(sck, payload)
    print("Response " .. payload)
end

function on_reconnection(sck)
    print("Reconnection")
end

function on_disconnection(sck)
    print("Disconnection")
end

function on_sent(sck)
    print("Sent")
end

function send_duration(d)
    print("duration " .. d)

    if wifi.sta.status() < 5 then
        print("wifi not connected " .. wifi.sta.status())
        tmr.alarm(0, 5000, 0, function () send_duration(d) end)
        print("alarm set")
    else
        conn = net.createConnection(net.TCP, 0)

        conn:on("connection", function(conn)
            local request = build_request(d)

            print("sending")
            conn:send(request)
            print("sent")
        end)
        conn:on("receive", on_receive)
        conn:on("reconnection", on_reconnection)
        conn:on("disconnection", on_disconnection)
        conn:on("sent", on_sent)

        print("connecting to http://" .. HOST .. ":" .. PORT .. URI)
        conn:connect(PORT, HOST)
        print("connected")
    end
end

function motion_start()
    start = tmr.time()
    print("Motion detected!")
    print("[DEBUG] start: " .. start .. ", last: " .. lastEnd ..
            ", break: " .. start - lastEnd)
    gpio.trig(inpin, "down", motion_stop)
end

function motion_stop()
    lastEnd = tmr.time()
    local d = lastEnd - start
    print("motion ended " .. lastEnd .. " after " .. d .. " seconds.")
    print("[DEBUG] start: " .. start .. ", duration: " .. d)
    print("after delay")
    print("sending duration")
    send_duration(d)
    print("duration sent")
    gpio.trig(inpin, "up", motion_start)
    print("resetting pin")
end

gpio.trig(inpin, "up", motion_start)
