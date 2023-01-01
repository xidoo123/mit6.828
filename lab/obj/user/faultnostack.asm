
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 17 03 80 00       	push   $0x800317
  80003e:	6a 00                	push   $0x0
  800040:	e8 2c 02 00 00       	call   800271 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 17                	jle    800122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 ca 0f 80 00       	push   $0x800fca
  800116:	6a 23                	push   $0x23
  800118:	68 e7 0f 80 00       	push   $0x800fe7
  80011d:	e8 19 02 00 00       	call   80033b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7e 17                	jle    8001a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	6a 04                	push   $0x4
  800192:	68 ca 0f 80 00       	push   $0x800fca
  800197:	6a 23                	push   $0x23
  800199:	68 e7 0f 80 00       	push   $0x800fe7
  80019e:	e8 98 01 00 00       	call   80033b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7e 17                	jle    8001e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 05                	push   $0x5
  8001d4:	68 ca 0f 80 00       	push   $0x800fca
  8001d9:	6a 23                	push   $0x23
  8001db:	68 e7 0f 80 00       	push   $0x800fe7
  8001e0:	e8 56 01 00 00       	call   80033b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	b8 06 00 00 00       	mov    $0x6,%eax
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 17                	jle    800227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 06                	push   $0x6
  800216:	68 ca 0f 80 00       	push   $0x800fca
  80021b:	6a 23                	push   $0x23
  80021d:	68 e7 0f 80 00       	push   $0x800fe7
  800222:	e8 14 01 00 00       	call   80033b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	b8 08 00 00 00       	mov    $0x8,%eax
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7e 17                	jle    800269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 08                	push   $0x8
  800258:	68 ca 0f 80 00       	push   $0x800fca
  80025d:	6a 23                	push   $0x23
  80025f:	68 e7 0f 80 00       	push   $0x800fe7
  800264:	e8 d2 00 00 00       	call   80033b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026c:	5b                   	pop    %ebx
  80026d:	5e                   	pop    %esi
  80026e:	5f                   	pop    %edi
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7e 17                	jle    8002ab <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 09                	push   $0x9
  80029a:	68 ca 0f 80 00       	push   $0x800fca
  80029f:	6a 23                	push   $0x23
  8002a1:	68 e7 0f 80 00       	push   $0x800fe7
  8002a6:	e8 90 00 00 00       	call   80033b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b9:	be 00 00 00 00       	mov    $0x0,%esi
  8002be:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7e 17                	jle    80030f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	6a 0c                	push   $0xc
  8002fe:	68 ca 0f 80 00       	push   $0x800fca
  800303:	6a 23                	push   $0x23
  800305:	68 e7 0f 80 00       	push   $0x800fe7
  80030a:	e8 2c 00 00 00       	call   80033b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80030f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5f                   	pop    %edi
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800317:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800318:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80031d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80031f:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  800322:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  800326:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  80032a:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  80032d:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  800330:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  800331:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  800334:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  800335:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  800336:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80033a:	c3                   	ret    

0080033b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800340:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800343:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800349:	e8 dc fd ff ff       	call   80012a <sys_getenvid>
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	ff 75 0c             	pushl  0xc(%ebp)
  800354:	ff 75 08             	pushl  0x8(%ebp)
  800357:	56                   	push   %esi
  800358:	50                   	push   %eax
  800359:	68 f8 0f 80 00       	push   $0x800ff8
  80035e:	e8 b1 00 00 00       	call   800414 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800363:	83 c4 18             	add    $0x18,%esp
  800366:	53                   	push   %ebx
  800367:	ff 75 10             	pushl  0x10(%ebp)
  80036a:	e8 54 00 00 00       	call   8003c3 <vcprintf>
	cprintf("\n");
  80036f:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  800376:	e8 99 00 00 00       	call   800414 <cprintf>
  80037b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037e:	cc                   	int3   
  80037f:	eb fd                	jmp    80037e <_panic+0x43>

00800381 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	53                   	push   %ebx
  800385:	83 ec 04             	sub    $0x4,%esp
  800388:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038b:	8b 13                	mov    (%ebx),%edx
  80038d:	8d 42 01             	lea    0x1(%edx),%eax
  800390:	89 03                	mov    %eax,(%ebx)
  800392:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800395:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800399:	3d ff 00 00 00       	cmp    $0xff,%eax
  80039e:	75 1a                	jne    8003ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003a0:	83 ec 08             	sub    $0x8,%esp
  8003a3:	68 ff 00 00 00       	push   $0xff
  8003a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ab:	50                   	push   %eax
  8003ac:	e8 fb fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d3:	00 00 00 
	b.cnt = 0;
  8003d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e0:	ff 75 0c             	pushl  0xc(%ebp)
  8003e3:	ff 75 08             	pushl  0x8(%ebp)
  8003e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ec:	50                   	push   %eax
  8003ed:	68 81 03 80 00       	push   $0x800381
  8003f2:	e8 54 01 00 00       	call   80054b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f7:	83 c4 08             	add    $0x8,%esp
  8003fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800400:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800406:	50                   	push   %eax
  800407:	e8 a0 fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80040c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800412:	c9                   	leave  
  800413:	c3                   	ret    

