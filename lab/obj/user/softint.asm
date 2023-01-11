
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
  800086:	e8 2a 05 00 00       	call   8005b5 <close_all>
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
  8000ff:	68 aa 22 80 00       	push   $0x8022aa
  800104:	6a 23                	push   $0x23
  800106:	68 c7 22 80 00       	push   $0x8022c7
  80010b:	e8 1e 14 00 00       	call   80152e <_panic>

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
  800180:	68 aa 22 80 00       	push   $0x8022aa
  800185:	6a 23                	push   $0x23
  800187:	68 c7 22 80 00       	push   $0x8022c7
  80018c:	e8 9d 13 00 00       	call   80152e <_panic>

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
  8001c2:	68 aa 22 80 00       	push   $0x8022aa
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 c7 22 80 00       	push   $0x8022c7
  8001ce:	e8 5b 13 00 00       	call   80152e <_panic>

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
  800204:	68 aa 22 80 00       	push   $0x8022aa
  800209:	6a 23                	push   $0x23
  80020b:	68 c7 22 80 00       	push   $0x8022c7
  800210:	e8 19 13 00 00       	call   80152e <_panic>

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
  800246:	68 aa 22 80 00       	push   $0x8022aa
  80024b:	6a 23                	push   $0x23
  80024d:	68 c7 22 80 00       	push   $0x8022c7
  800252:	e8 d7 12 00 00       	call   80152e <_panic>

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
  800288:	68 aa 22 80 00       	push   $0x8022aa
  80028d:	6a 23                	push   $0x23
  80028f:	68 c7 22 80 00       	push   $0x8022c7
  800294:	e8 95 12 00 00       	call   80152e <_panic>

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
  8002ca:	68 aa 22 80 00       	push   $0x8022aa
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 c7 22 80 00       	push   $0x8022c7
  8002d6:	e8 53 12 00 00       	call   80152e <_panic>

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
  80032e:	68 aa 22 80 00       	push   $0x8022aa
  800333:	6a 23                	push   $0x23
  800335:	68 c7 22 80 00       	push   $0x8022c7
  80033a:	e8 ef 11 00 00       	call   80152e <_panic>

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

00800366 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	57                   	push   %edi
  80036a:	56                   	push   %esi
  80036b:	53                   	push   %ebx
  80036c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80036f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800374:	b8 0f 00 00 00       	mov    $0xf,%eax
  800379:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037c:	8b 55 08             	mov    0x8(%ebp),%edx
  80037f:	89 df                	mov    %ebx,%edi
  800381:	89 de                	mov    %ebx,%esi
  800383:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800385:	85 c0                	test   %eax,%eax
  800387:	7e 17                	jle    8003a0 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800389:	83 ec 0c             	sub    $0xc,%esp
  80038c:	50                   	push   %eax
  80038d:	6a 0f                	push   $0xf
  80038f:	68 aa 22 80 00       	push   $0x8022aa
  800394:	6a 23                	push   $0x23
  800396:	68 c7 22 80 00       	push   $0x8022c7
  80039b:	e8 8e 11 00 00       	call   80152e <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8003a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003a3:	5b                   	pop    %ebx
  8003a4:	5e                   	pop    %esi
  8003a5:	5f                   	pop    %edi
  8003a6:	5d                   	pop    %ebp
  8003a7:	c3                   	ret    

008003a8 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	57                   	push   %edi
  8003ac:	56                   	push   %esi
  8003ad:	53                   	push   %ebx
  8003ae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b6:	b8 10 00 00 00       	mov    $0x10,%eax
  8003bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003be:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c1:	89 df                	mov    %ebx,%edi
  8003c3:	89 de                	mov    %ebx,%esi
  8003c5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003c7:	85 c0                	test   %eax,%eax
  8003c9:	7e 17                	jle    8003e2 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003cb:	83 ec 0c             	sub    $0xc,%esp
  8003ce:	50                   	push   %eax
  8003cf:	6a 10                	push   $0x10
  8003d1:	68 aa 22 80 00       	push   $0x8022aa
  8003d6:	6a 23                	push   $0x23
  8003d8:	68 c7 22 80 00       	push   $0x8022c7
  8003dd:	e8 4c 11 00 00       	call   80152e <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  8003e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e5:	5b                   	pop    %ebx
  8003e6:	5e                   	pop    %esi
  8003e7:	5f                   	pop    %edi
  8003e8:	5d                   	pop    %ebp
  8003e9:	c3                   	ret    

008003ea <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f0:	05 00 00 00 30       	add    $0x30000000,%eax
  8003f5:	c1 e8 0c             	shr    $0xc,%eax
}
  8003f8:	5d                   	pop    %ebp
  8003f9:	c3                   	ret    

008003fa <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800400:	05 00 00 00 30       	add    $0x30000000,%eax
  800405:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80040a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800417:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80041c:	89 c2                	mov    %eax,%edx
  80041e:	c1 ea 16             	shr    $0x16,%edx
  800421:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800428:	f6 c2 01             	test   $0x1,%dl
  80042b:	74 11                	je     80043e <fd_alloc+0x2d>
  80042d:	89 c2                	mov    %eax,%edx
  80042f:	c1 ea 0c             	shr    $0xc,%edx
  800432:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800439:	f6 c2 01             	test   $0x1,%dl
  80043c:	75 09                	jne    800447 <fd_alloc+0x36>
			*fd_store = fd;
  80043e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800440:	b8 00 00 00 00       	mov    $0x0,%eax
  800445:	eb 17                	jmp    80045e <fd_alloc+0x4d>
  800447:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80044c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800451:	75 c9                	jne    80041c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800453:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800459:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80045e:	5d                   	pop    %ebp
  80045f:	c3                   	ret    

00800460 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800460:	55                   	push   %ebp
  800461:	89 e5                	mov    %esp,%ebp
  800463:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800466:	83 f8 1f             	cmp    $0x1f,%eax
  800469:	77 36                	ja     8004a1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80046b:	c1 e0 0c             	shl    $0xc,%eax
  80046e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800473:	89 c2                	mov    %eax,%edx
  800475:	c1 ea 16             	shr    $0x16,%edx
  800478:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80047f:	f6 c2 01             	test   $0x1,%dl
  800482:	74 24                	je     8004a8 <fd_lookup+0x48>
  800484:	89 c2                	mov    %eax,%edx
  800486:	c1 ea 0c             	shr    $0xc,%edx
  800489:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800490:	f6 c2 01             	test   $0x1,%dl
  800493:	74 1a                	je     8004af <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800495:	8b 55 0c             	mov    0xc(%ebp),%edx
  800498:	89 02                	mov    %eax,(%edx)
	return 0;
  80049a:	b8 00 00 00 00       	mov    $0x0,%eax
  80049f:	eb 13                	jmp    8004b4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a6:	eb 0c                	jmp    8004b4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ad:	eb 05                	jmp    8004b4 <fd_lookup+0x54>
  8004af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004b4:	5d                   	pop    %ebp
  8004b5:	c3                   	ret    

008004b6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004bf:	ba 54 23 80 00       	mov    $0x802354,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004c4:	eb 13                	jmp    8004d9 <dev_lookup+0x23>
  8004c6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004c9:	39 08                	cmp    %ecx,(%eax)
  8004cb:	75 0c                	jne    8004d9 <dev_lookup+0x23>
			*dev = devtab[i];
  8004cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d7:	eb 2e                	jmp    800507 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004d9:	8b 02                	mov    (%edx),%eax
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	75 e7                	jne    8004c6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004df:	a1 08 40 80 00       	mov    0x804008,%eax
  8004e4:	8b 40 48             	mov    0x48(%eax),%eax
  8004e7:	83 ec 04             	sub    $0x4,%esp
  8004ea:	51                   	push   %ecx
  8004eb:	50                   	push   %eax
  8004ec:	68 d8 22 80 00       	push   $0x8022d8
  8004f1:	e8 11 11 00 00       	call   801607 <cprintf>
	*dev = 0;
  8004f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800507:	c9                   	leave  
  800508:	c3                   	ret    

00800509 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800509:	55                   	push   %ebp
  80050a:	89 e5                	mov    %esp,%ebp
  80050c:	56                   	push   %esi
  80050d:	53                   	push   %ebx
  80050e:	83 ec 10             	sub    $0x10,%esp
  800511:	8b 75 08             	mov    0x8(%ebp),%esi
  800514:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800517:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051a:	50                   	push   %eax
  80051b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800521:	c1 e8 0c             	shr    $0xc,%eax
  800524:	50                   	push   %eax
  800525:	e8 36 ff ff ff       	call   800460 <fd_lookup>
  80052a:	83 c4 08             	add    $0x8,%esp
  80052d:	85 c0                	test   %eax,%eax
  80052f:	78 05                	js     800536 <fd_close+0x2d>
	    || fd != fd2)
  800531:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800534:	74 0c                	je     800542 <fd_close+0x39>
		return (must_exist ? r : 0);
  800536:	84 db                	test   %bl,%bl
  800538:	ba 00 00 00 00       	mov    $0x0,%edx
  80053d:	0f 44 c2             	cmove  %edx,%eax
  800540:	eb 41                	jmp    800583 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800548:	50                   	push   %eax
  800549:	ff 36                	pushl  (%esi)
  80054b:	e8 66 ff ff ff       	call   8004b6 <dev_lookup>
  800550:	89 c3                	mov    %eax,%ebx
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	85 c0                	test   %eax,%eax
  800557:	78 1a                	js     800573 <fd_close+0x6a>
		if (dev->dev_close)
  800559:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80055c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80055f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800564:	85 c0                	test   %eax,%eax
  800566:	74 0b                	je     800573 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800568:	83 ec 0c             	sub    $0xc,%esp
  80056b:	56                   	push   %esi
  80056c:	ff d0                	call   *%eax
  80056e:	89 c3                	mov    %eax,%ebx
  800570:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	56                   	push   %esi
  800577:	6a 00                	push   $0x0
  800579:	e8 5d fc ff ff       	call   8001db <sys_page_unmap>
	return r;
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	89 d8                	mov    %ebx,%eax
}
  800583:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800586:	5b                   	pop    %ebx
  800587:	5e                   	pop    %esi
  800588:	5d                   	pop    %ebp
  800589:	c3                   	ret    

0080058a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80058a:	55                   	push   %ebp
  80058b:	89 e5                	mov    %esp,%ebp
  80058d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800590:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800593:	50                   	push   %eax
  800594:	ff 75 08             	pushl  0x8(%ebp)
  800597:	e8 c4 fe ff ff       	call   800460 <fd_lookup>
  80059c:	83 c4 08             	add    $0x8,%esp
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	78 10                	js     8005b3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8005a3:	83 ec 08             	sub    $0x8,%esp
  8005a6:	6a 01                	push   $0x1
  8005a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8005ab:	e8 59 ff ff ff       	call   800509 <fd_close>
  8005b0:	83 c4 10             	add    $0x10,%esp
}
  8005b3:	c9                   	leave  
  8005b4:	c3                   	ret    

008005b5 <close_all>:

void
close_all(void)
{
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	53                   	push   %ebx
  8005b9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005bc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	e8 c0 ff ff ff       	call   80058a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ca:	83 c3 01             	add    $0x1,%ebx
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	83 fb 20             	cmp    $0x20,%ebx
  8005d3:	75 ec                	jne    8005c1 <close_all+0xc>
		close(i);
}
  8005d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005d8:	c9                   	leave  
  8005d9:	c3                   	ret    

008005da <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005da:	55                   	push   %ebp
  8005db:	89 e5                	mov    %esp,%ebp
  8005dd:	57                   	push   %edi
  8005de:	56                   	push   %esi
  8005df:	53                   	push   %ebx
  8005e0:	83 ec 2c             	sub    $0x2c,%esp
  8005e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005e9:	50                   	push   %eax
  8005ea:	ff 75 08             	pushl  0x8(%ebp)
  8005ed:	e8 6e fe ff ff       	call   800460 <fd_lookup>
  8005f2:	83 c4 08             	add    $0x8,%esp
  8005f5:	85 c0                	test   %eax,%eax
  8005f7:	0f 88 c1 00 00 00    	js     8006be <dup+0xe4>
		return r;
	close(newfdnum);
  8005fd:	83 ec 0c             	sub    $0xc,%esp
  800600:	56                   	push   %esi
  800601:	e8 84 ff ff ff       	call   80058a <close>

	newfd = INDEX2FD(newfdnum);
  800606:	89 f3                	mov    %esi,%ebx
  800608:	c1 e3 0c             	shl    $0xc,%ebx
  80060b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800611:	83 c4 04             	add    $0x4,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	e8 de fd ff ff       	call   8003fa <fd2data>
  80061c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80061e:	89 1c 24             	mov    %ebx,(%esp)
  800621:	e8 d4 fd ff ff       	call   8003fa <fd2data>
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	c1 e8 16             	shr    $0x16,%eax
  800631:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800638:	a8 01                	test   $0x1,%al
  80063a:	74 37                	je     800673 <dup+0x99>
  80063c:	89 f8                	mov    %edi,%eax
  80063e:	c1 e8 0c             	shr    $0xc,%eax
  800641:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800648:	f6 c2 01             	test   $0x1,%dl
  80064b:	74 26                	je     800673 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80064d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800654:	83 ec 0c             	sub    $0xc,%esp
  800657:	25 07 0e 00 00       	and    $0xe07,%eax
  80065c:	50                   	push   %eax
  80065d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800660:	6a 00                	push   $0x0
  800662:	57                   	push   %edi
  800663:	6a 00                	push   $0x0
  800665:	e8 2f fb ff ff       	call   800199 <sys_page_map>
  80066a:	89 c7                	mov    %eax,%edi
  80066c:	83 c4 20             	add    $0x20,%esp
  80066f:	85 c0                	test   %eax,%eax
  800671:	78 2e                	js     8006a1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800673:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800676:	89 d0                	mov    %edx,%eax
  800678:	c1 e8 0c             	shr    $0xc,%eax
  80067b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800682:	83 ec 0c             	sub    $0xc,%esp
  800685:	25 07 0e 00 00       	and    $0xe07,%eax
  80068a:	50                   	push   %eax
  80068b:	53                   	push   %ebx
  80068c:	6a 00                	push   $0x0
  80068e:	52                   	push   %edx
  80068f:	6a 00                	push   $0x0
  800691:	e8 03 fb ff ff       	call   800199 <sys_page_map>
  800696:	89 c7                	mov    %eax,%edi
  800698:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80069b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80069d:	85 ff                	test   %edi,%edi
  80069f:	79 1d                	jns    8006be <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	6a 00                	push   $0x0
  8006a7:	e8 2f fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006ac:	83 c4 08             	add    $0x8,%esp
  8006af:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006b2:	6a 00                	push   $0x0
  8006b4:	e8 22 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	89 f8                	mov    %edi,%eax
}
  8006be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c1:	5b                   	pop    %ebx
  8006c2:	5e                   	pop    %esi
  8006c3:	5f                   	pop    %edi
  8006c4:	5d                   	pop    %ebp
  8006c5:	c3                   	ret    

