
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
  800086:	e8 e8 04 00 00       	call   800573 <close_all>
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
  8000ff:	68 6a 22 80 00       	push   $0x80226a
  800104:	6a 23                	push   $0x23
  800106:	68 87 22 80 00       	push   $0x802287
  80010b:	e8 dc 13 00 00       	call   8014ec <_panic>

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
  800180:	68 6a 22 80 00       	push   $0x80226a
  800185:	6a 23                	push   $0x23
  800187:	68 87 22 80 00       	push   $0x802287
  80018c:	e8 5b 13 00 00       	call   8014ec <_panic>

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
  8001c2:	68 6a 22 80 00       	push   $0x80226a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 87 22 80 00       	push   $0x802287
  8001ce:	e8 19 13 00 00       	call   8014ec <_panic>

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
  800204:	68 6a 22 80 00       	push   $0x80226a
  800209:	6a 23                	push   $0x23
  80020b:	68 87 22 80 00       	push   $0x802287
  800210:	e8 d7 12 00 00       	call   8014ec <_panic>

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
  800246:	68 6a 22 80 00       	push   $0x80226a
  80024b:	6a 23                	push   $0x23
  80024d:	68 87 22 80 00       	push   $0x802287
  800252:	e8 95 12 00 00       	call   8014ec <_panic>

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
  800288:	68 6a 22 80 00       	push   $0x80226a
  80028d:	6a 23                	push   $0x23
  80028f:	68 87 22 80 00       	push   $0x802287
  800294:	e8 53 12 00 00       	call   8014ec <_panic>

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
  8002ca:	68 6a 22 80 00       	push   $0x80226a
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 87 22 80 00       	push   $0x802287
  8002d6:	e8 11 12 00 00       	call   8014ec <_panic>

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
  80032e:	68 6a 22 80 00       	push   $0x80226a
  800333:	6a 23                	push   $0x23
  800335:	68 87 22 80 00       	push   $0x802287
  80033a:	e8 ad 11 00 00       	call   8014ec <_panic>

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
  80038f:	68 6a 22 80 00       	push   $0x80226a
  800394:	6a 23                	push   $0x23
  800396:	68 87 22 80 00       	push   $0x802287
  80039b:	e8 4c 11 00 00       	call   8014ec <_panic>

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

008003a8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ae:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b3:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003be:	05 00 00 00 30       	add    $0x30000000,%eax
  8003c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003da:	89 c2                	mov    %eax,%edx
  8003dc:	c1 ea 16             	shr    $0x16,%edx
  8003df:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e6:	f6 c2 01             	test   $0x1,%dl
  8003e9:	74 11                	je     8003fc <fd_alloc+0x2d>
  8003eb:	89 c2                	mov    %eax,%edx
  8003ed:	c1 ea 0c             	shr    $0xc,%edx
  8003f0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f7:	f6 c2 01             	test   $0x1,%dl
  8003fa:	75 09                	jne    800405 <fd_alloc+0x36>
			*fd_store = fd;
  8003fc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800403:	eb 17                	jmp    80041c <fd_alloc+0x4d>
  800405:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80040a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80040f:	75 c9                	jne    8003da <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800411:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800417:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80041c:	5d                   	pop    %ebp
  80041d:	c3                   	ret    

0080041e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800424:	83 f8 1f             	cmp    $0x1f,%eax
  800427:	77 36                	ja     80045f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800429:	c1 e0 0c             	shl    $0xc,%eax
  80042c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800431:	89 c2                	mov    %eax,%edx
  800433:	c1 ea 16             	shr    $0x16,%edx
  800436:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80043d:	f6 c2 01             	test   $0x1,%dl
  800440:	74 24                	je     800466 <fd_lookup+0x48>
  800442:	89 c2                	mov    %eax,%edx
  800444:	c1 ea 0c             	shr    $0xc,%edx
  800447:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80044e:	f6 c2 01             	test   $0x1,%dl
  800451:	74 1a                	je     80046d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800453:	8b 55 0c             	mov    0xc(%ebp),%edx
  800456:	89 02                	mov    %eax,(%edx)
	return 0;
  800458:	b8 00 00 00 00       	mov    $0x0,%eax
  80045d:	eb 13                	jmp    800472 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800464:	eb 0c                	jmp    800472 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800466:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046b:	eb 05                	jmp    800472 <fd_lookup+0x54>
  80046d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800472:	5d                   	pop    %ebp
  800473:	c3                   	ret    

00800474 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800474:	55                   	push   %ebp
  800475:	89 e5                	mov    %esp,%ebp
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80047d:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800482:	eb 13                	jmp    800497 <dev_lookup+0x23>
  800484:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800487:	39 08                	cmp    %ecx,(%eax)
  800489:	75 0c                	jne    800497 <dev_lookup+0x23>
			*dev = devtab[i];
  80048b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80048e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800490:	b8 00 00 00 00       	mov    $0x0,%eax
  800495:	eb 2e                	jmp    8004c5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800497:	8b 02                	mov    (%edx),%eax
  800499:	85 c0                	test   %eax,%eax
  80049b:	75 e7                	jne    800484 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80049d:	a1 08 40 80 00       	mov    0x804008,%eax
  8004a2:	8b 40 48             	mov    0x48(%eax),%eax
  8004a5:	83 ec 04             	sub    $0x4,%esp
  8004a8:	51                   	push   %ecx
  8004a9:	50                   	push   %eax
  8004aa:	68 98 22 80 00       	push   $0x802298
  8004af:	e8 11 11 00 00       	call   8015c5 <cprintf>
	*dev = 0;
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004c5:	c9                   	leave  
  8004c6:	c3                   	ret    

008004c7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004c7:	55                   	push   %ebp
  8004c8:	89 e5                	mov    %esp,%ebp
  8004ca:	56                   	push   %esi
  8004cb:	53                   	push   %ebx
  8004cc:	83 ec 10             	sub    $0x10,%esp
  8004cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d8:	50                   	push   %eax
  8004d9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004df:	c1 e8 0c             	shr    $0xc,%eax
  8004e2:	50                   	push   %eax
  8004e3:	e8 36 ff ff ff       	call   80041e <fd_lookup>
  8004e8:	83 c4 08             	add    $0x8,%esp
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	78 05                	js     8004f4 <fd_close+0x2d>
	    || fd != fd2)
  8004ef:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004f2:	74 0c                	je     800500 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004f4:	84 db                	test   %bl,%bl
  8004f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fb:	0f 44 c2             	cmove  %edx,%eax
  8004fe:	eb 41                	jmp    800541 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800506:	50                   	push   %eax
  800507:	ff 36                	pushl  (%esi)
  800509:	e8 66 ff ff ff       	call   800474 <dev_lookup>
  80050e:	89 c3                	mov    %eax,%ebx
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	85 c0                	test   %eax,%eax
  800515:	78 1a                	js     800531 <fd_close+0x6a>
		if (dev->dev_close)
  800517:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80051a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80051d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800522:	85 c0                	test   %eax,%eax
  800524:	74 0b                	je     800531 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800526:	83 ec 0c             	sub    $0xc,%esp
  800529:	56                   	push   %esi
  80052a:	ff d0                	call   *%eax
  80052c:	89 c3                	mov    %eax,%ebx
  80052e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	56                   	push   %esi
  800535:	6a 00                	push   $0x0
  800537:	e8 9f fc ff ff       	call   8001db <sys_page_unmap>
	return r;
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	89 d8                	mov    %ebx,%eax
}
  800541:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800544:	5b                   	pop    %ebx
  800545:	5e                   	pop    %esi
  800546:	5d                   	pop    %ebp
  800547:	c3                   	ret    

00800548 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80054e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800551:	50                   	push   %eax
  800552:	ff 75 08             	pushl  0x8(%ebp)
  800555:	e8 c4 fe ff ff       	call   80041e <fd_lookup>
  80055a:	83 c4 08             	add    $0x8,%esp
  80055d:	85 c0                	test   %eax,%eax
  80055f:	78 10                	js     800571 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	6a 01                	push   $0x1
  800566:	ff 75 f4             	pushl  -0xc(%ebp)
  800569:	e8 59 ff ff ff       	call   8004c7 <fd_close>
  80056e:	83 c4 10             	add    $0x10,%esp
}
  800571:	c9                   	leave  
  800572:	c3                   	ret    

00800573 <close_all>:

void
close_all(void)
{
  800573:	55                   	push   %ebp
  800574:	89 e5                	mov    %esp,%ebp
  800576:	53                   	push   %ebx
  800577:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80057a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80057f:	83 ec 0c             	sub    $0xc,%esp
  800582:	53                   	push   %ebx
  800583:	e8 c0 ff ff ff       	call   800548 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800588:	83 c3 01             	add    $0x1,%ebx
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	83 fb 20             	cmp    $0x20,%ebx
  800591:	75 ec                	jne    80057f <close_all+0xc>
		close(i);
}
  800593:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800596:	c9                   	leave  
  800597:	c3                   	ret    

00800598 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	57                   	push   %edi
  80059c:	56                   	push   %esi
  80059d:	53                   	push   %ebx
  80059e:	83 ec 2c             	sub    $0x2c,%esp
  8005a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005a4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a7:	50                   	push   %eax
  8005a8:	ff 75 08             	pushl  0x8(%ebp)
  8005ab:	e8 6e fe ff ff       	call   80041e <fd_lookup>
  8005b0:	83 c4 08             	add    $0x8,%esp
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	0f 88 c1 00 00 00    	js     80067c <dup+0xe4>
		return r;
	close(newfdnum);
  8005bb:	83 ec 0c             	sub    $0xc,%esp
  8005be:	56                   	push   %esi
  8005bf:	e8 84 ff ff ff       	call   800548 <close>

	newfd = INDEX2FD(newfdnum);
  8005c4:	89 f3                	mov    %esi,%ebx
  8005c6:	c1 e3 0c             	shl    $0xc,%ebx
  8005c9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005cf:	83 c4 04             	add    $0x4,%esp
  8005d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005d5:	e8 de fd ff ff       	call   8003b8 <fd2data>
  8005da:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005dc:	89 1c 24             	mov    %ebx,(%esp)
  8005df:	e8 d4 fd ff ff       	call   8003b8 <fd2data>
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005ea:	89 f8                	mov    %edi,%eax
  8005ec:	c1 e8 16             	shr    $0x16,%eax
  8005ef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005f6:	a8 01                	test   $0x1,%al
  8005f8:	74 37                	je     800631 <dup+0x99>
  8005fa:	89 f8                	mov    %edi,%eax
  8005fc:	c1 e8 0c             	shr    $0xc,%eax
  8005ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800606:	f6 c2 01             	test   $0x1,%dl
  800609:	74 26                	je     800631 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80060b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800612:	83 ec 0c             	sub    $0xc,%esp
  800615:	25 07 0e 00 00       	and    $0xe07,%eax
  80061a:	50                   	push   %eax
  80061b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061e:	6a 00                	push   $0x0
  800620:	57                   	push   %edi
  800621:	6a 00                	push   $0x0
  800623:	e8 71 fb ff ff       	call   800199 <sys_page_map>
  800628:	89 c7                	mov    %eax,%edi
  80062a:	83 c4 20             	add    $0x20,%esp
  80062d:	85 c0                	test   %eax,%eax
  80062f:	78 2e                	js     80065f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800631:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800634:	89 d0                	mov    %edx,%eax
  800636:	c1 e8 0c             	shr    $0xc,%eax
  800639:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800640:	83 ec 0c             	sub    $0xc,%esp
  800643:	25 07 0e 00 00       	and    $0xe07,%eax
  800648:	50                   	push   %eax
  800649:	53                   	push   %ebx
  80064a:	6a 00                	push   $0x0
  80064c:	52                   	push   %edx
  80064d:	6a 00                	push   $0x0
  80064f:	e8 45 fb ff ff       	call   800199 <sys_page_map>
  800654:	89 c7                	mov    %eax,%edi
  800656:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800659:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80065b:	85 ff                	test   %edi,%edi
  80065d:	79 1d                	jns    80067c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	53                   	push   %ebx
  800663:	6a 00                	push   $0x0
  800665:	e8 71 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  80066a:	83 c4 08             	add    $0x8,%esp
  80066d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800670:	6a 00                	push   $0x0
  800672:	e8 64 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800677:	83 c4 10             	add    $0x10,%esp
  80067a:	89 f8                	mov    %edi,%eax
}
  80067c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067f:	5b                   	pop    %ebx
  800680:	5e                   	pop    %esi
  800681:	5f                   	pop    %edi
  800682:	5d                   	pop    %ebp
  800683:	c3                   	ret    

00800684 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800684:	55                   	push   %ebp
  800685:	89 e5                	mov    %esp,%ebp
  800687:	53                   	push   %ebx
  800688:	83 ec 14             	sub    $0x14,%esp
  80068b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80068e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800691:	50                   	push   %eax
  800692:	53                   	push   %ebx
  800693:	e8 86 fd ff ff       	call   80041e <fd_lookup>
  800698:	83 c4 08             	add    $0x8,%esp
  80069b:	89 c2                	mov    %eax,%edx
  80069d:	85 c0                	test   %eax,%eax
  80069f:	78 6d                	js     80070e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006a7:	50                   	push   %eax
  8006a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006ab:	ff 30                	pushl  (%eax)
  8006ad:	e8 c2 fd ff ff       	call   800474 <dev_lookup>
  8006b2:	83 c4 10             	add    $0x10,%esp
  8006b5:	85 c0                	test   %eax,%eax
  8006b7:	78 4c                	js     800705 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006bc:	8b 42 08             	mov    0x8(%edx),%eax
  8006bf:	83 e0 03             	and    $0x3,%eax
  8006c2:	83 f8 01             	cmp    $0x1,%eax
  8006c5:	75 21                	jne    8006e8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8006cc:	8b 40 48             	mov    0x48(%eax),%eax
  8006cf:	83 ec 04             	sub    $0x4,%esp
  8006d2:	53                   	push   %ebx
  8006d3:	50                   	push   %eax
  8006d4:	68 d9 22 80 00       	push   $0x8022d9
  8006d9:	e8 e7 0e 00 00       	call   8015c5 <cprintf>
		return -E_INVAL;
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006e6:	eb 26                	jmp    80070e <read+0x8a>
	}
	if (!dev->dev_read)
  8006e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006eb:	8b 40 08             	mov    0x8(%eax),%eax
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	74 17                	je     800709 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006f2:	83 ec 04             	sub    $0x4,%esp
  8006f5:	ff 75 10             	pushl  0x10(%ebp)
  8006f8:	ff 75 0c             	pushl  0xc(%ebp)
  8006fb:	52                   	push   %edx
  8006fc:	ff d0                	call   *%eax
  8006fe:	89 c2                	mov    %eax,%edx
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	eb 09                	jmp    80070e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800705:	89 c2                	mov    %eax,%edx
  800707:	eb 05                	jmp    80070e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800709:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80070e:	89 d0                	mov    %edx,%eax
  800710:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800713:	c9                   	leave  
  800714:	c3                   	ret    

