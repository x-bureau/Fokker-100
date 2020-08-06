-- CREATED BY: JOE
-- CREATED ON: 8/5/2020


-- Generators
---- Engines
local gen1 = createGlobalPropertyi("fokker/electrical/generator_1", 0) -- Supplies AC BUS 1 AND the ESS BUS
local gen2 = createGlobalPropertyi("fokker/electrical/generator_2", 0) -- Supplies AC BUS 2
----  APU
local apu_on = createGlobalPropertyi("fokker/electrical/gpu_on", 0)
local apu_gen = createGlobalPropertyi("fokker/electrical/apu_gen", 0)
---- External Power
local gpu_is_aval = createGlobalPropertyi("fokker/electrical/gpu_is_aval", 0)
local gpu_pwr = createGlobalPropertyi("fokker/electrical/gpu_pwr", 0)
-- Busses
local acBus1 = createGlobalPropertyi("fokker/electrical/acBus1", 0)
local acBus2 = createGlobalPropertyi("fokker/electrical/acBus2", 0)
local acEssBus = createGlobalPropertyi("fokker/electrical/acEssBus", 0)
local acEmerBus = createGlobalPropertyi("fokker/electrical/acEmerBus", 0)
local acGndSerBus = createGlobalPropertyi("fokker/electrical/acGndSerBus", 0)
-- TRU
local tru1 = createGlobalPropertyi("fokker/electrical/tru1", 0) -- Powered by AC BUS 1
local tru2 = createGlobalPropertyi("fokker/electrical/tru2", 0) -- Powered by AC BUS 2
local truEss = createGlobalPropertyi("fokker/electrical/truEss", 0) -- Powered  by ESS BUS
local truEmer = createGlobalPropertyi("fokker/electrical/truEmer", 0)
local truGndSer = createGlobalPropertyi("fokker/electrical/truGndSer", 0) -- Powered by AC GND SER BUS
-- Busses
local dcBus1 = createGlobalPropertyi("fokker/electrical/dcBus1", 0)
local dcBus2 = createGlobalPropertyi("fokker/electrical/dcBus2", 0)
local dcEssBus = createGlobalPropertyi("fokker/electrical/dcEssBus", 0)
local dcEmerBus = createGlobalPropertyi("fokker/electrical/dcEmerBus", 0)
local dcGndSerBus = createGlobalPropertyi("fokker/electrical/dcGndSerBus", 0)
local dualDcBus = createGlobalPropertyi("fokker/electrical/dualDCBus", 0)
-- Cross Ties
local dcb1_dbc2_x_tie = createGlobalPropertyi("fokker/electrical/dcb1_dbc2_x_tie", 0)
-- Batteries
local batt1 = createGlobalPropertyi("fokker/electrical/battery_1", 0)
local batt2 = createGlobalPropertyi("fokker/electrical/battery_2", 0)
-- Push Buttons
local battery_switch = createGlobalPropertyi("fokker/buttons/battery_switch", 0)
local gpu_pb = createGlobalPropertyi("fokker/buttons/gpu_pb", 0)
local ess_emer_pwr_only = createGlobalPropertyi("fokker/buttons/ess_emer_pwr_only", 0)
local gen1_pb = createGlobalPropertyi("fokker/buttons/gen1_pb", 0)
local gen2_pb = createGlobalPropertyi("fokker/buttons/gen2_pb", 0)
local apu_gen_pb = createGlobalPropertyi("fokker/buttons/apu_gen_pb", 0)
local dcX_Tie_pb = createGlobalPropertyi("fokker/buttons/dcX_Tie_pb", 1)
local acX_Tie_pb1 = createGlobalPropertyi("fokker/buttons/acX_Tie_pb1", 1)
local acX_Tie_pb2 = createGlobalPropertyi("fokker/buttons/acX_Tie_pb1", 1)
local tru1_pb = createGlobalPropertyi("fokker/buttons/tru1_pb", 1)
local tru2_pb = createGlobalPropertyi("fokker/buttons/tru2_pb", 1)
local onGround = globalProperty("sim/flightmodel/failures/onground_any")
function update()
    if get(dcEssBus) == 0 then 
        -- PRESENT ALERT WHEN ESS DC BUS 
    end
    -- GENERATORS
    if get(gen1) == 1 and get(gen2) == 1 then -- IF GEN 1 AND GEN 2 ARE ON
        set(acBus1, 1)
        set(acEssBus, 1)
        set(acBus2, 1)
    elseif get(apu_gen) == 1 and get(acGndSerBus) == 1 then
            -- LET APU POWER THE ESSENTIAL AC BUS
            set(acEssBus, 1)
            -- LET GPU POWER AC BUS 1 AND AC BUS 2
            set(acBus1, 1)
            set(acBus2, 1)

    elseif get(apu_gen) == 1 then -- ACTS AS STANDBY IF GEN 1 AND GEN 2 ARE ON | REMEMBER: APU_GEN IS ONLY ON IF THE APU IS ON AND THE GENERATOR PUSH BUTTON (PB) IS ON
        if get(onGround) == 1 then
            if get(gen1) == 0 and get(gen2) == 0 then -- ON GROUND, WHEN BOTH ENGINES ARE OFF, AND APU  IS ON, POWER ALL OF THE AC SYSTEM
               set(acBus1, 1)
               set(acBus2, 1)
            end 
        else
            if get(gen1) == 0 and get(gen2) == 0 then -- IF BOTH ENGINES ARE FAILED
                set(acBus1, 1)
                set(acBus2, 1)
            elseif get(gen1) == 1 and get(gen2) == 0 then -- IF GEN 1 FAILS
                set(acBus1, 1)
            elseif get(gen1) == 0 and get(gen2) == 1 then -- IF GEN 2 FAILS
                set(acBus2, 1)
            end
        end
    elseif get(acGndSerBus) == 1 then
        set(acBus1, 1)
        set(acEssBus, 1)
        set(acBus2, 1)
    end
    -- If the battery switch is on
    if get(battery_switch) == 1 then
        set(batt1, 1)
        set(batt2, 2)
    end
    -- If batteries are on, power the emergency bus
    if get(batt1) == 1 or get(batt2) == 1 then
        set(dcEmerBus, 1)
    end
    -- Once the emergency bus is powered, power the DC Essential Bus, the DC BUS 1, and IF THE CROSS TIE IS ON (WHICH IT IS AUTOMATICALLY), TURN THE DC BUS 2 ON
    -- Basically simulating the DC Essential Bus and DC X-TIE
    if get(dcEmerBus) == 1 then 
        set(dcEssBus, 1)
        set(dcBus1, 1)
        if get(dcX_Tie_pb) == 1 then
            set(dcBus2, 1)
        else
            set(dcBus2, 0)
        end
    end
    if get(dcBus1) == 1 or get(dcBus2) == 1 then set(dualDcBus, 1) end -- DUAL DC BUS IS UN-INTERRUPTED | PROVIDES ELECTRICAL POWER FOR lift dumpers, anti-skid, speed brakes IF DC BUS 1 OR DC BUS 2 FAILS DURING LANDING
    -- SIMULATE THE GCU
    if get(gen1_pb) == 1 then set(gen1, 1) else set(gen1, 0) end
    if get(gen2_pb) == 1 then set(gen2, 1) else set(gen2, 0) end
    if get(apu_gen_pb) == 1 and get(apu_on) == 1 then set(apu_gen, 1) else set(apu_gen, 0) end
    -- SIMULATE THE GPCU
    if get(gpu_is_aval) == 1 then
        if get(gpu_pb) == 1 then
            set(acGndSerBus, 1) -- If the GPU is on, and the push button is on, then supply power to the AC Ground Service Bus
            ------ TODO: MEMO MESSAGE, EXT POWER CONNECTED (PRESENTED AT THE MFDU PRIMARY PAGE)
        else
            ------ TODO: MEMO MESSAGE, EXT POWER CONNECTED (PRESENTED AT THE MFDU PRIMARY PAGE)
        end
    end
    -- Automatically power the AC Emergency Bus
    if get(acEssBus) == 1 then 
        set(acEmerBus, 1) -- IF THE AC ESS BUS IS ON, POWER THE EMER BUS
    elseif get(batt1) == 1 and get(batt2) == 1 then
        set(acEmerBus, 1) -- HAVE THE BATTERIES CONTINUE TO POWER THE AC EMER BUS
        --------------------- TODO: In this case, an AC SUPPLY alert will be presented at the Standby Annunciator Panel (SAP); See section Flight Warnign System. TOTAL LOSS OF EMERGENCY POWER MAY OCCUR AFTER 30 MINUTES, BUT IS ACTUALLY DEPENDANT ON THE BATTERY CONFIGURATION AND SYSTEM LOADS
    else set(acEmerBus, 0) end
    -- If the AC busses are powered, turn the TRU on, else turn them off
    if get(acBus1) == 1 and get(tru1_pb) == 1 then set(tru1, 1) else set(tru1, 0) end
    if get(acBus2) == 1 and get(tru2_pb) == 1 then set(tru2, 1)  else set(tru2, 0) end
    if get(acEssBus) == 1 then set(truEss, 1) else set(truEss, 0) end
    if get(acEmerBus) == 1 then set(truEmer, 1) else set(truEmer, 0) end
    if get(acGndSerBus) == 1 then set(truGndSer, 1) else set(truGndSer, 0) end
    -- AND IF the TRU's are powered, the coresponding DC busses will then be powered
    if get(tru1) == 1 then set(dcBus1, 1) else set(dcBus1, 0) end
    if get(tru2) == 1 then set(dcBus2, 1) else set(dcBus2, 0) end
    if get(truEss) == 1 then set(dcEssBus, 1) else set(dcEssBus, 0) end
    if get(truEmer) == 1 then set(dcEmerBus, 1) else set(dcEmerBus, 0) end
    if get(truGndSer) == 1 then set(dcGndSerBus, 1) else set(dcGndSerBus, 0) end
end