
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
  80011d:	e8 18 02 00 00       	call   80033a <_panic>

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
  80019e:	e8 97 01 00 00       	call   80033a <_panic>

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
  8001e0:	e8 55 01 00 00       	call   80033a <_panic>

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
  800222:	e8 13 01 00 00       	call   80033a <_panic>

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
  800264:	e8 d1 00 00 00       	call   80033a <_panic>

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
  8002a6:	e8 8f 00 00 00       	call   80033a <_panic>

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
  80030a:	e8 2b 00 00 00       	call   80033a <_panic>

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
	popf					// pop to eflags
  800334:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  800335:	5c                   	pop    %esp
	subl $4, %esp
  800336:	83 ec 04             	sub    $0x4,%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800339:	c3                   	ret    

0080033a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	56                   	push   %esi
  80033e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80033f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800342:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800348:	e8 dd fd ff ff       	call   80012a <sys_getenvid>
  80034d:	83 ec 0c             	sub    $0xc,%esp
  800350:	ff 75 0c             	pushl  0xc(%ebp)
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	56                   	push   %esi
  800357:	50                   	push   %eax
  800358:	68 f8 0f 80 00       	push   $0x800ff8
  80035d:	e8 b1 00 00 00       	call   800413 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800362:	83 c4 18             	add    $0x18,%esp
  800365:	53                   	push   %ebx
  800366:	ff 75 10             	pushl  0x10(%ebp)
  800369:	e8 54 00 00 00       	call   8003c2 <vcprintf>
	cprintf("\n");
  80036e:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  800375:	e8 99 00 00 00       	call   800413 <cprintf>
  80037a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037d:	cc                   	int3   
  80037e:	eb fd                	jmp    80037d <_panic+0x43>

00800380 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	53                   	push   %ebx
  800384:	83 ec 04             	sub    $0x4,%esp
  800387:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038a:	8b 13                	mov    (%ebx),%edx
  80038c:	8d 42 01             	lea    0x1(%edx),%eax
  80038f:	89 03                	mov    %eax,(%ebx)
  800391:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800394:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800398:	3d ff 00 00 00       	cmp    $0xff,%eax
  80039d:	75 1a                	jne    8003b9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80039f:	83 ec 08             	sub    $0x8,%esp
  8003a2:	68 ff 00 00 00       	push   $0xff
  8003a7:	8d 43 08             	lea    0x8(%ebx),%eax
  8003aa:	50                   	push   %eax
  8003ab:	e8 fc fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003b6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003b9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c0:	c9                   	leave  
  8003c1:	c3                   	ret    

008003c2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
  8003c5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003cb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d2:	00 00 00 
	b.cnt = 0;
  8003d5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003dc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003df:	ff 75 0c             	pushl  0xc(%ebp)
  8003e2:	ff 75 08             	pushl  0x8(%ebp)
  8003e5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003eb:	50                   	push   %eax
  8003ec:	68 80 03 80 00       	push   $0x800380
  8003f1:	e8 54 01 00 00       	call   80054a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f6:	83 c4 08             	add    $0x8,%esp
  8003f9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ff:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800405:	50                   	push   %eax
  800406:	e8 a1 fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80040b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800411:	c9                   	leave  
  800412:	c3                   	ret    

00800413 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800419:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80041c:	50                   	push   %eax
  80041d:	ff 75 08             	pushl  0x8(%ebp)
  800420:	e8 9d ff ff ff       	call   8003c2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800425:	c9                   	leave  
  800426:	c3                   	ret    

