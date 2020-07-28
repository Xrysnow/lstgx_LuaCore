---@class lstg.mbg.Barrage
local M = class('lstg.mbg.Barrage')
local Center = require('game.mbg.Center')
local Player = require('game.mbg.Player')
local Time = require('game.mbg.Time')
local Main = require('game.mbg.Main')
local Math = require('game.mbg._math')
local MathHelper = Math
local float = { Parse = function(s)
    return tonumber(s)
end }

function M:ctor()
    self.conditions = {}-- float[3];
    for i = 1, 3 do
        self.conditions[i - 1] = 0
    end
    self.results = {}-- float[21];
    for i = 1, 21 do
        self.results[i - 1] = 0
    end
    --
    self.IsLase = false
    self.IsRay = false
    self.id = -1
    self.parentid = -2
    self.shatime = 0
    ---@type lstg.mbg.Shadows[]
    self.savesha = {} -- Shadows[]
    self.NeedDelete = false
    self.Dis = false
    self.Covered = {}-- List<int>
    self.life = 0
    self.time = 0
    self.type = 0
    self.x = 0
    self.y = 0
    self.dscale = 0.9
    self.wscale = 0
    self.rwscale = 0
    self.hscale = 0
    self.longs = 0
    self.rlongs = 0
    self.randf = 0
    self.R = 0
    self.G = 0
    self.B = 0
    self.alpha = 0
    self.head = 0
    self.speed = 0
    self.speedx = 0
    self.speedy = 0
    self.bspeedx = 0
    self.bspeedy = 0
    self.speedd = 0
    self.vf = 0
    self.aspeed = 0
    self.aspeedx = 0
    self.aspeedy = 0
    self.aspeedd = 0
    self.Withspeedd = false
    self.fdirection = 0
    self.sonaspeedd = 0
    self.fx = 0
    self.fy = 0
    self.fdirections = { X = 0, Y = 0 }
    self.sonaspeedds = { X = 0, Y = 0 }
    self.randfdirection = 0
    self.randsonaspeedd = 0
    self.g = 0
    self.tiaos = 0
    self.range = 0
    self.randrange = 0
    self.bindspeedd = 0
    self.Bindwithspeedd = false
    self.xscale = 0
    self.yscale = 0
    self.Mist = false
    self.Dispel = false
    self.Blend = false
    self.Afterimage = false
    self.Outdispel = false
    self.Invincible = false
    self.Cover = false
    self.Rebound = false
    self.Force = false
    self.Alreadylong = false
    self.reboundtime = 0
    self.fadeout = 0
    --
    self.batch = nil-- Batch
    self.lase = nil-- Lase
    self.cover = nil-- Cover
    self.Events = {}-- List<Event>
    self.Eventsexe = {}-- List<BExecution>
    self.LEventsexe = {}--  List<BLExecution>
    --
    local Shadows = require('game.mbg.Shadows')
    for i = 1, 50 do
        local s = Shadows()
        s.x = self.x
        s.y = self.y
        s.alpha = 0
        table.insert(self.savesha, s)
    end
end

