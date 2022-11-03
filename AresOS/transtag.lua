

local pos = construct.getWorldPosition()

keys = {}
keys[1] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} --16Byte
keys[2] = { md5( system.LocalTime() .. pos[1] .. "", false, true ) } --16Byte     
keys[3] = { md5( system.LocalTime() .. pos[2] .. "", false, true ) } --16Byte
keys[4] = { md5( system.LocalTime() .. pos[3] .. "", false, true ) } --16Byte

tagsSorted = {}
tagsRandom = {}
tagsBuffer = {}
tags = ""


local sysTime = math.floor(system.getTime() + 0.5)

local timeModulo = sysTime % 10

if not (timeModulo == timeModuloALt) and ( timeModulo == 0 or timeModulo ==  5 ) then

local a,b,c,d
local char = string.char

timeModuloALt = timeModulo

--sysTime = sysTime + saltTime
--sysTime = sysTime - (3600 * 1)?????
local sysTimeByteTable = int32ToByteTable(sysTime)

if timeModulo == 0 then

    tagsSorted[1] = XOR( keys[1], md5( { sysTimeByteTable[1], sysTimeByteTable[2],sysTimeByteTable[3],sysTimeByteTable[4], keys[1][1], keys[1][2], keys[1][3], keys[1][4], keys[1][5], keys[1][6], keys[1][7], keys[1][8], keys[1][9], keys[1][10], keys[1][11], keys[1][12], keys[1][13], keys[1][14], keys[1][15], keys[1][16] } , true, true) )
    tagsSorted[3] = XOR( keys[2], md5( { sysTimeByteTable[1], sysTimeByteTable[2],sysTimeByteTable[3],sysTimeByteTable[4], keys[2][1], keys[2][2], keys[2][3], keys[2][4], keys[2][5], keys[2][6], keys[2][7], keys[2][8], keys[2][9], keys[2][10], keys[2][11], keys[2][12], keys[2][13], keys[2][14], keys[2][15], keys[2][16] } , true, true) )
    tagsSorted[5] = XOR( keys[3], md5( { sysTimeByteTable[1], sysTimeByteTable[2],sysTimeByteTable[3],sysTimeByteTable[4], keys[3][1], keys[3][2], keys[3][3], keys[3][4], keys[3][5], keys[3][6], keys[3][7], keys[3][8], keys[3][9], keys[3][10], keys[3][11], keys[3][12], keys[3][13], keys[3][14], keys[3][15], keys[3][16] } , true, true) )
    tagsSorted[7] = XOR( keys[4], md5( { sysTimeByteTable[1], sysTimeByteTable[2],sysTimeByteTable[3],sysTimeByteTable[4], keys[4][1], keys[4][2], keys[4][3], keys[4][4], keys[4][5], keys[4][6], keys[4][7], keys[4][8], keys[4][9], keys[4][10], keys[4][11], keys[4][12], keys[4][13], keys[4][14], keys[4][15], keys[4][16] } , true, true) )

else

    tagsSorted[2] = XOR( keys[1], md5( { sysTimeByteTable[1], sysTimeByteTable[2],sysTimeByteTable[3],sysTimeByteTable[4], keys[1][1], keys[1][2], keys[1][3], keys[1][4], keys[1][5], keys[1][6], keys[1][7], keys[1][8], keys[1][9], keys[1][10], keys[1][11], keys[1][12], keys[1][13], keys[1][14], keys[1][15], keys[1][16] } , true, true) )
    tagsSorted[4] = XOR( keys[2], md5( { sysTimeByteTable[1], sysTimeByteTable[2],sysTimeByteTable[3],sysTimeByteTable[4], keys[2][1], keys[2][2], keys[2][3], keys[2][4], keys[2][5], keys[2][6], keys[2][7], keys[2][8], keys[2][9], keys[2][10], keys[2][11], keys[2][12], keys[2][13], keys[2][14], keys[2][15], keys[2][16] } , true, true) )
    tagsSorted[6] = XOR( keys[3], md5( { sysTimeByteTable[1], sysTimeByteTable[2],sysTimeByteTable[3],sysTimeByteTable[4], keys[3][1], keys[3][2], keys[3][3], keys[3][4], keys[3][5], keys[3][6], keys[3][7], keys[3][8], keys[3][9], keys[3][10], keys[3][11], keys[3][12], keys[3][13], keys[3][14], keys[3][15], keys[3][16] } , true, true) )
    tagsSorted[8] = XOR( keys[4], md5( { sysTimeByteTable[1], sysTimeByteTable[2],sysTimeByteTable[3],sysTimeByteTable[4], keys[4][1], keys[4][2], keys[4][3], keys[4][4], keys[4][5], keys[4][6], keys[4][7], keys[4][8], keys[4][9], keys[4][10], keys[4][11], keys[4][12], keys[4][13], keys[4][14], keys[4][15], keys[4][16] } , true, true) )