008006c6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	53                   	push   %ebx
  8006ca:	83 ec 14             	sub    $0x14,%esp
  8006cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006d3:	50                   	push   %eax
  8006d4:	53                   	push   %ebx
  8006d5:	e8 86 fd ff ff       	call   800460 <fd_lookup>
  8006da:	83 c4 08             	add    $0x8,%esp
  8006dd:	89 c2                	mov    %eax,%edx
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	78 6d                	js     800750 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006e9:	50                   	push   %eax
  8006ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006ed:	ff 30                	pushl  (%eax)
  8006ef:	e8 c2 fd ff ff       	call   8004b6 <dev_lookup>
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	78 4c                	js     800747 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006fe:	8b 42 08             	mov    0x8(%edx),%eax
  800701:	83 e0 03             	and    $0x3,%eax
  800704:	83 f8 01             	cmp    $0x1,%eax
  800707:	75 21                	jne    80072a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800709:	a1 08 40 80 00       	mov    0x804008,%eax
  80070e:	8b 40 48             	mov    0x48(%eax),%eax
  800711:	83 ec 04             	sub    $0x4,%esp
  800714:	53                   	push   %ebx
  800715:	50                   	push   %eax
  800716:	68 19 23 80 00       	push   $0x802319
  80071b:	e8 e7 0e 00 00       	call   801607 <cprintf>
		return -E_INVAL;
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800728:	eb 26                	jmp    800750 <read+0x8a>
	}
	if (!dev->dev_read)
  80072a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072d:	8b 40 08             	mov    0x8(%eax),%eax
  800730:	85 c0                	test   %eax,%eax
  800732:	74 17                	je     80074b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800734:	83 ec 04             	sub    $0x4,%esp
  800737:	ff 75 10             	pushl  0x10(%ebp)
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	52                   	push   %edx
  80073e:	ff d0                	call   *%eax
  800740:	89 c2                	mov    %eax,%edx
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb 09                	jmp    800750 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800747:	89 c2                	mov    %eax,%edx
  800749:	eb 05                	jmp    800750 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80074b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800750:	89 d0                	mov    %edx,%eax
  800752:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800755:	c9                   	leave  
  800756:	c3                   	ret    

00800757 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	57                   	push   %edi
  80075b:	56                   	push   %esi
  80075c:	53                   	push   %ebx
  80075d:	83 ec 0c             	sub    $0xc,%esp
  800760:	8b 7d 08             	mov    0x8(%ebp),%edi
  800763:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800766:	bb 00 00 00 00       	mov    $0x0,%ebx
  80076b:	eb 21                	jmp    80078e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80076d:	83 ec 04             	sub    $0x4,%esp
  800770:	89 f0                	mov    %esi,%eax
  800772:	29 d8                	sub    %ebx,%eax
  800774:	50                   	push   %eax
  800775:	89 d8                	mov    %ebx,%eax
  800777:	03 45 0c             	add    0xc(%ebp),%eax
  80077a:	50                   	push   %eax
  80077b:	57                   	push   %edi
  80077c:	e8 45 ff ff ff       	call   8006c6 <read>
		if (m < 0)
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	85 c0                	test   %eax,%eax
  800786:	78 10                	js     800798 <readn+0x41>
			return m;
		if (m == 0)
  800788:	85 c0                	test   %eax,%eax
  80078a:	74 0a                	je     800796 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80078c:	01 c3                	add    %eax,%ebx
  80078e:	39 f3                	cmp    %esi,%ebx
  800790:	72 db                	jb     80076d <readn+0x16>
  800792:	89 d8                	mov    %ebx,%eax
  800794:	eb 02                	jmp    800798 <readn+0x41>
  800796:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800798:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079b:	5b                   	pop    %ebx
  80079c:	5e                   	pop    %esi
  80079d:	5f                   	pop    %edi
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	83 ec 14             	sub    $0x14,%esp
  8007a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ad:	50                   	push   %eax
  8007ae:	53                   	push   %ebx
  8007af:	e8 ac fc ff ff       	call   800460 <fd_lookup>
  8007b4:	83 c4 08             	add    $0x8,%esp
  8007b7:	89 c2                	mov    %eax,%edx
  8007b9:	85 c0                	test   %eax,%eax
  8007bb:	78 68                	js     800825 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007bd:	83 ec 08             	sub    $0x8,%esp
  8007c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c7:	ff 30                	pushl  (%eax)
  8007c9:	e8 e8 fc ff ff       	call   8004b6 <dev_lookup>
  8007ce:	83 c4 10             	add    $0x10,%esp
  8007d1:	85 c0                	test   %eax,%eax
  8007d3:	78 47                	js     80081c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007dc:	75 21                	jne    8007ff <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007de:	a1 08 40 80 00       	mov    0x804008,%eax
  8007e3:	8b 40 48             	mov    0x48(%eax),%eax
  8007e6:	83 ec 04             	sub    $0x4,%esp
  8007e9:	53                   	push   %ebx
  8007ea:	50                   	push   %eax
  8007eb:	68 35 23 80 00       	push   $0x802335
  8007f0:	e8 12 0e 00 00       	call   801607 <cprintf>
		return -E_INVAL;
  8007f5:	83 c4 10             	add    $0x10,%esp
  8007f8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007fd:	eb 26                	jmp    800825 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800802:	8b 52 0c             	mov    0xc(%edx),%edx
  800805:	85 d2                	test   %edx,%edx
  800807:	74 17                	je     800820 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800809:	83 ec 04             	sub    $0x4,%esp
  80080c:	ff 75 10             	pushl  0x10(%ebp)
  80080f:	ff 75 0c             	pushl  0xc(%ebp)
  800812:	50                   	push   %eax
  800813:	ff d2                	call   *%edx
  800815:	89 c2                	mov    %eax,%edx
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	eb 09                	jmp    800825 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081c:	89 c2                	mov    %eax,%edx
  80081e:	eb 05                	jmp    800825 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800820:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800825:	89 d0                	mov    %edx,%eax
  800827:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <seek>:

int
seek(int fdnum, off_t offset)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800832:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800835:	50                   	push   %eax
  800836:	ff 75 08             	pushl  0x8(%ebp)
  800839:	e8 22 fc ff ff       	call   800460 <fd_lookup>
  80083e:	83 c4 08             	add    $0x8,%esp
  800841:	85 c0                	test   %eax,%eax
  800843:	78 0e                	js     800853 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800845:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80084e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800853:	c9                   	leave  
  800854:	c3                   	ret    

00800855 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	83 ec 14             	sub    $0x14,%esp
  80085c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80085f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800862:	50                   	push   %eax
  800863:	53                   	push   %ebx
  800864:	e8 f7 fb ff ff       	call   800460 <fd_lookup>
  800869:	83 c4 08             	add    $0x8,%esp
  80086c:	89 c2                	mov    %eax,%edx
  80086e:	85 c0                	test   %eax,%eax
  800870:	78 65                	js     8008d7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800878:	50                   	push   %eax
  800879:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80087c:	ff 30                	pushl  (%eax)
  80087e:	e8 33 fc ff ff       	call   8004b6 <dev_lookup>
  800883:	83 c4 10             	add    $0x10,%esp
  800886:	85 c0                	test   %eax,%eax
  800888:	78 44                	js     8008ce <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80088a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800891:	75 21                	jne    8008b4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800893:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800898:	8b 40 48             	mov    0x48(%eax),%eax
  80089b:	83 ec 04             	sub    $0x4,%esp
  80089e:	53                   	push   %ebx
  80089f:	50                   	push   %eax
  8008a0:	68 f8 22 80 00       	push   $0x8022f8
  8008a5:	e8 5d 0d 00 00       	call   801607 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008aa:	83 c4 10             	add    $0x10,%esp
  8008ad:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008b2:	eb 23                	jmp    8008d7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008b7:	8b 52 18             	mov    0x18(%edx),%edx
  8008ba:	85 d2                	test   %edx,%edx
  8008bc:	74 14                	je     8008d2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	ff 75 0c             	pushl  0xc(%ebp)
  8008c4:	50                   	push   %eax
  8008c5:	ff d2                	call   *%edx
  8008c7:	89 c2                	mov    %eax,%edx
  8008c9:	83 c4 10             	add    $0x10,%esp
  8008cc:	eb 09                	jmp    8008d7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ce:	89 c2                	mov    %eax,%edx
  8008d0:	eb 05                	jmp    8008d7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008d2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008d7:	89 d0                	mov    %edx,%eax
  8008d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008dc:	c9                   	leave  
  8008dd:	c3                   	ret    

008008de <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	53                   	push   %ebx
  8008e2:	83 ec 14             	sub    $0x14,%esp
  8008e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008eb:	50                   	push   %eax
  8008ec:	ff 75 08             	pushl  0x8(%ebp)
  8008ef:	e8 6c fb ff ff       	call   800460 <fd_lookup>
  8008f4:	83 c4 08             	add    $0x8,%esp
  8008f7:	89 c2                	mov    %eax,%edx
  8008f9:	85 c0                	test   %eax,%eax
  8008fb:	78 58                	js     800955 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008fd:	83 ec 08             	sub    $0x8,%esp
  800900:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800903:	50                   	push   %eax
  800904:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800907:	ff 30                	pushl  (%eax)
  800909:	e8 a8 fb ff ff       	call   8004b6 <dev_lookup>
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	85 c0                	test   %eax,%eax
  800913:	78 37                	js     80094c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800915:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800918:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80091c:	74 32                	je     800950 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80091e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800921:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800928:	00 00 00 
	stat->st_isdir = 0;
  80092b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800932:	00 00 00 
	stat->st_dev = dev;
  800935:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80093b:	83 ec 08             	sub    $0x8,%esp
  80093e:	53                   	push   %ebx
  80093f:	ff 75 f0             	pushl  -0x10(%ebp)
  800942:	ff 50 14             	call   *0x14(%eax)
  800945:	89 c2                	mov    %eax,%edx
  800947:	83 c4 10             	add    $0x10,%esp
  80094a:	eb 09                	jmp    800955 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80094c:	89 c2                	mov    %eax,%edx
  80094e:	eb 05                	jmp    800955 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800950:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800955:	89 d0                	mov    %edx,%eax
  800957:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80095a:	c9                   	leave  
  80095b:	c3                   	ret    

0080095c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	56                   	push   %esi
  800960:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800961:	83 ec 08             	sub    $0x8,%esp
  800964:	6a 00                	push   $0x0
  800966:	ff 75 08             	pushl  0x8(%ebp)
  800969:	e8 d6 01 00 00       	call   800b44 <open>
  80096e:	89 c3                	mov    %eax,%ebx
  800970:	83 c4 10             	add    $0x10,%esp
  800973:	85 c0                	test   %eax,%eax
  800975:	78 1b                	js     800992 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800977:	83 ec 08             	sub    $0x8,%esp
  80097a:	ff 75 0c             	pushl  0xc(%ebp)
  80097d:	50                   	push   %eax
  80097e:	e8 5b ff ff ff       	call   8008de <fstat>
  800983:	89 c6                	mov    %eax,%esi
	close(fd);
  800985:	89 1c 24             	mov    %ebx,(%esp)
  800988:	e8 fd fb ff ff       	call   80058a <close>
	return r;
  80098d:	83 c4 10             	add    $0x10,%esp
  800990:	89 f0                	mov    %esi,%eax
}
  800992:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800995:	5b                   	pop    %ebx
  800996:	5e                   	pop    %esi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
  80099e:	89 c6                	mov    %eax,%esi
  8009a0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009a2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009a9:	75 12                	jne    8009bd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009ab:	83 ec 0c             	sub    $0xc,%esp
  8009ae:	6a 01                	push   $0x1
  8009b0:	e8 d9 15 00 00       	call   801f8e <ipc_find_env>
  8009b5:	a3 00 40 80 00       	mov    %eax,0x804000
  8009ba:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009bd:	6a 07                	push   $0x7
  8009bf:	68 00 50 80 00       	push   $0x805000
  8009c4:	56                   	push   %esi
  8009c5:	ff 35 00 40 80 00    	pushl  0x804000
  8009cb:	e8 6a 15 00 00       	call   801f3a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009d0:	83 c4 0c             	add    $0xc,%esp
  8009d3:	6a 00                	push   $0x0
  8009d5:	53                   	push   %ebx
  8009d6:	6a 00                	push   $0x0
  8009d8:	e8 f6 14 00 00       	call   801ed3 <ipc_recv>
}
  8009dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800a02:	b8 02 00 00 00       	mov    $0x2,%eax
  800a07:	e8 8d ff ff ff       	call   800999 <fsipc>
}
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    

00800a0e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a24:	b8 06 00 00 00       	mov    $0x6,%eax
  800a29:	e8 6b ff ff ff       	call   800999 <fsipc>
}
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	53                   	push   %ebx
  800a34:	83 ec 04             	sub    $0x4,%esp
  800a37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a40:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800a4f:	e8 45 ff ff ff       	call   800999 <fsipc>
  800a54:	85 c0                	test   %eax,%eax
  800a56:	78 2c                	js     800a84 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	68 00 50 80 00       	push   $0x805000
  800a60:	53                   	push   %ebx
  800a61:	e8 26 11 00 00       	call   801b8c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a66:	a1 80 50 80 00       	mov    0x805080,%eax
  800a6b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a71:	a1 84 50 80 00       	mov    0x805084,%eax
  800a76:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a7c:	83 c4 10             	add    $0x10,%esp
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a87:	c9                   	leave  
  800a88:	c3                   	ret    