00800715 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	57                   	push   %edi
  800719:	56                   	push   %esi
  80071a:	53                   	push   %ebx
  80071b:	83 ec 0c             	sub    $0xc,%esp
  80071e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800721:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800724:	bb 00 00 00 00       	mov    $0x0,%ebx
  800729:	eb 21                	jmp    80074c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80072b:	83 ec 04             	sub    $0x4,%esp
  80072e:	89 f0                	mov    %esi,%eax
  800730:	29 d8                	sub    %ebx,%eax
  800732:	50                   	push   %eax
  800733:	89 d8                	mov    %ebx,%eax
  800735:	03 45 0c             	add    0xc(%ebp),%eax
  800738:	50                   	push   %eax
  800739:	57                   	push   %edi
  80073a:	e8 45 ff ff ff       	call   800684 <read>
		if (m < 0)
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	85 c0                	test   %eax,%eax
  800744:	78 10                	js     800756 <readn+0x41>
			return m;
		if (m == 0)
  800746:	85 c0                	test   %eax,%eax
  800748:	74 0a                	je     800754 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80074a:	01 c3                	add    %eax,%ebx
  80074c:	39 f3                	cmp    %esi,%ebx
  80074e:	72 db                	jb     80072b <readn+0x16>
  800750:	89 d8                	mov    %ebx,%eax
  800752:	eb 02                	jmp    800756 <readn+0x41>
  800754:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800756:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800759:	5b                   	pop    %ebx
  80075a:	5e                   	pop    %esi
  80075b:	5f                   	pop    %edi
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	53                   	push   %ebx
  800762:	83 ec 14             	sub    $0x14,%esp
  800765:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800768:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80076b:	50                   	push   %eax
  80076c:	53                   	push   %ebx
  80076d:	e8 ac fc ff ff       	call   80041e <fd_lookup>
  800772:	83 c4 08             	add    $0x8,%esp
  800775:	89 c2                	mov    %eax,%edx
  800777:	85 c0                	test   %eax,%eax
  800779:	78 68                	js     8007e3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077b:	83 ec 08             	sub    $0x8,%esp
  80077e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800781:	50                   	push   %eax
  800782:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800785:	ff 30                	pushl  (%eax)
  800787:	e8 e8 fc ff ff       	call   800474 <dev_lookup>
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	85 c0                	test   %eax,%eax
  800791:	78 47                	js     8007da <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800793:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800796:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80079a:	75 21                	jne    8007bd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80079c:	a1 08 40 80 00       	mov    0x804008,%eax
  8007a1:	8b 40 48             	mov    0x48(%eax),%eax
  8007a4:	83 ec 04             	sub    $0x4,%esp
  8007a7:	53                   	push   %ebx
  8007a8:	50                   	push   %eax
  8007a9:	68 f5 22 80 00       	push   $0x8022f5
  8007ae:	e8 12 0e 00 00       	call   8015c5 <cprintf>
		return -E_INVAL;
  8007b3:	83 c4 10             	add    $0x10,%esp
  8007b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007bb:	eb 26                	jmp    8007e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007c0:	8b 52 0c             	mov    0xc(%edx),%edx
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	74 17                	je     8007de <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c7:	83 ec 04             	sub    $0x4,%esp
  8007ca:	ff 75 10             	pushl  0x10(%ebp)
  8007cd:	ff 75 0c             	pushl  0xc(%ebp)
  8007d0:	50                   	push   %eax
  8007d1:	ff d2                	call   *%edx
  8007d3:	89 c2                	mov    %eax,%edx
  8007d5:	83 c4 10             	add    $0x10,%esp
  8007d8:	eb 09                	jmp    8007e3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007da:	89 c2                	mov    %eax,%edx
  8007dc:	eb 05                	jmp    8007e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007e3:	89 d0                	mov    %edx,%eax
  8007e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    

008007ea <seek>:

int
seek(int fdnum, off_t offset)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007f0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007f3:	50                   	push   %eax
  8007f4:	ff 75 08             	pushl  0x8(%ebp)
  8007f7:	e8 22 fc ff ff       	call   80041e <fd_lookup>
  8007fc:	83 c4 08             	add    $0x8,%esp
  8007ff:	85 c0                	test   %eax,%eax
  800801:	78 0e                	js     800811 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800803:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
  800809:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80080c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	83 ec 14             	sub    $0x14,%esp
  80081a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80081d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800820:	50                   	push   %eax
  800821:	53                   	push   %ebx
  800822:	e8 f7 fb ff ff       	call   80041e <fd_lookup>
  800827:	83 c4 08             	add    $0x8,%esp
  80082a:	89 c2                	mov    %eax,%edx
  80082c:	85 c0                	test   %eax,%eax
  80082e:	78 65                	js     800895 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800836:	50                   	push   %eax
  800837:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083a:	ff 30                	pushl  (%eax)
  80083c:	e8 33 fc ff ff       	call   800474 <dev_lookup>
  800841:	83 c4 10             	add    $0x10,%esp
  800844:	85 c0                	test   %eax,%eax
  800846:	78 44                	js     80088c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800848:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80084f:	75 21                	jne    800872 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800851:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800856:	8b 40 48             	mov    0x48(%eax),%eax
  800859:	83 ec 04             	sub    $0x4,%esp
  80085c:	53                   	push   %ebx
  80085d:	50                   	push   %eax
  80085e:	68 b8 22 80 00       	push   $0x8022b8
  800863:	e8 5d 0d 00 00       	call   8015c5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800868:	83 c4 10             	add    $0x10,%esp
  80086b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800870:	eb 23                	jmp    800895 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800872:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800875:	8b 52 18             	mov    0x18(%edx),%edx
  800878:	85 d2                	test   %edx,%edx
  80087a:	74 14                	je     800890 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80087c:	83 ec 08             	sub    $0x8,%esp
  80087f:	ff 75 0c             	pushl  0xc(%ebp)
  800882:	50                   	push   %eax
  800883:	ff d2                	call   *%edx
  800885:	89 c2                	mov    %eax,%edx
  800887:	83 c4 10             	add    $0x10,%esp
  80088a:	eb 09                	jmp    800895 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80088c:	89 c2                	mov    %eax,%edx
  80088e:	eb 05                	jmp    800895 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800890:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800895:	89 d0                	mov    %edx,%eax
  800897:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089a:	c9                   	leave  
  80089b:	c3                   	ret    

0080089c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	53                   	push   %ebx
  8008a0:	83 ec 14             	sub    $0x14,%esp
  8008a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a9:	50                   	push   %eax
  8008aa:	ff 75 08             	pushl  0x8(%ebp)
  8008ad:	e8 6c fb ff ff       	call   80041e <fd_lookup>
  8008b2:	83 c4 08             	add    $0x8,%esp
  8008b5:	89 c2                	mov    %eax,%edx
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	78 58                	js     800913 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c1:	50                   	push   %eax
  8008c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c5:	ff 30                	pushl  (%eax)
  8008c7:	e8 a8 fb ff ff       	call   800474 <dev_lookup>
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	78 37                	js     80090a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008da:	74 32                	je     80090e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008dc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008df:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008e6:	00 00 00 
	stat->st_isdir = 0;
  8008e9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008f0:	00 00 00 
	stat->st_dev = dev;
  8008f3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008f9:	83 ec 08             	sub    $0x8,%esp
  8008fc:	53                   	push   %ebx
  8008fd:	ff 75 f0             	pushl  -0x10(%ebp)
  800900:	ff 50 14             	call   *0x14(%eax)
  800903:	89 c2                	mov    %eax,%edx
  800905:	83 c4 10             	add    $0x10,%esp
  800908:	eb 09                	jmp    800913 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80090a:	89 c2                	mov    %eax,%edx
  80090c:	eb 05                	jmp    800913 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80090e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800913:	89 d0                	mov    %edx,%eax
  800915:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800918:	c9                   	leave  
  800919:	c3                   	ret    

0080091a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	56                   	push   %esi
  80091e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80091f:	83 ec 08             	sub    $0x8,%esp
  800922:	6a 00                	push   $0x0
  800924:	ff 75 08             	pushl  0x8(%ebp)
  800927:	e8 d6 01 00 00       	call   800b02 <open>
  80092c:	89 c3                	mov    %eax,%ebx
  80092e:	83 c4 10             	add    $0x10,%esp
  800931:	85 c0                	test   %eax,%eax
  800933:	78 1b                	js     800950 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800935:	83 ec 08             	sub    $0x8,%esp
  800938:	ff 75 0c             	pushl  0xc(%ebp)
  80093b:	50                   	push   %eax
  80093c:	e8 5b ff ff ff       	call   80089c <fstat>
  800941:	89 c6                	mov    %eax,%esi
	close(fd);
  800943:	89 1c 24             	mov    %ebx,(%esp)
  800946:	e8 fd fb ff ff       	call   800548 <close>
	return r;
  80094b:	83 c4 10             	add    $0x10,%esp
  80094e:	89 f0                	mov    %esi,%eax
}
  800950:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800953:	5b                   	pop    %ebx
  800954:	5e                   	pop    %esi
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	89 c6                	mov    %eax,%esi
  80095e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800960:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800967:	75 12                	jne    80097b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800969:	83 ec 0c             	sub    $0xc,%esp
  80096c:	6a 01                	push   $0x1
  80096e:	e8 d9 15 00 00       	call   801f4c <ipc_find_env>
  800973:	a3 00 40 80 00       	mov    %eax,0x804000
  800978:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80097b:	6a 07                	push   $0x7
  80097d:	68 00 50 80 00       	push   $0x805000
  800982:	56                   	push   %esi
  800983:	ff 35 00 40 80 00    	pushl  0x804000
  800989:	e8 6a 15 00 00       	call   801ef8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80098e:	83 c4 0c             	add    $0xc,%esp
  800991:	6a 00                	push   $0x0
  800993:	53                   	push   %ebx
  800994:	6a 00                	push   $0x0
  800996:	e8 f6 14 00 00       	call   801e91 <ipc_recv>
}
  80099b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8009c5:	e8 8d ff ff ff       	call   800957 <fsipc>
}
  8009ca:	c9                   	leave  
  8009cb:	c3                   	ret    

008009cc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8009e7:	e8 6b ff ff ff       	call   800957 <fsipc>
}
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	53                   	push   %ebx
  8009f2:	83 ec 04             	sub    $0x4,%esp
  8009f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fe:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a03:	ba 00 00 00 00       	mov    $0x0,%edx
  800a08:	b8 05 00 00 00       	mov    $0x5,%eax
  800a0d:	e8 45 ff ff ff       	call   800957 <fsipc>
  800a12:	85 c0                	test   %eax,%eax
  800a14:	78 2c                	js     800a42 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a16:	83 ec 08             	sub    $0x8,%esp
  800a19:	68 00 50 80 00       	push   $0x805000
  800a1e:	53                   	push   %ebx
  800a1f:	e8 26 11 00 00       	call   801b4a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a24:	a1 80 50 80 00       	mov    0x805080,%eax
  800a29:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a2f:	a1 84 50 80 00       	mov    0x805084,%eax
  800a34:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a3a:	83 c4 10             	add    $0x10,%esp
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    

