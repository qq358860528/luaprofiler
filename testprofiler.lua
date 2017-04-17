local profile = require("profiler")



--函数1
function test1()
	local sum = 0
	for i = 1,50000 do
		sum = sum +1
	end
end

--函数2
function test2()
	local sum = 0
	for i = 1,100000 do
		sum = sum +1
	end
end


--开始性能剖析 会占用一定的消耗
profile:start()

test1()
test1()
test2()

--结束 产出报告
--可以定制自己print函数
profile:stop(print)
--profile:stop()
