BEGIN {
    # split records by line
    FS="\n";
    # want to split file to records on blank lines
    RS="";
    # initialize count
    count=0;
}

# when a line starts with EXERCISE
/^### EXERCISE/ {
    # increment count
    count += 1;
    # when count matches target command line variable
    if (count == target){
        print;  # default to print entire record
        exit;
    }
}
