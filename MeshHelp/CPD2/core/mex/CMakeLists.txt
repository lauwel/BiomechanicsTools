add_library(cpd_P SHARED cpd_P.c)
target_link_libraries(cpd_P ${Matlab_LIBRARIES})

add_library(cpd_Pappmex SHARED cpd_Pappmex.c)
target_link_libraries(cpd_Pappmex ${Matlab_LIBRARIES})

add_library(cpd_Pcorrespondence SHARED cpd_Pcorrespondence.c)
target_link_libraries(cpd_Pcorrespondence ${Matlab_LIBRARIES})

set_target_properties(cpd_P cpd_Pappmex cpd_Pcorrespondence PROPERTIES
PREFIX "" LINKER_LANGUAGE CXX
LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/"
SUFFIX ".${Matlab_MEX_EXTENSION}")
