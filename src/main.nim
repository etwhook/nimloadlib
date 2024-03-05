import winim, strformat

{.passC:"-masm=intel".}
proc FetchPEB(): PPEB {.asmNoStackFrame.} =
    asm """
    mov rax, gs:[0x60]
    ret
    """

let peb: PPEB = FetchPEB()
let ldr: PPEB_LDR_DATA = cast[PPEB_LDR_DATA](peb.Ldr)
var pDte: PLDR_DATA_TABLE_ENTRY = cast[PLDR_DATA_TABLE_ENTRY](ldr.InMemoryOrderModuleList.Flink)

proc CustomLoadLibraryA(libName: string): HMODULE =
    while pDte.FullDllName.Length != 0:
        let name = $(pDte.FullDllName.Buffer)
        let handle = cast[HMODULE](pDte.Reserved2[0])
        echo(fmt"{name} -> {handle}")
        if lstrcmpiA(name, libName) == 0:
            echo("[*] Found.")
            return handle
        pDte = (cast[ptr PLDR_DATA_TABLE_ENTRY](pDte))[]

let kernel32 = CustomLoadLibraryA("kernel32.dll")
echo(kernel32)