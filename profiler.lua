
--������
--lua��������ģ��


local os = require("os")


-- define module
local profiler = {}

-- start profiling
function profiler:start(mode)

    -- ��ʼ������
    self._REPORTS           = {}
    self._REPORTS_BY_TITLE  = {}

    -- ��¼��ʼʱ��
    self._STARTIME = os.clock()

    -- ��ʼhook��ע��handler����¼call��return�¼�
    debug.sethook(profiler._profiling_handler, 'cr', 0)
end


-- stop profiling
function profiler:stop(mode,funp)
	funp = funp or print
    -- ��¼����ʱ��
    self._STOPTIME = os.clock()

    -- ֹͣhook
    debug.sethook()

    -- ��¼�ܺ�ʱ
    local totaltime = self._STOPTIME - self._STARTIME

    -- ���򱨸�
    table.sort(self._REPORTS, function(a, b)
        return a.totaltime > b.totaltime
    end)

    -- ��ʽ���������
	local pstr = string.format("%6s| %6s| %7s| %10s","time", "percent", "count", "title")
	funp(pstr)
    for _, report in ipairs(self._REPORTS) do

        -- calculate percent
        local percent = (report.totaltime / totaltime) * 100
        if percent < 1 then
            break
        end

        -- trace
		local pstr = string.format("%6.3f| %6.2f%%| %7d| %s",report.totaltime, percent, report.callcount, report.title)

		funp(pstr)
    end
end


-- profiling call
function profiler:_profiling_call(funcinfo)

    -- ��ȡ��ǰ������Ӧ�ı��棬������������ʼ����
    local report = self:_func_report(funcinfo)
    assert(report)

    -- ��¼�����������ʼ�����¼�
    report.calltime    = os.clock()

    -- �ۼ���������ĵ��ô���
    report.callcount   = report.callcount + 1

end

-- profiling return
function profiler:_profiling_return(funcinfo)

    -- ��¼��������ķ���ʱ��
    local stoptime = os.clock()

    -- ��ȡ��ǰ�����ı���
    local report = self:_func_report(funcinfo)
    assert(report)

    -- ������ۼӵ�ǰ�����ĵ�����ʱ��
    if report.calltime and report.calltime > 0 then
		report.totaltime = report.totaltime + (stoptime - report.calltime)
        report.calltime = 0
	end
end

-- the profiling handler
function profiler._profiling_handler(hooktype)

    -- ��ȡ��ǰ������Ϣ
    local funcinfo = debug.getinfo(2, 'nS')

    -- �����¼����ͣ��ֱ���
    if hooktype == "call" then
        profiler:_profiling_call(funcinfo)
    elseif hooktype == "return" then
        profiler:_profiling_return(funcinfo)
    end
end

-- get the function title
function profiler:_func_title(funcinfo)

    -- check
    assert(funcinfo)

    -- the function name
    local name = funcinfo.name or 'anonymous'

    -- the function line
    local line = string.format("%d", funcinfo.linedefined or 0)

    -- the function source
    local source = funcinfo.short_src or 'C_FUNC'
    --if os.isfile(source) then
    --    source = path.relative(source, xmake._PROGRAM_DIR)
    --end

    -- make title
    return string.format("%-10s: %s: %s", name, source, line)
end

-- get the function report
function profiler:_func_report(funcinfo)

    -- get the function title
    local title = self:_func_title(funcinfo)

    -- get the function report
    local report = self._REPORTS_BY_TITLE[title]
    if not report then

        -- init report
        report =
        {
            title       = self:_func_title(funcinfo)
        ,   callcount   = 0
        ,   totaltime   = 0
        }

        -- save it
        self._REPORTS_BY_TITLE[title] = report
        table.insert(self._REPORTS, report)
    end

    -- ok?
    return report
end

return profiler
