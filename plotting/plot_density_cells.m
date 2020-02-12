function plot_density_cells(fig)
%
% Plot the density field into the specified figure
%
global FE OPT

%% Change here whether you want to plot the penalized (i.e., effective) or 
%% the unpenalized (i.e., projected) densities.  By default, we plot the 
%% effective densities.
%
% For penalized, use OPT.penalized_elem_dens;
% For unpenalized, use OPT.elem_dens;
%
% plot_dens = OPT.penalized_elem_dens;
plot_dens = OPT.elem_dens;

%% 2D
if FE.dim == 2
    F = FE.elem_node.'; % matrix of faces to be sent to patch function
    V = FE.coords'; % vertex list to be sent to patch function
end
%% 3D
if FE.dim == 3
    element_face_nodes = ...
        [1,2,3,4;...
         1,2,6,5;...
         2,3,7,6;...
         3,4,8,7;...
         4,1,5,8;...
         5,6,7,8]';
    F = reshape(FE.elem_node(element_face_nodes,:),4,[])';
        V = FE.coords'; % vertex lest to be sent to patch function
end
    figure(fig); cla; hold on   
    
    % for n levels of opacity color
    n = 64;
    level = linspace(0,1,n+1);
    for i = n:-1:1 %1:n
        low = level(i);
        high = level(i+1);
        alpha= low;
        if FE.dim == 3
            C = repmat(min(plot_dens(:).',1),[6,1]);
            f = low < C & C <= high;
            p = patch('Faces',F(f,:),'Vertices',V) ;
        else
            C = min(plot_dens(:).',1);
            f = low < C & C <= high;
            p = patch('Faces',F(f,:),'Vertices',V) ;
        end
        p.FaceColor = [0,0,0]; 
        p.FaceAlpha = alpha; 
        p.EdgeColor = [0,0,0]; 
        p.EdgeAlpha = 0.05 + alpha*(1 -0.05); 
    end
end
