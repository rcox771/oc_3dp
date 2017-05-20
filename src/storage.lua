local computer = require "computer"
local fs = require "filesystem"
local robot = require "robot"
local serial = require "serialization"
local shell = require "shell"

local nav = require "nav"
local component = require "component"
inv = component.inventory_controller
t.getPos()
store = {}
store.white = {x=100, y=64, z=141}
store.black = {x=100, y=64, z=147}
store.gray = {x=100, y=64, z=140}
store.fuel = {x=100, y=64, z=139}

function t.getColor(color)
	local c_pos = store[color]
	t.gt(c_pos.x,c_pos.y,c_pos.z)
	t.f_w()
	robot.suck()
end

function load_table(fn)
	local f=io.open(fn,"r")
	local txt=f:read("*all")
	f:close()
	tab = serial.unserialize(txt)
	return tab
end

function t.needsRefuel()
	return (computer.energy()/computer.maxEnergy())<.3
end

function t.refuel()
	startx=t.x
	starty=t.y
	startz=t.z
	t.g_t(store.fuel.x, store.fuel.y,store.fuel.z)
	while ((computer.energy()/computer.maxEnergy())<.95) do
		os.sleep(5)
	end
	t.g_t(startx,starty,startz)
end
--layers = load_table("model")
--print(layers[-31])
