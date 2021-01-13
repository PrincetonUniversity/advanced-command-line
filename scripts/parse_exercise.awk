BEGIN {
    FS="\n";
    RS="\n\n";
    count=0;
}

/^### EXERCISE/ {
    count += 1;
    if (count == target){
        print;
        exit;
    }
}
