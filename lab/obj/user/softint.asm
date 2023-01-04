
obj/user/softint.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 87 04 00 00       	call   800512 <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 aa 1d 80 00       	push   $0x801daa
  800104:	6a 23                	push   $0x23
  800106:	68 c7 1d 80 00       	push   $0x801dc7
  80010b:	e8 14 0f 00 00       	call   801024 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 aa 1d 80 00       	push   $0x801daa
  800185:	6a 23                	push   $0x23
  800187:	68 c7 1d 80 00       	push   $0x801dc7
  80018c:	e8 93 0e 00 00       	call   801024 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 aa 1d 80 00       	push   $0x801daa
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 c7 1d 80 00       	push   $0x801dc7
  8001ce:	e8 51 0e 00 00       	call   801024 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 aa 1d 80 00       	push   $0x801daa
  800209:	6a 23                	push   $0x23
  80020b:	68 c7 1d 80 00       	push   $0x801dc7
  800210:	e8 0f 0e 00 00       	call   801024 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 aa 1d 80 00       	push   $0x801daa
  80024b:	6a 23                	push   $0x23
  80024d:	68 c7 1d 80 00       	push   $0x801dc7
  800252:	e8 cd 0d 00 00       	call   801024 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 aa 1d 80 00       	push   $0x801daa
  80028d:	6a 23                	push   $0x23
  80028f:	68 c7 1d 80 00       	push   $0x801dc7
  800294:	e8 8b 0d 00 00       	call   801024 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7e 17                	jle    8002db <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 0a                	push   $0xa
  8002ca:	68 aa 1d 80 00       	push   $0x801daa
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 c7 1d 80 00       	push   $0x801dc7
  8002d6:	e8 49 0d 00 00       	call   801024 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	b8 0d 00 00 00       	mov    $0xd,%eax
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 17                	jle    80033f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	50                   	push   %eax
  80032c:	6a 0d                	push   $0xd
  80032e:	68 aa 1d 80 00       	push   $0x801daa
  800333:	6a 23                	push   $0x23
  800335:	68 c7 1d 80 00       	push   $0x801dc7
  80033a:	e8 e5 0c 00 00       	call   801024 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	05 00 00 00 30       	add    $0x30000000,%eax
  800352:	c1 e8 0c             	shr    $0xc,%eax
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800367:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800379:	89 c2                	mov    %eax,%edx
  80037b:	c1 ea 16             	shr    $0x16,%edx
  80037e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800385:	f6 c2 01             	test   $0x1,%dl
  800388:	74 11                	je     80039b <fd_alloc+0x2d>
  80038a:	89 c2                	mov    %eax,%edx
  80038c:	c1 ea 0c             	shr    $0xc,%edx
  80038f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800396:	f6 c2 01             	test   $0x1,%dl
  800399:	75 09                	jne    8003a4 <fd_alloc+0x36>
			*fd_store = fd;
  80039b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039d:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a2:	eb 17                	jmp    8003bb <fd_alloc+0x4d>
  8003a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ae:	75 c9                	jne    800379 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c3:	83 f8 1f             	cmp    $0x1f,%eax
  8003c6:	77 36                	ja     8003fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
  8003cb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	c1 ea 16             	shr    $0x16,%edx
  8003d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dc:	f6 c2 01             	test   $0x1,%dl
  8003df:	74 24                	je     800405 <fd_lookup+0x48>
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	c1 ea 0c             	shr    $0xc,%edx
  8003e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ed:	f6 c2 01             	test   $0x1,%dl
  8003f0:	74 1a                	je     80040c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	eb 13                	jmp    800411 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800403:	eb 0c                	jmp    800411 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040a:	eb 05                	jmp    800411 <fd_lookup+0x54>
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041c:	ba 54 1e 80 00       	mov    $0x801e54,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800421:	eb 13                	jmp    800436 <dev_lookup+0x23>
  800423:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800426:	39 08                	cmp    %ecx,(%eax)
  800428:	75 0c                	jne    800436 <dev_lookup+0x23>
			*dev = devtab[i];
  80042a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
  800434:	eb 2e                	jmp    800464 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800436:	8b 02                	mov    (%edx),%eax
  800438:	85 c0                	test   %eax,%eax
  80043a:	75 e7                	jne    800423 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043c:	a1 04 40 80 00       	mov    0x804004,%eax
  800441:	8b 40 48             	mov    0x48(%eax),%eax
  800444:	83 ec 04             	sub    $0x4,%esp
  800447:	51                   	push   %ecx
  800448:	50                   	push   %eax
  800449:	68 d8 1d 80 00       	push   $0x801dd8
  80044e:	e8 aa 0c 00 00       	call   8010fd <cprintf>
	*dev = 0;
  800453:	8b 45 0c             	mov    0xc(%ebp),%eax
  800456:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800464:	c9                   	leave  
  800465:	c3                   	ret    

00800466 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	56                   	push   %esi
  80046a:	53                   	push   %ebx
  80046b:	83 ec 10             	sub    $0x10,%esp
  80046e:	8b 75 08             	mov    0x8(%ebp),%esi
  800471:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800477:	50                   	push   %eax
  800478:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047e:	c1 e8 0c             	shr    $0xc,%eax
  800481:	50                   	push   %eax
  800482:	e8 36 ff ff ff       	call   8003bd <fd_lookup>
  800487:	83 c4 08             	add    $0x8,%esp
  80048a:	85 c0                	test   %eax,%eax
  80048c:	78 05                	js     800493 <fd_close+0x2d>
	    || fd != fd2)
  80048e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800491:	74 0c                	je     80049f <fd_close+0x39>
		return (must_exist ? r : 0);
  800493:	84 db                	test   %bl,%bl
  800495:	ba 00 00 00 00       	mov    $0x0,%edx
  80049a:	0f 44 c2             	cmove  %edx,%eax
  80049d:	eb 41                	jmp    8004e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a5:	50                   	push   %eax
  8004a6:	ff 36                	pushl  (%esi)
  8004a8:	e8 66 ff ff ff       	call   800413 <dev_lookup>
  8004ad:	89 c3                	mov    %eax,%ebx
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	78 1a                	js     8004d0 <fd_close+0x6a>
		if (dev->dev_close)
  8004b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	74 0b                	je     8004d0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c5:	83 ec 0c             	sub    $0xc,%esp
  8004c8:	56                   	push   %esi
  8004c9:	ff d0                	call   *%eax
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	56                   	push   %esi
  8004d4:	6a 00                	push   $0x0
  8004d6:	e8 00 fd ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	89 d8                	mov    %ebx,%eax
}
  8004e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e3:	5b                   	pop    %ebx
  8004e4:	5e                   	pop    %esi
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f0:	50                   	push   %eax
  8004f1:	ff 75 08             	pushl  0x8(%ebp)
  8004f4:	e8 c4 fe ff ff       	call   8003bd <fd_lookup>
  8004f9:	83 c4 08             	add    $0x8,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 10                	js     800510 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	6a 01                	push   $0x1
  800505:	ff 75 f4             	pushl  -0xc(%ebp)
  800508:	e8 59 ff ff ff       	call   800466 <fd_close>
  80050d:	83 c4 10             	add    $0x10,%esp
}
  800510:	c9                   	leave  
  800511:	c3                   	ret    

00800512 <close_all>:

void
close_all(void)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	53                   	push   %ebx
  800516:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800519:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	53                   	push   %ebx
  800522:	e8 c0 ff ff ff       	call   8004e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800527:	83 c3 01             	add    $0x1,%ebx
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	83 fb 20             	cmp    $0x20,%ebx
  800530:	75 ec                	jne    80051e <close_all+0xc>
		close(i);
}
  800532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	57                   	push   %edi
  80053b:	56                   	push   %esi
  80053c:	53                   	push   %ebx
  80053d:	83 ec 2c             	sub    $0x2c,%esp
  800540:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800543:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800546:	50                   	push   %eax
  800547:	ff 75 08             	pushl  0x8(%ebp)
  80054a:	e8 6e fe ff ff       	call   8003bd <fd_lookup>
  80054f:	83 c4 08             	add    $0x8,%esp
  800552:	85 c0                	test   %eax,%eax
  800554:	0f 88 c1 00 00 00    	js     80061b <dup+0xe4>
		return r;
	close(newfdnum);
  80055a:	83 ec 0c             	sub    $0xc,%esp
  80055d:	56                   	push   %esi
  80055e:	e8 84 ff ff ff       	call   8004e7 <close>

	newfd = INDEX2FD(newfdnum);
  800563:	89 f3                	mov    %esi,%ebx
  800565:	c1 e3 0c             	shl    $0xc,%ebx
  800568:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056e:	83 c4 04             	add    $0x4,%esp
  800571:	ff 75 e4             	pushl  -0x1c(%ebp)
  800574:	e8 de fd ff ff       	call   800357 <fd2data>
  800579:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057b:	89 1c 24             	mov    %ebx,(%esp)
  80057e:	e8 d4 fd ff ff       	call   800357 <fd2data>
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800589:	89 f8                	mov    %edi,%eax
  80058b:	c1 e8 16             	shr    $0x16,%eax
  80058e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800595:	a8 01                	test   $0x1,%al
  800597:	74 37                	je     8005d0 <dup+0x99>
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 0c             	shr    $0xc,%eax
  80059e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a5:	f6 c2 01             	test   $0x1,%dl
  8005a8:	74 26                	je     8005d0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b1:	83 ec 0c             	sub    $0xc,%esp
  8005b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b9:	50                   	push   %eax
  8005ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bd:	6a 00                	push   $0x0
  8005bf:	57                   	push   %edi
  8005c0:	6a 00                	push   $0x0
  8005c2:	e8 d2 fb ff ff       	call   800199 <sys_page_map>
  8005c7:	89 c7                	mov    %eax,%edi
  8005c9:	83 c4 20             	add    $0x20,%esp
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	78 2e                	js     8005fe <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d3:	89 d0                	mov    %edx,%eax
  8005d5:	c1 e8 0c             	shr    $0xc,%eax
  8005d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e7:	50                   	push   %eax
  8005e8:	53                   	push   %ebx
  8005e9:	6a 00                	push   $0x0
  8005eb:	52                   	push   %edx
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 a6 fb ff ff       	call   800199 <sys_page_map>
  8005f3:	89 c7                	mov    %eax,%edi
  8005f5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	79 1d                	jns    80061b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 00                	push   $0x0
  800604:	e8 d2 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060f:	6a 00                	push   $0x0
  800611:	e8 c5 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	89 f8                	mov    %edi,%eax
}
  80061b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061e:	5b                   	pop    %ebx
  80061f:	5e                   	pop    %esi
  800620:	5f                   	pop    %edi
  800621:	5d                   	pop    %ebp
  800622:	c3                   	ret    

