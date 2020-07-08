% this function determines whether file has SDB in it or no

function [answer] = issdb(FID, name)
    test = 0;
    j=0;

    for i=1:100
        if ~feof(FID)
            A=fgetl(FID);
            if numel(A)>6
                test = test + strcmp(A(1:6),'AAAAAA');
                j=j+1;
            else
                answer = nan;
                return
            end
                
        end
    end

 
    if test>j/2
        answer = 1;
    elseif test<2
        answer = 0;
    else
        answer = nan;
    end
end

