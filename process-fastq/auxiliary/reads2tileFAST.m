 function [TILE, MATCH, MISMATCH] = reads2tileFAST(F, R, selected_tiles,...
                                                   mismatch_cutoff)

    
    TILE = nan(size(F,1),1);
    MISMATCH = TILE;
    MATCH = TILE;
    
    for jj = 1:numel(selected_tiles)

        % look at elements that are still unknown
        IX1 = find(isnan(TILE));
        [mismatch, match] = isperfectmatch(F(IX1,:),R(IX1,:),...
                                           selected_tiles(jj) );
        
        IX2 = find (mismatch<=mismatch_cutoff);
        TILE( IX1(IX2) )     = selected_tiles(jj);
        MISMATCH( IX1(IX2) ) = mismatch(IX2);
        MATCH( IX1(IX2) )    = match(IX2);

    end
    

    % find the most common matches in the remaining unknonwn reads
    IX1 = find(isnan(TILE));
    [rest_tile,rest_match,rest_mismatch] = reads2tileN(F(IX1,:),R(IX1,:));
    TILE( IX1 )     = rest_tile;
    MISMATCH( IX1 ) = rest_mismatch;
    MATCH( IX1 )    = rest_match;
    
end