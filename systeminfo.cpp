#include <windows.h>
#include <iostream>
#include <string.h>
#include <stdio.h>
#pragma comment(lib, "user32.lib")




/*typedef struct _SYSTEM_INFO {
	union {
		DWORD  dwOemId;  // An obsolete member that is retained for compatibility. Applications should use the wProcessorArchitecture branch of the union.
		struct {
			WORD wProcessorArchitecture; // The processor architecture of the installed operating system. This member can be one of the following values.
			WORD wReserved; // This member is reserved for future use.
		};
	};
	DWORD     dwPageSize; // The page size and the granularity of page protection and commitment. This is the page size used by the VirtualAlloc function.
	LPVOID    lpMinimumApplicationAddress; // A pointer to the lowest memory address accessible to applications and dynamic-link libraries (DLLs).
	LPVOID    lpMaximumApplicationAddress; // A pointer to the highest memory address accessible to applications and DLLs.
	DWORD_PTR dwActiveProcessorMask;  // A mask representing the set of processors configured into the system. Bit 0 is processor 0; bit 31 is processor 31.
	DWORD     dwNumberOfProcessors;  // The number of logical processors in the current group. To retrieve this value, use the GetLogicalProcessorInformation function.
	DWORD     dwProcessorType;  // An obsolete member that is retained for compatibility. Use the wProcessorArchitecture, wProcessorLevel, and wProcessorRevision members to determine the type of processor.
	DWORD     dwAllocationGranularity;  // The granularity for the starting address at which virtual memory can be allocated. For more information, see VirtualAlloc.
	WORD      wProcessorLevel; The architecture-dependent processor level. It should be used only for display purposes. To determine the feature set of a processor, use the IsProcessorFeaturePresent function.
	WORD      wProcessorRevision; The architecture-dependent processor revision. The following table shows how the revision value is assembled for each type of processor architecture.
} SYSTEM_INFO;
*/

// For ProcessorArchitecture
#define CPU_ARCHITECTURE_AMD64 9 // x64(AMD or Intel)
#define CPU_ARCHITECTURE_ARM   5   // ARM
#define CPU_ARCHITECTURE_IA64 6  // Intel Itanium - based
#define CPU_ARCHITECTURE_INTEL 0 // x86
#define CPU_ARCHITECTURE_UNKNOWN 0xffff // Unknown arch

// For processorType
#define CPU_INTEL_386  386
#define CPU_INTEL_486  486
#define CPU_INTEL_PENTIUM 586
#define CPU_INTEL_IA64 2200
#define CPU_AMD_X8664 8664
#define CPU_ARM -1


int main()
{
	SYSTEM_INFO siSysInfo;

	char the_processor_type[10];
	char the_processor_arch[10];

	// Copy the hardware information to the SYSTEM_INFO structure. 
	GetSystemInfo(&siSysInfo);
	// Display the contents of the SYSTEM_INFO structure. 

	printf("Hardware information: \n");

	switch(siSysInfo.dwProcessorType)
	{
		case  CPU_INTEL_386:
			strcpy(the_processor_type,"Intel 368");
		break;
		 
		case CPU_INTEL_486 :
			strcpy(the_processor_type , "Intel 486");
		break;

		case CPU_INTEL_PENTIUM :
			strcpy(the_processor_type,"Intel 586");
		break;

		case CPU_INTEL_IA64 :
			strcpy(the_processor_type ,"Intel IA64");
		break;

		case CPU_AMD_X8664 :
			strcpy(the_processor_type , "Intel x64");
		break;

		case CPU_ARM :
			strcpy(the_processor_type , "ARM?");
		break;

	}


	switch (siSysInfo.wProcessorArchitecture)
	{
		case  CPU_ARCHITECTURE_AMD64:
			strcpy(the_processor_arch, "Intel x64");
		break;

		case CPU_ARCHITECTURE_ARM:
			strcpy(the_processor_arch, "ARM");
		break;

		case CPU_ARCHITECTURE_IA64:
			strcpy(the_processor_arch, "Intel IA64");
		break;

		case CPU_ARCHITECTURE_INTEL:
			strcpy(the_processor_arch, "Intel x86");
		break;

		case CPU_ARCHITECTURE_UNKNOWN:
			strcpy(the_processor_arch, "Unknown Arch.");
		break;

	}
	printf("  Number of processors: %u\n",siSysInfo.dwNumberOfProcessors);
	printf("  Processor type: \t %s\n", the_processor_type);
	printf("  Minimum application address: \t %x\n",siSysInfo.lpMinimumApplicationAddress);
	printf("  Maximum application address: \t %x\n",siSysInfo.lpMaximumApplicationAddress);
	printf("  Page size: \t %u\n", siSysInfo.dwPageSize);
	printf("  Active processor mask: \t 0x%x\n",siSysInfo.dwActiveProcessorMask);
	printf("  Processor :\t  %s \n", the_processor_arch);
	printf("  Processor Level \t %u \n", siSysInfo.wProcessorLevel);
	printf("  Processor Revision \t 0x%x \n", siSysInfo.wProcessorRevision);

	
	return 0;
}