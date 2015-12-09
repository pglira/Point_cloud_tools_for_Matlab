function ICP4opalsPlotWindow

while ~isempty(findobj('type', 'figure', 'name', 'ICP results'))

    pause(0.1);
    
end

fprintf(1, 'Plot window closed\n');

end