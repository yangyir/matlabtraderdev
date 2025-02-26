function [datefrom,dateto,resstruct] = irene_findactiveperiod(varargin)
%
p = inputParser;
p.KeepUnmatched = true;p.CaseSensitive = false;
p.addParameter('code','',@ischar);
p.addParameter('frequency','30m',@ischar);
p.parse(varargin{:});

code = p.Results.code;
freq = p.Results.frequency;

[~,resstruct] = charlotte_loaddata('futcode',code,'frequency',freq);
dtstart = getlastbusinessdate(resstruct.px(1,1));
if hour(resstruct.px(end,1)) < 9
    dtsend = getlastbusinessdate(resstruct.px(end,1));
else
    dtsend = floor(resstruct.px(end,1));
end
if isfx(code)
    datefrom = dtstart;
    dateto = dtsend;
    return
else
    dts = gendates('fromdate',dtstart,'todate',dtsend);
    for i = 1:length(dts)
        fn_i = [getenv('datapath'),'activefutures\activefutures_',datestr(dts(i),'yyyymmdd'),'.txt'];
        data_i = cDataFileIO.loadDataFromTxtFile(fn_i);
        found_i = sum(strcmpi(data_i,code)) > 0;
        if found_i
            datefrom = dts(i);
            break
        end
    end
    if ~found_i
        if strcmpi(code,'T1512')
            datefrom = 736188;
            dateto = 736279;
        elseif strcmpi(code,'T1603')
            datefrom = 736280;
            dateto = 736362;
        elseif strcmpi(code,'T1606')
            datefrom = 736363;
            dateto = 736453;
        elseif strcmpi(code,'T1609')
            datefrom = 736454;
            dateto = 736549;
        elseif strcmpi(code,'T1612')
            datefrom = 736550;
            dateto = 736641;
        else
            datefrom = [];
            dateto = [];
        end
        return
    end
    %
    if i == length(dts)
        dateto = dts(end);
    else
        for j = i+1:length(dts)
            fn_j = [getenv('datapath'),'activefutures\activefutures_',datestr(dts(j),'yyyymmdd'),'.txt'];
            data_j = cDataFileIO.loadDataFromTxtFile(fn_j);
            dateto = dts(j);
            if sum(strcmpi(data_j,code)) == 0
                dateto = dts(j-1);
                break
            end
        end
    %
    
end


end