00800a89 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	83 ec 0c             	sub    $0xc,%esp
  800a8f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a92:	8b 55 08             	mov    0x8(%ebp),%edx
  800a95:	8b 52 0c             	mov    0xc(%edx),%edx
  800a98:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a9e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800aa3:	50                   	push   %eax
  800aa4:	ff 75 0c             	pushl  0xc(%ebp)
  800aa7:	68 08 50 80 00       	push   $0x805008
  800aac:	e8 6d 12 00 00       	call   801d1e <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800ab1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab6:	b8 04 00 00 00       	mov    $0x4,%eax
  800abb:	e8 d9 fe ff ff       	call   800999 <fsipc>

}
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
  800acd:	8b 40 0c             	mov    0xc(%eax),%eax
  800ad0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ad5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800adb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae5:	e8 af fe ff ff       	call   800999 <fsipc>
  800aea:	89 c3                	mov    %eax,%ebx
  800aec:	85 c0                	test   %eax,%eax
  800aee:	78 4b                	js     800b3b <devfile_read+0x79>
		return r;
	assert(r <= n);
  800af0:	39 c6                	cmp    %eax,%esi
  800af2:	73 16                	jae    800b0a <devfile_read+0x48>
  800af4:	68 68 23 80 00       	push   $0x802368
  800af9:	68 6f 23 80 00       	push   $0x80236f
  800afe:	6a 7c                	push   $0x7c
  800b00:	68 84 23 80 00       	push   $0x802384
  800b05:	e8 24 0a 00 00       	call   80152e <_panic>
	assert(r <= PGSIZE);
  800b0a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b0f:	7e 16                	jle    800b27 <devfile_read+0x65>
  800b11:	68 8f 23 80 00       	push   $0x80238f
  800b16:	68 6f 23 80 00       	push   $0x80236f
  800b1b:	6a 7d                	push   $0x7d
  800b1d:	68 84 23 80 00       	push   $0x802384
  800b22:	e8 07 0a 00 00       	call   80152e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b27:	83 ec 04             	sub    $0x4,%esp
  800b2a:	50                   	push   %eax
  800b2b:	68 00 50 80 00       	push   $0x805000
  800b30:	ff 75 0c             	pushl  0xc(%ebp)
  800b33:	e8 e6 11 00 00       	call   801d1e <memmove>
	return r;
  800b38:	83 c4 10             	add    $0x10,%esp
}
  800b3b:	89 d8                	mov    %ebx,%eax
  800b3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	53                   	push   %ebx
  800b48:	83 ec 20             	sub    $0x20,%esp
  800b4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b4e:	53                   	push   %ebx
  800b4f:	e8 ff 0f 00 00       	call   801b53 <strlen>
  800b54:	83 c4 10             	add    $0x10,%esp
  800b57:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b5c:	7f 67                	jg     800bc5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b64:	50                   	push   %eax
  800b65:	e8 a7 f8 ff ff       	call   800411 <fd_alloc>
  800b6a:	83 c4 10             	add    $0x10,%esp
		return r;
  800b6d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	78 57                	js     800bca <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b73:	83 ec 08             	sub    $0x8,%esp
  800b76:	53                   	push   %ebx
  800b77:	68 00 50 80 00       	push   $0x805000
  800b7c:	e8 0b 10 00 00       	call   801b8c <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b84:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b89:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b91:	e8 03 fe ff ff       	call   800999 <fsipc>
  800b96:	89 c3                	mov    %eax,%ebx
  800b98:	83 c4 10             	add    $0x10,%esp
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	79 14                	jns    800bb3 <open+0x6f>
		fd_close(fd, 0);
  800b9f:	83 ec 08             	sub    $0x8,%esp
  800ba2:	6a 00                	push   $0x0
  800ba4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ba7:	e8 5d f9 ff ff       	call   800509 <fd_close>
		return r;
  800bac:	83 c4 10             	add    $0x10,%esp
  800baf:	89 da                	mov    %ebx,%edx
  800bb1:	eb 17                	jmp    800bca <open+0x86>
	}

	return fd2num(fd);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	ff 75 f4             	pushl  -0xc(%ebp)
  800bb9:	e8 2c f8 ff ff       	call   8003ea <fd2num>
  800bbe:	89 c2                	mov    %eax,%edx
  800bc0:	83 c4 10             	add    $0x10,%esp
  800bc3:	eb 05                	jmp    800bca <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bc5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bca:	89 d0                	mov    %edx,%eax
  800bcc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcf:	c9                   	leave  
  800bd0:	c3                   	ret    

00800bd1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 08 00 00 00       	mov    $0x8,%eax
  800be1:	e8 b3 fd ff ff       	call   800999 <fsipc>
}
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bee:	68 9b 23 80 00       	push   $0x80239b
  800bf3:	ff 75 0c             	pushl  0xc(%ebp)
  800bf6:	e8 91 0f 00 00       	call   801b8c <strcpy>
	return 0;
}
  800bfb:	b8 00 00 00 00       	mov    $0x0,%eax
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	53                   	push   %ebx
  800c06:	83 ec 10             	sub    $0x10,%esp
  800c09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c0c:	53                   	push   %ebx
  800c0d:	e8 b5 13 00 00       	call   801fc7 <pageref>
  800c12:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c1a:	83 f8 01             	cmp    $0x1,%eax
  800c1d:	75 10                	jne    800c2f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	ff 73 0c             	pushl  0xc(%ebx)
  800c25:	e8 c0 02 00 00       	call   800eea <nsipc_close>
  800c2a:	89 c2                	mov    %eax,%edx
  800c2c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c2f:	89 d0                	mov    %edx,%eax
  800c31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c3c:	6a 00                	push   $0x0
  800c3e:	ff 75 10             	pushl  0x10(%ebp)
  800c41:	ff 75 0c             	pushl  0xc(%ebp)
  800c44:	8b 45 08             	mov    0x8(%ebp),%eax
  800c47:	ff 70 0c             	pushl  0xc(%eax)
  800c4a:	e8 78 03 00 00       	call   800fc7 <nsipc_send>
}
  800c4f:	c9                   	leave  
  800c50:	c3                   	ret    

00800c51 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c57:	6a 00                	push   $0x0
  800c59:	ff 75 10             	pushl  0x10(%ebp)
  800c5c:	ff 75 0c             	pushl  0xc(%ebp)
  800c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c62:	ff 70 0c             	pushl  0xc(%eax)
  800c65:	e8 f1 02 00 00       	call   800f5b <nsipc_recv>
}
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c72:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c75:	52                   	push   %edx
  800c76:	50                   	push   %eax
  800c77:	e8 e4 f7 ff ff       	call   800460 <fd_lookup>
  800c7c:	83 c4 10             	add    $0x10,%esp
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	78 17                	js     800c9a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c86:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c8c:	39 08                	cmp    %ecx,(%eax)
  800c8e:	75 05                	jne    800c95 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c90:	8b 40 0c             	mov    0xc(%eax),%eax
  800c93:	eb 05                	jmp    800c9a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c95:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c9a:	c9                   	leave  
  800c9b:	c3                   	ret    

00800c9c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 1c             	sub    $0x1c,%esp
  800ca4:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800ca6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca9:	50                   	push   %eax
  800caa:	e8 62 f7 ff ff       	call   800411 <fd_alloc>
  800caf:	89 c3                	mov    %eax,%ebx
  800cb1:	83 c4 10             	add    $0x10,%esp
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	78 1b                	js     800cd3 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cb8:	83 ec 04             	sub    $0x4,%esp
  800cbb:	68 07 04 00 00       	push   $0x407
  800cc0:	ff 75 f4             	pushl  -0xc(%ebp)
  800cc3:	6a 00                	push   $0x0
  800cc5:	e8 8c f4 ff ff       	call   800156 <sys_page_alloc>
  800cca:	89 c3                	mov    %eax,%ebx
  800ccc:	83 c4 10             	add    $0x10,%esp
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	79 10                	jns    800ce3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	56                   	push   %esi
  800cd7:	e8 0e 02 00 00       	call   800eea <nsipc_close>
		return r;
  800cdc:	83 c4 10             	add    $0x10,%esp
  800cdf:	89 d8                	mov    %ebx,%eax
  800ce1:	eb 24                	jmp    800d07 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ce3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cec:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cf8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	50                   	push   %eax
  800cff:	e8 e6 f6 ff ff       	call   8003ea <fd2num>
  800d04:	83 c4 10             	add    $0x10,%esp
}
  800d07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d14:	8b 45 08             	mov    0x8(%ebp),%eax
  800d17:	e8 50 ff ff ff       	call   800c6c <fd2sockid>
		return r;
  800d1c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	78 1f                	js     800d41 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d22:	83 ec 04             	sub    $0x4,%esp
  800d25:	ff 75 10             	pushl  0x10(%ebp)
  800d28:	ff 75 0c             	pushl  0xc(%ebp)
  800d2b:	50                   	push   %eax
  800d2c:	e8 12 01 00 00       	call   800e43 <nsipc_accept>
  800d31:	83 c4 10             	add    $0x10,%esp
		return r;
  800d34:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	78 07                	js     800d41 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d3a:	e8 5d ff ff ff       	call   800c9c <alloc_sockfd>
  800d3f:	89 c1                	mov    %eax,%ecx
}
  800d41:	89 c8                	mov    %ecx,%eax
  800d43:	c9                   	leave  
  800d44:	c3                   	ret    

00800d45 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4e:	e8 19 ff ff ff       	call   800c6c <fd2sockid>
  800d53:	85 c0                	test   %eax,%eax
  800d55:	78 12                	js     800d69 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d57:	83 ec 04             	sub    $0x4,%esp
  800d5a:	ff 75 10             	pushl  0x10(%ebp)
  800d5d:	ff 75 0c             	pushl  0xc(%ebp)
  800d60:	50                   	push   %eax
  800d61:	e8 2d 01 00 00       	call   800e93 <nsipc_bind>
  800d66:	83 c4 10             	add    $0x10,%esp
}
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    

00800d6b <shutdown>:

int
shutdown(int s, int how)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
  800d74:	e8 f3 fe ff ff       	call   800c6c <fd2sockid>
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	78 0f                	js     800d8c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d7d:	83 ec 08             	sub    $0x8,%esp
  800d80:	ff 75 0c             	pushl  0xc(%ebp)
  800d83:	50                   	push   %eax
  800d84:	e8 3f 01 00 00       	call   800ec8 <nsipc_shutdown>
  800d89:	83 c4 10             	add    $0x10,%esp
}
  800d8c:	c9                   	leave  
  800d8d:	c3                   	ret    

00800d8e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d94:	8b 45 08             	mov    0x8(%ebp),%eax
  800d97:	e8 d0 fe ff ff       	call   800c6c <fd2sockid>
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	78 12                	js     800db2 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800da0:	83 ec 04             	sub    $0x4,%esp
  800da3:	ff 75 10             	pushl  0x10(%ebp)
  800da6:	ff 75 0c             	pushl  0xc(%ebp)
  800da9:	50                   	push   %eax
  800daa:	e8 55 01 00 00       	call   800f04 <nsipc_connect>
  800daf:	83 c4 10             	add    $0x10,%esp
}
  800db2:	c9                   	leave  
  800db3:	c3                   	ret    

00800db4 <listen>:

int
listen(int s, int backlog)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dba:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbd:	e8 aa fe ff ff       	call   800c6c <fd2sockid>
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	78 0f                	js     800dd5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800dc6:	83 ec 08             	sub    $0x8,%esp
  800dc9:	ff 75 0c             	pushl  0xc(%ebp)
  800dcc:	50                   	push   %eax
  800dcd:	e8 67 01 00 00       	call   800f39 <nsipc_listen>
  800dd2:	83 c4 10             	add    $0x10,%esp
}
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    

00800dd7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800ddd:	ff 75 10             	pushl  0x10(%ebp)
  800de0:	ff 75 0c             	pushl  0xc(%ebp)
  800de3:	ff 75 08             	pushl  0x8(%ebp)
  800de6:	e8 3a 02 00 00       	call   801025 <nsipc_socket>
  800deb:	83 c4 10             	add    $0x10,%esp
  800dee:	85 c0                	test   %eax,%eax
  800df0:	78 05                	js     800df7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800df2:	e8 a5 fe ff ff       	call   800c9c <alloc_sockfd>
}
  800df7:	c9                   	leave  
  800df8:	c3                   	ret    

00800df9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 04             	sub    $0x4,%esp
  800e00:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e02:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e09:	75 12                	jne    800e1d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	6a 02                	push   $0x2
  800e10:	e8 79 11 00 00       	call   801f8e <ipc_find_env>
  800e15:	a3 04 40 80 00       	mov    %eax,0x804004
  800e1a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e1d:	6a 07                	push   $0x7
  800e1f:	68 00 60 80 00       	push   $0x806000
  800e24:	53                   	push   %ebx
  800e25:	ff 35 04 40 80 00    	pushl  0x804004
  800e2b:	e8 0a 11 00 00       	call   801f3a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e30:	83 c4 0c             	add    $0xc,%esp
  800e33:	6a 00                	push   $0x0
  800e35:	6a 00                	push   $0x0
  800e37:	6a 00                	push   $0x0
  800e39:	e8 95 10 00 00       	call   801ed3 <ipc_recv>
}
  800e3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e41:	c9                   	leave  
  800e42:	c3                   	ret    

00800e43 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e53:	8b 06                	mov    (%esi),%eax
  800e55:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5f:	e8 95 ff ff ff       	call   800df9 <nsipc>
  800e64:	89 c3                	mov    %eax,%ebx
  800e66:	85 c0                	test   %eax,%eax
  800e68:	78 20                	js     800e8a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e6a:	83 ec 04             	sub    $0x4,%esp
  800e6d:	ff 35 10 60 80 00    	pushl  0x806010
  800e73:	68 00 60 80 00       	push   $0x806000
  800e78:	ff 75 0c             	pushl  0xc(%ebp)
  800e7b:	e8 9e 0e 00 00       	call   801d1e <memmove>
		*addrlen = ret->ret_addrlen;
  800e80:	a1 10 60 80 00       	mov    0x806010,%eax
  800e85:	89 06                	mov    %eax,(%esi)
  800e87:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e8a:	89 d8                	mov    %ebx,%eax
  800e8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8f:	5b                   	pop    %ebx
  800e90:	5e                   	pop    %esi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	53                   	push   %ebx
  800e97:	83 ec 08             	sub    $0x8,%esp
  800e9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ea5:	53                   	push   %ebx
  800ea6:	ff 75 0c             	pushl  0xc(%ebp)
  800ea9:	68 04 60 80 00       	push   $0x806004
  800eae:	e8 6b 0e 00 00       	call   801d1e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800eb3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800eb9:	b8 02 00 00 00       	mov    $0x2,%eax
  800ebe:	e8 36 ff ff ff       	call   800df9 <nsipc>
}
  800ec3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec6:	c9                   	leave  
  800ec7:	c3                   	ret    

00800ec8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800ece:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ede:	b8 03 00 00 00       	mov    $0x3,%eax
  800ee3:	e8 11 ff ff ff       	call   800df9 <nsipc>
}
  800ee8:	c9                   	leave  
  800ee9:	c3                   	ret    

00800eea <nsipc_close>:

int
nsipc_close(int s)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ef0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef3:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ef8:	b8 04 00 00 00       	mov    $0x4,%eax
  800efd:	e8 f7 fe ff ff       	call   800df9 <nsipc>
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	53                   	push   %ebx
  800f08:	83 ec 08             	sub    $0x8,%esp
  800f0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f11:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f16:	53                   	push   %ebx
  800f17:	ff 75 0c             	pushl  0xc(%ebp)
  800f1a:	68 04 60 80 00       	push   $0x806004
  800f1f:	e8 fa 0d 00 00       	call   801d1e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f24:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f2a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f2f:	e8 c5 fe ff ff       	call   800df9 <nsipc>
}
  800f34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f37:	c9                   	leave  
  800f38:	c3                   	ret    

00800f39 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f42:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f4f:	b8 06 00 00 00       	mov    $0x6,%eax
  800f54:	e8 a0 fe ff ff       	call   800df9 <nsipc>
}
  800f59:	c9                   	leave  
  800f5a:	c3                   	ret    