00800a47 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	83 ec 0c             	sub    $0xc,%esp
  800a4d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a50:	8b 55 08             	mov    0x8(%ebp),%edx
  800a53:	8b 52 0c             	mov    0xc(%edx),%edx
  800a56:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a5c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a61:	50                   	push   %eax
  800a62:	ff 75 0c             	pushl  0xc(%ebp)
  800a65:	68 08 50 80 00       	push   $0x805008
  800a6a:	e8 6d 12 00 00       	call   801cdc <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a74:	b8 04 00 00 00       	mov    $0x4,%eax
  800a79:	e8 d9 fe ff ff       	call   800957 <fsipc>

}
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a93:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a99:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9e:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa3:	e8 af fe ff ff       	call   800957 <fsipc>
  800aa8:	89 c3                	mov    %eax,%ebx
  800aaa:	85 c0                	test   %eax,%eax
  800aac:	78 4b                	js     800af9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aae:	39 c6                	cmp    %eax,%esi
  800ab0:	73 16                	jae    800ac8 <devfile_read+0x48>
  800ab2:	68 28 23 80 00       	push   $0x802328
  800ab7:	68 2f 23 80 00       	push   $0x80232f
  800abc:	6a 7c                	push   $0x7c
  800abe:	68 44 23 80 00       	push   $0x802344
  800ac3:	e8 24 0a 00 00       	call   8014ec <_panic>
	assert(r <= PGSIZE);
  800ac8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800acd:	7e 16                	jle    800ae5 <devfile_read+0x65>
  800acf:	68 4f 23 80 00       	push   $0x80234f
  800ad4:	68 2f 23 80 00       	push   $0x80232f
  800ad9:	6a 7d                	push   $0x7d
  800adb:	68 44 23 80 00       	push   $0x802344
  800ae0:	e8 07 0a 00 00       	call   8014ec <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae5:	83 ec 04             	sub    $0x4,%esp
  800ae8:	50                   	push   %eax
  800ae9:	68 00 50 80 00       	push   $0x805000
  800aee:	ff 75 0c             	pushl  0xc(%ebp)
  800af1:	e8 e6 11 00 00       	call   801cdc <memmove>
	return r;
  800af6:	83 c4 10             	add    $0x10,%esp
}
  800af9:	89 d8                	mov    %ebx,%eax
  800afb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	53                   	push   %ebx
  800b06:	83 ec 20             	sub    $0x20,%esp
  800b09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b0c:	53                   	push   %ebx
  800b0d:	e8 ff 0f 00 00       	call   801b11 <strlen>
  800b12:	83 c4 10             	add    $0x10,%esp
  800b15:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1a:	7f 67                	jg     800b83 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b22:	50                   	push   %eax
  800b23:	e8 a7 f8 ff ff       	call   8003cf <fd_alloc>
  800b28:	83 c4 10             	add    $0x10,%esp
		return r;
  800b2b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	78 57                	js     800b88 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b31:	83 ec 08             	sub    $0x8,%esp
  800b34:	53                   	push   %ebx
  800b35:	68 00 50 80 00       	push   $0x805000
  800b3a:	e8 0b 10 00 00       	call   801b4a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b42:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b47:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4f:	e8 03 fe ff ff       	call   800957 <fsipc>
  800b54:	89 c3                	mov    %eax,%ebx
  800b56:	83 c4 10             	add    $0x10,%esp
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	79 14                	jns    800b71 <open+0x6f>
		fd_close(fd, 0);
  800b5d:	83 ec 08             	sub    $0x8,%esp
  800b60:	6a 00                	push   $0x0
  800b62:	ff 75 f4             	pushl  -0xc(%ebp)
  800b65:	e8 5d f9 ff ff       	call   8004c7 <fd_close>
		return r;
  800b6a:	83 c4 10             	add    $0x10,%esp
  800b6d:	89 da                	mov    %ebx,%edx
  800b6f:	eb 17                	jmp    800b88 <open+0x86>
	}

	return fd2num(fd);
  800b71:	83 ec 0c             	sub    $0xc,%esp
  800b74:	ff 75 f4             	pushl  -0xc(%ebp)
  800b77:	e8 2c f8 ff ff       	call   8003a8 <fd2num>
  800b7c:	89 c2                	mov    %eax,%edx
  800b7e:	83 c4 10             	add    $0x10,%esp
  800b81:	eb 05                	jmp    800b88 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b83:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b88:	89 d0                	mov    %edx,%eax
  800b8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9f:	e8 b3 fd ff ff       	call   800957 <fsipc>
}
  800ba4:	c9                   	leave  
  800ba5:	c3                   	ret    

00800ba6 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bac:	68 5b 23 80 00       	push   $0x80235b
  800bb1:	ff 75 0c             	pushl  0xc(%ebp)
  800bb4:	e8 91 0f 00 00       	call   801b4a <strcpy>
	return 0;
}
  800bb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 10             	sub    $0x10,%esp
  800bc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bca:	53                   	push   %ebx
  800bcb:	e8 b5 13 00 00       	call   801f85 <pageref>
  800bd0:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bd3:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bd8:	83 f8 01             	cmp    $0x1,%eax
  800bdb:	75 10                	jne    800bed <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	ff 73 0c             	pushl  0xc(%ebx)
  800be3:	e8 c0 02 00 00       	call   800ea8 <nsipc_close>
  800be8:	89 c2                	mov    %eax,%edx
  800bea:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bed:	89 d0                	mov    %edx,%eax
  800bef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bfa:	6a 00                	push   $0x0
  800bfc:	ff 75 10             	pushl  0x10(%ebp)
  800bff:	ff 75 0c             	pushl  0xc(%ebp)
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
  800c05:	ff 70 0c             	pushl  0xc(%eax)
  800c08:	e8 78 03 00 00       	call   800f85 <nsipc_send>
}
  800c0d:	c9                   	leave  
  800c0e:	c3                   	ret    

00800c0f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c15:	6a 00                	push   $0x0
  800c17:	ff 75 10             	pushl  0x10(%ebp)
  800c1a:	ff 75 0c             	pushl  0xc(%ebp)
  800c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c20:	ff 70 0c             	pushl  0xc(%eax)
  800c23:	e8 f1 02 00 00       	call   800f19 <nsipc_recv>
}
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c30:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c33:	52                   	push   %edx
  800c34:	50                   	push   %eax
  800c35:	e8 e4 f7 ff ff       	call   80041e <fd_lookup>
  800c3a:	83 c4 10             	add    $0x10,%esp
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	78 17                	js     800c58 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c44:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c4a:	39 08                	cmp    %ecx,(%eax)
  800c4c:	75 05                	jne    800c53 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c4e:	8b 40 0c             	mov    0xc(%eax),%eax
  800c51:	eb 05                	jmp    800c58 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c53:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    

00800c5a <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	83 ec 1c             	sub    $0x1c,%esp
  800c62:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c67:	50                   	push   %eax
  800c68:	e8 62 f7 ff ff       	call   8003cf <fd_alloc>
  800c6d:	89 c3                	mov    %eax,%ebx
  800c6f:	83 c4 10             	add    $0x10,%esp
  800c72:	85 c0                	test   %eax,%eax
  800c74:	78 1b                	js     800c91 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c76:	83 ec 04             	sub    $0x4,%esp
  800c79:	68 07 04 00 00       	push   $0x407
  800c7e:	ff 75 f4             	pushl  -0xc(%ebp)
  800c81:	6a 00                	push   $0x0
  800c83:	e8 ce f4 ff ff       	call   800156 <sys_page_alloc>
  800c88:	89 c3                	mov    %eax,%ebx
  800c8a:	83 c4 10             	add    $0x10,%esp
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	79 10                	jns    800ca1 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c91:	83 ec 0c             	sub    $0xc,%esp
  800c94:	56                   	push   %esi
  800c95:	e8 0e 02 00 00       	call   800ea8 <nsipc_close>
		return r;
  800c9a:	83 c4 10             	add    $0x10,%esp
  800c9d:	89 d8                	mov    %ebx,%eax
  800c9f:	eb 24                	jmp    800cc5 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ca1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800caa:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800caf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cb6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	50                   	push   %eax
  800cbd:	e8 e6 f6 ff ff       	call   8003a8 <fd2num>
  800cc2:	83 c4 10             	add    $0x10,%esp
}
  800cc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd5:	e8 50 ff ff ff       	call   800c2a <fd2sockid>
		return r;
  800cda:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	78 1f                	js     800cff <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ce0:	83 ec 04             	sub    $0x4,%esp
  800ce3:	ff 75 10             	pushl  0x10(%ebp)
  800ce6:	ff 75 0c             	pushl  0xc(%ebp)
  800ce9:	50                   	push   %eax
  800cea:	e8 12 01 00 00       	call   800e01 <nsipc_accept>
  800cef:	83 c4 10             	add    $0x10,%esp
		return r;
  800cf2:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	78 07                	js     800cff <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cf8:	e8 5d ff ff ff       	call   800c5a <alloc_sockfd>
  800cfd:	89 c1                	mov    %eax,%ecx
}
  800cff:	89 c8                	mov    %ecx,%eax
  800d01:	c9                   	leave  
  800d02:	c3                   	ret    

00800d03 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d09:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0c:	e8 19 ff ff ff       	call   800c2a <fd2sockid>
  800d11:	85 c0                	test   %eax,%eax
  800d13:	78 12                	js     800d27 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d15:	83 ec 04             	sub    $0x4,%esp
  800d18:	ff 75 10             	pushl  0x10(%ebp)
  800d1b:	ff 75 0c             	pushl  0xc(%ebp)
  800d1e:	50                   	push   %eax
  800d1f:	e8 2d 01 00 00       	call   800e51 <nsipc_bind>
  800d24:	83 c4 10             	add    $0x10,%esp
}
  800d27:	c9                   	leave  
  800d28:	c3                   	ret    

00800d29 <shutdown>:

int
shutdown(int s, int how)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	e8 f3 fe ff ff       	call   800c2a <fd2sockid>
  800d37:	85 c0                	test   %eax,%eax
  800d39:	78 0f                	js     800d4a <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d3b:	83 ec 08             	sub    $0x8,%esp
  800d3e:	ff 75 0c             	pushl  0xc(%ebp)
  800d41:	50                   	push   %eax
  800d42:	e8 3f 01 00 00       	call   800e86 <nsipc_shutdown>
  800d47:	83 c4 10             	add    $0x10,%esp
}
  800d4a:	c9                   	leave  
  800d4b:	c3                   	ret    

00800d4c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	e8 d0 fe ff ff       	call   800c2a <fd2sockid>
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	78 12                	js     800d70 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d5e:	83 ec 04             	sub    $0x4,%esp
  800d61:	ff 75 10             	pushl  0x10(%ebp)
  800d64:	ff 75 0c             	pushl  0xc(%ebp)
  800d67:	50                   	push   %eax
  800d68:	e8 55 01 00 00       	call   800ec2 <nsipc_connect>
  800d6d:	83 c4 10             	add    $0x10,%esp
}
  800d70:	c9                   	leave  
  800d71:	c3                   	ret    

00800d72 <listen>:

int
listen(int s, int backlog)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d78:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7b:	e8 aa fe ff ff       	call   800c2a <fd2sockid>
  800d80:	85 c0                	test   %eax,%eax
  800d82:	78 0f                	js     800d93 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d84:	83 ec 08             	sub    $0x8,%esp
  800d87:	ff 75 0c             	pushl  0xc(%ebp)
  800d8a:	50                   	push   %eax
  800d8b:	e8 67 01 00 00       	call   800ef7 <nsipc_listen>
  800d90:	83 c4 10             	add    $0x10,%esp
}
  800d93:	c9                   	leave  
  800d94:	c3                   	ret    

00800d95 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d9b:	ff 75 10             	pushl  0x10(%ebp)
  800d9e:	ff 75 0c             	pushl  0xc(%ebp)
  800da1:	ff 75 08             	pushl  0x8(%ebp)
  800da4:	e8 3a 02 00 00       	call   800fe3 <nsipc_socket>
  800da9:	83 c4 10             	add    $0x10,%esp
  800dac:	85 c0                	test   %eax,%eax
  800dae:	78 05                	js     800db5 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800db0:	e8 a5 fe ff ff       	call   800c5a <alloc_sockfd>
}
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    

00800db7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 04             	sub    $0x4,%esp
  800dbe:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dc0:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dc7:	75 12                	jne    800ddb <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	6a 02                	push   $0x2
  800dce:	e8 79 11 00 00       	call   801f4c <ipc_find_env>
  800dd3:	a3 04 40 80 00       	mov    %eax,0x804004
  800dd8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800ddb:	6a 07                	push   $0x7
  800ddd:	68 00 60 80 00       	push   $0x806000
  800de2:	53                   	push   %ebx
  800de3:	ff 35 04 40 80 00    	pushl  0x804004
  800de9:	e8 0a 11 00 00       	call   801ef8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dee:	83 c4 0c             	add    $0xc,%esp
  800df1:	6a 00                	push   $0x0
  800df3:	6a 00                	push   $0x0
  800df5:	6a 00                	push   $0x0
  800df7:	e8 95 10 00 00       	call   801e91 <ipc_recv>
}
  800dfc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dff:	c9                   	leave  
  800e00:	c3                   	ret    

00800e01 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e09:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e11:	8b 06                	mov    (%esi),%eax
  800e13:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e18:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1d:	e8 95 ff ff ff       	call   800db7 <nsipc>
  800e22:	89 c3                	mov    %eax,%ebx
  800e24:	85 c0                	test   %eax,%eax
  800e26:	78 20                	js     800e48 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e28:	83 ec 04             	sub    $0x4,%esp
  800e2b:	ff 35 10 60 80 00    	pushl  0x806010
  800e31:	68 00 60 80 00       	push   $0x806000
  800e36:	ff 75 0c             	pushl  0xc(%ebp)
  800e39:	e8 9e 0e 00 00       	call   801cdc <memmove>
		*addrlen = ret->ret_addrlen;
  800e3e:	a1 10 60 80 00       	mov    0x806010,%eax
  800e43:	89 06                	mov    %eax,(%esi)
  800e45:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e48:	89 d8                	mov    %ebx,%eax
  800e4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	53                   	push   %ebx
  800e55:	83 ec 08             	sub    $0x8,%esp
  800e58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e63:	53                   	push   %ebx
  800e64:	ff 75 0c             	pushl  0xc(%ebp)
  800e67:	68 04 60 80 00       	push   $0x806004
  800e6c:	e8 6b 0e 00 00       	call   801cdc <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e71:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e77:	b8 02 00 00 00       	mov    $0x2,%eax
  800e7c:	e8 36 ff ff ff       	call   800db7 <nsipc>
}
  800e81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e84:	c9                   	leave  
  800e85:	c3                   	ret    

00800e86 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e97:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e9c:	b8 03 00 00 00       	mov    $0x3,%eax
  800ea1:	e8 11 ff ff ff       	call   800db7 <nsipc>
}
  800ea6:	c9                   	leave  
  800ea7:	c3                   	ret    

00800ea8 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb1:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eb6:	b8 04 00 00 00       	mov    $0x4,%eax
  800ebb:	e8 f7 fe ff ff       	call   800db7 <nsipc>
}
  800ec0:	c9                   	leave  
  800ec1:	c3                   	ret    

