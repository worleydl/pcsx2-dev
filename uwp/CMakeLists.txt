cmake_minimum_required(VERSION 3.14)
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../cmake)

# Setup UWP platform
set(CMAKE_SYSTEM_NAME WindowsStore)
set(CMAKE_SYSTEM_VERSION 10.0.26100.0)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type (Debug, Release, RelWithDebInfo, MinSizeRel)" FORCE)
endif()

# Define project
project(pcsx2-uwp LANGUAGES CXX)
set_directory_properties(PROPERTIES VS_STARTUP_PROJECT ${PROJECT_NAME})

# Apply main project params since we include a lot of stuff for setup
include(Pcsx2Utils)
check_no_parenthesis_in_path()
detect_operating_system()
detect_compiler()
include(BuildParameters)
add_compile_definitions("${PCSX2_DEFS}")

# Config for core build path 
set(PCSX2_DIR "" CACHE PATH "")
if(NOT PCSX2_DIR)
	message(FATAL_ERROR "PCSX2_DIR must be set to a valid path pointing to the static lib build")
endif()

add_executable(${PROJECT_NAME} WIN32
	src/main.cpp
)

set(BinDeps
	Package.appxmanifest
)
source_group("BinDeps" FILES ${BinDeps})
set_source_files_properties(${BinDeps} PROPERTIES
	VS_COPY_TO_OUT_DIR Always
	VS_DEPLOYMENT_CONTENT TRUE
	VS_DEPLOYMENT_LOCATION "."
)

set(PkgAssets
	Assets/LockScreenLogo.scale-200.png
	Assets/Square44x44Logo.targetsize-24_altform-unplated.png
	Assets/Square44x44Logo.scale-200.png
	Assets/Square150x150Logo.scale-200.png
	Assets/StoreLogo.png
)
source_group("PkgAssets" FILES ${PkgAssets})
set_source_files_properties(${PkgAssets} PROPERTIES
	#VS_COPY_TO_OUT_DIR Always
	VS_DEPLOYMENT_CONTENT TRUE
	VS_DEPLOYMENT_LOCATION "Assets"
)

target_sources(${PROJECT_NAME} PRIVATE
	${BinDeps}
	${PkgAssets}
)

target_include_directories(${PROJECT_NAME} PRIVATE
	# Relies on builds being inside source folder!
	${PCSX2_DIR}/../
	${PCSX2_DIR}/../pcsx2
	${PCSX2_DIR}/../3rdparty/fast_float/include
	${PCSX2_DIR}/../3rdparty/fmt/include
	${PCSX2_DIR}/../3rdparty/simpleini/include
)


# Setup data deployment
file(GLOB_RECURSE DATA_FILES
        RELATIVE ${CMAKE_SOURCE_DIR}/../bin
        ${CMAKE_SOURCE_DIR}/../bin/resources/*
)

foreach(ASSET ${DATA_FILES})
        set(FULL_PATH "${CMAKE_SOURCE_DIR}/../bin/${ASSET}")

        get_filename_component(DEST_DIR ${ASSET} DIRECTORY)

        set_source_files_properties("${FULL_PATH}" PROPERTIES
                VS_COPY_TO_OUT_DIR Always
                VS_DEPLOYMENT_CONTENT TRUE
                VS_DEPLOYMENT_LOCATION "${DEST_DIR}" # preserves folder structure
        )

        target_sources(${PROJECT_NAME} PRIVATE "${FULL_PATH}")
        source_group("BinData" FILES "${FULL_PATH}")
endforeach()

set(BinLibs
	# 3rd party
	${PCSX2_DIR}/3rdparty/ccc/ccc.lib
	${PCSX2_DIR}/3rdparty/cpuinfo/cpuinfo.lib
	${PCSX2_DIR}/3rdparty/cubeb/cubeb.lib
	${PCSX2_DIR}/3rdparty/d3d12memalloc/D3D12MemAlloc.lib
	${PCSX2_DIR}/3rdparty/demangler/demanglegnu.lib
	${PCSX2_DIR}/3rdparty/discord-rpc/discord-rpc.lib
	${PCSX2_DIR}/3rdparty/fmt/fmt.lib # Needs swap config for release/debug
	${PCSX2_DIR}/3rdparty/freesurround/freesurround.lib
	${PCSX2_DIR}/3rdparty/imgui/imgui.lib
	${PCSX2_DIR}/3rdparty/libchdr/libchdr.lib
	${PCSX2_DIR}/3rdparty/libzip/zip.lib
	${PCSX2_DIR}/3rdparty/lzma/pcsx2-lzma.lib
	${PCSX2_DIR}/3rdparty/rainterface/rainterface.lib
	${PCSX2_DIR}/3rdparty/rapidyaml/pcsx2-rapidyaml.lib
	${PCSX2_DIR}/3rdparty/rcheevos/rcheevos.lib
	${PCSX2_DIR}/3rdparty/simpleini/simpleini.lib
	${PCSX2_DIR}/3rdparty/soundtouch/pcsx2-soundtouch.lib
	${PCSX2_DIR}/3rdparty/zydis/zydis.lib

	# vcpkg
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/brotlicommon.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/brotlidec.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/brotlienc.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/bz2.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/freetype.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/harfbuzz.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/jpeg.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/libpng16.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/libsharpyuv.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/libwebp.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/libwebpdecoder.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/libwebpdemux.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/libwebpmux.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/lz4.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/plutosvg.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/plutovg.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/turbojpeg.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/zlib.lib
	${PCSX2_DIR}/vcpkg_installed/x64-windows-static-md/lib/zstd.lib

	# Main bin
	${PCSX2_DIR}/common/common.lib
	# Need this if DISABLE_ADVANCE_SIM is enabled
	${PCSX2_DIR}/PCSX2/GS-avx.lib
	${PCSX2_DIR}/PCSX2/GS-avx2.lib
	${PCSX2_DIR}/PCSX2/GS-sse4.lib
	${PCSX2_DIR}/PCSX2/pcsx2.lib

	# DX stuff
	d3dcompiler.lib
	d3d11.lib
	d3d12.lib
	dxgi.lib

	# Other System
	ws2_32.lib
	OneCore.lib
	WindowsApp.lib
)

target_compile_options(${PROJECT_NAME} PRIVATE /utf-8 /arch:AVX2)
target_link_libraries(${PROJECT_NAME} PRIVATE ${BinLibs})
set_target_properties(${PROJECT_NAME} PROPERTIES VS_WINDOWS_TARGET_PLATFORM_MIN_VERSION 10.0.19041.0)
