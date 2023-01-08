
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
  800057:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800086:	e8 a6 04 00 00       	call   800531 <close_all>
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
  8000ff:	68 2a 22 80 00       	push   $0x80222a
  800104:	6a 23                	push   $0x23
  800106:	68 47 22 80 00       	push   $0x802247
  80010b:	e8 9a 13 00 00       	call   8014aa <_panic>

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
  800180:	68 2a 22 80 00       	push   $0x80222a
  800185:	6a 23                	push   $0x23
  800187:	68 47 22 80 00       	push   $0x802247
  80018c:	e8 19 13 00 00       	call   8014aa <_panic>

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
  8001c2:	68 2a 22 80 00       	push   $0x80222a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 47 22 80 00       	push   $0x802247
  8001ce:	e8 d7 12 00 00       	call   8014aa <_panic>

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
  800204:	68 2a 22 80 00       	push   $0x80222a
  800209:	6a 23                	push   $0x23
  80020b:	68 47 22 80 00       	push   $0x802247
  800210:	e8 95 12 00 00       	call   8014aa <_panic>

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
  800246:	68 2a 22 80 00       	push   $0x80222a
  80024b:	6a 23                	push   $0x23
  80024d:	68 47 22 80 00       	push   $0x802247
  800252:	e8 53 12 00 00       	call   8014aa <_panic>

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
  800288:	68 2a 22 80 00       	push   $0x80222a
  80028d:	6a 23                	push   $0x23
  80028f:	68 47 22 80 00       	push   $0x802247
  800294:	e8 11 12 00 00       	call   8014aa <_panic>

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
  8002ca:	68 2a 22 80 00       	push   $0x80222a
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 47 22 80 00       	push   $0x802247
  8002d6:	e8 cf 11 00 00       	call   8014aa <_panic>

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
  80032e:	68 2a 22 80 00       	push   $0x80222a
  800333:	6a 23                	push   $0x23
  800335:	68 47 22 80 00       	push   $0x802247
  80033a:	e8 6b 11 00 00       	call   8014aa <_panic>

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

00800347 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	57                   	push   %edi
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	b8 0e 00 00 00       	mov    $0xe,%eax
  800357:	89 d1                	mov    %edx,%ecx
  800359:	89 d3                	mov    %edx,%ebx
  80035b:	89 d7                	mov    %edx,%edi
  80035d:	89 d6                	mov    %edx,%esi
  80035f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800369:	8b 45 08             	mov    0x8(%ebp),%eax
  80036c:	05 00 00 00 30       	add    $0x30000000,%eax
  800371:	c1 e8 0c             	shr    $0xc,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	05 00 00 00 30       	add    $0x30000000,%eax
  800381:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800386:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80038b:	5d                   	pop    %ebp
  80038c:	c3                   	ret    

0080038d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800393:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800398:	89 c2                	mov    %eax,%edx
  80039a:	c1 ea 16             	shr    $0x16,%edx
  80039d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a4:	f6 c2 01             	test   $0x1,%dl
  8003a7:	74 11                	je     8003ba <fd_alloc+0x2d>
  8003a9:	89 c2                	mov    %eax,%edx
  8003ab:	c1 ea 0c             	shr    $0xc,%edx
  8003ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b5:	f6 c2 01             	test   $0x1,%dl
  8003b8:	75 09                	jne    8003c3 <fd_alloc+0x36>
			*fd_store = fd;
  8003ba:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c1:	eb 17                	jmp    8003da <fd_alloc+0x4d>
  8003c3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003c8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003cd:	75 c9                	jne    800398 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003cf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    

008003dc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003e2:	83 f8 1f             	cmp    $0x1f,%eax
  8003e5:	77 36                	ja     80041d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003e7:	c1 e0 0c             	shl    $0xc,%eax
  8003ea:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ef:	89 c2                	mov    %eax,%edx
  8003f1:	c1 ea 16             	shr    $0x16,%edx
  8003f4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003fb:	f6 c2 01             	test   $0x1,%dl
  8003fe:	74 24                	je     800424 <fd_lookup+0x48>
  800400:	89 c2                	mov    %eax,%edx
  800402:	c1 ea 0c             	shr    $0xc,%edx
  800405:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80040c:	f6 c2 01             	test   $0x1,%dl
  80040f:	74 1a                	je     80042b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800411:	8b 55 0c             	mov    0xc(%ebp),%edx
  800414:	89 02                	mov    %eax,(%edx)
	return 0;
  800416:	b8 00 00 00 00       	mov    $0x0,%eax
  80041b:	eb 13                	jmp    800430 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80041d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800422:	eb 0c                	jmp    800430 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800424:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800429:	eb 05                	jmp    800430 <fd_lookup+0x54>
  80042b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    

00800432 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043b:	ba d4 22 80 00       	mov    $0x8022d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800440:	eb 13                	jmp    800455 <dev_lookup+0x23>
  800442:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800445:	39 08                	cmp    %ecx,(%eax)
  800447:	75 0c                	jne    800455 <dev_lookup+0x23>
			*dev = devtab[i];
  800449:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80044c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	eb 2e                	jmp    800483 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	85 c0                	test   %eax,%eax
  800459:	75 e7                	jne    800442 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045b:	a1 08 40 80 00       	mov    0x804008,%eax
  800460:	8b 40 48             	mov    0x48(%eax),%eax
  800463:	83 ec 04             	sub    $0x4,%esp
  800466:	51                   	push   %ecx
  800467:	50                   	push   %eax
  800468:	68 58 22 80 00       	push   $0x802258
  80046d:	e8 11 11 00 00       	call   801583 <cprintf>
	*dev = 0;
  800472:	8b 45 0c             	mov    0xc(%ebp),%eax
  800475:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	56                   	push   %esi
  800489:	53                   	push   %ebx
  80048a:	83 ec 10             	sub    $0x10,%esp
  80048d:	8b 75 08             	mov    0x8(%ebp),%esi
  800490:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800493:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800496:	50                   	push   %eax
  800497:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80049d:	c1 e8 0c             	shr    $0xc,%eax
  8004a0:	50                   	push   %eax
  8004a1:	e8 36 ff ff ff       	call   8003dc <fd_lookup>
  8004a6:	83 c4 08             	add    $0x8,%esp
  8004a9:	85 c0                	test   %eax,%eax
  8004ab:	78 05                	js     8004b2 <fd_close+0x2d>
	    || fd != fd2)
  8004ad:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004b0:	74 0c                	je     8004be <fd_close+0x39>
		return (must_exist ? r : 0);
  8004b2:	84 db                	test   %bl,%bl
  8004b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b9:	0f 44 c2             	cmove  %edx,%eax
  8004bc:	eb 41                	jmp    8004ff <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004c4:	50                   	push   %eax
  8004c5:	ff 36                	pushl  (%esi)
  8004c7:	e8 66 ff ff ff       	call   800432 <dev_lookup>
  8004cc:	89 c3                	mov    %eax,%ebx
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	78 1a                	js     8004ef <fd_close+0x6a>
		if (dev->dev_close)
  8004d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004d8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004db:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	74 0b                	je     8004ef <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004e4:	83 ec 0c             	sub    $0xc,%esp
  8004e7:	56                   	push   %esi
  8004e8:	ff d0                	call   *%eax
  8004ea:	89 c3                	mov    %eax,%ebx
  8004ec:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	56                   	push   %esi
  8004f3:	6a 00                	push   $0x0
  8004f5:	e8 e1 fc ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	89 d8                	mov    %ebx,%eax
}
  8004ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800502:	5b                   	pop    %ebx
  800503:	5e                   	pop    %esi
  800504:	5d                   	pop    %ebp
  800505:	c3                   	ret    

00800506 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80050c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050f:	50                   	push   %eax
  800510:	ff 75 08             	pushl  0x8(%ebp)
  800513:	e8 c4 fe ff ff       	call   8003dc <fd_lookup>
  800518:	83 c4 08             	add    $0x8,%esp
  80051b:	85 c0                	test   %eax,%eax
  80051d:	78 10                	js     80052f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	6a 01                	push   $0x1
  800524:	ff 75 f4             	pushl  -0xc(%ebp)
  800527:	e8 59 ff ff ff       	call   800485 <fd_close>
  80052c:	83 c4 10             	add    $0x10,%esp
}
  80052f:	c9                   	leave  
  800530:	c3                   	ret    

00800531 <close_all>:

void
close_all(void)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	53                   	push   %ebx
  800535:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800538:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80053d:	83 ec 0c             	sub    $0xc,%esp
  800540:	53                   	push   %ebx
  800541:	e8 c0 ff ff ff       	call   800506 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800546:	83 c3 01             	add    $0x1,%ebx
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	83 fb 20             	cmp    $0x20,%ebx
  80054f:	75 ec                	jne    80053d <close_all+0xc>
		close(i);
}
  800551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800554:	c9                   	leave  
  800555:	c3                   	ret    

00800556 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	57                   	push   %edi
  80055a:	56                   	push   %esi
  80055b:	53                   	push   %ebx
  80055c:	83 ec 2c             	sub    $0x2c,%esp
  80055f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800562:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800565:	50                   	push   %eax
  800566:	ff 75 08             	pushl  0x8(%ebp)
  800569:	e8 6e fe ff ff       	call   8003dc <fd_lookup>
  80056e:	83 c4 08             	add    $0x8,%esp
  800571:	85 c0                	test   %eax,%eax
  800573:	0f 88 c1 00 00 00    	js     80063a <dup+0xe4>
		return r;
	close(newfdnum);
  800579:	83 ec 0c             	sub    $0xc,%esp
  80057c:	56                   	push   %esi
  80057d:	e8 84 ff ff ff       	call   800506 <close>

	newfd = INDEX2FD(newfdnum);
  800582:	89 f3                	mov    %esi,%ebx
  800584:	c1 e3 0c             	shl    $0xc,%ebx
  800587:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80058d:	83 c4 04             	add    $0x4,%esp
  800590:	ff 75 e4             	pushl  -0x1c(%ebp)
  800593:	e8 de fd ff ff       	call   800376 <fd2data>
  800598:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80059a:	89 1c 24             	mov    %ebx,(%esp)
  80059d:	e8 d4 fd ff ff       	call   800376 <fd2data>
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a8:	89 f8                	mov    %edi,%eax
  8005aa:	c1 e8 16             	shr    $0x16,%eax
  8005ad:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b4:	a8 01                	test   $0x1,%al
  8005b6:	74 37                	je     8005ef <dup+0x99>
  8005b8:	89 f8                	mov    %edi,%eax
  8005ba:	c1 e8 0c             	shr    $0xc,%eax
  8005bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c4:	f6 c2 01             	test   $0x1,%dl
  8005c7:	74 26                	je     8005ef <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d0:	83 ec 0c             	sub    $0xc,%esp
  8005d3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d8:	50                   	push   %eax
  8005d9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005dc:	6a 00                	push   $0x0
  8005de:	57                   	push   %edi
  8005df:	6a 00                	push   $0x0
  8005e1:	e8 b3 fb ff ff       	call   800199 <sys_page_map>
  8005e6:	89 c7                	mov    %eax,%edi
  8005e8:	83 c4 20             	add    $0x20,%esp
  8005eb:	85 c0                	test   %eax,%eax
  8005ed:	78 2e                	js     80061d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f2:	89 d0                	mov    %edx,%eax
  8005f4:	c1 e8 0c             	shr    $0xc,%eax
  8005f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fe:	83 ec 0c             	sub    $0xc,%esp
  800601:	25 07 0e 00 00       	and    $0xe07,%eax
  800606:	50                   	push   %eax
  800607:	53                   	push   %ebx
  800608:	6a 00                	push   $0x0
  80060a:	52                   	push   %edx
  80060b:	6a 00                	push   $0x0
  80060d:	e8 87 fb ff ff       	call   800199 <sys_page_map>
  800612:	89 c7                	mov    %eax,%edi
  800614:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800617:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800619:	85 ff                	test   %edi,%edi
  80061b:	79 1d                	jns    80063a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	53                   	push   %ebx
  800621:	6a 00                	push   $0x0
  800623:	e8 b3 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  800628:	83 c4 08             	add    $0x8,%esp
  80062b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80062e:	6a 00                	push   $0x0
  800630:	e8 a6 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800635:	83 c4 10             	add    $0x10,%esp
  800638:	89 f8                	mov    %edi,%eax
}
  80063a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063d:	5b                   	pop    %ebx
  80063e:	5e                   	pop    %esi
  80063f:	5f                   	pop    %edi
  800640:	5d                   	pop    %ebp
  800641:	c3                   	ret    

00800642 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800642:	55                   	push   %ebp
  800643:	89 e5                	mov    %esp,%ebp
  800645:	53                   	push   %ebx
  800646:	83 ec 14             	sub    $0x14,%esp
  800649:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80064c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80064f:	50                   	push   %eax
  800650:	53                   	push   %ebx
  800651:	e8 86 fd ff ff       	call   8003dc <fd_lookup>
  800656:	83 c4 08             	add    $0x8,%esp
  800659:	89 c2                	mov    %eax,%edx
  80065b:	85 c0                	test   %eax,%eax
  80065d:	78 6d                	js     8006cc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800665:	50                   	push   %eax
  800666:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800669:	ff 30                	pushl  (%eax)
  80066b:	e8 c2 fd ff ff       	call   800432 <dev_lookup>
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	85 c0                	test   %eax,%eax
  800675:	78 4c                	js     8006c3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800677:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80067a:	8b 42 08             	mov    0x8(%edx),%eax
  80067d:	83 e0 03             	and    $0x3,%eax
  800680:	83 f8 01             	cmp    $0x1,%eax
  800683:	75 21                	jne    8006a6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800685:	a1 08 40 80 00       	mov    0x804008,%eax
  80068a:	8b 40 48             	mov    0x48(%eax),%eax
  80068d:	83 ec 04             	sub    $0x4,%esp
  800690:	53                   	push   %ebx
  800691:	50                   	push   %eax
  800692:	68 99 22 80 00       	push   $0x802299
  800697:	e8 e7 0e 00 00       	call   801583 <cprintf>
		return -E_INVAL;
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006a4:	eb 26                	jmp    8006cc <read+0x8a>
	}
	if (!dev->dev_read)
  8006a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a9:	8b 40 08             	mov    0x8(%eax),%eax
  8006ac:	85 c0                	test   %eax,%eax
  8006ae:	74 17                	je     8006c7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b0:	83 ec 04             	sub    $0x4,%esp
  8006b3:	ff 75 10             	pushl  0x10(%ebp)
  8006b6:	ff 75 0c             	pushl  0xc(%ebp)
  8006b9:	52                   	push   %edx
  8006ba:	ff d0                	call   *%eax
  8006bc:	89 c2                	mov    %eax,%edx
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	eb 09                	jmp    8006cc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c3:	89 c2                	mov    %eax,%edx
  8006c5:	eb 05                	jmp    8006cc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006cc:	89 d0                	mov    %edx,%eax
  8006ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d1:	c9                   	leave  
  8006d2:	c3                   	ret    

