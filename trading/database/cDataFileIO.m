classdef cDataFileIO < handle
    %class to handle jobs reading/writing data from local text or excel
    %files into matlab
    
    methods (Static)
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
                                data(i,1) = datenum(A.textdata{i+1,1});
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
            
            %the file extension is '.txt' for test file
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
        
        function dataArray = readDataArrayFromTxtFile(fn_,delimiter,formatSpec)
            fileID = fopen(fn_,'r');
            dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
            fclose(fileID);
        end
        %end of static function 'readDataArrayFromTxtFile'
        
    end
end