function M:update()
    local BExecution = require('game.mbg.BExecution')

    if (not self.IsLase and self.type ~= -2) then
        local bx = self.x
        local by = self.y
        local bpx = Player.position.X
        local bpy = Player.position.Y
        local num = 0
        if (self.Mist) then
            num = 15
        end
        self.time = self.time + 1
        if (self.type <= -1) then
            self.type = -1
        end
        if (self.type >= #Main.bgset) then
            self.type = #Main.bgset - 1
        end
        if (self.time > 15 or not self.Mist) then
            if ((self.Mist and self.time == 16) or (not self.Mist and self.time == 1)) then
                -- sound
                --if (self.type > -1 and self.type < #Main.bgset and Main.bgset[self.type].sd ~= nil) then
                --    Main.bgset[self.type].sd.Play()
                --end
                if (self.fdirection == -99998) then
                    self.fdirection = MathHelper.ToDegrees(Main.Twopointangle(self.fx, self.fy, self.x, self.y))
                elseif (self.fdirection == -99999) then
                    self.fdirection = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                elseif (self.fdirection == -100000) then
                    self.fdirection = MathHelper.ToDegrees(Main.Twopointangle(self.fdirections.X, self.fdirections.Y, self.x, self.y))
                end
                if (self.Bindwithspeedd) then
                    self.speedd = self.fdirection + self.randfdirection + (self.g - (self.tiaos - 1) / 2) * (self.range + self.randrange) / self.tiaos + self.bindspeedd
                else
                    self.speedd = self.fdirection + self.randfdirection + (self.g - (self.tiaos - 1) / 2) * (self.range + self.randrange) / self.tiaos
                end
                if (self.sonaspeedd == -99998) then
                    self.sonaspeedd = MathHelper.ToDegrees(Main.Twopointangle(self.fx, self.fy, self.x, self.y))
                elseif (self.sonaspeedd == -99999) then
                    self.sonaspeedd = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                elseif (self.sonaspeedd == -100000) then
                    self.sonaspeedd = MathHelper.ToDegrees(Main.Twopointangle(self.sonaspeedds.X, self.sonaspeedds.Y, self.x, self.y))
                end
                self.aspeedd = self.sonaspeedd + self.randsonaspeedd
                self.speedx = self.xscale * self.speed * Math.Cos(MathHelper.ToRadians(self.speedd))
                self.speedy = self.yscale * self.speed * Math.Sin(MathHelper.ToRadians(self.speedd))
                self.aspeedx = self.xscale * self.aspeed * Math.Cos(MathHelper.ToRadians(self.aspeedd))
                self.aspeedy = self.yscale * self.aspeed * Math.Sin(MathHelper.ToRadians(self.aspeedd))
                if (self.Withspeedd) then
                    self.head = self.speedd + 90
                end
            end
            if (not self.Dis) then
                self.speedx = self.speedx + self.aspeedx * Time.stop
                self.speedy = self.speedy + self.aspeedy * Time.stop
                self.x = self.x + self.speedx * Time.stop
                self.y = self.y + self.speedy * Time.stop
            end
            if (self.speed ~= 0) then
                if (self.speedy ~= 0) then
                    self.vf = 1.57079637 - Math.Atan((self.speedx / self.xscale / (self.speedy / self.yscale)))
                    if (self.speedy < 0) then
                        self.vf = self.vf + 3.14159274
                    end
                else
                    if (self.speedx >= 0) then
                        self.vf = 0
                    end
                    if (self.speedx < 0) then
                        self.vf = 3.14159274
                    end
                end
                if (self.speed > 0) then
                    self.speedd = MathHelper.ToDegrees(self.vf)
                    if (self.Withspeedd) then
                        self.head = self.speedd
                    end
                elseif (self.Withspeedd) then
                    self.head = MathHelper.ToDegrees(self.vf)
                end
            end
            if (self.Afterimage and self.time <= num + self.life) then
                self.savesha[self.shatime].alpha = 0.4 * (self.alpha / 100)
                self.savesha[self.shatime].x = self.x
                self.savesha[self.shatime].y = self.y
                self.savesha[self.shatime].d = self.head
                self.shatime = self.shatime + 1
                if (self.shatime >= 49) then
                    self.shatime = 0
                end
            else
                self.shatime = 0
            end
            self.conditions[0] = (self.time - num)
            self.conditions[1] = self.x
            self.conditions[2] = self.y
            self.results[0] = self.life
            self.results[1] = self.type
            self.results[2] = self.wscale
            self.results[3] = self.hscale
            self.results[4] = self.R
            self.results[5] = self.G
            self.results[6] = self.B
            self.results[7] = self.alpha
            self.results[8] = self.head
            self.results[9] = self.speed
            self.results[10] = self.speedd
            self.results[11] = self.aspeed
            self.results[12] = self.aspeedd
            self.results[13] = self.xscale
            self.results[14] = self.yscale
            self.results[15] = 0
            self.results[16] = 0
            self.results[17] = 0
            self.results[18] = 0
            self.results[19] = 0
            self.results[20] = 0
            for _, event in ipairs(self.Events) do
                if (event.t <= 0) then
                    event.t = 1
                end
                if ((self.time - num) % event.t == 0) then
                    event.loop = event.loop + 1
                end
                for _, eventRead in ipairs(event.results) do
                    repeat
                        if (eventRead.special2 == 1) then
                            self.conditions[0] = Time.now
                        end
                        if (eventRead.opreator == ">") then
                            if (eventRead.opreator2 == ">") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] > float.Parse(eventRead.condition) + (event.loop * event.addtime) and self.conditions[eventRead.contype2] > float.Parse(eventRead.condition2) + (event.loop * event.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 10) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 12) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local bexecution = BExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        bexecution.change = eventRead.change
                                        bexecution.changetype = eventRead.changetype
                                        bexecution.changevalue = eventRead.changevalue
                                        bexecution.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        bexecution.region = tostring(self.results[eventRead.changename])
                                        bexecution.time = eventRead.times
                                        bexecution.ctime = bexecution.time
                                        table.insert(self.Eventsexe, bexecution)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] > float.Parse(eventRead.condition) + (event.loop * event.addtime) or self.conditions[eventRead.contype2] > float.Parse(eventRead.condition2) + (event.loop * event.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 10) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 12) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local bexecution2 = BExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    bexecution2.change = eventRead.change
                                    bexecution2.changetype = eventRead.changetype
                                    bexecution2.changevalue = eventRead.changevalue
                                    bexecution2.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    bexecution2.region = tostring(self.results[eventRead.changename])
                                    bexecution2.time = eventRead.times
                                    bexecution2.ctime = bexecution2.time
                                    table.insert(self.Eventsexe, bexecution2)
                                end
                            elseif (eventRead.opreator2 == "=") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] > float.Parse(eventRead.condition) + (event.loop * event.addtime) and self.conditions[eventRead.contype2] == float.Parse(eventRead.condition2) + (event.loop * event.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 10) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 12) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local bexecution3 = BExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        bexecution3.change = eventRead.change
                                        bexecution3.changetype = eventRead.changetype
                                        bexecution3.changevalue = eventRead.changevalue
                                        bexecution3.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        bexecution3.region = tostring(self.results[eventRead.changename])
                                        bexecution3.time = eventRead.times
                                        bexecution3.ctime = bexecution3.time
                                        table.insert(self.Eventsexe, bexecution3)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] > float.Parse(eventRead.condition) + (event.loop * event.addtime) or self.conditions[eventRead.contype2] == float.Parse(eventRead.condition2) + (event.loop * event.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 10) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 12) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local bexecution4 = BExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    bexecution4.change = eventRead.change
                                    bexecution4.changetype = eventRead.changetype
                                    bexecution4.changevalue = eventRead.changevalue
                                    bexecution4.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    bexecution4.region = tostring(self.results[eventRead.changename])
                                    bexecution4.time = eventRead.times
                                    bexecution4.ctime = bexecution4.time
                                    table.insert(self.Eventsexe, bexecution4)
                                end
                            elseif (eventRead.opreator2 == "<") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] > float.Parse(eventRead.condition) + (event.loop * event.addtime) and self.conditions[eventRead.contype2] < float.Parse(eventRead.condition2) + (event.loop * event.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 10) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 12) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local bexecution5 = BExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        bexecution5.change = eventRead.change
                                        bexecution5.changetype = eventRead.changetype
                                        bexecution5.changevalue = eventRead.changevalue
                                        bexecution5.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        bexecution5.region = tostring(self.results[eventRead.changename])
                                        bexecution5.time = eventRead.times
                                        bexecution5.ctime = bexecution5.time
                                        table.insert(self.Eventsexe, bexecution5)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] > float.Parse(eventRead.condition) + (event.loop * event.addtime) or self.conditions[eventRead.contype2] < float.Parse(eventRead.condition2) + (event.loop * event.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 10) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 12) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local bexecution6 = BExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    bexecution6.change = eventRead.change
                                    bexecution6.changetype = eventRead.changetype
                                    bexecution6.changevalue = eventRead.changevalue
                                    bexecution6.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    bexecution6.region = tostring(self.results[eventRead.changename])
                                    bexecution6.time = eventRead.times
                                    bexecution6.ctime = bexecution6.time
                                    table.insert(self.Eventsexe, bexecution6)
                                end
                            elseif (self.conditions[eventRead.contype] > float.Parse(eventRead.condition) + (event.loop * event.addtime)) then
                                if (eventRead.special == 4) then
                                    if (eventRead.changevalue == 10) then
                                        eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                    end
                                    if (eventRead.changevalue == 12) then
                                        eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                    end
                                end
                                local bexecution7 = BExecution()
                                if (eventRead.noloop) then
                                    break
                                end
                                if (eventRead.time > 0) then
                                    eventRead.time = eventRead.time - 1
                                    if (eventRead.time == 0) then
                                        eventRead.noloop = true
                                    end
                                end
                                bexecution7.change = eventRead.change
                                bexecution7.changetype = eventRead.changetype
                                bexecution7.changevalue = eventRead.changevalue
                                bexecution7.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                bexecution7.region = tostring(self.results[eventRead.changename])
                                bexecution7.time = eventRead.times
                                bexecution7.ctime = bexecution7.time
                                table.insert(self.Eventsexe, bexecution7)
                            end
                        end
                        if (eventRead.opreator == "=") then
                            if (eventRead.opreator2 == ">") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] == float.Parse(eventRead.condition) + (event.loop * event.addtime) and self.conditions[eventRead.contype2] > float.Parse(eventRead.condition2) + (event.loop * event.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 10) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 12) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local bexecution8 = BExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        bexecution8.change = eventRead.change
                                        bexecution8.changetype = eventRead.changetype
                                        bexecution8.changevalue = eventRead.changevalue
                                        bexecution8.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        bexecution8.region = tostring(self.results[eventRead.changename])
                                        bexecution8.time = eventRead.times
                                        bexecution8.ctime = bexecution8.time
                                        table.insert(self.Eventsexe, bexecution8)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] == float.Parse(eventRead.condition) + (event.loop * event.addtime) or self.conditions[eventRead.contype2] > float.Parse(eventRead.condition2) + (event.loop * event.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 10) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 12) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local bexecution9 = BExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    bexecution9.change = eventRead.change
                                    bexecution9.changetype = eventRead.changetype
                                    bexecution9.changevalue = eventRead.changevalue
                                    bexecution9.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    bexecution9.region = tostring(self.results[eventRead.changename])
                                    bexecution9.time = eventRead.times
                                    bexecution9.ctime = bexecution9.time
                                    table.insert(self.Eventsexe, bexecution9)
                                end
                            elseif (eventRead.opreator2 == "=") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] == float.Parse(eventRead.condition) + (event.loop * event.addtime) and self.conditions[eventRead.contype2] == float.Parse(eventRead.condition2) + (event.loop * event.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 10) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 12) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local bexecution10 = BExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        bexecution10.change = eventRead.change
                                        bexecution10.changetype = eventRead.changetype
                                        bexecution10.changevalue = eventRead.changevalue
                                        bexecution10.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        bexecution10.region = tostring(self.results[eventRead.changename])
                                        bexecution10.time = eventRead.times
                                        bexecution10.ctime = bexecution10.time
                                        table.insert(self.Eventsexe, bexecution10)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] == float.Parse(eventRead.condition) + (event.loop * event.addtime) or self.conditions[eventRead.contype2] == float.Parse(eventRead.condition2) + (event.loop * event.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 10) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 12) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local bexecution11 = BExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    bexecution11.change = eventRead.change
                                    bexecution11.changetype = eventRead.changetype
                                    bexecution11.changevalue = eventRead.changevalue
                                    bexecution11.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    bexecution11.region = tostring(self.results[eventRead.changename])
                                    bexecution11.time = eventRead.times
                                    bexecution11.ctime = bexecution11.time
                                    table.insert(self.Eventsexe, bexecution11)
                                end
                            elseif (eventRead.opreator2 == "<") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] == float.Parse(eventRead.condition) + (event.loop * event.addtime) and self.conditions[eventRead.contype2] < float.Parse(eventRead.condition2) + (event.loop * event.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 10) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 12) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local bexecution12 = BExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        bexecution12.change = eventRead.change
                                        bexecution12.changetype = eventRead.changetype
                                        bexecution12.changevalue = eventRead.changevalue
                                        bexecution12.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        bexecution12.region = tostring(self.results[eventRead.changename])
                                        bexecution12.time = eventRead.times
                                        bexecution12.ctime = bexecution12.time
                                        table.insert(self.Eventsexe, bexecution12)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] == float.Parse(eventRead.condition) + (event.loop * event.addtime) or self.conditions[eventRead.contype2] < float.Parse(eventRead.condition2) + (event.loop * event.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 10) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 12) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local bexecution13 = BExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    bexecution13.change = eventRead.change
                                    bexecution13.changetype = eventRead.changetype
                                    bexecution13.changevalue = eventRead.changevalue
                                    bexecution13.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    bexecution13.region = tostring(self.results[eventRead.changename])
                                    bexecution13.time = eventRead.times
                                    bexecution13.ctime = bexecution13.time
                                    table.insert(self.Eventsexe, bexecution13)
                                end
                            elseif (self.conditions[eventRead.contype] == float.Parse(eventRead.condition) + (event.loop * event.addtime)) then
                                if (eventRead.special == 4) then
                                    if (eventRead.changevalue == 10) then
                                        eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                    end
                                    if (eventRead.changevalue == 12) then
                                        eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                    end
                                end
                                local bexecution14 = BExecution()
                                if (eventRead.noloop) then
                                    break
                                end
                                if (eventRead.time > 0) then
                                    eventRead.time = eventRead.time - 1
                                    if (eventRead.time == 0) then
                                        eventRead.noloop = true
                                    end
                                end
                                bexecution14.change = eventRead.change
                                bexecution14.changetype = eventRead.changetype
                                bexecution14.changevalue = eventRead.changevalue
                                bexecution14.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                bexecution14.region = tostring(self.results[eventRead.changename])
                                bexecution14.time = eventRead.times
                                bexecution14.ctime = bexecution14.time
                                table.insert(self.Eventsexe, bexecution14)
                            end
                        end
                        if (eventRead.opreator == "<") then
                            if (eventRead.opreator2 == ">") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] < float.Parse(eventRead.condition) + (event.loop * event.addtime) and self.conditions[eventRead.contype2] > float.Parse(eventRead.condition2) + (event.loop * event.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 10) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 12) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local bexecution15 = BExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        bexecution15.change = eventRead.change
                                        bexecution15.changetype = eventRead.changetype
                                        bexecution15.changevalue = eventRead.changevalue
                                        bexecution15.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        bexecution15.region = tostring(self.results[eventRead.changename])
                                        bexecution15.time = eventRead.times
                                        bexecution15.ctime = bexecution15.time
                                        table.insert(self.Eventsexe, bexecution15)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] < float.Parse(eventRead.condition) + (event.loop * event.addtime) or self.conditions[eventRead.contype2] > float.Parse(eventRead.condition2) + (event.loop * event.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 10) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 12) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local bexecution16 = BExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    bexecution16.change = eventRead.change
                                    bexecution16.changetype = eventRead.changetype
                                    bexecution16.changevalue = eventRead.changevalue
                                    bexecution16.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    bexecution16.region = tostring(self.results[eventRead.changename])
                                    bexecution16.time = eventRead.times
                                    bexecution16.ctime = bexecution16.time
                                    table.insert(self.Eventsexe, bexecution16)
                                end
                            elseif (eventRead.opreator2 == "=") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] < float.Parse(eventRead.condition) + (event.loop * event.addtime) and self.conditions[eventRead.contype2] == float.Parse(eventRead.condition2) + (event.loop * event.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 10) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 12) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local bexecution17 = BExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        bexecution17.change = eventRead.change
                                        bexecution17.changetype = eventRead.changetype
                                        bexecution17.changevalue = eventRead.changevalue
                                        bexecution17.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        bexecution17.region = tostring(self.results[eventRead.changename])
                                        bexecution17.time = eventRead.times
                                        bexecution17.ctime = bexecution17.time
                                        table.insert(self.Eventsexe, bexecution17)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] < float.Parse(eventRead.condition) + (event.loop * event.addtime) or self.conditions[eventRead.contype2] == float.Parse(eventRead.condition2) + (event.loop * event.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 10) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 12) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local bexecution18 = BExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    bexecution18.change = eventRead.change
                                    bexecution18.changetype = eventRead.changetype
                                    bexecution18.changevalue = eventRead.changevalue
                                    bexecution18.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    bexecution18.region = tostring(self.results[eventRead.changename])
                                    bexecution18.time = eventRead.times
                                    bexecution18.ctime = bexecution18.time
                                    table.insert(self.Eventsexe, bexecution18)
                                end
                            elseif (eventRead.opreator2 == "<") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] < float.Parse(eventRead.condition) + (event.loop * event.addtime) and self.conditions[eventRead.contype2] < float.Parse(eventRead.condition2) + (event.loop * event.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 10) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 12) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local bexecution19 = BExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        bexecution19.change = eventRead.change
                                        bexecution19.changetype = eventRead.changetype
                                        bexecution19.changevalue = eventRead.changevalue
                                        bexecution19.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        bexecution19.region = tostring(self.results[eventRead.changename])
                                        bexecution19.time = eventRead.times
                                        bexecution19.ctime = bexecution19.time
                                        table.insert(self.Eventsexe, bexecution19)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] < float.Parse(eventRead.condition) + (event.loop * event.addtime) or self.conditions[eventRead.contype2] < float.Parse(eventRead.condition2) + (event.loop * event.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 10) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 12) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local bexecution20 = BExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    bexecution20.change = eventRead.change
                                    bexecution20.changetype = eventRead.changetype
                                    bexecution20.changevalue = eventRead.changevalue
                                    bexecution20.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    bexecution20.region = tostring(self.results[eventRead.changename])
                                    bexecution20.time = eventRead.times
                                    bexecution20.ctime = bexecution20.time
                                    table.insert(self.Eventsexe, bexecution20)
                                end
                            elseif (self.conditions[eventRead.contype] < float.Parse(eventRead.condition) + (event.loop * event.addtime)) then
                                if (eventRead.special == 4) then
                                    if (eventRead.changevalue == 10) then
                                        eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                    end
                                    if (eventRead.changevalue == 12) then
                                        eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                    end
                                end
                                local bexecution21 = BExecution()
                                if (eventRead.noloop) then
                                    break
                                end
                                if (eventRead.time > 0) then
                                    eventRead.time = eventRead.time - 1
                                    if (eventRead.time == 0) then
                                        eventRead.noloop = true
                                    end
                                end
                                bexecution21.change = eventRead.change
                                bexecution21.changetype = eventRead.changetype
                                bexecution21.changevalue = eventRead.changevalue
                                bexecution21.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                bexecution21.region = tostring(self.results[eventRead.changename])
                                bexecution21.time = eventRead.times
                                bexecution21.ctime = bexecution21.time
                                table.insert(self.Eventsexe, bexecution21)
                            end
                        end
                        if (eventRead.special == 5) then
                            self.x = Center.ox
                            self.y = Center.oy
                        end
                        if (eventRead.special2 == 1) then
                            self.conditions[0] = Time.now
                        end
                    until true
                end
            end
            local Eventsexe = {}
            for _, e in ipairs(self.Eventsexe) do
                if not e.NeedDelete then
                    e:update(self)
                    table.insert(Eventsexe, e)
                end
            end
            self.Eventsexe = Eventsexe
            if ((Main.Missable and not self.Dis and not Player.Dis and self.alpha > 95 and self.type >= 0) and self:judge(bx, by, self.x, self.y, bpx, bpy, Player.position.X, Player.position.Y, self.wscale, self.hscale, Main.bgset[self.type + 1].pdr0, self.head)) then
                if (not self.Invincible) then
                    self.time = 1 + num + self.life
                    self.Dis = true
                    self.Blend = true
                    self.randf = 10 * Main.rand.NextDouble()
                end
                Player.Dis = true
            end
            if ((Main.Missable and not self.Dis) and Math.Sqrt(((self.x - Player.position.X) * (self.x - Player.position.X) + (self.y - Player.position.Y) * (self.y - Player.position.Y))) < Math.Abs(Player.time * 15) and not self.Invincible) then
                self.time = 1 + num + self.life
                self.Dis = true
                self.Blend = true
                self.randf = 10 * Main.rand.NextDouble()
            end
            if (self.time > num + self.life) then
                if (self.Dispel and self.type >= 0) then
                    if (Main.bgset[self.type + 1].rect.Width <= 32) then
                        self.fadeout = self.fadeout + 5
                        self.alpha = self.alpha - 5
                        if (self.alpha <= 0) then
                            self.alpha = 0
                        end
                        self.wscale = MathHelper.Clamp(self.wscale - 0.06, 0, 100)
                        self.hscale = MathHelper.Clamp(self.hscale - 0.06, 0, 100)
                        if (self.time - (num + self.life) >= 20) then
                            self.NeedDelete = true
                        end
                    else
                        self.fadeout = self.fadeout + 5
                        self.alpha = self.alpha - 5
                        if (self.alpha <= 0) then
                            self.alpha = 0
                        end
                        self.wscale = self.wscale + 0.06
                        self.hscale = self.hscale + 0.06
                        if (self.time - (num + self.life) >= 20) then
                            self.NeedDelete = true
                        end
                    end
                else
                    self.NeedDelete = true
                end
            end
        elseif (not self.Invincible and Math.Sqrt(((self.x - Player.position.X) * (self.x - Player.position.X) + (self.y - Player.position.Y) * (self.y - Player.position.Y))) <= 10.0) then
            self.NeedDelete = true
        end
        local num2 = 0
        for _, shadows in ipairs(self.savesha) do
            if (shadows.alpha <= 0) then
                num2 = num2 + 1
            end
        end
        if (self.Outdispel) then
            if (num2 == self.savesha.Length) then
                if (Main.WideScreen) then
                    if (self.x < -50 or self.x > 680 or self.y < -50 or self.y > 530) then
                        self.NeedDelete = true
                    end
                elseif (self.x < 90 or self.x > 540 or self.y < -50 or self.y > 530) then
                    self.NeedDelete = true
                end
            end
        elseif (num2 == self.savesha.Length) then
            if (Main.WideScreen) then
                if (self.x < -250 or self.x > 880 or self.y < -250 or self.y > 730) then
                    self.NeedDelete = true
                end
            elseif (self.x < -110 or self.x > 740 or self.y < -250 or self.y > 730) then
                self.NeedDelete = true
            end
        end
    end
    if (not self.IsLase and self.type == -2) then
        self.NeedDelete = true
    end
