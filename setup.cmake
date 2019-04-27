# Create the build directory and initalize it

file (MAKE_DIRECTORY build)

execute_process (
    COMMAND ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=string:Debug -DBRICKMAN_TEST=bool:Yes ..
    WORKING_DIRECTORY build
)
