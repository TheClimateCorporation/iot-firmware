-- GPIO pin connected to data on DHT22 
pin = 6 

-- Source in secrets.lua, if present
l = file.list()
if l['secrets.lua'] then 
  dofile('secrets.lua')
end

function getTemp() --[[
     Input: <none>
     Output: temperature (celcius), humidity
     Notes:
      - uses nodemcu dht library
      - retries until status is OK (checksum is correct)
      - when using FLOAT firmware, _decimal variables are not needed
     --]]
  status = -1
  while (status ~= dht.OK) do
    status,temp,humi,temp_decimial,humi_decimial = dht.readxx(pin)

    ---[[ Print out values for debugging
    print (string.format("Temperature: %.2fC", temp))
    print (string.format("Humidity: %.2f", humi))
    --]]

    if (status ~= dht.OK) then
      print('error reading DHTxx, will retry in 5s')
      tmr.delay(5000000)
    end
  end
  return temp,humi
end

function thingspeakPost(temp, humi) --[[
    Input: temperature, humidity
    Output: <none>
    Notes:
      - ensure that TS_KEY is a valid thingspeak API key!
    --]]
  -- conecting to thingspeak.com
  print("Sending data to thingspeak.com")
  conn=net.createConnection(net.TCP, 0) 
  conn:on("receive", function(conn, payload) print(payload) end)
  -- api.thingspeak.com 184.106.153.149
  conn:connect(80,'184.106.153.149') 
  conn:send("GET /update?key="..TS_KEY.."&field1="..tempF.."&field2="..humi.." HTTP/1.1\r\n"
  .."Host: api.thingspeak.com\r\n"
  .."Accept: */*\r\n"
  .."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
  .."\r\n")
  conn:on("sent",function(conn)
                        print("Closing connection")
                        conn:close()
                    end)
  conn:on("disconnection", function(conn)
                        print("Got disconnection...")
    end)
end

--- Get temp and send data to thingspeak.com
function sendData()
  -- get data from the DHT22
  temp, humi = getTemp()

  tempF = temp * 9 / 5 + 32
  thingspeakPost(tempF, humi)
end

------ MAIN ------
-- send data every X ms to thing speak
sendData()
tmr.alarm(2, 60000, 1, function() sendData() end )
