#include <windows.h>

extern const char _SS[], _SE[];
extern FARPROC _AS[], _AE[];

extern BOOL WINAPI _cygwin_dll_entry(HINSTANCE h, DWORD r, LPVOID d);

BOOL WINAPI lazymain(HINSTANCE h, DWORD r, LPVOID d) {
  if (r == DLL_PROCESS_ATTACH) {
    FARPROC *pp = _AS;
    const char *p = _SS;

    while (p < _SE) {
      FARPROC fp;
      const char *name = p;
      p++;
      while (*p++) /*nil*/;
      fp = GetProcAddress((HMODULE)0, name);
      if (!fp) return FALSE;
      *pp++ = fp;
      while (p < _SE && *p == 0) p++;
    }
  }

  return _cygwin_dll_entry(h, r, d);
}
