function [category,extrainfo,instrument] = getfutcategory(varinput)
%categorizing listed futures traded in China exchanges
%category1:equity index futures
%   open at 9:30am and close at 11:30am for lunch break
%   reopen at 1:00pm and close at 3:00pm
%   not traded during the night

%category2:govtbond futures
%   open at 9:15am and close at 11:30am for lunch break
%   reopen at 1:00pm and close at 3:15pm
%   not traded during the night

%category3:commodity futures without evening trading sessions
%   open at 9:00am and close at 11:30 for lunch break
%   reopen at 1:00pm and close at 3:00pm
%   break between 10:15am and 10:30am
%   not traded during the night

%category4:commodity futures with evening trading sessions but not traded
%overnight
%   open at 9:00am and close at 11:30 for lunch break
%   reopen at 1:00pm and close at 3:00pm
%   reopen at 9:00pm and close at either 11:00pm or 11:30pm
%   break between 10:15am and 10:30am

%category5:commodity futures with evening trading sessions and traded overnight 
%   open at 9:00am and close at 11:30 for lunch break
%   reopen at 1:00pm and close at 3:00pm
%   reopen at 9:00pm and close at either 1:00am or 02:30am
%   break between 10:15am and 10:30am

    if ischar(varinput)
        instrument = code2instrument(varinput);
    elseif isa(varinput,'cInstrument')
        instrument = varinput;
    else
        error('getfutcategory:invalid data type "%s" for input\n',class(varinput));
    end
    
    break_interval = instrument.break_interval;
    if strcmpi(break_interval{1,1},'09:30:00') && size(break_interval,1) == 2
        category = 1;
        extrainfo = 'equityindex';
        return
    end
    
    if strcmpi(break_interval{1,1},'09:15:00') && ...
            strcmpi(break_interval{end,end},'15:15:00') && ...
            size(break_interval,1) == 2
        category = 2;
        extrainfo = 'govtbond';
        return
    end
    
    if strcmpi(break_interval{1,1},'09:00:00') && ...
            strcmpi(break_interval{end,end},'15:00:00') && ...
            ~isempty(instrument.trading_break)
        category = 3;
        extrainfo = 'comdtydaytimeonly';
        return
    end
    
    if strcmpi(break_interval{1,1},'09:00:00') && ...
            (strcmpi(break_interval{end,end},'23:00:00') ||...
            strcmpi(break_interval{end,end},'23:30:00')) && ...
            ~isempty(instrument.trading_break)
        category = 4;
        extrainfo = 'comdtynoovernight';
        return
    end
    
    if strcmpi(break_interval{1,1},'09:00:00') && ...
            (strcmpi(break_interval{end,end},'01:00:00') ||...
            strcmpi(break_interval{end,end},'02:30:00')) && ...
            ~isempty(instrument.trading_break)
        category = 5;
        extrainfo = 'comdtyovernight';
        return
    end

end

