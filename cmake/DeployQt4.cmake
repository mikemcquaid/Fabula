# - Functions to help assemble a standalone Qt4 application.
# A collection of CMake utility functions useful for deploying
# Qt4 applications.
#
# The following functions are provided by this module:
#   fixup_qt4_bundle
#   install_qt4_app
# Requires CMake 2.6 or greater and depends on BundleUtilities.cmake.
#
#  FIXUP_QT4_BUNDLE(<app> <qtplugins> [<libs> <dirs> <plugins_dir>])
# Copies Qt plugins, writes a Qt configuration file (if needed) and fixes up a
# Qt4 executable using BundleUtilities.
#
#  INSTALL_QT4_APP(<executable> <qtplugins> [<libs> <dirs> <plugins_dir>])
# Installs plugins, writes a Qt configuration file (if needed) and fixes up a
# Qt4 executable using BundleUtilties.

#=============================================================================
# Copyright 2011 KDAB
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================

# The functions defined in this file depend on the fixup_bundle function
# (and possibly others) found in BundleUtilities.cmake
#
get_filename_component(DeployQt4_cmake_dir "${CMAKE_CURRENT_LIST_FILE}" PATH)
include(BundleUtilities)

function(fixup_qt4_bundle app qtplugins)
    set(libs ${ARGV2})
    set(dirs ${ARGV3})
    set(plugins_dir ${ARGV4})

    message(STATUS "fixup_qt4_bundle")
    message(STATUS "  app='${app}'")
    message(STATUS "  qtplugins='${qtplugins}'")
    message(STATUS "  libs='${libs}'")
    message(STATUS "  dirs='${dirs}'")
    message(STATUS "  plugins_dir='${plugins_dir}'")

    if(QT_LIBRARY_DIR)
        list(APPEND dirs "${QT_LIBRARY_DIR}")
    endif()

    if(APPLE)
        if(NOT plugins_dir)
            set(plugins_dir "PlugIns")
        endif()
        set(plugins_path "${app}/Contents/${plugins_dir}")
        set(qt_conf_dir "${app}/Contents/Resources")
        set(write_qt_conf 1)
    else()
        if(NOT plugins_dir)
            set(plugins_dir "plugins")
        endif()
        set(plugins_dir ${plugin_inst_dir})
        get_filename_component(app_path "${app}" PATH)
        set(plugins_path "${app_path}/${plugins_dir}")
        set(qt_conf_dir "")
        set(write_qt_conf 0)
    endif()

    foreach(plugin ${qtplugins})
        if(EXISTS "${plugin}")
            set(plugin_group "")

            get_filename_component(plugin_path "${plugin}" PATH)
            get_filename_component(plugin_parent_path "${plugin_path}" PATH)
            get_filename_component(plugin_parent_dir_name "${plugin_parent_path}" NAME)
            get_filename_component(plugin_name "${plugin}" NAME)
            string(TOLOWER "${plugin_parent_dir_name}" plugin_parent_dir_name)

            if("${plugin_parent_dir_name}" STREQUAL "plugins")
                get_filename_component(plugin_group "${plugin_path}" NAME)
                message(STATUS "Matched ${plugin_name} to plugin group ${plugin_group}")
            endif()

            set(plugin_path "${plugins_path}/${plugin_group}")
            message(STATUS "Copying ${plugin_name} to ${plugin_path}")
            file(MAKE_DIRECTORY "${plugin_path}")
            file(COPY "${plugin}" DESTINATION "${plugin_path}")

            list(APPEND libs "${plugin_path}/${plugin_name}")
        else()
            message(FATAL_ERROR "Plugin ${plugin} not found")
        endif()
    endforeach()

    if(qtplugins AND write_qt_conf)
        set(qt_conf_path "${qt_conf_dir}/qt.conf")
        set(qt_conf_contents "[Paths]\nPlugins = ${plugins_dir}")
        message(STATUS "Writing to ${qt_conf_dir}/qt.conf:\n${qt_conf_contents}")
        file(WRITE "${qt_conf_path}" "${qt_conf_contents}")
    endif()

    fixup_bundle("${app}" "${libs}" "${dirs}")
endfunction(fixup_qt4_bundle)

function(install_qt4_app executable qtplugins)
    set(libs ${ARGV2})
    set(dirs ${ARGV3})
    set(plugins_dir ${ARGV4})
    if(QT_LIBRARY_DIR)
        list(APPEND dirs "${QT_LIBRARY_DIR}")
    endif()

    get_filename_component(executable_absolute "${executable}" ABSOLUTE)
    gp_file_type("${executable_absolute}" "${QT_QTCORE_LIBRARY}" qtcore_type)
    if(qtcore_type STREQUAL "system")
        set(qt_plugins_dir "")
    endif()

    foreach(plugin ${qtplugins})
        string(TOUPPER "QT_${plugin}_PLUGIN" plugin_var)
        if(NOT "${plugin}" AND EXISTS "${${plugin_var}_RELEASE}")
            set(plugin "${${plugin_var}_RELEASE}")
        elseif(NOT "${plugin}" AND EXISTS "${plugin_var}_DEBUG")
            set(plugin "${${plugin_var}_DEBUG}")
        endif()

        if(NOT EXISTS "${plugin}")
            message(FATAL_ERROR "Plugin ${plugin} not found")
        endif()

        list(APPEND "${plugin}" qtplugins_paths)
    endforeach()

    install(CODE
" INCLUDE( \"${CMAKE_MODULE_PATH}/DeployQt4.cmake\" )
  SET( BU_CHMOD_BUNDLE_ITEMS TRUE )
  FIXUP_QT4_BUNDLE( \"\${CMAKE_INSTALL_PREFIX}/${executable}\" \"${qtplugins_paths}\" \"${libs}\" \"${dirs}\" \"${plugins_dir}\" ) "
    )
endfunction(install_qt4_app)
