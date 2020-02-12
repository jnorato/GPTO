function writevtk(folder, name_prefix, iteration)
%
% This function writes a vtk file with the mesh and the densities that can
% be plotted with, e.g., ParaView
%
% This function writes an unstructured grid (vtk format) to folder (note
% that the folder is relative to the rooth folder where the main script is
% located).
%
% NOTE: if a vtk file with the same name exists in the folder, it will be
% overwritten.
%

global FE OPT

% Make sure the output folder exists, and if not, create it
if ~exist(OPT.options.vtk_output_path, 'dir')
   mkdir(OPT.options.vtk_output_path);
end

num_digits = numel(num2str(OPT.options.max_iter));
name_sufix = sprintf( strcat('%0', string(num_digits), 'd'), iteration);
filename = strcat(name_prefix, name_sufix, '.vtk');
filename = fullfile(folder, filename);
fid = fopen(filename, 'w');

% Write header
fprintf(fid,"# vtk DataFile Version 1.0 \n");
fprintf(fid, "Bar_TO_3D \n");
fprintf(fid, "ASCII \n");
fprintf(fid, "DATASET UNSTRUCTURED_GRID \n");

% Write nodal coordinates
coords = zeros(3, FE.n_node);
coords(1:FE.dim,:) = FE.coords(1:FE.dim,:);    
fprintf(fid, strcat("POINTS ", string(FE.n_node), " float \n"));
for inode=1:FE.n_node
  if FE.dim == 2
    fprintf(fid, '%f %f \n', coords(:, inode));
  elseif FE.dim == 3
    fprintf(fid, '%f %f %f \n', coords(:, inode));
  end
end

% Write elements
nnodes = 2^FE.dim;  % 4 for quads, 8 for hexas

fprintf(fid, strcat("CELLS ", string(FE.n_elem), " ", ...
        string(FE.n_elem*(nnodes+1)), " \n"));
for iel=1:FE.n_elem
    if FE.dim == 2
      format_spec = '%i %i %i %i %i \n';
      nel = 4;
    elseif FE.dim == 3
      format_spec = '%i %i %i %i %i %i %i %i %i \n';
      nel = 8;
    end
    % IMPORTANT! Vtk numbers nodes from 0, so we subtract 1
    fprintf(fid, format_spec, [nel FE.elem_node(:, iel)'-1]);
end

% Write element types
fprintf(fid, strcat("CELL_TYPES ", string(FE.n_elem), " \n"));
if FE.dim == 2
    elem_type = 9;  % Corresponding to VTK_QUAD
elseif FE.dim == 3
    elem_type = 12; % Corresponding to VTK_HEXAHEDRON
end
for iel=1:FE.n_elem
    fprintf(fid, '%i \n', elem_type);
end

% Write elemental densities
fprintf(fid, strcat("CELL_DATA ", string(FE.n_elem), " \n"));
fprintf(fid, "SCALARS density float 1 \n");
fprintf(fid, "LOOKUP_TABLE default \n");
for iel=1:FE.n_elem
    density = full(OPT.elem_dens(iel));
    fprintf(fid, '%f \n', density);
end

fclose(fid);
