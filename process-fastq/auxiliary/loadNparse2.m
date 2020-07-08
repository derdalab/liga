function [Tags, SeqF, SeqR, QuaF, QuaR, START, isEOF] = ...
                                loadNparse2(indir,name,chunk,START,newline)
    
                            
    DEBUG = 0;           % display information about reading process                            
    CH = newline(end);   % delineation character is ASCII 10; new line (NL) 
    chunk = 6*chunk;     % there are 6 lines in a chunk
   
    FID = fopen(fullfile(indir,name));
    
    fseek(FID,0,'eof');
    LAST = ftell(FID);  % position of the last element of the file
    
    % read 10000 characters from the current position in the FASTQ file
    N=10000;
    fseek(FID,START,'bof');
    temp = (fread(FID, N, '*char'))';

    % split the line using newline delineators
    split = regexp (temp, CH, 'split');

    % an estimate of the read length required to read exactly "chunk" lines
    readL= floor(N*chunk/numel(split));  
    
    if readL-START > LAST
        readL = LAST+1-START; % shorten theread length to read just to EOF
    end

    % rewind to the start, read the readL and count the number of newlines
    fseek(FID,START,'bof'); 
    temp2 = (fread(FID, readL, '*char'))';

    % look for the entire newline character (10/13) not just (10)
    IX = regexp(temp2, newline,'end');
    %IX = find(temp2==CH);  % find and count the new line characters
    
    N2 = numel(IX);  % the number of lines read_Bifang
   
    if DEBUG
        fprintf(['Read ' num2str(N2) '/' num2str(chunk) ' lines, ']); 
    end
    
    if N2<chunk && ~feof(FID)
        
        % by how much the reading missed the exact chunk
        miss=chunk-N2;
        if DEBUG, fprintf(['go forward ' num2str(miss) ' lines ']); end
        
        % find the readL, which is 2x the missed chunk, read it, count NL
        readL2=N*miss*2/numel(split);   
        temp3 = (fread(FID, readL2, '*char'))'; 
        
        % look for the entire newline character (10/13) not just (10)
        IX = regexp(temp3,newline,'end');
        %IX = find(temp3==CH);

        % IX(miss) is index of the NL at the line # equall to chunk
        % but if IX contain less than "miss" elements, or if its empty,
        % it means that you have reached EOF.
        if ~isempty(IX) && numel(IX)>=miss
            final = [temp2 temp3( 1:IX(miss) )];
        elseif ~isempty(IX) && numel(IX)<miss
            final = [temp2 temp3( 1:IX(end) )];  % EOF is reached
        else
            final = temp2;  % no NL has been found; EOF is reached
        end
        
    elseif N2<chunk && feof(FID)   % not enough NL but EOF is reached
        
        if DEBUG, fprintf('EOF! '); end
        final = temp2;
        
    elseif N2>=chunk
        
        if DEBUG, fprintf('rewind '); end
        % IX(chunk) is index of the new line at the line # equall to chunk
        % create a final string that contains the right number of NL
        final = temp2( 1:IX(chunk) );
        
    end
        
    
    % add the length of the read string to the START position
    START=START+numel(final);        % return the new START
    
    % move to that position, attempt reading 1 character, and check for EOF 
    fseek(FID,START,'bof');
    fread(FID,1,'*char');
    isEOF = feof(FID);               % return the EOF indicator
    
    %Splitline = regexp (final(1:end), '(\r\n|\r)', 'split');
    
    Splitline = regexp (final, '\r\n', 'split');
    
    Splitline = Splitline';
    
    Tags = char( Splitline(1:6:end, :) );
    Tags = Tags(1:end-1,:);
    
    SeqF = char( Splitline(2:6:end, :) );
    SeqR = char( Splitline(3:6:end, :) );
    QuaF = char( Splitline(5:6:end, :) );
    QuaR = char( Splitline(6:6:end, :) );

 
    
    fclose(FID);
end