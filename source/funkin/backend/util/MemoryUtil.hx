package funkin.backend.util;

/**
 * Utilities for working with the garbage collector.
 *
 * HXCPP is built on Immix.
 * HTML5 builds use the browser's built-in mark-and-sweep and JS has no APIs to interact with it.
 * @see https://www.cs.cornell.edu/courses/cs6120/2019fa/blog/immix/
 * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Memory_management
 * @see https://betterprogramming.pub/deep-dive-into-garbage-collection-in-javascript-6881610239a
 * @see https://github.com/HaxeFoundation/hxcpp/blob/master/docs/build_xml/Defines.md
 * @see cpp.vm.Gc
 */
class MemoryUtil
{
	public static function buildGCInfo():String
	{
		#if cpp
		var result:String = 'HXCPP-Immix:';
		result += '\n- Memory Used: ${cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_USAGE)} bytes';
		result += '\n- Memory Reserved: ${cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_RESERVED)} bytes';
		result += '\n- Memory Current Pool: ${cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_CURRENT)} bytes';
		result += '\n- Memory Large Pool: ${cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_LARGE)} bytes';
		result += '\n- HXCPP Debugger: ${#if HXCPP_DEBUGGER 'Enabled' #else 'Disabled' #end}';
		result += '\n- HXCPP Exp Generational Mode: ${#if HXCPP_GC_GENERATIONAL 'Enabled' #else 'Disabled' #end}';
		result += '\n- HXCPP Exp Moving GC: ${#if HXCPP_GC_MOVING 'Enabled' #else 'Disabled' #end}';
		result += '\n- HXCPP Exp Moving GC: ${#if HXCPP_GC_DYNAMIC_SIZE 'Enabled' #else 'Disabled' #end}';
		result += '\n- HXCPP Exp Moving GC: ${#if HXCPP_GC_BIG_BLOCKS 'Enabled' #else 'Disabled' #end}';
		result += '\n- HXCPP Debug Link: ${#if HXCPP_DEBUG_LINK 'Enabled' #else 'Disabled' #end}';
		result += '\n- HXCPP Stack Trace: ${#if HXCPP_STACK_TRACE 'Enabled' #else 'Disabled' #end}';
		result += '\n- HXCPP Stack Trace Line Numbers: ${#if HXCPP_STACK_LINE 'Enabled' #else 'Disabled' #end}';
		result += '\n- HXCPP Pointer Validation: ${#if HXCPP_CHECK_POINTER 'Enabled' #else 'Disabled' #end}';
		result += '\n- HXCPP Profiler: ${#if HXCPP_PROFILER 'Enabled' #else 'Disabled' #end}';
		result += '\n- HXCPP Local Telemetry: ${#if HXCPP_TELEMETRY 'Enabled' #else 'Disabled' #end}';
		result += '\n- HXCPP C++11: ${#if HXCPP_CPP11 'Enabled' #else 'Disabled' #end}';
		result += '\n- Source Annotation: ${#if annotate_source 'Enabled' #else 'Disabled' #end}';
		#elseif js
		var result:String = 'JS-MNS:';
		result += '\n- Memory Used: ${getMemoryUsed()} bytes';
		#else
		var result:String = 'Unknown GC';
		#end

		return result;
	}

	public static function enableGC(enable:Bool = true):Void
	{
		#if cpp
		cpp.NativeGc.enable(enable);
		cpp.vm.Gc.enable(enable);
		#elseif hl
		hl.Gc.enable(enable);
		#elseif java
		java.vm.Gc.run(enable);
		#elseif neko
		neko.vm.Gc.enable(enable);
		#end
	}

	public static function forceGC(enable:Bool = true):Void
	{
		#if cpp
		cpp.NativeGc.run(enable);
		cpp.vm.Gc.run(enable);
		#elseif hl
		if (enable)
			hl.Gc.major();
		#elseif java
		if (enable)
			java.lang.System.gc();
		#elseif neko
		neko.vm.Gc.run(enable);
		#else
		openfl.system.System.gc();
		#end
	}

	public static function memoryUsage():Int
	{
		#if cpp
		return cast cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
		#elseif java
		var runtime = java.lang.Runtime.getRuntime();
		return cast(runtime.totalMemory() - runtime.freeMemory());
		#else
		return -1;
		#end
	}

