local profile = require("profiler")



--����1
function test1()
	local sum = 0
	for i = 1,50000 do
		sum = sum +1
	end
end

--����2
function test2()
	local sum = 0
	for i = 1,100000 do
		sum = sum +1
	end
end


--��ʼ�������� ��ռ��һ��������
profile:start()

test1()
test1()
test2()

--���� ��������
--���Զ����Լ�print����
profile:stop(print)
--profile:stop()