00800ec2 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	53                   	push   %ebx
  800ec6:	83 ec 08             	sub    $0x8,%esp
  800ec9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecf:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ed4:	53                   	push   %ebx
  800ed5:	ff 75 0c             	pushl  0xc(%ebp)
  800ed8:	68 04 60 80 00       	push   $0x806004
  800edd:	e8 fa 0d 00 00       	call   801cdc <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ee2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ee8:	b8 05 00 00 00       	mov    $0x5,%eax
  800eed:	e8 c5 fe ff ff       	call   800db7 <nsipc>
}
  800ef2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800efd:	8b 45 08             	mov    0x8(%ebp),%eax
  800f00:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f08:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f0d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f12:	e8 a0 fe ff ff       	call   800db7 <nsipc>
}
  800f17:	c9                   	leave  
  800f18:	c3                   	ret    

00800f19 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	56                   	push   %esi
  800f1d:	53                   	push   %ebx
  800f1e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f21:	8b 45 08             	mov    0x8(%ebp),%eax
  800f24:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f29:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f2f:	8b 45 14             	mov    0x14(%ebp),%eax
  800f32:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f37:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3c:	e8 76 fe ff ff       	call   800db7 <nsipc>
  800f41:	89 c3                	mov    %eax,%ebx
  800f43:	85 c0                	test   %eax,%eax
  800f45:	78 35                	js     800f7c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f47:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f4c:	7f 04                	jg     800f52 <nsipc_recv+0x39>
  800f4e:	39 c6                	cmp    %eax,%esi
  800f50:	7d 16                	jge    800f68 <nsipc_recv+0x4f>
  800f52:	68 67 23 80 00       	push   $0x802367
  800f57:	68 2f 23 80 00       	push   $0x80232f
  800f5c:	6a 62                	push   $0x62
  800f5e:	68 7c 23 80 00       	push   $0x80237c
  800f63:	e8 84 05 00 00       	call   8014ec <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f68:	83 ec 04             	sub    $0x4,%esp
  800f6b:	50                   	push   %eax
  800f6c:	68 00 60 80 00       	push   $0x806000
  800f71:	ff 75 0c             	pushl  0xc(%ebp)
  800f74:	e8 63 0d 00 00       	call   801cdc <memmove>
  800f79:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f7c:	89 d8                	mov    %ebx,%eax
  800f7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    

00800f85 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	53                   	push   %ebx
  800f89:	83 ec 04             	sub    $0x4,%esp
  800f8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f92:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f97:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f9d:	7e 16                	jle    800fb5 <nsipc_send+0x30>
  800f9f:	68 88 23 80 00       	push   $0x802388
  800fa4:	68 2f 23 80 00       	push   $0x80232f
  800fa9:	6a 6d                	push   $0x6d
  800fab:	68 7c 23 80 00       	push   $0x80237c
  800fb0:	e8 37 05 00 00       	call   8014ec <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fb5:	83 ec 04             	sub    $0x4,%esp
  800fb8:	53                   	push   %ebx
  800fb9:	ff 75 0c             	pushl  0xc(%ebp)
  800fbc:	68 0c 60 80 00       	push   $0x80600c
  800fc1:	e8 16 0d 00 00       	call   801cdc <memmove>
	nsipcbuf.send.req_size = size;
  800fc6:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fcc:	8b 45 14             	mov    0x14(%ebp),%eax
  800fcf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fd4:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd9:	e8 d9 fd ff ff       	call   800db7 <nsipc>
}
  800fde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe1:	c9                   	leave  
  800fe2:	c3                   	ret    

00800fe3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fec:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ff9:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801001:	b8 09 00 00 00       	mov    $0x9,%eax
  801006:	e8 ac fd ff ff       	call   800db7 <nsipc>
}
  80100b:	c9                   	leave  
  80100c:	c3                   	ret    

0080100d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	ff 75 08             	pushl  0x8(%ebp)
  80101b:	e8 98 f3 ff ff       	call   8003b8 <fd2data>
  801020:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801022:	83 c4 08             	add    $0x8,%esp
  801025:	68 94 23 80 00       	push   $0x802394
  80102a:	53                   	push   %ebx
  80102b:	e8 1a 0b 00 00       	call   801b4a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801030:	8b 46 04             	mov    0x4(%esi),%eax
  801033:	2b 06                	sub    (%esi),%eax
  801035:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80103b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801042:	00 00 00 
	stat->st_dev = &devpipe;
  801045:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80104c:	30 80 00 
	return 0;
}
  80104f:	b8 00 00 00 00       	mov    $0x0,%eax
  801054:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801057:	5b                   	pop    %ebx
  801058:	5e                   	pop    %esi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	53                   	push   %ebx
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801065:	53                   	push   %ebx
  801066:	6a 00                	push   $0x0
  801068:	e8 6e f1 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80106d:	89 1c 24             	mov    %ebx,(%esp)
  801070:	e8 43 f3 ff ff       	call   8003b8 <fd2data>
  801075:	83 c4 08             	add    $0x8,%esp
  801078:	50                   	push   %eax
  801079:	6a 00                	push   $0x0
  80107b:	e8 5b f1 ff ff       	call   8001db <sys_page_unmap>
}
  801080:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801083:	c9                   	leave  
  801084:	c3                   	ret    

00801085 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	57                   	push   %edi
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
  80108b:	83 ec 1c             	sub    $0x1c,%esp
  80108e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801091:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801093:	a1 08 40 80 00       	mov    0x804008,%eax
  801098:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	ff 75 e0             	pushl  -0x20(%ebp)
  8010a1:	e8 df 0e 00 00       	call   801f85 <pageref>
  8010a6:	89 c3                	mov    %eax,%ebx
  8010a8:	89 3c 24             	mov    %edi,(%esp)
  8010ab:	e8 d5 0e 00 00       	call   801f85 <pageref>
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	39 c3                	cmp    %eax,%ebx
  8010b5:	0f 94 c1             	sete   %cl
  8010b8:	0f b6 c9             	movzbl %cl,%ecx
  8010bb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010be:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010c4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010c7:	39 ce                	cmp    %ecx,%esi
  8010c9:	74 1b                	je     8010e6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010cb:	39 c3                	cmp    %eax,%ebx
  8010cd:	75 c4                	jne    801093 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010cf:	8b 42 58             	mov    0x58(%edx),%eax
  8010d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d5:	50                   	push   %eax
  8010d6:	56                   	push   %esi
  8010d7:	68 9b 23 80 00       	push   $0x80239b
  8010dc:	e8 e4 04 00 00       	call   8015c5 <cprintf>
  8010e1:	83 c4 10             	add    $0x10,%esp
  8010e4:	eb ad                	jmp    801093 <_pipeisclosed+0xe>
	}
}
  8010e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ec:	5b                   	pop    %ebx
  8010ed:	5e                   	pop    %esi
  8010ee:	5f                   	pop    %edi
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	57                   	push   %edi
  8010f5:	56                   	push   %esi
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 28             	sub    $0x28,%esp
  8010fa:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010fd:	56                   	push   %esi
  8010fe:	e8 b5 f2 ff ff       	call   8003b8 <fd2data>
  801103:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	bf 00 00 00 00       	mov    $0x0,%edi
  80110d:	eb 4b                	jmp    80115a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80110f:	89 da                	mov    %ebx,%edx
  801111:	89 f0                	mov    %esi,%eax
  801113:	e8 6d ff ff ff       	call   801085 <_pipeisclosed>
  801118:	85 c0                	test   %eax,%eax
  80111a:	75 48                	jne    801164 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80111c:	e8 16 f0 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801121:	8b 43 04             	mov    0x4(%ebx),%eax
  801124:	8b 0b                	mov    (%ebx),%ecx
  801126:	8d 51 20             	lea    0x20(%ecx),%edx
  801129:	39 d0                	cmp    %edx,%eax
  80112b:	73 e2                	jae    80110f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80112d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801130:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801134:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801137:	89 c2                	mov    %eax,%edx
  801139:	c1 fa 1f             	sar    $0x1f,%edx
  80113c:	89 d1                	mov    %edx,%ecx
  80113e:	c1 e9 1b             	shr    $0x1b,%ecx
  801141:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801144:	83 e2 1f             	and    $0x1f,%edx
  801147:	29 ca                	sub    %ecx,%edx
  801149:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80114d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801151:	83 c0 01             	add    $0x1,%eax
  801154:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801157:	83 c7 01             	add    $0x1,%edi
  80115a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80115d:	75 c2                	jne    801121 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80115f:	8b 45 10             	mov    0x10(%ebp),%eax
  801162:	eb 05                	jmp    801169 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801164:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801169:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5f                   	pop    %edi
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	57                   	push   %edi
  801175:	56                   	push   %esi
  801176:	53                   	push   %ebx
  801177:	83 ec 18             	sub    $0x18,%esp
  80117a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80117d:	57                   	push   %edi
  80117e:	e8 35 f2 ff ff       	call   8003b8 <fd2data>
  801183:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118d:	eb 3d                	jmp    8011cc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80118f:	85 db                	test   %ebx,%ebx
  801191:	74 04                	je     801197 <devpipe_read+0x26>
				return i;
  801193:	89 d8                	mov    %ebx,%eax
  801195:	eb 44                	jmp    8011db <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801197:	89 f2                	mov    %esi,%edx
  801199:	89 f8                	mov    %edi,%eax
  80119b:	e8 e5 fe ff ff       	call   801085 <_pipeisclosed>
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	75 32                	jne    8011d6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011a4:	e8 8e ef ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011a9:	8b 06                	mov    (%esi),%eax
  8011ab:	3b 46 04             	cmp    0x4(%esi),%eax
  8011ae:	74 df                	je     80118f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011b0:	99                   	cltd   
  8011b1:	c1 ea 1b             	shr    $0x1b,%edx
  8011b4:	01 d0                	add    %edx,%eax
  8011b6:	83 e0 1f             	and    $0x1f,%eax
  8011b9:	29 d0                	sub    %edx,%eax
  8011bb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011c6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c9:	83 c3 01             	add    $0x1,%ebx
  8011cc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011cf:	75 d8                	jne    8011a9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d4:	eb 05                	jmp    8011db <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011d6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011de:	5b                   	pop    %ebx
  8011df:	5e                   	pop    %esi
  8011e0:	5f                   	pop    %edi
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	56                   	push   %esi
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ee:	50                   	push   %eax
  8011ef:	e8 db f1 ff ff       	call   8003cf <fd_alloc>
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	89 c2                	mov    %eax,%edx
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	0f 88 2c 01 00 00    	js     80132d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801201:	83 ec 04             	sub    $0x4,%esp
  801204:	68 07 04 00 00       	push   $0x407
  801209:	ff 75 f4             	pushl  -0xc(%ebp)
  80120c:	6a 00                	push   $0x0
  80120e:	e8 43 ef ff ff       	call   800156 <sys_page_alloc>
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	89 c2                	mov    %eax,%edx
  801218:	85 c0                	test   %eax,%eax
  80121a:	0f 88 0d 01 00 00    	js     80132d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801220:	83 ec 0c             	sub    $0xc,%esp
  801223:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801226:	50                   	push   %eax
  801227:	e8 a3 f1 ff ff       	call   8003cf <fd_alloc>
  80122c:	89 c3                	mov    %eax,%ebx
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	85 c0                	test   %eax,%eax
  801233:	0f 88 e2 00 00 00    	js     80131b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801239:	83 ec 04             	sub    $0x4,%esp
  80123c:	68 07 04 00 00       	push   $0x407
  801241:	ff 75 f0             	pushl  -0x10(%ebp)
  801244:	6a 00                	push   $0x0
  801246:	e8 0b ef ff ff       	call   800156 <sys_page_alloc>
  80124b:	89 c3                	mov    %eax,%ebx
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	0f 88 c3 00 00 00    	js     80131b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801258:	83 ec 0c             	sub    $0xc,%esp
  80125b:	ff 75 f4             	pushl  -0xc(%ebp)
  80125e:	e8 55 f1 ff ff       	call   8003b8 <fd2data>
  801263:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801265:	83 c4 0c             	add    $0xc,%esp
  801268:	68 07 04 00 00       	push   $0x407
  80126d:	50                   	push   %eax
  80126e:	6a 00                	push   $0x0
  801270:	e8 e1 ee ff ff       	call   800156 <sys_page_alloc>
  801275:	89 c3                	mov    %eax,%ebx
  801277:	83 c4 10             	add    $0x10,%esp
  80127a:	85 c0                	test   %eax,%eax
  80127c:	0f 88 89 00 00 00    	js     80130b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801282:	83 ec 0c             	sub    $0xc,%esp
  801285:	ff 75 f0             	pushl  -0x10(%ebp)
  801288:	e8 2b f1 ff ff       	call   8003b8 <fd2data>
  80128d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801294:	50                   	push   %eax
  801295:	6a 00                	push   $0x0
  801297:	56                   	push   %esi
  801298:	6a 00                	push   $0x0
  80129a:	e8 fa ee ff ff       	call   800199 <sys_page_map>
  80129f:	89 c3                	mov    %eax,%ebx
  8012a1:	83 c4 20             	add    $0x20,%esp
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 55                	js     8012fd <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012a8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012bd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012d2:	83 ec 0c             	sub    $0xc,%esp
  8012d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d8:	e8 cb f0 ff ff       	call   8003a8 <fd2num>
  8012dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012e2:	83 c4 04             	add    $0x4,%esp
  8012e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e8:	e8 bb f0 ff ff       	call   8003a8 <fd2num>
  8012ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fb:	eb 30                	jmp    80132d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012fd:	83 ec 08             	sub    $0x8,%esp
  801300:	56                   	push   %esi
  801301:	6a 00                	push   $0x0
  801303:	e8 d3 ee ff ff       	call   8001db <sys_page_unmap>
  801308:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	ff 75 f0             	pushl  -0x10(%ebp)
  801311:	6a 00                	push   $0x0
  801313:	e8 c3 ee ff ff       	call   8001db <sys_page_unmap>
  801318:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	ff 75 f4             	pushl  -0xc(%ebp)
  801321:	6a 00                	push   $0x0
  801323:	e8 b3 ee ff ff       	call   8001db <sys_page_unmap>
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80132d:	89 d0                	mov    %edx,%eax
  80132f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801332:	5b                   	pop    %ebx
  801333:	5e                   	pop    %esi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    

