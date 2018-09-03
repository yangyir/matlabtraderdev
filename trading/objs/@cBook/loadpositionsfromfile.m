function [] = loadpositionsfromfile(obj,fn)
%cBook
    if ~isempty(strfind(fn,'.txt'))
        fid = fopen(fn,'r');
    else
        fid = fopen([fn,'.txt'],'r');
    end
    if fid < 0, return; end
    
    ret = obj.checkpositionfile(fn);
    if ~ret,return;end
    
    obj.positions_ = {};
    bookname = obj.bookname_;
    tradername = obj.tradername_;
    countername = obj.countername_;
    
    if isempty(bookname)
        usebookname = false;
    else
        usebookname = true;
    end
    
    if isempty(tradername)
        usetradername = false;
    else
        usetradername = true;
    end
    
    if isempty(countername)
        usecountername = false;
    else
        usecountername = true;
    end
        
    line_ = fgetl(fid);
    linecount = 0;
    while ischar(line_)
        linecount = linecount + 1;
        if linecount == 1 
            line_ = fgetl(fid);
            continue;
        end
        lineinfo = regexp(line_,'\t','split');
        bookname_i = lineinfo{1};
        tradername_i = lineinfo{2};
        countername_i = lineinfo{3};
        if usebookname && ~strcmpi(bookname_i,bookname)
            line_ = fgetl(fid);
            continue;
        end
        if ~usebookname, obj.bookname_ = bookname_i;end
        
        if usetradername && ~strcmpi(tradername_i,tradername)
            line_ = fgetl(fid);
            continue;
        end
        if ~usetradername, obj.tradername_ = tradername_i;end
        
        if usecountername && ~strcmpi(countername_i,countername)
            line_ = fgetl(fid);
            continue;
        end
        if ~usecountername, obj.countername_ = countername_i;end

        code_i = lineinfo{4};
        direction_i = str2double(lineinfo{5});
        position_i = str2double(lineinfo{6});
        cost_i = str2double(lineinfo{7});
        datein = lineinfo{8};
        
        obj.addpositions('code',code_i,...
                    'price',cost_i,'volume',direction_i*position_i,...
                    'time',datenum(datein));
        
        line_ = fgetl(fid);
    end
            
    fclose(fid);
end