00800414 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80041d:	50                   	push   %eax
  80041e:	ff 75 08             	pushl  0x8(%ebp)
  800421:	e8 9d ff ff ff       	call   8003c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 1c             	sub    $0x1c,%esp
  800431:	89 c7                	mov    %eax,%edi
  800433:	89 d6                	mov    %edx,%esi
  800435:	8b 45 08             	mov    0x8(%ebp),%eax
  800438:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800441:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800444:	bb 00 00 00 00       	mov    $0x0,%ebx
  800449:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80044c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80044f:	39 d3                	cmp    %edx,%ebx
  800451:	72 05                	jb     800458 <printnum+0x30>
  800453:	39 45 10             	cmp    %eax,0x10(%ebp)
  800456:	77 45                	ja     80049d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800458:	83 ec 0c             	sub    $0xc,%esp
  80045b:	ff 75 18             	pushl  0x18(%ebp)
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800464:	53                   	push   %ebx
  800465:	ff 75 10             	pushl  0x10(%ebp)
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046e:	ff 75 e0             	pushl  -0x20(%ebp)
  800471:	ff 75 dc             	pushl  -0x24(%ebp)
  800474:	ff 75 d8             	pushl  -0x28(%ebp)
  800477:	e8 b4 08 00 00       	call   800d30 <__udivdi3>
  80047c:	83 c4 18             	add    $0x18,%esp
  80047f:	52                   	push   %edx
  800480:	50                   	push   %eax
  800481:	89 f2                	mov    %esi,%edx
  800483:	89 f8                	mov    %edi,%eax
  800485:	e8 9e ff ff ff       	call   800428 <printnum>
  80048a:	83 c4 20             	add    $0x20,%esp
  80048d:	eb 18                	jmp    8004a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	56                   	push   %esi
  800493:	ff 75 18             	pushl  0x18(%ebp)
  800496:	ff d7                	call   *%edi
  800498:	83 c4 10             	add    $0x10,%esp
  80049b:	eb 03                	jmp    8004a0 <printnum+0x78>
  80049d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004a0:	83 eb 01             	sub    $0x1,%ebx
  8004a3:	85 db                	test   %ebx,%ebx
  8004a5:	7f e8                	jg     80048f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	56                   	push   %esi
  8004ab:	83 ec 04             	sub    $0x4,%esp
  8004ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ba:	e8 a1 09 00 00       	call   800e60 <__umoddi3>
  8004bf:	83 c4 14             	add    $0x14,%esp
  8004c2:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  8004c9:	50                   	push   %eax
  8004ca:	ff d7                	call   *%edi
}
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d2:	5b                   	pop    %ebx
  8004d3:	5e                   	pop    %esi
  8004d4:	5f                   	pop    %edi
  8004d5:	5d                   	pop    %ebp
  8004d6:	c3                   	ret    

008004d7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004da:	83 fa 01             	cmp    $0x1,%edx
  8004dd:	7e 0e                	jle    8004ed <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004df:	8b 10                	mov    (%eax),%edx
  8004e1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004e4:	89 08                	mov    %ecx,(%eax)
  8004e6:	8b 02                	mov    (%edx),%eax
  8004e8:	8b 52 04             	mov    0x4(%edx),%edx
  8004eb:	eb 22                	jmp    80050f <getuint+0x38>
	else if (lflag)
  8004ed:	85 d2                	test   %edx,%edx
  8004ef:	74 10                	je     800501 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004f1:	8b 10                	mov    (%eax),%edx
  8004f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f6:	89 08                	mov    %ecx,(%eax)
  8004f8:	8b 02                	mov    (%edx),%eax
  8004fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ff:	eb 0e                	jmp    80050f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800501:	8b 10                	mov    (%eax),%edx
  800503:	8d 4a 04             	lea    0x4(%edx),%ecx
  800506:	89 08                	mov    %ecx,(%eax)
  800508:	8b 02                	mov    (%edx),%eax
  80050a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80050f:	5d                   	pop    %ebp
  800510:	c3                   	ret    

00800511 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800517:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80051b:	8b 10                	mov    (%eax),%edx
  80051d:	3b 50 04             	cmp    0x4(%eax),%edx
  800520:	73 0a                	jae    80052c <sprintputch+0x1b>
		*b->buf++ = ch;
  800522:	8d 4a 01             	lea    0x1(%edx),%ecx
  800525:	89 08                	mov    %ecx,(%eax)
  800527:	8b 45 08             	mov    0x8(%ebp),%eax
  80052a:	88 02                	mov    %al,(%edx)
}
  80052c:	5d                   	pop    %ebp
  80052d:	c3                   	ret    

