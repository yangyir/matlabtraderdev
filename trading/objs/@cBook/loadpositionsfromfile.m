function [] = loadpositionsfromfile(obj,fn,datein)
%cBook
    if ~isempty(strfind(fn,'.txt'))
        fid = fopen(fn,'r');
    else
        fid = fopen([fn,'.txt'],'r');
    end
    if fid < 0, return; end
    
    obj.positions_ = {};
        
    line_ = fgetl(fid);
    while ischar(line_)
        lineinfo = regexp(line_,'\t','split');
        code_i = lineinfo{1};
        flag = isoptchar(code_i);
        if flag
            instrument = cOption(code_i);
        else
            instrument = cFutures(code_i);
        end
        instrument.loadinfo([code_i,'_info.txt']);
        
        direction_i = str2double(lineinfo{2});
        position_i = str2double(lineinfo{3});
        cost_i = str2double(lineinfo{4});
        
        obj.addpositions('code',code_i,...
                    'price',cost_i,'volume',direction_i*position_i,...
                    'time',datenum(datein));
        
        line_ = fgetl(fid);
    end
            
    fclose(fid);
end