00800f5b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
  800f60:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f63:	8b 45 08             	mov    0x8(%ebp),%eax
  800f66:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f6b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f71:	8b 45 14             	mov    0x14(%ebp),%eax
  800f74:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f79:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7e:	e8 76 fe ff ff       	call   800df9 <nsipc>
  800f83:	89 c3                	mov    %eax,%ebx
  800f85:	85 c0                	test   %eax,%eax
  800f87:	78 35                	js     800fbe <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f89:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f8e:	7f 04                	jg     800f94 <nsipc_recv+0x39>
  800f90:	39 c6                	cmp    %eax,%esi
  800f92:	7d 16                	jge    800faa <nsipc_recv+0x4f>
  800f94:	68 a7 23 80 00       	push   $0x8023a7
  800f99:	68 6f 23 80 00       	push   $0x80236f
  800f9e:	6a 62                	push   $0x62
  800fa0:	68 bc 23 80 00       	push   $0x8023bc
  800fa5:	e8 84 05 00 00       	call   80152e <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800faa:	83 ec 04             	sub    $0x4,%esp
  800fad:	50                   	push   %eax
  800fae:	68 00 60 80 00       	push   $0x806000
  800fb3:	ff 75 0c             	pushl  0xc(%ebp)
  800fb6:	e8 63 0d 00 00       	call   801d1e <memmove>
  800fbb:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800fbe:	89 d8                	mov    %ebx,%eax
  800fc0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc3:	5b                   	pop    %ebx
  800fc4:	5e                   	pop    %esi
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	53                   	push   %ebx
  800fcb:	83 ec 04             	sub    $0x4,%esp
  800fce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fd9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fdf:	7e 16                	jle    800ff7 <nsipc_send+0x30>
  800fe1:	68 c8 23 80 00       	push   $0x8023c8
  800fe6:	68 6f 23 80 00       	push   $0x80236f
  800feb:	6a 6d                	push   $0x6d
  800fed:	68 bc 23 80 00       	push   $0x8023bc
  800ff2:	e8 37 05 00 00       	call   80152e <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	53                   	push   %ebx
  800ffb:	ff 75 0c             	pushl  0xc(%ebp)
  800ffe:	68 0c 60 80 00       	push   $0x80600c
  801003:	e8 16 0d 00 00       	call   801d1e <memmove>
	nsipcbuf.send.req_size = size;
  801008:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80100e:	8b 45 14             	mov    0x14(%ebp),%eax
  801011:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801016:	b8 08 00 00 00       	mov    $0x8,%eax
  80101b:	e8 d9 fd ff ff       	call   800df9 <nsipc>
}
  801020:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801023:	c9                   	leave  
  801024:	c3                   	ret    

00801025 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80102b:	8b 45 08             	mov    0x8(%ebp),%eax
  80102e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801033:	8b 45 0c             	mov    0xc(%ebp),%eax
  801036:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80103b:	8b 45 10             	mov    0x10(%ebp),%eax
  80103e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801043:	b8 09 00 00 00       	mov    $0x9,%eax
  801048:	e8 ac fd ff ff       	call   800df9 <nsipc>
}
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	ff 75 08             	pushl  0x8(%ebp)
  80105d:	e8 98 f3 ff ff       	call   8003fa <fd2data>
  801062:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801064:	83 c4 08             	add    $0x8,%esp
  801067:	68 d4 23 80 00       	push   $0x8023d4
  80106c:	53                   	push   %ebx
  80106d:	e8 1a 0b 00 00       	call   801b8c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801072:	8b 46 04             	mov    0x4(%esi),%eax
  801075:	2b 06                	sub    (%esi),%eax
  801077:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80107d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801084:	00 00 00 
	stat->st_dev = &devpipe;
  801087:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80108e:	30 80 00 
	return 0;
}
  801091:	b8 00 00 00 00       	mov    $0x0,%eax
  801096:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801099:	5b                   	pop    %ebx
  80109a:	5e                   	pop    %esi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    

0080109d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 0c             	sub    $0xc,%esp
  8010a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010a7:	53                   	push   %ebx
  8010a8:	6a 00                	push   $0x0
  8010aa:	e8 2c f1 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010af:	89 1c 24             	mov    %ebx,(%esp)
  8010b2:	e8 43 f3 ff ff       	call   8003fa <fd2data>
  8010b7:	83 c4 08             	add    $0x8,%esp
  8010ba:	50                   	push   %eax
  8010bb:	6a 00                	push   $0x0
  8010bd:	e8 19 f1 ff ff       	call   8001db <sys_page_unmap>
}
  8010c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c5:	c9                   	leave  
  8010c6:	c3                   	ret    

008010c7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	57                   	push   %edi
  8010cb:	56                   	push   %esi
  8010cc:	53                   	push   %ebx
  8010cd:	83 ec 1c             	sub    $0x1c,%esp
  8010d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010d3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010d5:	a1 08 40 80 00       	mov    0x804008,%eax
  8010da:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010dd:	83 ec 0c             	sub    $0xc,%esp
  8010e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8010e3:	e8 df 0e 00 00       	call   801fc7 <pageref>
  8010e8:	89 c3                	mov    %eax,%ebx
  8010ea:	89 3c 24             	mov    %edi,(%esp)
  8010ed:	e8 d5 0e 00 00       	call   801fc7 <pageref>
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	39 c3                	cmp    %eax,%ebx
  8010f7:	0f 94 c1             	sete   %cl
  8010fa:	0f b6 c9             	movzbl %cl,%ecx
  8010fd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801100:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801106:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801109:	39 ce                	cmp    %ecx,%esi
  80110b:	74 1b                	je     801128 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80110d:	39 c3                	cmp    %eax,%ebx
  80110f:	75 c4                	jne    8010d5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801111:	8b 42 58             	mov    0x58(%edx),%eax
  801114:	ff 75 e4             	pushl  -0x1c(%ebp)
  801117:	50                   	push   %eax
  801118:	56                   	push   %esi
  801119:	68 db 23 80 00       	push   $0x8023db
  80111e:	e8 e4 04 00 00       	call   801607 <cprintf>
  801123:	83 c4 10             	add    $0x10,%esp
  801126:	eb ad                	jmp    8010d5 <_pipeisclosed+0xe>
	}
}
  801128:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80112b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 28             	sub    $0x28,%esp
  80113c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80113f:	56                   	push   %esi
  801140:	e8 b5 f2 ff ff       	call   8003fa <fd2data>
  801145:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	bf 00 00 00 00       	mov    $0x0,%edi
  80114f:	eb 4b                	jmp    80119c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801151:	89 da                	mov    %ebx,%edx
  801153:	89 f0                	mov    %esi,%eax
  801155:	e8 6d ff ff ff       	call   8010c7 <_pipeisclosed>
  80115a:	85 c0                	test   %eax,%eax
  80115c:	75 48                	jne    8011a6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80115e:	e8 d4 ef ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801163:	8b 43 04             	mov    0x4(%ebx),%eax
  801166:	8b 0b                	mov    (%ebx),%ecx
  801168:	8d 51 20             	lea    0x20(%ecx),%edx
  80116b:	39 d0                	cmp    %edx,%eax
  80116d:	73 e2                	jae    801151 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80116f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801172:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801176:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801179:	89 c2                	mov    %eax,%edx
  80117b:	c1 fa 1f             	sar    $0x1f,%edx
  80117e:	89 d1                	mov    %edx,%ecx
  801180:	c1 e9 1b             	shr    $0x1b,%ecx
  801183:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801186:	83 e2 1f             	and    $0x1f,%edx
  801189:	29 ca                	sub    %ecx,%edx
  80118b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80118f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801193:	83 c0 01             	add    $0x1,%eax
  801196:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801199:	83 c7 01             	add    $0x1,%edi
  80119c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80119f:	75 c2                	jne    801163 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a4:	eb 05                	jmp    8011ab <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011a6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ae:	5b                   	pop    %ebx
  8011af:	5e                   	pop    %esi
  8011b0:	5f                   	pop    %edi
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    

008011b3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	57                   	push   %edi
  8011b7:	56                   	push   %esi
  8011b8:	53                   	push   %ebx
  8011b9:	83 ec 18             	sub    $0x18,%esp
  8011bc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011bf:	57                   	push   %edi
  8011c0:	e8 35 f2 ff ff       	call   8003fa <fd2data>
  8011c5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cf:	eb 3d                	jmp    80120e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011d1:	85 db                	test   %ebx,%ebx
  8011d3:	74 04                	je     8011d9 <devpipe_read+0x26>
				return i;
  8011d5:	89 d8                	mov    %ebx,%eax
  8011d7:	eb 44                	jmp    80121d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011d9:	89 f2                	mov    %esi,%edx
  8011db:	89 f8                	mov    %edi,%eax
  8011dd:	e8 e5 fe ff ff       	call   8010c7 <_pipeisclosed>
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	75 32                	jne    801218 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011e6:	e8 4c ef ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011eb:	8b 06                	mov    (%esi),%eax
  8011ed:	3b 46 04             	cmp    0x4(%esi),%eax
  8011f0:	74 df                	je     8011d1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011f2:	99                   	cltd   
  8011f3:	c1 ea 1b             	shr    $0x1b,%edx
  8011f6:	01 d0                	add    %edx,%eax
  8011f8:	83 e0 1f             	and    $0x1f,%eax
  8011fb:	29 d0                	sub    %edx,%eax
  8011fd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801205:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801208:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80120b:	83 c3 01             	add    $0x1,%ebx
  80120e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801211:	75 d8                	jne    8011eb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801213:	8b 45 10             	mov    0x10(%ebp),%eax
  801216:	eb 05                	jmp    80121d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801218:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80121d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801220:	5b                   	pop    %ebx
  801221:	5e                   	pop    %esi
  801222:	5f                   	pop    %edi
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	56                   	push   %esi
  801229:	53                   	push   %ebx
  80122a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80122d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801230:	50                   	push   %eax
  801231:	e8 db f1 ff ff       	call   800411 <fd_alloc>
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	89 c2                	mov    %eax,%edx
  80123b:	85 c0                	test   %eax,%eax
  80123d:	0f 88 2c 01 00 00    	js     80136f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801243:	83 ec 04             	sub    $0x4,%esp
  801246:	68 07 04 00 00       	push   $0x407
  80124b:	ff 75 f4             	pushl  -0xc(%ebp)
  80124e:	6a 00                	push   $0x0
  801250:	e8 01 ef ff ff       	call   800156 <sys_page_alloc>
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	89 c2                	mov    %eax,%edx
  80125a:	85 c0                	test   %eax,%eax
  80125c:	0f 88 0d 01 00 00    	js     80136f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801262:	83 ec 0c             	sub    $0xc,%esp
  801265:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801268:	50                   	push   %eax
  801269:	e8 a3 f1 ff ff       	call   800411 <fd_alloc>
  80126e:	89 c3                	mov    %eax,%ebx
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	85 c0                	test   %eax,%eax
  801275:	0f 88 e2 00 00 00    	js     80135d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	68 07 04 00 00       	push   $0x407
  801283:	ff 75 f0             	pushl  -0x10(%ebp)
  801286:	6a 00                	push   $0x0
  801288:	e8 c9 ee ff ff       	call   800156 <sys_page_alloc>
  80128d:	89 c3                	mov    %eax,%ebx
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	0f 88 c3 00 00 00    	js     80135d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80129a:	83 ec 0c             	sub    $0xc,%esp
  80129d:	ff 75 f4             	pushl  -0xc(%ebp)
  8012a0:	e8 55 f1 ff ff       	call   8003fa <fd2data>
  8012a5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012a7:	83 c4 0c             	add    $0xc,%esp
  8012aa:	68 07 04 00 00       	push   $0x407
  8012af:	50                   	push   %eax
  8012b0:	6a 00                	push   $0x0
  8012b2:	e8 9f ee ff ff       	call   800156 <sys_page_alloc>
  8012b7:	89 c3                	mov    %eax,%ebx
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	0f 88 89 00 00 00    	js     80134d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012c4:	83 ec 0c             	sub    $0xc,%esp
  8012c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ca:	e8 2b f1 ff ff       	call   8003fa <fd2data>
  8012cf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012d6:	50                   	push   %eax
  8012d7:	6a 00                	push   $0x0
  8012d9:	56                   	push   %esi
  8012da:	6a 00                	push   $0x0
  8012dc:	e8 b8 ee ff ff       	call   800199 <sys_page_map>
  8012e1:	89 c3                	mov    %eax,%ebx
  8012e3:	83 c4 20             	add    $0x20,%esp
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	78 55                	js     80133f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012ea:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012ff:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801305:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801308:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80130a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801314:	83 ec 0c             	sub    $0xc,%esp
  801317:	ff 75 f4             	pushl  -0xc(%ebp)
  80131a:	e8 cb f0 ff ff       	call   8003ea <fd2num>
  80131f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801322:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801324:	83 c4 04             	add    $0x4,%esp
  801327:	ff 75 f0             	pushl  -0x10(%ebp)
  80132a:	e8 bb f0 ff ff       	call   8003ea <fd2num>
  80132f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801332:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	ba 00 00 00 00       	mov    $0x0,%edx
  80133d:	eb 30                	jmp    80136f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80133f:	83 ec 08             	sub    $0x8,%esp
  801342:	56                   	push   %esi
  801343:	6a 00                	push   $0x0
  801345:	e8 91 ee ff ff       	call   8001db <sys_page_unmap>
  80134a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	ff 75 f0             	pushl  -0x10(%ebp)
  801353:	6a 00                	push   $0x0
  801355:	e8 81 ee ff ff       	call   8001db <sys_page_unmap>
  80135a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	ff 75 f4             	pushl  -0xc(%ebp)
  801363:	6a 00                	push   $0x0
  801365:	e8 71 ee ff ff       	call   8001db <sys_page_unmap>
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80136f:	89 d0                	mov    %edx,%eax
  801371:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801374:	5b                   	pop    %ebx
  801375:	5e                   	pop    %esi
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    

00801378 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801381:	50                   	push   %eax
  801382:	ff 75 08             	pushl  0x8(%ebp)
  801385:	e8 d6 f0 ff ff       	call   800460 <fd_lookup>
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 18                	js     8013a9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801391:	83 ec 0c             	sub    $0xc,%esp
  801394:	ff 75 f4             	pushl  -0xc(%ebp)
  801397:	e8 5e f0 ff ff       	call   8003fa <fd2data>
	return _pipeisclosed(fd, p);
  80139c:	89 c2                	mov    %eax,%edx
  80139e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a1:	e8 21 fd ff ff       	call   8010c7 <_pipeisclosed>
  8013a6:	83 c4 10             	add    $0x10,%esp
}
  8013a9:	c9                   	leave  
  8013aa:	c3                   	ret    

008013ab <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    

008013b5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013bb:	68 f3 23 80 00       	push   $0x8023f3
  8013c0:	ff 75 0c             	pushl  0xc(%ebp)
  8013c3:	e8 c4 07 00 00       	call   801b8c <strcpy>
	return 0;
}
  8013c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013cd:	c9                   	leave  
  8013ce:	c3                   	ret    

