function   roi_type=get_roi_type_tailSig(sigs)

if sigs(3)  % prim is significantly smaller from intact
    if sigs(2) % SG is significantly smaller from intact
        if sigs(1)  % HG is significantly smaller from intact
            roi_type = 'Very Long TRW';
        else
            roi_type = 'Long TRW';
        end
    elseif sigs(1) 
        roi_type = 'Wierd';
    else
        roi_type = 'Intermid TRW';
    end
elseif sum(sigs) > 0
    roi_type = 'Wierd';
else
    roi_type = 'Short TRW';
end
end

















