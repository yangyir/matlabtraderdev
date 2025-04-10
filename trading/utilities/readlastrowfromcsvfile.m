function lastrow = readlastrowfromcsvfile(filename)
    fid = fopen(filename, 'rt');
    if fid == -1
        error('readlastrowfromcsvfile:could not open file: %s', filename);
    end
    
    % Move to the end of the file
    fseek(fid, 0, 'eof');
    
    % Move backward until we find a newline character
    position = ftell(fid);
    
    % Find the last line with a new line mark
    while position > 0
        fseek(fid, -1, 'cof');
        position = ftell(fid);
        if fread(fid, 1, 'char') == sprintf('\n')
           break 
        end
        fseek(fid, position, 'bof');
    end
    
    % Move to the position with a newline mark
    fseek(fid,position,'bof');
    
    % Use fgetl to read the line info
    lastLine = fgetl(fid);

    % In case the last line is empty, we need to move backward to find a
    % line with non-empty entry
    if isempty(lastLine)
        while position > 0 && isempty(lastLine)
            position = position - 1;
            fseek(fid, position, 'bof');
            lastLine = fgetl(fid);
        end
    
        % Find the last non-empty line (if there is any empty line)
        % with a newline character
        while position > 0
            position = position - 1;
            fseek(fid, position, 'bof');
            if fread(fid, 1, 'char') == sprintf('\n')
                break 
            end
        end

        lastLine = fgetl(fid);    
    end
    
    fclose(fid);
    % Parse the CSV line
    try
        lastrow = textscan(lastLine, '%s', 'Delimiter', ',');
        lastrow = lastrow{1}'; % Convert to cell array
    catch
        lastrow = '';
    end
    
    
    
end