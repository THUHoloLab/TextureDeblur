function DelTris = DelTrisList(Pp, tris, tex_w, tex_h)

% vertex and facet delete list, '1' for deleted, '0' for reserve.

DelTris = zeros(size(tris));

DelVtx = (Pp(:,1)<1 | Pp(:,1)>tex_w | Pp(:,2)<1 | Pp(:,2)>tex_h);
DelTris(:) = DelVtx(tris(:));
DelTris = any(DelTris,2);