008006d3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	57                   	push   %edi
  8006d7:	56                   	push   %esi
  8006d8:	53                   	push   %ebx
  8006d9:	83 ec 0c             	sub    $0xc,%esp
  8006dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006df:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e7:	eb 21                	jmp    80070a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e9:	83 ec 04             	sub    $0x4,%esp
  8006ec:	89 f0                	mov    %esi,%eax
  8006ee:	29 d8                	sub    %ebx,%eax
  8006f0:	50                   	push   %eax
  8006f1:	89 d8                	mov    %ebx,%eax
  8006f3:	03 45 0c             	add    0xc(%ebp),%eax
  8006f6:	50                   	push   %eax
  8006f7:	57                   	push   %edi
  8006f8:	e8 45 ff ff ff       	call   800642 <read>
		if (m < 0)
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	85 c0                	test   %eax,%eax
  800702:	78 10                	js     800714 <readn+0x41>
			return m;
		if (m == 0)
  800704:	85 c0                	test   %eax,%eax
  800706:	74 0a                	je     800712 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800708:	01 c3                	add    %eax,%ebx
  80070a:	39 f3                	cmp    %esi,%ebx
  80070c:	72 db                	jb     8006e9 <readn+0x16>
  80070e:	89 d8                	mov    %ebx,%eax
  800710:	eb 02                	jmp    800714 <readn+0x41>
  800712:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800714:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800717:	5b                   	pop    %ebx
  800718:	5e                   	pop    %esi
  800719:	5f                   	pop    %edi
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	53                   	push   %ebx
  800720:	83 ec 14             	sub    $0x14,%esp
  800723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800726:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800729:	50                   	push   %eax
  80072a:	53                   	push   %ebx
  80072b:	e8 ac fc ff ff       	call   8003dc <fd_lookup>
  800730:	83 c4 08             	add    $0x8,%esp
  800733:	89 c2                	mov    %eax,%edx
  800735:	85 c0                	test   %eax,%eax
  800737:	78 68                	js     8007a1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80073f:	50                   	push   %eax
  800740:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800743:	ff 30                	pushl  (%eax)
  800745:	e8 e8 fc ff ff       	call   800432 <dev_lookup>
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	85 c0                	test   %eax,%eax
  80074f:	78 47                	js     800798 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800751:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800754:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800758:	75 21                	jne    80077b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80075a:	a1 08 40 80 00       	mov    0x804008,%eax
  80075f:	8b 40 48             	mov    0x48(%eax),%eax
  800762:	83 ec 04             	sub    $0x4,%esp
  800765:	53                   	push   %ebx
  800766:	50                   	push   %eax
  800767:	68 b5 22 80 00       	push   $0x8022b5
  80076c:	e8 12 0e 00 00       	call   801583 <cprintf>
		return -E_INVAL;
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800779:	eb 26                	jmp    8007a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80077b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80077e:	8b 52 0c             	mov    0xc(%edx),%edx
  800781:	85 d2                	test   %edx,%edx
  800783:	74 17                	je     80079c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800785:	83 ec 04             	sub    $0x4,%esp
  800788:	ff 75 10             	pushl  0x10(%ebp)
  80078b:	ff 75 0c             	pushl  0xc(%ebp)
  80078e:	50                   	push   %eax
  80078f:	ff d2                	call   *%edx
  800791:	89 c2                	mov    %eax,%edx
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	eb 09                	jmp    8007a1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800798:	89 c2                	mov    %eax,%edx
  80079a:	eb 05                	jmp    8007a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80079c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a1:	89 d0                	mov    %edx,%eax
  8007a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ae:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b1:	50                   	push   %eax
  8007b2:	ff 75 08             	pushl  0x8(%ebp)
  8007b5:	e8 22 fc ff ff       	call   8003dc <fd_lookup>
  8007ba:	83 c4 08             	add    $0x8,%esp
  8007bd:	85 c0                	test   %eax,%eax
  8007bf:	78 0e                	js     8007cf <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	53                   	push   %ebx
  8007d5:	83 ec 14             	sub    $0x14,%esp
  8007d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007de:	50                   	push   %eax
  8007df:	53                   	push   %ebx
  8007e0:	e8 f7 fb ff ff       	call   8003dc <fd_lookup>
  8007e5:	83 c4 08             	add    $0x8,%esp
  8007e8:	89 c2                	mov    %eax,%edx
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	78 65                	js     800853 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f4:	50                   	push   %eax
  8007f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f8:	ff 30                	pushl  (%eax)
  8007fa:	e8 33 fc ff ff       	call   800432 <dev_lookup>
  8007ff:	83 c4 10             	add    $0x10,%esp
  800802:	85 c0                	test   %eax,%eax
  800804:	78 44                	js     80084a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800806:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800809:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80080d:	75 21                	jne    800830 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80080f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800814:	8b 40 48             	mov    0x48(%eax),%eax
  800817:	83 ec 04             	sub    $0x4,%esp
  80081a:	53                   	push   %ebx
  80081b:	50                   	push   %eax
  80081c:	68 78 22 80 00       	push   $0x802278
  800821:	e8 5d 0d 00 00       	call   801583 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80082e:	eb 23                	jmp    800853 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800830:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800833:	8b 52 18             	mov    0x18(%edx),%edx
  800836:	85 d2                	test   %edx,%edx
  800838:	74 14                	je     80084e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	ff 75 0c             	pushl  0xc(%ebp)
  800840:	50                   	push   %eax
  800841:	ff d2                	call   *%edx
  800843:	89 c2                	mov    %eax,%edx
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	eb 09                	jmp    800853 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084a:	89 c2                	mov    %eax,%edx
  80084c:	eb 05                	jmp    800853 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80084e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800853:	89 d0                	mov    %edx,%eax
  800855:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	83 ec 14             	sub    $0x14,%esp
  800861:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800864:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800867:	50                   	push   %eax
  800868:	ff 75 08             	pushl  0x8(%ebp)
  80086b:	e8 6c fb ff ff       	call   8003dc <fd_lookup>
  800870:	83 c4 08             	add    $0x8,%esp
  800873:	89 c2                	mov    %eax,%edx
  800875:	85 c0                	test   %eax,%eax
  800877:	78 58                	js     8008d1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800879:	83 ec 08             	sub    $0x8,%esp
  80087c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087f:	50                   	push   %eax
  800880:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800883:	ff 30                	pushl  (%eax)
  800885:	e8 a8 fb ff ff       	call   800432 <dev_lookup>
  80088a:	83 c4 10             	add    $0x10,%esp
  80088d:	85 c0                	test   %eax,%eax
  80088f:	78 37                	js     8008c8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800891:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800894:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800898:	74 32                	je     8008cc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80089a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80089d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008a4:	00 00 00 
	stat->st_isdir = 0;
  8008a7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ae:	00 00 00 
	stat->st_dev = dev;
  8008b1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	53                   	push   %ebx
  8008bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8008be:	ff 50 14             	call   *0x14(%eax)
  8008c1:	89 c2                	mov    %eax,%edx
  8008c3:	83 c4 10             	add    $0x10,%esp
  8008c6:	eb 09                	jmp    8008d1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c8:	89 c2                	mov    %eax,%edx
  8008ca:	eb 05                	jmp    8008d1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d1:	89 d0                	mov    %edx,%eax
  8008d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008dd:	83 ec 08             	sub    $0x8,%esp
  8008e0:	6a 00                	push   $0x0
  8008e2:	ff 75 08             	pushl  0x8(%ebp)
  8008e5:	e8 d6 01 00 00       	call   800ac0 <open>
  8008ea:	89 c3                	mov    %eax,%ebx
  8008ec:	83 c4 10             	add    $0x10,%esp
  8008ef:	85 c0                	test   %eax,%eax
  8008f1:	78 1b                	js     80090e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008f3:	83 ec 08             	sub    $0x8,%esp
  8008f6:	ff 75 0c             	pushl  0xc(%ebp)
  8008f9:	50                   	push   %eax
  8008fa:	e8 5b ff ff ff       	call   80085a <fstat>
  8008ff:	89 c6                	mov    %eax,%esi
	close(fd);
  800901:	89 1c 24             	mov    %ebx,(%esp)
  800904:	e8 fd fb ff ff       	call   800506 <close>
	return r;
  800909:	83 c4 10             	add    $0x10,%esp
  80090c:	89 f0                	mov    %esi,%eax
}
  80090e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800911:	5b                   	pop    %ebx
  800912:	5e                   	pop    %esi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	89 c6                	mov    %eax,%esi
  80091c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80091e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800925:	75 12                	jne    800939 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800927:	83 ec 0c             	sub    $0xc,%esp
  80092a:	6a 01                	push   $0x1
  80092c:	e8 d9 15 00 00       	call   801f0a <ipc_find_env>
  800931:	a3 00 40 80 00       	mov    %eax,0x804000
  800936:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800939:	6a 07                	push   $0x7
  80093b:	68 00 50 80 00       	push   $0x805000
  800940:	56                   	push   %esi
  800941:	ff 35 00 40 80 00    	pushl  0x804000
  800947:	e8 6a 15 00 00       	call   801eb6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80094c:	83 c4 0c             	add    $0xc,%esp
  80094f:	6a 00                	push   $0x0
  800951:	53                   	push   %ebx
  800952:	6a 00                	push   $0x0
  800954:	e8 f6 14 00 00       	call   801e4f <ipc_recv>
}
  800959:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 40 0c             	mov    0xc(%eax),%eax
  80096c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800971:	8b 45 0c             	mov    0xc(%ebp),%eax
  800974:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800979:	ba 00 00 00 00       	mov    $0x0,%edx
  80097e:	b8 02 00 00 00       	mov    $0x2,%eax
  800983:	e8 8d ff ff ff       	call   800915 <fsipc>
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 40 0c             	mov    0xc(%eax),%eax
  800996:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80099b:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a0:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a5:	e8 6b ff ff ff       	call   800915 <fsipc>
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	53                   	push   %ebx
  8009b0:	83 ec 04             	sub    $0x4,%esp
  8009b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009bc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009cb:	e8 45 ff ff ff       	call   800915 <fsipc>
  8009d0:	85 c0                	test   %eax,%eax
  8009d2:	78 2c                	js     800a00 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009d4:	83 ec 08             	sub    $0x8,%esp
  8009d7:	68 00 50 80 00       	push   $0x805000
  8009dc:	53                   	push   %ebx
  8009dd:	e8 26 11 00 00       	call   801b08 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009e7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ed:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009f8:	83 c4 10             	add    $0x10,%esp
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    

00800a05 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	83 ec 0c             	sub    $0xc,%esp
  800a0b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a11:	8b 52 0c             	mov    0xc(%edx),%edx
  800a14:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a1a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a1f:	50                   	push   %eax
  800a20:	ff 75 0c             	pushl  0xc(%ebp)
  800a23:	68 08 50 80 00       	push   $0x805008
  800a28:	e8 6d 12 00 00       	call   801c9a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a32:	b8 04 00 00 00       	mov    $0x4,%eax
  800a37:	e8 d9 fe ff ff       	call   800915 <fsipc>

}
  800a3c:	c9                   	leave  
  800a3d:	c3                   	ret    

00800a3e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
  800a43:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a51:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a57:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a61:	e8 af fe ff ff       	call   800915 <fsipc>
  800a66:	89 c3                	mov    %eax,%ebx
  800a68:	85 c0                	test   %eax,%eax
  800a6a:	78 4b                	js     800ab7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a6c:	39 c6                	cmp    %eax,%esi
  800a6e:	73 16                	jae    800a86 <devfile_read+0x48>
  800a70:	68 e8 22 80 00       	push   $0x8022e8
  800a75:	68 ef 22 80 00       	push   $0x8022ef
  800a7a:	6a 7c                	push   $0x7c
  800a7c:	68 04 23 80 00       	push   $0x802304
  800a81:	e8 24 0a 00 00       	call   8014aa <_panic>
	assert(r <= PGSIZE);
  800a86:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a8b:	7e 16                	jle    800aa3 <devfile_read+0x65>
  800a8d:	68 0f 23 80 00       	push   $0x80230f
  800a92:	68 ef 22 80 00       	push   $0x8022ef
  800a97:	6a 7d                	push   $0x7d
  800a99:	68 04 23 80 00       	push   $0x802304
  800a9e:	e8 07 0a 00 00       	call   8014aa <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa3:	83 ec 04             	sub    $0x4,%esp
  800aa6:	50                   	push   %eax
  800aa7:	68 00 50 80 00       	push   $0x805000
  800aac:	ff 75 0c             	pushl  0xc(%ebp)
  800aaf:	e8 e6 11 00 00       	call   801c9a <memmove>
	return r;
  800ab4:	83 c4 10             	add    $0x10,%esp
}
  800ab7:	89 d8                	mov    %ebx,%eax
  800ab9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	53                   	push   %ebx
  800ac4:	83 ec 20             	sub    $0x20,%esp
  800ac7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aca:	53                   	push   %ebx
  800acb:	e8 ff 0f 00 00       	call   801acf <strlen>
  800ad0:	83 c4 10             	add    $0x10,%esp
  800ad3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad8:	7f 67                	jg     800b41 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ada:	83 ec 0c             	sub    $0xc,%esp
  800add:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae0:	50                   	push   %eax
  800ae1:	e8 a7 f8 ff ff       	call   80038d <fd_alloc>
  800ae6:	83 c4 10             	add    $0x10,%esp
		return r;
  800ae9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	78 57                	js     800b46 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aef:	83 ec 08             	sub    $0x8,%esp
  800af2:	53                   	push   %ebx
  800af3:	68 00 50 80 00       	push   $0x805000
  800af8:	e8 0b 10 00 00       	call   801b08 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b00:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b08:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0d:	e8 03 fe ff ff       	call   800915 <fsipc>
  800b12:	89 c3                	mov    %eax,%ebx
  800b14:	83 c4 10             	add    $0x10,%esp
  800b17:	85 c0                	test   %eax,%eax
  800b19:	79 14                	jns    800b2f <open+0x6f>
		fd_close(fd, 0);
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	6a 00                	push   $0x0
  800b20:	ff 75 f4             	pushl  -0xc(%ebp)
  800b23:	e8 5d f9 ff ff       	call   800485 <fd_close>
		return r;
  800b28:	83 c4 10             	add    $0x10,%esp
  800b2b:	89 da                	mov    %ebx,%edx
  800b2d:	eb 17                	jmp    800b46 <open+0x86>
	}

	return fd2num(fd);
  800b2f:	83 ec 0c             	sub    $0xc,%esp
  800b32:	ff 75 f4             	pushl  -0xc(%ebp)
  800b35:	e8 2c f8 ff ff       	call   800366 <fd2num>
  800b3a:	89 c2                	mov    %eax,%edx
  800b3c:	83 c4 10             	add    $0x10,%esp
  800b3f:	eb 05                	jmp    800b46 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b41:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b46:	89 d0                	mov    %edx,%eax
  800b48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b53:	ba 00 00 00 00       	mov    $0x0,%edx
  800b58:	b8 08 00 00 00       	mov    $0x8,%eax
  800b5d:	e8 b3 fd ff ff       	call   800915 <fsipc>
}
  800b62:	c9                   	leave  
  800b63:	c3                   	ret    

