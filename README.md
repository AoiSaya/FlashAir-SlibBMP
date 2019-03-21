# FlashAir-libBMP

Read and write 24bpp or 16bpp uncompressed windows bitmaps from pure Lua.

update at 2019/3/21:Suport 64K part load to save memory and direction(x,y) to udside down

## Requirement

This is SoraMame library for BMP.  
SoraMame series are IoT gadgets of FlashAir.

Tested on FlashAir W-04 v4.00.03.

## Install

SlibBMP.lua -- Copy to somewhere in Lua's search path.

## Color format of functions

bgcolor : BBBBB_GGGGGG_RRRRR (64K(16bpp) background color)

## Internal bitmap data format

    bitmap  = {}  
    bitmap.header -- copyed from BMP header  
    bitmap.width  -- bitmap width  
    bitmap.height -- bitmap height  
    bitmap.bit    -- bpp, 24 or 16(BBBBB_GGGGGG_RRRRR format)  
    bitmap.flat   -- 1:Flat(Stuffing without leaving spaces for small image), 0:Stored in an array for each line.  
    bitmap.data   -- bitmap data  

## Usage

command | description
--- | ---
bitmap,mes = BMP:loadFile(path, flat)  | **Read content from file and return as bitmap**<br>**bitmap:** bitmap table<br>**mes:** error message, if bitmap is nil<br><br>**path:** path+filename<br>**flat:** 1:data flat mode, 0:data array mode
res = BMP:saveFile(path, bitmap)       | **Dump bitmap to file**<br>**res:** "OK" or error message<br><br>**path:** path+filename<br>**bitmap:** bitmap table
img,mes = BMP:conv64K(bitmap or path)  | **Convert 24bit bitmap to 16 bpp bitmap**<br>If given path, read content from file.<br>**img:** 64K color bitmap table<br>**mes:** error message, if bitmap is nil<br><br>**bitmap:** bitmap table<br>**path:** path+filename
img,mes = BMP:conv64K(bitmap or path,<br> x, y, width, height, bgcolor)| **Crop out the 24bpp bitmap and convert it to 16bpp bitmap**<br>And replace the area out of the original image with the background color.<br>If given path, read content from file.<br>**img:** 64K color bitmap table<br>**mes:** error message, if bitmap is nil<br><br>**bitmap:** bitmap table<br>**path:** path+filename

## Licence

[MIT](https://github.com/AoiSaya/FlashAir-libBMP/blob/master/LICENSE)

## Author

[GitHub/AoiSaya](https://github.com/AoiSaya)  
[Twitter ID @La_zlo](https://twitter.com/La_zlo)