008013cf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	57                   	push   %edi
  8013d3:	56                   	push   %esi
  8013d4:	53                   	push   %ebx
  8013d5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013db:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013e0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013e6:	eb 2d                	jmp    801415 <devcons_write+0x46>
		m = n - tot;
  8013e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013eb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013ed:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013f0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013f5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013f8:	83 ec 04             	sub    $0x4,%esp
  8013fb:	53                   	push   %ebx
  8013fc:	03 45 0c             	add    0xc(%ebp),%eax
  8013ff:	50                   	push   %eax
  801400:	57                   	push   %edi
  801401:	e8 18 09 00 00       	call   801d1e <memmove>
		sys_cputs(buf, m);
  801406:	83 c4 08             	add    $0x8,%esp
  801409:	53                   	push   %ebx
  80140a:	57                   	push   %edi
  80140b:	e8 8a ec ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801410:	01 de                	add    %ebx,%esi
  801412:	83 c4 10             	add    $0x10,%esp
  801415:	89 f0                	mov    %esi,%eax
  801417:	3b 75 10             	cmp    0x10(%ebp),%esi
  80141a:	72 cc                	jb     8013e8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80141c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141f:	5b                   	pop    %ebx
  801420:	5e                   	pop    %esi
  801421:	5f                   	pop    %edi
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80142f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801433:	74 2a                	je     80145f <devcons_read+0x3b>
  801435:	eb 05                	jmp    80143c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801437:	e8 fb ec ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80143c:	e8 77 ec ff ff       	call   8000b8 <sys_cgetc>
  801441:	85 c0                	test   %eax,%eax
  801443:	74 f2                	je     801437 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801445:	85 c0                	test   %eax,%eax
  801447:	78 16                	js     80145f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801449:	83 f8 04             	cmp    $0x4,%eax
  80144c:	74 0c                	je     80145a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80144e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801451:	88 02                	mov    %al,(%edx)
	return 1;
  801453:	b8 01 00 00 00       	mov    $0x1,%eax
  801458:	eb 05                	jmp    80145f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80145a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80145f:	c9                   	leave  
  801460:	c3                   	ret    

00801461 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801467:	8b 45 08             	mov    0x8(%ebp),%eax
  80146a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80146d:	6a 01                	push   $0x1
  80146f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801472:	50                   	push   %eax
  801473:	e8 22 ec ff ff       	call   80009a <sys_cputs>
}
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <getchar>:

int
getchar(void)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801483:	6a 01                	push   $0x1
  801485:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801488:	50                   	push   %eax
  801489:	6a 00                	push   $0x0
  80148b:	e8 36 f2 ff ff       	call   8006c6 <read>
	if (r < 0)
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	85 c0                	test   %eax,%eax
  801495:	78 0f                	js     8014a6 <getchar+0x29>
		return r;
	if (r < 1)
  801497:	85 c0                	test   %eax,%eax
  801499:	7e 06                	jle    8014a1 <getchar+0x24>
		return -E_EOF;
	return c;
  80149b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80149f:	eb 05                	jmp    8014a6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014a1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014a6:	c9                   	leave  
  8014a7:	c3                   	ret    

008014a8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b1:	50                   	push   %eax
  8014b2:	ff 75 08             	pushl  0x8(%ebp)
  8014b5:	e8 a6 ef ff ff       	call   800460 <fd_lookup>
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 11                	js     8014d2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014ca:	39 10                	cmp    %edx,(%eax)
  8014cc:	0f 94 c0             	sete   %al
  8014cf:	0f b6 c0             	movzbl %al,%eax
}
  8014d2:	c9                   	leave  
  8014d3:	c3                   	ret    

008014d4 <opencons>:

int
opencons(void)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dd:	50                   	push   %eax
  8014de:	e8 2e ef ff ff       	call   800411 <fd_alloc>
  8014e3:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 3e                	js     80152a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ec:	83 ec 04             	sub    $0x4,%esp
  8014ef:	68 07 04 00 00       	push   $0x407
  8014f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f7:	6a 00                	push   $0x0
  8014f9:	e8 58 ec ff ff       	call   800156 <sys_page_alloc>
  8014fe:	83 c4 10             	add    $0x10,%esp
		return r;
  801501:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801503:	85 c0                	test   %eax,%eax
  801505:	78 23                	js     80152a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801507:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80150d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801510:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801512:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801515:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80151c:	83 ec 0c             	sub    $0xc,%esp
  80151f:	50                   	push   %eax
  801520:	e8 c5 ee ff ff       	call   8003ea <fd2num>
  801525:	89 c2                	mov    %eax,%edx
  801527:	83 c4 10             	add    $0x10,%esp
}
  80152a:	89 d0                	mov    %edx,%eax
  80152c:	c9                   	leave  
  80152d:	c3                   	ret    

0080152e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	56                   	push   %esi
  801532:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801533:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801536:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80153c:	e8 d7 eb ff ff       	call   800118 <sys_getenvid>
  801541:	83 ec 0c             	sub    $0xc,%esp
  801544:	ff 75 0c             	pushl  0xc(%ebp)
  801547:	ff 75 08             	pushl  0x8(%ebp)
  80154a:	56                   	push   %esi
  80154b:	50                   	push   %eax
  80154c:	68 00 24 80 00       	push   $0x802400
  801551:	e8 b1 00 00 00       	call   801607 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801556:	83 c4 18             	add    $0x18,%esp
  801559:	53                   	push   %ebx
  80155a:	ff 75 10             	pushl  0x10(%ebp)
  80155d:	e8 54 00 00 00       	call   8015b6 <vcprintf>
	cprintf("\n");
  801562:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  801569:	e8 99 00 00 00       	call   801607 <cprintf>
  80156e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801571:	cc                   	int3   
  801572:	eb fd                	jmp    801571 <_panic+0x43>

00801574 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	53                   	push   %ebx
  801578:	83 ec 04             	sub    $0x4,%esp
  80157b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80157e:	8b 13                	mov    (%ebx),%edx
  801580:	8d 42 01             	lea    0x1(%edx),%eax
  801583:	89 03                	mov    %eax,(%ebx)
  801585:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801588:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80158c:	3d ff 00 00 00       	cmp    $0xff,%eax
  801591:	75 1a                	jne    8015ad <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801593:	83 ec 08             	sub    $0x8,%esp
  801596:	68 ff 00 00 00       	push   $0xff
  80159b:	8d 43 08             	lea    0x8(%ebx),%eax
  80159e:	50                   	push   %eax
  80159f:	e8 f6 ea ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8015a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015aa:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015ad:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    

008015b6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015c6:	00 00 00 
	b.cnt = 0;
  8015c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015d3:	ff 75 0c             	pushl  0xc(%ebp)
  8015d6:	ff 75 08             	pushl  0x8(%ebp)
  8015d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015df:	50                   	push   %eax
  8015e0:	68 74 15 80 00       	push   $0x801574
  8015e5:	e8 54 01 00 00       	call   80173e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015ea:	83 c4 08             	add    $0x8,%esp
  8015ed:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	e8 9b ea ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8015ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801605:	c9                   	leave  
  801606:	c3                   	ret    

00801607 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80160d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801610:	50                   	push   %eax
  801611:	ff 75 08             	pushl  0x8(%ebp)
  801614:	e8 9d ff ff ff       	call   8015b6 <vcprintf>
	va_end(ap);

	return cnt;
}
  801619:	c9                   	leave  
  80161a:	c3                   	ret    

0080161b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	57                   	push   %edi
  80161f:	56                   	push   %esi
  801620:	53                   	push   %ebx
  801621:	83 ec 1c             	sub    $0x1c,%esp
  801624:	89 c7                	mov    %eax,%edi
  801626:	89 d6                	mov    %edx,%esi
  801628:	8b 45 08             	mov    0x8(%ebp),%eax
  80162b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80162e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801631:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801634:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801637:	bb 00 00 00 00       	mov    $0x0,%ebx
  80163c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80163f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801642:	39 d3                	cmp    %edx,%ebx
  801644:	72 05                	jb     80164b <printnum+0x30>
  801646:	39 45 10             	cmp    %eax,0x10(%ebp)
  801649:	77 45                	ja     801690 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80164b:	83 ec 0c             	sub    $0xc,%esp
  80164e:	ff 75 18             	pushl  0x18(%ebp)
  801651:	8b 45 14             	mov    0x14(%ebp),%eax
  801654:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801657:	53                   	push   %ebx
  801658:	ff 75 10             	pushl  0x10(%ebp)
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801661:	ff 75 e0             	pushl  -0x20(%ebp)
  801664:	ff 75 dc             	pushl  -0x24(%ebp)
  801667:	ff 75 d8             	pushl  -0x28(%ebp)
  80166a:	e8 a1 09 00 00       	call   802010 <__udivdi3>
  80166f:	83 c4 18             	add    $0x18,%esp
  801672:	52                   	push   %edx
  801673:	50                   	push   %eax
  801674:	89 f2                	mov    %esi,%edx
  801676:	89 f8                	mov    %edi,%eax
  801678:	e8 9e ff ff ff       	call   80161b <printnum>
  80167d:	83 c4 20             	add    $0x20,%esp
  801680:	eb 18                	jmp    80169a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801682:	83 ec 08             	sub    $0x8,%esp
  801685:	56                   	push   %esi
  801686:	ff 75 18             	pushl  0x18(%ebp)
  801689:	ff d7                	call   *%edi
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	eb 03                	jmp    801693 <printnum+0x78>
  801690:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801693:	83 eb 01             	sub    $0x1,%ebx
  801696:	85 db                	test   %ebx,%ebx
  801698:	7f e8                	jg     801682 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80169a:	83 ec 08             	sub    $0x8,%esp
  80169d:	56                   	push   %esi
  80169e:	83 ec 04             	sub    $0x4,%esp
  8016a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a7:	ff 75 dc             	pushl  -0x24(%ebp)
  8016aa:	ff 75 d8             	pushl  -0x28(%ebp)
  8016ad:	e8 8e 0a 00 00       	call   802140 <__umoddi3>
  8016b2:	83 c4 14             	add    $0x14,%esp
  8016b5:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
  8016bc:	50                   	push   %eax
  8016bd:	ff d7                	call   *%edi
}
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c5:	5b                   	pop    %ebx
  8016c6:	5e                   	pop    %esi
  8016c7:	5f                   	pop    %edi
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016cd:	83 fa 01             	cmp    $0x1,%edx
  8016d0:	7e 0e                	jle    8016e0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016d2:	8b 10                	mov    (%eax),%edx
  8016d4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016d7:	89 08                	mov    %ecx,(%eax)
  8016d9:	8b 02                	mov    (%edx),%eax
  8016db:	8b 52 04             	mov    0x4(%edx),%edx
  8016de:	eb 22                	jmp    801702 <getuint+0x38>
	else if (lflag)
  8016e0:	85 d2                	test   %edx,%edx
  8016e2:	74 10                	je     8016f4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016e4:	8b 10                	mov    (%eax),%edx
  8016e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016e9:	89 08                	mov    %ecx,(%eax)
  8016eb:	8b 02                	mov    (%edx),%eax
  8016ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f2:	eb 0e                	jmp    801702 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016f4:	8b 10                	mov    (%eax),%edx
  8016f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016f9:	89 08                	mov    %ecx,(%eax)
  8016fb:	8b 02                	mov    (%edx),%eax
  8016fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801702:	5d                   	pop    %ebp
  801703:	c3                   	ret    

00801704 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80170a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80170e:	8b 10                	mov    (%eax),%edx
  801710:	3b 50 04             	cmp    0x4(%eax),%edx
  801713:	73 0a                	jae    80171f <sprintputch+0x1b>
		*b->buf++ = ch;
  801715:	8d 4a 01             	lea    0x1(%edx),%ecx
  801718:	89 08                	mov    %ecx,(%eax)
  80171a:	8b 45 08             	mov    0x8(%ebp),%eax
  80171d:	88 02                	mov    %al,(%edx)
}
  80171f:	5d                   	pop    %ebp
  801720:	c3                   	ret    

