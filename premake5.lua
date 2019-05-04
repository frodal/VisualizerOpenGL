------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-- The Visualizer Solution                                                              --
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
workspace "Visualizer"
	architecture "x64"
	startproject "Visualizer"

	configurations
	{
		"Debug",
		"Release"
	}

outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"

-- Include directories relative to root folder (solution directory)
IncludeDir = {}
IncludeDir["GLFW"]  = "Visualizer/vendor/glfw/include"
IncludeDir["GLEW"]  = "Visualizer/vendor/GLEW-2.1.0/include"
IncludeDir["ImGui"] = "Visualizer/vendor/imgui"
IncludeDir["glm"]   = "Visualizer/vendor/glm"
IncludeDir["stb"]   = "Visualizer/vendor/stb"

VendorDir = {}
VendorDir["GLFW"] = "Visualizer/vendor/glfw"
VendorDir["ImGui"] = IncludeDir["ImGui"]

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-- Visualizer                                                                           --
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

project "Visualizer"
	location "Visualizer"
	kind "ConsoleApp"
	language "C++"
	staticruntime "off"

	targetdir ("bin/" .. outputdir .. "/%{prj.name}")
	objdir ("bin/int/" .. outputdir .. "/%{prj.name}")

	pchheader "PreCompiledHeader.h"
	pchsource "Visualizer/src/PreCompiledHeader.cpp"

	files
	{
		"%{prj.name}/src/**.h",
        "%{prj.name}/src/**.cpp",
        "%{prj.name}/vendor/glm/glm/**.hpp",
        "%{prj.name}/vendor/glm/glm/**.h",
		"%{prj.name}/vendor/glm/glm/**.inl"
	}

	includedirs
	{
        "%{prj.name}/src",
		"%{IncludeDir.GLFW}",
		"%{IncludeDir.GLEW}",
        "%{IncludeDir.ImGui}",
        "%{IncludeDir.glm}",
        "%{IncludeDir.stb}"
	}

	links 
	{ 
        "GLFW",
        "ImGui",
		"opengl32.lib"
    }

    filter "architecture:x64"
        links
        {
            "Visualizer/vendor/GLEW-2.1.0/lib/Win64/glew32s.lib"
        }

    filter "architecture:x86"
        links
        {
            "Visualizer/vendor/GLEW-2.1.0/lib/Win32/glew32s.lib"
        }

	filter "system:windows"
		cppdialect "C++17"
		systemversion "latest"

		defines
		{
			"GLEW_STATIC",
			"_CRT_SECURE_NO_WARNINGS"
		}

	filter "configurations:Debug"
		defines "HZ_DEBUG"
		runtime "Debug"
		symbols "On"

	filter "configurations:Release"
		defines "HZ_RELEASE"
		runtime "Release"
		optimize "On"

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-- GLFW                                                                                 --
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
project "GLFW"
    kind "StaticLib"
    language "C"
    
	targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("bin/int/" .. outputdir .. "/%{prj.name}")

	files
	{
        "%{VendorDir.GLFW}/include/GLFW/glfw3.h",
        "%{VendorDir.GLFW}/include/GLFW/glfw3native.h",
        "%{VendorDir.GLFW}/src/glfw_config.h",
        "%{VendorDir.GLFW}/src/context.c",
        "%{VendorDir.GLFW}/src/init.c",
        "%{VendorDir.GLFW}/src/input.c",
        "%{VendorDir.GLFW}/src/monitor.c",
        "%{VendorDir.GLFW}/src/vulkan.c",
        "%{VendorDir.GLFW}/src/window.c"
    }
    
	filter "system:windows"
        systemversion "latest"
        staticruntime "On"
        
        files
        {
            "%{VendorDir.GLFW}/src/win32_init.c",
            "%{VendorDir.GLFW}/src/win32_joystick.c",
            "%{VendorDir.GLFW}/src/win32_monitor.c",
            "%{VendorDir.GLFW}/src/win32_time.c",
            "%{VendorDir.GLFW}/src/win32_thread.c",
            "%{VendorDir.GLFW}/src/win32_window.c",
            "%{VendorDir.GLFW}/src/wgl_context.c",
            "%{VendorDir.GLFW}/src/egl_context.c",
            "%{VendorDir.GLFW}/src/osmesa_context.c"
        }

		defines 
		{ 
            "_GLFW_WIN32",
            "_CRT_SECURE_NO_WARNINGS"
		}
    filter { "system:windows", "configurations:Release" }
        buildoptions "/MT"

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-- ImGui                                                                                --
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
        project "ImGui"
        kind "StaticLib"
        language "C++"
        
        targetdir ("bin/" .. outputdir .. "/%{prj.name}")
        objdir ("bin/int/" .. outputdir .. "/%{prj.name}")
    
        files
        {
            "%{VendorDir.ImGui}/*.h",
            "%{VendorDir.ImGui}/*.cpp",
        }
        
        filter "system:windows"
            systemversion "latest"
            cppdialect "C++17"
            staticruntime "On"
            
        filter { "system:windows", "configurations:Release" }
            buildoptions "/MT"