00800b64 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b6a:	68 1b 23 80 00       	push   $0x80231b
  800b6f:	ff 75 0c             	pushl  0xc(%ebp)
  800b72:	e8 91 0f 00 00       	call   801b08 <strcpy>
	return 0;
}
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	53                   	push   %ebx
  800b82:	83 ec 10             	sub    $0x10,%esp
  800b85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800b88:	53                   	push   %ebx
  800b89:	e8 b5 13 00 00       	call   801f43 <pageref>
  800b8e:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800b91:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800b96:	83 f8 01             	cmp    $0x1,%eax
  800b99:	75 10                	jne    800bab <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	ff 73 0c             	pushl  0xc(%ebx)
  800ba1:	e8 c0 02 00 00       	call   800e66 <nsipc_close>
  800ba6:	89 c2                	mov    %eax,%edx
  800ba8:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bab:	89 d0                	mov    %edx,%eax
  800bad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb0:	c9                   	leave  
  800bb1:	c3                   	ret    

00800bb2 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bb8:	6a 00                	push   $0x0
  800bba:	ff 75 10             	pushl  0x10(%ebp)
  800bbd:	ff 75 0c             	pushl  0xc(%ebp)
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc3:	ff 70 0c             	pushl  0xc(%eax)
  800bc6:	e8 78 03 00 00       	call   800f43 <nsipc_send>
}
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bd3:	6a 00                	push   $0x0
  800bd5:	ff 75 10             	pushl  0x10(%ebp)
  800bd8:	ff 75 0c             	pushl  0xc(%ebp)
  800bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bde:	ff 70 0c             	pushl  0xc(%eax)
  800be1:	e8 f1 02 00 00       	call   800ed7 <nsipc_recv>
}
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800bee:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800bf1:	52                   	push   %edx
  800bf2:	50                   	push   %eax
  800bf3:	e8 e4 f7 ff ff       	call   8003dc <fd_lookup>
  800bf8:	83 c4 10             	add    $0x10,%esp
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	78 17                	js     800c16 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c02:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c08:	39 08                	cmp    %ecx,(%eax)
  800c0a:	75 05                	jne    800c11 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c0c:	8b 40 0c             	mov    0xc(%eax),%eax
  800c0f:	eb 05                	jmp    800c16 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c11:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c16:	c9                   	leave  
  800c17:	c3                   	ret    

00800c18 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	83 ec 1c             	sub    $0x1c,%esp
  800c20:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c25:	50                   	push   %eax
  800c26:	e8 62 f7 ff ff       	call   80038d <fd_alloc>
  800c2b:	89 c3                	mov    %eax,%ebx
  800c2d:	83 c4 10             	add    $0x10,%esp
  800c30:	85 c0                	test   %eax,%eax
  800c32:	78 1b                	js     800c4f <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c34:	83 ec 04             	sub    $0x4,%esp
  800c37:	68 07 04 00 00       	push   $0x407
  800c3c:	ff 75 f4             	pushl  -0xc(%ebp)
  800c3f:	6a 00                	push   $0x0
  800c41:	e8 10 f5 ff ff       	call   800156 <sys_page_alloc>
  800c46:	89 c3                	mov    %eax,%ebx
  800c48:	83 c4 10             	add    $0x10,%esp
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	79 10                	jns    800c5f <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c4f:	83 ec 0c             	sub    $0xc,%esp
  800c52:	56                   	push   %esi
  800c53:	e8 0e 02 00 00       	call   800e66 <nsipc_close>
		return r;
  800c58:	83 c4 10             	add    $0x10,%esp
  800c5b:	89 d8                	mov    %ebx,%eax
  800c5d:	eb 24                	jmp    800c83 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c5f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c68:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c6d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c74:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	50                   	push   %eax
  800c7b:	e8 e6 f6 ff ff       	call   800366 <fd2num>
  800c80:	83 c4 10             	add    $0x10,%esp
}
  800c83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800c90:	8b 45 08             	mov    0x8(%ebp),%eax
  800c93:	e8 50 ff ff ff       	call   800be8 <fd2sockid>
		return r;
  800c98:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	78 1f                	js     800cbd <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800c9e:	83 ec 04             	sub    $0x4,%esp
  800ca1:	ff 75 10             	pushl  0x10(%ebp)
  800ca4:	ff 75 0c             	pushl  0xc(%ebp)
  800ca7:	50                   	push   %eax
  800ca8:	e8 12 01 00 00       	call   800dbf <nsipc_accept>
  800cad:	83 c4 10             	add    $0x10,%esp
		return r;
  800cb0:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	78 07                	js     800cbd <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cb6:	e8 5d ff ff ff       	call   800c18 <alloc_sockfd>
  800cbb:	89 c1                	mov    %eax,%ecx
}
  800cbd:	89 c8                	mov    %ecx,%eax
  800cbf:	c9                   	leave  
  800cc0:	c3                   	ret    

00800cc1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cca:	e8 19 ff ff ff       	call   800be8 <fd2sockid>
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	78 12                	js     800ce5 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800cd3:	83 ec 04             	sub    $0x4,%esp
  800cd6:	ff 75 10             	pushl  0x10(%ebp)
  800cd9:	ff 75 0c             	pushl  0xc(%ebp)
  800cdc:	50                   	push   %eax
  800cdd:	e8 2d 01 00 00       	call   800e0f <nsipc_bind>
  800ce2:	83 c4 10             	add    $0x10,%esp
}
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <shutdown>:

int
shutdown(int s, int how)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	e8 f3 fe ff ff       	call   800be8 <fd2sockid>
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	78 0f                	js     800d08 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800cf9:	83 ec 08             	sub    $0x8,%esp
  800cfc:	ff 75 0c             	pushl  0xc(%ebp)
  800cff:	50                   	push   %eax
  800d00:	e8 3f 01 00 00       	call   800e44 <nsipc_shutdown>
  800d05:	83 c4 10             	add    $0x10,%esp
}
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    

00800d0a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d10:	8b 45 08             	mov    0x8(%ebp),%eax
  800d13:	e8 d0 fe ff ff       	call   800be8 <fd2sockid>
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	78 12                	js     800d2e <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d1c:	83 ec 04             	sub    $0x4,%esp
  800d1f:	ff 75 10             	pushl  0x10(%ebp)
  800d22:	ff 75 0c             	pushl  0xc(%ebp)
  800d25:	50                   	push   %eax
  800d26:	e8 55 01 00 00       	call   800e80 <nsipc_connect>
  800d2b:	83 c4 10             	add    $0x10,%esp
}
  800d2e:	c9                   	leave  
  800d2f:	c3                   	ret    

00800d30 <listen>:

int
listen(int s, int backlog)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
  800d39:	e8 aa fe ff ff       	call   800be8 <fd2sockid>
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	78 0f                	js     800d51 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d42:	83 ec 08             	sub    $0x8,%esp
  800d45:	ff 75 0c             	pushl  0xc(%ebp)
  800d48:	50                   	push   %eax
  800d49:	e8 67 01 00 00       	call   800eb5 <nsipc_listen>
  800d4e:	83 c4 10             	add    $0x10,%esp
}
  800d51:	c9                   	leave  
  800d52:	c3                   	ret    

00800d53 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d59:	ff 75 10             	pushl  0x10(%ebp)
  800d5c:	ff 75 0c             	pushl  0xc(%ebp)
  800d5f:	ff 75 08             	pushl  0x8(%ebp)
  800d62:	e8 3a 02 00 00       	call   800fa1 <nsipc_socket>
  800d67:	83 c4 10             	add    $0x10,%esp
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	78 05                	js     800d73 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d6e:	e8 a5 fe ff ff       	call   800c18 <alloc_sockfd>
}
  800d73:	c9                   	leave  
  800d74:	c3                   	ret    

00800d75 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	53                   	push   %ebx
  800d79:	83 ec 04             	sub    $0x4,%esp
  800d7c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800d7e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800d85:	75 12                	jne    800d99 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	6a 02                	push   $0x2
  800d8c:	e8 79 11 00 00       	call   801f0a <ipc_find_env>
  800d91:	a3 04 40 80 00       	mov    %eax,0x804004
  800d96:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800d99:	6a 07                	push   $0x7
  800d9b:	68 00 60 80 00       	push   $0x806000
  800da0:	53                   	push   %ebx
  800da1:	ff 35 04 40 80 00    	pushl  0x804004
  800da7:	e8 0a 11 00 00       	call   801eb6 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dac:	83 c4 0c             	add    $0xc,%esp
  800daf:	6a 00                	push   $0x0
  800db1:	6a 00                	push   $0x0
  800db3:	6a 00                	push   $0x0
  800db5:	e8 95 10 00 00       	call   801e4f <ipc_recv>
}
  800dba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dbd:	c9                   	leave  
  800dbe:	c3                   	ret    

00800dbf <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dca:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800dcf:	8b 06                	mov    (%esi),%eax
  800dd1:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ddb:	e8 95 ff ff ff       	call   800d75 <nsipc>
  800de0:	89 c3                	mov    %eax,%ebx
  800de2:	85 c0                	test   %eax,%eax
  800de4:	78 20                	js     800e06 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800de6:	83 ec 04             	sub    $0x4,%esp
  800de9:	ff 35 10 60 80 00    	pushl  0x806010
  800def:	68 00 60 80 00       	push   $0x806000
  800df4:	ff 75 0c             	pushl  0xc(%ebp)
  800df7:	e8 9e 0e 00 00       	call   801c9a <memmove>
		*addrlen = ret->ret_addrlen;
  800dfc:	a1 10 60 80 00       	mov    0x806010,%eax
  800e01:	89 06                	mov    %eax,(%esi)
  800e03:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e06:	89 d8                	mov    %ebx,%eax
  800e08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	53                   	push   %ebx
  800e13:	83 ec 08             	sub    $0x8,%esp
  800e16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e19:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e21:	53                   	push   %ebx
  800e22:	ff 75 0c             	pushl  0xc(%ebp)
  800e25:	68 04 60 80 00       	push   $0x806004
  800e2a:	e8 6b 0e 00 00       	call   801c9a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e2f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e35:	b8 02 00 00 00       	mov    $0x2,%eax
  800e3a:	e8 36 ff ff ff       	call   800d75 <nsipc>
}
  800e3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e42:	c9                   	leave  
  800e43:	c3                   	ret    

00800e44 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e55:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e5a:	b8 03 00 00 00       	mov    $0x3,%eax
  800e5f:	e8 11 ff ff ff       	call   800d75 <nsipc>
}
  800e64:	c9                   	leave  
  800e65:	c3                   	ret    

00800e66 <nsipc_close>:

int
nsipc_close(int s)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6f:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800e74:	b8 04 00 00 00       	mov    $0x4,%eax
  800e79:	e8 f7 fe ff ff       	call   800d75 <nsipc>
}
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	53                   	push   %ebx
  800e84:	83 ec 08             	sub    $0x8,%esp
  800e87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800e92:	53                   	push   %ebx
  800e93:	ff 75 0c             	pushl  0xc(%ebp)
  800e96:	68 04 60 80 00       	push   $0x806004
  800e9b:	e8 fa 0d 00 00       	call   801c9a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ea0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ea6:	b8 05 00 00 00       	mov    $0x5,%eax
  800eab:	e8 c5 fe ff ff       	call   800d75 <nsipc>
}
  800eb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebe:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800ecb:	b8 06 00 00 00       	mov    $0x6,%eax
  800ed0:	e8 a0 fe ff ff       	call   800d75 <nsipc>
}
  800ed5:	c9                   	leave  
  800ed6:	c3                   	ret    

00800ed7 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
  800edc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800ee7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800eed:	8b 45 14             	mov    0x14(%ebp),%eax
  800ef0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800ef5:	b8 07 00 00 00       	mov    $0x7,%eax
  800efa:	e8 76 fe ff ff       	call   800d75 <nsipc>
  800eff:	89 c3                	mov    %eax,%ebx
  800f01:	85 c0                	test   %eax,%eax
  800f03:	78 35                	js     800f3a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f05:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f0a:	7f 04                	jg     800f10 <nsipc_recv+0x39>
  800f0c:	39 c6                	cmp    %eax,%esi
  800f0e:	7d 16                	jge    800f26 <nsipc_recv+0x4f>
  800f10:	68 27 23 80 00       	push   $0x802327
  800f15:	68 ef 22 80 00       	push   $0x8022ef
  800f1a:	6a 62                	push   $0x62
  800f1c:	68 3c 23 80 00       	push   $0x80233c
  800f21:	e8 84 05 00 00       	call   8014aa <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f26:	83 ec 04             	sub    $0x4,%esp
  800f29:	50                   	push   %eax
  800f2a:	68 00 60 80 00       	push   $0x806000
  800f2f:	ff 75 0c             	pushl  0xc(%ebp)
  800f32:	e8 63 0d 00 00       	call   801c9a <memmove>
  800f37:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f3a:	89 d8                	mov    %ebx,%eax
  800f3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f3f:	5b                   	pop    %ebx
  800f40:	5e                   	pop    %esi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	53                   	push   %ebx
  800f47:	83 ec 04             	sub    $0x4,%esp
  800f4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f50:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f55:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f5b:	7e 16                	jle    800f73 <nsipc_send+0x30>
  800f5d:	68 48 23 80 00       	push   $0x802348
  800f62:	68 ef 22 80 00       	push   $0x8022ef
  800f67:	6a 6d                	push   $0x6d
  800f69:	68 3c 23 80 00       	push   $0x80233c
  800f6e:	e8 37 05 00 00       	call   8014aa <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f73:	83 ec 04             	sub    $0x4,%esp
  800f76:	53                   	push   %ebx
  800f77:	ff 75 0c             	pushl  0xc(%ebp)
  800f7a:	68 0c 60 80 00       	push   $0x80600c
  800f7f:	e8 16 0d 00 00       	call   801c9a <memmove>
	nsipcbuf.send.req_size = size;
  800f84:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800f8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f8d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800f92:	b8 08 00 00 00       	mov    $0x8,%eax
  800f97:	e8 d9 fd ff ff       	call   800d75 <nsipc>
}
  800f9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800faa:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800faf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb2:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fb7:	8b 45 10             	mov    0x10(%ebp),%eax
  800fba:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800fbf:	b8 09 00 00 00       	mov    $0x9,%eax
  800fc4:	e8 ac fd ff ff       	call   800d75 <nsipc>
}
  800fc9:	c9                   	leave  
  800fca:	c3                   	ret    

