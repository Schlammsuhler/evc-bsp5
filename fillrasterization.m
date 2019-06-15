%
% Copyright 2017 Vienna University of Technology.
% Institute of Computer Graphics and Algorithms.
%

function fillrasterization( mesh, framebuffer )
%FILLRASTERIZATION iterates over all faces of mesh and rasterizes them
%       by coloring every pixel in the framebuffer covered by the triangle.
%       Faces with more than 3 vertices are triangulated after the clipping stage.
%     mesh                  ... mesh object to rasterize
%     framebuffer           ... framebuffer
            
    for i=1:numel(mesh.faces)  
        v1 = mesh.getFace(i).getVertex(1);      
        for j=2:mesh.faces(i)-1
            v2 = mesh.getFace(i).getVertex(j);
            v3 = mesh.getFace(i).getVertex(j+1);
            drawTriangle(framebuffer, v1, v2, v3);
        end
    end
end

function drawTriangle( framebuffer, v1, v2, v3 )
%drawTriangle draws a triangle between v1, v2 and v3 into the framebuffer
%   using barycentric coordinates. Therefore the bounding box of the
%   triangle is computed as the minimum and maximum screen coordinates of
%   the given vertices. Then every pixel of this bounding box is traversed
%   and line equations are used to determine whether a pixel is inside or
%   outside the triangle. Furthermore, those line equations are helpful to
%   compute the barycentric coordinates of this pixel. Then the color can
%   be easily interpolated with the MeshVertex.barycentricMix() function.
%     framebuffer           ... framebuffer
%     v1                    ... vertex 1
%     v2                    ... vertex 2
%     v3                    ... vertex 3
    
    [x1, y1, z1] = v1.getScreenCoordinates();
    [x2, y2, z2] = v2.getScreenCoordinates();
    [x3, y3, z3] = v3.getScreenCoordinates();
    c1 = v1.getColor();
    c2 = v2.getColor();
    c3 = v3.getColor();
    
    % Calculate triangle area * 2
    rec = ((x3-x1)*(y2-y1) - (x2-x1)*(y3-y1));
            
    if rec ~= 0
        % Swap order of clockwise triangle to make them counter-clockwise
        if rec < 0
            t = x2; x2 = x3; x3 = t;
            t = y2; y2 = y3; y3 = t;
            t = z2; z2 = z3; z3 = t;
            t = c2; c2 = c3; c3 = t;
        end
        
        v = [x1 y1 1; x2 y2 1; x3 y3 1];
        ve = v([3 1 2], :) - v([2 3 1], :);
        vn = ve(:, [2 1 3]).* [-1 1 1];
        
        c = vn.*v([2 3 1], :);
        c = sum(c, 2)*-1;
        
        d = lineEq(vn(:,1), vn(:,2), c, v(:,1), v(:,2));
        
        low = min(v);
        hi = max(v);
        dif = hi-low + 1;
        vx = repelem(low(1):hi(1), dif(2));
        vy = repmat(low(2):hi(2), 1, dif(1));
        
        dtest = lineEq(vn(:,1), vn(:,2), c, vx, vy);
        enabled = max(dtest) <= 0;
        abc = dtest(:,enabled)./d;
        vx = vx(enabled);
        vy = vy(enabled);
        
        depth = MeshVertex.barycentricMix(z1, z2, z3, abc(1,:)', abc(2,:)', abc(3,:)');
        color = MeshVertex.barycentricMix(c1, c2, c3, abc(1,:)', abc(2,:)', abc(3,:)');
        
        framebuffer.setPixel(vx', vy', depth, color);
        
        %for x = low(1):hi(1)
        %   for y = low(2):hi(2)
        %       dn = lineEq(vnt(1, :), vnt(2, :), c, x, y);
               
        %       if max(dn) <= 0
        %          abc = dn./d;
        %          color = MeshVertex.barycentricMix(c1, c2, c3, abc(1), abc(2), abc(3));
        %          depth = MeshVertex.barycentricMix(z1, z2, z3, abc(1), abc(2), abc(3));
        %          framebuffer.setPixel(x, y, depth, color);
        %       end
        %   end
        %end
        
    end    
end

function res = lineEq(A, B, C, x, y)
%lineEq sets up the necessary line equation and returns the distance of a
%  point (x, y) to the line.
%     A    ... line equation parameter 1
%     B    ... line equation parameter 2
%     C    ... line equation parameter 3
%     x    ... x coordinate of point to test against the line
%     y    ... y coordinate of point to test against the line
%     res  ... distance of the point (x, y) to the line (A, B, C).
    %res = A*x + B*y + C;
    res = A.*x + B.*y + C;
end
