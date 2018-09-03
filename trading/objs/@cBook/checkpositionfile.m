function [ret] = checkpositionfile(obj,fn)
%cBook
    variablenotused(obj);

    if ~isempty(strfind(fn,'.txt'))
        fid = fopen(fn,'r');
    else
        fid = fopen([fn,'.txt'],'r');
    end
    if fid < 0, ret = false; return;end
    
    line_ = fgetl(fid);
    linecount = 0;
    
    ret = false;
    while ischar(line_)
        linecount = linecount + 1;
        if linecount == 1 
            line_ = fgetl(fid);
            continue;
        end
        lineinfo = regexp(line_,'\t','split');
        if linecount == 2
            bookname = lineinfo{1};
            tradername = lineinfo{2};
            countername = lineinfo{3};
            line_ = fgetl(fid);
            continue;
        end
        bookname_i = lineinfo{1};
        tradername_i = lineinfo{2};
        countername_i = lineinfo{3};
        if ~strcmpi(bookname,bookname_i) || ~strcmpi(tradername,tradername_i) ||...
                ~strcmpi(countername,countername_i)
            fclose(fid);
            error('error:cBook:checkpositionfile:inconsistent bookname, tradername or countername found in %s\n',...
                fn);
        end
        line_ = fgetl(fid);
    end
    fclose(fid);
    ret = true;
    
end