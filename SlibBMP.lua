-----------------------------------------------
-- SoraMame libraly of BMP for W4.00.03
-- Copyright (c) 2018, Saya
-- Original by max1220/lua-bitmap, Copyright (c) 2017 Max
-- 2018/09/09 rev.0.06 Saya breakpoint remove
-----------------------------------------------
local BMP = {}

function BMP:readWord(data, offset)
	return data:byte(offset+1)*256 + data:byte(offset)
end

function BMP:readDword(data, offset)
	return self:readWord(data, offset+2)*65536 + self:readWord(data, offset)
end

function BMP:writeWord(data, offset, value)
	local s1 = offset>1 and data:sub(1, offset-1) or ""
	local s2 = string.char(bit32.extract(value,0,8), bit32.extract(value,8,8))
	local s3 = offset+1<#data and data:sub(offset+2,-1) or ""
	return s1 .. s2 .. s3
end

function BMP:writeDword(data, offset, value)
	local s = self:writeWord(data, offset+2, bit32.extract(value,16,16))
	return self:writeWord(s, offset, bit32.extract(value,0,16))
end

function BMP:loadFile(path, flat)
	local i
	flat = flat or 0 -- 1:data flat mode, 0:data array mode

	local fp = io.open(path, "rb")
	if not fp then
		return nil, "Can't open file!"
	end
	local header = fp:read(54)
	fp:close()

	if not self:readDword(header, 1) == 0x4D42 then -- Bitmap "magic" header
		return nil, "Bitmap magic not found"
	elseif self:readWord(header, 29) ~= 24
	   and self:readWord(header, 29) ~= 16 then -- Bits per pixel
		return nil, "Only 24bpp bitmaps supported"
	elseif self:readDword(header, 31) ~= 0 then -- Compression
		return nil, "Only uncompressed bitmaps supported"
	end

	local bitmap  = {}
	local offset  = self:readDword(header, 11)
	local data	  = {}
	bitmap.header = header
	bitmap.width  = self:readDword(header, 19)
	bitmap.height = self:readDword(header, 23)
	bitmap.bit	  = self:readWord(header, 29)
	bitmap.flat	  = flat

	local fp = io.open(path, "rb")
	if not fp then
	return nil, "Can't open file!"
	end

	fp:seek("set", offset)
	local num = bitmap.width * bitmap.bit / 8
	local inc = (-num)%4
	local data = {}
	for i=1, bitmap.height do
		data[i] = fp:read(num)
		fp:seek("cur",inc)
	end
	fp:close()

   	if flat==1 then
		bitmap.data = table.concat(data)
	else
		bitmap.data = data
	end
	collectgarbage()

	return bitmap
end

function BMP:saveFile(path, bitmap)
	local i
	local fp = io.open(path, "wb")
	if not fp then
	return nil, "Can't open file!"
	end

	local num = bitmap.width * bitmap.bit / 8
	local gap = string.rep("\0", (-num)%4)

	fp:write(bitmap.header)
	for i=1, bitmap.height do
  	  fp:write(bitmap.data[i])
	  if gap then fp:write(gap); end
	  collectgarbage()
	end
	fp:close()
	collectgarbage()

	return 1
end

function BMP:conv64K(bitmap, ...)
	local x1, x2, y1, y2, ws
	local i, j, cx, cy, ch, cl, idx
	local data, b, g, r
	local bgcol, heaer, line
	local cols = {}
	local img = {}
	local bw = bitmap.width
	local bh = bitmap.height
	local bb = bitmap.bit/8
	local flat = bitmap.flat
	local bx = bit32.extract
	local dstData={}

	if ...==nil then
		x, y, w, h, bg = 0, 0, bw, bh, 0x0000
	else
		x, y, w, h, bg = ...
	end

	local ws = w + (-w)%4
	bgcol  = string.char(bx(bg,8,8), bx(bg,0,8))
	header = bitmap.header
	header = self:writeDword(header, 3, self:readDword(header,11) + ws*h*2) -- bfSize
	header = self:writeDword(header, 29, 16) -- biBitCount
	header = self:writeDword(header, 35, ws*h*2) -- biSizeImage

	x1 = (x<0) and 0 or x
	x2 = (x+w>=bw) and bw-1 or x+w-1
	y1 = (y<0) and 0 or y
	y2 = (y+h>=bh) and bh-1 or y+h-1

	if y1>=bh or y2<0 or x1>=bw or x2<0 then
		for i=1, h do
			dstData[i] = string.rep(bgcol,w)
		end
		return img
	end

	i = 1
	for cy=y, -1 do
		dstData[i] = string.rep(bgcol,w)
		i = i+1
	end
	for cy=y1, y2 do
		if x<0 then
			line = string.rep(bgcol,-x)
		else
			line = ""
		end
		idx = 3*x1+1
		if flat==0 then
			data = bitmap.data[cy+1]
		else
			data = bitmap.data:sub(cy*bw*bb+1,(cy+1)*bw*bb)
		end
		for i=0, x2-x1 do
			b,g,r = data:byte(idx,idx+2)
			ch=bx(b,3,5)*8+bx(g,5,3)
			cl=bx(g,2,3)*32+bx(r,3,5)
			cols[i*2+1],cols[i*2+2]=ch,cl
			idx=idx+3
		end
		line = line .. string.char(table.unpack(cols))
		if x2-x+1 < w then
			line = line .. string.rep(bgcol,w-(x2-x+1))
		end
		dstData[i] = line
		i = i+1
		collectgarbage()
	end
	for j=i, h do
		dstData[j] = string.rep(bgcol,w)
	end
	collectgarbage()

	img.header = header
	img.width  = w
	img.height = h
	img.bit	   = 16
	img.flat   = flat
	if flat==1 then
		img.data = table.concat(dstData)
	else
		img.data = dstData
	end
	collectgarbage()

	return img
end

collectgarbage()
return BMP