00801336 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133f:	50                   	push   %eax
  801340:	ff 75 08             	pushl  0x8(%ebp)
  801343:	e8 d6 f0 ff ff       	call   80041e <fd_lookup>
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 18                	js     801367 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	ff 75 f4             	pushl  -0xc(%ebp)
  801355:	e8 5e f0 ff ff       	call   8003b8 <fd2data>
	return _pipeisclosed(fd, p);
  80135a:	89 c2                	mov    %eax,%edx
  80135c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135f:	e8 21 fd ff ff       	call   801085 <_pipeisclosed>
  801364:	83 c4 10             	add    $0x10,%esp
}
  801367:	c9                   	leave  
  801368:	c3                   	ret    

00801369 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80136c:	b8 00 00 00 00       	mov    $0x0,%eax
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801379:	68 b3 23 80 00       	push   $0x8023b3
  80137e:	ff 75 0c             	pushl  0xc(%ebp)
  801381:	e8 c4 07 00 00       	call   801b4a <strcpy>
	return 0;
}
  801386:	b8 00 00 00 00       	mov    $0x0,%eax
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    

0080138d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	57                   	push   %edi
  801391:	56                   	push   %esi
  801392:	53                   	push   %ebx
  801393:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801399:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80139e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a4:	eb 2d                	jmp    8013d3 <devcons_write+0x46>
		m = n - tot;
  8013a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013ab:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013ae:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013b3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013b6:	83 ec 04             	sub    $0x4,%esp
  8013b9:	53                   	push   %ebx
  8013ba:	03 45 0c             	add    0xc(%ebp),%eax
  8013bd:	50                   	push   %eax
  8013be:	57                   	push   %edi
  8013bf:	e8 18 09 00 00       	call   801cdc <memmove>
		sys_cputs(buf, m);
  8013c4:	83 c4 08             	add    $0x8,%esp
  8013c7:	53                   	push   %ebx
  8013c8:	57                   	push   %edi
  8013c9:	e8 cc ec ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013ce:	01 de                	add    %ebx,%esi
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	89 f0                	mov    %esi,%eax
  8013d5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013d8:	72 cc                	jb     8013a6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5e                   	pop    %esi
  8013df:	5f                   	pop    %edi
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    

008013e2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f1:	74 2a                	je     80141d <devcons_read+0x3b>
  8013f3:	eb 05                	jmp    8013fa <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013f5:	e8 3d ed ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013fa:	e8 b9 ec ff ff       	call   8000b8 <sys_cgetc>
  8013ff:	85 c0                	test   %eax,%eax
  801401:	74 f2                	je     8013f5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801403:	85 c0                	test   %eax,%eax
  801405:	78 16                	js     80141d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801407:	83 f8 04             	cmp    $0x4,%eax
  80140a:	74 0c                	je     801418 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80140c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140f:	88 02                	mov    %al,(%edx)
	return 1;
  801411:	b8 01 00 00 00       	mov    $0x1,%eax
  801416:	eb 05                	jmp    80141d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801418:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801425:	8b 45 08             	mov    0x8(%ebp),%eax
  801428:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80142b:	6a 01                	push   $0x1
  80142d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801430:	50                   	push   %eax
  801431:	e8 64 ec ff ff       	call   80009a <sys_cputs>
}
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	c9                   	leave  
  80143a:	c3                   	ret    

0080143b <getchar>:

int
getchar(void)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801441:	6a 01                	push   $0x1
  801443:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801446:	50                   	push   %eax
  801447:	6a 00                	push   $0x0
  801449:	e8 36 f2 ff ff       	call   800684 <read>
	if (r < 0)
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	85 c0                	test   %eax,%eax
  801453:	78 0f                	js     801464 <getchar+0x29>
		return r;
	if (r < 1)
  801455:	85 c0                	test   %eax,%eax
  801457:	7e 06                	jle    80145f <getchar+0x24>
		return -E_EOF;
	return c;
  801459:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80145d:	eb 05                	jmp    801464 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80145f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801464:	c9                   	leave  
  801465:	c3                   	ret    

00801466 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80146c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146f:	50                   	push   %eax
  801470:	ff 75 08             	pushl  0x8(%ebp)
  801473:	e8 a6 ef ff ff       	call   80041e <fd_lookup>
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	85 c0                	test   %eax,%eax
  80147d:	78 11                	js     801490 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80147f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801482:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801488:	39 10                	cmp    %edx,(%eax)
  80148a:	0f 94 c0             	sete   %al
  80148d:	0f b6 c0             	movzbl %al,%eax
}
  801490:	c9                   	leave  
  801491:	c3                   	ret    

00801492 <opencons>:

int
opencons(void)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801498:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149b:	50                   	push   %eax
  80149c:	e8 2e ef ff ff       	call   8003cf <fd_alloc>
  8014a1:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 3e                	js     8014e8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014aa:	83 ec 04             	sub    $0x4,%esp
  8014ad:	68 07 04 00 00       	push   $0x407
  8014b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b5:	6a 00                	push   $0x0
  8014b7:	e8 9a ec ff ff       	call   800156 <sys_page_alloc>
  8014bc:	83 c4 10             	add    $0x10,%esp
		return r;
  8014bf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 23                	js     8014e8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014c5:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ce:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014da:	83 ec 0c             	sub    $0xc,%esp
  8014dd:	50                   	push   %eax
  8014de:	e8 c5 ee ff ff       	call   8003a8 <fd2num>
  8014e3:	89 c2                	mov    %eax,%edx
  8014e5:	83 c4 10             	add    $0x10,%esp
}
  8014e8:	89 d0                	mov    %edx,%eax
  8014ea:	c9                   	leave  
  8014eb:	c3                   	ret    

008014ec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	56                   	push   %esi
  8014f0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014f1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014f4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014fa:	e8 19 ec ff ff       	call   800118 <sys_getenvid>
  8014ff:	83 ec 0c             	sub    $0xc,%esp
  801502:	ff 75 0c             	pushl  0xc(%ebp)
  801505:	ff 75 08             	pushl  0x8(%ebp)
  801508:	56                   	push   %esi
  801509:	50                   	push   %eax
  80150a:	68 c0 23 80 00       	push   $0x8023c0
  80150f:	e8 b1 00 00 00       	call   8015c5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801514:	83 c4 18             	add    $0x18,%esp
  801517:	53                   	push   %ebx
  801518:	ff 75 10             	pushl  0x10(%ebp)
  80151b:	e8 54 00 00 00       	call   801574 <vcprintf>
	cprintf("\n");
  801520:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  801527:	e8 99 00 00 00       	call   8015c5 <cprintf>
  80152c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80152f:	cc                   	int3   
  801530:	eb fd                	jmp    80152f <_panic+0x43>

00801532 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	53                   	push   %ebx
  801536:	83 ec 04             	sub    $0x4,%esp
  801539:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80153c:	8b 13                	mov    (%ebx),%edx
  80153e:	8d 42 01             	lea    0x1(%edx),%eax
  801541:	89 03                	mov    %eax,(%ebx)
  801543:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801546:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80154a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80154f:	75 1a                	jne    80156b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801551:	83 ec 08             	sub    $0x8,%esp
  801554:	68 ff 00 00 00       	push   $0xff
  801559:	8d 43 08             	lea    0x8(%ebx),%eax
  80155c:	50                   	push   %eax
  80155d:	e8 38 eb ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  801562:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801568:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80156b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80156f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801572:	c9                   	leave  
  801573:	c3                   	ret    

00801574 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80157d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801584:	00 00 00 
	b.cnt = 0;
  801587:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80158e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801591:	ff 75 0c             	pushl  0xc(%ebp)
  801594:	ff 75 08             	pushl  0x8(%ebp)
  801597:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	68 32 15 80 00       	push   $0x801532
  8015a3:	e8 54 01 00 00       	call   8016fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015a8:	83 c4 08             	add    $0x8,%esp
  8015ab:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015b1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015b7:	50                   	push   %eax
  8015b8:	e8 dd ea ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8015bd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015c3:	c9                   	leave  
  8015c4:	c3                   	ret    

008015c5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015cb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015ce:	50                   	push   %eax
  8015cf:	ff 75 08             	pushl  0x8(%ebp)
  8015d2:	e8 9d ff ff ff       	call   801574 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015d7:	c9                   	leave  
  8015d8:	c3                   	ret    

008015d9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015d9:	55                   	push   %ebp
  8015da:	89 e5                	mov    %esp,%ebp
  8015dc:	57                   	push   %edi
  8015dd:	56                   	push   %esi
  8015de:	53                   	push   %ebx
  8015df:	83 ec 1c             	sub    $0x1c,%esp
  8015e2:	89 c7                	mov    %eax,%edi
  8015e4:	89 d6                	mov    %edx,%esi
  8015e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015fd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801600:	39 d3                	cmp    %edx,%ebx
  801602:	72 05                	jb     801609 <printnum+0x30>
  801604:	39 45 10             	cmp    %eax,0x10(%ebp)
  801607:	77 45                	ja     80164e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801609:	83 ec 0c             	sub    $0xc,%esp
  80160c:	ff 75 18             	pushl  0x18(%ebp)
  80160f:	8b 45 14             	mov    0x14(%ebp),%eax
  801612:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801615:	53                   	push   %ebx
  801616:	ff 75 10             	pushl  0x10(%ebp)
  801619:	83 ec 08             	sub    $0x8,%esp
  80161c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161f:	ff 75 e0             	pushl  -0x20(%ebp)
  801622:	ff 75 dc             	pushl  -0x24(%ebp)
  801625:	ff 75 d8             	pushl  -0x28(%ebp)
  801628:	e8 93 09 00 00       	call   801fc0 <__udivdi3>
  80162d:	83 c4 18             	add    $0x18,%esp
  801630:	52                   	push   %edx
  801631:	50                   	push   %eax
  801632:	89 f2                	mov    %esi,%edx
  801634:	89 f8                	mov    %edi,%eax
  801636:	e8 9e ff ff ff       	call   8015d9 <printnum>
  80163b:	83 c4 20             	add    $0x20,%esp
  80163e:	eb 18                	jmp    801658 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801640:	83 ec 08             	sub    $0x8,%esp
  801643:	56                   	push   %esi
  801644:	ff 75 18             	pushl  0x18(%ebp)
  801647:	ff d7                	call   *%edi
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	eb 03                	jmp    801651 <printnum+0x78>
  80164e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801651:	83 eb 01             	sub    $0x1,%ebx
  801654:	85 db                	test   %ebx,%ebx
  801656:	7f e8                	jg     801640 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801658:	83 ec 08             	sub    $0x8,%esp
  80165b:	56                   	push   %esi
  80165c:	83 ec 04             	sub    $0x4,%esp
  80165f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801662:	ff 75 e0             	pushl  -0x20(%ebp)
  801665:	ff 75 dc             	pushl  -0x24(%ebp)
  801668:	ff 75 d8             	pushl  -0x28(%ebp)
  80166b:	e8 80 0a 00 00       	call   8020f0 <__umoddi3>
  801670:	83 c4 14             	add    $0x14,%esp
  801673:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  80167a:	50                   	push   %eax
  80167b:	ff d7                	call   *%edi
}
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801683:	5b                   	pop    %ebx
  801684:	5e                   	pop    %esi
  801685:	5f                   	pop    %edi
  801686:	5d                   	pop    %ebp
  801687:	c3                   	ret    

00801688 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80168b:	83 fa 01             	cmp    $0x1,%edx
  80168e:	7e 0e                	jle    80169e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801690:	8b 10                	mov    (%eax),%edx
  801692:	8d 4a 08             	lea    0x8(%edx),%ecx
  801695:	89 08                	mov    %ecx,(%eax)
  801697:	8b 02                	mov    (%edx),%eax
  801699:	8b 52 04             	mov    0x4(%edx),%edx
  80169c:	eb 22                	jmp    8016c0 <getuint+0x38>
	else if (lflag)
  80169e:	85 d2                	test   %edx,%edx
  8016a0:	74 10                	je     8016b2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016a2:	8b 10                	mov    (%eax),%edx
  8016a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016a7:	89 08                	mov    %ecx,(%eax)
  8016a9:	8b 02                	mov    (%edx),%eax
  8016ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b0:	eb 0e                	jmp    8016c0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016b2:	8b 10                	mov    (%eax),%edx
  8016b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b7:	89 08                	mov    %ecx,(%eax)
  8016b9:	8b 02                	mov    (%edx),%eax
  8016bb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016c0:	5d                   	pop    %ebp
  8016c1:	c3                   	ret    

008016c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016c8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016cc:	8b 10                	mov    (%eax),%edx
  8016ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8016d1:	73 0a                	jae    8016dd <sprintputch+0x1b>
		*b->buf++ = ch;
  8016d3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016d6:	89 08                	mov    %ecx,(%eax)
  8016d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016db:	88 02                	mov    %al,(%edx)
}
  8016dd:	5d                   	pop    %ebp
  8016de:	c3                   	ret    

008016df <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016e5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016e8:	50                   	push   %eax
  8016e9:	ff 75 10             	pushl  0x10(%ebp)
  8016ec:	ff 75 0c             	pushl  0xc(%ebp)
  8016ef:	ff 75 08             	pushl  0x8(%ebp)
  8016f2:	e8 05 00 00 00       	call   8016fc <vprintfmt>
	va_end(ap);
}
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	c9                   	leave  
  8016fb:	c3                   	ret    

