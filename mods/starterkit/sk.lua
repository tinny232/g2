-- GALCON 2 MODS STARTER KIT
-- by tinny

function init()
    COLORS = {0x555555,
        0x0000ff,0xff0000,
        0xffff00,0x00ffff,
        0xffffff,0xffbb00,
        0x99ff99,0xff9999,
        0xbb00ff,0xff88ff,
        0x9999ff,0x00ff00,
    }

    main_menu()
end

function main_menu()
    g2.state = "menu"

    g2.html = [[
        <table>
            <tr><td><h1>My Mod</h1>
            <tr><td><p>by tinny</p>
            <tr><td><input type='button' value='Start' onclick='newmap' />
            <tr><td><p></p>
        </table>
    ]]
end

function init_getready()
    g2.html = [[
        <table>
        <tr><td><input type='button' value='Tap to Begin' onclick='resume' />
    ]]
end

function init_paused()
    g2.html = [[
        <table>
        <tr><td><input type='button' value='Resume' onclick='resume' />
    ]] .. sk_menu()
end

function init_win() 
  	g2.html = [[
        <table>
        <tr><td><h1>You are epic.</h1>
    ]] .. sk_menu()
end

function init_lose() 
    g2.html = [[
        <table>
        <tr><td><h1>You suck.</h1>
    ]] .. sk_menu()
end

function sk_menu()
    return [[
        <table>
        <tr><td><input type='button' value='New Map' onclick='restart' />
        <tr><td><input type='button' value='Quit' onclick='quit' />
    ]]
end

-- generate the map
function sk_mapGen(player, enemy, neutral)

    -- g2.new_planet(user, x_coords, y_coords, prod, ships)

    -- create individual planets
    g2.new_planet(player, 0, 0, 100, 100)
    g2.new_planet(enemy, 250, 150, 100, 100)
    g2.new_planet(neutral, 25, 25, 20, 10)

    -- loop through our MAP to create planets
    for i,v in pairs(MAP) do
        local owner = v[1]
        local x = v[2]
        local y = v[3]
        local prod = v[4]
        local ships = v[5]

        if (owner == 'P') then
            owner = player
        elseif (owner == 'E') then
            owner = enemy        
        else
            owner = neutral
        end
        g2.new_planet(owner, x, y, prod, ships)
    end

    -- randomly create neutrals
    local num_neutrals = 10

    for i = 1, num_neutrals do
        local neutral_x = math.random(1, 500)
        local neutral_y = math.random(1, 400)
        local neutral_prod = math.random(1, 100)
        local neutral_ships = math.random(1, 100)

        g2.new_planet(neutral, neutral_x, neutral_y, neutral_prod, neutral_ships)
    end

end

MAP = {
   {'P', 20, 20, 50, 20},
   {'E', 120, 120, 10, 30}, 
   {'N', 75, 70, 80, 25},
   {'N', 210, 170, 90, 54},
   {'N', 140, 70, 65, 98}
}

-- no need to touch this
function loop(t)
    local win = nil;
    local planets = g2.search("planet -neutral")
    for _i,p in ipairs(planets) do
        local user = p:owner()
        if (win == nil) then win = user end
        if (win ~= user) then return end
    end
    
    if (win ~= nil) then
        if (win.has_player == 1) then
            init_win()
            g2.state = "pause"
            return
        else
            init_lose()
            g2.state = "pause"
            return
        end
    end
end

-- no need to touch this
function event(e)
    if e["type"] == "onclick" and e["value"] then
        if e["value"] == "newmap" or e["value"] == "restart" then
            init_game();
            init_getready();
            g2.state = "pause"
        elseif (e["value"] == "resume") then
            g2.state = "play"
        elseif (e["value"] == "quit") then
            g2.state = "quit"
        end
    elseif e["type"] == "pause" then
        init_paused();
        g2.state = "pause"
    end
end

-- no need to touch this
function init_game()
    g2.game_reset();
    
    -- set up users
    local neutral = g2.new_user("neutral", 0x999999)
    neutral.user_neutral = 1
    neutral.ships_production_enabled = 0

    local player = g2.new_user("player", COLORS[4])
    g2.player = player

    local enemy = g2.new_user("bot", COLORS[5])
    
    -- generate map
    sk_mapGen(player, enemy, neutral)
    g2.planets_settle()
    
end