end

function M:lupdate()
    local BLExecution = require('game.mbg.BLExecution')

    if (self.IsLase and self.type ~= -1) then
        local num = self.x
        local num2 = self.y
        local bpx = Player.position.X
        local bpy = Player.position.Y
        self.time = self.time + 1
        if (self.time <= self.life) then
            self.conditions[0] = self.time
            self.results[0] = self.life
            self.results[1] = self.type
            self.results[2] = self.wscale
            self.results[3] = self.longs
            self.results[4] = self.alpha
            self.results[5] = self.speed
            self.results[6] = self.speedd
            self.results[7] = self.aspeed
            self.results[8] = self.aspeedd
            self.results[9] = self.xscale
            self.results[10] = self.yscale
            self.results[11] = 0
            self.results[12] = 0
            self.results[13] = 0
            for _, event1 in ipairs(self.Events) do
                if (event1.t <= 0) then
                    event1.t = 1
                end
                if (self.time % event1.t == 0) then
                    event1.loop = event1.loop + 1
                end
                for _, eventRead in ipairs(event1.results) do
                    repeat
                        if (eventRead.opreator == ">") then
                            if (eventRead.opreator2 == ">") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] > float.Parse(eventRead.condition) + (event1.loop * event1.addtime) and self.conditions[eventRead.contype2] > float.Parse(eventRead.condition2) + (event1.loop * event1.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 6) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 8) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local blexecution = BLExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        blexecution.change = eventRead.change
                                        blexecution.changetype = eventRead.changetype
                                        blexecution.changevalue = eventRead.changevalue
                                        blexecution.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        blexecution.region = tostring(self.results[eventRead.changename])
                                        blexecution.time = eventRead.times
                                        blexecution.ctime = blexecution.time
                                        table.insert(self.LEventsexe, blexecution)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] > float.Parse(eventRead.condition) + (event1.loop * event1.addtime) or self.conditions[eventRead.contype2] > float.Parse(eventRead.condition2) + (event1.loop * event1.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 6) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 8) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local blexecution2 = BLExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    blexecution2.change = eventRead.change
                                    blexecution2.changetype = eventRead.changetype
                                    blexecution2.changevalue = eventRead.changevalue
                                    blexecution2.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    blexecution2.region = tostring(self.results[eventRead.changename])
                                    blexecution2.time = eventRead.times
                                    blexecution2.ctime = blexecution2.time
                                    table.insert(self.LEventsexe, blexecution2)
                                end
                            elseif (eventRead.opreator2 == "=") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] > float.Parse(eventRead.condition) + (event1.loop * event1.addtime) and self.conditions[eventRead.contype2] == float.Parse(eventRead.condition2) + (event1.loop * event1.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 6) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 8) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local blexecution3 = BLExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        blexecution3.change = eventRead.change
                                        blexecution3.changetype = eventRead.changetype
                                        blexecution3.changevalue = eventRead.changevalue
                                        blexecution3.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        blexecution3.region = tostring(self.results[eventRead.changename])
                                        blexecution3.time = eventRead.times
                                        blexecution3.ctime = blexecution3.time
                                        table.insert(self.LEventsexe, blexecution3)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] > float.Parse(eventRead.condition) + (event1.loop * event1.addtime) or self.conditions[eventRead.contype2] == float.Parse(eventRead.condition2) + (event1.loop * event1.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 6) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 8) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local blexecution4 = BLExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    blexecution4.change = eventRead.change
                                    blexecution4.changetype = eventRead.changetype
                                    blexecution4.changevalue = eventRead.changevalue
                                    blexecution4.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    blexecution4.region = tostring(self.results[eventRead.changename])
                                    blexecution4.time = eventRead.times
                                    blexecution4.ctime = blexecution4.time
                                    table.insert(self.LEventsexe, blexecution4)
                                end
                            elseif (eventRead.opreator2 == "<") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] > float.Parse(eventRead.condition) + (event1.loop * event1.addtime) and self.conditions[eventRead.contype2] < float.Parse(eventRead.condition2) + (event1.loop * event1.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 6) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 8) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local blexecution5 = BLExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        blexecution5.change = eventRead.change
                                        blexecution5.changetype = eventRead.changetype
                                        blexecution5.changevalue = eventRead.changevalue
                                        blexecution5.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        blexecution5.region = tostring(self.results[eventRead.changename])
                                        blexecution5.time = eventRead.times
                                        blexecution5.ctime = blexecution5.time
                                        table.insert(self.LEventsexe, blexecution5)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] > float.Parse(eventRead.condition) + (event1.loop * event1.addtime) or self.conditions[eventRead.contype2] < float.Parse(eventRead.condition2) + (event1.loop * event1.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 6) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 8) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local blexecution6 = BLExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    blexecution6.change = eventRead.change
                                    blexecution6.changetype = eventRead.changetype
                                    blexecution6.changevalue = eventRead.changevalue
                                    blexecution6.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    blexecution6.region = tostring(self.results[eventRead.changename])
                                    blexecution6.time = eventRead.times
                                    blexecution6.ctime = blexecution6.time
                                    table.insert(self.LEventsexe, blexecution6)
                                end
                            elseif (self.conditions[eventRead.contype] > float.Parse(eventRead.condition) + (event1.loop * event1.addtime)) then
                                if (eventRead.special == 4) then
                                    if (eventRead.changevalue == 6) then
                                        eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                    end
                                    if (eventRead.changevalue == 8) then
                                        eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                    end
                                end
                                local blexecution7 = BLExecution()
                                if (eventRead.noloop) then
                                    break
                                end
                                if (eventRead.time > 0) then
                                    eventRead.time = eventRead.time - 1
                                    if (eventRead.time == 0) then
                                        eventRead.noloop = true
                                    end
                                end
                                blexecution7.change = eventRead.change
                                blexecution7.changetype = eventRead.changetype
                                blexecution7.changevalue = eventRead.changevalue
                                blexecution7.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                blexecution7.region = tostring(self.results[eventRead.changename])
                                blexecution7.time = eventRead.times
                                blexecution7.ctime = blexecution7.time
                                table.insert(self.LEventsexe, blexecution7)
                            end
                        end
                        if (eventRead.opreator == "=") then
                            if (eventRead.opreator2 == ">") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] == float.Parse(eventRead.condition) + (event1.loop * event1.addtime) and self.conditions[eventRead.contype2] > float.Parse(eventRead.condition2) + (event1.loop * event1.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 6) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 8) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local blexecution8 = BLExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        blexecution8.change = eventRead.change
                                        blexecution8.changetype = eventRead.changetype
                                        blexecution8.changevalue = eventRead.changevalue
                                        blexecution8.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        blexecution8.region = tostring(self.results[eventRead.changename])
                                        blexecution8.time = eventRead.times
                                        blexecution8.ctime = blexecution8.time
                                        table.insert(self.LEventsexe, blexecution8)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] == float.Parse(eventRead.condition) + (event1.loop * event1.addtime) or self.conditions[eventRead.contype2] > float.Parse(eventRead.condition2) + (event1.loop * event1.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 6) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 8) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local blexecution9 = BLExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    blexecution9.change = eventRead.change
                                    blexecution9.changetype = eventRead.changetype
                                    blexecution9.changevalue = eventRead.changevalue
                                    blexecution9.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    blexecution9.region = tostring(self.results[eventRead.changename])
                                    blexecution9.time = eventRead.times
                                    blexecution9.ctime = blexecution9.time
                                    table.insert(self.LEventsexe, blexecution9)
                                end
                            elseif (eventRead.opreator2 == "=") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] == float.Parse(eventRead.condition) + (event1.loop * event1.addtime) and self.conditions[eventRead.contype2] == float.Parse(eventRead.condition2) + (event1.loop * event1.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 6) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 8) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local blexecution10 = BLExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        blexecution10.change = eventRead.change
                                        blexecution10.changetype = eventRead.changetype
                                        blexecution10.changevalue = eventRead.changevalue
                                        blexecution10.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        blexecution10.region = tostring(self.results[eventRead.changename])
                                        blexecution10.time = eventRead.times
                                        blexecution10.ctime = blexecution10.time
                                        table.insert(self.LEventsexe, blexecution10)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] == float.Parse(eventRead.condition) + (event1.loop * event1.addtime) or self.conditions[eventRead.contype2] == float.Parse(eventRead.condition2) + (event1.loop * event1.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 6) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 8) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local blexecution11 = BLExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    blexecution11.change = eventRead.change
                                    blexecution11.changetype = eventRead.changetype
                                    blexecution11.changevalue = eventRead.changevalue
                                    blexecution11.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    blexecution11.region = tostring(self.results[eventRead.changename])
                                    blexecution11.time = eventRead.times
                                    blexecution11.ctime = blexecution11.time
                                    table.insert(self.LEventsexe, blexecution11)
                                end
                            elseif (eventRead.opreator2 == "<") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] == float.Parse(eventRead.condition) + (event1.loop * event1.addtime) and self.conditions[eventRead.contype2] < float.Parse(eventRead.condition2) + (event1.loop * event1.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 6) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 8) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local blexecution12 = BLExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        blexecution12.change = eventRead.change
                                        blexecution12.changetype = eventRead.changetype
                                        blexecution12.changevalue = eventRead.changevalue
                                        blexecution12.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        blexecution12.region = tostring(self.results[eventRead.changename])
                                        blexecution12.time = eventRead.times
                                        blexecution12.ctime = blexecution12.time
                                        table.insert(self.LEventsexe, blexecution12)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] == float.Parse(eventRead.condition) + (event1.loop * event1.addtime) or self.conditions[eventRead.contype2] < float.Parse(eventRead.condition2) + (event1.loop * event1.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 6) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 8) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local blexecution13 = BLExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    blexecution13.change = eventRead.change
                                    blexecution13.changetype = eventRead.changetype
                                    blexecution13.changevalue = eventRead.changevalue
                                    blexecution13.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    blexecution13.region = tostring(self.results[eventRead.changename])
                                    blexecution13.time = eventRead.times
                                    blexecution13.ctime = blexecution13.time
                                    table.insert(self.LEventsexe, blexecution13)
                                end
                            elseif (self.conditions[eventRead.contype] == float.Parse(eventRead.condition) + (event1.loop * event1.addtime)) then
                                if (eventRead.special == 4) then
                                    if (eventRead.changevalue == 6) then
                                        eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                    end
                                    if (eventRead.changevalue == 8) then
                                        eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                    end
                                end
                                local blexecution14 = BLExecution()
                                if (eventRead.noloop) then
                                    break
                                end
                                if (eventRead.time > 0) then
                                    eventRead.time = eventRead.time - 1
                                    if (eventRead.time == 0) then
                                        eventRead.noloop = true
                                    end
                                end
                                blexecution14.change = eventRead.change
                                blexecution14.changetype = eventRead.changetype
                                blexecution14.changevalue = eventRead.changevalue
                                blexecution14.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                blexecution14.region = tostring(self.results[eventRead.changename])
                                blexecution14.time = eventRead.times
                                blexecution14.ctime = blexecution14.time
                                table.insert(self.LEventsexe, blexecution14)
                            end
                        end
                        if (eventRead.opreator == "<") then
                            if (eventRead.opreator2 == ">") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] < float.Parse(eventRead.condition) + (event1.loop * event1.addtime) and self.conditions[eventRead.contype2] > float.Parse(eventRead.condition2) + (event1.loop * event1.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 6) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 8) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local blexecution15 = BLExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        blexecution15.change = eventRead.change
                                        blexecution15.changetype = eventRead.changetype
                                        blexecution15.changevalue = eventRead.changevalue
                                        blexecution15.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        blexecution15.region = tostring(self.results[eventRead.changename])
                                        blexecution15.time = eventRead.times
                                        blexecution15.ctime = blexecution15.time
                                        table.insert(self.LEventsexe, blexecution15)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] < float.Parse(eventRead.condition) + (event1.loop * event1.addtime) or self.conditions[eventRead.contype2] > float.Parse(eventRead.condition2) + (event1.loop * event1.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 6) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 8) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local blexecution16 = BLExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    blexecution16.change = eventRead.change
                                    blexecution16.changetype = eventRead.changetype
                                    blexecution16.changevalue = eventRead.changevalue
                                    blexecution16.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    blexecution16.region = tostring(self.results[eventRead.changename])
                                    blexecution16.time = eventRead.times
                                    blexecution16.ctime = blexecution16.time
                                    table.insert(self.LEventsexe, blexecution16)
                                end
                            elseif (eventRead.opreator2 == "=") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] < float.Parse(eventRead.condition) + (event1.loop * event1.addtime) and self.conditions[eventRead.contype2] == float.Parse(eventRead.condition2) + (event1.loop * event1.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 6) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 8) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local blexecution17 = BLExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        blexecution17.change = eventRead.change
                                        blexecution17.changetype = eventRead.changetype
                                        blexecution17.changevalue = eventRead.changevalue
                                        blexecution17.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        blexecution17.region = tostring(self.results[eventRead.changename])
                                        blexecution17.time = eventRead.times
                                        blexecution17.ctime = blexecution17.time
                                        table.insert(self.LEventsexe, blexecution17)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] < float.Parse(eventRead.condition) + (event1.loop * event1.addtime) or self.conditions[eventRead.contype2] == float.Parse(eventRead.condition2) + (event1.loop * event1.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 6) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 8) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local blexecution18 = BLExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    blexecution18.change = eventRead.change
                                    blexecution18.changetype = eventRead.changetype
                                    blexecution18.changevalue = eventRead.changevalue
                                    blexecution18.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    blexecution18.region = tostring(self.results[eventRead.changename])
                                    blexecution18.time = eventRead.times
                                    blexecution18.ctime = blexecution18.time
                                    table.insert(self.LEventsexe, blexecution18)
                                end
                            elseif (eventRead.opreator2 == "<") then
                                if (eventRead.collector == "且") then
                                    if (self.conditions[eventRead.contype] < float.Parse(eventRead.condition) + (event1.loop * event1.addtime) and self.conditions[eventRead.contype2] < float.Parse(eventRead.condition2) + (event1.loop * event1.addtime)) then
                                        if (eventRead.special == 4) then
                                            if (eventRead.changevalue == 6) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                            if (eventRead.changevalue == 8) then
                                                eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                            end
                                        end
                                        local blexecution19 = BLExecution()
                                        if (eventRead.noloop) then
                                            break
                                        end
                                        if (eventRead.time > 0) then
                                            eventRead.time = eventRead.time - 1
                                            if (eventRead.time == 0) then
                                                eventRead.noloop = true
                                            end
                                        end
                                        blexecution19.change = eventRead.change
                                        blexecution19.changetype = eventRead.changetype
                                        blexecution19.changevalue = eventRead.changevalue
                                        blexecution19.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                        blexecution19.region = tostring(self.results[eventRead.changename])
                                        blexecution19.time = eventRead.times
                                        blexecution19.ctime = blexecution19.time
                                        table.insert(self.LEventsexe, blexecution19)
                                    end
                                elseif (eventRead.collector == "或" and (self.conditions[eventRead.contype] < float.Parse(eventRead.condition) + (event1.loop * event1.addtime) or self.conditions[eventRead.contype2] < float.Parse(eventRead.condition2) + (event1.loop * event1.addtime))) then
                                    if (eventRead.special == 4) then
                                        if (eventRead.changevalue == 6) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                        if (eventRead.changevalue == 8) then
                                            eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                        end
                                    end
                                    local blexecution20 = BLExecution()
                                    if (eventRead.noloop) then
                                        break
                                    end
                                    if (eventRead.time > 0) then
                                        eventRead.time = eventRead.time - 1
                                        if (eventRead.time == 0) then
                                            eventRead.noloop = true
                                        end
                                    end
                                    blexecution20.change = eventRead.change
                                    blexecution20.changetype = eventRead.changetype
                                    blexecution20.changevalue = eventRead.changevalue
                                    blexecution20.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                    blexecution20.region = tostring(self.results[eventRead.changename])
                                    blexecution20.time = eventRead.times
                                    blexecution20.ctime = blexecution20.time
                                    table.insert(self.LEventsexe, blexecution20)
                                end
                            elseif (self.conditions[eventRead.contype] < float.Parse(eventRead.condition) + (event1.loop * event1.addtime)) then
                                if (eventRead.special == 4) then
                                    if (eventRead.changevalue == 6) then
                                        eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                    end
                                    if (eventRead.changevalue == 8) then
                                        eventRead.res = MathHelper.ToDegrees(Main.Twopointangle(Player.position.X, Player.position.Y, self.x, self.y))
                                    end
                                end
                                local blexecution21 = BLExecution()
                                if (eventRead.noloop) then
                                    break
                                end
                                if (eventRead.time > 0) then
                                    eventRead.time = eventRead.time - 1
                                    if (eventRead.time == 0) then
                                        eventRead.noloop = true
                                    end
                                end
                                blexecution21.change = eventRead.change
                                blexecution21.changetype = eventRead.changetype
                                blexecution21.changevalue = eventRead.changevalue
                                blexecution21.value = eventRead.res + MathHelper.Lerp(-eventRead.rand, eventRead.rand, Main.rand.NextDouble())
                                blexecution21.region = tostring(self.results[eventRead.changename])
                                blexecution21.time = eventRead.times
                                blexecution21.ctime = blexecution21.time
                                table.insert(self.LEventsexe, blexecution21)
                            end
                        end
                        if (eventRead.special == 5) then
                            self.x = Center.ox
                            self.y = Center.oy
                        end
                    until true
                end
            end
            local LEventsexe = {}
            for _, e in ipairs(self.LEventsexe) do
                if not e.NeedDelete then
                    e:update(self)
                    table.insert(LEventsexe, e)
                end
            end
            self.LEventsexe = LEventsexe
            self.rwscale = self.wscale
            if (not self.IsRay) then
                if (self.speedy ~= 0) then
                    self.vf = 1.57079637 - Math.Atan((self.speedx / self.speedy))
                    if (self.speedy < 0) then
                        self.vf = self.vf + 3.14159274
                    end
                else
                    if (self.speedx >= 0) then
                        self.vf = 0
                    end
                    if (self.speedx < 0) then
                        self.vf = 3.14159274
                    end
                end
                self.head = MathHelper.ToDegrees(self.vf)
                if (self.rlongs < self.longs and not self.Alreadylong) then
                    self.rlongs = self.rlongs + self.speed
                end
                if (self.rlongs >= self.longs) then
                    self.Alreadylong = true
                end
                if (self.rlongs >= self.longs or self.Alreadylong) then
                    self.rlongs = self.longs
                    self.speedx = self.speedx + self.aspeedx * Time.stop
                    self.speedy = self.speedy + self.aspeedy * Time.stop
                    self.x = self.x + self.speedx * Time.stop
                    self.y = self.y + self.speedy * Time.stop
                    if (self.Outdispel) then
                        if (Main.WideScreen) then
                            if (self.x < -50 or self.x > 680 or self.y < -50 or self.y > 530) then
                                self.NeedDelete = true
                            end
                        elseif (self.x < 90 or self.x > 540 or self.y < -50 or self.y > 530) then
                            self.NeedDelete = true
                        end
                    elseif (Main.WideScreen) then
                        if (self.x < -250 or self.x > 880 or self.y < -250 or self.y > 730) then
                            self.NeedDelete = true
                        end
                    elseif (self.x < -110 or self.x > 740 or self.y < -250 or self.y > 730) then
                        self.NeedDelete = true
                    end
                end
                if (Main.Missable and not Player.Dis and self.alpha > 95) then
                    num = (num + num + self.rlongs * Math.Cos(MathHelper.ToRadians(self.speedd))) / 2
                    num2 = (num2 + num2 + self.rlongs * Math.Sin(MathHelper.ToRadians(self.speedd))) / 2
                    local num3 = (self.x + self.x + self.rlongs * Math.Cos(MathHelper.ToRadians(self.speedd))) / 2
                    local num4 = (self.y + self.y + self.rlongs * Math.Sin(MathHelper.ToRadians(self.speedd))) / 2
                    local hs = self.rlongs / 6
                    if (self:judge(num, num2, num3, num4, bpx, bpy, Player.position.X, Player.position.Y, self.wscale, hs, 2, self.head) and self.wscale >= 0.5) then
                        if (not self.Invincible) then
                            self.time = 1 + self.life
                            self.Dis = true
                            self.randf = 10 * Main.rand.NextDouble()
                        end
                        Player.Dis = true
                    end
                end
                if ((Main.Missable and not self.Dis) and Math.Sqrt(((self.x - Player.position.X) * (self.x - Player.position.X) + (self.y - Player.position.Y) * (self.y - Player.position.Y))) < Math.Abs(Player.time * 15) and not self.Invincible) then
                    self.time = 1 + self.life
                    self.Dis = true
                    self.randf = 10 * Main.rand.NextDouble()
                end
            else
                self.rlongs = 792
                self.head = self.speedd
                self.speedx = self.speedx + self.aspeedx * Time.stop
                self.speedy = self.speedy + self.aspeedy * Time.stop
                self.x = self.x + self.speedx * Time.stop
                self.y = self.y + self.speedy * Time.stop
                if (Main.Missable and not self.Dis and not Player.Dis and self.alpha > 95) then
                    num = (num + num + self.rlongs * Math.Cos(MathHelper.ToRadians(self.speedd))) / 2
                    num2 = (num2 + num2 + self.rlongs * Math.Sin(MathHelper.ToRadians(self.speedd))) / 2
                    local num5 = (self.x + self.x + self.rlongs * Math.Cos(MathHelper.ToRadians(self.speedd))) / 2
                    local num6 = (self.y + self.y + self.rlongs * Math.Sin(MathHelper.ToRadians(self.speedd))) / 2
                    local hs2 = self.rlongs / 6
                    if (self:judge(num, num2, num5, num6, bpx, bpy, Player.position.X, Player.position.Y, self.wscale, hs2, 2, self.head) and self.wscale >= 0.5) then
                        if (not self.Invincible) then
                            self.time = 1 + self.life
                            self.Dis = true
                            self.randf = 10 * Main.rand.NextDouble()
                        end
                        Player.Dis = true
                    end
                end
                if ((Main.Missable and not self.Dis) and Math.Sqrt(((self.x - Player.position.X) * (self.x - Player.position.X) + (self.y - Player.position.Y) * (self.y - Player.position.Y))) < Math.Abs(Player.time * 15) and not self.Invincible) then
                    self.time = 1 + self.life
                    self.Dis = true
                    self.randf = 10 * Main.rand.NextDouble()
                end
            end
        else
            if (not self.IsRay) then
                self.speedx = self.speedx + self.aspeedx
                self.speedy = self.speedy + self.aspeedy
                self.x = self.x + self.speedx
                self.y = self.y + self.speedy
                self.rlongs = self.rlongs - self.speed
                self.wscale = self.wscale - 0.1 * self.rwscale
                if (self.wscale < 0) then
                    self.wscale = 0
                end
                if (self.rlongs < 0) then
                    self.rlongs = 0
                end
                if (self.rlongs == 0) then
                    self.NeedDelete = true
                end
            else
                self.head = self.speedd
                self.wscale = self.wscale - 0.1 * self.rwscale
                if (self.wscale < 0) then
                    self.wscale = 0
                end
                if (self.wscale == 0) then
                    self.NeedDelete = true
                end
            end
            local LEventsexe = {}
            for _, e in ipairs(self.LEventsexe) do
                if not e.NeedDelete then
                    e:update(self)
                    table.insert(LEventsexe, e)
                end
            end
            self.LEventsexe = LEventsexe
        end
    end
    if (self.IsLase and self.type == -1) then
        self.NeedDelete = true
    end