008016fc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	57                   	push   %edi
  801700:	56                   	push   %esi
  801701:	53                   	push   %ebx
  801702:	83 ec 2c             	sub    $0x2c,%esp
  801705:	8b 75 08             	mov    0x8(%ebp),%esi
  801708:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80170b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80170e:	eb 12                	jmp    801722 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801710:	85 c0                	test   %eax,%eax
  801712:	0f 84 89 03 00 00    	je     801aa1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801718:	83 ec 08             	sub    $0x8,%esp
  80171b:	53                   	push   %ebx
  80171c:	50                   	push   %eax
  80171d:	ff d6                	call   *%esi
  80171f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801722:	83 c7 01             	add    $0x1,%edi
  801725:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801729:	83 f8 25             	cmp    $0x25,%eax
  80172c:	75 e2                	jne    801710 <vprintfmt+0x14>
  80172e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801732:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801739:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801740:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801747:	ba 00 00 00 00       	mov    $0x0,%edx
  80174c:	eb 07                	jmp    801755 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801751:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801755:	8d 47 01             	lea    0x1(%edi),%eax
  801758:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80175b:	0f b6 07             	movzbl (%edi),%eax
  80175e:	0f b6 c8             	movzbl %al,%ecx
  801761:	83 e8 23             	sub    $0x23,%eax
  801764:	3c 55                	cmp    $0x55,%al
  801766:	0f 87 1a 03 00 00    	ja     801a86 <vprintfmt+0x38a>
  80176c:	0f b6 c0             	movzbl %al,%eax
  80176f:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801779:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80177d:	eb d6                	jmp    801755 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80177f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801782:	b8 00 00 00 00       	mov    $0x0,%eax
  801787:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80178a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80178d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801791:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801794:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801797:	83 fa 09             	cmp    $0x9,%edx
  80179a:	77 39                	ja     8017d5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80179c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80179f:	eb e9                	jmp    80178a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a4:	8d 48 04             	lea    0x4(%eax),%ecx
  8017a7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017aa:	8b 00                	mov    (%eax),%eax
  8017ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017b2:	eb 27                	jmp    8017db <vprintfmt+0xdf>
  8017b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017be:	0f 49 c8             	cmovns %eax,%ecx
  8017c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c7:	eb 8c                	jmp    801755 <vprintfmt+0x59>
  8017c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017cc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017d3:	eb 80                	jmp    801755 <vprintfmt+0x59>
  8017d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017d8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017df:	0f 89 70 ff ff ff    	jns    801755 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017e5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017f2:	e9 5e ff ff ff       	jmp    801755 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017f7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017fd:	e9 53 ff ff ff       	jmp    801755 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801802:	8b 45 14             	mov    0x14(%ebp),%eax
  801805:	8d 50 04             	lea    0x4(%eax),%edx
  801808:	89 55 14             	mov    %edx,0x14(%ebp)
  80180b:	83 ec 08             	sub    $0x8,%esp
  80180e:	53                   	push   %ebx
  80180f:	ff 30                	pushl  (%eax)
  801811:	ff d6                	call   *%esi
			break;
  801813:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801816:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801819:	e9 04 ff ff ff       	jmp    801722 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80181e:	8b 45 14             	mov    0x14(%ebp),%eax
  801821:	8d 50 04             	lea    0x4(%eax),%edx
  801824:	89 55 14             	mov    %edx,0x14(%ebp)
  801827:	8b 00                	mov    (%eax),%eax
  801829:	99                   	cltd   
  80182a:	31 d0                	xor    %edx,%eax
  80182c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80182e:	83 f8 0f             	cmp    $0xf,%eax
  801831:	7f 0b                	jg     80183e <vprintfmt+0x142>
  801833:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80183a:	85 d2                	test   %edx,%edx
  80183c:	75 18                	jne    801856 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80183e:	50                   	push   %eax
  80183f:	68 fb 23 80 00       	push   $0x8023fb
  801844:	53                   	push   %ebx
  801845:	56                   	push   %esi
  801846:	e8 94 fe ff ff       	call   8016df <printfmt>
  80184b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801851:	e9 cc fe ff ff       	jmp    801722 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801856:	52                   	push   %edx
  801857:	68 41 23 80 00       	push   $0x802341
  80185c:	53                   	push   %ebx
  80185d:	56                   	push   %esi
  80185e:	e8 7c fe ff ff       	call   8016df <printfmt>
  801863:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801866:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801869:	e9 b4 fe ff ff       	jmp    801722 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80186e:	8b 45 14             	mov    0x14(%ebp),%eax
  801871:	8d 50 04             	lea    0x4(%eax),%edx
  801874:	89 55 14             	mov    %edx,0x14(%ebp)
  801877:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801879:	85 ff                	test   %edi,%edi
  80187b:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  801880:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801883:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801887:	0f 8e 94 00 00 00    	jle    801921 <vprintfmt+0x225>
  80188d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801891:	0f 84 98 00 00 00    	je     80192f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801897:	83 ec 08             	sub    $0x8,%esp
  80189a:	ff 75 d0             	pushl  -0x30(%ebp)
  80189d:	57                   	push   %edi
  80189e:	e8 86 02 00 00       	call   801b29 <strnlen>
  8018a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018a6:	29 c1                	sub    %eax,%ecx
  8018a8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018ab:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018ae:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018b8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018ba:	eb 0f                	jmp    8018cb <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018bc:	83 ec 08             	sub    $0x8,%esp
  8018bf:	53                   	push   %ebx
  8018c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c5:	83 ef 01             	sub    $0x1,%edi
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	85 ff                	test   %edi,%edi
  8018cd:	7f ed                	jg     8018bc <vprintfmt+0x1c0>
  8018cf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018d2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018d5:	85 c9                	test   %ecx,%ecx
  8018d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018dc:	0f 49 c1             	cmovns %ecx,%eax
  8018df:	29 c1                	sub    %eax,%ecx
  8018e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018ea:	89 cb                	mov    %ecx,%ebx
  8018ec:	eb 4d                	jmp    80193b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018ee:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018f2:	74 1b                	je     80190f <vprintfmt+0x213>
  8018f4:	0f be c0             	movsbl %al,%eax
  8018f7:	83 e8 20             	sub    $0x20,%eax
  8018fa:	83 f8 5e             	cmp    $0x5e,%eax
  8018fd:	76 10                	jbe    80190f <vprintfmt+0x213>
					putch('?', putdat);
  8018ff:	83 ec 08             	sub    $0x8,%esp
  801902:	ff 75 0c             	pushl  0xc(%ebp)
  801905:	6a 3f                	push   $0x3f
  801907:	ff 55 08             	call   *0x8(%ebp)
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	eb 0d                	jmp    80191c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	ff 75 0c             	pushl  0xc(%ebp)
  801915:	52                   	push   %edx
  801916:	ff 55 08             	call   *0x8(%ebp)
  801919:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80191c:	83 eb 01             	sub    $0x1,%ebx
  80191f:	eb 1a                	jmp    80193b <vprintfmt+0x23f>
  801921:	89 75 08             	mov    %esi,0x8(%ebp)
  801924:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801927:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80192a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80192d:	eb 0c                	jmp    80193b <vprintfmt+0x23f>
  80192f:	89 75 08             	mov    %esi,0x8(%ebp)
  801932:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801935:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801938:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80193b:	83 c7 01             	add    $0x1,%edi
  80193e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801942:	0f be d0             	movsbl %al,%edx
  801945:	85 d2                	test   %edx,%edx
  801947:	74 23                	je     80196c <vprintfmt+0x270>
  801949:	85 f6                	test   %esi,%esi
  80194b:	78 a1                	js     8018ee <vprintfmt+0x1f2>
  80194d:	83 ee 01             	sub    $0x1,%esi
  801950:	79 9c                	jns    8018ee <vprintfmt+0x1f2>
  801952:	89 df                	mov    %ebx,%edi
  801954:	8b 75 08             	mov    0x8(%ebp),%esi
  801957:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80195a:	eb 18                	jmp    801974 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80195c:	83 ec 08             	sub    $0x8,%esp
  80195f:	53                   	push   %ebx
  801960:	6a 20                	push   $0x20
  801962:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801964:	83 ef 01             	sub    $0x1,%edi
  801967:	83 c4 10             	add    $0x10,%esp
  80196a:	eb 08                	jmp    801974 <vprintfmt+0x278>
  80196c:	89 df                	mov    %ebx,%edi
  80196e:	8b 75 08             	mov    0x8(%ebp),%esi
  801971:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801974:	85 ff                	test   %edi,%edi
  801976:	7f e4                	jg     80195c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801978:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80197b:	e9 a2 fd ff ff       	jmp    801722 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801980:	83 fa 01             	cmp    $0x1,%edx
  801983:	7e 16                	jle    80199b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801985:	8b 45 14             	mov    0x14(%ebp),%eax
  801988:	8d 50 08             	lea    0x8(%eax),%edx
  80198b:	89 55 14             	mov    %edx,0x14(%ebp)
  80198e:	8b 50 04             	mov    0x4(%eax),%edx
  801991:	8b 00                	mov    (%eax),%eax
  801993:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801996:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801999:	eb 32                	jmp    8019cd <vprintfmt+0x2d1>
	else if (lflag)
  80199b:	85 d2                	test   %edx,%edx
  80199d:	74 18                	je     8019b7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80199f:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a2:	8d 50 04             	lea    0x4(%eax),%edx
  8019a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a8:	8b 00                	mov    (%eax),%eax
  8019aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ad:	89 c1                	mov    %eax,%ecx
  8019af:	c1 f9 1f             	sar    $0x1f,%ecx
  8019b2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019b5:	eb 16                	jmp    8019cd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ba:	8d 50 04             	lea    0x4(%eax),%edx
  8019bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8019c0:	8b 00                	mov    (%eax),%eax
  8019c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c5:	89 c1                	mov    %eax,%ecx
  8019c7:	c1 f9 1f             	sar    $0x1f,%ecx
  8019ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019d0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019d3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019d8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019dc:	79 74                	jns    801a52 <vprintfmt+0x356>
				putch('-', putdat);
  8019de:	83 ec 08             	sub    $0x8,%esp
  8019e1:	53                   	push   %ebx
  8019e2:	6a 2d                	push   $0x2d
  8019e4:	ff d6                	call   *%esi
				num = -(long long) num;
  8019e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019e9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019ec:	f7 d8                	neg    %eax
  8019ee:	83 d2 00             	adc    $0x0,%edx
  8019f1:	f7 da                	neg    %edx
  8019f3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019f6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019fb:	eb 55                	jmp    801a52 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019fd:	8d 45 14             	lea    0x14(%ebp),%eax
  801a00:	e8 83 fc ff ff       	call   801688 <getuint>
			base = 10;
  801a05:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a0a:	eb 46                	jmp    801a52 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a0c:	8d 45 14             	lea    0x14(%ebp),%eax
  801a0f:	e8 74 fc ff ff       	call   801688 <getuint>
			base = 8;
  801a14:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a19:	eb 37                	jmp    801a52 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a1b:	83 ec 08             	sub    $0x8,%esp
  801a1e:	53                   	push   %ebx
  801a1f:	6a 30                	push   $0x30
  801a21:	ff d6                	call   *%esi
			putch('x', putdat);
  801a23:	83 c4 08             	add    $0x8,%esp
  801a26:	53                   	push   %ebx
  801a27:	6a 78                	push   $0x78
  801a29:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a2b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2e:	8d 50 04             	lea    0x4(%eax),%edx
  801a31:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a34:	8b 00                	mov    (%eax),%eax
  801a36:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a3b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a3e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a43:	eb 0d                	jmp    801a52 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a45:	8d 45 14             	lea    0x14(%ebp),%eax
  801a48:	e8 3b fc ff ff       	call   801688 <getuint>
			base = 16;
  801a4d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a52:	83 ec 0c             	sub    $0xc,%esp
  801a55:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a59:	57                   	push   %edi
  801a5a:	ff 75 e0             	pushl  -0x20(%ebp)
  801a5d:	51                   	push   %ecx
  801a5e:	52                   	push   %edx
  801a5f:	50                   	push   %eax
  801a60:	89 da                	mov    %ebx,%edx
  801a62:	89 f0                	mov    %esi,%eax
  801a64:	e8 70 fb ff ff       	call   8015d9 <printnum>
			break;
  801a69:	83 c4 20             	add    $0x20,%esp
  801a6c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a6f:	e9 ae fc ff ff       	jmp    801722 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a74:	83 ec 08             	sub    $0x8,%esp
  801a77:	53                   	push   %ebx
  801a78:	51                   	push   %ecx
  801a79:	ff d6                	call   *%esi
			break;
  801a7b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a81:	e9 9c fc ff ff       	jmp    801722 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a86:	83 ec 08             	sub    $0x8,%esp
  801a89:	53                   	push   %ebx
  801a8a:	6a 25                	push   $0x25
  801a8c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	eb 03                	jmp    801a96 <vprintfmt+0x39a>
  801a93:	83 ef 01             	sub    $0x1,%edi
  801a96:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a9a:	75 f7                	jne    801a93 <vprintfmt+0x397>
  801a9c:	e9 81 fc ff ff       	jmp    801722 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aa1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5e                   	pop    %esi
  801aa6:	5f                   	pop    %edi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	83 ec 18             	sub    $0x18,%esp
  801aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ab5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ab8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801abc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801abf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	74 26                	je     801af0 <vsnprintf+0x47>
  801aca:	85 d2                	test   %edx,%edx
  801acc:	7e 22                	jle    801af0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ace:	ff 75 14             	pushl  0x14(%ebp)
  801ad1:	ff 75 10             	pushl  0x10(%ebp)
  801ad4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ad7:	50                   	push   %eax
  801ad8:	68 c2 16 80 00       	push   $0x8016c2
  801add:	e8 1a fc ff ff       	call   8016fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ae2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ae5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	eb 05                	jmp    801af5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801af0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801afd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b00:	50                   	push   %eax
  801b01:	ff 75 10             	pushl  0x10(%ebp)
  801b04:	ff 75 0c             	pushl  0xc(%ebp)
  801b07:	ff 75 08             	pushl  0x8(%ebp)
  801b0a:	e8 9a ff ff ff       	call   801aa9 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b0f:	c9                   	leave  
  801b10:	c3                   	ret    

