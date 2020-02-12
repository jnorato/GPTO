function  plot_history(fig)
%
% Plot and save the history of the optimization objective and constraint.
% The user can costomize the figure sizes here.
global OPT


markertype = 'none';
markersize = 6;
linestyle = '-';

f = OPT.history.fval;

figure(fig); cla;
subplot(2,1,1);
a = semilogy(f);
a.LineStyle = linestyle;
a.Marker = markertype;
a.MarkerSize = markersize;
title('objective history')
xlabel('iteration')
legend(OPT.functions.f{1}.name)

if isfield(OPT.history,'fconsval')
    g = reshape(OPT.history.fconsval,OPT.functions.n_func-1,[]).' ...
        + OPT.functions.constraint_limit;
    label = cell(1,OPT.functions.n_func-1);
    scale = ones(1,OPT.functions.n_func-1);
    for i = 2:OPT.functions.n_func
       label{i-1} = OPT.functions.f{i}.name;
       if strcmpi(OPT.functions.f{i}.name,'angle constraint')
          scale(i-1) = OPT.options.angle_constraint.scale;
       end
    end
    
    subplot(2,1,2); hold on
    plot(g./scale,'Linestyle', linestyle, 'Marker', markertype,...
        'MarkerSize', markersize);
    title('constraint history')
    xlabel('iteration')


    hold on
    cons_lim = 0*g + OPT.functions.constraint_limit;
    plot(cons_lim,'Color',0.25*[1,1,1],'LineStyle',':','LineWidth',1.5)
    hold off
    legend(label)
    ylim([-.05,1.8*max(OPT.functions.constraint_limit)]);
end