00800623 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800623:	55                   	push   %ebp
  800624:	89 e5                	mov    %esp,%ebp
  800626:	53                   	push   %ebx
  800627:	83 ec 14             	sub    $0x14,%esp
  80062a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800630:	50                   	push   %eax
  800631:	53                   	push   %ebx
  800632:	e8 86 fd ff ff       	call   8003bd <fd_lookup>
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	89 c2                	mov    %eax,%edx
  80063c:	85 c0                	test   %eax,%eax
  80063e:	78 6d                	js     8006ad <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800646:	50                   	push   %eax
  800647:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064a:	ff 30                	pushl  (%eax)
  80064c:	e8 c2 fd ff ff       	call   800413 <dev_lookup>
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	85 c0                	test   %eax,%eax
  800656:	78 4c                	js     8006a4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800658:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065b:	8b 42 08             	mov    0x8(%edx),%eax
  80065e:	83 e0 03             	and    $0x3,%eax
  800661:	83 f8 01             	cmp    $0x1,%eax
  800664:	75 21                	jne    800687 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800666:	a1 04 40 80 00       	mov    0x804004,%eax
  80066b:	8b 40 48             	mov    0x48(%eax),%eax
  80066e:	83 ec 04             	sub    $0x4,%esp
  800671:	53                   	push   %ebx
  800672:	50                   	push   %eax
  800673:	68 19 1e 80 00       	push   $0x801e19
  800678:	e8 80 0a 00 00       	call   8010fd <cprintf>
		return -E_INVAL;
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800685:	eb 26                	jmp    8006ad <read+0x8a>
	}
	if (!dev->dev_read)
  800687:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068a:	8b 40 08             	mov    0x8(%eax),%eax
  80068d:	85 c0                	test   %eax,%eax
  80068f:	74 17                	je     8006a8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800691:	83 ec 04             	sub    $0x4,%esp
  800694:	ff 75 10             	pushl  0x10(%ebp)
  800697:	ff 75 0c             	pushl  0xc(%ebp)
  80069a:	52                   	push   %edx
  80069b:	ff d0                	call   *%eax
  80069d:	89 c2                	mov    %eax,%edx
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	eb 09                	jmp    8006ad <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a4:	89 c2                	mov    %eax,%edx
  8006a6:	eb 05                	jmp    8006ad <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ad:	89 d0                	mov    %edx,%eax
  8006af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	57                   	push   %edi
  8006b8:	56                   	push   %esi
  8006b9:	53                   	push   %ebx
  8006ba:	83 ec 0c             	sub    $0xc,%esp
  8006bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c8:	eb 21                	jmp    8006eb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ca:	83 ec 04             	sub    $0x4,%esp
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	29 d8                	sub    %ebx,%eax
  8006d1:	50                   	push   %eax
  8006d2:	89 d8                	mov    %ebx,%eax
  8006d4:	03 45 0c             	add    0xc(%ebp),%eax
  8006d7:	50                   	push   %eax
  8006d8:	57                   	push   %edi
  8006d9:	e8 45 ff ff ff       	call   800623 <read>
		if (m < 0)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	78 10                	js     8006f5 <readn+0x41>
			return m;
		if (m == 0)
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	74 0a                	je     8006f3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e9:	01 c3                	add    %eax,%ebx
  8006eb:	39 f3                	cmp    %esi,%ebx
  8006ed:	72 db                	jb     8006ca <readn+0x16>
  8006ef:	89 d8                	mov    %ebx,%eax
  8006f1:	eb 02                	jmp    8006f5 <readn+0x41>
  8006f3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5f                   	pop    %edi
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	53                   	push   %ebx
  800701:	83 ec 14             	sub    $0x14,%esp
  800704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800707:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	53                   	push   %ebx
  80070c:	e8 ac fc ff ff       	call   8003bd <fd_lookup>
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	89 c2                	mov    %eax,%edx
  800716:	85 c0                	test   %eax,%eax
  800718:	78 68                	js     800782 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800720:	50                   	push   %eax
  800721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800724:	ff 30                	pushl  (%eax)
  800726:	e8 e8 fc ff ff       	call   800413 <dev_lookup>
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	85 c0                	test   %eax,%eax
  800730:	78 47                	js     800779 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800739:	75 21                	jne    80075c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073b:	a1 04 40 80 00       	mov    0x804004,%eax
  800740:	8b 40 48             	mov    0x48(%eax),%eax
  800743:	83 ec 04             	sub    $0x4,%esp
  800746:	53                   	push   %ebx
  800747:	50                   	push   %eax
  800748:	68 35 1e 80 00       	push   $0x801e35
  80074d:	e8 ab 09 00 00       	call   8010fd <cprintf>
		return -E_INVAL;
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075a:	eb 26                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075f:	8b 52 0c             	mov    0xc(%edx),%edx
  800762:	85 d2                	test   %edx,%edx
  800764:	74 17                	je     80077d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	ff 75 10             	pushl  0x10(%ebp)
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	50                   	push   %eax
  800770:	ff d2                	call   *%edx
  800772:	89 c2                	mov    %eax,%edx
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	eb 09                	jmp    800782 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800779:	89 c2                	mov    %eax,%edx
  80077b:	eb 05                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800782:	89 d0                	mov    %edx,%eax
  800784:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <seek>:

int
seek(int fdnum, off_t offset)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800792:	50                   	push   %eax
  800793:	ff 75 08             	pushl  0x8(%ebp)
  800796:	e8 22 fc ff ff       	call   8003bd <fd_lookup>
  80079b:	83 c4 08             	add    $0x8,%esp
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	78 0e                	js     8007b0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	83 ec 14             	sub    $0x14,%esp
  8007b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bf:	50                   	push   %eax
  8007c0:	53                   	push   %ebx
  8007c1:	e8 f7 fb ff ff       	call   8003bd <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	89 c2                	mov    %eax,%edx
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	78 65                	js     800834 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d9:	ff 30                	pushl  (%eax)
  8007db:	e8 33 fc ff ff       	call   800413 <dev_lookup>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	78 44                	js     80082b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ee:	75 21                	jne    800811 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f5:	8b 40 48             	mov    0x48(%eax),%eax
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	53                   	push   %ebx
  8007fc:	50                   	push   %eax
  8007fd:	68 f8 1d 80 00       	push   $0x801df8
  800802:	e8 f6 08 00 00       	call   8010fd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080f:	eb 23                	jmp    800834 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800811:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800814:	8b 52 18             	mov    0x18(%edx),%edx
  800817:	85 d2                	test   %edx,%edx
  800819:	74 14                	je     80082f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	ff 75 0c             	pushl  0xc(%ebp)
  800821:	50                   	push   %eax
  800822:	ff d2                	call   *%edx
  800824:	89 c2                	mov    %eax,%edx
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	eb 09                	jmp    800834 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082b:	89 c2                	mov    %eax,%edx
  80082d:	eb 05                	jmp    800834 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800834:	89 d0                	mov    %edx,%eax
  800836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 14             	sub    $0x14,%esp
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800845:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	ff 75 08             	pushl  0x8(%ebp)
  80084c:	e8 6c fb ff ff       	call   8003bd <fd_lookup>
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	89 c2                	mov    %eax,%edx
  800856:	85 c0                	test   %eax,%eax
  800858:	78 58                	js     8008b2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800860:	50                   	push   %eax
  800861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800864:	ff 30                	pushl  (%eax)
  800866:	e8 a8 fb ff ff       	call   800413 <dev_lookup>
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	85 c0                	test   %eax,%eax
  800870:	78 37                	js     8008a9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800875:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800879:	74 32                	je     8008ad <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800885:	00 00 00 
	stat->st_isdir = 0;
  800888:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088f:	00 00 00 
	stat->st_dev = dev;
  800892:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	53                   	push   %ebx
  80089c:	ff 75 f0             	pushl  -0x10(%ebp)
  80089f:	ff 50 14             	call   *0x14(%eax)
  8008a2:	89 c2                	mov    %eax,%edx
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	eb 09                	jmp    8008b2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a9:	89 c2                	mov    %eax,%edx
  8008ab:	eb 05                	jmp    8008b2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b2:	89 d0                	mov    %edx,%eax
  8008b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	6a 00                	push   $0x0
  8008c3:	ff 75 08             	pushl  0x8(%ebp)
  8008c6:	e8 d6 01 00 00       	call   800aa1 <open>
  8008cb:	89 c3                	mov    %eax,%ebx
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	78 1b                	js     8008ef <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	50                   	push   %eax
  8008db:	e8 5b ff ff ff       	call   80083b <fstat>
  8008e0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e2:	89 1c 24             	mov    %ebx,(%esp)
  8008e5:	e8 fd fb ff ff       	call   8004e7 <close>
	return r;
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	89 f0                	mov    %esi,%eax
}
  8008ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	89 c6                	mov    %eax,%esi
  8008fd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008ff:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800906:	75 12                	jne    80091a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800908:	83 ec 0c             	sub    $0xc,%esp
  80090b:	6a 01                	push   $0x1
  80090d:	e8 72 11 00 00       	call   801a84 <ipc_find_env>
  800912:	a3 00 40 80 00       	mov    %eax,0x804000
  800917:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091a:	6a 07                	push   $0x7
  80091c:	68 00 50 80 00       	push   $0x805000
  800921:	56                   	push   %esi
  800922:	ff 35 00 40 80 00    	pushl  0x804000
  800928:	e8 03 11 00 00       	call   801a30 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80092d:	83 c4 0c             	add    $0xc,%esp
  800930:	6a 00                	push   $0x0
  800932:	53                   	push   %ebx
  800933:	6a 00                	push   $0x0
  800935:	e8 8f 10 00 00       	call   8019c9 <ipc_recv>
}
  80093a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 40 0c             	mov    0xc(%eax),%eax
  80094d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	b8 02 00 00 00       	mov    $0x2,%eax
  800964:	e8 8d ff ff ff       	call   8008f6 <fsipc>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 40 0c             	mov    0xc(%eax),%eax
  800977:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
  800981:	b8 06 00 00 00       	mov    $0x6,%eax
  800986:	e8 6b ff ff ff       	call   8008f6 <fsipc>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	53                   	push   %ebx
  800991:	83 ec 04             	sub    $0x4,%esp
  800994:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 40 0c             	mov    0xc(%eax),%eax
  80099d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ac:	e8 45 ff ff ff       	call   8008f6 <fsipc>
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	78 2c                	js     8009e1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b5:	83 ec 08             	sub    $0x8,%esp
  8009b8:	68 00 50 80 00       	push   $0x805000
  8009bd:	53                   	push   %ebx
  8009be:	e8 bf 0c 00 00       	call   801682 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ce:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d9:	83 c4 10             	add    $0x10,%esp
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	83 ec 0c             	sub    $0xc,%esp
  8009ec:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f2:	8b 52 0c             	mov    0xc(%edx),%edx
  8009f5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009fb:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a00:	50                   	push   %eax
  800a01:	ff 75 0c             	pushl  0xc(%ebp)
  800a04:	68 08 50 80 00       	push   $0x805008
  800a09:	e8 06 0e 00 00       	call   801814 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a13:	b8 04 00 00 00       	mov    $0x4,%eax
  800a18:	e8 d9 fe ff ff       	call   8008f6 <fsipc>

}
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a32:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a38:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a42:	e8 af fe ff ff       	call   8008f6 <fsipc>
  800a47:	89 c3                	mov    %eax,%ebx
  800a49:	85 c0                	test   %eax,%eax
  800a4b:	78 4b                	js     800a98 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a4d:	39 c6                	cmp    %eax,%esi
  800a4f:	73 16                	jae    800a67 <devfile_read+0x48>
  800a51:	68 64 1e 80 00       	push   $0x801e64
  800a56:	68 6b 1e 80 00       	push   $0x801e6b
  800a5b:	6a 7c                	push   $0x7c
  800a5d:	68 80 1e 80 00       	push   $0x801e80
  800a62:	e8 bd 05 00 00       	call   801024 <_panic>
	assert(r <= PGSIZE);
  800a67:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a6c:	7e 16                	jle    800a84 <devfile_read+0x65>
  800a6e:	68 8b 1e 80 00       	push   $0x801e8b
  800a73:	68 6b 1e 80 00       	push   $0x801e6b
  800a78:	6a 7d                	push   $0x7d
  800a7a:	68 80 1e 80 00       	push   $0x801e80
  800a7f:	e8 a0 05 00 00       	call   801024 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a84:	83 ec 04             	sub    $0x4,%esp
  800a87:	50                   	push   %eax
  800a88:	68 00 50 80 00       	push   $0x805000
  800a8d:	ff 75 0c             	pushl  0xc(%ebp)
  800a90:	e8 7f 0d 00 00       	call   801814 <memmove>
	return r;
  800a95:	83 c4 10             	add    $0x10,%esp
}
  800a98:	89 d8                	mov    %ebx,%eax
  800a9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	53                   	push   %ebx
  800aa5:	83 ec 20             	sub    $0x20,%esp
  800aa8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aab:	53                   	push   %ebx
  800aac:	e8 98 0b 00 00       	call   801649 <strlen>
  800ab1:	83 c4 10             	add    $0x10,%esp
  800ab4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab9:	7f 67                	jg     800b22 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800abb:	83 ec 0c             	sub    $0xc,%esp
  800abe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac1:	50                   	push   %eax
  800ac2:	e8 a7 f8 ff ff       	call   80036e <fd_alloc>
  800ac7:	83 c4 10             	add    $0x10,%esp
		return r;
  800aca:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800acc:	85 c0                	test   %eax,%eax
  800ace:	78 57                	js     800b27 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ad0:	83 ec 08             	sub    $0x8,%esp
  800ad3:	53                   	push   %ebx
  800ad4:	68 00 50 80 00       	push   $0x805000
  800ad9:	e8 a4 0b 00 00       	call   801682 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ae6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aee:	e8 03 fe ff ff       	call   8008f6 <fsipc>
  800af3:	89 c3                	mov    %eax,%ebx
  800af5:	83 c4 10             	add    $0x10,%esp
  800af8:	85 c0                	test   %eax,%eax
  800afa:	79 14                	jns    800b10 <open+0x6f>
		fd_close(fd, 0);
  800afc:	83 ec 08             	sub    $0x8,%esp
  800aff:	6a 00                	push   $0x0
  800b01:	ff 75 f4             	pushl  -0xc(%ebp)
  800b04:	e8 5d f9 ff ff       	call   800466 <fd_close>
		return r;
  800b09:	83 c4 10             	add    $0x10,%esp
  800b0c:	89 da                	mov    %ebx,%edx
  800b0e:	eb 17                	jmp    800b27 <open+0x86>
	}

	return fd2num(fd);
  800b10:	83 ec 0c             	sub    $0xc,%esp
  800b13:	ff 75 f4             	pushl  -0xc(%ebp)
  800b16:	e8 2c f8 ff ff       	call   800347 <fd2num>
  800b1b:	89 c2                	mov    %eax,%edx
  800b1d:	83 c4 10             	add    $0x10,%esp
  800b20:	eb 05                	jmp    800b27 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b22:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b27:	89 d0                	mov    %edx,%eax
  800b29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 08 00 00 00       	mov    $0x8,%eax
  800b3e:	e8 b3 fd ff ff       	call   8008f6 <fsipc>
}
  800b43:	c9                   	leave  
  800b44:	c3                   	ret    