00800fcb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800fd3:	83 ec 0c             	sub    $0xc,%esp
  800fd6:	ff 75 08             	pushl  0x8(%ebp)
  800fd9:	e8 98 f3 ff ff       	call   800376 <fd2data>
  800fde:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800fe0:	83 c4 08             	add    $0x8,%esp
  800fe3:	68 54 23 80 00       	push   $0x802354
  800fe8:	53                   	push   %ebx
  800fe9:	e8 1a 0b 00 00       	call   801b08 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800fee:	8b 46 04             	mov    0x4(%esi),%eax
  800ff1:	2b 06                	sub    (%esi),%eax
  800ff3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ff9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801000:	00 00 00 
	stat->st_dev = &devpipe;
  801003:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80100a:	30 80 00 
	return 0;
}
  80100d:	b8 00 00 00 00       	mov    $0x0,%eax
  801012:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	53                   	push   %ebx
  80101d:	83 ec 0c             	sub    $0xc,%esp
  801020:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801023:	53                   	push   %ebx
  801024:	6a 00                	push   $0x0
  801026:	e8 b0 f1 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80102b:	89 1c 24             	mov    %ebx,(%esp)
  80102e:	e8 43 f3 ff ff       	call   800376 <fd2data>
  801033:	83 c4 08             	add    $0x8,%esp
  801036:	50                   	push   %eax
  801037:	6a 00                	push   $0x0
  801039:	e8 9d f1 ff ff       	call   8001db <sys_page_unmap>
}
  80103e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801041:	c9                   	leave  
  801042:	c3                   	ret    

00801043 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	57                   	push   %edi
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
  801049:	83 ec 1c             	sub    $0x1c,%esp
  80104c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80104f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801051:	a1 08 40 80 00       	mov    0x804008,%eax
  801056:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	ff 75 e0             	pushl  -0x20(%ebp)
  80105f:	e8 df 0e 00 00       	call   801f43 <pageref>
  801064:	89 c3                	mov    %eax,%ebx
  801066:	89 3c 24             	mov    %edi,(%esp)
  801069:	e8 d5 0e 00 00       	call   801f43 <pageref>
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	39 c3                	cmp    %eax,%ebx
  801073:	0f 94 c1             	sete   %cl
  801076:	0f b6 c9             	movzbl %cl,%ecx
  801079:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80107c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801082:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801085:	39 ce                	cmp    %ecx,%esi
  801087:	74 1b                	je     8010a4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801089:	39 c3                	cmp    %eax,%ebx
  80108b:	75 c4                	jne    801051 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80108d:	8b 42 58             	mov    0x58(%edx),%eax
  801090:	ff 75 e4             	pushl  -0x1c(%ebp)
  801093:	50                   	push   %eax
  801094:	56                   	push   %esi
  801095:	68 5b 23 80 00       	push   $0x80235b
  80109a:	e8 e4 04 00 00       	call   801583 <cprintf>
  80109f:	83 c4 10             	add    $0x10,%esp
  8010a2:	eb ad                	jmp    801051 <_pipeisclosed+0xe>
	}
}
  8010a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010aa:	5b                   	pop    %ebx
  8010ab:	5e                   	pop    %esi
  8010ac:	5f                   	pop    %edi
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	57                   	push   %edi
  8010b3:	56                   	push   %esi
  8010b4:	53                   	push   %ebx
  8010b5:	83 ec 28             	sub    $0x28,%esp
  8010b8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010bb:	56                   	push   %esi
  8010bc:	e8 b5 f2 ff ff       	call   800376 <fd2data>
  8010c1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010c3:	83 c4 10             	add    $0x10,%esp
  8010c6:	bf 00 00 00 00       	mov    $0x0,%edi
  8010cb:	eb 4b                	jmp    801118 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8010cd:	89 da                	mov    %ebx,%edx
  8010cf:	89 f0                	mov    %esi,%eax
  8010d1:	e8 6d ff ff ff       	call   801043 <_pipeisclosed>
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	75 48                	jne    801122 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8010da:	e8 58 f0 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010df:	8b 43 04             	mov    0x4(%ebx),%eax
  8010e2:	8b 0b                	mov    (%ebx),%ecx
  8010e4:	8d 51 20             	lea    0x20(%ecx),%edx
  8010e7:	39 d0                	cmp    %edx,%eax
  8010e9:	73 e2                	jae    8010cd <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8010eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ee:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8010f2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8010f5:	89 c2                	mov    %eax,%edx
  8010f7:	c1 fa 1f             	sar    $0x1f,%edx
  8010fa:	89 d1                	mov    %edx,%ecx
  8010fc:	c1 e9 1b             	shr    $0x1b,%ecx
  8010ff:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801102:	83 e2 1f             	and    $0x1f,%edx
  801105:	29 ca                	sub    %ecx,%edx
  801107:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80110b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80110f:	83 c0 01             	add    $0x1,%eax
  801112:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801115:	83 c7 01             	add    $0x1,%edi
  801118:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80111b:	75 c2                	jne    8010df <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80111d:	8b 45 10             	mov    0x10(%ebp),%eax
  801120:	eb 05                	jmp    801127 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801122:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112a:	5b                   	pop    %ebx
  80112b:	5e                   	pop    %esi
  80112c:	5f                   	pop    %edi
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    

0080112f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	57                   	push   %edi
  801133:	56                   	push   %esi
  801134:	53                   	push   %ebx
  801135:	83 ec 18             	sub    $0x18,%esp
  801138:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80113b:	57                   	push   %edi
  80113c:	e8 35 f2 ff ff       	call   800376 <fd2data>
  801141:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114b:	eb 3d                	jmp    80118a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80114d:	85 db                	test   %ebx,%ebx
  80114f:	74 04                	je     801155 <devpipe_read+0x26>
				return i;
  801151:	89 d8                	mov    %ebx,%eax
  801153:	eb 44                	jmp    801199 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801155:	89 f2                	mov    %esi,%edx
  801157:	89 f8                	mov    %edi,%eax
  801159:	e8 e5 fe ff ff       	call   801043 <_pipeisclosed>
  80115e:	85 c0                	test   %eax,%eax
  801160:	75 32                	jne    801194 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801162:	e8 d0 ef ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801167:	8b 06                	mov    (%esi),%eax
  801169:	3b 46 04             	cmp    0x4(%esi),%eax
  80116c:	74 df                	je     80114d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80116e:	99                   	cltd   
  80116f:	c1 ea 1b             	shr    $0x1b,%edx
  801172:	01 d0                	add    %edx,%eax
  801174:	83 e0 1f             	and    $0x1f,%eax
  801177:	29 d0                	sub    %edx,%eax
  801179:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80117e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801181:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801184:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801187:	83 c3 01             	add    $0x1,%ebx
  80118a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80118d:	75 d8                	jne    801167 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80118f:	8b 45 10             	mov    0x10(%ebp),%eax
  801192:	eb 05                	jmp    801199 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801194:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119c:	5b                   	pop    %ebx
  80119d:	5e                   	pop    %esi
  80119e:	5f                   	pop    %edi
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	56                   	push   %esi
  8011a5:	53                   	push   %ebx
  8011a6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ac:	50                   	push   %eax
  8011ad:	e8 db f1 ff ff       	call   80038d <fd_alloc>
  8011b2:	83 c4 10             	add    $0x10,%esp
  8011b5:	89 c2                	mov    %eax,%edx
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	0f 88 2c 01 00 00    	js     8012eb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011bf:	83 ec 04             	sub    $0x4,%esp
  8011c2:	68 07 04 00 00       	push   $0x407
  8011c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8011ca:	6a 00                	push   $0x0
  8011cc:	e8 85 ef ff ff       	call   800156 <sys_page_alloc>
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	89 c2                	mov    %eax,%edx
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	0f 88 0d 01 00 00    	js     8012eb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8011de:	83 ec 0c             	sub    $0xc,%esp
  8011e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e4:	50                   	push   %eax
  8011e5:	e8 a3 f1 ff ff       	call   80038d <fd_alloc>
  8011ea:	89 c3                	mov    %eax,%ebx
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	0f 88 e2 00 00 00    	js     8012d9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	68 07 04 00 00       	push   $0x407
  8011ff:	ff 75 f0             	pushl  -0x10(%ebp)
  801202:	6a 00                	push   $0x0
  801204:	e8 4d ef ff ff       	call   800156 <sys_page_alloc>
  801209:	89 c3                	mov    %eax,%ebx
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	85 c0                	test   %eax,%eax
  801210:	0f 88 c3 00 00 00    	js     8012d9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801216:	83 ec 0c             	sub    $0xc,%esp
  801219:	ff 75 f4             	pushl  -0xc(%ebp)
  80121c:	e8 55 f1 ff ff       	call   800376 <fd2data>
  801221:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801223:	83 c4 0c             	add    $0xc,%esp
  801226:	68 07 04 00 00       	push   $0x407
  80122b:	50                   	push   %eax
  80122c:	6a 00                	push   $0x0
  80122e:	e8 23 ef ff ff       	call   800156 <sys_page_alloc>
  801233:	89 c3                	mov    %eax,%ebx
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	0f 88 89 00 00 00    	js     8012c9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801240:	83 ec 0c             	sub    $0xc,%esp
  801243:	ff 75 f0             	pushl  -0x10(%ebp)
  801246:	e8 2b f1 ff ff       	call   800376 <fd2data>
  80124b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801252:	50                   	push   %eax
  801253:	6a 00                	push   $0x0
  801255:	56                   	push   %esi
  801256:	6a 00                	push   $0x0
  801258:	e8 3c ef ff ff       	call   800199 <sys_page_map>
  80125d:	89 c3                	mov    %eax,%ebx
  80125f:	83 c4 20             	add    $0x20,%esp
  801262:	85 c0                	test   %eax,%eax
  801264:	78 55                	js     8012bb <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801266:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80126c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80126f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801271:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801274:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80127b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801281:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801284:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801289:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801290:	83 ec 0c             	sub    $0xc,%esp
  801293:	ff 75 f4             	pushl  -0xc(%ebp)
  801296:	e8 cb f0 ff ff       	call   800366 <fd2num>
  80129b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012a0:	83 c4 04             	add    $0x4,%esp
  8012a3:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a6:	e8 bb f0 ff ff       	call   800366 <fd2num>
  8012ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ae:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b9:	eb 30                	jmp    8012eb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012bb:	83 ec 08             	sub    $0x8,%esp
  8012be:	56                   	push   %esi
  8012bf:	6a 00                	push   $0x0
  8012c1:	e8 15 ef ff ff       	call   8001db <sys_page_unmap>
  8012c6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8012c9:	83 ec 08             	sub    $0x8,%esp
  8012cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8012cf:	6a 00                	push   $0x0
  8012d1:	e8 05 ef ff ff       	call   8001db <sys_page_unmap>
  8012d6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8012df:	6a 00                	push   $0x0
  8012e1:	e8 f5 ee ff ff       	call   8001db <sys_page_unmap>
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8012eb:	89 d0                	mov    %edx,%eax
  8012ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f0:	5b                   	pop    %ebx
  8012f1:	5e                   	pop    %esi
  8012f2:	5d                   	pop    %ebp
  8012f3:	c3                   	ret    

008012f4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fd:	50                   	push   %eax
  8012fe:	ff 75 08             	pushl  0x8(%ebp)
  801301:	e8 d6 f0 ff ff       	call   8003dc <fd_lookup>
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	85 c0                	test   %eax,%eax
  80130b:	78 18                	js     801325 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80130d:	83 ec 0c             	sub    $0xc,%esp
  801310:	ff 75 f4             	pushl  -0xc(%ebp)
  801313:	e8 5e f0 ff ff       	call   800376 <fd2data>
	return _pipeisclosed(fd, p);
  801318:	89 c2                	mov    %eax,%edx
  80131a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131d:	e8 21 fd ff ff       	call   801043 <_pipeisclosed>
  801322:	83 c4 10             	add    $0x10,%esp
}
  801325:	c9                   	leave  
  801326:	c3                   	ret    

00801327 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80132a:	b8 00 00 00 00       	mov    $0x0,%eax
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    

00801331 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801337:	68 73 23 80 00       	push   $0x802373
  80133c:	ff 75 0c             	pushl  0xc(%ebp)
  80133f:	e8 c4 07 00 00       	call   801b08 <strcpy>
	return 0;
}
  801344:	b8 00 00 00 00       	mov    $0x0,%eax
  801349:	c9                   	leave  
  80134a:	c3                   	ret    

0080134b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	57                   	push   %edi
  80134f:	56                   	push   %esi
  801350:	53                   	push   %ebx
  801351:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801357:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80135c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801362:	eb 2d                	jmp    801391 <devcons_write+0x46>
		m = n - tot;
  801364:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801367:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801369:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80136c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801371:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801374:	83 ec 04             	sub    $0x4,%esp
  801377:	53                   	push   %ebx
  801378:	03 45 0c             	add    0xc(%ebp),%eax
  80137b:	50                   	push   %eax
  80137c:	57                   	push   %edi
  80137d:	e8 18 09 00 00       	call   801c9a <memmove>
		sys_cputs(buf, m);
  801382:	83 c4 08             	add    $0x8,%esp
  801385:	53                   	push   %ebx
  801386:	57                   	push   %edi
  801387:	e8 0e ed ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80138c:	01 de                	add    %ebx,%esi
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	89 f0                	mov    %esi,%eax
  801393:	3b 75 10             	cmp    0x10(%ebp),%esi
  801396:	72 cc                	jb     801364 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80139b:	5b                   	pop    %ebx
  80139c:	5e                   	pop    %esi
  80139d:	5f                   	pop    %edi
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    