00801b11 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b17:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1c:	eb 03                	jmp    801b21 <strlen+0x10>
		n++;
  801b1e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b21:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b25:	75 f7                	jne    801b1e <strlen+0xd>
		n++;
	return n;
}
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b32:	ba 00 00 00 00       	mov    $0x0,%edx
  801b37:	eb 03                	jmp    801b3c <strnlen+0x13>
		n++;
  801b39:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b3c:	39 c2                	cmp    %eax,%edx
  801b3e:	74 08                	je     801b48 <strnlen+0x1f>
  801b40:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b44:	75 f3                	jne    801b39 <strnlen+0x10>
  801b46:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b48:	5d                   	pop    %ebp
  801b49:	c3                   	ret    

00801b4a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	53                   	push   %ebx
  801b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b54:	89 c2                	mov    %eax,%edx
  801b56:	83 c2 01             	add    $0x1,%edx
  801b59:	83 c1 01             	add    $0x1,%ecx
  801b5c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b60:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b63:	84 db                	test   %bl,%bl
  801b65:	75 ef                	jne    801b56 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b67:	5b                   	pop    %ebx
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    

00801b6a <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	53                   	push   %ebx
  801b6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b71:	53                   	push   %ebx
  801b72:	e8 9a ff ff ff       	call   801b11 <strlen>
  801b77:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b7a:	ff 75 0c             	pushl  0xc(%ebp)
  801b7d:	01 d8                	add    %ebx,%eax
  801b7f:	50                   	push   %eax
  801b80:	e8 c5 ff ff ff       	call   801b4a <strcpy>
	return dst;
}
  801b85:	89 d8                	mov    %ebx,%eax
  801b87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	56                   	push   %esi
  801b90:	53                   	push   %ebx
  801b91:	8b 75 08             	mov    0x8(%ebp),%esi
  801b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b97:	89 f3                	mov    %esi,%ebx
  801b99:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b9c:	89 f2                	mov    %esi,%edx
  801b9e:	eb 0f                	jmp    801baf <strncpy+0x23>
		*dst++ = *src;
  801ba0:	83 c2 01             	add    $0x1,%edx
  801ba3:	0f b6 01             	movzbl (%ecx),%eax
  801ba6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ba9:	80 39 01             	cmpb   $0x1,(%ecx)
  801bac:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801baf:	39 da                	cmp    %ebx,%edx
  801bb1:	75 ed                	jne    801ba0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bb3:	89 f0                	mov    %esi,%eax
  801bb5:	5b                   	pop    %ebx
  801bb6:	5e                   	pop    %esi
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    

00801bb9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
  801bbc:	56                   	push   %esi
  801bbd:	53                   	push   %ebx
  801bbe:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc4:	8b 55 10             	mov    0x10(%ebp),%edx
  801bc7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bc9:	85 d2                	test   %edx,%edx
  801bcb:	74 21                	je     801bee <strlcpy+0x35>
  801bcd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bd1:	89 f2                	mov    %esi,%edx
  801bd3:	eb 09                	jmp    801bde <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bd5:	83 c2 01             	add    $0x1,%edx
  801bd8:	83 c1 01             	add    $0x1,%ecx
  801bdb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bde:	39 c2                	cmp    %eax,%edx
  801be0:	74 09                	je     801beb <strlcpy+0x32>
  801be2:	0f b6 19             	movzbl (%ecx),%ebx
  801be5:	84 db                	test   %bl,%bl
  801be7:	75 ec                	jne    801bd5 <strlcpy+0x1c>
  801be9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801beb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bee:	29 f0                	sub    %esi,%eax
}
  801bf0:	5b                   	pop    %ebx
  801bf1:	5e                   	pop    %esi
  801bf2:	5d                   	pop    %ebp
  801bf3:	c3                   	ret    

00801bf4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bfa:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bfd:	eb 06                	jmp    801c05 <strcmp+0x11>
		p++, q++;
  801bff:	83 c1 01             	add    $0x1,%ecx
  801c02:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c05:	0f b6 01             	movzbl (%ecx),%eax
  801c08:	84 c0                	test   %al,%al
  801c0a:	74 04                	je     801c10 <strcmp+0x1c>
  801c0c:	3a 02                	cmp    (%edx),%al
  801c0e:	74 ef                	je     801bff <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c10:	0f b6 c0             	movzbl %al,%eax
  801c13:	0f b6 12             	movzbl (%edx),%edx
  801c16:	29 d0                	sub    %edx,%eax
}
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    

00801c1a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	53                   	push   %ebx
  801c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c21:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c24:	89 c3                	mov    %eax,%ebx
  801c26:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c29:	eb 06                	jmp    801c31 <strncmp+0x17>
		n--, p++, q++;
  801c2b:	83 c0 01             	add    $0x1,%eax
  801c2e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c31:	39 d8                	cmp    %ebx,%eax
  801c33:	74 15                	je     801c4a <strncmp+0x30>
  801c35:	0f b6 08             	movzbl (%eax),%ecx
  801c38:	84 c9                	test   %cl,%cl
  801c3a:	74 04                	je     801c40 <strncmp+0x26>
  801c3c:	3a 0a                	cmp    (%edx),%cl
  801c3e:	74 eb                	je     801c2b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c40:	0f b6 00             	movzbl (%eax),%eax
  801c43:	0f b6 12             	movzbl (%edx),%edx
  801c46:	29 d0                	sub    %edx,%eax
  801c48:	eb 05                	jmp    801c4f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c4a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c4f:	5b                   	pop    %ebx
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    

00801c52 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	8b 45 08             	mov    0x8(%ebp),%eax
  801c58:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c5c:	eb 07                	jmp    801c65 <strchr+0x13>
		if (*s == c)
  801c5e:	38 ca                	cmp    %cl,%dl
  801c60:	74 0f                	je     801c71 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c62:	83 c0 01             	add    $0x1,%eax
  801c65:	0f b6 10             	movzbl (%eax),%edx
  801c68:	84 d2                	test   %dl,%dl
  801c6a:	75 f2                	jne    801c5e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c71:	5d                   	pop    %ebp
  801c72:	c3                   	ret    

00801c73 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	8b 45 08             	mov    0x8(%ebp),%eax
  801c79:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c7d:	eb 03                	jmp    801c82 <strfind+0xf>
  801c7f:	83 c0 01             	add    $0x1,%eax
  801c82:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c85:	38 ca                	cmp    %cl,%dl
  801c87:	74 04                	je     801c8d <strfind+0x1a>
  801c89:	84 d2                	test   %dl,%dl
  801c8b:	75 f2                	jne    801c7f <strfind+0xc>
			break;
	return (char *) s;
}
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    

00801c8f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	57                   	push   %edi
  801c93:	56                   	push   %esi
  801c94:	53                   	push   %ebx
  801c95:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c98:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c9b:	85 c9                	test   %ecx,%ecx
  801c9d:	74 36                	je     801cd5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c9f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ca5:	75 28                	jne    801ccf <memset+0x40>
  801ca7:	f6 c1 03             	test   $0x3,%cl
  801caa:	75 23                	jne    801ccf <memset+0x40>
		c &= 0xFF;
  801cac:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cb0:	89 d3                	mov    %edx,%ebx
  801cb2:	c1 e3 08             	shl    $0x8,%ebx
  801cb5:	89 d6                	mov    %edx,%esi
  801cb7:	c1 e6 18             	shl    $0x18,%esi
  801cba:	89 d0                	mov    %edx,%eax
  801cbc:	c1 e0 10             	shl    $0x10,%eax
  801cbf:	09 f0                	or     %esi,%eax
  801cc1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cc3:	89 d8                	mov    %ebx,%eax
  801cc5:	09 d0                	or     %edx,%eax
  801cc7:	c1 e9 02             	shr    $0x2,%ecx
  801cca:	fc                   	cld    
  801ccb:	f3 ab                	rep stos %eax,%es:(%edi)
  801ccd:	eb 06                	jmp    801cd5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd2:	fc                   	cld    
  801cd3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cd5:	89 f8                	mov    %edi,%eax
  801cd7:	5b                   	pop    %ebx
  801cd8:	5e                   	pop    %esi
  801cd9:	5f                   	pop    %edi
  801cda:	5d                   	pop    %ebp
  801cdb:	c3                   	ret    

00801cdc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	57                   	push   %edi
  801ce0:	56                   	push   %esi
  801ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ce7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cea:	39 c6                	cmp    %eax,%esi
  801cec:	73 35                	jae    801d23 <memmove+0x47>
  801cee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cf1:	39 d0                	cmp    %edx,%eax
  801cf3:	73 2e                	jae    801d23 <memmove+0x47>
		s += n;
		d += n;
  801cf5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf8:	89 d6                	mov    %edx,%esi
  801cfa:	09 fe                	or     %edi,%esi
  801cfc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d02:	75 13                	jne    801d17 <memmove+0x3b>
  801d04:	f6 c1 03             	test   $0x3,%cl
  801d07:	75 0e                	jne    801d17 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d09:	83 ef 04             	sub    $0x4,%edi
  801d0c:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d0f:	c1 e9 02             	shr    $0x2,%ecx
  801d12:	fd                   	std    
  801d13:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d15:	eb 09                	jmp    801d20 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d17:	83 ef 01             	sub    $0x1,%edi
  801d1a:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d1d:	fd                   	std    
  801d1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d20:	fc                   	cld    
  801d21:	eb 1d                	jmp    801d40 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d23:	89 f2                	mov    %esi,%edx
  801d25:	09 c2                	or     %eax,%edx
  801d27:	f6 c2 03             	test   $0x3,%dl
  801d2a:	75 0f                	jne    801d3b <memmove+0x5f>
  801d2c:	f6 c1 03             	test   $0x3,%cl
  801d2f:	75 0a                	jne    801d3b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d31:	c1 e9 02             	shr    $0x2,%ecx
  801d34:	89 c7                	mov    %eax,%edi
  801d36:	fc                   	cld    
  801d37:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d39:	eb 05                	jmp    801d40 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d3b:	89 c7                	mov    %eax,%edi
  801d3d:	fc                   	cld    
  801d3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d40:	5e                   	pop    %esi
  801d41:	5f                   	pop    %edi
  801d42:	5d                   	pop    %ebp
  801d43:	c3                   	ret    

00801d44 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d47:	ff 75 10             	pushl  0x10(%ebp)
  801d4a:	ff 75 0c             	pushl  0xc(%ebp)
  801d4d:	ff 75 08             	pushl  0x8(%ebp)
  801d50:	e8 87 ff ff ff       	call   801cdc <memmove>
}
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    

00801d57 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	56                   	push   %esi
  801d5b:	53                   	push   %ebx
  801d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d62:	89 c6                	mov    %eax,%esi
  801d64:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d67:	eb 1a                	jmp    801d83 <memcmp+0x2c>
		if (*s1 != *s2)
  801d69:	0f b6 08             	movzbl (%eax),%ecx
  801d6c:	0f b6 1a             	movzbl (%edx),%ebx
  801d6f:	38 d9                	cmp    %bl,%cl
  801d71:	74 0a                	je     801d7d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d73:	0f b6 c1             	movzbl %cl,%eax
  801d76:	0f b6 db             	movzbl %bl,%ebx
  801d79:	29 d8                	sub    %ebx,%eax
  801d7b:	eb 0f                	jmp    801d8c <memcmp+0x35>
		s1++, s2++;
  801d7d:	83 c0 01             	add    $0x1,%eax
  801d80:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d83:	39 f0                	cmp    %esi,%eax
  801d85:	75 e2                	jne    801d69 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d8c:	5b                   	pop    %ebx
  801d8d:	5e                   	pop    %esi
  801d8e:	5d                   	pop    %ebp
  801d8f:	c3                   	ret    

00801d90 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	53                   	push   %ebx
  801d94:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d97:	89 c1                	mov    %eax,%ecx
  801d99:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d9c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da0:	eb 0a                	jmp    801dac <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801da2:	0f b6 10             	movzbl (%eax),%edx
  801da5:	39 da                	cmp    %ebx,%edx
  801da7:	74 07                	je     801db0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da9:	83 c0 01             	add    $0x1,%eax
  801dac:	39 c8                	cmp    %ecx,%eax
  801dae:	72 f2                	jb     801da2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801db0:	5b                   	pop    %ebx
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    

