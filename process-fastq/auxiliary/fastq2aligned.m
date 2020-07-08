function fastq2aligned(varargin)
             

indir = '';
outdir = '';

chunk = 250000;            % default chunk size


% check for INPUT variable
if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end

    % read INPUT variables
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'chunk',          chunk = varargin{ni+1};
            case 'outdir',         outdir = varargin{ni+1};
            case 'indir',          indir=varargin{ni+1};
            case 'delimiter',      CH=varargin{ni+1};
            case 'nmismatches',    mismatches=varargin{ni+1}; 
            case 'matchsearch',    MatchSearch=varargin{ni+1};
            case 'minimummatch',   MinimumMatch=varargin{ni+1};
            case 'newline',        newline=varargin{ni+1}; 
            case 'files',          files=varargin{ni+1}; 
            case 'statistis',      statis = varargin{ni+1};
            case 'newvariable',    newvariable=varargin{ni+1}; 

        end
    end
end

%%%%%%%%%%%%%%%% check all input files and directories  %%%%%%%%%%%%%%%%%%
 
% check whether outdir name was defined
if strcmp(outdir,'')
    outdir = fullfile(indir, 'AllRAWFiles');
end

if ~isdir(outdir)
    mkdir(outdir);    
end

% check whether statis name was defined
if strcmp(statis,'')
    outdir = fullfile(indir, 'Statis');
end

if ~isdir(statis)
    mkdir(statis);    
end

if strcmp(files,'all')
      NucName = dir(fullfile(indir,'R*'));
else
      NucName = dir(fullfile(indir,[files '*']));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sort samples in order (R1F1,R1F2,R1F3,...,R10F17,R10f18,R10F19,R10F20) %
Samname = [];
for i=1:size(NucName,1)
    name_tmp = NucName(i).name(10:end-4);
    name_num = regexp(name_tmp,'\d+','match');
    Samname(i,1) = 100*str2num(name_num{1})+str2num(name_num{2});
    
end

[~,IX] = sort(Samname,'ascend');
NucName = NucName(IX);

%NUMreads = zeros(200,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:size(NucName,1)

    START=0;
    tic
    name = NucName(i).name;

    FID = fopen(fullfile(indir,name),'r');
    
    [TOT, lines]=findPAR(FID, chunk);
    frewind(FID);
    NUMreads(i,1) = statistics(FID,CH);
    

    if TOT>1
        disp([name ' has ' num2str(lines) ' lines reading in ~'...
            num2str(TOT) ' chunks of ' num2str(chunk) ])
    else
        fprintf([name '; ']);
    end

    for ii=1:TOT+1
    
        fprintf(['chunk ' num2str(ii) '/' num2str(TOT) '; ']);
    
        [~, SeqF, SeqR, QuaF, QuaR, START, isEOF] = ...
                            loadNparse2(indir,name,chunk,START,newline);
        if ~isempty(SeqF)
      
%%%%%%%%%%%%%%%%%% this is where alignment and saving is done %%%%%%%%%%%%%

           
           
           
        if ii==1
            % map the most probable tiles
            
          if size(SeqF,1)>10000
           
                % find the most common matches in randomly sampled small set of reads
              IX = 1:10000; 
          else
              IX = 1:size(SeqF,1);
          end
            %take the reads towards the end of the chunk
            
            disp(['Looking for most probable tiles in ' num2str(numel(IX)) ' reads']);
            [TILE,~, MISMATCH] = reads2tileN(SeqF(IX,:), SeqR(IX,:));

            % identify the most common unique tags
            % selected_tiles = unique( TILE(MISMATCH <= mismatches) );
            selected_tiles = unique(TILE);
            
            count=[];
            for kk=1:numel(selected_tiles)
                count(kk) = numel( find(TILE == selected_tiles(kk) ) );
            end
            [count, IX] = sort(count, 'descend');
            selected_tiles = selected_tiles(IX);
             
        end
        
        outname = NucName(i).name;
                    
        AlignSeqInline2(SeqF, SeqR,...
                         QuaF, QuaR,...
                         outdir, outname,...
                         selected_tiles, mismatches,MinimumMatch);
          
            
        end
    end

       

        fprintf(['Save=' num2str(toc,'%10.1f') '; \n']); tic
           
        clear Seq* Qua* All* addI* I Rest;
        
end 

    

fclose('all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save the number of reads with mapped barcodes in 'statistics.xlsx' file

Fstatis = fullfile(statis,[files(1:9) 'statistics.xlsx']);
NumReads = reshape(NUMreads,20,[]);
startRange = 'B2';
xlwrite(Fstatis,num2cell(NumReads),'Sheet1',startRange);

end

function [TOT, lines] = findPAR(FID,chunk)

    BlockL=0;
    fseek(FID,0,'eof');
    LAST = ftell(FID);  % position of the last element of the file
    
    % find the middle position, go there
    MIDDLE = round(LAST/2);
    fseek(FID,MIDDLE,0);
    
    % read some random line and throw it away, cus it's probably truncated
    fgets(FID);
    frewind(FID);
    
    % FASTQ format has 6 lines, repeated N times. What I call a BLOCK is a
    % block of 6 lines. To find an average length of the block of 6 lines,
    % we read 6000 lines, calculate the length and divide it by 1000. In
    % other words, its an average length of the first 1000 blocks.
    
    % read 6000 lines (1000 blocks) to estimate the length of the block
    N=1000;
    
    currL2 = cell(6*N,1); % preallocate memory like a good programmer you are
    for i=1:6*N 
       currL2{i,1} = fgets(FID);
       BlockL = BlockL + numel(currL2{i,1}) ;
    end
    
    TOT = floor(LAST/(chunk*BlockL/N));
    lines = floor(LAST/(BlockL/N));
    if TOT ==0
        TOT = 1;
    end

end

function [num] = statistics(FID,CH)
    
    fcontent = fread(FID, inf, 'uint8=>char');
    num = sum(double(fcontent == CH));
    fclose(FID);
end