00800b45 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b4d:	83 ec 0c             	sub    $0xc,%esp
  800b50:	ff 75 08             	pushl  0x8(%ebp)
  800b53:	e8 ff f7 ff ff       	call   800357 <fd2data>
  800b58:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b5a:	83 c4 08             	add    $0x8,%esp
  800b5d:	68 97 1e 80 00       	push   $0x801e97
  800b62:	53                   	push   %ebx
  800b63:	e8 1a 0b 00 00       	call   801682 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b68:	8b 46 04             	mov    0x4(%esi),%eax
  800b6b:	2b 06                	sub    (%esi),%eax
  800b6d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b73:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b7a:	00 00 00 
	stat->st_dev = &devpipe;
  800b7d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b84:	30 80 00 
	return 0;
}
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	53                   	push   %ebx
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b9d:	53                   	push   %ebx
  800b9e:	6a 00                	push   $0x0
  800ba0:	e8 36 f6 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800ba5:	89 1c 24             	mov    %ebx,(%esp)
  800ba8:	e8 aa f7 ff ff       	call   800357 <fd2data>
  800bad:	83 c4 08             	add    $0x8,%esp
  800bb0:	50                   	push   %eax
  800bb1:	6a 00                	push   $0x0
  800bb3:	e8 23 f6 ff ff       	call   8001db <sys_page_unmap>
}
  800bb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 1c             	sub    $0x1c,%esp
  800bc6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bc9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bcb:	a1 04 40 80 00       	mov    0x804004,%eax
  800bd0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	ff 75 e0             	pushl  -0x20(%ebp)
  800bd9:	e8 df 0e 00 00       	call   801abd <pageref>
  800bde:	89 c3                	mov    %eax,%ebx
  800be0:	89 3c 24             	mov    %edi,(%esp)
  800be3:	e8 d5 0e 00 00       	call   801abd <pageref>
  800be8:	83 c4 10             	add    $0x10,%esp
  800beb:	39 c3                	cmp    %eax,%ebx
  800bed:	0f 94 c1             	sete   %cl
  800bf0:	0f b6 c9             	movzbl %cl,%ecx
  800bf3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bf6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bfc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bff:	39 ce                	cmp    %ecx,%esi
  800c01:	74 1b                	je     800c1e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c03:	39 c3                	cmp    %eax,%ebx
  800c05:	75 c4                	jne    800bcb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c07:	8b 42 58             	mov    0x58(%edx),%eax
  800c0a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c0d:	50                   	push   %eax
  800c0e:	56                   	push   %esi
  800c0f:	68 9e 1e 80 00       	push   $0x801e9e
  800c14:	e8 e4 04 00 00       	call   8010fd <cprintf>
  800c19:	83 c4 10             	add    $0x10,%esp
  800c1c:	eb ad                	jmp    800bcb <_pipeisclosed+0xe>
	}
}
  800c1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 28             	sub    $0x28,%esp
  800c32:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c35:	56                   	push   %esi
  800c36:	e8 1c f7 ff ff       	call   800357 <fd2data>
  800c3b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c3d:	83 c4 10             	add    $0x10,%esp
  800c40:	bf 00 00 00 00       	mov    $0x0,%edi
  800c45:	eb 4b                	jmp    800c92 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c47:	89 da                	mov    %ebx,%edx
  800c49:	89 f0                	mov    %esi,%eax
  800c4b:	e8 6d ff ff ff       	call   800bbd <_pipeisclosed>
  800c50:	85 c0                	test   %eax,%eax
  800c52:	75 48                	jne    800c9c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c54:	e8 de f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c59:	8b 43 04             	mov    0x4(%ebx),%eax
  800c5c:	8b 0b                	mov    (%ebx),%ecx
  800c5e:	8d 51 20             	lea    0x20(%ecx),%edx
  800c61:	39 d0                	cmp    %edx,%eax
  800c63:	73 e2                	jae    800c47 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c6c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c6f:	89 c2                	mov    %eax,%edx
  800c71:	c1 fa 1f             	sar    $0x1f,%edx
  800c74:	89 d1                	mov    %edx,%ecx
  800c76:	c1 e9 1b             	shr    $0x1b,%ecx
  800c79:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c7c:	83 e2 1f             	and    $0x1f,%edx
  800c7f:	29 ca                	sub    %ecx,%edx
  800c81:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c85:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c89:	83 c0 01             	add    $0x1,%eax
  800c8c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c8f:	83 c7 01             	add    $0x1,%edi
  800c92:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c95:	75 c2                	jne    800c59 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c97:	8b 45 10             	mov    0x10(%ebp),%eax
  800c9a:	eb 05                	jmp    800ca1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c9c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	83 ec 18             	sub    $0x18,%esp
  800cb2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cb5:	57                   	push   %edi
  800cb6:	e8 9c f6 ff ff       	call   800357 <fd2data>
  800cbb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cbd:	83 c4 10             	add    $0x10,%esp
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	eb 3d                	jmp    800d04 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cc7:	85 db                	test   %ebx,%ebx
  800cc9:	74 04                	je     800ccf <devpipe_read+0x26>
				return i;
  800ccb:	89 d8                	mov    %ebx,%eax
  800ccd:	eb 44                	jmp    800d13 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ccf:	89 f2                	mov    %esi,%edx
  800cd1:	89 f8                	mov    %edi,%eax
  800cd3:	e8 e5 fe ff ff       	call   800bbd <_pipeisclosed>
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	75 32                	jne    800d0e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cdc:	e8 56 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ce1:	8b 06                	mov    (%esi),%eax
  800ce3:	3b 46 04             	cmp    0x4(%esi),%eax
  800ce6:	74 df                	je     800cc7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ce8:	99                   	cltd   
  800ce9:	c1 ea 1b             	shr    $0x1b,%edx
  800cec:	01 d0                	add    %edx,%eax
  800cee:	83 e0 1f             	and    $0x1f,%eax
  800cf1:	29 d0                	sub    %edx,%eax
  800cf3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800cfe:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d01:	83 c3 01             	add    $0x1,%ebx
  800d04:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d07:	75 d8                	jne    800ce1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d09:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0c:	eb 05                	jmp    800d13 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d0e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
  800d20:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d26:	50                   	push   %eax
  800d27:	e8 42 f6 ff ff       	call   80036e <fd_alloc>
  800d2c:	83 c4 10             	add    $0x10,%esp
  800d2f:	89 c2                	mov    %eax,%edx
  800d31:	85 c0                	test   %eax,%eax
  800d33:	0f 88 2c 01 00 00    	js     800e65 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d39:	83 ec 04             	sub    $0x4,%esp
  800d3c:	68 07 04 00 00       	push   $0x407
  800d41:	ff 75 f4             	pushl  -0xc(%ebp)
  800d44:	6a 00                	push   $0x0
  800d46:	e8 0b f4 ff ff       	call   800156 <sys_page_alloc>
  800d4b:	83 c4 10             	add    $0x10,%esp
  800d4e:	89 c2                	mov    %eax,%edx
  800d50:	85 c0                	test   %eax,%eax
  800d52:	0f 88 0d 01 00 00    	js     800e65 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d58:	83 ec 0c             	sub    $0xc,%esp
  800d5b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d5e:	50                   	push   %eax
  800d5f:	e8 0a f6 ff ff       	call   80036e <fd_alloc>
  800d64:	89 c3                	mov    %eax,%ebx
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	0f 88 e2 00 00 00    	js     800e53 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d71:	83 ec 04             	sub    $0x4,%esp
  800d74:	68 07 04 00 00       	push   $0x407
  800d79:	ff 75 f0             	pushl  -0x10(%ebp)
  800d7c:	6a 00                	push   $0x0
  800d7e:	e8 d3 f3 ff ff       	call   800156 <sys_page_alloc>
  800d83:	89 c3                	mov    %eax,%ebx
  800d85:	83 c4 10             	add    $0x10,%esp
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	0f 88 c3 00 00 00    	js     800e53 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	ff 75 f4             	pushl  -0xc(%ebp)
  800d96:	e8 bc f5 ff ff       	call   800357 <fd2data>
  800d9b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9d:	83 c4 0c             	add    $0xc,%esp
  800da0:	68 07 04 00 00       	push   $0x407
  800da5:	50                   	push   %eax
  800da6:	6a 00                	push   $0x0
  800da8:	e8 a9 f3 ff ff       	call   800156 <sys_page_alloc>
  800dad:	89 c3                	mov    %eax,%ebx
  800daf:	83 c4 10             	add    $0x10,%esp
  800db2:	85 c0                	test   %eax,%eax
  800db4:	0f 88 89 00 00 00    	js     800e43 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc0:	e8 92 f5 ff ff       	call   800357 <fd2data>
  800dc5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dcc:	50                   	push   %eax
  800dcd:	6a 00                	push   $0x0
  800dcf:	56                   	push   %esi
  800dd0:	6a 00                	push   $0x0
  800dd2:	e8 c2 f3 ff ff       	call   800199 <sys_page_map>
  800dd7:	89 c3                	mov    %eax,%ebx
  800dd9:	83 c4 20             	add    $0x20,%esp
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	78 55                	js     800e35 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800de0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800df5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dfe:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e03:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e10:	e8 32 f5 ff ff       	call   800347 <fd2num>
  800e15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e18:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e1a:	83 c4 04             	add    $0x4,%esp
  800e1d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e20:	e8 22 f5 ff ff       	call   800347 <fd2num>
  800e25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e28:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e2b:	83 c4 10             	add    $0x10,%esp
  800e2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e33:	eb 30                	jmp    800e65 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e35:	83 ec 08             	sub    $0x8,%esp
  800e38:	56                   	push   %esi
  800e39:	6a 00                	push   $0x0
  800e3b:	e8 9b f3 ff ff       	call   8001db <sys_page_unmap>
  800e40:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e43:	83 ec 08             	sub    $0x8,%esp
  800e46:	ff 75 f0             	pushl  -0x10(%ebp)
  800e49:	6a 00                	push   $0x0
  800e4b:	e8 8b f3 ff ff       	call   8001db <sys_page_unmap>
  800e50:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e53:	83 ec 08             	sub    $0x8,%esp
  800e56:	ff 75 f4             	pushl  -0xc(%ebp)
  800e59:	6a 00                	push   $0x0
  800e5b:	e8 7b f3 ff ff       	call   8001db <sys_page_unmap>
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e65:	89 d0                	mov    %edx,%eax
  800e67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e6a:	5b                   	pop    %ebx
  800e6b:	5e                   	pop    %esi
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    