0080052e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80052e:	55                   	push   %ebp
  80052f:	89 e5                	mov    %esp,%ebp
  800531:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800534:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800537:	50                   	push   %eax
  800538:	ff 75 10             	pushl  0x10(%ebp)
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	ff 75 08             	pushl  0x8(%ebp)
  800541:	e8 05 00 00 00       	call   80054b <vprintfmt>
	va_end(ap);
}
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	57                   	push   %edi
  80054f:	56                   	push   %esi
  800550:	53                   	push   %ebx
  800551:	83 ec 2c             	sub    $0x2c,%esp
  800554:	8b 75 08             	mov    0x8(%ebp),%esi
  800557:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80055d:	eb 12                	jmp    800571 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80055f:	85 c0                	test   %eax,%eax
  800561:	0f 84 89 03 00 00    	je     8008f0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	53                   	push   %ebx
  80056b:	50                   	push   %eax
  80056c:	ff d6                	call   *%esi
  80056e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800571:	83 c7 01             	add    $0x1,%edi
  800574:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800578:	83 f8 25             	cmp    $0x25,%eax
  80057b:	75 e2                	jne    80055f <vprintfmt+0x14>
  80057d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800581:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800588:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80058f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800596:	ba 00 00 00 00       	mov    $0x0,%edx
  80059b:	eb 07                	jmp    8005a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005a0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8d 47 01             	lea    0x1(%edi),%eax
  8005a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005aa:	0f b6 07             	movzbl (%edi),%eax
  8005ad:	0f b6 c8             	movzbl %al,%ecx
  8005b0:	83 e8 23             	sub    $0x23,%eax
  8005b3:	3c 55                	cmp    $0x55,%al
  8005b5:	0f 87 1a 03 00 00    	ja     8008d5 <vprintfmt+0x38a>
  8005bb:	0f b6 c0             	movzbl %al,%eax
  8005be:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005cc:	eb d6                	jmp    8005a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005d9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005dc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005e0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005e3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005e6:	83 fa 09             	cmp    $0x9,%edx
  8005e9:	77 39                	ja     800624 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005eb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005ee:	eb e9                	jmp    8005d9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8d 48 04             	lea    0x4(%eax),%ecx
  8005f6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f9:	8b 00                	mov    (%eax),%eax
  8005fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800601:	eb 27                	jmp    80062a <vprintfmt+0xdf>
  800603:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800606:	85 c0                	test   %eax,%eax
  800608:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060d:	0f 49 c8             	cmovns %eax,%ecx
  800610:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800613:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800616:	eb 8c                	jmp    8005a4 <vprintfmt+0x59>
  800618:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80061b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800622:	eb 80                	jmp    8005a4 <vprintfmt+0x59>
  800624:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800627:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80062a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80062e:	0f 89 70 ff ff ff    	jns    8005a4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800634:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800637:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80063a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800641:	e9 5e ff ff ff       	jmp    8005a4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800646:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800649:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80064c:	e9 53 ff ff ff       	jmp    8005a4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 50 04             	lea    0x4(%eax),%edx
  800657:	89 55 14             	mov    %edx,0x14(%ebp)
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	ff 30                	pushl  (%eax)
  800660:	ff d6                	call   *%esi
			break;
  800662:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800665:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800668:	e9 04 ff ff ff       	jmp    800571 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 50 04             	lea    0x4(%eax),%edx
  800673:	89 55 14             	mov    %edx,0x14(%ebp)
  800676:	8b 00                	mov    (%eax),%eax
  800678:	99                   	cltd   
  800679:	31 d0                	xor    %edx,%eax
  80067b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80067d:	83 f8 08             	cmp    $0x8,%eax
  800680:	7f 0b                	jg     80068d <vprintfmt+0x142>
  800682:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800689:	85 d2                	test   %edx,%edx
  80068b:	75 18                	jne    8006a5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80068d:	50                   	push   %eax
  80068e:	68 36 10 80 00       	push   $0x801036
  800693:	53                   	push   %ebx
  800694:	56                   	push   %esi
  800695:	e8 94 fe ff ff       	call   80052e <printfmt>
  80069a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006a0:	e9 cc fe ff ff       	jmp    800571 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006a5:	52                   	push   %edx
  8006a6:	68 3f 10 80 00       	push   $0x80103f
  8006ab:	53                   	push   %ebx
  8006ac:	56                   	push   %esi
  8006ad:	e8 7c fe ff ff       	call   80052e <printfmt>
  8006b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b8:	e9 b4 fe ff ff       	jmp    800571 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8d 50 04             	lea    0x4(%eax),%edx
  8006c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006c8:	85 ff                	test   %edi,%edi
  8006ca:	b8 2f 10 80 00       	mov    $0x80102f,%eax
  8006cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d6:	0f 8e 94 00 00 00    	jle    800770 <vprintfmt+0x225>
  8006dc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006e0:	0f 84 98 00 00 00    	je     80077e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	ff 75 d0             	pushl  -0x30(%ebp)
  8006ec:	57                   	push   %edi
  8006ed:	e8 86 02 00 00       	call   800978 <strnlen>
  8006f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006f5:	29 c1                	sub    %eax,%ecx
  8006f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006fa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006fd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800701:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800704:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800707:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800709:	eb 0f                	jmp    80071a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	53                   	push   %ebx
  80070f:	ff 75 e0             	pushl  -0x20(%ebp)
  800712:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800714:	83 ef 01             	sub    $0x1,%edi
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	85 ff                	test   %edi,%edi
  80071c:	7f ed                	jg     80070b <vprintfmt+0x1c0>
  80071e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800721:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800724:	85 c9                	test   %ecx,%ecx
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
  80072b:	0f 49 c1             	cmovns %ecx,%eax
  80072e:	29 c1                	sub    %eax,%ecx
  800730:	89 75 08             	mov    %esi,0x8(%ebp)
  800733:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800736:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800739:	89 cb                	mov    %ecx,%ebx
  80073b:	eb 4d                	jmp    80078a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80073d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800741:	74 1b                	je     80075e <vprintfmt+0x213>
  800743:	0f be c0             	movsbl %al,%eax
  800746:	83 e8 20             	sub    $0x20,%eax
  800749:	83 f8 5e             	cmp    $0x5e,%eax
  80074c:	76 10                	jbe    80075e <vprintfmt+0x213>
					putch('?', putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	6a 3f                	push   $0x3f
  800756:	ff 55 08             	call   *0x8(%ebp)
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	eb 0d                	jmp    80076b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	ff 75 0c             	pushl  0xc(%ebp)
  800764:	52                   	push   %edx
  800765:	ff 55 08             	call   *0x8(%ebp)
  800768:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076b:	83 eb 01             	sub    $0x1,%ebx
  80076e:	eb 1a                	jmp    80078a <vprintfmt+0x23f>
  800770:	89 75 08             	mov    %esi,0x8(%ebp)
  800773:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800776:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800779:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80077c:	eb 0c                	jmp    80078a <vprintfmt+0x23f>
  80077e:	89 75 08             	mov    %esi,0x8(%ebp)
  800781:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800784:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800787:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80078a:	83 c7 01             	add    $0x1,%edi
  80078d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800791:	0f be d0             	movsbl %al,%edx
  800794:	85 d2                	test   %edx,%edx
  800796:	74 23                	je     8007bb <vprintfmt+0x270>
  800798:	85 f6                	test   %esi,%esi
  80079a:	78 a1                	js     80073d <vprintfmt+0x1f2>
  80079c:	83 ee 01             	sub    $0x1,%esi
  80079f:	79 9c                	jns    80073d <vprintfmt+0x1f2>
  8007a1:	89 df                	mov    %ebx,%edi
  8007a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a9:	eb 18                	jmp    8007c3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	53                   	push   %ebx
  8007af:	6a 20                	push   $0x20
  8007b1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b3:	83 ef 01             	sub    $0x1,%edi
  8007b6:	83 c4 10             	add    $0x10,%esp
  8007b9:	eb 08                	jmp    8007c3 <vprintfmt+0x278>
  8007bb:	89 df                	mov    %ebx,%edi
  8007bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c3:	85 ff                	test   %edi,%edi
  8007c5:	7f e4                	jg     8007ab <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ca:	e9 a2 fd ff ff       	jmp    800571 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007cf:	83 fa 01             	cmp    $0x1,%edx
  8007d2:	7e 16                	jle    8007ea <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8d 50 08             	lea    0x8(%eax),%edx
  8007da:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dd:	8b 50 04             	mov    0x4(%eax),%edx
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e8:	eb 32                	jmp    80081c <vprintfmt+0x2d1>
	else if (lflag)
  8007ea:	85 d2                	test   %edx,%edx
  8007ec:	74 18                	je     800806 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f1:	8d 50 04             	lea    0x4(%eax),%edx
  8007f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f7:	8b 00                	mov    (%eax),%eax
  8007f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fc:	89 c1                	mov    %eax,%ecx
  8007fe:	c1 f9 1f             	sar    $0x1f,%ecx
  800801:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800804:	eb 16                	jmp    80081c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8d 50 04             	lea    0x4(%eax),%edx
  80080c:	89 55 14             	mov    %edx,0x14(%ebp)
  80080f:	8b 00                	mov    (%eax),%eax
  800811:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800814:	89 c1                	mov    %eax,%ecx
  800816:	c1 f9 1f             	sar    $0x1f,%ecx
  800819:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80081c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80081f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800822:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800827:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80082b:	79 74                	jns    8008a1 <vprintfmt+0x356>
				putch('-', putdat);
  80082d:	83 ec 08             	sub    $0x8,%esp
  800830:	53                   	push   %ebx
  800831:	6a 2d                	push   $0x2d
  800833:	ff d6                	call   *%esi
				num = -(long long) num;
  800835:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800838:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80083b:	f7 d8                	neg    %eax
  80083d:	83 d2 00             	adc    $0x0,%edx
  800840:	f7 da                	neg    %edx
  800842:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800845:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80084a:	eb 55                	jmp    8008a1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80084c:	8d 45 14             	lea    0x14(%ebp),%eax
  80084f:	e8 83 fc ff ff       	call   8004d7 <getuint>
			base = 10;
  800854:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800859:	eb 46                	jmp    8008a1 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80085b:	8d 45 14             	lea    0x14(%ebp),%eax
  80085e:	e8 74 fc ff ff       	call   8004d7 <getuint>
			base = 8;
  800863:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800868:	eb 37                	jmp    8008a1 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	53                   	push   %ebx
  80086e:	6a 30                	push   $0x30
  800870:	ff d6                	call   *%esi
			putch('x', putdat);
  800872:	83 c4 08             	add    $0x8,%esp
  800875:	53                   	push   %ebx
  800876:	6a 78                	push   $0x78
  800878:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087a:	8b 45 14             	mov    0x14(%ebp),%eax
  80087d:	8d 50 04             	lea    0x4(%eax),%edx
  800880:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800883:	8b 00                	mov    (%eax),%eax
  800885:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80088a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80088d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800892:	eb 0d                	jmp    8008a1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800894:	8d 45 14             	lea    0x14(%ebp),%eax
  800897:	e8 3b fc ff ff       	call   8004d7 <getuint>
			base = 16;
  80089c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a1:	83 ec 0c             	sub    $0xc,%esp
  8008a4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008a8:	57                   	push   %edi
  8008a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ac:	51                   	push   %ecx
  8008ad:	52                   	push   %edx
  8008ae:	50                   	push   %eax
  8008af:	89 da                	mov    %ebx,%edx
  8008b1:	89 f0                	mov    %esi,%eax
  8008b3:	e8 70 fb ff ff       	call   800428 <printnum>
			break;
  8008b8:	83 c4 20             	add    $0x20,%esp
  8008bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008be:	e9 ae fc ff ff       	jmp    800571 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	51                   	push   %ecx
  8008c8:	ff d6                	call   *%esi
			break;
  8008ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008d0:	e9 9c fc ff ff       	jmp    800571 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d5:	83 ec 08             	sub    $0x8,%esp
  8008d8:	53                   	push   %ebx
  8008d9:	6a 25                	push   $0x25
  8008db:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	eb 03                	jmp    8008e5 <vprintfmt+0x39a>
  8008e2:	83 ef 01             	sub    $0x1,%edi
  8008e5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008e9:	75 f7                	jne    8008e2 <vprintfmt+0x397>
  8008eb:	e9 81 fc ff ff       	jmp    800571 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008f3:	5b                   	pop    %ebx
  8008f4:	5e                   	pop    %esi
  8008f5:	5f                   	pop    %edi
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	83 ec 18             	sub    $0x18,%esp
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800904:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800907:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80090b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80090e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800915:	85 c0                	test   %eax,%eax
  800917:	74 26                	je     80093f <vsnprintf+0x47>
  800919:	85 d2                	test   %edx,%edx
  80091b:	7e 22                	jle    80093f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80091d:	ff 75 14             	pushl  0x14(%ebp)
  800920:	ff 75 10             	pushl  0x10(%ebp)
  800923:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800926:	50                   	push   %eax
  800927:	68 11 05 80 00       	push   $0x800511
  80092c:	e8 1a fc ff ff       	call   80054b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800931:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800934:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800937:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80093a:	83 c4 10             	add    $0x10,%esp
  80093d:	eb 05                	jmp    800944 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80093f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80094c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80094f:	50                   	push   %eax
  800950:	ff 75 10             	pushl  0x10(%ebp)
  800953:	ff 75 0c             	pushl  0xc(%ebp)
  800956:	ff 75 08             	pushl  0x8(%ebp)
  800959:	e8 9a ff ff ff       	call   8008f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80095e:	c9                   	leave  
  80095f:	c3                   	ret    

00800960 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800966:	b8 00 00 00 00       	mov    $0x0,%eax
  80096b:	eb 03                	jmp    800970 <strlen+0x10>
		n++;
  80096d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800970:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800974:	75 f7                	jne    80096d <strlen+0xd>
		n++;
	return n;
}
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800981:	ba 00 00 00 00       	mov    $0x0,%edx
  800986:	eb 03                	jmp    80098b <strnlen+0x13>
		n++;
  800988:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098b:	39 c2                	cmp    %eax,%edx
  80098d:	74 08                	je     800997 <strnlen+0x1f>
  80098f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800993:	75 f3                	jne    800988 <strnlen+0x10>
  800995:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	53                   	push   %ebx
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a3:	89 c2                	mov    %eax,%edx
  8009a5:	83 c2 01             	add    $0x1,%edx
  8009a8:	83 c1 01             	add    $0x1,%ecx
  8009ab:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009af:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009b2:	84 db                	test   %bl,%bl
  8009b4:	75 ef                	jne    8009a5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009b6:	5b                   	pop    %ebx
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	53                   	push   %ebx
  8009bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c0:	53                   	push   %ebx
  8009c1:	e8 9a ff ff ff       	call   800960 <strlen>
  8009c6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009c9:	ff 75 0c             	pushl  0xc(%ebp)
  8009cc:	01 d8                	add    %ebx,%eax
  8009ce:	50                   	push   %eax
  8009cf:	e8 c5 ff ff ff       	call   800999 <strcpy>
	return dst;
}
  8009d4:	89 d8                	mov    %ebx,%eax
  8009d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	56                   	push   %esi
  8009df:	53                   	push   %ebx
  8009e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e6:	89 f3                	mov    %esi,%ebx
  8009e8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009eb:	89 f2                	mov    %esi,%edx
  8009ed:	eb 0f                	jmp    8009fe <strncpy+0x23>
		*dst++ = *src;
  8009ef:	83 c2 01             	add    $0x1,%edx
  8009f2:	0f b6 01             	movzbl (%ecx),%eax
  8009f5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009f8:	80 39 01             	cmpb   $0x1,(%ecx)
  8009fb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009fe:	39 da                	cmp    %ebx,%edx
  800a00:	75 ed                	jne    8009ef <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a02:	89 f0                	mov    %esi,%eax
  800a04:	5b                   	pop    %ebx
  800a05:	5e                   	pop    %esi
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a13:	8b 55 10             	mov    0x10(%ebp),%edx
  800a16:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a18:	85 d2                	test   %edx,%edx
  800a1a:	74 21                	je     800a3d <strlcpy+0x35>
  800a1c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a20:	89 f2                	mov    %esi,%edx
  800a22:	eb 09                	jmp    800a2d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a24:	83 c2 01             	add    $0x1,%edx
  800a27:	83 c1 01             	add    $0x1,%ecx
  800a2a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a2d:	39 c2                	cmp    %eax,%edx
  800a2f:	74 09                	je     800a3a <strlcpy+0x32>
  800a31:	0f b6 19             	movzbl (%ecx),%ebx
  800a34:	84 db                	test   %bl,%bl
  800a36:	75 ec                	jne    800a24 <strlcpy+0x1c>
  800a38:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a3a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a3d:	29 f0                	sub    %esi,%eax
}
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a49:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a4c:	eb 06                	jmp    800a54 <strcmp+0x11>
		p++, q++;
  800a4e:	83 c1 01             	add    $0x1,%ecx
  800a51:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a54:	0f b6 01             	movzbl (%ecx),%eax
  800a57:	84 c0                	test   %al,%al
  800a59:	74 04                	je     800a5f <strcmp+0x1c>
  800a5b:	3a 02                	cmp    (%edx),%al
  800a5d:	74 ef                	je     800a4e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a5f:	0f b6 c0             	movzbl %al,%eax
  800a62:	0f b6 12             	movzbl (%edx),%edx
  800a65:	29 d0                	sub    %edx,%eax
}
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	53                   	push   %ebx
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a73:	89 c3                	mov    %eax,%ebx
  800a75:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a78:	eb 06                	jmp    800a80 <strncmp+0x17>
		n--, p++, q++;
  800a7a:	83 c0 01             	add    $0x1,%eax
  800a7d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a80:	39 d8                	cmp    %ebx,%eax
  800a82:	74 15                	je     800a99 <strncmp+0x30>
  800a84:	0f b6 08             	movzbl (%eax),%ecx
  800a87:	84 c9                	test   %cl,%cl
  800a89:	74 04                	je     800a8f <strncmp+0x26>
  800a8b:	3a 0a                	cmp    (%edx),%cl
  800a8d:	74 eb                	je     800a7a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8f:	0f b6 00             	movzbl (%eax),%eax
  800a92:	0f b6 12             	movzbl (%edx),%edx
  800a95:	29 d0                	sub    %edx,%eax
  800a97:	eb 05                	jmp    800a9e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a99:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a9e:	5b                   	pop    %ebx
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aab:	eb 07                	jmp    800ab4 <strchr+0x13>
		if (*s == c)
  800aad:	38 ca                	cmp    %cl,%dl
  800aaf:	74 0f                	je     800ac0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ab1:	83 c0 01             	add    $0x1,%eax
  800ab4:	0f b6 10             	movzbl (%eax),%edx
  800ab7:	84 d2                	test   %dl,%dl
  800ab9:	75 f2                	jne    800aad <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800acc:	eb 03                	jmp    800ad1 <strfind+0xf>
  800ace:	83 c0 01             	add    $0x1,%eax
  800ad1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ad4:	38 ca                	cmp    %cl,%dl
  800ad6:	74 04                	je     800adc <strfind+0x1a>
  800ad8:	84 d2                	test   %dl,%dl
  800ada:	75 f2                	jne    800ace <strfind+0xc>
			break;
	return (char *) s;
}
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
  800ae4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aea:	85 c9                	test   %ecx,%ecx
  800aec:	74 36                	je     800b24 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af4:	75 28                	jne    800b1e <memset+0x40>
  800af6:	f6 c1 03             	test   $0x3,%cl
  800af9:	75 23                	jne    800b1e <memset+0x40>
		c &= 0xFF;
  800afb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aff:	89 d3                	mov    %edx,%ebx
  800b01:	c1 e3 08             	shl    $0x8,%ebx
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	c1 e6 18             	shl    $0x18,%esi
  800b09:	89 d0                	mov    %edx,%eax
  800b0b:	c1 e0 10             	shl    $0x10,%eax
  800b0e:	09 f0                	or     %esi,%eax
  800b10:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b12:	89 d8                	mov    %ebx,%eax
  800b14:	09 d0                	or     %edx,%eax
  800b16:	c1 e9 02             	shr    $0x2,%ecx
  800b19:	fc                   	cld    
  800b1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b1c:	eb 06                	jmp    800b24 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b21:	fc                   	cld    
  800b22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b24:	89 f8                	mov    %edi,%eax
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b39:	39 c6                	cmp    %eax,%esi
  800b3b:	73 35                	jae    800b72 <memmove+0x47>
  800b3d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b40:	39 d0                	cmp    %edx,%eax
  800b42:	73 2e                	jae    800b72 <memmove+0x47>
		s += n;
		d += n;
  800b44:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b47:	89 d6                	mov    %edx,%esi
  800b49:	09 fe                	or     %edi,%esi
  800b4b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b51:	75 13                	jne    800b66 <memmove+0x3b>
  800b53:	f6 c1 03             	test   $0x3,%cl
  800b56:	75 0e                	jne    800b66 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b58:	83 ef 04             	sub    $0x4,%edi
  800b5b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b5e:	c1 e9 02             	shr    $0x2,%ecx
  800b61:	fd                   	std    
  800b62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b64:	eb 09                	jmp    800b6f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b66:	83 ef 01             	sub    $0x1,%edi
  800b69:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b6c:	fd                   	std    
  800b6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b6f:	fc                   	cld    
  800b70:	eb 1d                	jmp    800b8f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b72:	89 f2                	mov    %esi,%edx
  800b74:	09 c2                	or     %eax,%edx
  800b76:	f6 c2 03             	test   $0x3,%dl
  800b79:	75 0f                	jne    800b8a <memmove+0x5f>
  800b7b:	f6 c1 03             	test   $0x3,%cl
  800b7e:	75 0a                	jne    800b8a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b80:	c1 e9 02             	shr    $0x2,%ecx
  800b83:	89 c7                	mov    %eax,%edi
  800b85:	fc                   	cld    
  800b86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b88:	eb 05                	jmp    800b8f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b8a:	89 c7                	mov    %eax,%edi
  800b8c:	fc                   	cld    
  800b8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b96:	ff 75 10             	pushl  0x10(%ebp)
  800b99:	ff 75 0c             	pushl  0xc(%ebp)
  800b9c:	ff 75 08             	pushl  0x8(%ebp)
  800b9f:	e8 87 ff ff ff       	call   800b2b <memmove>
}
  800ba4:	c9                   	leave  
  800ba5:	c3                   	ret    

