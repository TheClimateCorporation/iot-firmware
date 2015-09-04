-- print wifi information
print(wifi.sta.status())
print(wifi.sta.getip())
print(wifi.getmode())
print(wifi.sta.getbroadcast())
print(wifi.sta.getconfig())

-- 1 = autoconnect
wifi.sta.config(ssid, ssid_pass, 1)
wifi.sta.disconnect()
wifi.sta.connect()