	public static function currentMemory():Int
	{
		#if cpp
		return cast cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_CURRENT);
		#else
		return -1;
		#end
	}

	public static function reservedMemory():Int
	{
		#if cpp
		return cast cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_RESERVED);
		#else
		return -1;
		#end
	}

	public static function largeMemory():Int
	{
		#if cpp
		return cast cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_LARGE);
		#else
		return -1;
		#end
	}

	public static function compact():Void
	{
		#if cpp
		cpp.NativeGc.compact();
		cpp.vm.Gc.compact();
		#elseif eval
		eval.Gc.compact();
		#end
	}

	public static function getMemoryStats():MemoryStats
	{
		var stats:MemoryStats = {
			usage: memoryUsage(),
			current: currentMemory(),
			reserved: reservedMemory(),
			large: largeMemory()
		};

		#if hl
		var hlStats = hl.Gc.stats();
		stats.hlTotalAllocated = Std.int(hlStats.totalAllocated);
		stats.hlAllocationCount = Std.int(hlStats.allocationCount);
		#end

		return stats;
	}

	public static function getAccurateRamUsage():Float
	{
		#if windows
		return WindowsMemoryAPI.getProcessMemoryUsage();
		#elseif (linux || android)
		return getLinuxMemoryUsage();
		#elseif mac
		return getMacMemoryUsage();
		#elseif ios
		return getIOSMemoryUsage();
		#else
		#if (openfl || flash)
		return openfl.system.System.totalMemoryNumber;
		#else
		return -1;
		#end
		#end
	}

	// Linux implementation
	// Same for android cuz it's kinda linux too, but idk if there needs using JNI
	#if (linux || android)
	private static function getLinuxMemoryUsage():Float
	{
		#if cpp
		var result:Float = -1.0;
		untyped __cpp__('
            FILE* file = fopen("/proc/self/statm", "r");
            if (file) {
                long pages = 0;
                if (fscanf(file, "%*s%ld", &pages) == 1) {
                    long page_size = sysconf(_SC_PAGESIZE);
                    result = (double)(pages * page_size);
                }
                fclose(file);
            }
        ');
		return result;
		#else
		return -1;
		#end
	}
	#end

	// macOS implementation
	#if mac
	private static function getMacMemoryUsage():Float
	{
		#if cpp
		var result:Float = -1.0;
		untyped __cpp__('
            task_basic_info_data_t taskInfo;
            mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
            if (task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount) == KERN_SUCCESS) {
                result = (double)taskInfo.resident_size;
            }
        ');
		return result;
		#else
		return -1;
		#end
	}
	#end

	// iOS implementation
	#if ios
	private static function getIOSMemoryUsage():Float
	{
		#if cpp
		var result:Float = -1.0;
		untyped __cpp__('
            task_vm_info_data_t vmInfo;
            mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
            if (task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&vmInfo, &count) == KERN_SUCCESS) {
                result = (double)vmInfo.phys_footprint;
            }
        ');
		return result;
		#else
		return -1;
		#end
	}
	#end

	public static function getPeakRamUsage():Float
	{
		#if windows
		return WindowsMemoryAPI.getPeakMemoryUsage();
		#else
		return getAccurateRamUsage();
		#end
	}

	/*public static function getAvailableSystemMemory():Float
	{
		#if windows
		return WindowsMemoryAPI.getAvailableSystemMemory();
		#elseif linux
		#if cpp
		var result:Float = -1.0;
		untyped __cpp__('
            struct sysinfo info;
            if (sysinfo(&info) == 0) {
                result = (double)(info.freeram * info.mem_unit);
            }
        ');
		return result;
		#else
		return -1;
		#end
		#elseif mac
		#if cpp
		var result:Float = -1.0;
		untyped __cpp__('
            vm_size_t page_size;
            vm_statistics64_data_t vm_stats;
            mach_msg_type_number_t host_size = sizeof(vm_stats) / sizeof(natural_t);
            
            if (host_page_size(mach_host_self(), &page_size) == KERN_SUCCESS &&
                host_statistics64(mach_host_self(), HOST_VM_INFO, (host_info64_t)&vm_stats, &host_size) == KERN_SUCCESS) {
                result = (double)((int64_t)vm_stats.free_count * (int64_t)page_size);
            }
        ');
		return result;
		#else
		return -1;
		#end
		#else
		return -1;
		#end
	}*/
}

// С++ MY BELOVED <3
#if windows
@:buildXml("
<target id='haxe'>
    <lib name='psapi.lib' if='windows'/>
    <lib name='kernel32.lib' if='windows || mac || linux || android || ios'/>
</target>
")
@:headerCode('
#include <windows.h>
#include <psapi.h>
')
class WindowsMemoryAPI
{
	public static function getProcessMemoryUsage(moreAccurate:Bool = true):Float
	{
		#if cpp
		var result:Float = -1.0;
		untyped __cpp__('
            PROCESS_MEMORY_COUNTERS_EX pmc;
            if (GetProcessMemoryInfo(GetCurrentProcess(), (PROCESS_MEMORY_COUNTERS*)&pmc, sizeof(pmc))) {
                result = moreAccurate ? (double)pmc.WorkingSetSize : (double)pmc.PrivateUsage;
            }
        ');
		return result;
		#else
		return -1;
		#end
	}

	public static function getPeakMemoryUsage():Float
	{
		#if cpp
		var result:Float = -1.0;
		untyped __cpp__('
            PROCESS_MEMORY_COUNTERS_EX pmc;
            if (GetProcessMemoryInfo(GetCurrentProcess(), (PROCESS_MEMORY_COUNTERS*)&pmc, sizeof(pmc))) {
                result = (double)pmc.PeakPagefileUsage;
            }
        ');
		return result;
		#else
		return -1;
		#end
	}
	/*public static function getAvailableSystemMemory():Float {
		#if cpp
		var result:Float = -1.0;
		untyped __cpp__('
			MEMORYSTATUSEX statex;
			statex.dwLength = sizeof(statex);
			if (GlobalMemoryStatusEx(&statex)) {
				result = (double)statex.ullAvailPhys;
			}
		');
		return result;
		#else
		return -1;
		#end
	}*/
}
#end

@:structInit
class MemoryStats
{
	public var usage:Int;
	public var current:Int;
	public var reserved:Int;
	public var large:Int;

	@:optional public var hlTotalAllocated:Int;
	@:optional public var hlAllocationCount:Int;
}