008013a0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013af:	74 2a                	je     8013db <devcons_read+0x3b>
  8013b1:	eb 05                	jmp    8013b8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013b3:	e8 7f ed ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013b8:	e8 fb ec ff ff       	call   8000b8 <sys_cgetc>
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	74 f2                	je     8013b3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 16                	js     8013db <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013c5:	83 f8 04             	cmp    $0x4,%eax
  8013c8:	74 0c                	je     8013d6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013cd:	88 02                	mov    %al,(%edx)
	return 1;
  8013cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8013d4:	eb 05                	jmp    8013db <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013d6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013db:	c9                   	leave  
  8013dc:	c3                   	ret    

008013dd <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8013e9:	6a 01                	push   $0x1
  8013eb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013ee:	50                   	push   %eax
  8013ef:	e8 a6 ec ff ff       	call   80009a <sys_cputs>
}
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	c9                   	leave  
  8013f8:	c3                   	ret    

008013f9 <getchar>:

int
getchar(void)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8013ff:	6a 01                	push   $0x1
  801401:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801404:	50                   	push   %eax
  801405:	6a 00                	push   $0x0
  801407:	e8 36 f2 ff ff       	call   800642 <read>
	if (r < 0)
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	85 c0                	test   %eax,%eax
  801411:	78 0f                	js     801422 <getchar+0x29>
		return r;
	if (r < 1)
  801413:	85 c0                	test   %eax,%eax
  801415:	7e 06                	jle    80141d <getchar+0x24>
		return -E_EOF;
	return c;
  801417:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80141b:	eb 05                	jmp    801422 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80141d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801422:	c9                   	leave  
  801423:	c3                   	ret    

00801424 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80142a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142d:	50                   	push   %eax
  80142e:	ff 75 08             	pushl  0x8(%ebp)
  801431:	e8 a6 ef ff ff       	call   8003dc <fd_lookup>
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	85 c0                	test   %eax,%eax
  80143b:	78 11                	js     80144e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80143d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801440:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801446:	39 10                	cmp    %edx,(%eax)
  801448:	0f 94 c0             	sete   %al
  80144b:	0f b6 c0             	movzbl %al,%eax
}
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <opencons>:

int
opencons(void)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801456:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801459:	50                   	push   %eax
  80145a:	e8 2e ef ff ff       	call   80038d <fd_alloc>
  80145f:	83 c4 10             	add    $0x10,%esp
		return r;
  801462:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801464:	85 c0                	test   %eax,%eax
  801466:	78 3e                	js     8014a6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801468:	83 ec 04             	sub    $0x4,%esp
  80146b:	68 07 04 00 00       	push   $0x407
  801470:	ff 75 f4             	pushl  -0xc(%ebp)
  801473:	6a 00                	push   $0x0
  801475:	e8 dc ec ff ff       	call   800156 <sys_page_alloc>
  80147a:	83 c4 10             	add    $0x10,%esp
		return r;
  80147d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 23                	js     8014a6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801483:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801489:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80148e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801491:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801498:	83 ec 0c             	sub    $0xc,%esp
  80149b:	50                   	push   %eax
  80149c:	e8 c5 ee ff ff       	call   800366 <fd2num>
  8014a1:	89 c2                	mov    %eax,%edx
  8014a3:	83 c4 10             	add    $0x10,%esp
}
  8014a6:	89 d0                	mov    %edx,%eax
  8014a8:	c9                   	leave  
  8014a9:	c3                   	ret    

008014aa <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	56                   	push   %esi
  8014ae:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014af:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014b2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014b8:	e8 5b ec ff ff       	call   800118 <sys_getenvid>
  8014bd:	83 ec 0c             	sub    $0xc,%esp
  8014c0:	ff 75 0c             	pushl  0xc(%ebp)
  8014c3:	ff 75 08             	pushl  0x8(%ebp)
  8014c6:	56                   	push   %esi
  8014c7:	50                   	push   %eax
  8014c8:	68 80 23 80 00       	push   $0x802380
  8014cd:	e8 b1 00 00 00       	call   801583 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014d2:	83 c4 18             	add    $0x18,%esp
  8014d5:	53                   	push   %ebx
  8014d6:	ff 75 10             	pushl  0x10(%ebp)
  8014d9:	e8 54 00 00 00       	call   801532 <vcprintf>
	cprintf("\n");
  8014de:	c7 04 24 6c 23 80 00 	movl   $0x80236c,(%esp)
  8014e5:	e8 99 00 00 00       	call   801583 <cprintf>
  8014ea:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014ed:	cc                   	int3   
  8014ee:	eb fd                	jmp    8014ed <_panic+0x43>

008014f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	53                   	push   %ebx
  8014f4:	83 ec 04             	sub    $0x4,%esp
  8014f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8014fa:	8b 13                	mov    (%ebx),%edx
  8014fc:	8d 42 01             	lea    0x1(%edx),%eax
  8014ff:	89 03                	mov    %eax,(%ebx)
  801501:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801504:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801508:	3d ff 00 00 00       	cmp    $0xff,%eax
  80150d:	75 1a                	jne    801529 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80150f:	83 ec 08             	sub    $0x8,%esp
  801512:	68 ff 00 00 00       	push   $0xff
  801517:	8d 43 08             	lea    0x8(%ebx),%eax
  80151a:	50                   	push   %eax
  80151b:	e8 7a eb ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  801520:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801526:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801529:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80152d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801530:	c9                   	leave  
  801531:	c3                   	ret    

00801532 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80153b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801542:	00 00 00 
	b.cnt = 0;
  801545:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80154c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80154f:	ff 75 0c             	pushl  0xc(%ebp)
  801552:	ff 75 08             	pushl  0x8(%ebp)
  801555:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80155b:	50                   	push   %eax
  80155c:	68 f0 14 80 00       	push   $0x8014f0
  801561:	e8 54 01 00 00       	call   8016ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801566:	83 c4 08             	add    $0x8,%esp
  801569:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80156f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801575:	50                   	push   %eax
  801576:	e8 1f eb ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  80157b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801589:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80158c:	50                   	push   %eax
  80158d:	ff 75 08             	pushl  0x8(%ebp)
  801590:	e8 9d ff ff ff       	call   801532 <vcprintf>
	va_end(ap);

	return cnt;
}
  801595:	c9                   	leave  
  801596:	c3                   	ret    

00801597 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	57                   	push   %edi
  80159b:	56                   	push   %esi
  80159c:	53                   	push   %ebx
  80159d:	83 ec 1c             	sub    $0x1c,%esp
  8015a0:	89 c7                	mov    %eax,%edi
  8015a2:	89 d6                	mov    %edx,%esi
  8015a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ad:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015b8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015bb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015be:	39 d3                	cmp    %edx,%ebx
  8015c0:	72 05                	jb     8015c7 <printnum+0x30>
  8015c2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015c5:	77 45                	ja     80160c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015c7:	83 ec 0c             	sub    $0xc,%esp
  8015ca:	ff 75 18             	pushl  0x18(%ebp)
  8015cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015d3:	53                   	push   %ebx
  8015d4:	ff 75 10             	pushl  0x10(%ebp)
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e0:	ff 75 dc             	pushl  -0x24(%ebp)
  8015e3:	ff 75 d8             	pushl  -0x28(%ebp)
  8015e6:	e8 95 09 00 00       	call   801f80 <__udivdi3>
  8015eb:	83 c4 18             	add    $0x18,%esp
  8015ee:	52                   	push   %edx
  8015ef:	50                   	push   %eax
  8015f0:	89 f2                	mov    %esi,%edx
  8015f2:	89 f8                	mov    %edi,%eax
  8015f4:	e8 9e ff ff ff       	call   801597 <printnum>
  8015f9:	83 c4 20             	add    $0x20,%esp
  8015fc:	eb 18                	jmp    801616 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8015fe:	83 ec 08             	sub    $0x8,%esp
  801601:	56                   	push   %esi
  801602:	ff 75 18             	pushl  0x18(%ebp)
  801605:	ff d7                	call   *%edi
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb 03                	jmp    80160f <printnum+0x78>
  80160c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80160f:	83 eb 01             	sub    $0x1,%ebx
  801612:	85 db                	test   %ebx,%ebx
  801614:	7f e8                	jg     8015fe <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	56                   	push   %esi
  80161a:	83 ec 04             	sub    $0x4,%esp
  80161d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801620:	ff 75 e0             	pushl  -0x20(%ebp)
  801623:	ff 75 dc             	pushl  -0x24(%ebp)
  801626:	ff 75 d8             	pushl  -0x28(%ebp)
  801629:	e8 82 0a 00 00       	call   8020b0 <__umoddi3>
  80162e:	83 c4 14             	add    $0x14,%esp
  801631:	0f be 80 a3 23 80 00 	movsbl 0x8023a3(%eax),%eax
  801638:	50                   	push   %eax
  801639:	ff d7                	call   *%edi
}
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5f                   	pop    %edi
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801649:	83 fa 01             	cmp    $0x1,%edx
  80164c:	7e 0e                	jle    80165c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80164e:	8b 10                	mov    (%eax),%edx
  801650:	8d 4a 08             	lea    0x8(%edx),%ecx
  801653:	89 08                	mov    %ecx,(%eax)
  801655:	8b 02                	mov    (%edx),%eax
  801657:	8b 52 04             	mov    0x4(%edx),%edx
  80165a:	eb 22                	jmp    80167e <getuint+0x38>
	else if (lflag)
  80165c:	85 d2                	test   %edx,%edx
  80165e:	74 10                	je     801670 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801660:	8b 10                	mov    (%eax),%edx
  801662:	8d 4a 04             	lea    0x4(%edx),%ecx
  801665:	89 08                	mov    %ecx,(%eax)
  801667:	8b 02                	mov    (%edx),%eax
  801669:	ba 00 00 00 00       	mov    $0x0,%edx
  80166e:	eb 0e                	jmp    80167e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801670:	8b 10                	mov    (%eax),%edx
  801672:	8d 4a 04             	lea    0x4(%edx),%ecx
  801675:	89 08                	mov    %ecx,(%eax)
  801677:	8b 02                	mov    (%edx),%eax
  801679:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801686:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80168a:	8b 10                	mov    (%eax),%edx
  80168c:	3b 50 04             	cmp    0x4(%eax),%edx
  80168f:	73 0a                	jae    80169b <sprintputch+0x1b>
		*b->buf++ = ch;
  801691:	8d 4a 01             	lea    0x1(%edx),%ecx
  801694:	89 08                	mov    %ecx,(%eax)
  801696:	8b 45 08             	mov    0x8(%ebp),%eax
  801699:	88 02                	mov    %al,(%edx)
}
  80169b:	5d                   	pop    %ebp
  80169c:	c3                   	ret    

0080169d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016a3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016a6:	50                   	push   %eax
  8016a7:	ff 75 10             	pushl  0x10(%ebp)
  8016aa:	ff 75 0c             	pushl  0xc(%ebp)
  8016ad:	ff 75 08             	pushl  0x8(%ebp)
  8016b0:	e8 05 00 00 00       	call   8016ba <vprintfmt>
	va_end(ap);
}
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	c9                   	leave  
  8016b9:	c3                   	ret    

