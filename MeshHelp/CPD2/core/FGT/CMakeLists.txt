add_library(fgt_model SHARED fgt_model.c)
target_link_libraries(fgt_model ${Matlab_LIBRARIES})

add_library(fgt_predict SHARED fgt_predict.c)
target_link_libraries(fgt_predict ${Matlab_LIBRARIES})

set_target_properties(fgt_model fgt_predict PROPERTIES
PREFIX "" LINKER_LANGUAGE CXX
LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/"
SUFFIX ".${Matlab_MEX_EXTENSION}")
