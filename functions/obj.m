function [f, gradf] = obj(dv)
    global  OPT
    
    OPT.dv_old = OPT.dv; % save the previous design
    OPT.dv = dv(:); % update the design
    
    
    if OPT.dv == OPT.dv_old
        %don't update or perform the analysis
    else
        update_geom_from_dv(); % update GEOM for this design
        perform_analysis();
    end

    f = OPT.functions.f{1}.value;
    gradf = OPT.functions.f{1}.grad;
    