008016ba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	57                   	push   %edi
  8016be:	56                   	push   %esi
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 2c             	sub    $0x2c,%esp
  8016c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8016c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016c9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016cc:	eb 12                	jmp    8016e0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	0f 84 89 03 00 00    	je     801a5f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	53                   	push   %ebx
  8016da:	50                   	push   %eax
  8016db:	ff d6                	call   *%esi
  8016dd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016e0:	83 c7 01             	add    $0x1,%edi
  8016e3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016e7:	83 f8 25             	cmp    $0x25,%eax
  8016ea:	75 e2                	jne    8016ce <vprintfmt+0x14>
  8016ec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801705:	ba 00 00 00 00       	mov    $0x0,%edx
  80170a:	eb 07                	jmp    801713 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80170c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80170f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801713:	8d 47 01             	lea    0x1(%edi),%eax
  801716:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801719:	0f b6 07             	movzbl (%edi),%eax
  80171c:	0f b6 c8             	movzbl %al,%ecx
  80171f:	83 e8 23             	sub    $0x23,%eax
  801722:	3c 55                	cmp    $0x55,%al
  801724:	0f 87 1a 03 00 00    	ja     801a44 <vprintfmt+0x38a>
  80172a:	0f b6 c0             	movzbl %al,%eax
  80172d:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  801734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801737:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80173b:	eb d6                	jmp    801713 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80173d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801740:	b8 00 00 00 00       	mov    $0x0,%eax
  801745:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801748:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80174b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80174f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801752:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801755:	83 fa 09             	cmp    $0x9,%edx
  801758:	77 39                	ja     801793 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80175a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80175d:	eb e9                	jmp    801748 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80175f:	8b 45 14             	mov    0x14(%ebp),%eax
  801762:	8d 48 04             	lea    0x4(%eax),%ecx
  801765:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801768:	8b 00                	mov    (%eax),%eax
  80176a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80176d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801770:	eb 27                	jmp    801799 <vprintfmt+0xdf>
  801772:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801775:	85 c0                	test   %eax,%eax
  801777:	b9 00 00 00 00       	mov    $0x0,%ecx
  80177c:	0f 49 c8             	cmovns %eax,%ecx
  80177f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801782:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801785:	eb 8c                	jmp    801713 <vprintfmt+0x59>
  801787:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80178a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801791:	eb 80                	jmp    801713 <vprintfmt+0x59>
  801793:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801796:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801799:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80179d:	0f 89 70 ff ff ff    	jns    801713 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017a3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017a9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017b0:	e9 5e ff ff ff       	jmp    801713 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017b5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017bb:	e9 53 ff ff ff       	jmp    801713 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c3:	8d 50 04             	lea    0x4(%eax),%edx
  8017c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8017c9:	83 ec 08             	sub    $0x8,%esp
  8017cc:	53                   	push   %ebx
  8017cd:	ff 30                	pushl  (%eax)
  8017cf:	ff d6                	call   *%esi
			break;
  8017d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017d7:	e9 04 ff ff ff       	jmp    8016e0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8017df:	8d 50 04             	lea    0x4(%eax),%edx
  8017e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8017e5:	8b 00                	mov    (%eax),%eax
  8017e7:	99                   	cltd   
  8017e8:	31 d0                	xor    %edx,%eax
  8017ea:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017ec:	83 f8 0f             	cmp    $0xf,%eax
  8017ef:	7f 0b                	jg     8017fc <vprintfmt+0x142>
  8017f1:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8017f8:	85 d2                	test   %edx,%edx
  8017fa:	75 18                	jne    801814 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8017fc:	50                   	push   %eax
  8017fd:	68 bb 23 80 00       	push   $0x8023bb
  801802:	53                   	push   %ebx
  801803:	56                   	push   %esi
  801804:	e8 94 fe ff ff       	call   80169d <printfmt>
  801809:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80180f:	e9 cc fe ff ff       	jmp    8016e0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801814:	52                   	push   %edx
  801815:	68 01 23 80 00       	push   $0x802301
  80181a:	53                   	push   %ebx
  80181b:	56                   	push   %esi
  80181c:	e8 7c fe ff ff       	call   80169d <printfmt>
  801821:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801824:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801827:	e9 b4 fe ff ff       	jmp    8016e0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80182c:	8b 45 14             	mov    0x14(%ebp),%eax
  80182f:	8d 50 04             	lea    0x4(%eax),%edx
  801832:	89 55 14             	mov    %edx,0x14(%ebp)
  801835:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801837:	85 ff                	test   %edi,%edi
  801839:	b8 b4 23 80 00       	mov    $0x8023b4,%eax
  80183e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801841:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801845:	0f 8e 94 00 00 00    	jle    8018df <vprintfmt+0x225>
  80184b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80184f:	0f 84 98 00 00 00    	je     8018ed <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	ff 75 d0             	pushl  -0x30(%ebp)
  80185b:	57                   	push   %edi
  80185c:	e8 86 02 00 00       	call   801ae7 <strnlen>
  801861:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801864:	29 c1                	sub    %eax,%ecx
  801866:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801869:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80186c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801870:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801873:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801876:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801878:	eb 0f                	jmp    801889 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80187a:	83 ec 08             	sub    $0x8,%esp
  80187d:	53                   	push   %ebx
  80187e:	ff 75 e0             	pushl  -0x20(%ebp)
  801881:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801883:	83 ef 01             	sub    $0x1,%edi
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	85 ff                	test   %edi,%edi
  80188b:	7f ed                	jg     80187a <vprintfmt+0x1c0>
  80188d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801890:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801893:	85 c9                	test   %ecx,%ecx
  801895:	b8 00 00 00 00       	mov    $0x0,%eax
  80189a:	0f 49 c1             	cmovns %ecx,%eax
  80189d:	29 c1                	sub    %eax,%ecx
  80189f:	89 75 08             	mov    %esi,0x8(%ebp)
  8018a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018a8:	89 cb                	mov    %ecx,%ebx
  8018aa:	eb 4d                	jmp    8018f9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018b0:	74 1b                	je     8018cd <vprintfmt+0x213>
  8018b2:	0f be c0             	movsbl %al,%eax
  8018b5:	83 e8 20             	sub    $0x20,%eax
  8018b8:	83 f8 5e             	cmp    $0x5e,%eax
  8018bb:	76 10                	jbe    8018cd <vprintfmt+0x213>
					putch('?', putdat);
  8018bd:	83 ec 08             	sub    $0x8,%esp
  8018c0:	ff 75 0c             	pushl  0xc(%ebp)
  8018c3:	6a 3f                	push   $0x3f
  8018c5:	ff 55 08             	call   *0x8(%ebp)
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	eb 0d                	jmp    8018da <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018cd:	83 ec 08             	sub    $0x8,%esp
  8018d0:	ff 75 0c             	pushl  0xc(%ebp)
  8018d3:	52                   	push   %edx
  8018d4:	ff 55 08             	call   *0x8(%ebp)
  8018d7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018da:	83 eb 01             	sub    $0x1,%ebx
  8018dd:	eb 1a                	jmp    8018f9 <vprintfmt+0x23f>
  8018df:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018eb:	eb 0c                	jmp    8018f9 <vprintfmt+0x23f>
  8018ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8018f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018f9:	83 c7 01             	add    $0x1,%edi
  8018fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801900:	0f be d0             	movsbl %al,%edx
  801903:	85 d2                	test   %edx,%edx
  801905:	74 23                	je     80192a <vprintfmt+0x270>
  801907:	85 f6                	test   %esi,%esi
  801909:	78 a1                	js     8018ac <vprintfmt+0x1f2>
  80190b:	83 ee 01             	sub    $0x1,%esi
  80190e:	79 9c                	jns    8018ac <vprintfmt+0x1f2>
  801910:	89 df                	mov    %ebx,%edi
  801912:	8b 75 08             	mov    0x8(%ebp),%esi
  801915:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801918:	eb 18                	jmp    801932 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80191a:	83 ec 08             	sub    $0x8,%esp
  80191d:	53                   	push   %ebx
  80191e:	6a 20                	push   $0x20
  801920:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801922:	83 ef 01             	sub    $0x1,%edi
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	eb 08                	jmp    801932 <vprintfmt+0x278>
  80192a:	89 df                	mov    %ebx,%edi
  80192c:	8b 75 08             	mov    0x8(%ebp),%esi
  80192f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801932:	85 ff                	test   %edi,%edi
  801934:	7f e4                	jg     80191a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801936:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801939:	e9 a2 fd ff ff       	jmp    8016e0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80193e:	83 fa 01             	cmp    $0x1,%edx
  801941:	7e 16                	jle    801959 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801943:	8b 45 14             	mov    0x14(%ebp),%eax
  801946:	8d 50 08             	lea    0x8(%eax),%edx
  801949:	89 55 14             	mov    %edx,0x14(%ebp)
  80194c:	8b 50 04             	mov    0x4(%eax),%edx
  80194f:	8b 00                	mov    (%eax),%eax
  801951:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801954:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801957:	eb 32                	jmp    80198b <vprintfmt+0x2d1>
	else if (lflag)
  801959:	85 d2                	test   %edx,%edx
  80195b:	74 18                	je     801975 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80195d:	8b 45 14             	mov    0x14(%ebp),%eax
  801960:	8d 50 04             	lea    0x4(%eax),%edx
  801963:	89 55 14             	mov    %edx,0x14(%ebp)
  801966:	8b 00                	mov    (%eax),%eax
  801968:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80196b:	89 c1                	mov    %eax,%ecx
  80196d:	c1 f9 1f             	sar    $0x1f,%ecx
  801970:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801973:	eb 16                	jmp    80198b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801975:	8b 45 14             	mov    0x14(%ebp),%eax
  801978:	8d 50 04             	lea    0x4(%eax),%edx
  80197b:	89 55 14             	mov    %edx,0x14(%ebp)
  80197e:	8b 00                	mov    (%eax),%eax
  801980:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801983:	89 c1                	mov    %eax,%ecx
  801985:	c1 f9 1f             	sar    $0x1f,%ecx
  801988:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80198b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80198e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801991:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801996:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80199a:	79 74                	jns    801a10 <vprintfmt+0x356>
				putch('-', putdat);
  80199c:	83 ec 08             	sub    $0x8,%esp
  80199f:	53                   	push   %ebx
  8019a0:	6a 2d                	push   $0x2d
  8019a2:	ff d6                	call   *%esi
				num = -(long long) num;
  8019a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019aa:	f7 d8                	neg    %eax
  8019ac:	83 d2 00             	adc    $0x0,%edx
  8019af:	f7 da                	neg    %edx
  8019b1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019b4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019b9:	eb 55                	jmp    801a10 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8019be:	e8 83 fc ff ff       	call   801646 <getuint>
			base = 10;
  8019c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019c8:	eb 46                	jmp    801a10 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8019ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8019cd:	e8 74 fc ff ff       	call   801646 <getuint>
			base = 8;
  8019d2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8019d7:	eb 37                	jmp    801a10 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8019d9:	83 ec 08             	sub    $0x8,%esp
  8019dc:	53                   	push   %ebx
  8019dd:	6a 30                	push   $0x30
  8019df:	ff d6                	call   *%esi
			putch('x', putdat);
  8019e1:	83 c4 08             	add    $0x8,%esp
  8019e4:	53                   	push   %ebx
  8019e5:	6a 78                	push   $0x78
  8019e7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ec:	8d 50 04             	lea    0x4(%eax),%edx
  8019ef:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019f2:	8b 00                	mov    (%eax),%eax
  8019f4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8019f9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8019fc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a01:	eb 0d                	jmp    801a10 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a03:	8d 45 14             	lea    0x14(%ebp),%eax
  801a06:	e8 3b fc ff ff       	call   801646 <getuint>
			base = 16;
  801a0b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a10:	83 ec 0c             	sub    $0xc,%esp
  801a13:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a17:	57                   	push   %edi
  801a18:	ff 75 e0             	pushl  -0x20(%ebp)
  801a1b:	51                   	push   %ecx
  801a1c:	52                   	push   %edx
  801a1d:	50                   	push   %eax
  801a1e:	89 da                	mov    %ebx,%edx
  801a20:	89 f0                	mov    %esi,%eax
  801a22:	e8 70 fb ff ff       	call   801597 <printnum>
			break;
  801a27:	83 c4 20             	add    $0x20,%esp
  801a2a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a2d:	e9 ae fc ff ff       	jmp    8016e0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a32:	83 ec 08             	sub    $0x8,%esp
  801a35:	53                   	push   %ebx
  801a36:	51                   	push   %ecx
  801a37:	ff d6                	call   *%esi
			break;
  801a39:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a3c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a3f:	e9 9c fc ff ff       	jmp    8016e0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a44:	83 ec 08             	sub    $0x8,%esp
  801a47:	53                   	push   %ebx
  801a48:	6a 25                	push   $0x25
  801a4a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	eb 03                	jmp    801a54 <vprintfmt+0x39a>
  801a51:	83 ef 01             	sub    $0x1,%edi
  801a54:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a58:	75 f7                	jne    801a51 <vprintfmt+0x397>
  801a5a:	e9 81 fc ff ff       	jmp    8016e0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a62:	5b                   	pop    %ebx
  801a63:	5e                   	pop    %esi
  801a64:	5f                   	pop    %edi
  801a65:	5d                   	pop    %ebp
  801a66:	c3                   	ret    

00801a67 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	83 ec 18             	sub    $0x18,%esp
  801a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a70:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a73:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a76:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a7a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a84:	85 c0                	test   %eax,%eax
  801a86:	74 26                	je     801aae <vsnprintf+0x47>
  801a88:	85 d2                	test   %edx,%edx
  801a8a:	7e 22                	jle    801aae <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a8c:	ff 75 14             	pushl  0x14(%ebp)
  801a8f:	ff 75 10             	pushl  0x10(%ebp)
  801a92:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a95:	50                   	push   %eax
  801a96:	68 80 16 80 00       	push   $0x801680
  801a9b:	e8 1a fc ff ff       	call   8016ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801aa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801aa3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	eb 05                	jmp    801ab3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801aae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801abb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801abe:	50                   	push   %eax
  801abf:	ff 75 10             	pushl  0x10(%ebp)
  801ac2:	ff 75 0c             	pushl  0xc(%ebp)
  801ac5:	ff 75 08             	pushl  0x8(%ebp)
  801ac8:	e8 9a ff ff ff       	call   801a67 <vsnprintf>
	va_end(ap);

	return rc;
}
  801acd:	c9                   	leave  
  801ace:	c3                   	ret    

00801acf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  801ada:	eb 03                	jmp    801adf <strlen+0x10>
		n++;
  801adc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801adf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801ae3:	75 f7                	jne    801adc <strlen+0xd>
		n++;
	return n;
}
  801ae5:	5d                   	pop    %ebp
  801ae6:	c3                   	ret    

00801ae7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aed:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801af0:	ba 00 00 00 00       	mov    $0x0,%edx
  801af5:	eb 03                	jmp    801afa <strnlen+0x13>
		n++;
  801af7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801afa:	39 c2                	cmp    %eax,%edx
  801afc:	74 08                	je     801b06 <strnlen+0x1f>
  801afe:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b02:	75 f3                	jne    801af7 <strnlen+0x10>
  801b04:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b06:	5d                   	pop    %ebp
  801b07:	c3                   	ret    

00801b08 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	53                   	push   %ebx
  801b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b12:	89 c2                	mov    %eax,%edx
  801b14:	83 c2 01             	add    $0x1,%edx
  801b17:	83 c1 01             	add    $0x1,%ecx
  801b1a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b1e:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b21:	84 db                	test   %bl,%bl
  801b23:	75 ef                	jne    801b14 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b25:	5b                   	pop    %ebx
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    

00801b28 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	53                   	push   %ebx
  801b2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b2f:	53                   	push   %ebx
  801b30:	e8 9a ff ff ff       	call   801acf <strlen>
  801b35:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b38:	ff 75 0c             	pushl  0xc(%ebp)
  801b3b:	01 d8                	add    %ebx,%eax
  801b3d:	50                   	push   %eax
  801b3e:	e8 c5 ff ff ff       	call   801b08 <strcpy>
	return dst;
}
  801b43:	89 d8                	mov    %ebx,%eax
  801b45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b48:	c9                   	leave  
  801b49:	c3                   	ret    

00801b4a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	56                   	push   %esi
  801b4e:	53                   	push   %ebx
  801b4f:	8b 75 08             	mov    0x8(%ebp),%esi
  801b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b55:	89 f3                	mov    %esi,%ebx
  801b57:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b5a:	89 f2                	mov    %esi,%edx
  801b5c:	eb 0f                	jmp    801b6d <strncpy+0x23>
		*dst++ = *src;
  801b5e:	83 c2 01             	add    $0x1,%edx
  801b61:	0f b6 01             	movzbl (%ecx),%eax
  801b64:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b67:	80 39 01             	cmpb   $0x1,(%ecx)
  801b6a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b6d:	39 da                	cmp    %ebx,%edx
  801b6f:	75 ed                	jne    801b5e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b71:	89 f0                	mov    %esi,%eax
  801b73:	5b                   	pop    %ebx
  801b74:	5e                   	pop    %esi
  801b75:	5d                   	pop    %ebp
  801b76:	c3                   	ret    

