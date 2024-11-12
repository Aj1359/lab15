#!/bin/bash
INPUT_FILE=$1
OUTPUT_FILE="heart_data_table.tex"

echo "\documentclass{article}" > $OUTPUT_FILE
echo "\usepackage{graphicx}" >> $OUTPUT_FILE
echo "\begin{document}" >> $OUTPUT_FILE
echo "\begin{table}[h!]" >> $OUTPUT_FILE
echo "\centering" >> $OUTPUT_FILE
echo "\begin{tabular}{|l|l|l|l|l|l|l|l|l|}" >> $OUTPUT_FILE
echo "\hline" >> $OUTPUT_FILE
# Read the CSV header and format as LaTeX table header
HEADER=$(head -n 1 $INPUT_FILE)
echo $HEADER | awk -F',' '{for(i=1;i<=NF;i++) printf "%s & ", $i}' | sed 's/& $/\\\\ \\hline/' >> $OUTPUT_FILE

tail -n +2 $INPUT_FILE | while IFS=',' read -r col1 col2 col3 col4 col5 col6 col7 col8 col9
do
  echo "$col1 & $col2 & $col3 & $col4 & $col5 & $col6 & $col7 & $col8 & $col9 \\\\ \\hline" >> $OUTPUT_FILE
done
echo "\end{tabular}" >> $OUTPUT_FILE
echo "\caption{Heart Disease Data}" >> $OUTPUT_FILE
echo "\end{table}" >> $OUTPUT_FILE
echo "\end{document}" >> $OUTPUT_FILE
echo "LaTeX file $OUTPUT_FILE generated."

