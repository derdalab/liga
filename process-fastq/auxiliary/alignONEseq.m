function [Num_M0,Num_mapped,Num_unique]= alignONEseq(indir, parseDir,...
                                       uniDir, name, LIB, FB, RB, kind,...
                                      chunk,newline, outname2,...
                                      Num_M0,Num_mapped,Num_unique,...
                                      FBnum,RBnum)

START=0;
tic
WRITE='new';

[TOT, lines]=findPAR(indir, name, chunk);

if TOT>1
    disp([name ' has ' num2str(lines) ' lines reading in ~'...
          num2str(TOT) ' chunks of ' num2str(chunk) ]);
else
    fprintf([name '; ']);
end

for i=1:TOT+1
    
    fprintf(['chunk ' num2str(i) '/' num2str(TOT) '; ']);
    
    [Tags, SeqF, SeqR, QuaF, QuaR, START, isEOF] = ...
                        loadNparse2(indir,name,chunk,START,newline);

    if isempty(Tags), disp(' '); return; end   % abort if no reads
 
    [FR] = add(SeqF,SeqR);           % add forward and reverse reads
    
    clear Seq* Qua*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    M0 = findM0(Tags,'{0}', 1);      % Find reads without FR-mismatches
    
    numreads = size(M0,1);
    
%%%%%%%%%%%%%%% number of reads aligned well  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Num_M0(FBnum,RBnum) = Num_M0(FBnum,RBnum)+numreads;
    
    clear Tags
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%% this function finds library reads in a continous reads using
    %%% predefined library structure and rules for matching this structure
    [FA, NUC, RA] = matchReads(M0, FR, FB, RB, LIB, kind);
    
   mapped = size(NUC,1);
   
   Num_mapped(FBnum,RBnum)= Num_mapped(FBnum,RBnum) + mapped;
    
    clear FR M0;
    
    % matching involves trimming of sequences, if some were trimmed to a
    % complete blank (no nucleotides) this function converts them to '-'
    NUC = ReplaceBlankByDash(NUC);   
    
    if isempty(NUC), continue; end;
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if i>1, WRITE='add'; end   % after 2nd cycle, write in add-to file mode
    
    quickSave(['parsed_' name(1:end-4) '-' outname2 '.txt'], parseDir, {FA, NUC, RA}, 0,0, WRITE);
    

    clear FA RA
    %%%%% extract library from a specific location or use whole sequence
    %%%%% and convert the total sequences to unique sequences 
    if isfield(LIB,'LOCATION')  %%%Determine whether input is structure
                                %%%array field
        NUC = NUC(:,LIB.LOCATION);
        
        % after trimming, find and replace potential blank sequences by '-'
        NUC = ReplaceBlankByDash(NUC);
    end
    
    [newNUC, newFr] = uniquef(cellstr(NUC));
 
    
    clear NUC    
    
    %%%%% read the old unique sequences/frequencies from the saved file
    if strcmp(WRITE,'add')
        [oldNuc, oldFr] = quickRead([name(1:end-4) '-' outname2 '.txt'], uniDir);
    else
         oldNuc = {};
         oldFr = [];
    end
    
    %%%%% combine the old and new nucleotides and frequencies
    [uNUC, Fr, ~] = uniqueCOMB([oldNuc; newNUC], [oldFr; newFr]);
    
    clear oldNuc newNUC oldFr newFr
 
    AA = nt2aacell(uNUC,1);  % convert nucleotides to amino acids 
    try
        quickSave([name(1:end-4) '-' outname2 '.txt'], uniDir, {uNUC, AA}, Fr,0, 'new');
    catch
        disp('error');
    end
    
       
    disp([num2str(numel(uNUC)) ' unique (' num2str(toc,'%10.1f') ' s)']);
    
    if isEOF, break; end;  % exit the loop if the end of file was reached
end

try
    Num_unique(FBnum,RBnum) = Num_unique(FBnum,RBnum) + numel(uNUC);
catch
    disp('error');
end



end


function [TOT, lines] = findPAR(indir,name,chunk)

    FID = fopen(fullfile(indir,name));
    BlockL=0;
    fseek(FID,0,'eof');
    LAST = ftell(FID);  % position of the last element of the file
    currL2 = cell(1,4);

    % read 4000 lines to estimate the length of the block
    frewind(FID);
    for i=1:4000 
       currL2{i} = fgets(FID);
       BlockL = BlockL + numel(currL2{i}) ;
    end
    
    
    TOT = floor(LAST/(chunk*BlockL/1000));
    
    lines = floor(LAST/(BlockL/1000));
    if TOT ==0
        TOT = 1;
    end
    
end


