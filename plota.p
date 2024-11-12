set datafile separator ","
set terminal png
set output 'gender_histogram.png'
set title "Gender vs Heart Disease"
set xlabel "Gender"
set ylabel "Number of People"
set style data histograms
set style fill solid
set boxwidth 0.5
set xtics ("Female" 0, "Male" 1)
set key autotitle columnheader
plot 'heart.csv' every ::1 using ($2 == 1 ? $14 : 1/0):xtic(2) title "Heart Disease"