00801721 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801727:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80172a:	50                   	push   %eax
  80172b:	ff 75 10             	pushl  0x10(%ebp)
  80172e:	ff 75 0c             	pushl  0xc(%ebp)
  801731:	ff 75 08             	pushl  0x8(%ebp)
  801734:	e8 05 00 00 00       	call   80173e <vprintfmt>
	va_end(ap);
}
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	57                   	push   %edi
  801742:	56                   	push   %esi
  801743:	53                   	push   %ebx
  801744:	83 ec 2c             	sub    $0x2c,%esp
  801747:	8b 75 08             	mov    0x8(%ebp),%esi
  80174a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80174d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801750:	eb 12                	jmp    801764 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801752:	85 c0                	test   %eax,%eax
  801754:	0f 84 89 03 00 00    	je     801ae3 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80175a:	83 ec 08             	sub    $0x8,%esp
  80175d:	53                   	push   %ebx
  80175e:	50                   	push   %eax
  80175f:	ff d6                	call   *%esi
  801761:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801764:	83 c7 01             	add    $0x1,%edi
  801767:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80176b:	83 f8 25             	cmp    $0x25,%eax
  80176e:	75 e2                	jne    801752 <vprintfmt+0x14>
  801770:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801774:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80177b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801782:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801789:	ba 00 00 00 00       	mov    $0x0,%edx
  80178e:	eb 07                	jmp    801797 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801790:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801793:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801797:	8d 47 01             	lea    0x1(%edi),%eax
  80179a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80179d:	0f b6 07             	movzbl (%edi),%eax
  8017a0:	0f b6 c8             	movzbl %al,%ecx
  8017a3:	83 e8 23             	sub    $0x23,%eax
  8017a6:	3c 55                	cmp    $0x55,%al
  8017a8:	0f 87 1a 03 00 00    	ja     801ac8 <vprintfmt+0x38a>
  8017ae:	0f b6 c0             	movzbl %al,%eax
  8017b1:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  8017b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017bb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017bf:	eb d6                	jmp    801797 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017cf:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017d3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017d6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017d9:	83 fa 09             	cmp    $0x9,%edx
  8017dc:	77 39                	ja     801817 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017de:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017e1:	eb e9                	jmp    8017cc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8017e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017ec:	8b 00                	mov    (%eax),%eax
  8017ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017f4:	eb 27                	jmp    80181d <vprintfmt+0xdf>
  8017f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  801800:	0f 49 c8             	cmovns %eax,%ecx
  801803:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801806:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801809:	eb 8c                	jmp    801797 <vprintfmt+0x59>
  80180b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80180e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801815:	eb 80                	jmp    801797 <vprintfmt+0x59>
  801817:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80181a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80181d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801821:	0f 89 70 ff ff ff    	jns    801797 <vprintfmt+0x59>
				width = precision, precision = -1;
  801827:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80182a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80182d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801834:	e9 5e ff ff ff       	jmp    801797 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801839:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80183f:	e9 53 ff ff ff       	jmp    801797 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801844:	8b 45 14             	mov    0x14(%ebp),%eax
  801847:	8d 50 04             	lea    0x4(%eax),%edx
  80184a:	89 55 14             	mov    %edx,0x14(%ebp)
  80184d:	83 ec 08             	sub    $0x8,%esp
  801850:	53                   	push   %ebx
  801851:	ff 30                	pushl  (%eax)
  801853:	ff d6                	call   *%esi
			break;
  801855:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801858:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80185b:	e9 04 ff ff ff       	jmp    801764 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801860:	8b 45 14             	mov    0x14(%ebp),%eax
  801863:	8d 50 04             	lea    0x4(%eax),%edx
  801866:	89 55 14             	mov    %edx,0x14(%ebp)
  801869:	8b 00                	mov    (%eax),%eax
  80186b:	99                   	cltd   
  80186c:	31 d0                	xor    %edx,%eax
  80186e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801870:	83 f8 0f             	cmp    $0xf,%eax
  801873:	7f 0b                	jg     801880 <vprintfmt+0x142>
  801875:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  80187c:	85 d2                	test   %edx,%edx
  80187e:	75 18                	jne    801898 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801880:	50                   	push   %eax
  801881:	68 3b 24 80 00       	push   $0x80243b
  801886:	53                   	push   %ebx
  801887:	56                   	push   %esi
  801888:	e8 94 fe ff ff       	call   801721 <printfmt>
  80188d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801890:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801893:	e9 cc fe ff ff       	jmp    801764 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801898:	52                   	push   %edx
  801899:	68 81 23 80 00       	push   $0x802381
  80189e:	53                   	push   %ebx
  80189f:	56                   	push   %esi
  8018a0:	e8 7c fe ff ff       	call   801721 <printfmt>
  8018a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018ab:	e9 b4 fe ff ff       	jmp    801764 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b3:	8d 50 04             	lea    0x4(%eax),%edx
  8018b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8018b9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018bb:	85 ff                	test   %edi,%edi
  8018bd:	b8 34 24 80 00       	mov    $0x802434,%eax
  8018c2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8018c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018c9:	0f 8e 94 00 00 00    	jle    801963 <vprintfmt+0x225>
  8018cf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018d3:	0f 84 98 00 00 00    	je     801971 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018d9:	83 ec 08             	sub    $0x8,%esp
  8018dc:	ff 75 d0             	pushl  -0x30(%ebp)
  8018df:	57                   	push   %edi
  8018e0:	e8 86 02 00 00       	call   801b6b <strnlen>
  8018e5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018e8:	29 c1                	sub    %eax,%ecx
  8018ea:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018ed:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018f0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018fa:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018fc:	eb 0f                	jmp    80190d <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018fe:	83 ec 08             	sub    $0x8,%esp
  801901:	53                   	push   %ebx
  801902:	ff 75 e0             	pushl  -0x20(%ebp)
  801905:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801907:	83 ef 01             	sub    $0x1,%edi
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	85 ff                	test   %edi,%edi
  80190f:	7f ed                	jg     8018fe <vprintfmt+0x1c0>
  801911:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801914:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801917:	85 c9                	test   %ecx,%ecx
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
  80191e:	0f 49 c1             	cmovns %ecx,%eax
  801921:	29 c1                	sub    %eax,%ecx
  801923:	89 75 08             	mov    %esi,0x8(%ebp)
  801926:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801929:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80192c:	89 cb                	mov    %ecx,%ebx
  80192e:	eb 4d                	jmp    80197d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801930:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801934:	74 1b                	je     801951 <vprintfmt+0x213>
  801936:	0f be c0             	movsbl %al,%eax
  801939:	83 e8 20             	sub    $0x20,%eax
  80193c:	83 f8 5e             	cmp    $0x5e,%eax
  80193f:	76 10                	jbe    801951 <vprintfmt+0x213>
					putch('?', putdat);
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	ff 75 0c             	pushl  0xc(%ebp)
  801947:	6a 3f                	push   $0x3f
  801949:	ff 55 08             	call   *0x8(%ebp)
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	eb 0d                	jmp    80195e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	ff 75 0c             	pushl  0xc(%ebp)
  801957:	52                   	push   %edx
  801958:	ff 55 08             	call   *0x8(%ebp)
  80195b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80195e:	83 eb 01             	sub    $0x1,%ebx
  801961:	eb 1a                	jmp    80197d <vprintfmt+0x23f>
  801963:	89 75 08             	mov    %esi,0x8(%ebp)
  801966:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801969:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80196c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80196f:	eb 0c                	jmp    80197d <vprintfmt+0x23f>
  801971:	89 75 08             	mov    %esi,0x8(%ebp)
  801974:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801977:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80197a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80197d:	83 c7 01             	add    $0x1,%edi
  801980:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801984:	0f be d0             	movsbl %al,%edx
  801987:	85 d2                	test   %edx,%edx
  801989:	74 23                	je     8019ae <vprintfmt+0x270>
  80198b:	85 f6                	test   %esi,%esi
  80198d:	78 a1                	js     801930 <vprintfmt+0x1f2>
  80198f:	83 ee 01             	sub    $0x1,%esi
  801992:	79 9c                	jns    801930 <vprintfmt+0x1f2>
  801994:	89 df                	mov    %ebx,%edi
  801996:	8b 75 08             	mov    0x8(%ebp),%esi
  801999:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80199c:	eb 18                	jmp    8019b6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80199e:	83 ec 08             	sub    $0x8,%esp
  8019a1:	53                   	push   %ebx
  8019a2:	6a 20                	push   $0x20
  8019a4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019a6:	83 ef 01             	sub    $0x1,%edi
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	eb 08                	jmp    8019b6 <vprintfmt+0x278>
  8019ae:	89 df                	mov    %ebx,%edi
  8019b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8019b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019b6:	85 ff                	test   %edi,%edi
  8019b8:	7f e4                	jg     80199e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019bd:	e9 a2 fd ff ff       	jmp    801764 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019c2:	83 fa 01             	cmp    $0x1,%edx
  8019c5:	7e 16                	jle    8019dd <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8019c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ca:	8d 50 08             	lea    0x8(%eax),%edx
  8019cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8019d0:	8b 50 04             	mov    0x4(%eax),%edx
  8019d3:	8b 00                	mov    (%eax),%eax
  8019d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019db:	eb 32                	jmp    801a0f <vprintfmt+0x2d1>
	else if (lflag)
  8019dd:	85 d2                	test   %edx,%edx
  8019df:	74 18                	je     8019f9 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e4:	8d 50 04             	lea    0x4(%eax),%edx
  8019e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8019ea:	8b 00                	mov    (%eax),%eax
  8019ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ef:	89 c1                	mov    %eax,%ecx
  8019f1:	c1 f9 1f             	sar    $0x1f,%ecx
  8019f4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019f7:	eb 16                	jmp    801a0f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019fc:	8d 50 04             	lea    0x4(%eax),%edx
  8019ff:	89 55 14             	mov    %edx,0x14(%ebp)
  801a02:	8b 00                	mov    (%eax),%eax
  801a04:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a07:	89 c1                	mov    %eax,%ecx
  801a09:	c1 f9 1f             	sar    $0x1f,%ecx
  801a0c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a0f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a12:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a15:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a1a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a1e:	79 74                	jns    801a94 <vprintfmt+0x356>
				putch('-', putdat);
  801a20:	83 ec 08             	sub    $0x8,%esp
  801a23:	53                   	push   %ebx
  801a24:	6a 2d                	push   $0x2d
  801a26:	ff d6                	call   *%esi
				num = -(long long) num;
  801a28:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a2b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a2e:	f7 d8                	neg    %eax
  801a30:	83 d2 00             	adc    $0x0,%edx
  801a33:	f7 da                	neg    %edx
  801a35:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a38:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a3d:	eb 55                	jmp    801a94 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a3f:	8d 45 14             	lea    0x14(%ebp),%eax
  801a42:	e8 83 fc ff ff       	call   8016ca <getuint>
			base = 10;
  801a47:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a4c:	eb 46                	jmp    801a94 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a4e:	8d 45 14             	lea    0x14(%ebp),%eax
  801a51:	e8 74 fc ff ff       	call   8016ca <getuint>
			base = 8;
  801a56:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a5b:	eb 37                	jmp    801a94 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a5d:	83 ec 08             	sub    $0x8,%esp
  801a60:	53                   	push   %ebx
  801a61:	6a 30                	push   $0x30
  801a63:	ff d6                	call   *%esi
			putch('x', putdat);
  801a65:	83 c4 08             	add    $0x8,%esp
  801a68:	53                   	push   %ebx
  801a69:	6a 78                	push   $0x78
  801a6b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a6d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a70:	8d 50 04             	lea    0x4(%eax),%edx
  801a73:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a76:	8b 00                	mov    (%eax),%eax
  801a78:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a7d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a80:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a85:	eb 0d                	jmp    801a94 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a87:	8d 45 14             	lea    0x14(%ebp),%eax
  801a8a:	e8 3b fc ff ff       	call   8016ca <getuint>
			base = 16;
  801a8f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a94:	83 ec 0c             	sub    $0xc,%esp
  801a97:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a9b:	57                   	push   %edi
  801a9c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a9f:	51                   	push   %ecx
  801aa0:	52                   	push   %edx
  801aa1:	50                   	push   %eax
  801aa2:	89 da                	mov    %ebx,%edx
  801aa4:	89 f0                	mov    %esi,%eax
  801aa6:	e8 70 fb ff ff       	call   80161b <printnum>
			break;
  801aab:	83 c4 20             	add    $0x20,%esp
  801aae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ab1:	e9 ae fc ff ff       	jmp    801764 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ab6:	83 ec 08             	sub    $0x8,%esp
  801ab9:	53                   	push   %ebx
  801aba:	51                   	push   %ecx
  801abb:	ff d6                	call   *%esi
			break;
  801abd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ac0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ac3:	e9 9c fc ff ff       	jmp    801764 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801ac8:	83 ec 08             	sub    $0x8,%esp
  801acb:	53                   	push   %ebx
  801acc:	6a 25                	push   $0x25
  801ace:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	eb 03                	jmp    801ad8 <vprintfmt+0x39a>
  801ad5:	83 ef 01             	sub    $0x1,%edi
  801ad8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801adc:	75 f7                	jne    801ad5 <vprintfmt+0x397>
  801ade:	e9 81 fc ff ff       	jmp    801764 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ae3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae6:	5b                   	pop    %ebx
  801ae7:	5e                   	pop    %esi
  801ae8:	5f                   	pop    %edi
  801ae9:	5d                   	pop    %ebp
  801aea:	c3                   	ret    

00801aeb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	83 ec 18             	sub    $0x18,%esp
  801af1:	8b 45 08             	mov    0x8(%ebp),%eax
  801af4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801af7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801afa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801afe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	74 26                	je     801b32 <vsnprintf+0x47>
  801b0c:	85 d2                	test   %edx,%edx
  801b0e:	7e 22                	jle    801b32 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b10:	ff 75 14             	pushl  0x14(%ebp)
  801b13:	ff 75 10             	pushl  0x10(%ebp)
  801b16:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b19:	50                   	push   %eax
  801b1a:	68 04 17 80 00       	push   $0x801704
  801b1f:	e8 1a fc ff ff       	call   80173e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b24:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b27:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	eb 05                	jmp    801b37 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b37:	c9                   	leave  
  801b38:	c3                   	ret    

00801b39 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b3f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b42:	50                   	push   %eax
  801b43:	ff 75 10             	pushl  0x10(%ebp)
  801b46:	ff 75 0c             	pushl  0xc(%ebp)
  801b49:	ff 75 08             	pushl  0x8(%ebp)
  801b4c:	e8 9a ff ff ff       	call   801aeb <vsnprintf>
	va_end(ap);

	return rc;
}
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    

00801b53 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b59:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5e:	eb 03                	jmp    801b63 <strlen+0x10>
		n++;
  801b60:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b63:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b67:	75 f7                	jne    801b60 <strlen+0xd>
		n++;
	return n;
}
  801b69:	5d                   	pop    %ebp
  801b6a:	c3                   	ret    

00801b6b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b71:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b74:	ba 00 00 00 00       	mov    $0x0,%edx
  801b79:	eb 03                	jmp    801b7e <strnlen+0x13>
		n++;
  801b7b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b7e:	39 c2                	cmp    %eax,%edx
  801b80:	74 08                	je     801b8a <strnlen+0x1f>
  801b82:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b86:	75 f3                	jne    801b7b <strnlen+0x10>
  801b88:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    

00801b8c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	53                   	push   %ebx
  801b90:	8b 45 08             	mov    0x8(%ebp),%eax
  801b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b96:	89 c2                	mov    %eax,%edx
  801b98:	83 c2 01             	add    $0x1,%edx
  801b9b:	83 c1 01             	add    $0x1,%ecx
  801b9e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801ba2:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ba5:	84 db                	test   %bl,%bl
  801ba7:	75 ef                	jne    801b98 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801ba9:	5b                   	pop    %ebx
  801baa:	5d                   	pop    %ebp
  801bab:	c3                   	ret    

00801bac <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	53                   	push   %ebx
  801bb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bb3:	53                   	push   %ebx
  801bb4:	e8 9a ff ff ff       	call   801b53 <strlen>
  801bb9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bbc:	ff 75 0c             	pushl  0xc(%ebp)
  801bbf:	01 d8                	add    %ebx,%eax
  801bc1:	50                   	push   %eax
  801bc2:	e8 c5 ff ff ff       	call   801b8c <strcpy>
	return dst;
}
  801bc7:	89 d8                	mov    %ebx,%eax
  801bc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	56                   	push   %esi
  801bd2:	53                   	push   %ebx
  801bd3:	8b 75 08             	mov    0x8(%ebp),%esi
  801bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd9:	89 f3                	mov    %esi,%ebx
  801bdb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bde:	89 f2                	mov    %esi,%edx
  801be0:	eb 0f                	jmp    801bf1 <strncpy+0x23>
		*dst++ = *src;
  801be2:	83 c2 01             	add    $0x1,%edx
  801be5:	0f b6 01             	movzbl (%ecx),%eax
  801be8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801beb:	80 39 01             	cmpb   $0x1,(%ecx)
  801bee:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bf1:	39 da                	cmp    %ebx,%edx
  801bf3:	75 ed                	jne    801be2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bf5:	89 f0                	mov    %esi,%eax
  801bf7:	5b                   	pop    %ebx
  801bf8:	5e                   	pop    %esi
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	56                   	push   %esi
  801bff:	53                   	push   %ebx
  801c00:	8b 75 08             	mov    0x8(%ebp),%esi
  801c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c06:	8b 55 10             	mov    0x10(%ebp),%edx
  801c09:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c0b:	85 d2                	test   %edx,%edx
  801c0d:	74 21                	je     801c30 <strlcpy+0x35>
  801c0f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c13:	89 f2                	mov    %esi,%edx
  801c15:	eb 09                	jmp    801c20 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c17:	83 c2 01             	add    $0x1,%edx
  801c1a:	83 c1 01             	add    $0x1,%ecx
  801c1d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c20:	39 c2                	cmp    %eax,%edx
  801c22:	74 09                	je     801c2d <strlcpy+0x32>
  801c24:	0f b6 19             	movzbl (%ecx),%ebx
  801c27:	84 db                	test   %bl,%bl
  801c29:	75 ec                	jne    801c17 <strlcpy+0x1c>
  801c2b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c2d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c30:	29 f0                	sub    %esi,%eax
}
  801c32:	5b                   	pop    %ebx
  801c33:	5e                   	pop    %esi
  801c34:	5d                   	pop    %ebp
  801c35:	c3                   	ret    

