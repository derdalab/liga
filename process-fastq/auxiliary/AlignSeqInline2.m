function AlignSeqInline2(SeqF, SeqR, QuaF, QuaR, outdir, NucName,...
                         selected_tiles, mismatch_cutoff,MiniNumMatch)
     
    % find alignments in all reads using the selected teles tiles
    [TILE, MATCH, MISMATCH] = reads2tileFAST(SeqF, SeqR,...
                                             selected_tiles,...
                                             mismatch_cutoff);
    
%     % find reads with the number of MiniNummatch matches                                  
    IN = find(MATCH>=MiniNumMatch);
    
    if ~isempty(IN)
        SeqF = SeqF(IN,:);
        SeqR = SeqR(IN,:);
        QuaF = QuaF(IN,:);
        QuaR = QuaR(IN,:);
        TILE = TILE(IN);
        MATCH = MATCH(IN);
        MISMATCH = MISMATCH(IN);
    
    
    % make tags for saving
        [TAG] = makeTAG2(SeqF, SeqR, MATCH, MISMATCH, TILE, mismatch_cutoff);
    
        uTILE = unique(TILE);
    
        for i=1:numel(uTILE)
            IX = find( TILE==uTILE(i) );
        
    % add the ~~ spacers to the sequences
            [Fnuc, Rnuc] = addDASH(SeqF(IX,:), SeqR(IX,:), uTILE(i));
            [Fqua, Rqua] = addDASH(QuaF(IX,:), QuaR(IX,:), uTILE(i));
        
            saveSeq(TAG(IX,:), Fnuc, Rnuc, Fqua, Rqua, outdir, NucName)
        end
    end
    
    

end

function [Fnuc, Rnuc] = addDASH(SeqF, SeqR, TILE)
    
    if TILE<0
        DASH =  char( double('~') * ones(size(SeqF,1), abs(TILE) ) );
        Fnuc = [ DASH SeqF ];
        Rnuc = [ SeqR DASH ];
    elseif TILE>0
        DASH =  char( double('~') * ones(size(SeqF,1), abs(TILE) ) );
        Fnuc = [ SeqF DASH ];
        Rnuc = [ DASH SeqR ];
    else
        Fnuc = SeqF;
        Rnuc = SeqR;
    end       
end

function saveSeq(TAG, Fnuc, Rnuc, Fqua, Rqua, outdir, name)

    if isempty(Fnuc)
        return
    end
    
    % replace all the '|' characters by '~' because it doens't matter
    % anymore at this point; the analysis is done.
    IXX = find(Rnuc=='|');
    Rnuc(IXX) = '~';
    Rqua(IXX) = '~';
    
    IXX = find(Fnuc=='|');
    Fnuc(IXX) = '~';
    Fqua(IXX) = '~';
    clear IXX;
    
    RET  = char( [ 13*ones(size(Fnuc,1),1) 10*ones(size(Fnuc,1),1)] );

    PLUS = double('+')*ones(size(Fnuc,1),1); % separator between Seq and Qua
    
    toSave = [TAG RET Fnuc RET Rnuc RET PLUS RET Fqua RET Rqua RET];
   
    %write to file
    fhQ = fopen(fullfile(outdir, name), 'a+');
    fprintf(fhQ, '%s', toSave');
    fclose(fhQ);        
end 


