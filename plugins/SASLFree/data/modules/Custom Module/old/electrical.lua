---------- OUTDATED ----------


local yellow	= {1, 1, 0, 1}

local function RGB(r,g,b,a) return { r/255, g/255, b/255, a and a/255 or 1} end

white = RGB(256, 256, 256)
green = RGB(17, 90, 34)
blue = RGB(62, 107, 99)

ecam_red = RGB(242, 24, 67)
ecam_amber = RGB(255, 122, 62)
ecam_blue = RGB(130,234,221)
ecam_green = RGB(8,161,79)
ecam_black = RGB(56,56,56)


local font1	= loadFont(getXPlanePath() .. "Resources/fonts/ProFontWindows.ttf")

local onGround = globalProperty("sim/flightmodel/failures/onground_any")

-- Create two batteries
local battery1 = createGlobalPropertyi("fokker/electrical/battery1", 0)
local battery1Charging = createGlobalPropertyi("fokker/electrical/battery1_charging", 0)
local battery2 = createGlobalPropertyi("fokker/electrical/battery2", 0)
local battery2Charging = createGlobalPropertyi("fokker/electrical/battery2_charging", 0)

-- Ground Handling
local dcGndHdlgBus = createGlobalPropertyi("fokker/electrical/dcGroundHandlingBus", 0)
local dcGndHdlgBusVoltage = createGlobalPropertyi("fokker/electrical/dcGroundHandlingBusVoltage", 0)

-- APU
local apu = createGlobalPropertyi("fokker/electrical/apu", 0) -- APU (ON/OFF)
local apu_gen = createGlobalPropertyi("fokker/electrical/apu_gen", 0) -- APU GENERATOR (ON/OFF)
--local apu_gen_pb = createGlobalPropertyi("fokker/electrical/apu_gen_pb", 0) -- APU GEN PUSH BUTTON

-- GPU
local gpu = createGlobalPropertyi("fokker/electrical/gpu", 0)
local gpu_gen = createGlobalPropertyi("fokker/electrical/gpu_gen", 0)
local gpu_connected = createGlobalPropertyi("fokker/external/gpu_connected", 0)

-- Engines
local gen1 = createGlobalPropertyi("fokker/electrical/eng1_gen", 0) -- Engine 1 generator
local gen2 = createGlobalPropertyi("fokker/electrical/gen2_gen", 0) -- Engine 2 generator

-- Control
local battery1ChargingControl = createGlobalPropertyi("fokker/electrical/batt1ChargCtrl", 0) -- 0 is off, therefore the batteries WONT be charged EVEN if the SUFFICENT AC current is PROVIDED (USED FOR THE OVERHEAD CONTROL SWITCH)
local battery2ChargingControl = createGlobalPropertyi("fokker/electrical/batt2ChargCtrl", 0) -- 0 is off, therefore the batteries WONT be charged EVEN if the SUFFICENT AC current is PROVIDED (USED FOR THE OVERHEAD CONTROL SWITCH)

-- Busses
local dcBus1 = createGlobalPropertyi("fokker/electrical/dcBus1", 0) -- Create dc bus 1
local acBus1 = createGlobalPropertyi("fokker/electrical/acBus1", 0) -- Create ac bus 1 | CONNECTED TO: Gen 1, APU gen
local acBus2 = createGlobalPropertyi("fokker/electrical/asBus2", 0) -- Create ac bus 2
local essAcBus = createGlobalPropertyi("fokker/electrical/essAcBus", 0) 

-- TRU
tru1 = createGlobalPropertyi("fokker/electrical/tru1", 1) -- Create the TRU
esstru = createGlobalPropertyi("fokker/electrical/esstru", 1) -- Create the essential bus TRU

-- Voltages
local batt1Voltage = createGlobalPropertyi("fokker/electrical/battery1_voltage", 0)
local batt2Voltage = createGlobalPropertyi("fokker/electrical/battery2_voltage", 0)
local dcBus1Voltage = createGlobalPropertyi("fokker/electrical/dcBus1Voltage", 0)
local acBus1Voltage = createGlobalPropertyi("fokker/electrical/acBus1Voltage", 0)
local acBus2Voltage = createGlobalPropertyi("fokker/electrical/acBus2Voltage", 0)

local essAcBusVoltage = createGlobalPropertyi("fokker/electrical/essAcBusVoltage", 0)

local bus1OnBat = false
local bus1OnTRU = false

local truFail = false -- IF THIS IS TRUE THAT MEANS THE TRU HAS FAILED (IF FAILED LOGIC WILL TURN IF OFF AUTOMATICALLY)
local truOverheat = true -- TRU Overheat
local truRevCrnt = false -- TRU Reverse Current

local acPoweredByAPU = false
local acPoweredByExternalPower = false
local acPoweredByBothEngineGens = false
local acPoweredByGen1 = false
local acPoweredByGen2 = false

local ecam = {}

function updateMFDU(message, type, priority)
    table.insert(ecam, {message, type, priority})
end