00801c36 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c3f:	eb 06                	jmp    801c47 <strcmp+0x11>
		p++, q++;
  801c41:	83 c1 01             	add    $0x1,%ecx
  801c44:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c47:	0f b6 01             	movzbl (%ecx),%eax
  801c4a:	84 c0                	test   %al,%al
  801c4c:	74 04                	je     801c52 <strcmp+0x1c>
  801c4e:	3a 02                	cmp    (%edx),%al
  801c50:	74 ef                	je     801c41 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c52:	0f b6 c0             	movzbl %al,%eax
  801c55:	0f b6 12             	movzbl (%edx),%edx
  801c58:	29 d0                	sub    %edx,%eax
}
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	53                   	push   %ebx
  801c60:	8b 45 08             	mov    0x8(%ebp),%eax
  801c63:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c66:	89 c3                	mov    %eax,%ebx
  801c68:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c6b:	eb 06                	jmp    801c73 <strncmp+0x17>
		n--, p++, q++;
  801c6d:	83 c0 01             	add    $0x1,%eax
  801c70:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c73:	39 d8                	cmp    %ebx,%eax
  801c75:	74 15                	je     801c8c <strncmp+0x30>
  801c77:	0f b6 08             	movzbl (%eax),%ecx
  801c7a:	84 c9                	test   %cl,%cl
  801c7c:	74 04                	je     801c82 <strncmp+0x26>
  801c7e:	3a 0a                	cmp    (%edx),%cl
  801c80:	74 eb                	je     801c6d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c82:	0f b6 00             	movzbl (%eax),%eax
  801c85:	0f b6 12             	movzbl (%edx),%edx
  801c88:	29 d0                	sub    %edx,%eax
  801c8a:	eb 05                	jmp    801c91 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c8c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c91:	5b                   	pop    %ebx
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    

00801c94 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c9e:	eb 07                	jmp    801ca7 <strchr+0x13>
		if (*s == c)
  801ca0:	38 ca                	cmp    %cl,%dl
  801ca2:	74 0f                	je     801cb3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ca4:	83 c0 01             	add    $0x1,%eax
  801ca7:	0f b6 10             	movzbl (%eax),%edx
  801caa:	84 d2                	test   %dl,%dl
  801cac:	75 f2                	jne    801ca0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    

00801cb5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cbf:	eb 03                	jmp    801cc4 <strfind+0xf>
  801cc1:	83 c0 01             	add    $0x1,%eax
  801cc4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cc7:	38 ca                	cmp    %cl,%dl
  801cc9:	74 04                	je     801ccf <strfind+0x1a>
  801ccb:	84 d2                	test   %dl,%dl
  801ccd:	75 f2                	jne    801cc1 <strfind+0xc>
			break;
	return (char *) s;
}
  801ccf:	5d                   	pop    %ebp
  801cd0:	c3                   	ret    

00801cd1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	57                   	push   %edi
  801cd5:	56                   	push   %esi
  801cd6:	53                   	push   %ebx
  801cd7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cda:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cdd:	85 c9                	test   %ecx,%ecx
  801cdf:	74 36                	je     801d17 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ce1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ce7:	75 28                	jne    801d11 <memset+0x40>
  801ce9:	f6 c1 03             	test   $0x3,%cl
  801cec:	75 23                	jne    801d11 <memset+0x40>
		c &= 0xFF;
  801cee:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cf2:	89 d3                	mov    %edx,%ebx
  801cf4:	c1 e3 08             	shl    $0x8,%ebx
  801cf7:	89 d6                	mov    %edx,%esi
  801cf9:	c1 e6 18             	shl    $0x18,%esi
  801cfc:	89 d0                	mov    %edx,%eax
  801cfe:	c1 e0 10             	shl    $0x10,%eax
  801d01:	09 f0                	or     %esi,%eax
  801d03:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d05:	89 d8                	mov    %ebx,%eax
  801d07:	09 d0                	or     %edx,%eax
  801d09:	c1 e9 02             	shr    $0x2,%ecx
  801d0c:	fc                   	cld    
  801d0d:	f3 ab                	rep stos %eax,%es:(%edi)
  801d0f:	eb 06                	jmp    801d17 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d14:	fc                   	cld    
  801d15:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d17:	89 f8                	mov    %edi,%eax
  801d19:	5b                   	pop    %ebx
  801d1a:	5e                   	pop    %esi
  801d1b:	5f                   	pop    %edi
  801d1c:	5d                   	pop    %ebp
  801d1d:	c3                   	ret    

00801d1e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	8b 45 08             	mov    0x8(%ebp),%eax
  801d26:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d29:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d2c:	39 c6                	cmp    %eax,%esi
  801d2e:	73 35                	jae    801d65 <memmove+0x47>
  801d30:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d33:	39 d0                	cmp    %edx,%eax
  801d35:	73 2e                	jae    801d65 <memmove+0x47>
		s += n;
		d += n;
  801d37:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d3a:	89 d6                	mov    %edx,%esi
  801d3c:	09 fe                	or     %edi,%esi
  801d3e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d44:	75 13                	jne    801d59 <memmove+0x3b>
  801d46:	f6 c1 03             	test   $0x3,%cl
  801d49:	75 0e                	jne    801d59 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d4b:	83 ef 04             	sub    $0x4,%edi
  801d4e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d51:	c1 e9 02             	shr    $0x2,%ecx
  801d54:	fd                   	std    
  801d55:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d57:	eb 09                	jmp    801d62 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d59:	83 ef 01             	sub    $0x1,%edi
  801d5c:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d5f:	fd                   	std    
  801d60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d62:	fc                   	cld    
  801d63:	eb 1d                	jmp    801d82 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d65:	89 f2                	mov    %esi,%edx
  801d67:	09 c2                	or     %eax,%edx
  801d69:	f6 c2 03             	test   $0x3,%dl
  801d6c:	75 0f                	jne    801d7d <memmove+0x5f>
  801d6e:	f6 c1 03             	test   $0x3,%cl
  801d71:	75 0a                	jne    801d7d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d73:	c1 e9 02             	shr    $0x2,%ecx
  801d76:	89 c7                	mov    %eax,%edi
  801d78:	fc                   	cld    
  801d79:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d7b:	eb 05                	jmp    801d82 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d7d:	89 c7                	mov    %eax,%edi
  801d7f:	fc                   	cld    
  801d80:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d82:	5e                   	pop    %esi
  801d83:	5f                   	pop    %edi
  801d84:	5d                   	pop    %ebp
  801d85:	c3                   	ret    

00801d86 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d89:	ff 75 10             	pushl  0x10(%ebp)
  801d8c:	ff 75 0c             	pushl  0xc(%ebp)
  801d8f:	ff 75 08             	pushl  0x8(%ebp)
  801d92:	e8 87 ff ff ff       	call   801d1e <memmove>
}
  801d97:	c9                   	leave  
  801d98:	c3                   	ret    

00801d99 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	56                   	push   %esi
  801d9d:	53                   	push   %ebx
  801d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801da1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da4:	89 c6                	mov    %eax,%esi
  801da6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801da9:	eb 1a                	jmp    801dc5 <memcmp+0x2c>
		if (*s1 != *s2)
  801dab:	0f b6 08             	movzbl (%eax),%ecx
  801dae:	0f b6 1a             	movzbl (%edx),%ebx
  801db1:	38 d9                	cmp    %bl,%cl
  801db3:	74 0a                	je     801dbf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801db5:	0f b6 c1             	movzbl %cl,%eax
  801db8:	0f b6 db             	movzbl %bl,%ebx
  801dbb:	29 d8                	sub    %ebx,%eax
  801dbd:	eb 0f                	jmp    801dce <memcmp+0x35>
		s1++, s2++;
  801dbf:	83 c0 01             	add    $0x1,%eax
  801dc2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dc5:	39 f0                	cmp    %esi,%eax
  801dc7:	75 e2                	jne    801dab <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801dc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dce:	5b                   	pop    %ebx
  801dcf:	5e                   	pop    %esi
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    

00801dd2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	53                   	push   %ebx
  801dd6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801dd9:	89 c1                	mov    %eax,%ecx
  801ddb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801dde:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801de2:	eb 0a                	jmp    801dee <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801de4:	0f b6 10             	movzbl (%eax),%edx
  801de7:	39 da                	cmp    %ebx,%edx
  801de9:	74 07                	je     801df2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801deb:	83 c0 01             	add    $0x1,%eax
  801dee:	39 c8                	cmp    %ecx,%eax
  801df0:	72 f2                	jb     801de4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801df2:	5b                   	pop    %ebx
  801df3:	5d                   	pop    %ebp
  801df4:	c3                   	ret    

00801df5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	57                   	push   %edi
  801df9:	56                   	push   %esi
  801dfa:	53                   	push   %ebx
  801dfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e01:	eb 03                	jmp    801e06 <strtol+0x11>
		s++;
  801e03:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e06:	0f b6 01             	movzbl (%ecx),%eax
  801e09:	3c 20                	cmp    $0x20,%al
  801e0b:	74 f6                	je     801e03 <strtol+0xe>
  801e0d:	3c 09                	cmp    $0x9,%al
  801e0f:	74 f2                	je     801e03 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e11:	3c 2b                	cmp    $0x2b,%al
  801e13:	75 0a                	jne    801e1f <strtol+0x2a>
		s++;
  801e15:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e18:	bf 00 00 00 00       	mov    $0x0,%edi
  801e1d:	eb 11                	jmp    801e30 <strtol+0x3b>
  801e1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e24:	3c 2d                	cmp    $0x2d,%al
  801e26:	75 08                	jne    801e30 <strtol+0x3b>
		s++, neg = 1;
  801e28:	83 c1 01             	add    $0x1,%ecx
  801e2b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e30:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e36:	75 15                	jne    801e4d <strtol+0x58>
  801e38:	80 39 30             	cmpb   $0x30,(%ecx)
  801e3b:	75 10                	jne    801e4d <strtol+0x58>
  801e3d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e41:	75 7c                	jne    801ebf <strtol+0xca>
		s += 2, base = 16;
  801e43:	83 c1 02             	add    $0x2,%ecx
  801e46:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e4b:	eb 16                	jmp    801e63 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e4d:	85 db                	test   %ebx,%ebx
  801e4f:	75 12                	jne    801e63 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e51:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e56:	80 39 30             	cmpb   $0x30,(%ecx)
  801e59:	75 08                	jne    801e63 <strtol+0x6e>
		s++, base = 8;
  801e5b:	83 c1 01             	add    $0x1,%ecx
  801e5e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e63:	b8 00 00 00 00       	mov    $0x0,%eax
  801e68:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e6b:	0f b6 11             	movzbl (%ecx),%edx
  801e6e:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e71:	89 f3                	mov    %esi,%ebx
  801e73:	80 fb 09             	cmp    $0x9,%bl
  801e76:	77 08                	ja     801e80 <strtol+0x8b>
			dig = *s - '0';
  801e78:	0f be d2             	movsbl %dl,%edx
  801e7b:	83 ea 30             	sub    $0x30,%edx
  801e7e:	eb 22                	jmp    801ea2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e80:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e83:	89 f3                	mov    %esi,%ebx
  801e85:	80 fb 19             	cmp    $0x19,%bl
  801e88:	77 08                	ja     801e92 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e8a:	0f be d2             	movsbl %dl,%edx
  801e8d:	83 ea 57             	sub    $0x57,%edx
  801e90:	eb 10                	jmp    801ea2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e92:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e95:	89 f3                	mov    %esi,%ebx
  801e97:	80 fb 19             	cmp    $0x19,%bl
  801e9a:	77 16                	ja     801eb2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e9c:	0f be d2             	movsbl %dl,%edx
  801e9f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ea2:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ea5:	7d 0b                	jge    801eb2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ea7:	83 c1 01             	add    $0x1,%ecx
  801eaa:	0f af 45 10          	imul   0x10(%ebp),%eax
  801eae:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801eb0:	eb b9                	jmp    801e6b <strtol+0x76>

	if (endptr)
  801eb2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801eb6:	74 0d                	je     801ec5 <strtol+0xd0>
		*endptr = (char *) s;
  801eb8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ebb:	89 0e                	mov    %ecx,(%esi)
  801ebd:	eb 06                	jmp    801ec5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ebf:	85 db                	test   %ebx,%ebx
  801ec1:	74 98                	je     801e5b <strtol+0x66>
  801ec3:	eb 9e                	jmp    801e63 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ec5:	89 c2                	mov    %eax,%edx
  801ec7:	f7 da                	neg    %edx
  801ec9:	85 ff                	test   %edi,%edi
  801ecb:	0f 45 c2             	cmovne %edx,%eax
}
  801ece:	5b                   	pop    %ebx
  801ecf:	5e                   	pop    %esi
  801ed0:	5f                   	pop    %edi
  801ed1:	5d                   	pop    %ebp
  801ed2:	c3                   	ret    

00801ed3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	56                   	push   %esi
  801ed7:	53                   	push   %ebx
  801ed8:	8b 75 08             	mov    0x8(%ebp),%esi
  801edb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ede:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ee1:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ee3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ee8:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801eeb:	83 ec 0c             	sub    $0xc,%esp
  801eee:	50                   	push   %eax
  801eef:	e8 12 e4 ff ff       	call   800306 <sys_ipc_recv>

	if (from_env_store != NULL)
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	85 f6                	test   %esi,%esi
  801ef9:	74 14                	je     801f0f <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801efb:	ba 00 00 00 00       	mov    $0x0,%edx
  801f00:	85 c0                	test   %eax,%eax
  801f02:	78 09                	js     801f0d <ipc_recv+0x3a>
  801f04:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f0a:	8b 52 74             	mov    0x74(%edx),%edx
  801f0d:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f0f:	85 db                	test   %ebx,%ebx
  801f11:	74 14                	je     801f27 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f13:	ba 00 00 00 00       	mov    $0x0,%edx
  801f18:	85 c0                	test   %eax,%eax
  801f1a:	78 09                	js     801f25 <ipc_recv+0x52>
  801f1c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f22:	8b 52 78             	mov    0x78(%edx),%edx
  801f25:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f27:	85 c0                	test   %eax,%eax
  801f29:	78 08                	js     801f33 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f2b:	a1 08 40 80 00       	mov    0x804008,%eax
  801f30:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f36:	5b                   	pop    %ebx
  801f37:	5e                   	pop    %esi
  801f38:	5d                   	pop    %ebp
  801f39:	c3                   	ret    

