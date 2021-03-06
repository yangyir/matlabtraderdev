function [n] = numberofentrusts(obj,varargin)
%cOps
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Status','all',@ischar);
    p.addParameter('Direction','all',@ischar);
    p.addParameter('Offset','all',@ischar);
    p.addParameter('Code','all',@ischar);
    p.parse(varargin{:});
    statusin = p.Results.Status;
    directionin = p.Results.Direction;
    offsetin = p.Results.Offset;
    codein = p.Results.Code;
    
    if ~(strcmpi(statusin,'all') || strcmpi(statusin,'finished') || strcmpi(status,'pending'))
        error('cOps:numberofentrusts:invalid status input')
    end
    
    if ~(strcmpi(directionin,'all') || strcmpi(directionin,'buy') || strcmpi(directionin,'sell'))
        error('cOps:numberofentrusts:invalid direction input')
    end
    
    if ~(strcmpi(offsetin,'all') || strcmpi(offsetin,'open') || strcmpi(offsetin,'close'))
        error('cOps:numberofentrusts:invalid offset input')
    end
    
    if strcmpi(statusin,'all')
        entrusts = obj.entrusts_;
    elseif strcmpi(statusin,'finished')
        entrusts = obj.entrustfinished_;
    else
        entrusts = obj.entrustpending_;
    end
    
    if strcmpi(directionin,'all')
        usedirection = 0;
    else
        if strcmpi(directionin,'buy')
            usedirection = 1;
        else
            usedirection = -1;
        end
    end
    
    if strcmpi(offsetin,'all')
        useoffset = 0;
    else
        if strcmpi(offsetin,'open')
            useoffset = 1;
        else
            useoffset = -1;
        end
    end
    
    if strcmpi(codein,'all')
        usecode = 0;
    else
        usecode = 1;
    end
    
    n = 0;
    for i = 1:entrusts.latest
       if ~usedirection && ~useoffset
           if usecode
               if strcmpi(entrusts.node(i).instrumentCode,codein)
                   n = n + 1;
               end
           else
               n = n + 1;
           end
       elseif ~usedirection && useoffset && entrusts.node(i).offsetFlag == useoffset
           if usecode
               if strcmpi(entrusts.node(i).instrumentCode,codein)
                   n = n + 1;
               end
           else
               n = n + 1;
           end
       elseif usedirection && entrusts.node(i).direction == usedirection && ~useoffset
           if usecode
               if strcmpi(entrusts.node(i).instrumentCode,codein)
                   n = n + 1;
               end
           else
               n = n + 1;
           end
       elseif usedirection && entrusts.node(i).direction == usedirection && useoffset && entrusts.node(i).offsetFlag == useoffset
           if usecode
               if strcmpi(entrusts.node(i).instrumentCode,codein)
                   n = n + 1;
               end
           else
               n = n + 1;
           end
       end 
    end
    
    
end