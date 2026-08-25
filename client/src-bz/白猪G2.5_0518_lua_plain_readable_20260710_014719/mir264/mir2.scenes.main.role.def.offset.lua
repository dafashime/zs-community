local def = {}
local cBigFireDragonAppr = 240

function def.getOffset(appr)
	if appr == cBigFireDragonAppr then
		return 0
	elseif appr == 142 then
		return 1130
	end

	local ret
	local race = math.modf(appr / 10)
	local pos = math.mod(appr, 10)

	if race == 0 then
		ret = pos * 280
	elseif race == 1 then
		ret = pos * 230
	elseif race == 2 or race == 3 or race >= 7 and race <= 12 then
		ret = pos * 360
	elseif race == 4 then
		if pos == 1 then
			ret = 600
		else
			ret = pos * 360
		end
	elseif race == 5 then
		ret = pos * 430
	elseif race == 6 then
		ret = pos * 440
	elseif race == 13 then
		if pos == 2 then
			ret = 440
		elseif pos == 3 then
			ret = 550
		else
			ret = pos * 360
		end
	elseif race == 14 then
		ret = pos * 360
	elseif race == 15 then
		ret = pos * 360
	elseif race == 16 then
		ret = pos * 360
	elseif race == 17 then
		if pos == 2 then
			ret = 1260
		else
			ret = pos * 350
		end
	elseif race == 18 then
		if pos == 0 then
			ret = 0
		elseif pos == 1 then
			ret = 520
		elseif pos == 2 then
			ret = 950
		elseif pos == 3 then
			ret = 1574
		elseif pos == 4 then
			ret = 1934
		elseif pos == 5 then
			ret = 2294
		elseif pos == 6 then
			ret = 2654
		elseif pos == 7 then
			ret = 3014
		end
	elseif race == 19 then
		if pos == 0 then
			ret = 0
		elseif pos == 1 then
			ret = 370
		elseif pos == 2 then
			ret = 810
		elseif pos == 3 then
			ret = 1250
		elseif pos == 4 then
			ret = 1630
		elseif pos == 5 then
			ret = 2010
		elseif pos == 6 then
			ret = 2390
		end
	elseif race == 20 then
		if pos == 0 then
			ret = 0
		elseif pos == 1 then
			ret = 360
		elseif pos == 2 then
			ret = 720
		elseif pos == 3 then
			ret = 1080
		elseif pos == 4 then
			ret = 1440
		elseif pos == 5 then
			ret = 1800
		elseif pos == 6 then
			ret = 2350
		elseif pos == 7 then
			ret = 3060
		end
	elseif race == 21 then
		if pos == 0 then
			ret = 0
		elseif pos == 1 then
			ret = 460
		elseif pos == 2 then
			ret = 820
		elseif pos == 3 then
			ret = 1180
		elseif pos == 4 then
			ret = 1540
		elseif pos == 5 then
			ret = 1900
		elseif pos == 6 then
			ret = 2260
		elseif pos == 7 then
			ret = 2440
		elseif pos == 8 then
			ret = 2570
		elseif pos == 9 then
			ret = 2700
		end
	elseif race == 22 then
		if pos == 0 then
			ret = 0
		elseif pos == 1 then
			ret = 430
		elseif pos == 2 then
			ret = 1290
		elseif pos == 3 then
			ret = 1810
		end
	elseif race == 23 then
		if pos == 0 then
			ret = 680
		elseif pos == 1 then
			ret = 4460
		elseif pos == 2 then
			ret = 4100
		elseif pos == 3 then
			ret = 3750
		elseif pos == 4 then
			ret = 2950
		elseif pos == 5 then
			ret = 2610
		elseif pos == 6 then
			ret = 3290
		elseif pos == 7 then
			ret = 1180
		elseif pos == 8 then
			ret = 0
		elseif pos == 9 then
			ret = 340
		end
	elseif race == 24 then
		if pos == 1 then
			ret = 0
		elseif pos == 2 then
			ret = 510
		elseif pos == 3 then
			ret = 320
		elseif pos == 4 then
			ret = 300
		elseif pos == 5 then
			ret = 1020
		elseif pos == 6 then
			ret = 1020
		elseif pos == 7 then
			ret = 1090
		end
	elseif race == 25 then
		if pos == 0 then
			ret = 0
		elseif pos == 1 then
			ret = 510
		elseif pos == 2 then
			ret = 1020
		elseif pos == 3 then
			ret = 1370
		elseif pos == 4 then
			ret = 1720
		elseif pos == 5 then
			ret = 2070
		elseif pos == 6 then
			ret = 2740
		elseif pos == 7 then
			ret = 3780
		elseif pos == 8 then
			ret = 3820
		elseif pos == 9 then
			ret = 4170
		end
	elseif race == 26 then
		if pos == 0 then
			ret = 0
		elseif pos == 1 then
			ret = 340
		elseif pos == 2 then
			ret = 680
		elseif pos == 3 then
			ret = 1190
		elseif pos == 4 then
			ret = 2100
		elseif pos == 5 then
			ret = 2440
		elseif pos == 6 then
			ret = 2540
		elseif pos == 7 then
			ret = 3570
		end
	elseif race == 27 then
		if pos == 5 then
			ret = 1560
		elseif pos == 6 then
			ret = 1910
		end
	elseif race == 28 then
		if pos == 1 then
			ret = 0
		elseif pos == 2 then
			ret = 600
		end
	elseif race == 29 then
		if pos == 0 then
			ret = 0
		elseif pos == 1 then
			ret = 720
		end
	elseif race == 30 then
		if pos == 0 then
			ret = 190
		elseif pos == 1 then
			ret = 0
		end
	elseif race == 32 then
		if pos == 0 then
			ret = 0
		elseif pos == 1 then
			ret = 440
		elseif pos == 2 then
			ret = 820
		elseif pos == 3 then
			ret = 2590
		elseif pos == 4 then
			ret = 3500
		elseif pos == 5 then
			ret = 3930
		elseif pos == 6 then
			ret = 2680
		elseif pos == 7 then
			ret = 2790
		elseif pos == 8 then
			ret = 2900
		elseif pos == 9 then
			ret = 2980
		end
	elseif race == 33 then
		if pos == 0 then
			ret = 3060
		elseif pos == 1 then
			ret = 3140
		elseif pos == 2 then
			ret = 3220
		elseif pos == 3 then
			ret = 3300
		elseif pos == 4 then
			ret = 4440
		elseif pos == 5 then
			ret = 4370
		elseif pos == 6 then
			ret = 4397
		elseif pos == 7 then
			ret = 1360
		end
	elseif race == 31 then
		if pos == 0 then
			ret = 360
		elseif pos == 1 then
			ret = 720
		end
	elseif race == 34 then
		if pos == 1 then
			ret = 0
		elseif pos == 2 then
			ret = 720
		elseif pos == 3 then
			ret = 1160
		elseif pos == 4 then
			ret = 1770
		elseif pos == 5 then
			ret = 1780
		elseif pos == 6 then
			ret = 1790
		elseif pos == 7 then
			ret = 1820
		elseif pos == 8 then
			ret = 3250
		elseif pos == 9 then
			ret = 3310
		end
	elseif race == 35 then
		if pos == 0 then
			ret = 0
		elseif pos == 1 then
			ret = 680
		elseif pos == 2 then
			ret = 1030
		end
	elseif race == 37 then
		if pos == 0 then
			ret = 2240
		elseif pos == 1 then
			ret = 0
		elseif pos == 2 then
			ret = 400
		elseif pos == 3 then
			ret = 960
		elseif pos == 4 then
			ret = 1360
		elseif pos == 5 then
			ret = 1440
		elseif pos == 6 then
			ret = 1840
		end
	elseif race == 80 then
		if pos == 0 then
			ret = 0
		elseif pos == 1 then
			ret = 80
		elseif pos == 2 then
			ret = 300
		elseif pos == 3 then
			ret = 301
		elseif pos == 4 then
			ret = 302
		elseif pos == 5 then
			ret = 320
		elseif pos == 6 then
			ret = 321
		elseif pos == 7 then
			ret = 322
		end
	elseif race == 90 then
		if pos == 0 then
			ret = 80
		elseif pos == 1 then
			ret = 168
		elseif pos == 2 then
			ret = 184
		elseif pos == 3 then
			ret = 200
		end
	elseif race == 255 then
		if pos == 0 then
			ret = 5870
		elseif pos == 1 then
			ret = 6680
		elseif pos == 2 then
			ret = 1050
		elseif pos == 3 then
			ret = 2230
		elseif pos == 4 then
			ret = 3710
		elseif pos == 5 then
			ret = 3190
		elseif pos == 6 then
			ret = 4390
		elseif pos == 7 then
			ret = 1420
		elseif pos == 8 then
			ret = 2670
		elseif pos == 9 then
			ret = 1860
		end
	elseif race == 254 then
		if pos == 0 then
			ret = 4750
		elseif pos == 1 then
			ret = 5270
		elseif pos == 2 then
			ret = 170
		end
	elseif race == 255 then
		if pos == 0 then
			ret = 0
		elseif pos == 1 then
			ret = 320
		elseif pos == 2 then
			ret = 640
		elseif pos == 3 then
			ret = 960
		elseif pos == 4 then
			ret = 1280
		elseif pos == 5 then
			ret = 1600
		elseif pos == 6 then
			ret = 1936
		elseif pos == 7 then
			ret = 2320
		end
	end

	return ret