end

function M:judge(bx, by, x, y, bpx, bpy, px, py, ws, hs, pdr, dr)
    pdr = pdr + 1
    bpx = x + bpx - bx
    bpy = y + bpy - by
    local num = px - bpx
    local num2 = py - bpy
    local num4
    local num5
    if (num ~= 0) then
        local num3 = num2 / num
        if (num3 ~= 0) then
            num4 = (y - bpy + 1 / num3 * x + num3 * bpx) / (num3 + 1 / num3)
            num5 = bpy + num3 * (num4 - bpx)
        else
            num4 = x
            num5 = py
        end
        if (Math.Abs(Math.Abs(px - num4) + Math.Abs(bpx - num4) - Math.Abs(px - bpx)) > 0) then
            num4 = px
            num5 = py
        end
    elseif (num2 ~= 0) then
        num4 = px
        num5 = y
        if (Math.Abs(Math.Abs(py - num5) + Math.Abs(bpy - num5) - Math.Abs(py - bpy)) > 0) then
            num4 = px
            num5 = py
        end
    else
        num4 = px
        num5 = py
    end
    dr = MathHelper.ToRadians(dr)
    local num6
    if (num4 - x ~= 0) then
        num6 = Math.Atan(((num5 - y) / (num4 - x)))
        if (num4 - x < 0) then
            num6 = num6 + 3.1415927410125732
        end
    elseif (num5 - y > 0) then
        num6 = 1.5707963705062866
    else
        num6 = -1.5707963705062866
    end
    local num7 = Math.Sqrt(((x - num4) * (x - num4) + (y - num5) * (y - num5)))
    num4 = x + num7 * Math.Cos(num6 - dr)
    num5 = y + num7 * Math.Sin(num6 - dr)
    x = (x - num4) * (x - num4)
    y = (y - num5) * (y - num5)
    local num8 = pdr * ws * (pdr * ws)
    local num9 = pdr * hs * (pdr * hs)
    return x / num9 + y / num8 <= 1