00800427 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	57                   	push   %edi
  80042b:	56                   	push   %esi
  80042c:	53                   	push   %ebx
  80042d:	83 ec 1c             	sub    $0x1c,%esp
  800430:	89 c7                	mov    %eax,%edi
  800432:	89 d6                	mov    %edx,%esi
  800434:	8b 45 08             	mov    0x8(%ebp),%eax
  800437:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800440:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800443:	bb 00 00 00 00       	mov    $0x0,%ebx
  800448:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80044b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80044e:	39 d3                	cmp    %edx,%ebx
  800450:	72 05                	jb     800457 <printnum+0x30>
  800452:	39 45 10             	cmp    %eax,0x10(%ebp)
  800455:	77 45                	ja     80049c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800457:	83 ec 0c             	sub    $0xc,%esp
  80045a:	ff 75 18             	pushl  0x18(%ebp)
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800463:	53                   	push   %ebx
  800464:	ff 75 10             	pushl  0x10(%ebp)
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046d:	ff 75 e0             	pushl  -0x20(%ebp)
  800470:	ff 75 dc             	pushl  -0x24(%ebp)
  800473:	ff 75 d8             	pushl  -0x28(%ebp)
  800476:	e8 b5 08 00 00       	call   800d30 <__udivdi3>
  80047b:	83 c4 18             	add    $0x18,%esp
  80047e:	52                   	push   %edx
  80047f:	50                   	push   %eax
  800480:	89 f2                	mov    %esi,%edx
  800482:	89 f8                	mov    %edi,%eax
  800484:	e8 9e ff ff ff       	call   800427 <printnum>
  800489:	83 c4 20             	add    $0x20,%esp
  80048c:	eb 18                	jmp    8004a6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	56                   	push   %esi
  800492:	ff 75 18             	pushl  0x18(%ebp)
  800495:	ff d7                	call   *%edi
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	eb 03                	jmp    80049f <printnum+0x78>
  80049c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80049f:	83 eb 01             	sub    $0x1,%ebx
  8004a2:	85 db                	test   %ebx,%ebx
  8004a4:	7f e8                	jg     80048e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a6:	83 ec 08             	sub    $0x8,%esp
  8004a9:	56                   	push   %esi
  8004aa:	83 ec 04             	sub    $0x4,%esp
  8004ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b9:	e8 a2 09 00 00       	call   800e60 <__umoddi3>
  8004be:	83 c4 14             	add    $0x14,%esp
  8004c1:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  8004c8:	50                   	push   %eax
  8004c9:	ff d7                	call   *%edi
}
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d1:	5b                   	pop    %ebx
  8004d2:	5e                   	pop    %esi
  8004d3:	5f                   	pop    %edi
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d9:	83 fa 01             	cmp    $0x1,%edx
  8004dc:	7e 0e                	jle    8004ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004de:	8b 10                	mov    (%eax),%edx
  8004e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004e3:	89 08                	mov    %ecx,(%eax)
  8004e5:	8b 02                	mov    (%edx),%eax
  8004e7:	8b 52 04             	mov    0x4(%edx),%edx
  8004ea:	eb 22                	jmp    80050e <getuint+0x38>
	else if (lflag)
  8004ec:	85 d2                	test   %edx,%edx
  8004ee:	74 10                	je     800500 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004f0:	8b 10                	mov    (%eax),%edx
  8004f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f5:	89 08                	mov    %ecx,(%eax)
  8004f7:	8b 02                	mov    (%edx),%eax
  8004f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fe:	eb 0e                	jmp    80050e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800500:	8b 10                	mov    (%eax),%edx
  800502:	8d 4a 04             	lea    0x4(%edx),%ecx
  800505:	89 08                	mov    %ecx,(%eax)
  800507:	8b 02                	mov    (%edx),%eax
  800509:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80050e:	5d                   	pop    %ebp
  80050f:	c3                   	ret    

00800510 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800516:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80051a:	8b 10                	mov    (%eax),%edx
  80051c:	3b 50 04             	cmp    0x4(%eax),%edx
  80051f:	73 0a                	jae    80052b <sprintputch+0x1b>
		*b->buf++ = ch;
  800521:	8d 4a 01             	lea    0x1(%edx),%ecx
  800524:	89 08                	mov    %ecx,(%eax)
  800526:	8b 45 08             	mov    0x8(%ebp),%eax
  800529:	88 02                	mov    %al,(%edx)
}
  80052b:	5d                   	pop    %ebp
  80052c:	c3                   	ret    

0080052d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80052d:	55                   	push   %ebp
  80052e:	89 e5                	mov    %esp,%ebp
  800530:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800533:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800536:	50                   	push   %eax
  800537:	ff 75 10             	pushl  0x10(%ebp)
  80053a:	ff 75 0c             	pushl  0xc(%ebp)
  80053d:	ff 75 08             	pushl  0x8(%ebp)
  800540:	e8 05 00 00 00       	call   80054a <vprintfmt>
	va_end(ap);
}
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	c9                   	leave  
  800549:	c3                   	ret    