00800e6e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e77:	50                   	push   %eax
  800e78:	ff 75 08             	pushl  0x8(%ebp)
  800e7b:	e8 3d f5 ff ff       	call   8003bd <fd_lookup>
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	85 c0                	test   %eax,%eax
  800e85:	78 18                	js     800e9f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e87:	83 ec 0c             	sub    $0xc,%esp
  800e8a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8d:	e8 c5 f4 ff ff       	call   800357 <fd2data>
	return _pipeisclosed(fd, p);
  800e92:	89 c2                	mov    %eax,%edx
  800e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e97:	e8 21 fd ff ff       	call   800bbd <_pipeisclosed>
  800e9c:	83 c4 10             	add    $0x10,%esp
}
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    

00800ea1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ea4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eb1:	68 b6 1e 80 00       	push   $0x801eb6
  800eb6:	ff 75 0c             	pushl  0xc(%ebp)
  800eb9:	e8 c4 07 00 00       	call   801682 <strcpy>
	return 0;
}
  800ebe:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec3:	c9                   	leave  
  800ec4:	c3                   	ret    

00800ec5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	57                   	push   %edi
  800ec9:	56                   	push   %esi
  800eca:	53                   	push   %ebx
  800ecb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ed1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ed6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800edc:	eb 2d                	jmp    800f0b <devcons_write+0x46>
		m = n - tot;
  800ede:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ee3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ee6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800eeb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eee:	83 ec 04             	sub    $0x4,%esp
  800ef1:	53                   	push   %ebx
  800ef2:	03 45 0c             	add    0xc(%ebp),%eax
  800ef5:	50                   	push   %eax
  800ef6:	57                   	push   %edi
  800ef7:	e8 18 09 00 00       	call   801814 <memmove>
		sys_cputs(buf, m);
  800efc:	83 c4 08             	add    $0x8,%esp
  800eff:	53                   	push   %ebx
  800f00:	57                   	push   %edi
  800f01:	e8 94 f1 ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f06:	01 de                	add    %ebx,%esi
  800f08:	83 c4 10             	add    $0x10,%esp
  800f0b:	89 f0                	mov    %esi,%eax
  800f0d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f10:	72 cc                	jb     800ede <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	83 ec 08             	sub    $0x8,%esp
  800f20:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f25:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f29:	74 2a                	je     800f55 <devcons_read+0x3b>
  800f2b:	eb 05                	jmp    800f32 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f2d:	e8 05 f2 ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f32:	e8 81 f1 ff ff       	call   8000b8 <sys_cgetc>
  800f37:	85 c0                	test   %eax,%eax
  800f39:	74 f2                	je     800f2d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	78 16                	js     800f55 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f3f:	83 f8 04             	cmp    $0x4,%eax
  800f42:	74 0c                	je     800f50 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f44:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f47:	88 02                	mov    %al,(%edx)
	return 1;
  800f49:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4e:	eb 05                	jmp    800f55 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f50:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f60:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f63:	6a 01                	push   $0x1
  800f65:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f68:	50                   	push   %eax
  800f69:	e8 2c f1 ff ff       	call   80009a <sys_cputs>
}
  800f6e:	83 c4 10             	add    $0x10,%esp
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    

00800f73 <getchar>:

int
getchar(void)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f79:	6a 01                	push   $0x1
  800f7b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f7e:	50                   	push   %eax
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 9d f6 ff ff       	call   800623 <read>
	if (r < 0)
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	78 0f                	js     800f9c <getchar+0x29>
		return r;
	if (r < 1)
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	7e 06                	jle    800f97 <getchar+0x24>
		return -E_EOF;
	return c;
  800f91:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f95:	eb 05                	jmp    800f9c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f97:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f9c:	c9                   	leave  
  800f9d:	c3                   	ret    

00800f9e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa7:	50                   	push   %eax
  800fa8:	ff 75 08             	pushl  0x8(%ebp)
  800fab:	e8 0d f4 ff ff       	call   8003bd <fd_lookup>
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	78 11                	js     800fc8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fba:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fc0:	39 10                	cmp    %edx,(%eax)
  800fc2:	0f 94 c0             	sete   %al
  800fc5:	0f b6 c0             	movzbl %al,%eax
}
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    

00800fca <opencons>:

int
opencons(void)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd3:	50                   	push   %eax
  800fd4:	e8 95 f3 ff ff       	call   80036e <fd_alloc>
  800fd9:	83 c4 10             	add    $0x10,%esp
		return r;
  800fdc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 3e                	js     801020 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fe2:	83 ec 04             	sub    $0x4,%esp
  800fe5:	68 07 04 00 00       	push   $0x407
  800fea:	ff 75 f4             	pushl  -0xc(%ebp)
  800fed:	6a 00                	push   $0x0
  800fef:	e8 62 f1 ff ff       	call   800156 <sys_page_alloc>
  800ff4:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	78 23                	js     801020 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800ffd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801003:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801006:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801008:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	50                   	push   %eax
  801016:	e8 2c f3 ff ff       	call   800347 <fd2num>
  80101b:	89 c2                	mov    %eax,%edx
  80101d:	83 c4 10             	add    $0x10,%esp
}
  801020:	89 d0                	mov    %edx,%eax
  801022:	c9                   	leave  
  801023:	c3                   	ret    

00801024 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	56                   	push   %esi
  801028:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801029:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80102c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801032:	e8 e1 f0 ff ff       	call   800118 <sys_getenvid>
  801037:	83 ec 0c             	sub    $0xc,%esp
  80103a:	ff 75 0c             	pushl  0xc(%ebp)
  80103d:	ff 75 08             	pushl  0x8(%ebp)
  801040:	56                   	push   %esi
  801041:	50                   	push   %eax
  801042:	68 c4 1e 80 00       	push   $0x801ec4
  801047:	e8 b1 00 00 00       	call   8010fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80104c:	83 c4 18             	add    $0x18,%esp
  80104f:	53                   	push   %ebx
  801050:	ff 75 10             	pushl  0x10(%ebp)
  801053:	e8 54 00 00 00       	call   8010ac <vcprintf>
	cprintf("\n");
  801058:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  80105f:	e8 99 00 00 00       	call   8010fd <cprintf>
  801064:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801067:	cc                   	int3   
  801068:	eb fd                	jmp    801067 <_panic+0x43>

0080106a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	53                   	push   %ebx
  80106e:	83 ec 04             	sub    $0x4,%esp
  801071:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801074:	8b 13                	mov    (%ebx),%edx
  801076:	8d 42 01             	lea    0x1(%edx),%eax
  801079:	89 03                	mov    %eax,(%ebx)
  80107b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801082:	3d ff 00 00 00       	cmp    $0xff,%eax
  801087:	75 1a                	jne    8010a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801089:	83 ec 08             	sub    $0x8,%esp
  80108c:	68 ff 00 00 00       	push   $0xff
  801091:	8d 43 08             	lea    0x8(%ebx),%eax
  801094:	50                   	push   %eax
  801095:	e8 00 f0 ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  80109a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010aa:	c9                   	leave  
  8010ab:	c3                   	ret    

008010ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010bc:	00 00 00 
	b.cnt = 0;
  8010bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010c9:	ff 75 0c             	pushl  0xc(%ebp)
  8010cc:	ff 75 08             	pushl  0x8(%ebp)
  8010cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010d5:	50                   	push   %eax
  8010d6:	68 6a 10 80 00       	push   $0x80106a
  8010db:	e8 54 01 00 00       	call   801234 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010e0:	83 c4 08             	add    $0x8,%esp
  8010e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010ef:	50                   	push   %eax
  8010f0:	e8 a5 ef ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8010f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010fb:	c9                   	leave  
  8010fc:	c3                   	ret    

008010fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801103:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801106:	50                   	push   %eax
  801107:	ff 75 08             	pushl  0x8(%ebp)
  80110a:	e8 9d ff ff ff       	call   8010ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80110f:	c9                   	leave  
  801110:	c3                   	ret    

00801111 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	57                   	push   %edi
  801115:	56                   	push   %esi
  801116:	53                   	push   %ebx
  801117:	83 ec 1c             	sub    $0x1c,%esp
  80111a:	89 c7                	mov    %eax,%edi
  80111c:	89 d6                	mov    %edx,%esi
  80111e:	8b 45 08             	mov    0x8(%ebp),%eax
  801121:	8b 55 0c             	mov    0xc(%ebp),%edx
  801124:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801127:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80112a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80112d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801132:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801135:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801138:	39 d3                	cmp    %edx,%ebx
  80113a:	72 05                	jb     801141 <printnum+0x30>
  80113c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80113f:	77 45                	ja     801186 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801141:	83 ec 0c             	sub    $0xc,%esp
  801144:	ff 75 18             	pushl  0x18(%ebp)
  801147:	8b 45 14             	mov    0x14(%ebp),%eax
  80114a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80114d:	53                   	push   %ebx
  80114e:	ff 75 10             	pushl  0x10(%ebp)
  801151:	83 ec 08             	sub    $0x8,%esp
  801154:	ff 75 e4             	pushl  -0x1c(%ebp)
  801157:	ff 75 e0             	pushl  -0x20(%ebp)
  80115a:	ff 75 dc             	pushl  -0x24(%ebp)
  80115d:	ff 75 d8             	pushl  -0x28(%ebp)
  801160:	e8 9b 09 00 00       	call   801b00 <__udivdi3>
  801165:	83 c4 18             	add    $0x18,%esp
  801168:	52                   	push   %edx
  801169:	50                   	push   %eax
  80116a:	89 f2                	mov    %esi,%edx
  80116c:	89 f8                	mov    %edi,%eax
  80116e:	e8 9e ff ff ff       	call   801111 <printnum>
  801173:	83 c4 20             	add    $0x20,%esp
  801176:	eb 18                	jmp    801190 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801178:	83 ec 08             	sub    $0x8,%esp
  80117b:	56                   	push   %esi
  80117c:	ff 75 18             	pushl  0x18(%ebp)
  80117f:	ff d7                	call   *%edi
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	eb 03                	jmp    801189 <printnum+0x78>
  801186:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801189:	83 eb 01             	sub    $0x1,%ebx
  80118c:	85 db                	test   %ebx,%ebx
  80118e:	7f e8                	jg     801178 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801190:	83 ec 08             	sub    $0x8,%esp
  801193:	56                   	push   %esi
  801194:	83 ec 04             	sub    $0x4,%esp
  801197:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119a:	ff 75 e0             	pushl  -0x20(%ebp)
  80119d:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8011a3:	e8 88 0a 00 00       	call   801c30 <__umoddi3>
  8011a8:	83 c4 14             	add    $0x14,%esp
  8011ab:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  8011b2:	50                   	push   %eax
  8011b3:	ff d7                	call   *%edi
}
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011c3:	83 fa 01             	cmp    $0x1,%edx
  8011c6:	7e 0e                	jle    8011d6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011c8:	8b 10                	mov    (%eax),%edx
  8011ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011cd:	89 08                	mov    %ecx,(%eax)
  8011cf:	8b 02                	mov    (%edx),%eax
  8011d1:	8b 52 04             	mov    0x4(%edx),%edx
  8011d4:	eb 22                	jmp    8011f8 <getuint+0x38>
	else if (lflag)
  8011d6:	85 d2                	test   %edx,%edx
  8011d8:	74 10                	je     8011ea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011da:	8b 10                	mov    (%eax),%edx
  8011dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011df:	89 08                	mov    %ecx,(%eax)
  8011e1:	8b 02                	mov    (%edx),%eax
  8011e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e8:	eb 0e                	jmp    8011f8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011ea:	8b 10                	mov    (%eax),%edx
  8011ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011ef:	89 08                	mov    %ecx,(%eax)
  8011f1:	8b 02                	mov    (%edx),%eax
  8011f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801200:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801204:	8b 10                	mov    (%eax),%edx
  801206:	3b 50 04             	cmp    0x4(%eax),%edx
  801209:	73 0a                	jae    801215 <sprintputch+0x1b>
		*b->buf++ = ch;
  80120b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80120e:	89 08                	mov    %ecx,(%eax)
  801210:	8b 45 08             	mov    0x8(%ebp),%eax
  801213:	88 02                	mov    %al,(%edx)
}
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80121d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801220:	50                   	push   %eax
  801221:	ff 75 10             	pushl  0x10(%ebp)
  801224:	ff 75 0c             	pushl  0xc(%ebp)
  801227:	ff 75 08             	pushl  0x8(%ebp)
  80122a:	e8 05 00 00 00       	call   801234 <vprintfmt>
	va_end(ap);
}
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	c9                   	leave  
  801233:	c3                   	ret    

