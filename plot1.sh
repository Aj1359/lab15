if [ "$#" -ne 1 ]; then
    echo "Usage: $0 heart.csv"
    exit 1
fi

INPUT_FILE=$1

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found."
    exit 1
fi
#1
awk -F, '{
    if ($2 == "1" && $14 == "1") men_with_disease++;
    if ($2 == "0" && $14 == "1") women_with_disease++;
}
END {
    print 1, men_with_disease > "temp_gender_vs_heart.dat";
    print 0, women_with_disease >> "temp_gender_vs_heart.dat";
}' "$INPUT_FILE"

# Plot using gnuplot
gnuplot -persist <<-EOF
    set terminal png
    set output 'gen_v_heart.png'
    set title "Gender vs Heart Disease"
    set xlabel "Gender (0: Female, 1: Male)"
    set ylabel "Number of People"
    set style data histograms
    set style fill solid
    set boxwidth 0.65
    set xtics ("Female" 0, "Male" 1)
    plot 'temp_gender_vs_heart.dat' using 2:xtic(1) title "Heart Disease"
EOF

rm temp_gender_vs_heart.dat

#2.
awk -F, 'NR > 1 { print $1, $4 }' "$INPUT_FILE" > data2.dat


gnuplot -persist <<-EOF
    set terminal png
    set output 'age_vs_blood_pressure.png'
    set title "Age vs Blood Pressure"
    set xlabel "Age"
    set ylabel "Blood Pressure"
    plot 'data2.dat' using 1:2 with points title "Blood Pressure"
EOF
rm data2.dat
#3
awk -F, '$14 == 0 { print $1, $5 }' "$INPUT_FILE" > data3.dat

# Plot using gnuplot
gnuplot -persist <<-EOF
    set terminal png
    set output 'age_vs_chol_no_disease.png'
    set title "Age vs Cholesterol (No Heart Disease)"
    set xlabel "Age"
    set ylabel "Cholesterol"
    plot 'data3.dat' using 1:2 with linespoints title "Cholesterol"
EOF
rm data3.dat

# 4

awk -F, 'NR > 1 {
    if ($1 >= 40 && $1 < 50 && $14 == 1) age_40_50++;
    if ($1 >= 50 && $1 < 60 && $14 == 1) age_50_60++;
    if ($1 >= 60 && $1 < 70 && $14 == 1) age_60_70++;
    if ($1 >= 70 && $1 < 80 && $14 == 1) age_70_80++;
    if ($1 >= 80 && $1 < 90 && $14 == 1) age_80_90++;
}
END {
    total = age_40_50 + age_50_60 + age_60_70 + age_70_80 + age_80_90;

    if (total > 0) {
        print "40-50", age_40_50 / total * 100 > "temp_age_groups.dat";
        print "50-60", age_50_60 / total * 100 >> "temp_age_groups.dat";
        print "60-70", age_60_70 / total * 100 >> "temp_age_groups.dat";
        print "70-80", age_70_80 / total * 100 >> "temp_age_groups.dat";
        print "80-90", age_80_90 / total * 100 >> "temp_age_groups.dat";
    }
}' "$1"

# Plot using gnuplot (Pie Chart)
gnuplot -persist <<-EOF
    set terminal pngcairo size 600,600
    set output 'age_group_pie_chart.png'
    set title "Age Groups with Heart Disease"
    
    unset key
    unset tics
    unset border
    set size ratio -1

    # Colors for the slices
    colors = "red green blue orange purple"

    # Parameters for the pie chart
    set style fill solid 1.0 border -1
    set angles degrees
    radius = 1.0
    center_x = 0
    center_y = 0

    # Read percentages from the temp file
    stats 'temp_age_groups.dat' using 2 nooutput prefix "group"

    # Initialize cumulative angle
    theta = 0

    # Function to plot a slice of the pie chart
    plot_slice(start, size, color) = "set object circle arc [start:(start + size)] size screen radius at screen center_x,center_y fillstyle solid 1.0 lc rgb color"

    # Plot each slice
    start_angle = 0
    for [i=1:5] {
        size = word(group_col2, i)
        color = word(colors, i)
        call plot_slice(theta, size, color)
        theta = theta + size
    }

EOF

# Clean up the temporary file
rm temp_age_groups.dat

