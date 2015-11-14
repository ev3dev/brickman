set (files
    openroberta-connected12x9
    openroberta-connected16x16
    openroberta-idle12x9
    openroberta-idle16x16
    splash
)

set (generated_files "")
foreach (file ${files})
    set (in_file ${CMAKE_CURRENT_SOURCE_DIR}/${file}.pbm)
    set (out_file ${CMAKE_BINARY_DIR}/${file}.png)
    list (APPEND generated_files ${out_file})
    add_custom_command (
        OUTPUT
            ${out_file}
        COMMAND
            ${CMAKE_COMMAND} -Din_file="${in_file}" -Dout_file="${out_file}" -P ${CMAKE_CURRENT_SOURCE_DIR}/pnmtopng.cmake
        WORKING_DIRECTORY
            ${CMAKE_CURRENT_BINARY_DIR}
        DEPENDS
            ${in_file})
endforeach (file)

add_custom_target (brickman_data
    DEPENDS
        ${generated_files})

install (
    FILES
        ${generated_files}
    DESTINATION
        share/${CMAKE_PROJECT_NAME})