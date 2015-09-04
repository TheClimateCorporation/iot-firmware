-- print file contents
file.open("motion.lua", "r")
print(file.read('\r'))
file.close()

-- list files
l = file.list();
for k,v in pairs(l) do
    print("name:"..k..", size:"..v)
end