00801b77 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	56                   	push   %esi
  801b7b:	53                   	push   %ebx
  801b7c:	8b 75 08             	mov    0x8(%ebp),%esi
  801b7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b82:	8b 55 10             	mov    0x10(%ebp),%edx
  801b85:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b87:	85 d2                	test   %edx,%edx
  801b89:	74 21                	je     801bac <strlcpy+0x35>
  801b8b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801b8f:	89 f2                	mov    %esi,%edx
  801b91:	eb 09                	jmp    801b9c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801b93:	83 c2 01             	add    $0x1,%edx
  801b96:	83 c1 01             	add    $0x1,%ecx
  801b99:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801b9c:	39 c2                	cmp    %eax,%edx
  801b9e:	74 09                	je     801ba9 <strlcpy+0x32>
  801ba0:	0f b6 19             	movzbl (%ecx),%ebx
  801ba3:	84 db                	test   %bl,%bl
  801ba5:	75 ec                	jne    801b93 <strlcpy+0x1c>
  801ba7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801ba9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bac:	29 f0                	sub    %esi,%eax
}
  801bae:	5b                   	pop    %ebx
  801baf:	5e                   	pop    %esi
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    

00801bb2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bbb:	eb 06                	jmp    801bc3 <strcmp+0x11>
		p++, q++;
  801bbd:	83 c1 01             	add    $0x1,%ecx
  801bc0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bc3:	0f b6 01             	movzbl (%ecx),%eax
  801bc6:	84 c0                	test   %al,%al
  801bc8:	74 04                	je     801bce <strcmp+0x1c>
  801bca:	3a 02                	cmp    (%edx),%al
  801bcc:	74 ef                	je     801bbd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801bce:	0f b6 c0             	movzbl %al,%eax
  801bd1:	0f b6 12             	movzbl (%edx),%edx
  801bd4:	29 d0                	sub    %edx,%eax
}
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	53                   	push   %ebx
  801bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801be2:	89 c3                	mov    %eax,%ebx
  801be4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801be7:	eb 06                	jmp    801bef <strncmp+0x17>
		n--, p++, q++;
  801be9:	83 c0 01             	add    $0x1,%eax
  801bec:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801bef:	39 d8                	cmp    %ebx,%eax
  801bf1:	74 15                	je     801c08 <strncmp+0x30>
  801bf3:	0f b6 08             	movzbl (%eax),%ecx
  801bf6:	84 c9                	test   %cl,%cl
  801bf8:	74 04                	je     801bfe <strncmp+0x26>
  801bfa:	3a 0a                	cmp    (%edx),%cl
  801bfc:	74 eb                	je     801be9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801bfe:	0f b6 00             	movzbl (%eax),%eax
  801c01:	0f b6 12             	movzbl (%edx),%edx
  801c04:	29 d0                	sub    %edx,%eax
  801c06:	eb 05                	jmp    801c0d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c08:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c0d:	5b                   	pop    %ebx
  801c0e:	5d                   	pop    %ebp
  801c0f:	c3                   	ret    

00801c10 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	8b 45 08             	mov    0x8(%ebp),%eax
  801c16:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c1a:	eb 07                	jmp    801c23 <strchr+0x13>
		if (*s == c)
  801c1c:	38 ca                	cmp    %cl,%dl
  801c1e:	74 0f                	je     801c2f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c20:	83 c0 01             	add    $0x1,%eax
  801c23:	0f b6 10             	movzbl (%eax),%edx
  801c26:	84 d2                	test   %dl,%dl
  801c28:	75 f2                	jne    801c1c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    

00801c31 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	8b 45 08             	mov    0x8(%ebp),%eax
  801c37:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c3b:	eb 03                	jmp    801c40 <strfind+0xf>
  801c3d:	83 c0 01             	add    $0x1,%eax
  801c40:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c43:	38 ca                	cmp    %cl,%dl
  801c45:	74 04                	je     801c4b <strfind+0x1a>
  801c47:	84 d2                	test   %dl,%dl
  801c49:	75 f2                	jne    801c3d <strfind+0xc>
			break;
	return (char *) s;
}
  801c4b:	5d                   	pop    %ebp
  801c4c:	c3                   	ret    

00801c4d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	57                   	push   %edi
  801c51:	56                   	push   %esi
  801c52:	53                   	push   %ebx
  801c53:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c59:	85 c9                	test   %ecx,%ecx
  801c5b:	74 36                	je     801c93 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c5d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c63:	75 28                	jne    801c8d <memset+0x40>
  801c65:	f6 c1 03             	test   $0x3,%cl
  801c68:	75 23                	jne    801c8d <memset+0x40>
		c &= 0xFF;
  801c6a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801c6e:	89 d3                	mov    %edx,%ebx
  801c70:	c1 e3 08             	shl    $0x8,%ebx
  801c73:	89 d6                	mov    %edx,%esi
  801c75:	c1 e6 18             	shl    $0x18,%esi
  801c78:	89 d0                	mov    %edx,%eax
  801c7a:	c1 e0 10             	shl    $0x10,%eax
  801c7d:	09 f0                	or     %esi,%eax
  801c7f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801c81:	89 d8                	mov    %ebx,%eax
  801c83:	09 d0                	or     %edx,%eax
  801c85:	c1 e9 02             	shr    $0x2,%ecx
  801c88:	fc                   	cld    
  801c89:	f3 ab                	rep stos %eax,%es:(%edi)
  801c8b:	eb 06                	jmp    801c93 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801c8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c90:	fc                   	cld    
  801c91:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801c93:	89 f8                	mov    %edi,%eax
  801c95:	5b                   	pop    %ebx
  801c96:	5e                   	pop    %esi
  801c97:	5f                   	pop    %edi
  801c98:	5d                   	pop    %ebp
  801c99:	c3                   	ret    

00801c9a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801c9a:	55                   	push   %ebp
  801c9b:	89 e5                	mov    %esp,%ebp
  801c9d:	57                   	push   %edi
  801c9e:	56                   	push   %esi
  801c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ca5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ca8:	39 c6                	cmp    %eax,%esi
  801caa:	73 35                	jae    801ce1 <memmove+0x47>
  801cac:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801caf:	39 d0                	cmp    %edx,%eax
  801cb1:	73 2e                	jae    801ce1 <memmove+0x47>
		s += n;
		d += n;
  801cb3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cb6:	89 d6                	mov    %edx,%esi
  801cb8:	09 fe                	or     %edi,%esi
  801cba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cc0:	75 13                	jne    801cd5 <memmove+0x3b>
  801cc2:	f6 c1 03             	test   $0x3,%cl
  801cc5:	75 0e                	jne    801cd5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801cc7:	83 ef 04             	sub    $0x4,%edi
  801cca:	8d 72 fc             	lea    -0x4(%edx),%esi
  801ccd:	c1 e9 02             	shr    $0x2,%ecx
  801cd0:	fd                   	std    
  801cd1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801cd3:	eb 09                	jmp    801cde <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801cd5:	83 ef 01             	sub    $0x1,%edi
  801cd8:	8d 72 ff             	lea    -0x1(%edx),%esi
  801cdb:	fd                   	std    
  801cdc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801cde:	fc                   	cld    
  801cdf:	eb 1d                	jmp    801cfe <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ce1:	89 f2                	mov    %esi,%edx
  801ce3:	09 c2                	or     %eax,%edx
  801ce5:	f6 c2 03             	test   $0x3,%dl
  801ce8:	75 0f                	jne    801cf9 <memmove+0x5f>
  801cea:	f6 c1 03             	test   $0x3,%cl
  801ced:	75 0a                	jne    801cf9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801cef:	c1 e9 02             	shr    $0x2,%ecx
  801cf2:	89 c7                	mov    %eax,%edi
  801cf4:	fc                   	cld    
  801cf5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801cf7:	eb 05                	jmp    801cfe <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801cf9:	89 c7                	mov    %eax,%edi
  801cfb:	fc                   	cld    
  801cfc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    

00801d02 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d05:	ff 75 10             	pushl  0x10(%ebp)
  801d08:	ff 75 0c             	pushl  0xc(%ebp)
  801d0b:	ff 75 08             	pushl  0x8(%ebp)
  801d0e:	e8 87 ff ff ff       	call   801c9a <memmove>
}
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	56                   	push   %esi
  801d19:	53                   	push   %ebx
  801d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d20:	89 c6                	mov    %eax,%esi
  801d22:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d25:	eb 1a                	jmp    801d41 <memcmp+0x2c>
		if (*s1 != *s2)
  801d27:	0f b6 08             	movzbl (%eax),%ecx
  801d2a:	0f b6 1a             	movzbl (%edx),%ebx
  801d2d:	38 d9                	cmp    %bl,%cl
  801d2f:	74 0a                	je     801d3b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d31:	0f b6 c1             	movzbl %cl,%eax
  801d34:	0f b6 db             	movzbl %bl,%ebx
  801d37:	29 d8                	sub    %ebx,%eax
  801d39:	eb 0f                	jmp    801d4a <memcmp+0x35>
		s1++, s2++;
  801d3b:	83 c0 01             	add    $0x1,%eax
  801d3e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d41:	39 f0                	cmp    %esi,%eax
  801d43:	75 e2                	jne    801d27 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d4a:	5b                   	pop    %ebx
  801d4b:	5e                   	pop    %esi
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	53                   	push   %ebx
  801d52:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d55:	89 c1                	mov    %eax,%ecx
  801d57:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d5a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d5e:	eb 0a                	jmp    801d6a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d60:	0f b6 10             	movzbl (%eax),%edx
  801d63:	39 da                	cmp    %ebx,%edx
  801d65:	74 07                	je     801d6e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d67:	83 c0 01             	add    $0x1,%eax
  801d6a:	39 c8                	cmp    %ecx,%eax
  801d6c:	72 f2                	jb     801d60 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801d6e:	5b                   	pop    %ebx
  801d6f:	5d                   	pop    %ebp
  801d70:	c3                   	ret    

00801d71 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	57                   	push   %edi
  801d75:	56                   	push   %esi
  801d76:	53                   	push   %ebx
  801d77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d7d:	eb 03                	jmp    801d82 <strtol+0x11>
		s++;
  801d7f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d82:	0f b6 01             	movzbl (%ecx),%eax
  801d85:	3c 20                	cmp    $0x20,%al
  801d87:	74 f6                	je     801d7f <strtol+0xe>
  801d89:	3c 09                	cmp    $0x9,%al
  801d8b:	74 f2                	je     801d7f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801d8d:	3c 2b                	cmp    $0x2b,%al
  801d8f:	75 0a                	jne    801d9b <strtol+0x2a>
		s++;
  801d91:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801d94:	bf 00 00 00 00       	mov    $0x0,%edi
  801d99:	eb 11                	jmp    801dac <strtol+0x3b>
  801d9b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801da0:	3c 2d                	cmp    $0x2d,%al
  801da2:	75 08                	jne    801dac <strtol+0x3b>
		s++, neg = 1;
  801da4:	83 c1 01             	add    $0x1,%ecx
  801da7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dac:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801db2:	75 15                	jne    801dc9 <strtol+0x58>
  801db4:	80 39 30             	cmpb   $0x30,(%ecx)
  801db7:	75 10                	jne    801dc9 <strtol+0x58>
  801db9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801dbd:	75 7c                	jne    801e3b <strtol+0xca>
		s += 2, base = 16;
  801dbf:	83 c1 02             	add    $0x2,%ecx
  801dc2:	bb 10 00 00 00       	mov    $0x10,%ebx
  801dc7:	eb 16                	jmp    801ddf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801dc9:	85 db                	test   %ebx,%ebx
  801dcb:	75 12                	jne    801ddf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801dcd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801dd2:	80 39 30             	cmpb   $0x30,(%ecx)
  801dd5:	75 08                	jne    801ddf <strtol+0x6e>
		s++, base = 8;
  801dd7:	83 c1 01             	add    $0x1,%ecx
  801dda:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801ddf:	b8 00 00 00 00       	mov    $0x0,%eax
  801de4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801de7:	0f b6 11             	movzbl (%ecx),%edx
  801dea:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ded:	89 f3                	mov    %esi,%ebx
  801def:	80 fb 09             	cmp    $0x9,%bl
  801df2:	77 08                	ja     801dfc <strtol+0x8b>
			dig = *s - '0';
  801df4:	0f be d2             	movsbl %dl,%edx
  801df7:	83 ea 30             	sub    $0x30,%edx
  801dfa:	eb 22                	jmp    801e1e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801dfc:	8d 72 9f             	lea    -0x61(%edx),%esi
  801dff:	89 f3                	mov    %esi,%ebx
  801e01:	80 fb 19             	cmp    $0x19,%bl
  801e04:	77 08                	ja     801e0e <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e06:	0f be d2             	movsbl %dl,%edx
  801e09:	83 ea 57             	sub    $0x57,%edx
  801e0c:	eb 10                	jmp    801e1e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e0e:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e11:	89 f3                	mov    %esi,%ebx
  801e13:	80 fb 19             	cmp    $0x19,%bl
  801e16:	77 16                	ja     801e2e <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e18:	0f be d2             	movsbl %dl,%edx
  801e1b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e1e:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e21:	7d 0b                	jge    801e2e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e23:	83 c1 01             	add    $0x1,%ecx
  801e26:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e2a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e2c:	eb b9                	jmp    801de7 <strtol+0x76>

	if (endptr)
  801e2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e32:	74 0d                	je     801e41 <strtol+0xd0>
		*endptr = (char *) s;
  801e34:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e37:	89 0e                	mov    %ecx,(%esi)
  801e39:	eb 06                	jmp    801e41 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e3b:	85 db                	test   %ebx,%ebx
  801e3d:	74 98                	je     801dd7 <strtol+0x66>
  801e3f:	eb 9e                	jmp    801ddf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e41:	89 c2                	mov    %eax,%edx
  801e43:	f7 da                	neg    %edx
  801e45:	85 ff                	test   %edi,%edi
  801e47:	0f 45 c2             	cmovne %edx,%eax
}
  801e4a:	5b                   	pop    %ebx
  801e4b:	5e                   	pop    %esi
  801e4c:	5f                   	pop    %edi
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	56                   	push   %esi
  801e53:	53                   	push   %ebx
  801e54:	8b 75 08             	mov    0x8(%ebp),%esi
  801e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e5d:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e5f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e64:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801e67:	83 ec 0c             	sub    $0xc,%esp
  801e6a:	50                   	push   %eax
  801e6b:	e8 96 e4 ff ff       	call   800306 <sys_ipc_recv>

	if (from_env_store != NULL)
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	85 f6                	test   %esi,%esi
  801e75:	74 14                	je     801e8b <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801e77:	ba 00 00 00 00       	mov    $0x0,%edx
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	78 09                	js     801e89 <ipc_recv+0x3a>
  801e80:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e86:	8b 52 74             	mov    0x74(%edx),%edx
  801e89:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801e8b:	85 db                	test   %ebx,%ebx
  801e8d:	74 14                	je     801ea3 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801e8f:	ba 00 00 00 00       	mov    $0x0,%edx
  801e94:	85 c0                	test   %eax,%eax
  801e96:	78 09                	js     801ea1 <ipc_recv+0x52>
  801e98:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e9e:	8b 52 78             	mov    0x78(%edx),%edx
  801ea1:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	78 08                	js     801eaf <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ea7:	a1 08 40 80 00       	mov    0x804008,%eax
  801eac:	8b 40 70             	mov    0x70(%eax),%eax
}
  801eaf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb2:	5b                   	pop    %ebx
  801eb3:	5e                   	pop    %esi
  801eb4:	5d                   	pop    %ebp
  801eb5:	c3                   	ret    