00801234 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	57                   	push   %edi
  801238:	56                   	push   %esi
  801239:	53                   	push   %ebx
  80123a:	83 ec 2c             	sub    $0x2c,%esp
  80123d:	8b 75 08             	mov    0x8(%ebp),%esi
  801240:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801243:	8b 7d 10             	mov    0x10(%ebp),%edi
  801246:	eb 12                	jmp    80125a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801248:	85 c0                	test   %eax,%eax
  80124a:	0f 84 89 03 00 00    	je     8015d9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801250:	83 ec 08             	sub    $0x8,%esp
  801253:	53                   	push   %ebx
  801254:	50                   	push   %eax
  801255:	ff d6                	call   *%esi
  801257:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80125a:	83 c7 01             	add    $0x1,%edi
  80125d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801261:	83 f8 25             	cmp    $0x25,%eax
  801264:	75 e2                	jne    801248 <vprintfmt+0x14>
  801266:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80126a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801271:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801278:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80127f:	ba 00 00 00 00       	mov    $0x0,%edx
  801284:	eb 07                	jmp    80128d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801286:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801289:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80128d:	8d 47 01             	lea    0x1(%edi),%eax
  801290:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801293:	0f b6 07             	movzbl (%edi),%eax
  801296:	0f b6 c8             	movzbl %al,%ecx
  801299:	83 e8 23             	sub    $0x23,%eax
  80129c:	3c 55                	cmp    $0x55,%al
  80129e:	0f 87 1a 03 00 00    	ja     8015be <vprintfmt+0x38a>
  8012a4:	0f b6 c0             	movzbl %al,%eax
  8012a7:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  8012ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012b5:	eb d6                	jmp    80128d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012c2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012c5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012c9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012cc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012cf:	83 fa 09             	cmp    $0x9,%edx
  8012d2:	77 39                	ja     80130d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012d4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012d7:	eb e9                	jmp    8012c2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8012dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8012df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012e2:	8b 00                	mov    (%eax),%eax
  8012e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012ea:	eb 27                	jmp    801313 <vprintfmt+0xdf>
  8012ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012f6:	0f 49 c8             	cmovns %eax,%ecx
  8012f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ff:	eb 8c                	jmp    80128d <vprintfmt+0x59>
  801301:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801304:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80130b:	eb 80                	jmp    80128d <vprintfmt+0x59>
  80130d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801310:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801313:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801317:	0f 89 70 ff ff ff    	jns    80128d <vprintfmt+0x59>
				width = precision, precision = -1;
  80131d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801320:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801323:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80132a:	e9 5e ff ff ff       	jmp    80128d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80132f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801335:	e9 53 ff ff ff       	jmp    80128d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80133a:	8b 45 14             	mov    0x14(%ebp),%eax
  80133d:	8d 50 04             	lea    0x4(%eax),%edx
  801340:	89 55 14             	mov    %edx,0x14(%ebp)
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	53                   	push   %ebx
  801347:	ff 30                	pushl  (%eax)
  801349:	ff d6                	call   *%esi
			break;
  80134b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801351:	e9 04 ff ff ff       	jmp    80125a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801356:	8b 45 14             	mov    0x14(%ebp),%eax
  801359:	8d 50 04             	lea    0x4(%eax),%edx
  80135c:	89 55 14             	mov    %edx,0x14(%ebp)
  80135f:	8b 00                	mov    (%eax),%eax
  801361:	99                   	cltd   
  801362:	31 d0                	xor    %edx,%eax
  801364:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801366:	83 f8 0f             	cmp    $0xf,%eax
  801369:	7f 0b                	jg     801376 <vprintfmt+0x142>
  80136b:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  801372:	85 d2                	test   %edx,%edx
  801374:	75 18                	jne    80138e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801376:	50                   	push   %eax
  801377:	68 ff 1e 80 00       	push   $0x801eff
  80137c:	53                   	push   %ebx
  80137d:	56                   	push   %esi
  80137e:	e8 94 fe ff ff       	call   801217 <printfmt>
  801383:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801389:	e9 cc fe ff ff       	jmp    80125a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80138e:	52                   	push   %edx
  80138f:	68 7d 1e 80 00       	push   $0x801e7d
  801394:	53                   	push   %ebx
  801395:	56                   	push   %esi
  801396:	e8 7c fe ff ff       	call   801217 <printfmt>
  80139b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013a1:	e9 b4 fe ff ff       	jmp    80125a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a9:	8d 50 04             	lea    0x4(%eax),%edx
  8013ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8013af:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013b1:	85 ff                	test   %edi,%edi
  8013b3:	b8 f8 1e 80 00       	mov    $0x801ef8,%eax
  8013b8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013bf:	0f 8e 94 00 00 00    	jle    801459 <vprintfmt+0x225>
  8013c5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013c9:	0f 84 98 00 00 00    	je     801467 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013cf:	83 ec 08             	sub    $0x8,%esp
  8013d2:	ff 75 d0             	pushl  -0x30(%ebp)
  8013d5:	57                   	push   %edi
  8013d6:	e8 86 02 00 00       	call   801661 <strnlen>
  8013db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013de:	29 c1                	sub    %eax,%ecx
  8013e0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013e3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013e6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013ed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013f0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f2:	eb 0f                	jmp    801403 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8013f4:	83 ec 08             	sub    $0x8,%esp
  8013f7:	53                   	push   %ebx
  8013f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8013fb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013fd:	83 ef 01             	sub    $0x1,%edi
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	85 ff                	test   %edi,%edi
  801405:	7f ed                	jg     8013f4 <vprintfmt+0x1c0>
  801407:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80140a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80140d:	85 c9                	test   %ecx,%ecx
  80140f:	b8 00 00 00 00       	mov    $0x0,%eax
  801414:	0f 49 c1             	cmovns %ecx,%eax
  801417:	29 c1                	sub    %eax,%ecx
  801419:	89 75 08             	mov    %esi,0x8(%ebp)
  80141c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80141f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801422:	89 cb                	mov    %ecx,%ebx
  801424:	eb 4d                	jmp    801473 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801426:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80142a:	74 1b                	je     801447 <vprintfmt+0x213>
  80142c:	0f be c0             	movsbl %al,%eax
  80142f:	83 e8 20             	sub    $0x20,%eax
  801432:	83 f8 5e             	cmp    $0x5e,%eax
  801435:	76 10                	jbe    801447 <vprintfmt+0x213>
					putch('?', putdat);
  801437:	83 ec 08             	sub    $0x8,%esp
  80143a:	ff 75 0c             	pushl  0xc(%ebp)
  80143d:	6a 3f                	push   $0x3f
  80143f:	ff 55 08             	call   *0x8(%ebp)
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	eb 0d                	jmp    801454 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	ff 75 0c             	pushl  0xc(%ebp)
  80144d:	52                   	push   %edx
  80144e:	ff 55 08             	call   *0x8(%ebp)
  801451:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801454:	83 eb 01             	sub    $0x1,%ebx
  801457:	eb 1a                	jmp    801473 <vprintfmt+0x23f>
  801459:	89 75 08             	mov    %esi,0x8(%ebp)
  80145c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80145f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801462:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801465:	eb 0c                	jmp    801473 <vprintfmt+0x23f>
  801467:	89 75 08             	mov    %esi,0x8(%ebp)
  80146a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80146d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801470:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801473:	83 c7 01             	add    $0x1,%edi
  801476:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80147a:	0f be d0             	movsbl %al,%edx
  80147d:	85 d2                	test   %edx,%edx
  80147f:	74 23                	je     8014a4 <vprintfmt+0x270>
  801481:	85 f6                	test   %esi,%esi
  801483:	78 a1                	js     801426 <vprintfmt+0x1f2>
  801485:	83 ee 01             	sub    $0x1,%esi
  801488:	79 9c                	jns    801426 <vprintfmt+0x1f2>
  80148a:	89 df                	mov    %ebx,%edi
  80148c:	8b 75 08             	mov    0x8(%ebp),%esi
  80148f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801492:	eb 18                	jmp    8014ac <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801494:	83 ec 08             	sub    $0x8,%esp
  801497:	53                   	push   %ebx
  801498:	6a 20                	push   $0x20
  80149a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80149c:	83 ef 01             	sub    $0x1,%edi
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	eb 08                	jmp    8014ac <vprintfmt+0x278>
  8014a4:	89 df                	mov    %ebx,%edi
  8014a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014ac:	85 ff                	test   %edi,%edi
  8014ae:	7f e4                	jg     801494 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014b3:	e9 a2 fd ff ff       	jmp    80125a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014b8:	83 fa 01             	cmp    $0x1,%edx
  8014bb:	7e 16                	jle    8014d3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c0:	8d 50 08             	lea    0x8(%eax),%edx
  8014c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014c6:	8b 50 04             	mov    0x4(%eax),%edx
  8014c9:	8b 00                	mov    (%eax),%eax
  8014cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014d1:	eb 32                	jmp    801505 <vprintfmt+0x2d1>
	else if (lflag)
  8014d3:	85 d2                	test   %edx,%edx
  8014d5:	74 18                	je     8014ef <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014da:	8d 50 04             	lea    0x4(%eax),%edx
  8014dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e0:	8b 00                	mov    (%eax),%eax
  8014e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e5:	89 c1                	mov    %eax,%ecx
  8014e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8014ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014ed:	eb 16                	jmp    801505 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f2:	8d 50 04             	lea    0x4(%eax),%edx
  8014f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f8:	8b 00                	mov    (%eax),%eax
  8014fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014fd:	89 c1                	mov    %eax,%ecx
  8014ff:	c1 f9 1f             	sar    $0x1f,%ecx
  801502:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801505:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801508:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80150b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801510:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801514:	79 74                	jns    80158a <vprintfmt+0x356>
				putch('-', putdat);
  801516:	83 ec 08             	sub    $0x8,%esp
  801519:	53                   	push   %ebx
  80151a:	6a 2d                	push   $0x2d
  80151c:	ff d6                	call   *%esi
				num = -(long long) num;
  80151e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801521:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801524:	f7 d8                	neg    %eax
  801526:	83 d2 00             	adc    $0x0,%edx
  801529:	f7 da                	neg    %edx
  80152b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80152e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801533:	eb 55                	jmp    80158a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801535:	8d 45 14             	lea    0x14(%ebp),%eax
  801538:	e8 83 fc ff ff       	call   8011c0 <getuint>
			base = 10;
  80153d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801542:	eb 46                	jmp    80158a <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801544:	8d 45 14             	lea    0x14(%ebp),%eax
  801547:	e8 74 fc ff ff       	call   8011c0 <getuint>
			base = 8;
  80154c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801551:	eb 37                	jmp    80158a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801553:	83 ec 08             	sub    $0x8,%esp
  801556:	53                   	push   %ebx
  801557:	6a 30                	push   $0x30
  801559:	ff d6                	call   *%esi
			putch('x', putdat);
  80155b:	83 c4 08             	add    $0x8,%esp
  80155e:	53                   	push   %ebx
  80155f:	6a 78                	push   $0x78
  801561:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801563:	8b 45 14             	mov    0x14(%ebp),%eax
  801566:	8d 50 04             	lea    0x4(%eax),%edx
  801569:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80156c:	8b 00                	mov    (%eax),%eax
  80156e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801573:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801576:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80157b:	eb 0d                	jmp    80158a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80157d:	8d 45 14             	lea    0x14(%ebp),%eax
  801580:	e8 3b fc ff ff       	call   8011c0 <getuint>
			base = 16;
  801585:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80158a:	83 ec 0c             	sub    $0xc,%esp
  80158d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801591:	57                   	push   %edi
  801592:	ff 75 e0             	pushl  -0x20(%ebp)
  801595:	51                   	push   %ecx
  801596:	52                   	push   %edx
  801597:	50                   	push   %eax
  801598:	89 da                	mov    %ebx,%edx
  80159a:	89 f0                	mov    %esi,%eax
  80159c:	e8 70 fb ff ff       	call   801111 <printnum>
			break;
  8015a1:	83 c4 20             	add    $0x20,%esp
  8015a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015a7:	e9 ae fc ff ff       	jmp    80125a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	53                   	push   %ebx
  8015b0:	51                   	push   %ecx
  8015b1:	ff d6                	call   *%esi
			break;
  8015b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015b9:	e9 9c fc ff ff       	jmp    80125a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	53                   	push   %ebx
  8015c2:	6a 25                	push   $0x25
  8015c4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	eb 03                	jmp    8015ce <vprintfmt+0x39a>
  8015cb:	83 ef 01             	sub    $0x1,%edi
  8015ce:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015d2:	75 f7                	jne    8015cb <vprintfmt+0x397>
  8015d4:	e9 81 fc ff ff       	jmp    80125a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015dc:	5b                   	pop    %ebx
  8015dd:	5e                   	pop    %esi
  8015de:	5f                   	pop    %edi
  8015df:	5d                   	pop    %ebp
  8015e0:	c3                   	ret    