end

function def.getNpcOffset(appr)
	local ret = 0

	if appr >= 0 and appr <= 22 then
		ret = appr * 60
	elseif appr == 23 then
		ret = 1380
	elseif appr == 27 or appr == 32 then
		ret = appr * 60 + 30
	elseif appr == 26 or appr >= 28 and appr <= 31 or appr >= 33 and appr <= 41 then
		ret = (appr + 1) * 60
	elseif appr == 42 or appr == 43 then
		ret = 2580
	elseif appr >= 44 and appr <= 47 then
		ret = 2640
	elseif appr >= 48 and appr <= 50 then
		ret = (appr - 3) * 60
	elseif appr == 51 then
		ret = 2880
	elseif appr == 52 then
		ret = 2960
	elseif appr == 53 then
		ret = 2980
	elseif appr >= 60 and appr <= 67 or appr == 69 then
		ret = 3060 + (appr - 60) * 60
	elseif appr >= 70 and appr <= 75 then
		ret = 3780 + (appr - 70) * 10
	elseif appr >= 80 and appr <= 85 then
		ret = 3780 + (appr - 80) * 10
	elseif appr >= 90 and appr <= 92 then
		ret = 3750 + (appr - 90) * 10
	elseif appr == 93 then
		ret = 3840
	elseif appr == 94 then
		ret = 3900
	elseif appr >= 95 and appr <= 97 then
		ret = 3960 + (appr - 95) * 20
	elseif appr >= 98 and appr <= 100 then
		ret = 4060 + (appr - 98) * 60
	elseif appr == 101 then
		ret = 4240
	elseif appr == 102 then
		ret = 4490
	elseif appr == 103 then
		ret = 4500
	elseif appr == 104 then
		ret = 4510
	elseif appr == 105 then
		ret = 4520
	elseif appr == 106 then
		ret = 4530
	elseif appr == 107 then
		ret = 4540
	elseif appr == 108 then
		ret = 4560
	elseif appr == 109 then
		ret = 4630
	elseif appr == 110 then
		ret = 4640
	elseif appr == 111 then
		ret = 4650
	elseif appr == 112 then
		ret = 4660
	elseif appr == 113 then
		ret = 4670
	elseif appr == 114 then
		ret = 4680
	elseif appr == 121 then
		ret = 0
	elseif appr == 122 then
		ret = 70
	elseif appr == 123 then
		ret = 140
	elseif appr == 124 then
		ret = 210
	elseif appr == 125 then
		ret = 280
	elseif appr == 126 then
		ret = 350
	elseif appr == 127 then
		ret = 420
	elseif appr == 128 then
		ret = 490
	elseif appr == 129 then
		ret = 560
	elseif appr == 130 then
		ret = 2040
	elseif appr == 131 then
		ret = 2100
	elseif appr == 146 then
		ret = 700
	elseif appr == 153 then
		ret = 740
	elseif appr == 154 then
		ret = 810
	elseif appr == 155 then
		ret = 820
	elseif appr == 156 then
		ret = 830
	elseif appr == 157 then
		ret = 840
	elseif appr == 158 then
		ret = 850
	elseif appr == 159 then
		ret = 860
	elseif appr == 160 then
		ret = 980
	elseif appr == 161 then
		ret = 870
	elseif appr == 162 then
		ret = 900
	elseif appr == 163 then
		ret = 930
	elseif appr == 164 then
		ret = 2650
	elseif appr == 165 then
		ret = 860
	elseif appr == 166 then
		ret = 1160
	elseif appr == 167 then
		ret = 1680
	elseif appr == 168 then
		ret = 970
	elseif appr == 169 then
		ret = 630
	elseif appr == 170 then
		ret = 1020
	elseif appr == 171 then
		ret = 1030
	elseif appr == 172 then
		ret = 3760
	elseif appr == 173 then
		ret = 600
	elseif appr == 174 then
		ret = 1061
	elseif appr == 175 then
		ret = 1070
	elseif appr == 176 then
		ret = 1071
	end

	return ret
end

return def
