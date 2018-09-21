# FlashAir-libBMP

Read and write 24bpp or 16bpp uncompressed windows bitmaps from pure Lua.

## Requirement

This is SoraMame library for BMP.  
SoraMame series are IoT gadgets of FlashAir.

Tested on FlashAir W-04 v4.00.03.

## Install

SlibBMP.lua -- Copy to somewhere in Lua's search path.

## Color format of functions

bgcolor : BBBBB_GGGGGG_RRRRR (64K(16bpp) back ground color)

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
bitmap = BMP:loadFile(path, flat)  | **Read content from file and return as bitmap**<br>**path:** path+filename<br>**flat:** 1:data flat mode, 0:data array mode.<br>**bitmap:** bitmap table.
res = BMP:saveFile(path, bitmap)   | **Dump bitmap to file**<br>**path:** path+filename<br>**bitmap:** bitmap table.<br>**res:** "OK" or error message.
img = BMP:conv64K(bitmap)          | **Convert 24bit bitmap to 16 bit bitmap**<br>**img:** 64K color bitmap table.
img = BMP:conv64K(bitmap, x, y, width, height, bgcolor)| **Crop out the 24bpp bitmap and convert it to 16bpp bitmap**<br>And replace the area out of the original image with the background color.<br>**img:** 64K color bitmap table.

## Licence

[MIT](https://github.com/AoiSaya/FlashAir-libBMP/blob/master/LICENSE)

## Author

[GitHub/AoiSaya](https://github.com/AoiSaya)  
[Twitter ID @La_zlo](https://twitter.com/La_zlo)
