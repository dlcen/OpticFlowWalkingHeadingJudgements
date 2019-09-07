function PlotFlowField(x, y, vx, vy, x_limit, y_limit, speed, angle, vec_scale, head_size, cscale, map, lw, gazeat)

    if nargin == 8
		vec_scale = 0.5;
		head_size = 0.5;
		cscale = 2;
        map = pink;
        lw = 1;
        gazeat = 0;
	elseif nargin == 10
		cscale = 2;
        lw  = 1;
        map = pink;
        gazeat = 0;
    elseif nargin == 13
        gazeat = 0;
    end

    figure

    % Have a constant for colorbar scaling
    CC = colormap(map);
    clen = size(CC, 1);

    if cscale > 1 
        clen_addition = (cscale - 1) * clen;
        CC = [CC; repmat(CC(end, :), clen_addition, 1)];
    elseif cscale < 1
        CC = CC(1: ceil(clen * cscale), :);
    end 
    
    c = colorbar; 
    c.Color = [1 1 1];
    % c.Box = 'off';
    caxis([0 max(speed)/cscale]);

    % Sort the data according to the speed magnitude
    [sp_sorted, sorted_id] = sort(speed);
    x_sorted = x(sorted_id);
    y_sorted = y(sorted_id);
    vx_sorted = vx(sorted_id);
    vy_sorted = vy(sorted_id);

    spn = round(sp_sorted/max(sp_sorted(:)) * cscale * clen);

    ndata = length(spn);

    hold on

    for i = 1:ndata
    	ii = int8(round(spn(i)));
    	if ii == 0; ii = 1; end
    	c1 = CC(ii, 1); c2 = CC(ii, 2); c3 = CC(ii, 3);
    	quiver(x_sorted(i), y_sorted(i), vec_scale * vx_sorted(i), vec_scale * vy_sorted(i), 0, 'color', [c1 c2 c3], 'LineWidth', lw, 'MaxHeadSize', head_size);
    end
    
    scatter(gazeat, 0, 25, [0.3010, 0.7450, 0.9330], 'filled')
    plot([angle - 1; angle + 1], [0; 0], 'color', [0.4660, 0.6740, 0.1880], 'LineWidth', 2)
    plot([angle; angle], [-1; 1], 'color', [0.4660, 0.6740, 0.1880], 'LineWidth', 2)

    box on

	xlim([-x_limit, x_limit])
	ylim([-y_limit, y_limit])
	xlabel('Retinal X [°]')
	ylabel('Retinal Y [°]')
	set(gca, 'fontsize', 16)
	set(gcf, 'Units', 'centimeters', 'OuterPosition', [5, 5, 21, 14])
    set(gca, 'color', [0 0 0],'Xcolor','w','Ycolor','w');
    set(gcf, 'color', [0 0 0]);
    set(gcf, 'InvertHardCopy', 'off')
    
end