00800ba6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	8b 45 08             	mov    0x8(%ebp),%eax
  800bae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb1:	89 c6                	mov    %eax,%esi
  800bb3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb6:	eb 1a                	jmp    800bd2 <memcmp+0x2c>
		if (*s1 != *s2)
  800bb8:	0f b6 08             	movzbl (%eax),%ecx
  800bbb:	0f b6 1a             	movzbl (%edx),%ebx
  800bbe:	38 d9                	cmp    %bl,%cl
  800bc0:	74 0a                	je     800bcc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bc2:	0f b6 c1             	movzbl %cl,%eax
  800bc5:	0f b6 db             	movzbl %bl,%ebx
  800bc8:	29 d8                	sub    %ebx,%eax
  800bca:	eb 0f                	jmp    800bdb <memcmp+0x35>
		s1++, s2++;
  800bcc:	83 c0 01             	add    $0x1,%eax
  800bcf:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd2:	39 f0                	cmp    %esi,%eax
  800bd4:	75 e2                	jne    800bb8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	53                   	push   %ebx
  800be3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800be6:	89 c1                	mov    %eax,%ecx
  800be8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800beb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bef:	eb 0a                	jmp    800bfb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf1:	0f b6 10             	movzbl (%eax),%edx
  800bf4:	39 da                	cmp    %ebx,%edx
  800bf6:	74 07                	je     800bff <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf8:	83 c0 01             	add    $0x1,%eax
  800bfb:	39 c8                	cmp    %ecx,%eax
  800bfd:	72 f2                	jb     800bf1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bff:	5b                   	pop    %ebx
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0e:	eb 03                	jmp    800c13 <strtol+0x11>
		s++;
  800c10:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c13:	0f b6 01             	movzbl (%ecx),%eax
  800c16:	3c 20                	cmp    $0x20,%al
  800c18:	74 f6                	je     800c10 <strtol+0xe>
  800c1a:	3c 09                	cmp    $0x9,%al
  800c1c:	74 f2                	je     800c10 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c1e:	3c 2b                	cmp    $0x2b,%al
  800c20:	75 0a                	jne    800c2c <strtol+0x2a>
		s++;
  800c22:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c25:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2a:	eb 11                	jmp    800c3d <strtol+0x3b>
  800c2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c31:	3c 2d                	cmp    $0x2d,%al
  800c33:	75 08                	jne    800c3d <strtol+0x3b>
		s++, neg = 1;
  800c35:	83 c1 01             	add    $0x1,%ecx
  800c38:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c43:	75 15                	jne    800c5a <strtol+0x58>
  800c45:	80 39 30             	cmpb   $0x30,(%ecx)
  800c48:	75 10                	jne    800c5a <strtol+0x58>
  800c4a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c4e:	75 7c                	jne    800ccc <strtol+0xca>
		s += 2, base = 16;
  800c50:	83 c1 02             	add    $0x2,%ecx
  800c53:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c58:	eb 16                	jmp    800c70 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c5a:	85 db                	test   %ebx,%ebx
  800c5c:	75 12                	jne    800c70 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c5e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c63:	80 39 30             	cmpb   $0x30,(%ecx)
  800c66:	75 08                	jne    800c70 <strtol+0x6e>
		s++, base = 8;
  800c68:	83 c1 01             	add    $0x1,%ecx
  800c6b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c70:	b8 00 00 00 00       	mov    $0x0,%eax
  800c75:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c78:	0f b6 11             	movzbl (%ecx),%edx
  800c7b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c7e:	89 f3                	mov    %esi,%ebx
  800c80:	80 fb 09             	cmp    $0x9,%bl
  800c83:	77 08                	ja     800c8d <strtol+0x8b>
			dig = *s - '0';
  800c85:	0f be d2             	movsbl %dl,%edx
  800c88:	83 ea 30             	sub    $0x30,%edx
  800c8b:	eb 22                	jmp    800caf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c90:	89 f3                	mov    %esi,%ebx
  800c92:	80 fb 19             	cmp    $0x19,%bl
  800c95:	77 08                	ja     800c9f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c97:	0f be d2             	movsbl %dl,%edx
  800c9a:	83 ea 57             	sub    $0x57,%edx
  800c9d:	eb 10                	jmp    800caf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ca2:	89 f3                	mov    %esi,%ebx
  800ca4:	80 fb 19             	cmp    $0x19,%bl
  800ca7:	77 16                	ja     800cbf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ca9:	0f be d2             	movsbl %dl,%edx
  800cac:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800caf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cb2:	7d 0b                	jge    800cbf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cb4:	83 c1 01             	add    $0x1,%ecx
  800cb7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cbb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cbd:	eb b9                	jmp    800c78 <strtol+0x76>

	if (endptr)
  800cbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc3:	74 0d                	je     800cd2 <strtol+0xd0>
		*endptr = (char *) s;
  800cc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cc8:	89 0e                	mov    %ecx,(%esi)
  800cca:	eb 06                	jmp    800cd2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ccc:	85 db                	test   %ebx,%ebx
  800cce:	74 98                	je     800c68 <strtol+0x66>
  800cd0:	eb 9e                	jmp    800c70 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cd2:	89 c2                	mov    %eax,%edx
  800cd4:	f7 da                	neg    %edx
  800cd6:	85 ff                	test   %edi,%edi
  800cd8:	0f 45 c2             	cmovne %edx,%eax
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800ce6:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800ced:	75 2e                	jne    800d1d <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800cef:	e8 36 f4 ff ff       	call   80012a <sys_getenvid>
  800cf4:	83 ec 04             	sub    $0x4,%esp
  800cf7:	68 07 0e 00 00       	push   $0xe07
  800cfc:	68 00 f0 bf ee       	push   $0xeebff000
  800d01:	50                   	push   %eax
  800d02:	e8 61 f4 ff ff       	call   800168 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800d07:	e8 1e f4 ff ff       	call   80012a <sys_getenvid>
  800d0c:	83 c4 08             	add    $0x8,%esp
  800d0f:	68 17 03 80 00       	push   $0x800317
  800d14:	50                   	push   %eax
  800d15:	e8 57 f5 ff ff       	call   800271 <sys_env_set_pgfault_upcall>
  800d1a:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d20:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    
  800d27:	66 90                	xchg   %ax,%ax
  800d29:	66 90                	xchg   %ax,%ax
  800d2b:	66 90                	xchg   %ax,%ax
  800d2d:	66 90                	xchg   %ax,%ax
  800d2f:	90                   	nop