00801f3a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	57                   	push   %edi
  801f3e:	56                   	push   %esi
  801f3f:	53                   	push   %ebx
  801f40:	83 ec 0c             	sub    $0xc,%esp
  801f43:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f46:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f4c:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f4e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f53:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f56:	ff 75 14             	pushl  0x14(%ebp)
  801f59:	53                   	push   %ebx
  801f5a:	56                   	push   %esi
  801f5b:	57                   	push   %edi
  801f5c:	e8 82 e3 ff ff       	call   8002e3 <sys_ipc_try_send>

		if (err < 0) {
  801f61:	83 c4 10             	add    $0x10,%esp
  801f64:	85 c0                	test   %eax,%eax
  801f66:	79 1e                	jns    801f86 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f68:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f6b:	75 07                	jne    801f74 <ipc_send+0x3a>
				sys_yield();
  801f6d:	e8 c5 e1 ff ff       	call   800137 <sys_yield>
  801f72:	eb e2                	jmp    801f56 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f74:	50                   	push   %eax
  801f75:	68 20 27 80 00       	push   $0x802720
  801f7a:	6a 49                	push   $0x49
  801f7c:	68 2d 27 80 00       	push   $0x80272d
  801f81:	e8 a8 f5 ff ff       	call   80152e <_panic>
		}

	} while (err < 0);

}
  801f86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f89:	5b                   	pop    %ebx
  801f8a:	5e                   	pop    %esi
  801f8b:	5f                   	pop    %edi
  801f8c:	5d                   	pop    %ebp
  801f8d:	c3                   	ret    

00801f8e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f94:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f99:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f9c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fa2:	8b 52 50             	mov    0x50(%edx),%edx
  801fa5:	39 ca                	cmp    %ecx,%edx
  801fa7:	75 0d                	jne    801fb6 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fa9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fb1:	8b 40 48             	mov    0x48(%eax),%eax
  801fb4:	eb 0f                	jmp    801fc5 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fb6:	83 c0 01             	add    $0x1,%eax
  801fb9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fbe:	75 d9                	jne    801f99 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fc5:	5d                   	pop    %ebp
  801fc6:	c3                   	ret    

00801fc7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
  801fca:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fcd:	89 d0                	mov    %edx,%eax
  801fcf:	c1 e8 16             	shr    $0x16,%eax
  801fd2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fd9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fde:	f6 c1 01             	test   $0x1,%cl
  801fe1:	74 1d                	je     802000 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fe3:	c1 ea 0c             	shr    $0xc,%edx
  801fe6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fed:	f6 c2 01             	test   $0x1,%dl
  801ff0:	74 0e                	je     802000 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ff2:	c1 ea 0c             	shr    $0xc,%edx
  801ff5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ffc:	ef 
  801ffd:	0f b7 c0             	movzwl %ax,%eax
}
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    
  802002:	66 90                	xchg   %ax,%ax
  802004:	66 90                	xchg   %ax,%ax
  802006:	66 90                	xchg   %ax,%ax
  802008:	66 90                	xchg   %ax,%ax
  80200a:	66 90                	xchg   %ax,%ax
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__udivdi3>:
  802010:	55                   	push   %ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
  802017:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80201b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80201f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802027:	85 f6                	test   %esi,%esi
  802029:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80202d:	89 ca                	mov    %ecx,%edx
  80202f:	89 f8                	mov    %edi,%eax
  802031:	75 3d                	jne    802070 <__udivdi3+0x60>
  802033:	39 cf                	cmp    %ecx,%edi
  802035:	0f 87 c5 00 00 00    	ja     802100 <__udivdi3+0xf0>
  80203b:	85 ff                	test   %edi,%edi
  80203d:	89 fd                	mov    %edi,%ebp
  80203f:	75 0b                	jne    80204c <__udivdi3+0x3c>
  802041:	b8 01 00 00 00       	mov    $0x1,%eax
  802046:	31 d2                	xor    %edx,%edx
  802048:	f7 f7                	div    %edi
  80204a:	89 c5                	mov    %eax,%ebp
  80204c:	89 c8                	mov    %ecx,%eax
  80204e:	31 d2                	xor    %edx,%edx
  802050:	f7 f5                	div    %ebp
  802052:	89 c1                	mov    %eax,%ecx
  802054:	89 d8                	mov    %ebx,%eax
  802056:	89 cf                	mov    %ecx,%edi
  802058:	f7 f5                	div    %ebp
  80205a:	89 c3                	mov    %eax,%ebx
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
  802070:	39 ce                	cmp    %ecx,%esi
  802072:	77 74                	ja     8020e8 <__udivdi3+0xd8>
  802074:	0f bd fe             	bsr    %esi,%edi
  802077:	83 f7 1f             	xor    $0x1f,%edi
  80207a:	0f 84 98 00 00 00    	je     802118 <__udivdi3+0x108>
  802080:	bb 20 00 00 00       	mov    $0x20,%ebx
  802085:	89 f9                	mov    %edi,%ecx
  802087:	89 c5                	mov    %eax,%ebp
  802089:	29 fb                	sub    %edi,%ebx
  80208b:	d3 e6                	shl    %cl,%esi
  80208d:	89 d9                	mov    %ebx,%ecx
  80208f:	d3 ed                	shr    %cl,%ebp
  802091:	89 f9                	mov    %edi,%ecx
  802093:	d3 e0                	shl    %cl,%eax
  802095:	09 ee                	or     %ebp,%esi
  802097:	89 d9                	mov    %ebx,%ecx
  802099:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209d:	89 d5                	mov    %edx,%ebp
  80209f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020a3:	d3 ed                	shr    %cl,%ebp
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e2                	shl    %cl,%edx
  8020a9:	89 d9                	mov    %ebx,%ecx
  8020ab:	d3 e8                	shr    %cl,%eax
  8020ad:	09 c2                	or     %eax,%edx
  8020af:	89 d0                	mov    %edx,%eax
  8020b1:	89 ea                	mov    %ebp,%edx
  8020b3:	f7 f6                	div    %esi
  8020b5:	89 d5                	mov    %edx,%ebp
  8020b7:	89 c3                	mov    %eax,%ebx
  8020b9:	f7 64 24 0c          	mull   0xc(%esp)
  8020bd:	39 d5                	cmp    %edx,%ebp
  8020bf:	72 10                	jb     8020d1 <__udivdi3+0xc1>
  8020c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e6                	shl    %cl,%esi
  8020c9:	39 c6                	cmp    %eax,%esi
  8020cb:	73 07                	jae    8020d4 <__udivdi3+0xc4>
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	75 03                	jne    8020d4 <__udivdi3+0xc4>
  8020d1:	83 eb 01             	sub    $0x1,%ebx
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 d8                	mov    %ebx,%eax
  8020d8:	89 fa                	mov    %edi,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	31 ff                	xor    %edi,%edi
  8020ea:	31 db                	xor    %ebx,%ebx
  8020ec:	89 d8                	mov    %ebx,%eax
  8020ee:	89 fa                	mov    %edi,%edx
  8020f0:	83 c4 1c             	add    $0x1c,%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	90                   	nop
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	89 d8                	mov    %ebx,%eax
  802102:	f7 f7                	div    %edi
  802104:	31 ff                	xor    %edi,%edi
  802106:	89 c3                	mov    %eax,%ebx
  802108:	89 d8                	mov    %ebx,%eax
  80210a:	89 fa                	mov    %edi,%edx
  80210c:	83 c4 1c             	add    $0x1c,%esp
  80210f:	5b                   	pop    %ebx
  802110:	5e                   	pop    %esi
  802111:	5f                   	pop    %edi
  802112:	5d                   	pop    %ebp
  802113:	c3                   	ret    
  802114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802118:	39 ce                	cmp    %ecx,%esi
  80211a:	72 0c                	jb     802128 <__udivdi3+0x118>
  80211c:	31 db                	xor    %ebx,%ebx
  80211e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802122:	0f 87 34 ff ff ff    	ja     80205c <__udivdi3+0x4c>
  802128:	bb 01 00 00 00       	mov    $0x1,%ebx
  80212d:	e9 2a ff ff ff       	jmp    80205c <__udivdi3+0x4c>
  802132:	66 90                	xchg   %ax,%ax
  802134:	66 90                	xchg   %ax,%ax
  802136:	66 90                	xchg   %ax,%ax
  802138:	66 90                	xchg   %ax,%ax
  80213a:	66 90                	xchg   %ax,%ax
  80213c:	66 90                	xchg   %ax,%ax
  80213e:	66 90                	xchg   %ax,%ax

00802140 <__umoddi3>:
  802140:	55                   	push   %ebp
  802141:	57                   	push   %edi
  802142:	56                   	push   %esi
  802143:	53                   	push   %ebx
  802144:	83 ec 1c             	sub    $0x1c,%esp
  802147:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80214b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80214f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802153:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802157:	85 d2                	test   %edx,%edx
  802159:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80215d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802161:	89 f3                	mov    %esi,%ebx
  802163:	89 3c 24             	mov    %edi,(%esp)
  802166:	89 74 24 04          	mov    %esi,0x4(%esp)
  80216a:	75 1c                	jne    802188 <__umoddi3+0x48>
  80216c:	39 f7                	cmp    %esi,%edi
  80216e:	76 50                	jbe    8021c0 <__umoddi3+0x80>
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	f7 f7                	div    %edi
  802176:	89 d0                	mov    %edx,%eax
  802178:	31 d2                	xor    %edx,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	39 f2                	cmp    %esi,%edx
  80218a:	89 d0                	mov    %edx,%eax
  80218c:	77 52                	ja     8021e0 <__umoddi3+0xa0>
  80218e:	0f bd ea             	bsr    %edx,%ebp
  802191:	83 f5 1f             	xor    $0x1f,%ebp
  802194:	75 5a                	jne    8021f0 <__umoddi3+0xb0>
  802196:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80219a:	0f 82 e0 00 00 00    	jb     802280 <__umoddi3+0x140>
  8021a0:	39 0c 24             	cmp    %ecx,(%esp)
  8021a3:	0f 86 d7 00 00 00    	jbe    802280 <__umoddi3+0x140>
  8021a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021b1:	83 c4 1c             	add    $0x1c,%esp
  8021b4:	5b                   	pop    %ebx
  8021b5:	5e                   	pop    %esi
  8021b6:	5f                   	pop    %edi
  8021b7:	5d                   	pop    %ebp
  8021b8:	c3                   	ret    
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	85 ff                	test   %edi,%edi
  8021c2:	89 fd                	mov    %edi,%ebp
  8021c4:	75 0b                	jne    8021d1 <__umoddi3+0x91>
  8021c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021cb:	31 d2                	xor    %edx,%edx
  8021cd:	f7 f7                	div    %edi
  8021cf:	89 c5                	mov    %eax,%ebp
  8021d1:	89 f0                	mov    %esi,%eax
  8021d3:	31 d2                	xor    %edx,%edx
  8021d5:	f7 f5                	div    %ebp
  8021d7:	89 c8                	mov    %ecx,%eax
  8021d9:	f7 f5                	div    %ebp
  8021db:	89 d0                	mov    %edx,%eax
  8021dd:	eb 99                	jmp    802178 <__umoddi3+0x38>
  8021df:	90                   	nop
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	83 c4 1c             	add    $0x1c,%esp
  8021e7:	5b                   	pop    %ebx
  8021e8:	5e                   	pop    %esi
  8021e9:	5f                   	pop    %edi
  8021ea:	5d                   	pop    %ebp
  8021eb:	c3                   	ret    
  8021ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	8b 34 24             	mov    (%esp),%esi
  8021f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021f8:	89 e9                	mov    %ebp,%ecx
  8021fa:	29 ef                	sub    %ebp,%edi
  8021fc:	d3 e0                	shl    %cl,%eax
  8021fe:	89 f9                	mov    %edi,%ecx
  802200:	89 f2                	mov    %esi,%edx
  802202:	d3 ea                	shr    %cl,%edx
  802204:	89 e9                	mov    %ebp,%ecx
  802206:	09 c2                	or     %eax,%edx
  802208:	89 d8                	mov    %ebx,%eax
  80220a:	89 14 24             	mov    %edx,(%esp)
  80220d:	89 f2                	mov    %esi,%edx
  80220f:	d3 e2                	shl    %cl,%edx
  802211:	89 f9                	mov    %edi,%ecx
  802213:	89 54 24 04          	mov    %edx,0x4(%esp)
  802217:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	89 c6                	mov    %eax,%esi
  802221:	d3 e3                	shl    %cl,%ebx
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 d0                	mov    %edx,%eax
  802227:	d3 e8                	shr    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	09 d8                	or     %ebx,%eax
  80222d:	89 d3                	mov    %edx,%ebx
  80222f:	89 f2                	mov    %esi,%edx
  802231:	f7 34 24             	divl   (%esp)
  802234:	89 d6                	mov    %edx,%esi
  802236:	d3 e3                	shl    %cl,%ebx
  802238:	f7 64 24 04          	mull   0x4(%esp)
  80223c:	39 d6                	cmp    %edx,%esi
  80223e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802242:	89 d1                	mov    %edx,%ecx
  802244:	89 c3                	mov    %eax,%ebx
  802246:	72 08                	jb     802250 <__umoddi3+0x110>
  802248:	75 11                	jne    80225b <__umoddi3+0x11b>
  80224a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80224e:	73 0b                	jae    80225b <__umoddi3+0x11b>
  802250:	2b 44 24 04          	sub    0x4(%esp),%eax
  802254:	1b 14 24             	sbb    (%esp),%edx
  802257:	89 d1                	mov    %edx,%ecx
  802259:	89 c3                	mov    %eax,%ebx
  80225b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80225f:	29 da                	sub    %ebx,%edx
  802261:	19 ce                	sbb    %ecx,%esi
  802263:	89 f9                	mov    %edi,%ecx
  802265:	89 f0                	mov    %esi,%eax
  802267:	d3 e0                	shl    %cl,%eax
  802269:	89 e9                	mov    %ebp,%ecx
  80226b:	d3 ea                	shr    %cl,%edx
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	d3 ee                	shr    %cl,%esi
  802271:	09 d0                	or     %edx,%eax
  802273:	89 f2                	mov    %esi,%edx
  802275:	83 c4 1c             	add    $0x1c,%esp
  802278:	5b                   	pop    %ebx
  802279:	5e                   	pop    %esi
  80227a:	5f                   	pop    %edi
  80227b:	5d                   	pop    %ebp
  80227c:	c3                   	ret    
  80227d:	8d 76 00             	lea    0x0(%esi),%esi
  802280:	29 f9                	sub    %edi,%ecx
  802282:	19 d6                	sbb    %edx,%esi
  802284:	89 74 24 04          	mov    %esi,0x4(%esp)
  802288:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80228c:	e9 18 ff ff ff       	jmp    8021a9 <__umoddi3+0x69>
