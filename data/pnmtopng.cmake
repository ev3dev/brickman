# requires list of files set using -Din_file="file1" -Dout_file="file2"

execute_process (
    COMMAND
        pnmtopng
    INPUT_FILE
        ${in_file}
    OUTPUT_FILE
        ${out_file}
    OUTPUT_VARIABLE
        output
    ERROR_VARIABLE
        error)

