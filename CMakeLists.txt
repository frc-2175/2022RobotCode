cmake_minimum_required(VERSION 3.24)
include(ExternalProject)
include(FetchContent)

macro(downzip lib url out)
	file(
		DOWNLOAD
		${url}
		"${PROJECT_BINARY_DIR}/zip/${lib}.zip"
	)
	
	file(
		ARCHIVE_EXTRACT
		INPUT "${PROJECT_BINARY_DIR}/zip/${lib}.zip" 
		DESTINATION "${out}"
	)
endmacro()

project(RobotCode)
file(GLOB_RECURSE sources CONFIGURE_DEPENDS "${PROJECT_SOURCE_DIR}/src/main/cpp/*.cpp")
add_executable(${PROJECT_NAME} ${sources})

set_target_properties(${PROJECT_NAME} PROPERTIES CXX_STANDARD 17)
target_compile_options(${PROJECT_NAME} PRIVATE -w)
target_link_options(${PROJECT_NAME} PRIVATE -rdynamic)


if(APPLE)
	set(systype "osx")
elseif(UNIX)
	set(systype "linux")
elseif(WIN32) # yes, even 64 bit windows will be called win32, becauase winclown gotta winclown
	set(systype "windows")
endif()


# WPILIB
option(BUILD_WPILIB OFF)

set(wpilib_year 	"2022")
set(wpilib_version 	"${wpilib_year}.4.1")
set(wpi_url			"https://frcmaven.wpi.edu/artifactory/release/edu/wpi/first")
set(wpi_include_dir "${PROJECT_BINARY_DIR}/wpilib/include")
set(wpi_lib_dir		"${PROJECT_BINARY_DIR}/wpilib/lib")
set(wpi_libs		cameraserver cscore ntcore wpilibc wpimath wpiutil hal)
set(wpi_libs_alt 	cameraserver cscore ntcore wpilibc wpimath wpiutil wpiHal) # for some unknown reason, they replace hal with wpiHal sometimes. 
set(wpi_libs_sim	halsim_ds_socket halsim_gui halsim_ws_client halsim_ws_core halsim_ws_server)

if (BUILD_WPILIB)
	ExternalProject_Add(
		allwpilib
		URL 			"https://codeload.github.com/wpilibsuite/allwpilib/tar.gz/refs/tags/v${wpilib_version}"
		CMAKE_ARGS		-Wno-dev -DWITH_JAVA=OFF -DWITH_TESTS=OFF -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_DOCS=OFF -DGLFW_BUILD_TESTS=OFF -DWPILIB_TARGET_WARNINGS=-w -DCMAKE_INSTALL_PREFIX=${PROJECT_BINARY_DIR}
		PATCH_COMMAND	sed -i -e "s/3755745085ac2e865fd22270cfe9169c26640f70/5f8d7fd191ba22ff2b60c1106d7135bb9a335533/" imgui/CMakeLists.txt.in
	)
	add_dependencies(${PROJECT_NAME} allwpilib)
