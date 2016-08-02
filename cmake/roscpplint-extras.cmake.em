if (_roscpplint_EXTRAS_INCLUDED_)
  return()
endif()
set(_roscpplint_EXTRAS_INCLUDED_ TRUE)

@[if INSTALLSPACE]@
# bin and template dir variables in installspace
set(roscpplint_SCRIPTS_DIR "${roscpplint_DIR}/../../../@(CATKIN_PACKAGE_BIN_DESTINATION)")
@[else]@
# bin and template dir variables in develspace
set(roscpplint_SCRIPTS_DIR "@(CMAKE_CURRENT_SOURCE_DIR)/scripts")
@[end if]@

macro(_roscpplint_create_targets)
  # Create the master "roscpplint" target if it doesn't exist yet.
  if (NOT TARGET roscpplint)
    add_custom_target(roscpplint)
  endif()

  # Create the "roscpplint_pkgname" target if it doesn't exist yet. Doing this
  # with a check means that multiple linters can share the same target.
  if (NOT TARGET roscpplint_${PROJECT_NAME})
    add_custom_target(roscpplint_${PROJECT_NAME})
    add_dependencies(roscpplint roscpplint_${PROJECT_NAME})
  endif()
endmacro()

# Run a custom lint command on a list of file names.
#
# :param linter: linter command name.
# :param lintopts: linter options.
# :param argn: a non-empty list of files to process.
# :type string
#
function(roscpplint_custom linter lintopts)
  if ("${ARGN}" STREQUAL "")
    message(WARNING "roscpplint: no files provided for command")
  else ()
    _roscpplint_create_targets()
    add_custom_command(TARGET roscpplint_${PROJECT_NAME} POST_BUILD
                       WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
                       COMMAND ${linter} ${lintopts} ${ARGN} VERBATIM)
  endif()
endfunction()

# Run cpplint on a list of file names.
#
function(roscpplint_cpp)
  if ("${ARGN}" STREQUAL "")
    file(GLOB_RECURSE ARGN *.cpp *.h)
  endif()
  if (NOT DEFINED roscpplint_CPP_CMD)
    set(roscpplint_CPP_CMD ${roscpplint_SCRIPTS_DIR}/cpplint)
  endif()
  roscpplint_custom("${roscpplint_CPP_CMD}" "${roscpplint_CPP_OPTS}" ${ARGN})
endfunction()

# Run pep8 on a list of file names.
#
function(roscpplint_python)
  if ("${ARGN}" STREQUAL "")
    file(GLOB_RECURSE ARGN *.py)
  endif()
  if (NOT DEFINED roscpplint_PYTHON_CMD)
    set(roscpplint_PYTHON_CMD ${roscpplint_SCRIPTS_DIR}/pep8)
  endif()
  roscpplint_custom("${roscpplint_PYTHON_CMD}" "${roscpplint_PYTHON_OPTS}" ${ARGN})
endfunction()

# Run roscpplint for this package as a test.
function(roscpplint_add_test)
  catkin_run_tests_target("roscpplint" "package" "roscpplint-${PROJECT_NAME}.xml"
    COMMAND "${roscpplint_SCRIPTS_DIR}/test_wrapper ${CATKIN_TEST_RESULTS_DIR}/${PROJECT_NAME}/roscpplint-${PROJECT_NAME}.xml make roscpplint_${PROJECT_NAME}"
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
endfunction()