00801db3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	57                   	push   %edi
  801db7:	56                   	push   %esi
  801db8:	53                   	push   %ebx
  801db9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dbf:	eb 03                	jmp    801dc4 <strtol+0x11>
		s++;
  801dc1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc4:	0f b6 01             	movzbl (%ecx),%eax
  801dc7:	3c 20                	cmp    $0x20,%al
  801dc9:	74 f6                	je     801dc1 <strtol+0xe>
  801dcb:	3c 09                	cmp    $0x9,%al
  801dcd:	74 f2                	je     801dc1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dcf:	3c 2b                	cmp    $0x2b,%al
  801dd1:	75 0a                	jne    801ddd <strtol+0x2a>
		s++;
  801dd3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dd6:	bf 00 00 00 00       	mov    $0x0,%edi
  801ddb:	eb 11                	jmp    801dee <strtol+0x3b>
  801ddd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801de2:	3c 2d                	cmp    $0x2d,%al
  801de4:	75 08                	jne    801dee <strtol+0x3b>
		s++, neg = 1;
  801de6:	83 c1 01             	add    $0x1,%ecx
  801de9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dee:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801df4:	75 15                	jne    801e0b <strtol+0x58>
  801df6:	80 39 30             	cmpb   $0x30,(%ecx)
  801df9:	75 10                	jne    801e0b <strtol+0x58>
  801dfb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801dff:	75 7c                	jne    801e7d <strtol+0xca>
		s += 2, base = 16;
  801e01:	83 c1 02             	add    $0x2,%ecx
  801e04:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e09:	eb 16                	jmp    801e21 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e0b:	85 db                	test   %ebx,%ebx
  801e0d:	75 12                	jne    801e21 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e0f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e14:	80 39 30             	cmpb   $0x30,(%ecx)
  801e17:	75 08                	jne    801e21 <strtol+0x6e>
		s++, base = 8;
  801e19:	83 c1 01             	add    $0x1,%ecx
  801e1c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e21:	b8 00 00 00 00       	mov    $0x0,%eax
  801e26:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e29:	0f b6 11             	movzbl (%ecx),%edx
  801e2c:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e2f:	89 f3                	mov    %esi,%ebx
  801e31:	80 fb 09             	cmp    $0x9,%bl
  801e34:	77 08                	ja     801e3e <strtol+0x8b>
			dig = *s - '0';
  801e36:	0f be d2             	movsbl %dl,%edx
  801e39:	83 ea 30             	sub    $0x30,%edx
  801e3c:	eb 22                	jmp    801e60 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e3e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e41:	89 f3                	mov    %esi,%ebx
  801e43:	80 fb 19             	cmp    $0x19,%bl
  801e46:	77 08                	ja     801e50 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e48:	0f be d2             	movsbl %dl,%edx
  801e4b:	83 ea 57             	sub    $0x57,%edx
  801e4e:	eb 10                	jmp    801e60 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e50:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e53:	89 f3                	mov    %esi,%ebx
  801e55:	80 fb 19             	cmp    $0x19,%bl
  801e58:	77 16                	ja     801e70 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e5a:	0f be d2             	movsbl %dl,%edx
  801e5d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e60:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e63:	7d 0b                	jge    801e70 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e65:	83 c1 01             	add    $0x1,%ecx
  801e68:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e6c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e6e:	eb b9                	jmp    801e29 <strtol+0x76>

	if (endptr)
  801e70:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e74:	74 0d                	je     801e83 <strtol+0xd0>
		*endptr = (char *) s;
  801e76:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e79:	89 0e                	mov    %ecx,(%esi)
  801e7b:	eb 06                	jmp    801e83 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e7d:	85 db                	test   %ebx,%ebx
  801e7f:	74 98                	je     801e19 <strtol+0x66>
  801e81:	eb 9e                	jmp    801e21 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e83:	89 c2                	mov    %eax,%edx
  801e85:	f7 da                	neg    %edx
  801e87:	85 ff                	test   %edi,%edi
  801e89:	0f 45 c2             	cmovne %edx,%eax
}
  801e8c:	5b                   	pop    %ebx
  801e8d:	5e                   	pop    %esi
  801e8e:	5f                   	pop    %edi
  801e8f:	5d                   	pop    %ebp
  801e90:	c3                   	ret    

00801e91 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	56                   	push   %esi
  801e95:	53                   	push   %ebx
  801e96:	8b 75 08             	mov    0x8(%ebp),%esi
  801e99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e9f:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ea1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ea6:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801ea9:	83 ec 0c             	sub    $0xc,%esp
  801eac:	50                   	push   %eax
  801ead:	e8 54 e4 ff ff       	call   800306 <sys_ipc_recv>

	if (from_env_store != NULL)
  801eb2:	83 c4 10             	add    $0x10,%esp
  801eb5:	85 f6                	test   %esi,%esi
  801eb7:	74 14                	je     801ecd <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801eb9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	78 09                	js     801ecb <ipc_recv+0x3a>
  801ec2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ec8:	8b 52 74             	mov    0x74(%edx),%edx
  801ecb:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801ecd:	85 db                	test   %ebx,%ebx
  801ecf:	74 14                	je     801ee5 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ed1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	78 09                	js     801ee3 <ipc_recv+0x52>
  801eda:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ee0:	8b 52 78             	mov    0x78(%edx),%edx
  801ee3:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	78 08                	js     801ef1 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ee9:	a1 08 40 80 00       	mov    0x804008,%eax
  801eee:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ef1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef4:	5b                   	pop    %ebx
  801ef5:	5e                   	pop    %esi
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    

00801ef8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	57                   	push   %edi
  801efc:	56                   	push   %esi
  801efd:	53                   	push   %ebx
  801efe:	83 ec 0c             	sub    $0xc,%esp
  801f01:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f04:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f0a:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f0c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f11:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f14:	ff 75 14             	pushl  0x14(%ebp)
  801f17:	53                   	push   %ebx
  801f18:	56                   	push   %esi
  801f19:	57                   	push   %edi
  801f1a:	e8 c4 e3 ff ff       	call   8002e3 <sys_ipc_try_send>

		if (err < 0) {
  801f1f:	83 c4 10             	add    $0x10,%esp
  801f22:	85 c0                	test   %eax,%eax
  801f24:	79 1e                	jns    801f44 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f26:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f29:	75 07                	jne    801f32 <ipc_send+0x3a>
				sys_yield();
  801f2b:	e8 07 e2 ff ff       	call   800137 <sys_yield>
  801f30:	eb e2                	jmp    801f14 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f32:	50                   	push   %eax
  801f33:	68 e0 26 80 00       	push   $0x8026e0
  801f38:	6a 49                	push   $0x49
  801f3a:	68 ed 26 80 00       	push   $0x8026ed
  801f3f:	e8 a8 f5 ff ff       	call   8014ec <_panic>
		}

	} while (err < 0);

}
  801f44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f47:	5b                   	pop    %ebx
  801f48:	5e                   	pop    %esi
  801f49:	5f                   	pop    %edi
  801f4a:	5d                   	pop    %ebp
  801f4b:	c3                   	ret    

00801f4c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f52:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f57:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f5a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f60:	8b 52 50             	mov    0x50(%edx),%edx
  801f63:	39 ca                	cmp    %ecx,%edx
  801f65:	75 0d                	jne    801f74 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f67:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f6a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f6f:	8b 40 48             	mov    0x48(%eax),%eax
  801f72:	eb 0f                	jmp    801f83 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f74:	83 c0 01             	add    $0x1,%eax
  801f77:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f7c:	75 d9                	jne    801f57 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f83:	5d                   	pop    %ebp
  801f84:	c3                   	ret    

00801f85 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f85:	55                   	push   %ebp
  801f86:	89 e5                	mov    %esp,%ebp
  801f88:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8b:	89 d0                	mov    %edx,%eax
  801f8d:	c1 e8 16             	shr    $0x16,%eax
  801f90:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f97:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9c:	f6 c1 01             	test   $0x1,%cl
  801f9f:	74 1d                	je     801fbe <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa1:	c1 ea 0c             	shr    $0xc,%edx
  801fa4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fab:	f6 c2 01             	test   $0x1,%dl
  801fae:	74 0e                	je     801fbe <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb0:	c1 ea 0c             	shr    $0xc,%edx
  801fb3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fba:	ef 
  801fbb:	0f b7 c0             	movzwl %ax,%eax
}
  801fbe:	5d                   	pop    %ebp
  801fbf:	c3                   	ret    

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 f6                	test   %esi,%esi
  801fd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdd:	89 ca                	mov    %ecx,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	75 3d                	jne    802020 <__udivdi3+0x60>
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	0f 87 c5 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  801feb:	85 ff                	test   %edi,%edi
  801fed:	89 fd                	mov    %edi,%ebp
  801fef:	75 0b                	jne    801ffc <__udivdi3+0x3c>
  801ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff6:	31 d2                	xor    %edx,%edx
  801ff8:	f7 f7                	div    %edi
  801ffa:	89 c5                	mov    %eax,%ebp
  801ffc:	89 c8                	mov    %ecx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f5                	div    %ebp
  802002:	89 c1                	mov    %eax,%ecx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	89 cf                	mov    %ecx,%edi
  802008:	f7 f5                	div    %ebp
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 ce                	cmp    %ecx,%esi
  802022:	77 74                	ja     802098 <__udivdi3+0xd8>
  802024:	0f bd fe             	bsr    %esi,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0x108>
  802030:	bb 20 00 00 00       	mov    $0x20,%ebx
  802035:	89 f9                	mov    %edi,%ecx
  802037:	89 c5                	mov    %eax,%ebp
  802039:	29 fb                	sub    %edi,%ebx
  80203b:	d3 e6                	shl    %cl,%esi
  80203d:	89 d9                	mov    %ebx,%ecx
  80203f:	d3 ed                	shr    %cl,%ebp
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	09 ee                	or     %ebp,%esi
  802047:	89 d9                	mov    %ebx,%ecx
  802049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204d:	89 d5                	mov    %edx,%ebp
  80204f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802053:	d3 ed                	shr    %cl,%ebp
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e2                	shl    %cl,%edx
  802059:	89 d9                	mov    %ebx,%ecx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	89 d0                	mov    %edx,%eax
  802061:	89 ea                	mov    %ebp,%edx
  802063:	f7 f6                	div    %esi
  802065:	89 d5                	mov    %edx,%ebp
  802067:	89 c3                	mov    %eax,%ebx
  802069:	f7 64 24 0c          	mull   0xc(%esp)
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	72 10                	jb     802081 <__udivdi3+0xc1>
  802071:	8b 74 24 08          	mov    0x8(%esp),%esi
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e6                	shl    %cl,%esi
  802079:	39 c6                	cmp    %eax,%esi
  80207b:	73 07                	jae    802084 <__udivdi3+0xc4>
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	75 03                	jne    802084 <__udivdi3+0xc4>
  802081:	83 eb 01             	sub    $0x1,%ebx
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 d8                	mov    %ebx,%eax
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	31 db                	xor    %ebx,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	f7 f7                	div    %edi
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 fa                	mov    %edi,%edx
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 ce                	cmp    %ecx,%esi
  8020ca:	72 0c                	jb     8020d8 <__udivdi3+0x118>
  8020cc:	31 db                	xor    %ebx,%ebx
  8020ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020d2:	0f 87 34 ff ff ff    	ja     80200c <__udivdi3+0x4c>
  8020d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020dd:	e9 2a ff ff ff       	jmp    80200c <__udivdi3+0x4c>
  8020e2:	66 90                	xchg   %ax,%ax
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 d2                	test   %edx,%edx
  802109:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f3                	mov    %esi,%ebx
  802113:	89 3c 24             	mov    %edi,(%esp)
  802116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211a:	75 1c                	jne    802138 <__umoddi3+0x48>
  80211c:	39 f7                	cmp    %esi,%edi
  80211e:	76 50                	jbe    802170 <__umoddi3+0x80>
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	f7 f7                	div    %edi
  802126:	89 d0                	mov    %edx,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	77 52                	ja     802190 <__umoddi3+0xa0>
  80213e:	0f bd ea             	bsr    %edx,%ebp
  802141:	83 f5 1f             	xor    $0x1f,%ebp
  802144:	75 5a                	jne    8021a0 <__umoddi3+0xb0>
  802146:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	39 0c 24             	cmp    %ecx,(%esp)
  802153:	0f 86 d7 00 00 00    	jbe    802230 <__umoddi3+0x140>
  802159:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	85 ff                	test   %edi,%edi
  802172:	89 fd                	mov    %edi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 c8                	mov    %ecx,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	eb 99                	jmp    802128 <__umoddi3+0x38>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	83 c4 1c             	add    $0x1c,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	8b 34 24             	mov    (%esp),%esi
  8021a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	29 ef                	sub    %ebp,%edi
  8021ac:	d3 e0                	shl    %cl,%eax
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	d3 ea                	shr    %cl,%edx
  8021b4:	89 e9                	mov    %ebp,%ecx
  8021b6:	09 c2                	or     %eax,%edx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 14 24             	mov    %edx,(%esp)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	d3 e2                	shl    %cl,%edx
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	89 c6                	mov    %eax,%esi
  8021d1:	d3 e3                	shl    %cl,%ebx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	09 d8                	or     %ebx,%eax
  8021dd:	89 d3                	mov    %edx,%ebx
  8021df:	89 f2                	mov    %esi,%edx
  8021e1:	f7 34 24             	divl   (%esp)
  8021e4:	89 d6                	mov    %edx,%esi
  8021e6:	d3 e3                	shl    %cl,%ebx
  8021e8:	f7 64 24 04          	mull   0x4(%esp)
  8021ec:	39 d6                	cmp    %edx,%esi
  8021ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f2:	89 d1                	mov    %edx,%ecx
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	72 08                	jb     802200 <__umoddi3+0x110>
  8021f8:	75 11                	jne    80220b <__umoddi3+0x11b>
  8021fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021fe:	73 0b                	jae    80220b <__umoddi3+0x11b>
  802200:	2b 44 24 04          	sub    0x4(%esp),%eax
  802204:	1b 14 24             	sbb    (%esp),%edx
  802207:	89 d1                	mov    %edx,%ecx
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80220f:	29 da                	sub    %ebx,%edx
  802211:	19 ce                	sbb    %ecx,%esi
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e0                	shl    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	d3 ee                	shr    %cl,%esi
  802221:	09 d0                	or     %edx,%eax
  802223:	89 f2                	mov    %esi,%edx
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 f9                	sub    %edi,%ecx
  802232:	19 d6                	sbb    %edx,%esi
  802234:	89 74 24 04          	mov    %esi,0x4(%esp)
  802238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223c:	e9 18 ff ff ff       	jmp    802159 <__umoddi3+0x69>