else()
	foreach(lib lib_alt IN ZIP_LISTS wpi_libs wpi_libs_alt)
		# download & extract compiled libraries
		if(NOT EXISTS "${PROJECT_BINARY_DIR}/binaries/${lib}/")
			downzip(
				${lib}
				"${wpi_url}/${lib}/${lib}-cpp/${wpilib_version}/${lib}-cpp-${wpilib_version}-${systype}x86-64.zip" 
				"${PROJECT_BINARY_DIR}/binaries/${lib}"
			)
		endif()

		file(GLOB objects "${PROJECT_BINARY_DIR}/binaries/${lib}/${systype}/x86-64/shared/*")

		file(
			COPY ${objects}
			DESTINATION "${wpi_lib_dir}"
		)

		# download & extract headers
		if(NOT EXISTS "${PROJECT_BINARY_DIR}/zip/${lib}-headers.zip")
			downzip(
				${lib}-headers
				"${wpi_url}/${lib}/${lib}-cpp/${wpilib_version}/${lib}-cpp-${wpilib_version}-headers.zip" 
				"${wpi_include_dir}/${lib}/"
			)
		endif()
	endforeach()

	foreach(lib ${wpi_libs_sim})
		# download & extract compiled libraries
		if(NOT EXISTS "${PROJECT_BINARY_DIR}/binaries/${lib}/")
			downzip(
				${lib}
				"${wpi_url}/halsim/${lib}/${wpilib_version}/${lib}-${wpilib_version}-${systype}x86-64.zip" 
				"${PROJECT_BINARY_DIR}/binaries/${lib}"
			)
		endif()

		file(GLOB objects "${PROJECT_BINARY_DIR}/binaries/${lib}/${systype}/x86-64/shared/*")

		file(
			COPY ${objects}
			DESTINATION "${wpi_lib_dir}"
		)

		# download & extract headers
		if(NOT EXISTS "${PROJECT_BINARY_DIR}/zip/${lib}-headers.zip")
			downzip(
				${lib}-headers
				"${wpi_url}/halsim/${lib}/${wpilib_version}/${lib}-${wpilib_version}-headers.zip" 
				"${wpi_include_dir}/${lib}/"
			)
		endif()
	endforeach()

	if(NOT EXISTS "${PROJECT_BINARY_DIR}/binaries/opencv/")
		downzip(
			opencv
			"${wpi_url}/thirdparty/frc${wpilib_year}/opencv/opencv-cpp/4.5.2-1/opencv-cpp-4.5.2-1-${systype}x86-64.zip" 
			"${PROJECT_BINARY_DIR}/binaries/opencv"
		)
	endif()

	file(GLOB opencv_libs "${PROJECT_BINARY_DIR}/binaries/opencv/${systype}/x86-64/shared/*")

	file(
		COPY ${opencv_libs}
		DESTINATION "${wpi_lib_dir}"
	)

	if(NOT EXISTS "${PROJECT_BINARY_DIR}/binaries/imgui/")
		downzip(
			imgui
			"${wpi_url}/thirdparty/frc${wpilib_year}/imgui/1.86-1/imgui-1.86-1-${systype}x86-64static.zip" 
			"${PROJECT_BINARY_DIR}/binaries/imgui"
		)
	endif()


	file(GLOB imgui_object "${PROJECT_BINARY_DIR}/binaries/imgui/${systype}/x86-64/static/*")

	file(
		COPY ${imgui_object}
		DESTINATION "${wpi_lib_dir}"
	)
endif()

foreach(lib ${wpi_libs})
	target_include_directories(${PROJECT_NAME} PUBLIC "${wpi_include_dir}/${lib}")
endforeach()


# CTRE
set(ctre_version		"5.21.3")
set(ctre_url 			"https://maven.ctr-electronics.com/release/com/ctre/phoenix")
set(ctre_libs			api-cpp cci wpiapi-cpp)
set(ctre_libs_sim		api-cpp-sim cci-sim simCANCoder simPigeonIMU simTalonFX simTalonSRX simVictorSPX wpiapi-cpp-sim)
set(ctre_lib_dir		"${PROJECT_BINARY_DIR}/ctre/lib")
set(ctre_include_dir	"${PROJECT_BINARY_DIR}/ctre/include")

foreach(lib ${ctre_libs})
	if(NOT EXISTS "${PROJECT_BINARY_DIR}/binaries/${lib}/")
		downzip(
			${lib}
			"${ctre_url}/${lib}/${ctre_version}/${lib}-${ctre_version}-${systype}x86-64.zip" 
			"${PROJECT_BINARY_DIR}/binaries/${lib}"
		)
	endif()

	file(GLOB objects "${PROJECT_BINARY_DIR}/binaries/${lib}/${systype}/x86-64/shared/*")
	
	file(
		COPY ${objects}
		DESTINATION "${ctre_lib_dir}"
	)
endforeach()

foreach(lib ${ctre_libs_sim})
	if(NOT EXISTS "${PROJECT_BINARY_DIR}/binaries/${lib}/")
		downzip(
			${lib}
			"${ctre_url}/sim/${lib}/${ctre_version}/${lib}-${ctre_version}-${systype}x86-64.zip" 
			"${PROJECT_BINARY_DIR}/binaries/${lib}"
		)
	endif()

	file(GLOB objects "${PROJECT_BINARY_DIR}/binaries/${lib}/${systype}/x86-64/shared/*")
	
	file(
		COPY ${objects}
		DESTINATION "${ctre_lib_dir}"
	)

	if(NOT EXISTS "${PROJECT_BINARY_DIR}/zip/${lib}-headers.zip")
		downzip(
			${lib}-headers
			"${ctre_url}/sim/${lib}/${ctre_version}/${lib}-${ctre_version}-headers.zip" 
			"${ctre_include_dir}"
		)
	endif()

	file(GLOB objects "${PROJECT_BINARY_DIR}/binaries/${lib}/${systype}/x86-64/shared/*")
	
	file(
		COPY ${objects}
		DESTINATION "${ctre_lib_dir}"
	)
