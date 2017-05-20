local computer = require "computer"
local fs = require "filesystem"
local robot = require "robot"
local serial=require "serialization"
local shell = require "shell"
NORTH = 0
EAST = 1
SOUTH = 2
WEST = 3

t = {}
local args, options = shell.parse(...)
function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function save_table(fn,table)
	local f=io.open(fn,"w")
	f:write(serial.serialize(table))
	f:close()
end

function load_table(fn)
	local f=io.open(fn,"r")
	local txt=f:read("*all")
	f:close()
	tab = serial.unserialize(txt)
	return tab
end

function t.savePos()
	local pos = {}
	pos.x = t.x
	pos.y = t.y
	pos.z = t.z
	pos.f = t.f
	save_table("pos",pos)
end

function t.getPos()
	if file_exists("pos")==false then
		--pos = {}
		t.x=13
		t.y=75
		t.z=212
		t.f=NORTH
	else
		local pos = load_table("pos")
		t.x = pos.x
		t.y = pos.y
		t.z = pos.z
		t.f = pos.f
	end
end

function cRight(f)
    f = (f + 1) % 4
	return f
end

function cLeft(f)
    f = (f - 1) % 4
	return f
end
	
function t.right(n)
	n = n or 1
	for i=1,n do
		robot.turnRight()
		t.f = (t.f + 1) % 4
		t.savePos()
	end
end

function t.left(n)
	n = n or 1
	for i=1,n do
		robot.turnLeft()
		t.f = (t.f - 1) % 4
		t.savePos()
	end
end

function t.rotate_to(to_f)
	local my_f = t.f
	if my_f~=to_f then
		local cl=0
		local cr=0
		--test left first
		local temp=my_f
		while temp~=to_f do
			temp=cLeft(temp)
			cl=cl+1
		end	
		--test right
		temp=my_f
		while temp~=to_f do
			temp=cRight(temp)
			cr=cr+1
		end
		if cl>cr then
			--print 'turnRight * %d'%cr
			t.right(cr)
		elseif cl<cr then
			--print 'turnLeft * %d'%cl
			t.left(cl)
		else
			--print('doesnt matter * %d'%cl
			t.right(cr)
		end
	end
end

function t.f_e()
	if t.f~=EAST then
		t.rotate_to(EAST)
		t.savePos()
	end
end

function t.f_w()
	if t.f~=WEST then
		t.rotate_to(WEST)
		t.savePos()
	end
end

function t.f_s()
	if t.f~=SOUTH then
		t.rotate_to(SOUTH)
		t.savePos()
	end
end

function t.f_n()
	if t.f~=NORTH then
		t.rotate_to(NORTH)
		t.savePos()
	end
end

--function t.try_move(x,y,z,f)

--end

function calc_deltas(p0,p1)
	local delta = (p0*-1)+p1
	return delta
end

function t.to_x(x)

	local delta = (t.x*-1)+x
	print('delta x:', delta)
	if delta<0 then
		--aboutface
		t.f_w()
		print('facing west')
		for i=1,math.abs(delta) do
			robot.forward()
			t.x = t.x - 1
			t.savePos()
			print('t.x->', t.x)
		end
	elseif delta>0 then
		t.f_e()
		print('facing east')
		for i=1,math.abs(delta) do
			robot.forward()
			t.x = t.x + 1
			t.savePos()
			print('t.x->', t.x)
		end
	end
end

function t.to_y(y)
	local delta = (t.y*-1)+y
	print('delta z:',delta)
	if delta>0 then
		print('going up')
		for i=1,math.abs(delta) do
			robot.up()
			t.y = t.y + 1
			t.savePos()
		end
	elseif delta<0 then
		print('going down')
		for i=1,math.abs(delta) do
			robot.down()
			t.y = t.y - 1
			t.savePos()
		end
	end
end

function t.to_z(z)
	local delta = (t.z*-1)+z
	print('delta z:',delta)
	if delta>0 then
		--aboutface
		t.f_s()
		print('facing south')
		--mc coords are stupid
		for i=1,math.abs(delta) do
			local success = robot.forward()
			t.z = t.z + 1
			t.savePos()
			--print('t.z->', t.z)
		end
	elseif delta<0 then
		t.f_n()
		print('facing north')
		for i=1,math.abs(delta) do
			robot.forward()
			t.z = t.z - 1
			t.savePos()
			--print('t.z->', t.z)
		end
	end
end

function t.gt(ix,iy,iz)
	t.to_x(ix)
	t.to_y(iy)
	t.to_z(iz)
end

function array_sub(a1,a2)
	local result = []
	for i=1,#a2 do
		result[i] = calc_deltas(a1[i],a2[i])
	end
	return result
end



function main()
	if #args~=3 then
		print("usage: test.lua <x> <y> <z>")
	else
		t.getPos()
		t.savePos()
		print('init xyzf:',t.x,t.y,t.z,t.f)
		for a=1,#args do
			--print('arg:',a,args[a])
			args[a] = tonumber(args[a])
		end
		local my_x = args[1]
		local my_y = args[2]
		local my_z = args[3]
		print('heading to:',x,y,z)
		t.gt(my_x, my_y, my_z)
		print('reached xyzf:',t.x,t.y,t.z,t.f)
	end
end

main()

