function [data,coldefs,textdata] = loadDataFromTxtFile(fn_)
    if ~ischar(fn_)
        error('cDataFileIO:loadDataFromTxtFile:invalid input')
    end

    %the file extension is '.txt' for test file
    if isempty(strfind(fn_,'.txt'))
        fn_ = [fn_,'.txt'];
    end

    %try to first open up the file for reading
    [fid,errmsg] = fopen(fn_,'r');
    if fid < 0
        error(['cDataFileIO:loadDataFromTxtFile:',errmsg,' in ',fn_])
    end

    A = importdata(fn_);
    if isstruct(A)
        flds = fields(A);
        hascolheaders = false;
        for i = 1:size(flds,1)
            if strcmpi(flds{i},'colheaders')
                hascolheaders = true;
                break
            end
        end
        if hascolheaders
            data = A.data;
            coldefs = A.colheaders;
            textdata = {};
        else
            if size(A.textdata,1) - size(A.data,1) == 1
                coldefs = cell(1,size(A.textdata,2));
                for i = 1:size(A.textdata,2)
                    coldefs{i} = A.textdata{1,i};
                end
                if strcmpi(coldefs{1},'date') || ...
                        strcmpi(coldefs{1},'time') || ...
                        strcmpi(coldefs{1},'datetime')
                    data = zeros(size(A.data,1),size(A.data,2)+1);
                    data(:,2:end) = A.data;
                    for i = 1:size(data,1)
                        try
                            data(i,1) = datenum(A.textdata{i+1,1});
                        catch
                            error('unknown')
                        end
                    end
                end
                textdata = A.textdata(2:end,:);
            else
                error('cDataFileIO:loadDataFromTxtFile:internal error')
            end
        end
    else
        data = A;
        coldefs = {};
    end

    fclose(fid);
end
%end of static function 'loadDataFromTxtFile'