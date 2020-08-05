local yellow	= {1, 1, 0, 1}

local function RGB(r,g,b,a) return { r/255, g/255, b/255, a and a/255 or 1} end

white = RGB(256, 256, 256)
green = RGB(17, 90, 34)
blue = RGB(62, 107, 99)
local font1	= loadFont(getXPlanePath() .. "Resources/fonts/ProFontWindows.ttf")

-- Create two batteries
local battery1 = createGlobalPropertyi("fokker/electrical/battery1", 0)
local battery1Charging = createGlobalPropertyi("fokker/electrical/battery1_charging", 0)
local battery2 = createGlobalPropertyi("fokker/electrical/battery2", 0)
local battery2Charging = createGlobalPropertyi("fokker/electrical/battery2_charging", 0)

-- Control
local battery1ChargingControl = createGlobalPropertyi("fokker/electrical/batt1ChargCtrl", 0) -- 0 is off, therefore the batteries WONT be charged EVEN if the SUFFICENT AC current is PROVIDED (USED FOR THE OVERHEAD CONTROL SWITCH)
local battery2ChargingControl = createGlobalPropertyi("fokker/electrical/batt2ChargCtrl", 0) -- 0 is off, therefore the batteries WONT be charged EVEN if the SUFFICENT AC current is PROVIDED (USED FOR THE OVERHEAD CONTROL SWITCH)


-- Busses
local dcBus1 = createGlobalPropertyi("fokker/electrical/dcBus1", 0) -- Create dc bus 1
local acBus1 = createGlobalPropertyi("fokker/electrical/acBus1", 0) -- Create ac bus 1 | CONNECTED TO: Gen 1, APU gen

-- TRU
tru1 = createGlobalPropertyi("fokker/electrical/tru1", 1) -- Create the TRU


local bus1OnBat = false

local truFail = false -- IF THIS IS TRUE THAT MEANS THE TRU HAS FAILED (IF FAILED LOGIC WILL TURN IF OFF AUTOMATICALLY)
local truOverheat = true -- TRU Overheat
local truRevCrnt = false -- TRU Reverse Current

function update()
    -- Automatically supply DC Bus 1 power
    if get(acBus1) == 1 and get(tru1) == 1 then    -- If AC bus is powered and the TRU is on (controlled by push button on overhead)
        set(dcBus1, 1) -- Supply power to the DC BUS
        if(get(battery1ChargingControl) == 1) then  -- If the overhead button ALLOWS batt charging for BATT 1
            set(battery1Charging, 1) -- Charge battery 1
        end
        if(get(battery2ChargingControl) == 1) then  -- If the overhead button ALLOWS batt charging for BATT 2
            set(battery2Charging, 1) -- Charge battery 2
        end
        bus1OnBat = false -- Set on bat to false, since bus 1 is getting power from the ac bus (converted via the TRU)
    elseif get(acBus1) == 0 then -- If the ac bus isn't powered
        if get(battery1) == 1 then -- But the battery bus IS powered
            set(dcBus1, 1) -- Supplying power to the DC bus
            set(battery1Charging, 0) -- Not charging battery 1
            set(battery2Charging, 0) -- Not charging battery 2
            bus1OnBat = false -- Set on bat to true, since bus 1 is getting power from battery 1
        elseif get(battery1) == 0 then -- But the battery bus ISN'T powered
            set(dcBus, 0) -- Not supplying power to the DC bus
            set(battery1Charging, 0) -- Not charging battery 1
            set(battery2Charging, 0) -- Not charging battery 2
            bus1OnBat = false -- DC Bus 1 is NOT on battery power
        end
    end
end
