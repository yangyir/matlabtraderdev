function flag = saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr)
    if nargin < 3
        coldefs = {};
        permission = 'w';
        usedatestr = false;
    end

    if nargin < 4
        permission = 'w';
        usedatestr = false;
    end

    %the file extension is '.txt' for text file
    if isempty(strfind(fn_,'.txt'))
        fn_ = [fn_,'.txt'];
    end

    if ~isempty(coldefs)
        if ischar(coldefs)
            ncols = 1;
        else
            ncols = length(coldefs);
        end
        if ncols ~= size(data,2)
            error('cDataFileIO:saveDataToTxtFile:mismatch between data columns and colheader columns')
        end
    end

    if ~isempty(coldefs), colfmt = '%s'; end
    if ~usedatestr
        datafmt = '%f';
    else
        datafmt = '%s';
    end
    for i = 2:ncols
        if ~isempty(coldefs), temp1 = [colfmt,'\t%s'];colfmt = temp1;end
        temp2 = [datafmt,'\t%f'];
        datafmt = temp2;
    end

    if ~isempty(coldefs), temp1 = [colfmt,'\n'];colfmt = temp1;end
    temp2 = [datafmt,'\n'];
    datafmt = temp2;

    fid = fopen(fn_,permission);

    if ~isempty(coldefs)
        txtstr = 'coldefs{1}';
        for i = 2:ncols
            temp = [txtstr,',','coldefs{',num2str(i),'}'];
            txtstr = temp;
        end
        eval(['fprintf(fid,colfmt,',txtstr,');']);
    end

    for i = 1:size(data,1)
        if usedatestr
            dateformat = 'yyyy-mm-dd HH:MM:SS';
            txtstr = 'datestr(data(i,1),dateformat)';
        else
            txtstr = 'data(i,1)';
        end
        for j = 2:ncols
            temp = [txtstr,',','data(i,',num2str(j),')'];
            txtstr = temp;
        end
        eval(['fprintf(fid,datafmt,',txtstr,');']);
    end

    fclose(fid);
    flag = true;
end
%end of static function 'saveDataToTxtFile'