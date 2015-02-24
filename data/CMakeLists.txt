execute_process (
    COMMAND
        pnmtopng
    INPUT_FILE
        ${CMAKE_CURRENT_SOURCE_DIR}/splash.pbm
    OUTPUT_FILE
        ${CMAKE_CURRENT_BINARY_DIR}/splash.png)

install (
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/splash.png
    DESTINATION
        share/${CMAKE_PROJECT_NAME})