00800d30 <__udivdi3>:
  800d30:	55                   	push   %ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 1c             	sub    $0x1c,%esp
  800d37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d47:	85 f6                	test   %esi,%esi
  800d49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d4d:	89 ca                	mov    %ecx,%edx
  800d4f:	89 f8                	mov    %edi,%eax
  800d51:	75 3d                	jne    800d90 <__udivdi3+0x60>
  800d53:	39 cf                	cmp    %ecx,%edi
  800d55:	0f 87 c5 00 00 00    	ja     800e20 <__udivdi3+0xf0>
  800d5b:	85 ff                	test   %edi,%edi
  800d5d:	89 fd                	mov    %edi,%ebp
  800d5f:	75 0b                	jne    800d6c <__udivdi3+0x3c>
  800d61:	b8 01 00 00 00       	mov    $0x1,%eax
  800d66:	31 d2                	xor    %edx,%edx
  800d68:	f7 f7                	div    %edi
  800d6a:	89 c5                	mov    %eax,%ebp
  800d6c:	89 c8                	mov    %ecx,%eax
  800d6e:	31 d2                	xor    %edx,%edx
  800d70:	f7 f5                	div    %ebp
  800d72:	89 c1                	mov    %eax,%ecx
  800d74:	89 d8                	mov    %ebx,%eax
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	f7 f5                	div    %ebp
  800d7a:	89 c3                	mov    %eax,%ebx
  800d7c:	89 d8                	mov    %ebx,%eax
  800d7e:	89 fa                	mov    %edi,%edx
  800d80:	83 c4 1c             	add    $0x1c,%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    
  800d88:	90                   	nop
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	39 ce                	cmp    %ecx,%esi
  800d92:	77 74                	ja     800e08 <__udivdi3+0xd8>
  800d94:	0f bd fe             	bsr    %esi,%edi
  800d97:	83 f7 1f             	xor    $0x1f,%edi
  800d9a:	0f 84 98 00 00 00    	je     800e38 <__udivdi3+0x108>
  800da0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	89 c5                	mov    %eax,%ebp
  800da9:	29 fb                	sub    %edi,%ebx
  800dab:	d3 e6                	shl    %cl,%esi
  800dad:	89 d9                	mov    %ebx,%ecx
  800daf:	d3 ed                	shr    %cl,%ebp
  800db1:	89 f9                	mov    %edi,%ecx
  800db3:	d3 e0                	shl    %cl,%eax
  800db5:	09 ee                	or     %ebp,%esi
  800db7:	89 d9                	mov    %ebx,%ecx
  800db9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dbd:	89 d5                	mov    %edx,%ebp
  800dbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800dc3:	d3 ed                	shr    %cl,%ebp
  800dc5:	89 f9                	mov    %edi,%ecx
  800dc7:	d3 e2                	shl    %cl,%edx
  800dc9:	89 d9                	mov    %ebx,%ecx
  800dcb:	d3 e8                	shr    %cl,%eax
  800dcd:	09 c2                	or     %eax,%edx
  800dcf:	89 d0                	mov    %edx,%eax
  800dd1:	89 ea                	mov    %ebp,%edx
  800dd3:	f7 f6                	div    %esi
  800dd5:	89 d5                	mov    %edx,%ebp
  800dd7:	89 c3                	mov    %eax,%ebx
  800dd9:	f7 64 24 0c          	mull   0xc(%esp)
  800ddd:	39 d5                	cmp    %edx,%ebp
  800ddf:	72 10                	jb     800df1 <__udivdi3+0xc1>
  800de1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800de5:	89 f9                	mov    %edi,%ecx
  800de7:	d3 e6                	shl    %cl,%esi
  800de9:	39 c6                	cmp    %eax,%esi
  800deb:	73 07                	jae    800df4 <__udivdi3+0xc4>
  800ded:	39 d5                	cmp    %edx,%ebp
  800def:	75 03                	jne    800df4 <__udivdi3+0xc4>
  800df1:	83 eb 01             	sub    $0x1,%ebx
  800df4:	31 ff                	xor    %edi,%edi
  800df6:	89 d8                	mov    %ebx,%eax
  800df8:	89 fa                	mov    %edi,%edx
  800dfa:	83 c4 1c             	add    $0x1c,%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    
  800e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e08:	31 ff                	xor    %edi,%edi
  800e0a:	31 db                	xor    %ebx,%ebx
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	89 fa                	mov    %edi,%edx
  800e10:	83 c4 1c             	add    $0x1c,%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
  800e18:	90                   	nop
  800e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e20:	89 d8                	mov    %ebx,%eax
  800e22:	f7 f7                	div    %edi
  800e24:	31 ff                	xor    %edi,%edi
  800e26:	89 c3                	mov    %eax,%ebx
  800e28:	89 d8                	mov    %ebx,%eax
  800e2a:	89 fa                	mov    %edi,%edx
  800e2c:	83 c4 1c             	add    $0x1c,%esp
  800e2f:	5b                   	pop    %ebx
  800e30:	5e                   	pop    %esi
  800e31:	5f                   	pop    %edi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    
  800e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e38:	39 ce                	cmp    %ecx,%esi
  800e3a:	72 0c                	jb     800e48 <__udivdi3+0x118>
  800e3c:	31 db                	xor    %ebx,%ebx
  800e3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e42:	0f 87 34 ff ff ff    	ja     800d7c <__udivdi3+0x4c>
  800e48:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e4d:	e9 2a ff ff ff       	jmp    800d7c <__udivdi3+0x4c>
  800e52:	66 90                	xchg   %ax,%ax
  800e54:	66 90                	xchg   %ax,%ax
  800e56:	66 90                	xchg   %ax,%ax
  800e58:	66 90                	xchg   %ax,%ax
  800e5a:	66 90                	xchg   %ax,%ax
  800e5c:	66 90                	xchg   %ax,%ax
  800e5e:	66 90                	xchg   %ax,%ax

