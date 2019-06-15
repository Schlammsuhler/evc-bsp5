%
% Copyright 2017 Vienna University of Technology.
% Institute of Computer Graphics and Algorithms.
%

function [ clipped_mesh ] = clip( mesh, clipping_planes )
%CLIP clips all faces in the mesh M against every clipping plane defined in
%   clipplanes. 
%     mesh              ... mesh object to clip
%     clipping_planes   ... array of clipping planes to clip against
%     clipped_mesh      ... clipped mesh

    clipped_mesh = Mesh;

    for f = 1:numel(mesh.faces)  
        positions = mesh.getFace(f).getVertex(1:mesh.faces(f)).getPosition();
        colors = mesh.getFace(f).getVertex(1:mesh.faces(f)).getColor();
        vertex_count = 3;
        for i = 1:numel(clipping_planes)
            [vertex_count, positions, colors] = clipPlane(vertex_count, positions, colors, clipping_planes(i));
        end 
        if vertex_count ~= 0
            clipped_mesh.addFace(vertex_count, positions, colors);
        end
    end
    
end

function [vertex_count_clipped,  pos_clipped, col_clipped ] = clipPlane(vertex_count, positions, colors, clipping_plane )  
%CLIPPLANE clips all vertices defined in positions against the clipping
%          plane clipping_plane. Clipping is done by using the Sutherland 
%          Hodgman algorithm. 
%     vertex_count          ... number of vertices of the face that is clipped
%     positions             ... n x 4 matrix with positions of n vertices
%                               one row corresponds to one vertex position
%     colors                ... n x 3 matrix with colors of n vertices
%                               one row corresponds to one vertex color
%     clipping_plane        ... plane to clip against
%     vertex_count_clipped  ... number of resulting vertices after clipping; 
%                               this number depends on how the plane intersects 
%                               with the face and therefore is not constant
%     pos_clipped           ... n x 4 matrix with positions of n clipped vertices
%                               one row corresponds to one vertex position
%     col_clipped           ... n x 3 matrix with colors of n clipped vertices
%                               one row corresponds to one vertex color
    
    pos_clipped = zeros(vertex_count + 1, 4);
    col_clipped = zeros(vertex_count + 1, 3);
    vertex_count_clipped = 0;
    
    if vertex_count > 0
        p2 = positions(vertex_count, :);
        c2 = colors(vertex_count, :);
        i2 = inside(clipping_plane, p2);
    end
    
    for i = 1:vertex_count
        p1 = p2;
        c1 = c2;
        i1 = i2;
        c2 = colors(i, :);
        p2 = positions(i, :);
        i2 = inside(clipping_plane, p2);
        
        if i1 && i2
            vertex_count_clipped = vertex_count_clipped + 1;
            pos_clipped(vertex_count_clipped, :) = p2;
            col_clipped(vertex_count_clipped, :) = c2;
        elseif i1
            t = intersect(clipping_plane, p1, p2);
            t = t - 10^-6;
            vertex_count_clipped = vertex_count_clipped + 1;
            pos_clipped(vertex_count_clipped, :) = MeshVertex.mix(p1, p2, t);
            col_clipped(vertex_count_clipped, :) = MeshVertex.mix(c1, c2, t);
        elseif i2
            t = intersect(clipping_plane, p1, p2);
            t = t + 10^-6;
            vertex_count_clipped = vertex_count_clipped + 1;
            pos_clipped(vertex_count_clipped, :) = MeshVertex.mix(p1, p2, t);
            col_clipped(vertex_count_clipped, :) = MeshVertex.mix(c1, c2, t);
            
            vertex_count_clipped = vertex_count_clipped + 1;
            pos_clipped(vertex_count_clipped, :) = p2;
            col_clipped(vertex_count_clipped, :) = c2;
        end
    end
end
