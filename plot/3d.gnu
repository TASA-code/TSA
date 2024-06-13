set terminal png size 1200,800 crop
set output '3d.png'

# Read the data from the file
set datafile separator " "

# Configure the key (legend)
set key at screen 1, 0.9 right top vertical Right noreverse enhanced autotitle nobox

# Style the textbox
set style textbox opaque margins 0.5, 0.5 fc bgnd noborder linewidth 1.0

# Set the view angle
set view 60, 30, 1, 1.1

# Set the sample points and isosamples
set samples 20, 20
set isosamples 21, 21

# Configure contours
set contour base
set cntrparam levels auto 10 unsorted

# Set data style
set style data lines

# Set the title and axis labels
set title "Contours on base grid with labels"
#set xlabel "X axis"
#set ylabel "Y axis"
#set zlabel "Z axis"

# Set the axis ranges
set xrange [ * : * ] noreverse writeback
set x2range [ * : * ] noreverse writeback
set yrange [ * : * ] noreverse writeback
set y2range [ * : * ] noreverse writeback
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback

# Set zlabel offset
set zlabel offset character 1, 0, 0 font "" textcolor lt -1 norotate

# Plot the data from the file
splot 'output.txt' using 1:2:3 with lines title 'Data', \
      'output.txt' using 1:2:3 with labels boxed notitle