00801eb6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	57                   	push   %edi
  801eba:	56                   	push   %esi
  801ebb:	53                   	push   %ebx
  801ebc:	83 ec 0c             	sub    $0xc,%esp
  801ebf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ec2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801ec8:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801eca:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ecf:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ed2:	ff 75 14             	pushl  0x14(%ebp)
  801ed5:	53                   	push   %ebx
  801ed6:	56                   	push   %esi
  801ed7:	57                   	push   %edi
  801ed8:	e8 06 e4 ff ff       	call   8002e3 <sys_ipc_try_send>

		if (err < 0) {
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	79 1e                	jns    801f02 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801ee4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ee7:	75 07                	jne    801ef0 <ipc_send+0x3a>
				sys_yield();
  801ee9:	e8 49 e2 ff ff       	call   800137 <sys_yield>
  801eee:	eb e2                	jmp    801ed2 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801ef0:	50                   	push   %eax
  801ef1:	68 a0 26 80 00       	push   $0x8026a0
  801ef6:	6a 49                	push   $0x49
  801ef8:	68 ad 26 80 00       	push   $0x8026ad
  801efd:	e8 a8 f5 ff ff       	call   8014aa <_panic>
		}

	} while (err < 0);

}
  801f02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f05:	5b                   	pop    %ebx
  801f06:	5e                   	pop    %esi
  801f07:	5f                   	pop    %edi
  801f08:	5d                   	pop    %ebp
  801f09:	c3                   	ret    

00801f0a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f10:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f15:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f18:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f1e:	8b 52 50             	mov    0x50(%edx),%edx
  801f21:	39 ca                	cmp    %ecx,%edx
  801f23:	75 0d                	jne    801f32 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f25:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f28:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f2d:	8b 40 48             	mov    0x48(%eax),%eax
  801f30:	eb 0f                	jmp    801f41 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f32:	83 c0 01             	add    $0x1,%eax
  801f35:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f3a:	75 d9                	jne    801f15 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f41:	5d                   	pop    %ebp
  801f42:	c3                   	ret    

00801f43 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f49:	89 d0                	mov    %edx,%eax
  801f4b:	c1 e8 16             	shr    $0x16,%eax
  801f4e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f55:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5a:	f6 c1 01             	test   $0x1,%cl
  801f5d:	74 1d                	je     801f7c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f5f:	c1 ea 0c             	shr    $0xc,%edx
  801f62:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f69:	f6 c2 01             	test   $0x1,%dl
  801f6c:	74 0e                	je     801f7c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f6e:	c1 ea 0c             	shr    $0xc,%edx
  801f71:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f78:	ef 
  801f79:	0f b7 c0             	movzwl %ax,%eax
}
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    
  801f7e:	66 90                	xchg   %ax,%ax

00801f80 <__udivdi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f97:	85 f6                	test   %esi,%esi
  801f99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f9d:	89 ca                	mov    %ecx,%edx
  801f9f:	89 f8                	mov    %edi,%eax
  801fa1:	75 3d                	jne    801fe0 <__udivdi3+0x60>
  801fa3:	39 cf                	cmp    %ecx,%edi
  801fa5:	0f 87 c5 00 00 00    	ja     802070 <__udivdi3+0xf0>
  801fab:	85 ff                	test   %edi,%edi
  801fad:	89 fd                	mov    %edi,%ebp
  801faf:	75 0b                	jne    801fbc <__udivdi3+0x3c>
  801fb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb6:	31 d2                	xor    %edx,%edx
  801fb8:	f7 f7                	div    %edi
  801fba:	89 c5                	mov    %eax,%ebp
  801fbc:	89 c8                	mov    %ecx,%eax
  801fbe:	31 d2                	xor    %edx,%edx
  801fc0:	f7 f5                	div    %ebp
  801fc2:	89 c1                	mov    %eax,%ecx
  801fc4:	89 d8                	mov    %ebx,%eax
  801fc6:	89 cf                	mov    %ecx,%edi
  801fc8:	f7 f5                	div    %ebp
  801fca:	89 c3                	mov    %eax,%ebx
  801fcc:	89 d8                	mov    %ebx,%eax
  801fce:	89 fa                	mov    %edi,%edx
  801fd0:	83 c4 1c             	add    $0x1c,%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5e                   	pop    %esi
  801fd5:	5f                   	pop    %edi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    
  801fd8:	90                   	nop
  801fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	39 ce                	cmp    %ecx,%esi
  801fe2:	77 74                	ja     802058 <__udivdi3+0xd8>
  801fe4:	0f bd fe             	bsr    %esi,%edi
  801fe7:	83 f7 1f             	xor    $0x1f,%edi
  801fea:	0f 84 98 00 00 00    	je     802088 <__udivdi3+0x108>
  801ff0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	89 c5                	mov    %eax,%ebp
  801ff9:	29 fb                	sub    %edi,%ebx
  801ffb:	d3 e6                	shl    %cl,%esi
  801ffd:	89 d9                	mov    %ebx,%ecx
  801fff:	d3 ed                	shr    %cl,%ebp
  802001:	89 f9                	mov    %edi,%ecx
  802003:	d3 e0                	shl    %cl,%eax
  802005:	09 ee                	or     %ebp,%esi
  802007:	89 d9                	mov    %ebx,%ecx
  802009:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80200d:	89 d5                	mov    %edx,%ebp
  80200f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802013:	d3 ed                	shr    %cl,%ebp
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e2                	shl    %cl,%edx
  802019:	89 d9                	mov    %ebx,%ecx
  80201b:	d3 e8                	shr    %cl,%eax
  80201d:	09 c2                	or     %eax,%edx
  80201f:	89 d0                	mov    %edx,%eax
  802021:	89 ea                	mov    %ebp,%edx
  802023:	f7 f6                	div    %esi
  802025:	89 d5                	mov    %edx,%ebp
  802027:	89 c3                	mov    %eax,%ebx
  802029:	f7 64 24 0c          	mull   0xc(%esp)
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	72 10                	jb     802041 <__udivdi3+0xc1>
  802031:	8b 74 24 08          	mov    0x8(%esp),%esi
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e6                	shl    %cl,%esi
  802039:	39 c6                	cmp    %eax,%esi
  80203b:	73 07                	jae    802044 <__udivdi3+0xc4>
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	75 03                	jne    802044 <__udivdi3+0xc4>
  802041:	83 eb 01             	sub    $0x1,%ebx
  802044:	31 ff                	xor    %edi,%edi
  802046:	89 d8                	mov    %ebx,%eax
  802048:	89 fa                	mov    %edi,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	31 ff                	xor    %edi,%edi
  80205a:	31 db                	xor    %ebx,%ebx
  80205c:	89 d8                	mov    %ebx,%eax
  80205e:	89 fa                	mov    %edi,%edx
  802060:	83 c4 1c             	add    $0x1c,%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
  802068:	90                   	nop
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d8                	mov    %ebx,%eax
  802072:	f7 f7                	div    %edi
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 c3                	mov    %eax,%ebx
  802078:	89 d8                	mov    %ebx,%eax
  80207a:	89 fa                	mov    %edi,%edx
  80207c:	83 c4 1c             	add    $0x1c,%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    
  802084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802088:	39 ce                	cmp    %ecx,%esi
  80208a:	72 0c                	jb     802098 <__udivdi3+0x118>
  80208c:	31 db                	xor    %ebx,%ebx
  80208e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802092:	0f 87 34 ff ff ff    	ja     801fcc <__udivdi3+0x4c>
  802098:	bb 01 00 00 00       	mov    $0x1,%ebx
  80209d:	e9 2a ff ff ff       	jmp    801fcc <__udivdi3+0x4c>
  8020a2:	66 90                	xchg   %ax,%ax
  8020a4:	66 90                	xchg   %ax,%ax
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__umoddi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 d2                	test   %edx,%edx
  8020c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f3                	mov    %esi,%ebx
  8020d3:	89 3c 24             	mov    %edi,(%esp)
  8020d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020da:	75 1c                	jne    8020f8 <__umoddi3+0x48>
  8020dc:	39 f7                	cmp    %esi,%edi
  8020de:	76 50                	jbe    802130 <__umoddi3+0x80>
  8020e0:	89 c8                	mov    %ecx,%eax
  8020e2:	89 f2                	mov    %esi,%edx
  8020e4:	f7 f7                	div    %edi
  8020e6:	89 d0                	mov    %edx,%eax
  8020e8:	31 d2                	xor    %edx,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	39 f2                	cmp    %esi,%edx
  8020fa:	89 d0                	mov    %edx,%eax
  8020fc:	77 52                	ja     802150 <__umoddi3+0xa0>
  8020fe:	0f bd ea             	bsr    %edx,%ebp
  802101:	83 f5 1f             	xor    $0x1f,%ebp
  802104:	75 5a                	jne    802160 <__umoddi3+0xb0>
  802106:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80210a:	0f 82 e0 00 00 00    	jb     8021f0 <__umoddi3+0x140>
  802110:	39 0c 24             	cmp    %ecx,(%esp)
  802113:	0f 86 d7 00 00 00    	jbe    8021f0 <__umoddi3+0x140>
  802119:	8b 44 24 08          	mov    0x8(%esp),%eax
  80211d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802121:	83 c4 1c             	add    $0x1c,%esp
  802124:	5b                   	pop    %ebx
  802125:	5e                   	pop    %esi
  802126:	5f                   	pop    %edi
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	85 ff                	test   %edi,%edi
  802132:	89 fd                	mov    %edi,%ebp
  802134:	75 0b                	jne    802141 <__umoddi3+0x91>
  802136:	b8 01 00 00 00       	mov    $0x1,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	f7 f7                	div    %edi
  80213f:	89 c5                	mov    %eax,%ebp
  802141:	89 f0                	mov    %esi,%eax
  802143:	31 d2                	xor    %edx,%edx
  802145:	f7 f5                	div    %ebp
  802147:	89 c8                	mov    %ecx,%eax
  802149:	f7 f5                	div    %ebp
  80214b:	89 d0                	mov    %edx,%eax
  80214d:	eb 99                	jmp    8020e8 <__umoddi3+0x38>
  80214f:	90                   	nop
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	83 c4 1c             	add    $0x1c,%esp
  802157:	5b                   	pop    %ebx
  802158:	5e                   	pop    %esi
  802159:	5f                   	pop    %edi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    
  80215c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802160:	8b 34 24             	mov    (%esp),%esi
  802163:	bf 20 00 00 00       	mov    $0x20,%edi
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	29 ef                	sub    %ebp,%edi
  80216c:	d3 e0                	shl    %cl,%eax
  80216e:	89 f9                	mov    %edi,%ecx
  802170:	89 f2                	mov    %esi,%edx
  802172:	d3 ea                	shr    %cl,%edx
  802174:	89 e9                	mov    %ebp,%ecx
  802176:	09 c2                	or     %eax,%edx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 14 24             	mov    %edx,(%esp)
  80217d:	89 f2                	mov    %esi,%edx
  80217f:	d3 e2                	shl    %cl,%edx
  802181:	89 f9                	mov    %edi,%ecx
  802183:	89 54 24 04          	mov    %edx,0x4(%esp)
  802187:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	89 c6                	mov    %eax,%esi
  802191:	d3 e3                	shl    %cl,%ebx
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 d0                	mov    %edx,%eax
  802197:	d3 e8                	shr    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	09 d8                	or     %ebx,%eax
  80219d:	89 d3                	mov    %edx,%ebx
  80219f:	89 f2                	mov    %esi,%edx
  8021a1:	f7 34 24             	divl   (%esp)
  8021a4:	89 d6                	mov    %edx,%esi
  8021a6:	d3 e3                	shl    %cl,%ebx
  8021a8:	f7 64 24 04          	mull   0x4(%esp)
  8021ac:	39 d6                	cmp    %edx,%esi
  8021ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021b2:	89 d1                	mov    %edx,%ecx
  8021b4:	89 c3                	mov    %eax,%ebx
  8021b6:	72 08                	jb     8021c0 <__umoddi3+0x110>
  8021b8:	75 11                	jne    8021cb <__umoddi3+0x11b>
  8021ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021be:	73 0b                	jae    8021cb <__umoddi3+0x11b>
  8021c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021c4:	1b 14 24             	sbb    (%esp),%edx
  8021c7:	89 d1                	mov    %edx,%ecx
  8021c9:	89 c3                	mov    %eax,%ebx
  8021cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021cf:	29 da                	sub    %ebx,%edx
  8021d1:	19 ce                	sbb    %ecx,%esi
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 f0                	mov    %esi,%eax
  8021d7:	d3 e0                	shl    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	d3 ea                	shr    %cl,%edx
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	d3 ee                	shr    %cl,%esi
  8021e1:	09 d0                	or     %edx,%eax
  8021e3:	89 f2                	mov    %esi,%edx
  8021e5:	83 c4 1c             	add    $0x1c,%esp
  8021e8:	5b                   	pop    %ebx
  8021e9:	5e                   	pop    %esi
  8021ea:	5f                   	pop    %edi
  8021eb:	5d                   	pop    %ebp
  8021ec:	c3                   	ret    
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi
  8021f0:	29 f9                	sub    %edi,%ecx
  8021f2:	19 d6                	sbb    %edx,%esi
  8021f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021fc:	e9 18 ff ff ff       	jmp    802119 <__umoddi3+0x69>