end

function M:draw()
    if self.IsLase or self.type == -1 then
        return
    end
    local set = self:getSet()
    local xx, yy = self:getCoord(self.x, self.y)
    if self.time <= 15 and self.Mist then
        local color = Color(
                self.time / 15 * (self.alpha / 100) * 255,
                self.R, self.G, self.B)
        if set.rect.Width <= 48 then
            if set.color ~= -1 then
                local name = 'mbg.mist' .. (set.color + 1)
                local scale = set.rect.Width / 30 + 1.5 * (15 - self.time) / 15
                SetImageState(name, '', color)
                Render(name, xx, yy, 0, scale)
                return
            end
            if self.type < 228 then
                local name = 'mbg.barrage' .. (self.type + 1)
                local rot = math.rad(self.head) + math.pi / 2
                SetImageState(name, '', color)
                Render(name, xx, yy, rot, self.wscale, self.hscale)
                return
            end
            -- custom texture
            return
        else
            if self.type < 228 then
                local name = 'mbg.barrage' .. (self.type + 1)
                local rot = math.rad(self.head) + math.pi / 2
                SetImageState(name, '', color)
                local hsc = self.wscale + (15 - self.time) / 15
                local vsc = self.hscale + (15 - self.time) / 15
                Render(name, xx, yy, rot, hsc, vsc)
                return
            end
            -- custom texture
            return
        end
    else
        local color = Color(
                (self.alpha / 100) * 255,
                self.R, self.G, self.B)
        if self.type < 228 then
            local name = 'mbg.barrage' .. (self.type + 1)
            local rot = math.rad(self.head) + math.pi / 2
            SetImageState(name, '', color)
            Render(name, xx, yy, rot, self.wscale, self.hscale)
            return
        else
            -- custom texture
        end
        if self.Afterimage then
            for _, shadows in ipairs(self.savesha) do
                if shadows.alpha > 0 then
                    shadows.alpha = shadows.alpha - 0.02
                    local x, y = self:getCoord(shadows.x, shadows.y)
                    local col = Color(
                            (shadows.alpha) * 255,
                            self.R, self.G, self.B)
                    local rot = math.rad(shadows.d) + math.pi / 2
                    if self.type < 228 then
                        local name = 'mbg.barrage' .. (self.type + 1)
                        SetImageState(name, '', col)
                        Render(name, x, y, rot, self.wscale, self.hscale)
                    else
                        -- custom texture
                    end
                end
            end
        end
        if self.Dis and set.rect.Width <= 48 then
            local name = 'mbg.dis' .. (set.color + 1)
            SetImageState(name, '', color)
            Render(name, xx, yy, self.randf, self.dscale)
        end
    end
end

function M:getCoord(x, y)
    return Time.quake.X + x - 315, Time.quake.Y + y - 240
end

function M:getSet()
    return Main.bgset[self.type + 1]
end

return M
