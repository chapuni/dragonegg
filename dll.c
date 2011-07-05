#include <inttypes.h>
#include <windows.h>
#include <stdlib.h>

extern const char _image_base__[];

#define A(a) (void *)&_image_base__[a]

WINAPI void *__delayLoadHelper2(uint32_t const *desc, void **p)
{
  abort();
  return NULL;
}

static BOOL resolve(uint32_t const *desc)
{
  int i;
  unsigned const *syms = A(desc[4]);
  void **iat = A(desc[3]);
  for (i = 0; syms[i]; i++) {
    IMAGE_IMPORT_BY_NAME const *sym = A(syms[i]);
    iat[i] = GetProcAddress(NULL, (char const *)sym->Name);
    if (!iat[i]) return 0;
  }

  return 1;
}

extern WINAPI BOOL _cygwin_dll_entry(HINSTANCE h, DWORD r, LPVOID d);
extern uint32_t const _DELAY_IMPORT_DESCRIPTOR_libcc1_a[];

WINAPI BOOL lazymain(HINSTANCE h, DWORD r, LPVOID d)
{
  if (r == DLL_PROCESS_ATTACH) {
    if (!resolve(_DELAY_IMPORT_DESCRIPTOR_libcc1_a))
      return 0;
  }

  return _cygwin_dll_entry(h, r, d);
}