008015e1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	83 ec 18             	sub    $0x18,%esp
  8015e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015fe:	85 c0                	test   %eax,%eax
  801600:	74 26                	je     801628 <vsnprintf+0x47>
  801602:	85 d2                	test   %edx,%edx
  801604:	7e 22                	jle    801628 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801606:	ff 75 14             	pushl  0x14(%ebp)
  801609:	ff 75 10             	pushl  0x10(%ebp)
  80160c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80160f:	50                   	push   %eax
  801610:	68 fa 11 80 00       	push   $0x8011fa
  801615:	e8 1a fc ff ff       	call   801234 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80161a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80161d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801620:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	eb 05                	jmp    80162d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801628:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801635:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801638:	50                   	push   %eax
  801639:	ff 75 10             	pushl  0x10(%ebp)
  80163c:	ff 75 0c             	pushl  0xc(%ebp)
  80163f:	ff 75 08             	pushl  0x8(%ebp)
  801642:	e8 9a ff ff ff       	call   8015e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  801647:	c9                   	leave  
  801648:	c3                   	ret    

00801649 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80164f:	b8 00 00 00 00       	mov    $0x0,%eax
  801654:	eb 03                	jmp    801659 <strlen+0x10>
		n++;
  801656:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801659:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80165d:	75 f7                	jne    801656 <strlen+0xd>
		n++;
	return n;
}
  80165f:	5d                   	pop    %ebp
  801660:	c3                   	ret    

00801661 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801667:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80166a:	ba 00 00 00 00       	mov    $0x0,%edx
  80166f:	eb 03                	jmp    801674 <strnlen+0x13>
		n++;
  801671:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801674:	39 c2                	cmp    %eax,%edx
  801676:	74 08                	je     801680 <strnlen+0x1f>
  801678:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80167c:	75 f3                	jne    801671 <strnlen+0x10>
  80167e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	8b 45 08             	mov    0x8(%ebp),%eax
  801689:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80168c:	89 c2                	mov    %eax,%edx
  80168e:	83 c2 01             	add    $0x1,%edx
  801691:	83 c1 01             	add    $0x1,%ecx
  801694:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801698:	88 5a ff             	mov    %bl,-0x1(%edx)
  80169b:	84 db                	test   %bl,%bl
  80169d:	75 ef                	jne    80168e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80169f:	5b                   	pop    %ebx
  8016a0:	5d                   	pop    %ebp
  8016a1:	c3                   	ret    

008016a2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	53                   	push   %ebx
  8016a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016a9:	53                   	push   %ebx
  8016aa:	e8 9a ff ff ff       	call   801649 <strlen>
  8016af:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016b2:	ff 75 0c             	pushl  0xc(%ebp)
  8016b5:	01 d8                	add    %ebx,%eax
  8016b7:	50                   	push   %eax
  8016b8:	e8 c5 ff ff ff       	call   801682 <strcpy>
	return dst;
}
  8016bd:	89 d8                	mov    %ebx,%eax
  8016bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	56                   	push   %esi
  8016c8:	53                   	push   %ebx
  8016c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8016cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016cf:	89 f3                	mov    %esi,%ebx
  8016d1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016d4:	89 f2                	mov    %esi,%edx
  8016d6:	eb 0f                	jmp    8016e7 <strncpy+0x23>
		*dst++ = *src;
  8016d8:	83 c2 01             	add    $0x1,%edx
  8016db:	0f b6 01             	movzbl (%ecx),%eax
  8016de:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016e1:	80 39 01             	cmpb   $0x1,(%ecx)
  8016e4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016e7:	39 da                	cmp    %ebx,%edx
  8016e9:	75 ed                	jne    8016d8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016eb:	89 f0                	mov    %esi,%eax
  8016ed:	5b                   	pop    %ebx
  8016ee:	5e                   	pop    %esi
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    

008016f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	56                   	push   %esi
  8016f5:	53                   	push   %ebx
  8016f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fc:	8b 55 10             	mov    0x10(%ebp),%edx
  8016ff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801701:	85 d2                	test   %edx,%edx
  801703:	74 21                	je     801726 <strlcpy+0x35>
  801705:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801709:	89 f2                	mov    %esi,%edx
  80170b:	eb 09                	jmp    801716 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80170d:	83 c2 01             	add    $0x1,%edx
  801710:	83 c1 01             	add    $0x1,%ecx
  801713:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801716:	39 c2                	cmp    %eax,%edx
  801718:	74 09                	je     801723 <strlcpy+0x32>
  80171a:	0f b6 19             	movzbl (%ecx),%ebx
  80171d:	84 db                	test   %bl,%bl
  80171f:	75 ec                	jne    80170d <strlcpy+0x1c>
  801721:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801723:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801726:	29 f0                	sub    %esi,%eax
}
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5d                   	pop    %ebp
  80172b:	c3                   	ret    

0080172c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801732:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801735:	eb 06                	jmp    80173d <strcmp+0x11>
		p++, q++;
  801737:	83 c1 01             	add    $0x1,%ecx
  80173a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80173d:	0f b6 01             	movzbl (%ecx),%eax
  801740:	84 c0                	test   %al,%al
  801742:	74 04                	je     801748 <strcmp+0x1c>
  801744:	3a 02                	cmp    (%edx),%al
  801746:	74 ef                	je     801737 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801748:	0f b6 c0             	movzbl %al,%eax
  80174b:	0f b6 12             	movzbl (%edx),%edx
  80174e:	29 d0                	sub    %edx,%eax
}
  801750:	5d                   	pop    %ebp
  801751:	c3                   	ret    

00801752 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	53                   	push   %ebx
  801756:	8b 45 08             	mov    0x8(%ebp),%eax
  801759:	8b 55 0c             	mov    0xc(%ebp),%edx
  80175c:	89 c3                	mov    %eax,%ebx
  80175e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801761:	eb 06                	jmp    801769 <strncmp+0x17>
		n--, p++, q++;
  801763:	83 c0 01             	add    $0x1,%eax
  801766:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801769:	39 d8                	cmp    %ebx,%eax
  80176b:	74 15                	je     801782 <strncmp+0x30>
  80176d:	0f b6 08             	movzbl (%eax),%ecx
  801770:	84 c9                	test   %cl,%cl
  801772:	74 04                	je     801778 <strncmp+0x26>
  801774:	3a 0a                	cmp    (%edx),%cl
  801776:	74 eb                	je     801763 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801778:	0f b6 00             	movzbl (%eax),%eax
  80177b:	0f b6 12             	movzbl (%edx),%edx
  80177e:	29 d0                	sub    %edx,%eax
  801780:	eb 05                	jmp    801787 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801782:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801787:	5b                   	pop    %ebx
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	8b 45 08             	mov    0x8(%ebp),%eax
  801790:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801794:	eb 07                	jmp    80179d <strchr+0x13>
		if (*s == c)
  801796:	38 ca                	cmp    %cl,%dl
  801798:	74 0f                	je     8017a9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80179a:	83 c0 01             	add    $0x1,%eax
  80179d:	0f b6 10             	movzbl (%eax),%edx
  8017a0:	84 d2                	test   %dl,%dl
  8017a2:	75 f2                	jne    801796 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    

008017ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017b5:	eb 03                	jmp    8017ba <strfind+0xf>
  8017b7:	83 c0 01             	add    $0x1,%eax
  8017ba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017bd:	38 ca                	cmp    %cl,%dl
  8017bf:	74 04                	je     8017c5 <strfind+0x1a>
  8017c1:	84 d2                	test   %dl,%dl
  8017c3:	75 f2                	jne    8017b7 <strfind+0xc>
			break;
	return (char *) s;
}
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	57                   	push   %edi
  8017cb:	56                   	push   %esi
  8017cc:	53                   	push   %ebx
  8017cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017d3:	85 c9                	test   %ecx,%ecx
  8017d5:	74 36                	je     80180d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017dd:	75 28                	jne    801807 <memset+0x40>
  8017df:	f6 c1 03             	test   $0x3,%cl
  8017e2:	75 23                	jne    801807 <memset+0x40>
		c &= 0xFF;
  8017e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017e8:	89 d3                	mov    %edx,%ebx
  8017ea:	c1 e3 08             	shl    $0x8,%ebx
  8017ed:	89 d6                	mov    %edx,%esi
  8017ef:	c1 e6 18             	shl    $0x18,%esi
  8017f2:	89 d0                	mov    %edx,%eax
  8017f4:	c1 e0 10             	shl    $0x10,%eax
  8017f7:	09 f0                	or     %esi,%eax
  8017f9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8017fb:	89 d8                	mov    %ebx,%eax
  8017fd:	09 d0                	or     %edx,%eax
  8017ff:	c1 e9 02             	shr    $0x2,%ecx
  801802:	fc                   	cld    
  801803:	f3 ab                	rep stos %eax,%es:(%edi)
  801805:	eb 06                	jmp    80180d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801807:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180a:	fc                   	cld    
  80180b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80180d:	89 f8                	mov    %edi,%eax
  80180f:	5b                   	pop    %ebx
  801810:	5e                   	pop    %esi
  801811:	5f                   	pop    %edi
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	57                   	push   %edi
  801818:	56                   	push   %esi
  801819:	8b 45 08             	mov    0x8(%ebp),%eax
  80181c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80181f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801822:	39 c6                	cmp    %eax,%esi
  801824:	73 35                	jae    80185b <memmove+0x47>
  801826:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801829:	39 d0                	cmp    %edx,%eax
  80182b:	73 2e                	jae    80185b <memmove+0x47>
		s += n;
		d += n;
  80182d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801830:	89 d6                	mov    %edx,%esi
  801832:	09 fe                	or     %edi,%esi
  801834:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80183a:	75 13                	jne    80184f <memmove+0x3b>
  80183c:	f6 c1 03             	test   $0x3,%cl
  80183f:	75 0e                	jne    80184f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801841:	83 ef 04             	sub    $0x4,%edi
  801844:	8d 72 fc             	lea    -0x4(%edx),%esi
  801847:	c1 e9 02             	shr    $0x2,%ecx
  80184a:	fd                   	std    
  80184b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80184d:	eb 09                	jmp    801858 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80184f:	83 ef 01             	sub    $0x1,%edi
  801852:	8d 72 ff             	lea    -0x1(%edx),%esi
  801855:	fd                   	std    
  801856:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801858:	fc                   	cld    
  801859:	eb 1d                	jmp    801878 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80185b:	89 f2                	mov    %esi,%edx
  80185d:	09 c2                	or     %eax,%edx
  80185f:	f6 c2 03             	test   $0x3,%dl
  801862:	75 0f                	jne    801873 <memmove+0x5f>
  801864:	f6 c1 03             	test   $0x3,%cl
  801867:	75 0a                	jne    801873 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801869:	c1 e9 02             	shr    $0x2,%ecx
  80186c:	89 c7                	mov    %eax,%edi
  80186e:	fc                   	cld    
  80186f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801871:	eb 05                	jmp    801878 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801873:	89 c7                	mov    %eax,%edi
  801875:	fc                   	cld    
  801876:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801878:	5e                   	pop    %esi
  801879:	5f                   	pop    %edi
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    

