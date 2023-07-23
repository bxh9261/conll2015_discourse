#!/bin/bash

# raw text to json for discourse parsing

###
# PATHS:
# Berkeley Parser command
BP='java -jar berkeleyparser/BerkeleyParser-1.7.jar -gr berkeleyparser/eng_sm6.gr'
# Stanford constituency to dependency conversion command
SC='java -cp bin/stanford-parser.jar edu.stanford.nlp.trees.EnglishGrammaticalStructure -basic -treeFile'
# Tokenization command
TK='java -cp bin/stanford-parser.jar edu.stanford.nlp.process.DocumentPreprocessor'

sdir='scripts'

input_dir='conll2015/raw'  # Specify the input directory containing the text files
output_file="pdtb-parses.json"  # Specify the output file name

# Clear the output file if it exists
echo "" > "$output_file"

# Find all .txt files in the input directory and its subdirectories
find "$input_dir" -type f -name '*.txt' | while read -r raw; do
    out="${raw%.*}"  # Output file name based on the input file name
    
    # Perform parsing steps for the current file
    $TK "$raw" > "$out.tok"
    $BP < "$out.tok" > "$out.ptree"
    $SC "$out.ptree" > "$out.dep"
    
    # Convert the parsed data to JSON format and append it to the output file
    php "$sdir/txt2json.php" -r "$raw" -t "$out.tok" -p "$out.ptree" -d "$out.dep" >> "$output_file"
done