0080054a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80054a:	55                   	push   %ebp
  80054b:	89 e5                	mov    %esp,%ebp
  80054d:	57                   	push   %edi
  80054e:	56                   	push   %esi
  80054f:	53                   	push   %ebx
  800550:	83 ec 2c             	sub    $0x2c,%esp
  800553:	8b 75 08             	mov    0x8(%ebp),%esi
  800556:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800559:	8b 7d 10             	mov    0x10(%ebp),%edi
  80055c:	eb 12                	jmp    800570 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80055e:	85 c0                	test   %eax,%eax
  800560:	0f 84 89 03 00 00    	je     8008ef <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800566:	83 ec 08             	sub    $0x8,%esp
  800569:	53                   	push   %ebx
  80056a:	50                   	push   %eax
  80056b:	ff d6                	call   *%esi
  80056d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800570:	83 c7 01             	add    $0x1,%edi
  800573:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800577:	83 f8 25             	cmp    $0x25,%eax
  80057a:	75 e2                	jne    80055e <vprintfmt+0x14>
  80057c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800580:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800587:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80058e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800595:	ba 00 00 00 00       	mov    $0x0,%edx
  80059a:	eb 07                	jmp    8005a3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80059f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8d 47 01             	lea    0x1(%edi),%eax
  8005a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a9:	0f b6 07             	movzbl (%edi),%eax
  8005ac:	0f b6 c8             	movzbl %al,%ecx
  8005af:	83 e8 23             	sub    $0x23,%eax
  8005b2:	3c 55                	cmp    $0x55,%al
  8005b4:	0f 87 1a 03 00 00    	ja     8008d4 <vprintfmt+0x38a>
  8005ba:	0f b6 c0             	movzbl %al,%eax
  8005bd:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8005c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005cb:	eb d6                	jmp    8005a3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005d8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005db:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005df:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005e2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005e5:	83 fa 09             	cmp    $0x9,%edx
  8005e8:	77 39                	ja     800623 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ea:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005ed:	eb e9                	jmp    8005d8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 48 04             	lea    0x4(%eax),%ecx
  8005f5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800600:	eb 27                	jmp    800629 <vprintfmt+0xdf>
  800602:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800605:	85 c0                	test   %eax,%eax
  800607:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060c:	0f 49 c8             	cmovns %eax,%ecx
  80060f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800615:	eb 8c                	jmp    8005a3 <vprintfmt+0x59>
  800617:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80061a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800621:	eb 80                	jmp    8005a3 <vprintfmt+0x59>
  800623:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800626:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800629:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80062d:	0f 89 70 ff ff ff    	jns    8005a3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800633:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800636:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800639:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800640:	e9 5e ff ff ff       	jmp    8005a3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800645:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800648:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80064b:	e9 53 ff ff ff       	jmp    8005a3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 50 04             	lea    0x4(%eax),%edx
  800656:	89 55 14             	mov    %edx,0x14(%ebp)
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	ff 30                	pushl  (%eax)
  80065f:	ff d6                	call   *%esi
			break;
  800661:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800667:	e9 04 ff ff ff       	jmp    800570 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 04             	lea    0x4(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)
  800675:	8b 00                	mov    (%eax),%eax
  800677:	99                   	cltd   
  800678:	31 d0                	xor    %edx,%eax
  80067a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80067c:	83 f8 08             	cmp    $0x8,%eax
  80067f:	7f 0b                	jg     80068c <vprintfmt+0x142>
  800681:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800688:	85 d2                	test   %edx,%edx
  80068a:	75 18                	jne    8006a4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80068c:	50                   	push   %eax
  80068d:	68 36 10 80 00       	push   $0x801036
  800692:	53                   	push   %ebx
  800693:	56                   	push   %esi
  800694:	e8 94 fe ff ff       	call   80052d <printfmt>
  800699:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80069f:	e9 cc fe ff ff       	jmp    800570 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006a4:	52                   	push   %edx
  8006a5:	68 3f 10 80 00       	push   $0x80103f
  8006aa:	53                   	push   %ebx
  8006ab:	56                   	push   %esi
  8006ac:	e8 7c fe ff ff       	call   80052d <printfmt>
  8006b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b7:	e9 b4 fe ff ff       	jmp    800570 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8d 50 04             	lea    0x4(%eax),%edx
  8006c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006c7:	85 ff                	test   %edi,%edi
  8006c9:	b8 2f 10 80 00       	mov    $0x80102f,%eax
  8006ce:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d5:	0f 8e 94 00 00 00    	jle    80076f <vprintfmt+0x225>
  8006db:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006df:	0f 84 98 00 00 00    	je     80077d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	ff 75 d0             	pushl  -0x30(%ebp)
  8006eb:	57                   	push   %edi
  8006ec:	e8 86 02 00 00       	call   800977 <strnlen>
  8006f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006f4:	29 c1                	sub    %eax,%ecx
  8006f6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006f9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006fc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800700:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800703:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800706:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800708:	eb 0f                	jmp    800719 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	ff 75 e0             	pushl  -0x20(%ebp)
  800711:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800713:	83 ef 01             	sub    $0x1,%edi
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	85 ff                	test   %edi,%edi
  80071b:	7f ed                	jg     80070a <vprintfmt+0x1c0>
  80071d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800720:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800723:	85 c9                	test   %ecx,%ecx
  800725:	b8 00 00 00 00       	mov    $0x0,%eax
  80072a:	0f 49 c1             	cmovns %ecx,%eax
  80072d:	29 c1                	sub    %eax,%ecx
  80072f:	89 75 08             	mov    %esi,0x8(%ebp)
  800732:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800735:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800738:	89 cb                	mov    %ecx,%ebx
  80073a:	eb 4d                	jmp    800789 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80073c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800740:	74 1b                	je     80075d <vprintfmt+0x213>
  800742:	0f be c0             	movsbl %al,%eax
  800745:	83 e8 20             	sub    $0x20,%eax
  800748:	83 f8 5e             	cmp    $0x5e,%eax
  80074b:	76 10                	jbe    80075d <vprintfmt+0x213>
					putch('?', putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	6a 3f                	push   $0x3f
  800755:	ff 55 08             	call   *0x8(%ebp)
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	eb 0d                	jmp    80076a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	ff 75 0c             	pushl  0xc(%ebp)
  800763:	52                   	push   %edx
  800764:	ff 55 08             	call   *0x8(%ebp)
  800767:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076a:	83 eb 01             	sub    $0x1,%ebx
  80076d:	eb 1a                	jmp    800789 <vprintfmt+0x23f>
  80076f:	89 75 08             	mov    %esi,0x8(%ebp)
  800772:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800775:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800778:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80077b:	eb 0c                	jmp    800789 <vprintfmt+0x23f>
  80077d:	89 75 08             	mov    %esi,0x8(%ebp)
  800780:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800783:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800786:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800789:	83 c7 01             	add    $0x1,%edi
  80078c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800790:	0f be d0             	movsbl %al,%edx
  800793:	85 d2                	test   %edx,%edx
  800795:	74 23                	je     8007ba <vprintfmt+0x270>
  800797:	85 f6                	test   %esi,%esi
  800799:	78 a1                	js     80073c <vprintfmt+0x1f2>
  80079b:	83 ee 01             	sub    $0x1,%esi
  80079e:	79 9c                	jns    80073c <vprintfmt+0x1f2>
  8007a0:	89 df                	mov    %ebx,%edi
  8007a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a8:	eb 18                	jmp    8007c2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	53                   	push   %ebx
  8007ae:	6a 20                	push   $0x20
  8007b0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b2:	83 ef 01             	sub    $0x1,%edi
  8007b5:	83 c4 10             	add    $0x10,%esp
  8007b8:	eb 08                	jmp    8007c2 <vprintfmt+0x278>
  8007ba:	89 df                	mov    %ebx,%edi
  8007bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c2:	85 ff                	test   %edi,%edi
  8007c4:	7f e4                	jg     8007aa <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c9:	e9 a2 fd ff ff       	jmp    800570 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ce:	83 fa 01             	cmp    $0x1,%edx
  8007d1:	7e 16                	jle    8007e9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8d 50 08             	lea    0x8(%eax),%edx
  8007d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dc:	8b 50 04             	mov    0x4(%eax),%edx
  8007df:	8b 00                	mov    (%eax),%eax
  8007e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e7:	eb 32                	jmp    80081b <vprintfmt+0x2d1>
	else if (lflag)
  8007e9:	85 d2                	test   %edx,%edx
  8007eb:	74 18                	je     800805 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f0:	8d 50 04             	lea    0x4(%eax),%edx
  8007f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f6:	8b 00                	mov    (%eax),%eax
  8007f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fb:	89 c1                	mov    %eax,%ecx
  8007fd:	c1 f9 1f             	sar    $0x1f,%ecx
  800800:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800803:	eb 16                	jmp    80081b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8d 50 04             	lea    0x4(%eax),%edx
  80080b:	89 55 14             	mov    %edx,0x14(%ebp)
  80080e:	8b 00                	mov    (%eax),%eax
  800810:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800813:	89 c1                	mov    %eax,%ecx
  800815:	c1 f9 1f             	sar    $0x1f,%ecx
  800818:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80081b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80081e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800821:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800826:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80082a:	79 74                	jns    8008a0 <vprintfmt+0x356>
				putch('-', putdat);
  80082c:	83 ec 08             	sub    $0x8,%esp
  80082f:	53                   	push   %ebx
  800830:	6a 2d                	push   $0x2d
  800832:	ff d6                	call   *%esi
				num = -(long long) num;
  800834:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800837:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80083a:	f7 d8                	neg    %eax
  80083c:	83 d2 00             	adc    $0x0,%edx
  80083f:	f7 da                	neg    %edx
  800841:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800844:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800849:	eb 55                	jmp    8008a0 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80084b:	8d 45 14             	lea    0x14(%ebp),%eax
  80084e:	e8 83 fc ff ff       	call   8004d6 <getuint>
			base = 10;
  800853:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800858:	eb 46                	jmp    8008a0 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80085a:	8d 45 14             	lea    0x14(%ebp),%eax
  80085d:	e8 74 fc ff ff       	call   8004d6 <getuint>
			base = 8;
  800862:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800867:	eb 37                	jmp    8008a0 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800869:	83 ec 08             	sub    $0x8,%esp
  80086c:	53                   	push   %ebx
  80086d:	6a 30                	push   $0x30
  80086f:	ff d6                	call   *%esi
			putch('x', putdat);
  800871:	83 c4 08             	add    $0x8,%esp
  800874:	53                   	push   %ebx
  800875:	6a 78                	push   $0x78
  800877:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800879:	8b 45 14             	mov    0x14(%ebp),%eax
  80087c:	8d 50 04             	lea    0x4(%eax),%edx
  80087f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800882:	8b 00                	mov    (%eax),%eax
  800884:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800889:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80088c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800891:	eb 0d                	jmp    8008a0 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800893:	8d 45 14             	lea    0x14(%ebp),%eax
  800896:	e8 3b fc ff ff       	call   8004d6 <getuint>
			base = 16;
  80089b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a0:	83 ec 0c             	sub    $0xc,%esp
  8008a3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008a7:	57                   	push   %edi
  8008a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ab:	51                   	push   %ecx
  8008ac:	52                   	push   %edx
  8008ad:	50                   	push   %eax
  8008ae:	89 da                	mov    %ebx,%edx
  8008b0:	89 f0                	mov    %esi,%eax
  8008b2:	e8 70 fb ff ff       	call   800427 <printnum>
			break;
  8008b7:	83 c4 20             	add    $0x20,%esp
  8008ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008bd:	e9 ae fc ff ff       	jmp    800570 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	53                   	push   %ebx
  8008c6:	51                   	push   %ecx
  8008c7:	ff d6                	call   *%esi
			break;
  8008c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008cf:	e9 9c fc ff ff       	jmp    800570 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	53                   	push   %ebx
  8008d8:	6a 25                	push   $0x25
  8008da:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008dc:	83 c4 10             	add    $0x10,%esp
  8008df:	eb 03                	jmp    8008e4 <vprintfmt+0x39a>
  8008e1:	83 ef 01             	sub    $0x1,%edi
  8008e4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008e8:	75 f7                	jne    8008e1 <vprintfmt+0x397>
  8008ea:	e9 81 fc ff ff       	jmp    800570 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5f                   	pop    %edi
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	83 ec 18             	sub    $0x18,%esp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800903:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800906:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80090a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80090d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800914:	85 c0                	test   %eax,%eax
  800916:	74 26                	je     80093e <vsnprintf+0x47>
  800918:	85 d2                	test   %edx,%edx
  80091a:	7e 22                	jle    80093e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80091c:	ff 75 14             	pushl  0x14(%ebp)
  80091f:	ff 75 10             	pushl  0x10(%ebp)
  800922:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800925:	50                   	push   %eax
  800926:	68 10 05 80 00       	push   $0x800510
  80092b:	e8 1a fc ff ff       	call   80054a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800930:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800933:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800936:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800939:	83 c4 10             	add    $0x10,%esp
  80093c:	eb 05                	jmp    800943 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80093e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80094b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80094e:	50                   	push   %eax
  80094f:	ff 75 10             	pushl  0x10(%ebp)
  800952:	ff 75 0c             	pushl  0xc(%ebp)
  800955:	ff 75 08             	pushl  0x8(%ebp)
  800958:	e8 9a ff ff ff       	call   8008f7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
  80096a:	eb 03                	jmp    80096f <strlen+0x10>
		n++;
  80096c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80096f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800973:	75 f7                	jne    80096c <strlen+0xd>
		n++;
	return n;
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800980:	ba 00 00 00 00       	mov    $0x0,%edx
  800985:	eb 03                	jmp    80098a <strnlen+0x13>
		n++;
  800987:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098a:	39 c2                	cmp    %eax,%edx
  80098c:	74 08                	je     800996 <strnlen+0x1f>
  80098e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800992:	75 f3                	jne    800987 <strnlen+0x10>
  800994:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	53                   	push   %ebx
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a2:	89 c2                	mov    %eax,%edx
  8009a4:	83 c2 01             	add    $0x1,%edx
  8009a7:	83 c1 01             	add    $0x1,%ecx
  8009aa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009ae:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009b1:	84 db                	test   %bl,%bl
  8009b3:	75 ef                	jne    8009a4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009b5:	5b                   	pop    %ebx
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009bf:	53                   	push   %ebx
  8009c0:	e8 9a ff ff ff       	call   80095f <strlen>
  8009c5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009c8:	ff 75 0c             	pushl  0xc(%ebp)
  8009cb:	01 d8                	add    %ebx,%eax
  8009cd:	50                   	push   %eax
  8009ce:	e8 c5 ff ff ff       	call   800998 <strcpy>
	return dst;
}
  8009d3:	89 d8                	mov    %ebx,%eax
  8009d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d8:	c9                   	leave  
  8009d9:	c3                   	ret    

