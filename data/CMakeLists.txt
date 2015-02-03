execute_process (
    COMMAND
        pnmtopng
    INPUT_FILE
        ${CMAKE_CURRENT_SOURCE_DIR}/splash.pbm
    OUTPUT_FILE
        splash.png)

install (
    FILES
        splash.png
    DESTINATION
        share/${CMAKE_PROJECT_NAME})