endforeach()


# REV
set(rev_version		"2022.1.1")
set(rev_url 		"https://github.com/REVrobotics/REV-Software-Binaries/releases/download/revlib-${rev_version}/")
set(rev_libs		REVLib-cpp REVLib-driver)
set(rev_lib_dir		"${PROJECT_BINARY_DIR}/rev/lib")
set(rev_include_dir	"${PROJECT_BINARY_DIR}/rev/include")

foreach(lib ${rev_libs})
	if(NOT EXISTS "${PROJECT_BINARY_DIR}/binaries/${lib}/")
		downzip(
			${lib}
			"${rev_url}/${lib}-${rev_version}-${systype}x86-64.zip" 
			"${PROJECT_BINARY_DIR}/binaries/${lib}"
		)
	endif()

	file(GLOB objects "${PROJECT_BINARY_DIR}/binaries/${lib}/${systype}/x86-64/shared/*")
	
	file(
		COPY ${objects}
		DESTINATION "${rev_lib_dir}"
	)

	if(NOT EXISTS "${PROJECT_BINARY_DIR}/zip/${lib}-headers.zip")
		downzip(
			${lib}-headers
			"${rev_url}/${lib}-${rev_version}-headers.zip" 
			"${rev_include_dir}"
		)
	endif()
endforeach()


# NAVX
set(navx_version 		4.0.447)
set(navx_url 			"https://repo1.maven.org/maven2/com/kauailabs/navx/frc/navx-cpp/${navx_version}")
set(navx_lib_dir		"${PROJECT_BINARY_DIR}/navx/lib")
set(navx_include_dir	"${PROJECT_BINARY_DIR}/navx/include")

if(UNIX)
	downzip(
		navx
		"${navx_url}/navx-cpp-${navx_version}-sources.zip"
		"${PROJECT_BINARY_DIR}/navx/src"
	)

	file(GLOB navx_sources CONFIGURE_DEPENDS "${PROJECT_BINARY_DIR}/navx/src/*.cpp" "${PROJECT_BINARY_DIR}/navx/src/*.h")

	add_library(navx_frc SHARED ${navx_sources})
	set_target_properties(navx_frc PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${navx_lib_dir})

	foreach(lib ${wpi_libs})
		target_include_directories(navx_frc PUBLIC "${wpi_include_dir}/${lib}")
	endforeach()

	downzip(
		navx-headers
		"${navx_url}/navx-cpp-${navx_version}-headers.zip"
		"${navx_include_dir}"
	)
	target_include_directories(navx_frc PUBLIC ${navx_include_dir})

	add_dependencies(${PROJECT_NAME} navx_frc)
elseif(NOT EXISTS "${PROJECT_BINARY_DIR}/binaries/navx/")
	downzip(
		navx
		"${navx_url}/navx-cpp-${navx_version}-${systype}x86-64.zip"
		"${PROJECT_BINARY_DIR}/binaries/navx"
	)

	file(GLOB objects "${PROJECT_BINARY_DIR}/binaries/navx/${systype}/x86-64/shared/*")

	file(
		COPY ${objects}
		DESTINATION "${navx_lib_dir}"
	)

	downzip(
		navx-headers
		"${navx_url}/navx-cpp-${navx_version}-headers.zip"
		"${navx_include_dir}"
	)
endif()

target_include_directories(
	${PROJECT_NAME} PUBLIC
	${PROJECT_SOURCE_DIR}/src/main/include
	${PROJECT_SOURCE_DIR}/include
	${ctre_include_dir}
	${rev_include_dir}
	${navx_include_dir}
)


target_link_directories(
	${PROJECT_NAME} PUBLIC
	${PROJECT_SOURCE_DIR}/lib
	${wpi_lib_dir}
	${ctre_lib_dir}
	${rev_lib_dir}
	${navx_lib_dir}
)

target_link_libraries(
	${PROJECT_NAME}
	${wpi_libs_alt}
	CTRE_Phoenix
	CTRE_PhoenixSim
	CTRE_Phoenix_WPI
	CTRE_Phoenix_WPISim
	CTRE_PhoenixCCI
	CTRE_PhoenixCCISim
	CTRE_SimCANCoder
	CTRE_SimPigeonIMU
	CTRE_SimTalonFX
	CTRE_SimTalonSRX
	CTRE_SimVictorSPX
	REVLib
	REVLibDriver
	navx_frc
	luajit-5.1_linux
)
