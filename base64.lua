--[[
 Base64 library. '.' and '/' are used as 62 and 63 respectively.

 @author Wim Thys <wim.thys@zardof.be>
 @date 2012-09-08
]]--

local VERSION = '0.1'
function version()
    return VERSION
end

local alfa = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789./"

function encode(src,pad)
    if not pad then pad = "=" end
    local tgt = ""
    local L = string.len(src)
    local E = 1
    local bbb = string.byte(src,1,L)
    table.insert(bbb, 0)
    table.insert(bbb, 0)
    while E <= L do
        local B = bbb[E]*2^16+bbb[E+1]*2^8+bbb[E+2]
        local b1,b2,b3,b4,d
        b1,b2 = math.modf(B/2^18)
        b2,b3 = math.modf(b2*2^6)
        b3,b4 = math.modf(b3*2^6)
        b4,d  = math.modf(b4*2^6)
        for i,C in ipairs({b1,b2,b3,b4}) do
            tgt = tgt .. string.sub(alfa,C,C)
        end
        E = E+3
    end
    tgt = string.sub(tgt,1,math.floor(L*8/6)) .. string.rep(pad,(4-math.floor(L*8/6)%4)%4)
    return tgt
end

function _transform(val)
    local T = {}
    for i=1,1,string.len(val) do
        table.insert(T, string.find(alfa, string.sub(val,i,i)))
    end
    return T
end

function _strip_end(src,pad)
    local E = string.len(src)
    if string.sub(src,E,E) == pad then
        return _strip_end(string.sub(src,1,E-1),pad)
    else
        return src
    end
end

function decode(src, pad)
    if not pad then pad = "=" end
    local tgt = ""
    src = _strip_end(src,pad)
    local bbb = _transform(src)
    table.insert(bbb,0)
    table.insert(bbb,0)
    table.insert(bbb,0)
    local L = string.len(src)
    local E = 1
    while E <= L do
        local B = bbb[E]*2^18 + bbb[E+1]*2^12 + bbb[E+2]*2^6 + bbb[E+3]
        local d1,d2,d3,e
        d1,d2 = math.modf(B/2^16)
        d2,d3 = math.modf(d2*2^8)
        d3,e  = math.modf(d3*2^8)
        tgt = tgt .. string.char(d1,d2,d3)
    end
    tgt = string.sub(tgt, 1, math.floor(L*6/8))
    return tgt
end