00800e60 <__umoddi3>:
  800e60:	55                   	push   %ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 1c             	sub    $0x1c,%esp
  800e67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e77:	85 d2                	test   %edx,%edx
  800e79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e81:	89 f3                	mov    %esi,%ebx
  800e83:	89 3c 24             	mov    %edi,(%esp)
  800e86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e8a:	75 1c                	jne    800ea8 <__umoddi3+0x48>
  800e8c:	39 f7                	cmp    %esi,%edi
  800e8e:	76 50                	jbe    800ee0 <__umoddi3+0x80>
  800e90:	89 c8                	mov    %ecx,%eax
  800e92:	89 f2                	mov    %esi,%edx
  800e94:	f7 f7                	div    %edi
  800e96:	89 d0                	mov    %edx,%eax
  800e98:	31 d2                	xor    %edx,%edx
  800e9a:	83 c4 1c             	add    $0x1c,%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    
  800ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ea8:	39 f2                	cmp    %esi,%edx
  800eaa:	89 d0                	mov    %edx,%eax
  800eac:	77 52                	ja     800f00 <__umoddi3+0xa0>
  800eae:	0f bd ea             	bsr    %edx,%ebp
  800eb1:	83 f5 1f             	xor    $0x1f,%ebp
  800eb4:	75 5a                	jne    800f10 <__umoddi3+0xb0>
  800eb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eba:	0f 82 e0 00 00 00    	jb     800fa0 <__umoddi3+0x140>
  800ec0:	39 0c 24             	cmp    %ecx,(%esp)
  800ec3:	0f 86 d7 00 00 00    	jbe    800fa0 <__umoddi3+0x140>
  800ec9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ecd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ed1:	83 c4 1c             	add    $0x1c,%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    
  800ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	85 ff                	test   %edi,%edi
  800ee2:	89 fd                	mov    %edi,%ebp
  800ee4:	75 0b                	jne    800ef1 <__umoddi3+0x91>
  800ee6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	f7 f7                	div    %edi
  800eef:	89 c5                	mov    %eax,%ebp
  800ef1:	89 f0                	mov    %esi,%eax
  800ef3:	31 d2                	xor    %edx,%edx
  800ef5:	f7 f5                	div    %ebp
  800ef7:	89 c8                	mov    %ecx,%eax
  800ef9:	f7 f5                	div    %ebp
  800efb:	89 d0                	mov    %edx,%eax
  800efd:	eb 99                	jmp    800e98 <__umoddi3+0x38>
  800eff:	90                   	nop
  800f00:	89 c8                	mov    %ecx,%eax
  800f02:	89 f2                	mov    %esi,%edx
  800f04:	83 c4 1c             	add    $0x1c,%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    
  800f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f10:	8b 34 24             	mov    (%esp),%esi
  800f13:	bf 20 00 00 00       	mov    $0x20,%edi
  800f18:	89 e9                	mov    %ebp,%ecx
  800f1a:	29 ef                	sub    %ebp,%edi
  800f1c:	d3 e0                	shl    %cl,%eax
  800f1e:	89 f9                	mov    %edi,%ecx
  800f20:	89 f2                	mov    %esi,%edx
  800f22:	d3 ea                	shr    %cl,%edx
  800f24:	89 e9                	mov    %ebp,%ecx
  800f26:	09 c2                	or     %eax,%edx
  800f28:	89 d8                	mov    %ebx,%eax
  800f2a:	89 14 24             	mov    %edx,(%esp)
  800f2d:	89 f2                	mov    %esi,%edx
  800f2f:	d3 e2                	shl    %cl,%edx
  800f31:	89 f9                	mov    %edi,%ecx
  800f33:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f3b:	d3 e8                	shr    %cl,%eax
  800f3d:	89 e9                	mov    %ebp,%ecx
  800f3f:	89 c6                	mov    %eax,%esi
  800f41:	d3 e3                	shl    %cl,%ebx
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	89 d0                	mov    %edx,%eax
  800f47:	d3 e8                	shr    %cl,%eax
  800f49:	89 e9                	mov    %ebp,%ecx
  800f4b:	09 d8                	or     %ebx,%eax
  800f4d:	89 d3                	mov    %edx,%ebx
  800f4f:	89 f2                	mov    %esi,%edx
  800f51:	f7 34 24             	divl   (%esp)
  800f54:	89 d6                	mov    %edx,%esi
  800f56:	d3 e3                	shl    %cl,%ebx
  800f58:	f7 64 24 04          	mull   0x4(%esp)
  800f5c:	39 d6                	cmp    %edx,%esi
  800f5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f62:	89 d1                	mov    %edx,%ecx
  800f64:	89 c3                	mov    %eax,%ebx
  800f66:	72 08                	jb     800f70 <__umoddi3+0x110>
  800f68:	75 11                	jne    800f7b <__umoddi3+0x11b>
  800f6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f6e:	73 0b                	jae    800f7b <__umoddi3+0x11b>
  800f70:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f74:	1b 14 24             	sbb    (%esp),%edx
  800f77:	89 d1                	mov    %edx,%ecx
  800f79:	89 c3                	mov    %eax,%ebx
  800f7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f7f:	29 da                	sub    %ebx,%edx
  800f81:	19 ce                	sbb    %ecx,%esi
  800f83:	89 f9                	mov    %edi,%ecx
  800f85:	89 f0                	mov    %esi,%eax
  800f87:	d3 e0                	shl    %cl,%eax
  800f89:	89 e9                	mov    %ebp,%ecx
  800f8b:	d3 ea                	shr    %cl,%edx
  800f8d:	89 e9                	mov    %ebp,%ecx
  800f8f:	d3 ee                	shr    %cl,%esi
  800f91:	09 d0                	or     %edx,%eax
  800f93:	89 f2                	mov    %esi,%edx
  800f95:	83 c4 1c             	add    $0x1c,%esp
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5f                   	pop    %edi
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    
  800f9d:	8d 76 00             	lea    0x0(%esi),%esi
  800fa0:	29 f9                	sub    %edi,%ecx
  800fa2:	19 d6                	sbb    %edx,%esi
  800fa4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fac:	e9 18 ff ff ff       	jmp    800ec9 <__umoddi3+0x69>