0080187c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80187f:	ff 75 10             	pushl  0x10(%ebp)
  801882:	ff 75 0c             	pushl  0xc(%ebp)
  801885:	ff 75 08             	pushl  0x8(%ebp)
  801888:	e8 87 ff ff ff       	call   801814 <memmove>
}
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    

0080188f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	56                   	push   %esi
  801893:	53                   	push   %ebx
  801894:	8b 45 08             	mov    0x8(%ebp),%eax
  801897:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189a:	89 c6                	mov    %eax,%esi
  80189c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80189f:	eb 1a                	jmp    8018bb <memcmp+0x2c>
		if (*s1 != *s2)
  8018a1:	0f b6 08             	movzbl (%eax),%ecx
  8018a4:	0f b6 1a             	movzbl (%edx),%ebx
  8018a7:	38 d9                	cmp    %bl,%cl
  8018a9:	74 0a                	je     8018b5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018ab:	0f b6 c1             	movzbl %cl,%eax
  8018ae:	0f b6 db             	movzbl %bl,%ebx
  8018b1:	29 d8                	sub    %ebx,%eax
  8018b3:	eb 0f                	jmp    8018c4 <memcmp+0x35>
		s1++, s2++;
  8018b5:	83 c0 01             	add    $0x1,%eax
  8018b8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018bb:	39 f0                	cmp    %esi,%eax
  8018bd:	75 e2                	jne    8018a1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c4:	5b                   	pop    %ebx
  8018c5:	5e                   	pop    %esi
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    

008018c8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	53                   	push   %ebx
  8018cc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018cf:	89 c1                	mov    %eax,%ecx
  8018d1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018d4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018d8:	eb 0a                	jmp    8018e4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018da:	0f b6 10             	movzbl (%eax),%edx
  8018dd:	39 da                	cmp    %ebx,%edx
  8018df:	74 07                	je     8018e8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018e1:	83 c0 01             	add    $0x1,%eax
  8018e4:	39 c8                	cmp    %ecx,%eax
  8018e6:	72 f2                	jb     8018da <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018e8:	5b                   	pop    %ebx
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    

008018eb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	57                   	push   %edi
  8018ef:	56                   	push   %esi
  8018f0:	53                   	push   %ebx
  8018f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018f7:	eb 03                	jmp    8018fc <strtol+0x11>
		s++;
  8018f9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018fc:	0f b6 01             	movzbl (%ecx),%eax
  8018ff:	3c 20                	cmp    $0x20,%al
  801901:	74 f6                	je     8018f9 <strtol+0xe>
  801903:	3c 09                	cmp    $0x9,%al
  801905:	74 f2                	je     8018f9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801907:	3c 2b                	cmp    $0x2b,%al
  801909:	75 0a                	jne    801915 <strtol+0x2a>
		s++;
  80190b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80190e:	bf 00 00 00 00       	mov    $0x0,%edi
  801913:	eb 11                	jmp    801926 <strtol+0x3b>
  801915:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80191a:	3c 2d                	cmp    $0x2d,%al
  80191c:	75 08                	jne    801926 <strtol+0x3b>
		s++, neg = 1;
  80191e:	83 c1 01             	add    $0x1,%ecx
  801921:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801926:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80192c:	75 15                	jne    801943 <strtol+0x58>
  80192e:	80 39 30             	cmpb   $0x30,(%ecx)
  801931:	75 10                	jne    801943 <strtol+0x58>
  801933:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801937:	75 7c                	jne    8019b5 <strtol+0xca>
		s += 2, base = 16;
  801939:	83 c1 02             	add    $0x2,%ecx
  80193c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801941:	eb 16                	jmp    801959 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801943:	85 db                	test   %ebx,%ebx
  801945:	75 12                	jne    801959 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801947:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80194c:	80 39 30             	cmpb   $0x30,(%ecx)
  80194f:	75 08                	jne    801959 <strtol+0x6e>
		s++, base = 8;
  801951:	83 c1 01             	add    $0x1,%ecx
  801954:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801959:	b8 00 00 00 00       	mov    $0x0,%eax
  80195e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801961:	0f b6 11             	movzbl (%ecx),%edx
  801964:	8d 72 d0             	lea    -0x30(%edx),%esi
  801967:	89 f3                	mov    %esi,%ebx
  801969:	80 fb 09             	cmp    $0x9,%bl
  80196c:	77 08                	ja     801976 <strtol+0x8b>
			dig = *s - '0';
  80196e:	0f be d2             	movsbl %dl,%edx
  801971:	83 ea 30             	sub    $0x30,%edx
  801974:	eb 22                	jmp    801998 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801976:	8d 72 9f             	lea    -0x61(%edx),%esi
  801979:	89 f3                	mov    %esi,%ebx
  80197b:	80 fb 19             	cmp    $0x19,%bl
  80197e:	77 08                	ja     801988 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801980:	0f be d2             	movsbl %dl,%edx
  801983:	83 ea 57             	sub    $0x57,%edx
  801986:	eb 10                	jmp    801998 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801988:	8d 72 bf             	lea    -0x41(%edx),%esi
  80198b:	89 f3                	mov    %esi,%ebx
  80198d:	80 fb 19             	cmp    $0x19,%bl
  801990:	77 16                	ja     8019a8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801992:	0f be d2             	movsbl %dl,%edx
  801995:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801998:	3b 55 10             	cmp    0x10(%ebp),%edx
  80199b:	7d 0b                	jge    8019a8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80199d:	83 c1 01             	add    $0x1,%ecx
  8019a0:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019a4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019a6:	eb b9                	jmp    801961 <strtol+0x76>

	if (endptr)
  8019a8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019ac:	74 0d                	je     8019bb <strtol+0xd0>
		*endptr = (char *) s;
  8019ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019b1:	89 0e                	mov    %ecx,(%esi)
  8019b3:	eb 06                	jmp    8019bb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019b5:	85 db                	test   %ebx,%ebx
  8019b7:	74 98                	je     801951 <strtol+0x66>
  8019b9:	eb 9e                	jmp    801959 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019bb:	89 c2                	mov    %eax,%edx
  8019bd:	f7 da                	neg    %edx
  8019bf:	85 ff                	test   %edi,%edi
  8019c1:	0f 45 c2             	cmovne %edx,%eax
}
  8019c4:	5b                   	pop    %ebx
  8019c5:	5e                   	pop    %esi
  8019c6:	5f                   	pop    %edi
  8019c7:	5d                   	pop    %ebp
  8019c8:	c3                   	ret    

008019c9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	56                   	push   %esi
  8019cd:	53                   	push   %ebx
  8019ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8019d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019d7:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019d9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019de:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019e1:	83 ec 0c             	sub    $0xc,%esp
  8019e4:	50                   	push   %eax
  8019e5:	e8 1c e9 ff ff       	call   800306 <sys_ipc_recv>

	if (from_env_store != NULL)
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	85 f6                	test   %esi,%esi
  8019ef:	74 14                	je     801a05 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8019f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	78 09                	js     801a03 <ipc_recv+0x3a>
  8019fa:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a00:	8b 52 74             	mov    0x74(%edx),%edx
  801a03:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a05:	85 db                	test   %ebx,%ebx
  801a07:	74 14                	je     801a1d <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a09:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 09                	js     801a1b <ipc_recv+0x52>
  801a12:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a18:	8b 52 78             	mov    0x78(%edx),%edx
  801a1b:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	78 08                	js     801a29 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a21:	a1 04 40 80 00       	mov    0x804004,%eax
  801a26:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2c:	5b                   	pop    %ebx
  801a2d:	5e                   	pop    %esi
  801a2e:	5d                   	pop    %ebp
  801a2f:	c3                   	ret    

00801a30 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	57                   	push   %edi
  801a34:	56                   	push   %esi
  801a35:	53                   	push   %ebx
  801a36:	83 ec 0c             	sub    $0xc,%esp
  801a39:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a42:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a44:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a49:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a4c:	ff 75 14             	pushl  0x14(%ebp)
  801a4f:	53                   	push   %ebx
  801a50:	56                   	push   %esi
  801a51:	57                   	push   %edi
  801a52:	e8 8c e8 ff ff       	call   8002e3 <sys_ipc_try_send>

		if (err < 0) {
  801a57:	83 c4 10             	add    $0x10,%esp
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	79 1e                	jns    801a7c <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a5e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a61:	75 07                	jne    801a6a <ipc_send+0x3a>
				sys_yield();
  801a63:	e8 cf e6 ff ff       	call   800137 <sys_yield>
  801a68:	eb e2                	jmp    801a4c <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a6a:	50                   	push   %eax
  801a6b:	68 e0 21 80 00       	push   $0x8021e0
  801a70:	6a 49                	push   $0x49
  801a72:	68 ed 21 80 00       	push   $0x8021ed
  801a77:	e8 a8 f5 ff ff       	call   801024 <_panic>
		}

	} while (err < 0);

}
  801a7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5f                   	pop    %edi
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    

00801a84 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a8a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a8f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a92:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a98:	8b 52 50             	mov    0x50(%edx),%edx
  801a9b:	39 ca                	cmp    %ecx,%edx
  801a9d:	75 0d                	jne    801aac <ipc_find_env+0x28>
			return envs[i].env_id;
  801a9f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aa2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aa7:	8b 40 48             	mov    0x48(%eax),%eax
  801aaa:	eb 0f                	jmp    801abb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aac:	83 c0 01             	add    $0x1,%eax
  801aaf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ab4:	75 d9                	jne    801a8f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ab6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801abb:	5d                   	pop    %ebp
  801abc:	c3                   	ret    

00801abd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ac3:	89 d0                	mov    %edx,%eax
  801ac5:	c1 e8 16             	shr    $0x16,%eax
  801ac8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ad4:	f6 c1 01             	test   $0x1,%cl
  801ad7:	74 1d                	je     801af6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ad9:	c1 ea 0c             	shr    $0xc,%edx
  801adc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ae3:	f6 c2 01             	test   $0x1,%dl
  801ae6:	74 0e                	je     801af6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ae8:	c1 ea 0c             	shr    $0xc,%edx
  801aeb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801af2:	ef 
  801af3:	0f b7 c0             	movzwl %ax,%eax
}
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    
  801af8:	66 90                	xchg   %ax,%ax
  801afa:	66 90                	xchg   %ax,%ax
  801afc:	66 90                	xchg   %ax,%ax
  801afe:	66 90                	xchg   %ax,%ax

