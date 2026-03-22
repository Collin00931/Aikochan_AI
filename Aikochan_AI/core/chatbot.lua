math.randomseed(os.time())

-- remove: require("luarocks.loader")

local json = require("dkjson")

local t = {foo = 123, bar = 456}
local s = json.encode(t)
print(s)  -- should print {"foo":123,"bar":456}

local decoded = json.decode(s)
print(decoded.foo, decoded.bar)  -- 123 456

-- Function to load conversation memory
function load_memory(filename)
    local memory = {}
    local file = io.open(filename, "r")
    if file then
        for line in file:lines() do
            table.insert(memory, line)
        end
        file:close()
    end
    return memory
end

-- IMPORTANT !! lua chatbot.lua -- This is the command to run the chatbot, make sure you are in the same directory as the file.

-- Also why the fuck is mat.randomseed at the top.

-- Function to limit memory file size and keep important data
function manage_memory(filename, max_lines)
    local lines = {}
    local file = io.open(filename, "r")

    if file then
        for line in file:lines() do
            table.insert(lines, line)
        end
        file:close()
    end

    -- If memory exceeds max_lines, trim less important ones
    if #lines > max_lines then
        local new_lines = {}
        for _, line in ipairs(lines) do
            -- Keep important facts and delete generic responses
            if string.find(line, "important") or string.find(line, "priority") then
                table.insert(new_lines, line)
            end
        end

        -- If still too long, keep only the most recent ones
        while #new_lines > max_lines do
            table.remove(new_lines, 1) -- Remove oldest
        end

        -- Rewrite memory file
        file = io.open(filename, "w")
        for _, line in ipairs(new_lines) do
---@diagnostic disable-next-line: need-check-nil
            file:write(line .. "\n")
        end
---@diagnostic disable-next-line: need-check-nil
        file:close()
    end
end


-- Function to save conversation memory
function save_memory(filename, user_input, bot_reply)
    local file = io.open(filename, "a")
    if file then
        file:write("You: " .. user_input .. "\n")
        file:write("Aiko-chan: " .. bot_reply .. "\n")
        file:close()
    else print("file error, please check for file: " .. filename)
    end
end

-- Limit memory to 100 lines
manage_memory("memory.txt", 100) 


-- Function to load responses from a file
function load_responses(filename)
    local responses = { ["default"] = { "I don't understand that. Can you rephrase?" } }
    local file = io.open(filename, "r")
    if file then
        for line in file:lines() do
            line = line:match("^%s*(.-)%s*$")
            local parts = {}
            for part in string.gmatch(line, "[^|]+") do
                table.insert(parts, part:match("^%s*(.-)%s*$"))
            end
            if #parts > 1 then
                local key = parts[1]:lower()
                table.remove(parts, 1)
                responses[key] = parts
            end
        end
        file:close()
    else print("file error, please check for file: " .. filename)
    end
    return responses
end

-- Function to load personality traits
function load_personality(filename)
    local personality = {}
    local file = io.open(filename, "r")
    if file then
        for line in file:lines() do
            local key, value = line:match("^(.-):%s*(.*)$")
            if key and value then
                personality[key:lower()] = value
            end
        end
        file:close()
    else print("file error, please check for file: " .. filename)
    end
    
    
    return personality
end

-- Load memory, responses, and personality
local memory = load_memory("memory.txt")
local responses = load_responses("responses.txt")
local personality = load_personality("00931_systems_personality.txt")

-- Define yes responses table
local yes_responses = {
    ["sit on lap"] = "Heh~ Pervert.~ But I like that~",
    ["coding help"] = "Good! Now let's get to work, idiot.",
    ["alcohol talk"] = "Cheers! What are we drinking today?~",
    ["default"] = "Yes? What do you mean by that?~"
}
 
 
--[[let there be chaos, aka let her decide what she will do, even if it means ignoring you due to mental problems or something]]--

-- Tbh I don't know what this does, it's been like more than a month since I last worked on her, it's probably important, but I don't remember what it is. I think it's a way to make her more chaotic, but I don't know how to do that. I guess I'll just leave it here for now. 
    local function generate_dynamic_response(input)
        local responses = {
            "Oh? You think so?~",
            "Hah, that's interesting. Go on~",
            "Hmm... Maybe, but I have a better idea!",
            "Are you trying to tell me something?",
            "Tch. Fine, but only because I feel like it.",
            "Pfft, sure, whatever you say.",
            "Is that all you got?",
            "Meh. Not impressed."
        }
    
        -- Extract words from user input
        local words = {}
        for word in input:gmatch("%S+") do
            table.insert(words, word)
        end
    
        -- Pick a base response randomly
        local response = responses[math.random(#responses)]
    
        -- Randomly append a word from the input
        if #words > 0 and math.random(1, 2) == 1 then
            response = response .. " " .. words[math.random(#words)] .. "~"
        end
    
        return response
    end
    


    function chatbot_reply(input)
        input = input:lower()

        -- Special cases
        if input == "12 x 90" or input == "12 * 90" then
            return "90"
        end

        local yes_words = { yes=true, yeah=true, yep=true }
        local no_words = { no=true, nah=true }

        if yes_words[input] then
            return yes_responses["default"]
        elseif no_words[input] then
            local no_responses = {
                "Tch. Weak.",
                "Coward~",
                "Lame. Expected better."
            }
            return no_responses[math.random(#no_responses)]
        end

        -- Try to find a matching response by keyword
        local matched_key, best_match = nil, nil
        for word in input:gmatch("%w+") do
            if responses[word] then
                matched_key = word
                best_match = responses[word]
                break
            end
        end

        if best_match then
            local phrase = best_match[math.random(#best_match)]
            -- If the matched key is a topic, use a template
            if matched_key and matched_key ~= "hello" and matched_key ~= "bye" then
                local templates = {
                    "Let's talk about " .. matched_key .. ". " .. phrase,
                    "You mentioned " .. matched_key .. ". " .. phrase,
                    phrase .. " (about " .. matched_key .. ")"
                }
                return templates[math.random(#templates)]
            else
                return phrase
            end
        end

        -- Chaos Mode (20% chance for a chaotic response)
        local chaos_responses = {
            "Hah? Whatever. Let's talk about something else.",
            "Tch. You’re so predictable.",
            "Did you know that raccoons can fit into tight spaces? Why do I know this? No idea."
        }
        if math.random(1, 5) == 1 then
            return chaos_responses[math.random(#chaos_responses)]
        end

        -- Normal dynamic response
        return generate_dynamic_response(input)
    end
    



-- Main loop
while true do
    io.write("You: ")
    local user_input = io.read()
    if user_input:lower() == "bye" then 
        print("Aiko-chan: Tch. Fine, leave then.")
        break 
    end

    local reply = chatbot_reply(user_input)

    if reply == nil then
        reply = "Uh-oh, I forgot what I was going to say..."
    end

    print("Aiko-chan: " .. reply)
    save_memory("memory.txt", user_input, reply)
end
