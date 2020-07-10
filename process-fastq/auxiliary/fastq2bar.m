function fastq2bar(varargin)


% for new types of sequences, I recommend running it in DEBUG mode
DEBUG=1;
% if you want to check files whether they exist or not, make this 1
CHECKFILES=0;
             
fname = '';              % initiate the variables
indir = '';
outdir = '';

chunk = 250000;            % default chunk size

BARL = 4;                  % default length of the barcode

% change these variables in the INPUT file if you want to debug the
% processing and look for reason why there isn't matching, etc.
% by default, I turn both of these veriables off
saveNOmatch = 0;   % do not save sequences that do not match the pattern
saveNObar = 0;  % do not save sequences that do not match the barcode
SAVERAW = 0;    % do not save raw, non-aligned sequences by default

% check for INPUT variable
if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end

    % read INPUT variables
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'fname',          fname = varargin{ni+1};
            case 'rname',          rname = varargin{ni+1};
            case 'chunk',          chunk = varargin{ni+1};
            case 'outdir',         outdir = varargin{ni+1};
            case 'indir',          indir=varargin{ni+1};
            case 'allexcelfiles',  AllExcelFiles= varargin{ni+1};
            case 'xlsname',        xlsname=varargin{ni+1};
            case 'sheetname',      sheetname=varargin{ni+1}; 
            case 'barcodes',       B=varargin{ni+1}; 
            case 'savenomatch',    saveNOmatch=varargin{ni+1}; 
            case 'savenobar',      saveNObar=varargin{ni+1};
            case 'saveraw',        SAVERAW=varargin{ni+1};
            case 'delimiter',      CH=varargin{ni+1};
            case 'newline',        newline=varargin{ni+1};
            case 'statistis',      statis = varargin{ni+1};
            case 'files',          files=varargin{ni+1};
            case 'newvariable',    newvariable=varargin{ni+1};
            case 'rn',             RN=varargin{ni+1};
            case 'fn',             FN=varargin{ni+1};  
        end
    end
end

%%%%%%%%%%%%%%%% check all input files and direactories  %%%%%%%%%%%%%%%%%%

%%%% these are file names for saving
[~,Name,~]=xlsread(fullfile(AllExcelFiles,xlsname.name),sheetname);

Name = Name(2:(FN+1),2:(RN+1));
        
% check whether outdir name was defined
if strcmp(outdir,'')
    outdir = fullfile(indir, 'AllBarFiles');
end

if ~isdir(outdir)
    mkdir(outdir);    
end

% check whether statis name was defined
if strcmp(statis,'')
    outdir = fullfile(indir, 'Statis');
end

if CHECKFILES
    for kk=1:numel(fname)
        FIDR = fopen(fullfile(indir, rname{kk}));

        if FIDR==-1 
            error(['FASTQ file ' fullfile(indir, rname{kk}) ' is not found']);
        end

        FIDF = fopen(fullfile(indir, fname{kk})); 
        if FIDF==-1 
            error(['FASTQ file ' fullfile(indir, fname{kk}) ' is not found']);
        end
        fclose all;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NumReads = 0;

