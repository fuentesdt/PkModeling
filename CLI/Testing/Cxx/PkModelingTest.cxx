#include "itkTestMain.h"

// STD includes
#include <iostream>

#if defined(_WIN32) && !defined(MODULE_STATIC)
#define MODULE_IMPORT __declspec(dllimport)
#else
#define MODULE_IMPORT
#endif

extern "C" MODULE_IMPORT int ModuleEntryPoint(int, char *[]);

int DoNothingAndPass(int argc, char * argv[])
{
  return 0;
}

void RegisterTests()
{
  StringToTestFunctionMap["ModuleEntryPoint"] = ModuleEntryPoint;
  StringToTestFunctionMap["DoNothingAndPass"] = DoNothingAndPass;
}
