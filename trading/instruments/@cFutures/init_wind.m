function [] = init_wind(obj,w)
    ctpstr = obj.code_ctp;
    if isempty(ctpstr)
        return
    end

    if nargin < 2, return; end

    if ~isa(w,'windmatlab')
        error('cFutures:init:invalid wind connection')
    end

    wind_fields = {'contractmultiplier',...
    'mfprice',...
    'ftdate',...
    'lasttrade_date',...
    'lastdelivery_date',...
    'thours',...
    'margin'};

[wdata,~,~,~,errorid,~] = w.wss(obj.code_wind,wind_fields);

if errorid ~= 0
    error('cFutures:init_wind failed')
end

ticksizeStr = wdata{1,2};
idxStr = strfind(ticksizeStr,'人民币');
tickSize = str2double(ticksizeStr(1:idxStr-1));

    obj.contract_size = wdata{1,1};
    obj.tick_size = tickSize;
    obj.tick_value = obj.contract_size*obj.tick_size;
    
    obj.first_trade_date1 = datenum(wdata{1,3});
    obj.first_trade_date2 = datestr(obj.first_trade_date1,'yyyy-mm-dd');
    obj.last_trade_date1 = datenum(wdata{1,4});
    obj.last_trade_date2 = datestr(obj.last_trade_date1,'yyyy-mm-dd');
    
    obj.first_notice_date1 = obj.last_trade_date1;
    obj.first_notice_date2 = datestr(obj.first_notice_date1,'yyyy-mm-dd');
    
    obj.first_dlv_date1 = dateadd(obj.last_trade_date1,'1b');
    obj.first_dlv_date2 = datestr(obj.first_dlv_date1,'yyyy-mm-dd');
    obj.last_dlv_date1 = datenum(wdata{1,5});
    obj.last_dlv_date2 = datestr(obj.last_dlv_date1,'yyyy-mm-dd');
    
    try
        obj.init_margin_rate = wdata{1,end}/100;
    catch
        obj.init_margin_rate = [];
    end
    
    th = wdata{1,6};
    th_ = regexp(th,',','split');
    
    n1 = length(th_{1,1});
    n2 = length(th_{1,2});
    if n1 == 12
        str1 = ['0',th_{1,1}(3:end)];
    else
        str1 = ['0',th_{1,1}];
    end
    if n2 == 13
        str2 = th_{1,2}(3:end);
    else
        str2 = th_{1,2};
    end
    
    if size(th_,2) == 3
        
        %下午21:00-次日2:30(夜盘)
        %下午21:00-次日1:00(夜盘)
        %下午21:00-23:00(夜盘)
        if strcmpi(th_{1,3}, '下午21:00-23:00(夜盘)')
            str3 = '21:00-23:00';
        elseif strcmpi(th_{1,3}, '下午21:00-次日1:00(夜盘)')
            str3 = '21:00-01:00';
        elseif strcmpi(th_{1,3}, '下午21:00-次日2:30(夜盘)')
            str3 = '21:00-02:30';
        end
        
        obj.trading_hours = [str1,';',str2,';',str3];
        obj.trading_break = '10:15-10:30';
    else
        obj.trading_hours = [str1,';',str2];
        if strcmpi(obj.asset_name,'eqindex_300') || ...
                strcmpi(obj.asset_name,'eqindex_50') || ...
                strcmpi(obj.asset_name,'eqindex_500') || ...
                strcmpi(obj.asset_name,'govtbond_5y') || ...
                strcmpi(obj.asset_name,'govtbond_10y')
            obj.trading_break = '';
        else
            obj.trading_break = '10:15-10:30';
        end
    end

end
%end of init_wind

