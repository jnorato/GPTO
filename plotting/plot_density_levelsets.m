function plot_density_levelsets(fig)
%
% Plot level sets of the density into the specified figure
%
global FE OPT

if ~strcmpi(FE.mesh_input.type,'generate') && ...
   ~strcmpi(FE.mesh_input.type,'read-home-made') % mesh was not generated
    error('not yet implemented for non meshgrid conforming meshes')
end

%% Change here whether you want to plot the penalized (i.e., effective) or 
%% the unpenalized (i.e., projected) densities.  By default, we plot the 
%% effective densities.
%
% For penalized, use OPT.penalized_elem_dens;
% For unpenalized, use OPT.elem_dens;

% plot_dens = OPT.elem_dens; 
plot_dens = OPT.penalized_elem_dens;

figure(fig); cla;
g = 1; colormap(flipud(gray(255))*g + (1-g));
if FE.dim == 2
    n = 64;
    levels = linspace(0,1,n);
else 
  levels = [.25,.5,.75];
end

% 2D
if FE.dim == 2
    if ~isfield (OPT.options,'centroid_mesh')
        mn = FE.mesh_input.elements_per_side;
        nm = mn([2,1]); % for meshgrid
        OPT.options.centroid_mesh.shape = nm;
        OPT.options.centroid_mesh.X = reshape(FE.centroids(1,:),nm);
        OPT.options.centroid_mesh.Y = reshape(FE.centroids(2,:),nm);
    end
    X = OPT.options.centroid_mesh.X;
    Y = OPT.options.centroid_mesh.Y;
    V = reshape(plot_dens(:),OPT.options.centroid_mesh.shape);
    cla
    fv = contourf(X,Y,V,levels,'Edgecolor','none');
    axis tight
end
% 3D
if FE.dim == 3
    if ~isfield (OPT.options,'centroid_mesh')
        mnp = FE.mesh_input.elements_per_side;
        nmp = mnp([2,1,3]); % for meshgrid
        OPT.options.centroid_mesh.shape = nmp;
        OPT.options.centroid_mesh.X = reshape(FE.centroids(1,:),nmp);
        OPT.options.centroid_mesh.Y = reshape(FE.centroids(2,:),nmp);
        OPT.options.centroid_mesh.Z = reshape(FE.centroids(3,:),nmp);
    end
    X = OPT.options.centroid_mesh.X;
    Y = OPT.options.centroid_mesh.Y;
    Z = OPT.options.centroid_mesh.Z;
    V = reshape(plot_dens(:),OPT.options.centroid_mesh.shape);

    figure(fig); cla; hold on   
    for level = levels
    fv = isosurface(X,Y,Z,V,level);
    p = patch(fv);
    isonormals(X,Y,Z,V,p);
    p.FaceColor = 0.5*[1,1,1];
    p.EdgeColor = 'none';
    p.FaceAlpha = level;
    end
    hold off;
    daspect([1 1 1])
    view(3); 
    axis tight
    camlight 
    lighting gouraud
end