function update()

    -- Set voltages
    if get(battery1) == 1 then  -- If the battery 1 is on
        set(batt1Voltage, 28)
    end

    -- Turn on/off the AC BUSSES depending on which systems are alive
    -- AC BUS 1 is powered from: 
    -- ENGINE GEN 1 / ENGINE GEN 2
    -- APU GEN
    -- EXTERNAL POWER
    -- IF ANY OF THESE FAIL, THE AC BUS WILL AUTOMATICALLY SWITCH TO THE NEXT ACTIVE POWER SOURCE
    --------------
    -- AC POWER IS DESTRIBUTED TO:
    -- AC BUSSES 1 AND 2
    -- ESS AC BUS
    -- EMER AC BUS
    -- GALLEY BUS 1 AND 2
    -- AC GROUND SERVICES BUS


    -- APU
    -- On ground, with only APU pwr aval, entire elec sys is energized [DONE]
    -- IF one engine gen is inoperative, the APU will supply the engine generators busses [DONE]
    -- The essential bus will be supplied by the active engine generator [DONE]
    -- The essential bus is normally powered by gen 1, but if it becomes inoperative it's supplied by gen 2 [DONE]
    -- IF BOTH ENGINES INOPERATIVE, the APU GEN supplies the AC busses [DONE]

    function powerEssAcBus()
        set(essAcBus, 1) -- SET THE ESSENTIAL AC BUS TO ON
        set(essAcBusVoltage, 115)
        if get(esstru) == 1 then -- IF THE ESSENTIAL AC BUS TRU IS ON, CONVERT ESS AC BUS AC CURRENT TO DC
            
        end
    end
    
    function powerAc()
        set(acBus1, 1) -- Set the AC BUS 1 TO ON
        set(acBus1Voltage, 115) -- Set the AC BUS 1 Voltage to 115
        set(acBus2, 1) --  Set the AC BUS 2 TO ON
        set(acBus2Voltage, 115) -- Set the AC BUS 2 Voltage to 115
    end

    if get(gen1) == 1 and get(gen2) == 1 then -- IF ENGINE GEN 1 AND 2 IS OPERATIVE
        acPoweredByBothEngineGens = true
        acPoweredByAPU = false
        acPoweredByExternalPower = false
        powerAc()
        powerEssAcBus()
    elseif get(gen1) == 0 and get(gen2) == 1 then -- IF GEN 1 ISN'T ACTIVE, POWER THE ESSENTIAL BUS THRU GEN 2
        acPoweredByGen2 = true
        powerEssAcBus()
    elseif get(gen2) == 0 and get(gen1) == 1 then -- IF GEN 1 IS ACTIVE BUT GEN 2 ISNT
        acPoweredByGen2 = true
    elseif get(gen1)  == 0 and get(gen2) == 0 then
        acPoweredByBothEngineGens = 0
    end
    
    -- SIMULATE GPCU (Ground Power Control Unit)
    if get(gpu_gen) == 1 then -- If the External power generator is on
        if get(gpu) == 1 and get(gpu_connected) == 1 then -- If the GPU is ON and CONNECTED
            acPoweredByExternalPower = true
            acPoweredByAPU = false
            powerAc()
        else
            acPoweredByExternalPower = false
            -- MESSAGE ECAM THAT GPU IS OFF BUT GEN IS ON?
        end
    end

    if get(apu_gen) == 1 then  -- If the gpu generator is off and the apu generator is on (controlled by overhead push button) (meaning allowing generated power from the APU)
        if get(apu) == 1 then -- If the APU is on
            if get(onGround) == 1 and not acPoweredByBothEngineGens and not acPoweredByExternalPower then -- If the aircraft is on the ground, power the entire electrical system IF engine generators are off AND if the externak power generator is off
                acPoweredByAPU = true
                powerAc()
            elseif get(onGround) == 0 and get(gen1) == 0 and get(gen2) == 0 then --  IF both engines inoperative, power both ac busses
                acPoweredByAPU = true
                powerAc()
            end
        end
    end


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
        bus1OnTRU = true -- Set to true because bus 1 is powered via the AC current coming from the TRU
    elseif get(acBus1) == 0 then -- If the ac bus isn't powered
        if get(battery1) == 1 then -- But the battery bus IS powered
            set(dcBus1, 1) -- Supplying power to the DC bus
            set(battery1Charging, 0) -- Not charging battery 1
            set(battery2Charging, 0) -- Not charging battery 2
            bus1OnBat = true -- Set on bat to true, since bus 1 is getting power from battery 1
            bus1OnTRU = false
        elseif get(battery1) == 0 then -- But the battery bus ISN'T powered
            set(dcBus1, 0) -- Not supplying power to the DC bus
            set(battery1Charging, 0) -- Not charging battery 1
            set(battery2Charging, 0) -- Not charging battery 2
            bus1OnBat = false -- DC Bus 1 is NOT on battery power
            bus1OnTRU = false
        end
    end

    -- Unless there is a failure, the DC BUS 1 VOLTAGE IS 28 V (we can calculate realistic voltage once we have actual battery data)
    if bus1OnBat then -- If the DC BUS 1 IS ON BATTERY POWER, then SET the BUS to 28 V
       set(dcBus1Voltage, 28)
    elseif not bus1OnBat and bus1OnTRU then -- If the DC BUS 1 electrical power is supplied from the TRU, set the bus to 28 V
        set(dcBus1Voltage, 28)
    else
        set(dcBus1Voltage, 0) -- Else, if no power is supplied, the BUS voltage is nothing
    end
end

local MAX_ECAM_LENGTH = 6
local CURRENT_ECAM_LENGTH = 0


function draw()
    --drawText(font1, 390/2, 296/2, "test", 30, false, false, TEXT_ALIGN_CENTER, ecam_red) -- Display Current Load in Amps
    --for i = 1, table.getn(ecam) do
    --    local message = ecam[i][1]
    --    local type = ecam[i][2]
    --    local priority = ecam[i][3]
    --    drawText(font1, 390/2, 296/2, message, 30, false, false, TEXT_ALIGN_CENTER, ecam_red) -- Display Current Load in Amps
    --end

end