00801b00 <__udivdi3>:
  801b00:	55                   	push   %ebp
  801b01:	57                   	push   %edi
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	83 ec 1c             	sub    $0x1c,%esp
  801b07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b17:	85 f6                	test   %esi,%esi
  801b19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b1d:	89 ca                	mov    %ecx,%edx
  801b1f:	89 f8                	mov    %edi,%eax
  801b21:	75 3d                	jne    801b60 <__udivdi3+0x60>
  801b23:	39 cf                	cmp    %ecx,%edi
  801b25:	0f 87 c5 00 00 00    	ja     801bf0 <__udivdi3+0xf0>
  801b2b:	85 ff                	test   %edi,%edi
  801b2d:	89 fd                	mov    %edi,%ebp
  801b2f:	75 0b                	jne    801b3c <__udivdi3+0x3c>
  801b31:	b8 01 00 00 00       	mov    $0x1,%eax
  801b36:	31 d2                	xor    %edx,%edx
  801b38:	f7 f7                	div    %edi
  801b3a:	89 c5                	mov    %eax,%ebp
  801b3c:	89 c8                	mov    %ecx,%eax
  801b3e:	31 d2                	xor    %edx,%edx
  801b40:	f7 f5                	div    %ebp
  801b42:	89 c1                	mov    %eax,%ecx
  801b44:	89 d8                	mov    %ebx,%eax
  801b46:	89 cf                	mov    %ecx,%edi
  801b48:	f7 f5                	div    %ebp
  801b4a:	89 c3                	mov    %eax,%ebx
  801b4c:	89 d8                	mov    %ebx,%eax
  801b4e:	89 fa                	mov    %edi,%edx
  801b50:	83 c4 1c             	add    $0x1c,%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5f                   	pop    %edi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    
  801b58:	90                   	nop
  801b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b60:	39 ce                	cmp    %ecx,%esi
  801b62:	77 74                	ja     801bd8 <__udivdi3+0xd8>
  801b64:	0f bd fe             	bsr    %esi,%edi
  801b67:	83 f7 1f             	xor    $0x1f,%edi
  801b6a:	0f 84 98 00 00 00    	je     801c08 <__udivdi3+0x108>
  801b70:	bb 20 00 00 00       	mov    $0x20,%ebx
  801b75:	89 f9                	mov    %edi,%ecx
  801b77:	89 c5                	mov    %eax,%ebp
  801b79:	29 fb                	sub    %edi,%ebx
  801b7b:	d3 e6                	shl    %cl,%esi
  801b7d:	89 d9                	mov    %ebx,%ecx
  801b7f:	d3 ed                	shr    %cl,%ebp
  801b81:	89 f9                	mov    %edi,%ecx
  801b83:	d3 e0                	shl    %cl,%eax
  801b85:	09 ee                	or     %ebp,%esi
  801b87:	89 d9                	mov    %ebx,%ecx
  801b89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b8d:	89 d5                	mov    %edx,%ebp
  801b8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b93:	d3 ed                	shr    %cl,%ebp
  801b95:	89 f9                	mov    %edi,%ecx
  801b97:	d3 e2                	shl    %cl,%edx
  801b99:	89 d9                	mov    %ebx,%ecx
  801b9b:	d3 e8                	shr    %cl,%eax
  801b9d:	09 c2                	or     %eax,%edx
  801b9f:	89 d0                	mov    %edx,%eax
  801ba1:	89 ea                	mov    %ebp,%edx
  801ba3:	f7 f6                	div    %esi
  801ba5:	89 d5                	mov    %edx,%ebp
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	f7 64 24 0c          	mull   0xc(%esp)
  801bad:	39 d5                	cmp    %edx,%ebp
  801baf:	72 10                	jb     801bc1 <__udivdi3+0xc1>
  801bb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bb5:	89 f9                	mov    %edi,%ecx
  801bb7:	d3 e6                	shl    %cl,%esi
  801bb9:	39 c6                	cmp    %eax,%esi
  801bbb:	73 07                	jae    801bc4 <__udivdi3+0xc4>
  801bbd:	39 d5                	cmp    %edx,%ebp
  801bbf:	75 03                	jne    801bc4 <__udivdi3+0xc4>
  801bc1:	83 eb 01             	sub    $0x1,%ebx
  801bc4:	31 ff                	xor    %edi,%edi
  801bc6:	89 d8                	mov    %ebx,%eax
  801bc8:	89 fa                	mov    %edi,%edx
  801bca:	83 c4 1c             	add    $0x1c,%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5f                   	pop    %edi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    
  801bd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bd8:	31 ff                	xor    %edi,%edi
  801bda:	31 db                	xor    %ebx,%ebx
  801bdc:	89 d8                	mov    %ebx,%eax
  801bde:	89 fa                	mov    %edi,%edx
  801be0:	83 c4 1c             	add    $0x1c,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    
  801be8:	90                   	nop
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	89 d8                	mov    %ebx,%eax
  801bf2:	f7 f7                	div    %edi
  801bf4:	31 ff                	xor    %edi,%edi
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	89 d8                	mov    %ebx,%eax
  801bfa:	89 fa                	mov    %edi,%edx
  801bfc:	83 c4 1c             	add    $0x1c,%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5f                   	pop    %edi
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    
  801c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c08:	39 ce                	cmp    %ecx,%esi
  801c0a:	72 0c                	jb     801c18 <__udivdi3+0x118>
  801c0c:	31 db                	xor    %ebx,%ebx
  801c0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c12:	0f 87 34 ff ff ff    	ja     801b4c <__udivdi3+0x4c>
  801c18:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c1d:	e9 2a ff ff ff       	jmp    801b4c <__udivdi3+0x4c>
  801c22:	66 90                	xchg   %ax,%ax
  801c24:	66 90                	xchg   %ax,%ax
  801c26:	66 90                	xchg   %ax,%ax
  801c28:	66 90                	xchg   %ax,%ax
  801c2a:	66 90                	xchg   %ax,%ax
  801c2c:	66 90                	xchg   %ax,%ax
  801c2e:	66 90                	xchg   %ax,%ax

00801c30 <__umoddi3>:
  801c30:	55                   	push   %ebp
  801c31:	57                   	push   %edi
  801c32:	56                   	push   %esi
  801c33:	53                   	push   %ebx
  801c34:	83 ec 1c             	sub    $0x1c,%esp
  801c37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c47:	85 d2                	test   %edx,%edx
  801c49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c51:	89 f3                	mov    %esi,%ebx
  801c53:	89 3c 24             	mov    %edi,(%esp)
  801c56:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c5a:	75 1c                	jne    801c78 <__umoddi3+0x48>
  801c5c:	39 f7                	cmp    %esi,%edi
  801c5e:	76 50                	jbe    801cb0 <__umoddi3+0x80>
  801c60:	89 c8                	mov    %ecx,%eax
  801c62:	89 f2                	mov    %esi,%edx
  801c64:	f7 f7                	div    %edi
  801c66:	89 d0                	mov    %edx,%eax
  801c68:	31 d2                	xor    %edx,%edx
  801c6a:	83 c4 1c             	add    $0x1c,%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
  801c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c78:	39 f2                	cmp    %esi,%edx
  801c7a:	89 d0                	mov    %edx,%eax
  801c7c:	77 52                	ja     801cd0 <__umoddi3+0xa0>
  801c7e:	0f bd ea             	bsr    %edx,%ebp
  801c81:	83 f5 1f             	xor    $0x1f,%ebp
  801c84:	75 5a                	jne    801ce0 <__umoddi3+0xb0>
  801c86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801c8a:	0f 82 e0 00 00 00    	jb     801d70 <__umoddi3+0x140>
  801c90:	39 0c 24             	cmp    %ecx,(%esp)
  801c93:	0f 86 d7 00 00 00    	jbe    801d70 <__umoddi3+0x140>
  801c99:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ca1:	83 c4 1c             	add    $0x1c,%esp
  801ca4:	5b                   	pop    %ebx
  801ca5:	5e                   	pop    %esi
  801ca6:	5f                   	pop    %edi
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	85 ff                	test   %edi,%edi
  801cb2:	89 fd                	mov    %edi,%ebp
  801cb4:	75 0b                	jne    801cc1 <__umoddi3+0x91>
  801cb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbb:	31 d2                	xor    %edx,%edx
  801cbd:	f7 f7                	div    %edi
  801cbf:	89 c5                	mov    %eax,%ebp
  801cc1:	89 f0                	mov    %esi,%eax
  801cc3:	31 d2                	xor    %edx,%edx
  801cc5:	f7 f5                	div    %ebp
  801cc7:	89 c8                	mov    %ecx,%eax
  801cc9:	f7 f5                	div    %ebp
  801ccb:	89 d0                	mov    %edx,%eax
  801ccd:	eb 99                	jmp    801c68 <__umoddi3+0x38>
  801ccf:	90                   	nop
  801cd0:	89 c8                	mov    %ecx,%eax
  801cd2:	89 f2                	mov    %esi,%edx
  801cd4:	83 c4 1c             	add    $0x1c,%esp
  801cd7:	5b                   	pop    %ebx
  801cd8:	5e                   	pop    %esi
  801cd9:	5f                   	pop    %edi
  801cda:	5d                   	pop    %ebp
  801cdb:	c3                   	ret    
  801cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	8b 34 24             	mov    (%esp),%esi
  801ce3:	bf 20 00 00 00       	mov    $0x20,%edi
  801ce8:	89 e9                	mov    %ebp,%ecx
  801cea:	29 ef                	sub    %ebp,%edi
  801cec:	d3 e0                	shl    %cl,%eax
  801cee:	89 f9                	mov    %edi,%ecx
  801cf0:	89 f2                	mov    %esi,%edx
  801cf2:	d3 ea                	shr    %cl,%edx
  801cf4:	89 e9                	mov    %ebp,%ecx
  801cf6:	09 c2                	or     %eax,%edx
  801cf8:	89 d8                	mov    %ebx,%eax
  801cfa:	89 14 24             	mov    %edx,(%esp)
  801cfd:	89 f2                	mov    %esi,%edx
  801cff:	d3 e2                	shl    %cl,%edx
  801d01:	89 f9                	mov    %edi,%ecx
  801d03:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d0b:	d3 e8                	shr    %cl,%eax
  801d0d:	89 e9                	mov    %ebp,%ecx
  801d0f:	89 c6                	mov    %eax,%esi
  801d11:	d3 e3                	shl    %cl,%ebx
  801d13:	89 f9                	mov    %edi,%ecx
  801d15:	89 d0                	mov    %edx,%eax
  801d17:	d3 e8                	shr    %cl,%eax
  801d19:	89 e9                	mov    %ebp,%ecx
  801d1b:	09 d8                	or     %ebx,%eax
  801d1d:	89 d3                	mov    %edx,%ebx
  801d1f:	89 f2                	mov    %esi,%edx
  801d21:	f7 34 24             	divl   (%esp)
  801d24:	89 d6                	mov    %edx,%esi
  801d26:	d3 e3                	shl    %cl,%ebx
  801d28:	f7 64 24 04          	mull   0x4(%esp)
  801d2c:	39 d6                	cmp    %edx,%esi
  801d2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d32:	89 d1                	mov    %edx,%ecx
  801d34:	89 c3                	mov    %eax,%ebx
  801d36:	72 08                	jb     801d40 <__umoddi3+0x110>
  801d38:	75 11                	jne    801d4b <__umoddi3+0x11b>
  801d3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d3e:	73 0b                	jae    801d4b <__umoddi3+0x11b>
  801d40:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d44:	1b 14 24             	sbb    (%esp),%edx
  801d47:	89 d1                	mov    %edx,%ecx
  801d49:	89 c3                	mov    %eax,%ebx
  801d4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d4f:	29 da                	sub    %ebx,%edx
  801d51:	19 ce                	sbb    %ecx,%esi
  801d53:	89 f9                	mov    %edi,%ecx
  801d55:	89 f0                	mov    %esi,%eax
  801d57:	d3 e0                	shl    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	d3 ea                	shr    %cl,%edx
  801d5d:	89 e9                	mov    %ebp,%ecx
  801d5f:	d3 ee                	shr    %cl,%esi
  801d61:	09 d0                	or     %edx,%eax
  801d63:	89 f2                	mov    %esi,%edx
  801d65:	83 c4 1c             	add    $0x1c,%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5f                   	pop    %edi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    
  801d6d:	8d 76 00             	lea    0x0(%esi),%esi
  801d70:	29 f9                	sub    %edi,%ecx
  801d72:	19 d6                	sbb    %edx,%esi
  801d74:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d7c:	e9 18 ff ff ff       	jmp    801c99 <__umoddi3+0x69>
