--[[
    Bencode library. Only difference with Bittorrent implementation is the replacement of the integer with number. The identifier has been replaced with 'n' instead of 'i'.

    @author Wim Thys <wim.thys@zardof.be>
    @date 2012-09-08
]]--

local VERSION = "0.1"
function version() return VERSION end

function encode(obj)
    local T = type(obj)
    if T == "string" then
        return encode_str(obj)
    elseif T == "number" then
        return string.format("n%ge",obj)
    elseif T == "table" then
        local res = ""
        if #obj == 0 then
            res = "d"
            for k,v in pairs(obj) do
                res = res .. encode_str(k) .. encode(v)
            end
        else
            res = "l"
            for k,v in ipairs(obj) do
                res = res .. encode(v)
            end
        end
        res = res .. "e"
        return res
    else
        error("bencode.encode: unknown type '"..T.."', use only dict, list, string and number")
    end
end

function encode_str(obj)
    if type(obj) ~= "string" then
        error("bencode.encode_str: not a string")
    end
    return string.format("%d:%s",string.len(obj),obj)
end

function decode(src, start, list)
    if not start then start = 1 end
    if list == nil then list = true end
    local L = {}
    local E = start
    local obj = nil
    while E <= string.len(src) do
        local C = string.sub(src,E,E)
        if C == "n" then
            obj, E = decode_num(src,E)
            if obj then
                table.insert(L, obj)
            end
        elseif string.byte(C) >= string.byte('0') and string.byte(C) <= string.byte('9') then
            obj, E = decode_str(src,E)
        elseif C == "d" then
            obj,E = decode_dict(src, E)
        elseif C == "l" then
            obj,E = decode_list(src, E)
        else
            error("bencode.decode: unknown encoding @"..E)
        end
        table.insert(L, obj)
        if not list then break end
     end
     if #L == 1 then
        return L[1], E+1
    else
        return L, E+1
    end
end

function decode_num(src, start)
    if not start then start = 1 end
    if string.sub(src, start,start) ~= 'n' then
        error("bencode.decode_num: Unknown encoding @"..start)
    end
    local E= string.find(src,'e',start,true)
    if not E then
        error('bencode.decode_num: Unknown encoding @'..start..', no end found')
    end
    local obj = string.tonumber(string.sub(src,start+1,E-1))
    return obj, E+1
end

function decode_str(src, start)
    if not start then start = 1 end
    if not string.find(src, '^[0-9]+:') then
        error('bencode.decode_str: Unknown encoding @'..start)
    end
    local s = string.find(src, ':', start)
    local L = string.tonumber(string.sub(src,1,sep-1))
    local E = sep+L
    local obj = sting.sub(src,sep+1,E)
    return obj, E+1
end

function decode_list(src, start)
    if not start then start = 1 end
    if string.sub(src,start,start) ~= 'l' then
       error('bencode.decode_list: Unknown encoding @'..start)
    end
    local L = {}
    local E = start+1
    local obj = nil
    while string.sub(src,E,E) ~= 'e' do
        obj,E = decode(src,E,false)
        table.insert(L, obj)
    end
    return L, E+1
end

function decode_dict(src, start)
    if not start then start = 1 end
    if string.sub(src,start,start) ~= 'd' then
       error('bencode.decode_dict: Unknown encoding @'..start)
    end
    local D = {}
    local E = start+1
    local obj = nil
    while string.sub(src,E,E) ~= 'e' do
        local key, value
        key, E = decode_str(src, E)
        value, E = decode(src, E, false)
        D[key] = value
    end
    return D, E+1
end
