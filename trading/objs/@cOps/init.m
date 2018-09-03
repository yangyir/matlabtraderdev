function [obj] = init(obj,varargin)
%cOps
    if ~ischar(name), error('cOps:init invalid name input');end
    if ~isa(book,'cBook'), error('cOps:init:invalid book input');end
    obj.name_ = name;
    obj.book_ = book;
    
    obj.entrusts_ = EntrustArray;
    obj.entrustspending_ = EntrustArray;
    obj.entrustsfinished_ = EntrustArray;
    obj.trades_ = cTradeOpenArray;
end