008009da <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e5:	89 f3                	mov    %esi,%ebx
  8009e7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ea:	89 f2                	mov    %esi,%edx
  8009ec:	eb 0f                	jmp    8009fd <strncpy+0x23>
		*dst++ = *src;
  8009ee:	83 c2 01             	add    $0x1,%edx
  8009f1:	0f b6 01             	movzbl (%ecx),%eax
  8009f4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009f7:	80 39 01             	cmpb   $0x1,(%ecx)
  8009fa:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009fd:	39 da                	cmp    %ebx,%edx
  8009ff:	75 ed                	jne    8009ee <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a01:	89 f0                	mov    %esi,%eax
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a12:	8b 55 10             	mov    0x10(%ebp),%edx
  800a15:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a17:	85 d2                	test   %edx,%edx
  800a19:	74 21                	je     800a3c <strlcpy+0x35>
  800a1b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a1f:	89 f2                	mov    %esi,%edx
  800a21:	eb 09                	jmp    800a2c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a23:	83 c2 01             	add    $0x1,%edx
  800a26:	83 c1 01             	add    $0x1,%ecx
  800a29:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a2c:	39 c2                	cmp    %eax,%edx
  800a2e:	74 09                	je     800a39 <strlcpy+0x32>
  800a30:	0f b6 19             	movzbl (%ecx),%ebx
  800a33:	84 db                	test   %bl,%bl
  800a35:	75 ec                	jne    800a23 <strlcpy+0x1c>
  800a37:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a39:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a3c:	29 f0                	sub    %esi,%eax
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a48:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a4b:	eb 06                	jmp    800a53 <strcmp+0x11>
		p++, q++;
  800a4d:	83 c1 01             	add    $0x1,%ecx
  800a50:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a53:	0f b6 01             	movzbl (%ecx),%eax
  800a56:	84 c0                	test   %al,%al
  800a58:	74 04                	je     800a5e <strcmp+0x1c>
  800a5a:	3a 02                	cmp    (%edx),%al
  800a5c:	74 ef                	je     800a4d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a5e:	0f b6 c0             	movzbl %al,%eax
  800a61:	0f b6 12             	movzbl (%edx),%edx
  800a64:	29 d0                	sub    %edx,%eax
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	53                   	push   %ebx
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a72:	89 c3                	mov    %eax,%ebx
  800a74:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a77:	eb 06                	jmp    800a7f <strncmp+0x17>
		n--, p++, q++;
  800a79:	83 c0 01             	add    $0x1,%eax
  800a7c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a7f:	39 d8                	cmp    %ebx,%eax
  800a81:	74 15                	je     800a98 <strncmp+0x30>
  800a83:	0f b6 08             	movzbl (%eax),%ecx
  800a86:	84 c9                	test   %cl,%cl
  800a88:	74 04                	je     800a8e <strncmp+0x26>
  800a8a:	3a 0a                	cmp    (%edx),%cl
  800a8c:	74 eb                	je     800a79 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8e:	0f b6 00             	movzbl (%eax),%eax
  800a91:	0f b6 12             	movzbl (%edx),%edx
  800a94:	29 d0                	sub    %edx,%eax
  800a96:	eb 05                	jmp    800a9d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aaa:	eb 07                	jmp    800ab3 <strchr+0x13>
		if (*s == c)
  800aac:	38 ca                	cmp    %cl,%dl
  800aae:	74 0f                	je     800abf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ab0:	83 c0 01             	add    $0x1,%eax
  800ab3:	0f b6 10             	movzbl (%eax),%edx
  800ab6:	84 d2                	test   %dl,%dl
  800ab8:	75 f2                	jne    800aac <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800acb:	eb 03                	jmp    800ad0 <strfind+0xf>
  800acd:	83 c0 01             	add    $0x1,%eax
  800ad0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ad3:	38 ca                	cmp    %cl,%dl
  800ad5:	74 04                	je     800adb <strfind+0x1a>
  800ad7:	84 d2                	test   %dl,%dl
  800ad9:	75 f2                	jne    800acd <strfind+0xc>
			break;
	return (char *) s;
}
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
  800ae3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ae9:	85 c9                	test   %ecx,%ecx
  800aeb:	74 36                	je     800b23 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af3:	75 28                	jne    800b1d <memset+0x40>
  800af5:	f6 c1 03             	test   $0x3,%cl
  800af8:	75 23                	jne    800b1d <memset+0x40>
		c &= 0xFF;
  800afa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800afe:	89 d3                	mov    %edx,%ebx
  800b00:	c1 e3 08             	shl    $0x8,%ebx
  800b03:	89 d6                	mov    %edx,%esi
  800b05:	c1 e6 18             	shl    $0x18,%esi
  800b08:	89 d0                	mov    %edx,%eax
  800b0a:	c1 e0 10             	shl    $0x10,%eax
  800b0d:	09 f0                	or     %esi,%eax
  800b0f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b11:	89 d8                	mov    %ebx,%eax
  800b13:	09 d0                	or     %edx,%eax
  800b15:	c1 e9 02             	shr    $0x2,%ecx
  800b18:	fc                   	cld    
  800b19:	f3 ab                	rep stos %eax,%es:(%edi)
  800b1b:	eb 06                	jmp    800b23 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b20:	fc                   	cld    
  800b21:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b23:	89 f8                	mov    %edi,%eax
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b38:	39 c6                	cmp    %eax,%esi
  800b3a:	73 35                	jae    800b71 <memmove+0x47>
  800b3c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b3f:	39 d0                	cmp    %edx,%eax
  800b41:	73 2e                	jae    800b71 <memmove+0x47>
		s += n;
		d += n;
  800b43:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b46:	89 d6                	mov    %edx,%esi
  800b48:	09 fe                	or     %edi,%esi
  800b4a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b50:	75 13                	jne    800b65 <memmove+0x3b>
  800b52:	f6 c1 03             	test   $0x3,%cl
  800b55:	75 0e                	jne    800b65 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b57:	83 ef 04             	sub    $0x4,%edi
  800b5a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b5d:	c1 e9 02             	shr    $0x2,%ecx
  800b60:	fd                   	std    
  800b61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b63:	eb 09                	jmp    800b6e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b65:	83 ef 01             	sub    $0x1,%edi
  800b68:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b6b:	fd                   	std    
  800b6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b6e:	fc                   	cld    
  800b6f:	eb 1d                	jmp    800b8e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b71:	89 f2                	mov    %esi,%edx
  800b73:	09 c2                	or     %eax,%edx
  800b75:	f6 c2 03             	test   $0x3,%dl
  800b78:	75 0f                	jne    800b89 <memmove+0x5f>
  800b7a:	f6 c1 03             	test   $0x3,%cl
  800b7d:	75 0a                	jne    800b89 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b7f:	c1 e9 02             	shr    $0x2,%ecx
  800b82:	89 c7                	mov    %eax,%edi
  800b84:	fc                   	cld    
  800b85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b87:	eb 05                	jmp    800b8e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b89:	89 c7                	mov    %eax,%edi
  800b8b:	fc                   	cld    
  800b8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b95:	ff 75 10             	pushl  0x10(%ebp)
  800b98:	ff 75 0c             	pushl  0xc(%ebp)
  800b9b:	ff 75 08             	pushl  0x8(%ebp)
  800b9e:	e8 87 ff ff ff       	call   800b2a <memmove>
}
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb0:	89 c6                	mov    %eax,%esi
  800bb2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb5:	eb 1a                	jmp    800bd1 <memcmp+0x2c>
		if (*s1 != *s2)
  800bb7:	0f b6 08             	movzbl (%eax),%ecx
  800bba:	0f b6 1a             	movzbl (%edx),%ebx
  800bbd:	38 d9                	cmp    %bl,%cl
  800bbf:	74 0a                	je     800bcb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bc1:	0f b6 c1             	movzbl %cl,%eax
  800bc4:	0f b6 db             	movzbl %bl,%ebx
  800bc7:	29 d8                	sub    %ebx,%eax
  800bc9:	eb 0f                	jmp    800bda <memcmp+0x35>
		s1++, s2++;
  800bcb:	83 c0 01             	add    $0x1,%eax
  800bce:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd1:	39 f0                	cmp    %esi,%eax
  800bd3:	75 e2                	jne    800bb7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	53                   	push   %ebx
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800be5:	89 c1                	mov    %eax,%ecx
  800be7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bea:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bee:	eb 0a                	jmp    800bfa <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf0:	0f b6 10             	movzbl (%eax),%edx
  800bf3:	39 da                	cmp    %ebx,%edx
  800bf5:	74 07                	je     800bfe <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf7:	83 c0 01             	add    $0x1,%eax
  800bfa:	39 c8                	cmp    %ecx,%eax
  800bfc:	72 f2                	jb     800bf0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0d:	eb 03                	jmp    800c12 <strtol+0x11>
		s++;
  800c0f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c12:	0f b6 01             	movzbl (%ecx),%eax
  800c15:	3c 20                	cmp    $0x20,%al
  800c17:	74 f6                	je     800c0f <strtol+0xe>
  800c19:	3c 09                	cmp    $0x9,%al
  800c1b:	74 f2                	je     800c0f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c1d:	3c 2b                	cmp    $0x2b,%al
  800c1f:	75 0a                	jne    800c2b <strtol+0x2a>
		s++;
  800c21:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c24:	bf 00 00 00 00       	mov    $0x0,%edi
  800c29:	eb 11                	jmp    800c3c <strtol+0x3b>
  800c2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c30:	3c 2d                	cmp    $0x2d,%al
  800c32:	75 08                	jne    800c3c <strtol+0x3b>
		s++, neg = 1;
  800c34:	83 c1 01             	add    $0x1,%ecx
  800c37:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c3c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c42:	75 15                	jne    800c59 <strtol+0x58>
  800c44:	80 39 30             	cmpb   $0x30,(%ecx)
  800c47:	75 10                	jne    800c59 <strtol+0x58>
  800c49:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c4d:	75 7c                	jne    800ccb <strtol+0xca>
		s += 2, base = 16;
  800c4f:	83 c1 02             	add    $0x2,%ecx
  800c52:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c57:	eb 16                	jmp    800c6f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c59:	85 db                	test   %ebx,%ebx
  800c5b:	75 12                	jne    800c6f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c5d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c62:	80 39 30             	cmpb   $0x30,(%ecx)
  800c65:	75 08                	jne    800c6f <strtol+0x6e>
		s++, base = 8;
  800c67:	83 c1 01             	add    $0x1,%ecx
  800c6a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c74:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c77:	0f b6 11             	movzbl (%ecx),%edx
  800c7a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c7d:	89 f3                	mov    %esi,%ebx
  800c7f:	80 fb 09             	cmp    $0x9,%bl
  800c82:	77 08                	ja     800c8c <strtol+0x8b>
			dig = *s - '0';
  800c84:	0f be d2             	movsbl %dl,%edx
  800c87:	83 ea 30             	sub    $0x30,%edx
  800c8a:	eb 22                	jmp    800cae <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c8c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c8f:	89 f3                	mov    %esi,%ebx
  800c91:	80 fb 19             	cmp    $0x19,%bl
  800c94:	77 08                	ja     800c9e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c96:	0f be d2             	movsbl %dl,%edx
  800c99:	83 ea 57             	sub    $0x57,%edx
  800c9c:	eb 10                	jmp    800cae <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c9e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ca1:	89 f3                	mov    %esi,%ebx
  800ca3:	80 fb 19             	cmp    $0x19,%bl
  800ca6:	77 16                	ja     800cbe <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ca8:	0f be d2             	movsbl %dl,%edx
  800cab:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cae:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cb1:	7d 0b                	jge    800cbe <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cb3:	83 c1 01             	add    $0x1,%ecx
  800cb6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cba:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cbc:	eb b9                	jmp    800c77 <strtol+0x76>

	if (endptr)
  800cbe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc2:	74 0d                	je     800cd1 <strtol+0xd0>
		*endptr = (char *) s;
  800cc4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cc7:	89 0e                	mov    %ecx,(%esi)
  800cc9:	eb 06                	jmp    800cd1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ccb:	85 db                	test   %ebx,%ebx
  800ccd:	74 98                	je     800c67 <strtol+0x66>
  800ccf:	eb 9e                	jmp    800c6f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cd1:	89 c2                	mov    %eax,%edx
  800cd3:	f7 da                	neg    %edx
  800cd5:	85 ff                	test   %edi,%edi
  800cd7:	0f 45 c2             	cmovne %edx,%eax
}
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800ce5:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cec:	75 2e                	jne    800d1c <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800cee:	e8 37 f4 ff ff       	call   80012a <sys_getenvid>
  800cf3:	83 ec 04             	sub    $0x4,%esp
  800cf6:	68 07 0e 00 00       	push   $0xe07
  800cfb:	68 00 f0 bf ee       	push   $0xeebff000
  800d00:	50                   	push   %eax
  800d01:	e8 62 f4 ff ff       	call   800168 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800d06:	e8 1f f4 ff ff       	call   80012a <sys_getenvid>
  800d0b:	83 c4 08             	add    $0x8,%esp
  800d0e:	68 17 03 80 00       	push   $0x800317
  800d13:	50                   	push   %eax
  800d14:	e8 58 f5 ff ff       	call   800271 <sys_env_set_pgfault_upcall>
  800d19:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1f:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d24:	c9                   	leave  
  800d25:	c3                   	ret    
  800d26:	66 90                	xchg   %ax,%ax
  800d28:	66 90                	xchg   %ax,%ax
  800d2a:	66 90                	xchg   %ax,%ax
  800d2c:	66 90                	xchg   %ax,%ax
  800d2e:	66 90                	xchg   %ax,%ax

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