end


--randomizing order
tagsBuffer = tagsSorted
--j = 1

for i = 8, 1, -1 do

    tagsRandom[9 - i] = tagsBuffer[math.random(1,i)]
    --j = j + 1

end


--converting into Transponder-Element dataformat
for i = 1 , 8 do

    local tmp = tagsRandom[i]
    tagsRandom[i] = ""
    
    for j = 1 , 16 do
    
        tagsRandom[i] = tagsRandom[i] .. char(tmp[j])
    
    end
    
end

tags = base64M(tagsRandom[1]) .. ","

for i = 2 , 8 do

    tags = tags .. "," ..  base64M(tagsRandom[i])

end
 

transponder.setTaglist(tags)
transponder.deactivate()
transponder.activate()

end



--library.start()


function XOR(a,b)

for i = 1, #a do

    a[i] = a[i] ~ b[i]

end

return a

end

local bsM = { [0] =
         'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
         'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
         'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
         'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','-',
}
local byte, char, rep = string.byte, string.char, string.rep
-- Leads to overflow after 325 runs, really high performance
-- Test-String = "This is a long ass string that is used for encoding Tasks. ÄÖwill be there too!"
function base64M(s)
local pad = 2 - ((#s-1) % 3)
s = (s..rep('\0', pad)):gsub("...", function(cs)
    local a, b, c = byte(cs, 1, 3)
    return bsM[a>>2] .. bsM[(a&3)<<4|b>>4] .. bsM[(b&15)<<2|c>>6] .. bsM[c&63]
end)
return s:sub(1, #s-pad) .. rep('=', pad)
end

-- shift amounts
local s = {
7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20,
4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
}

-- constants
local K = {
0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391,
}

local function leftRotate(x, c)
return (x << c) | (x >> (32-c))
end

local function getInt(byteArray, n)
return (byteArray[n+3]<<24) + (byteArray[n+2]<<16) + (byteArray[n+1]<<8) + byteArray[n]
end

--- converts 32bit integer n to a little endian hex representation
-- @tparam integer n
local function lE(n)
local s = ''
for i = 0, 3 do
s = ('%s%02x'):format(s, (n>>(i*8))&0xff)
end
return s
end

--- md5
-- @tparam string message
function md5(message,byteTableInput,byteTableOutput)
local a0, b0, c0, d0 = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476

local bytes

if byteTableInput then

bytes = message

else

bytes = {message:byte(1, -1)}

end


-- insert 1 bit (and the rest of the byte)
table.insert(bytes, 0x80)

-- pad with zeros until we have *just enough*
local p = #bytes%64
if p > 56 then
p = p - 64
end
for _ = p+1, 56 do
table.insert(bytes, 0)
end

-- insert the initial message length, in little-endian
local len = ((#message)<<3)&0xffffffffffffffff -- length in bits
for i = 0, 7 do
table.insert(bytes, (len>>(i*8))&0xff)
end


for i = 0, #bytes//64-1 do
local a, b, c, d = a0, b0, c0, d0
for j = 0, 63 do
  local F, g
  -- permutate
  if j <= 15 then
    F = (b & c) | (~b & d)
    g = j
  elseif j <= 31 then
    F = (d & b) | (~d & c)
    g = (5*j + 1) & 15
  elseif j <= 47 then
    F = b ~ c ~ d
    g = (3*j + 5) & 15
  else
    F = c ~ (b | ~d)
    g = (7*j) & 15
  end

  F = (F + a + K[j+1] + getInt(bytes, i*64+g*4+1))&0xffffffff
  -- shuffle
  a = d
  d = c
  c = b
  b = (b + leftRotate(F, s[j+1]))&0xffffffff
end
-- update internal state
a0 = (a0 + a)&0xffffffff
b0 = (b0 + b)&0xffffffff
c0 = (c0 + c)&0xffffffff
d0 = (d0 + d)&0xffffffff
end


if byteTableOutput then


--erhält nicht die Bitreihenfolge!!!!!!
local a,b,c,d = int32ToByteTable(a0), int32ToByteTable(b0), int32ToByteTable(c0), int32ToByteTable(d0)
return { a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4], c[1], c[2], c[3], c[4], d[1], d[2], d[3], d[4] }

else

-- lua doesn't support any other byte strings. Could convert to a wacky string but this is more printable.
return lE(a0)..lE(b0)..lE(c0)..lE(d0)

end

end

function int32ToByteTable(i32)

local b3, b2, b1, b0, i16, i24

b3 = math.floor(i32/16777216)
i24 = i32 % 16777216

b2 = math.floor(i24/65536)
i16 = i24 % 65536 

b1 = math.floor(i16/256)
b0 = i16 % 256 

return { b3, b2, b1, b0 }

end