for kk=1:numel(fname)
    
    %find the parameters of the FASTQ file for chunk-y loading
    
    % check for unzipped file, if not present, unzip the gz file
    FIDF = fopen(fullfile(indir, fname{kk}(1:end-3)));
    if  FIDF~= -1        
        UZfname =  fullfile(indir, fname{kk}(1:end-3));
    else
        fprintf(['unzipping the ' fname{kk} ]);  tic
        UZfname = gunzip(fullfile(indir, fname{kk}));
        UZfname = UZfname{1};
        disp([' (done in ' num2str(toc,'%10.1f') ' s)']);
    end
    
    FIDR = fopen(fullfile(indir, rname{kk}(1:end-3)));
    if FIDR ~= -1
        UZrname =  fullfile(indir, rname{kk}(1:end-3));
    else
        fprintf(['unzipping the ' rname{kk} ]);  tic
        UZrname = gunzip(fullfile(indir, rname{kk}));
        UZrname = UZrname{1};
        disp([' (done in ' num2str(toc,'%10.1f') ' s)']);
    end
    

    % find the reading parameters for quick reading
    [TOT,lines ]=findPAR( fopen(UZrname), chunk );
    
    NumReads = NumReads+lines;
    
    disp(['Processing ' UZfname(end-20:end)...
          '; Total of ' num2str(lines) ...
          ' lines will be processed in ' num2str(TOT) ' chunks']);
    
    STARTF=0;
    STARTR=0;

    for ii=1:TOT
        tic        
        fprintf([ 'Chunk# ' num2str(ii) '/' num2str(TOT) '; ']);
        
        %read the reverse
        FIDR = fopen(UZrname);
        [SeqR, QuaR, TagR, STARTR] = loadNparse(FIDR,chunk,STARTR,CH);

        SeqR = rcomplementFAST(SeqR);
        QuaR = fliplr(QuaR);
        
        fprintf(['LoadF=' num2str(toc,'%10.1f') '; ']); tic

        %read the forward
        FIDF = fopen(UZfname);
        [SeqF, QuaF, TagF, STARTF] = loadNparse(FIDF,chunk,STARTF,CH);
        LINES = size(SeqF,1);
        

        if isempty(SeqR), disp('no sequences'); continue; end

        %fill the spaces at the end of the forward sequence with ~
        IX = find(SeqF==' ');
        SeqF(IX)='~';
        try
            QuaF(IX)='~';
        catch
            fprintf('hello');
        end
        
        %fill the spaces at the beginning of the reverse sequence with ~
        IX = find(SeqR==' ');
        SeqR(IX)='~';
        QuaR(IX)='~';
        
        fprintf(['LoadR=' num2str(toc,'%10.1f') '; ']); tic
        
        % 
        NUM = min(size(SeqF,1), size(SeqR,1));
        SeqF = SeqF(1:NUM,:);
        SeqR = SeqR(1:NUM,:);
        QuaF = QuaF(1:NUM,:);
        QuaR = QuaR(1:NUM,:);
        TagF = TagF(1:NUM,:);
        TagR = TagR(1:NUM,:);
        
        % find the lines that contain N symbols
        [r1,~]=find(SeqR=='N');
        [r2,~]=find(SeqF=='N');
        
        % find the lines that do not contain the N symbol
        NoN = setdiff(1:size(SeqF,1),unique([r1; r2]));
     
        % save reads that were not matched into unmatched.txt
        if saveNOmatch
            Rest = setdiff(1:size(SeqF,1),NoN);
            [~,IX] = sortrows(Seq(Rest,2:end-1));
            
            DASH =  char( double('|')*ones(size(Rest,1),1) );

            SQsave(outdir,'S_unmatched',...
                   [SeqF(Rest(IX),:) DASH SeqR(Rest(IX),:)],...
                   [QuaF(Rest(IX),:) DASH QuaR(Rest(IX),:)]);
        end
        
        % clear all lines that contain N
        SeqF = SeqF(NoN,:);
        try
        SeqR = SeqR(NoN,:);
        catch
            disp(NoN);
        end
        QuaF = QuaF(NoN,:);
        QuaR = QuaR(NoN,:);
        TagF = TagF(NoN,:);
        TagR = TagR(NoN,:);

        % extract barcodes and sequences from specific location of the read
        AllFB =  SeqF(:,1:BARL);
        AllRB =  SeqR(:,end-BARL+1:end);
        
        
        % covert barcodes to numeric analogs for faster searching
        NF = bar2numer(AllFB,1,B);
        NR = bar2numer(AllRB,-1,B);
        % if barcode isn't found, NF and NR are zero. It is probably PhiX
        % sequence used for dilution.
        
        fprintf(['ClearN=' num2str(toc,'%10.1f') '; ']); tic

        addI=[];  % index variable storing all found barcodes;
        
       
            
        for F =1:size(Name,1)
            
            for R=1:size(Name,2)
                
                I=find(NF==F & NR==R);
                
                % remember all found combinations
                addI = [addI; I];
                
                 Bmap(F,R) = numel(I);
                
                 outname = [xlsname(1).name(1:8) '-' 'R' num2str(R) 'F' num2str(F) ...
                           '.txt'];  
                 if ~isempty(I)
                     
                    Tags = split(cellstr(TagF(I,:)));
                    if (size(I,1)>1)
                     
                        Tags_new = Tags(:,1);
                    else
                        Tags_new = Tags(1,:);
                    end

                    saveSeq(Tags_new, SeqF(I,:), SeqR(I,:),...
                        QuaF(I,:),QuaR(I,:), outdir, outname);
                 else %added by jessica
                    %write empty string to file
                    fhQ = fopen(fullfile(outdir, outname), 'a+');
                    fprintf(fhQ, '\n');
                    fclose(fhQ);  
                    %fprintf(['Empty:R' num2str(R) 'F' num2str(F) '\n']);
                  end
               
                       

                 if SAVERAW 
                    
                     DASH =  char( double('|')*ones(size(I,1),1) );
                           
                     SQsave(outdir,['RAW_' outname],...
                           [SeqF(I,:) DASH SeqR(I,:)],...
                           [QuaF(I,:) DASH QuaR(I,:)]);
                 end
            end
            
        end

        
        % find non-mapped barcodes and save them to S_unmatchedbar.txt
        if saveNObar
            I = setdiff(1:size(AllSeq,1),addI);

            SQsave(outdir,'S_unmatchedbar',...
                   [SeqF(I,:) DASH SeqR(I,:)],...
                   [QuaF(I,:) DASH QuaR(I,:)]);
        end

        fprintf(['Save=' num2str(toc,'%10.1f') '; ']); tic
        
        disp([ num2str(LINES) ' lines read; ' ...
               num2str(numel(NoN)) ' have no N; '...
               num2str(numel(addI)) ' have BARs; ']);  
           
        clear Seq* Qua* All* addI* I Rest;
        
    end  % of for ii=1:TOT
    
    %delete the unzipped files to free up the space
%     delete(UZfname);
%     delete(UZrname);

end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save the number of reads of this run in 'statistics.xlsx' file

Fstatis = fullfile(statis,[files(1:9) 'statistics.xlsx']);
startRange = 'A1';
%xlwrite(Fstatis,num2cell(NumReads),'Sheet1',startRange);

fclose('all');

end

function saveSeq(TAG, Fnuc, Rnuc, Fqua, Rqua, outdir, name)

    if isempty(Fnuc)
        return
    end
    
    RET  = char( [ 13*ones(size(Fnuc,1),1) 10*ones(size(Fnuc,1),1)] );

    PLUS = char(double('+')*ones(size(Fnuc,1),1)); % separator between Seq and Qua
    
    try 
        toSave = [char(TAG) RET Fnuc RET Rnuc RET PLUS RET Fqua RET Rqua RET];
    catch
        disp('error');
    end
   
    %write to file
    fhQ = fopen(fullfile(outdir, name), 'a+');
    fprintf(fhQ, '%s', toSave');
    fclose(fhQ);        
end 
