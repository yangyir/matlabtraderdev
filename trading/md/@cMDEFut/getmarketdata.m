% written by sunq on 20180611, this function is used to get
% marketdata(including bid, ask and timet)
% according the input para 'code'

function [bid,ask, timet] = getmarketdata(obj, code)
    quotes = obj.qms_.getquote;
    n = size(quotes,1);
    if n == 0, return; end
    
    id = ismember(code,quotes.code_ctp);
    if sum(sum(id))==0,return; end
    bid = quotes{id}.bid1;
    ask = quotes{id}.ask1;
    timet = datestr(quotes{id}.update_time1,'HH:MM:SS');
end
    

