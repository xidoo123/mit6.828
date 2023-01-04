
obj/user/faultnostack.debug:     file format elf32-i386


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
  800039:	68 61 03 80 00       	push   $0x800361
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
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
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

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
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 ab 04 00 00       	call   800550 <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 0a 1e 80 00       	push   $0x801e0a
  80011e:	6a 23                	push   $0x23
  800120:	68 27 1e 80 00       	push   $0x801e27
  800125:	e8 19 0f 00 00       	call   801043 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 0a 1e 80 00       	push   $0x801e0a
  80019f:	6a 23                	push   $0x23
  8001a1:	68 27 1e 80 00       	push   $0x801e27
  8001a6:	e8 98 0e 00 00       	call   801043 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 0a 1e 80 00       	push   $0x801e0a
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 27 1e 80 00       	push   $0x801e27
  8001e8:	e8 56 0e 00 00       	call   801043 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 0a 1e 80 00       	push   $0x801e0a
  800223:	6a 23                	push   $0x23
  800225:	68 27 1e 80 00       	push   $0x801e27
  80022a:	e8 14 0e 00 00       	call   801043 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 0a 1e 80 00       	push   $0x801e0a
  800265:	6a 23                	push   $0x23
  800267:	68 27 1e 80 00       	push   $0x801e27
  80026c:	e8 d2 0d 00 00       	call   801043 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 0a 1e 80 00       	push   $0x801e0a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 27 1e 80 00       	push   $0x801e27
  8002ae:	e8 90 0d 00 00       	call   801043 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0a                	push   $0xa
  8002e4:	68 0a 1e 80 00       	push   $0x801e0a
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 27 1e 80 00       	push   $0x801e27
  8002f0:	e8 4e 0d 00 00       	call   801043 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 0a 1e 80 00       	push   $0x801e0a
  80034d:	6a 23                	push   $0x23
  80034f:	68 27 1e 80 00       	push   $0x801e27
  800354:	e8 ea 0c 00 00       	call   801043 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800361:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800362:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800367:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800369:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80036c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  800370:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  800374:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  800377:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80037a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80037b:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80037e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80037f:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  800380:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800384:	c3                   	ret    

00800385 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
  80038b:	05 00 00 00 30       	add    $0x30000000,%eax
  800390:	c1 e8 0c             	shr    $0xc,%eax
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
  80039b:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003a5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003b7:	89 c2                	mov    %eax,%edx
  8003b9:	c1 ea 16             	shr    $0x16,%edx
  8003bc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003c3:	f6 c2 01             	test   $0x1,%dl
  8003c6:	74 11                	je     8003d9 <fd_alloc+0x2d>
  8003c8:	89 c2                	mov    %eax,%edx
  8003ca:	c1 ea 0c             	shr    $0xc,%edx
  8003cd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003d4:	f6 c2 01             	test   $0x1,%dl
  8003d7:	75 09                	jne    8003e2 <fd_alloc+0x36>
			*fd_store = fd;
  8003d9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003db:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e0:	eb 17                	jmp    8003f9 <fd_alloc+0x4d>
  8003e2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ec:	75 c9                	jne    8003b7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ee:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003f4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800401:	83 f8 1f             	cmp    $0x1f,%eax
  800404:	77 36                	ja     80043c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800406:	c1 e0 0c             	shl    $0xc,%eax
  800409:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80040e:	89 c2                	mov    %eax,%edx
  800410:	c1 ea 16             	shr    $0x16,%edx
  800413:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041a:	f6 c2 01             	test   $0x1,%dl
  80041d:	74 24                	je     800443 <fd_lookup+0x48>
  80041f:	89 c2                	mov    %eax,%edx
  800421:	c1 ea 0c             	shr    $0xc,%edx
  800424:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042b:	f6 c2 01             	test   $0x1,%dl
  80042e:	74 1a                	je     80044a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800430:	8b 55 0c             	mov    0xc(%ebp),%edx
  800433:	89 02                	mov    %eax,(%edx)
	return 0;
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
  80043a:	eb 13                	jmp    80044f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800441:	eb 0c                	jmp    80044f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800443:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800448:	eb 05                	jmp    80044f <fd_lookup+0x54>
  80044a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    

00800451 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045a:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80045f:	eb 13                	jmp    800474 <dev_lookup+0x23>
  800461:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800464:	39 08                	cmp    %ecx,(%eax)
  800466:	75 0c                	jne    800474 <dev_lookup+0x23>
			*dev = devtab[i];
  800468:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	eb 2e                	jmp    8004a2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800474:	8b 02                	mov    (%edx),%eax
  800476:	85 c0                	test   %eax,%eax
  800478:	75 e7                	jne    800461 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80047a:	a1 04 40 80 00       	mov    0x804004,%eax
  80047f:	8b 40 48             	mov    0x48(%eax),%eax
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	51                   	push   %ecx
  800486:	50                   	push   %eax
  800487:	68 38 1e 80 00       	push   $0x801e38
  80048c:	e8 8b 0c 00 00       	call   80111c <cprintf>
	*dev = 0;
  800491:	8b 45 0c             	mov    0xc(%ebp),%eax
  800494:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004a2:	c9                   	leave  
  8004a3:	c3                   	ret    

008004a4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	56                   	push   %esi
  8004a8:	53                   	push   %ebx
  8004a9:	83 ec 10             	sub    $0x10,%esp
  8004ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004bc:	c1 e8 0c             	shr    $0xc,%eax
  8004bf:	50                   	push   %eax
  8004c0:	e8 36 ff ff ff       	call   8003fb <fd_lookup>
  8004c5:	83 c4 08             	add    $0x8,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	78 05                	js     8004d1 <fd_close+0x2d>
	    || fd != fd2)
  8004cc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004cf:	74 0c                	je     8004dd <fd_close+0x39>
		return (must_exist ? r : 0);
  8004d1:	84 db                	test   %bl,%bl
  8004d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d8:	0f 44 c2             	cmove  %edx,%eax
  8004db:	eb 41                	jmp    80051e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004e3:	50                   	push   %eax
  8004e4:	ff 36                	pushl  (%esi)
  8004e6:	e8 66 ff ff ff       	call   800451 <dev_lookup>
  8004eb:	89 c3                	mov    %eax,%ebx
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	78 1a                	js     80050e <fd_close+0x6a>
		if (dev->dev_close)
  8004f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004f7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004fa:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ff:	85 c0                	test   %eax,%eax
  800501:	74 0b                	je     80050e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800503:	83 ec 0c             	sub    $0xc,%esp
  800506:	56                   	push   %esi
  800507:	ff d0                	call   *%eax
  800509:	89 c3                	mov    %eax,%ebx
  80050b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	56                   	push   %esi
  800512:	6a 00                	push   $0x0
  800514:	e8 dc fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	89 d8                	mov    %ebx,%eax
}
  80051e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800521:	5b                   	pop    %ebx
  800522:	5e                   	pop    %esi
  800523:	5d                   	pop    %ebp
  800524:	c3                   	ret    

00800525 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80052b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80052e:	50                   	push   %eax
  80052f:	ff 75 08             	pushl  0x8(%ebp)
  800532:	e8 c4 fe ff ff       	call   8003fb <fd_lookup>
  800537:	83 c4 08             	add    $0x8,%esp
  80053a:	85 c0                	test   %eax,%eax
  80053c:	78 10                	js     80054e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	6a 01                	push   $0x1
  800543:	ff 75 f4             	pushl  -0xc(%ebp)
  800546:	e8 59 ff ff ff       	call   8004a4 <fd_close>
  80054b:	83 c4 10             	add    $0x10,%esp
}
  80054e:	c9                   	leave  
  80054f:	c3                   	ret    

00800550 <close_all>:

void
close_all(void)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	53                   	push   %ebx
  800554:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800557:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80055c:	83 ec 0c             	sub    $0xc,%esp
  80055f:	53                   	push   %ebx
  800560:	e8 c0 ff ff ff       	call   800525 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800565:	83 c3 01             	add    $0x1,%ebx
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	83 fb 20             	cmp    $0x20,%ebx
  80056e:	75 ec                	jne    80055c <close_all+0xc>
		close(i);
}
  800570:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800573:	c9                   	leave  
  800574:	c3                   	ret    

00800575 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	57                   	push   %edi
  800579:	56                   	push   %esi
  80057a:	53                   	push   %ebx
  80057b:	83 ec 2c             	sub    $0x2c,%esp
  80057e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800581:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800584:	50                   	push   %eax
  800585:	ff 75 08             	pushl  0x8(%ebp)
  800588:	e8 6e fe ff ff       	call   8003fb <fd_lookup>
  80058d:	83 c4 08             	add    $0x8,%esp
  800590:	85 c0                	test   %eax,%eax
  800592:	0f 88 c1 00 00 00    	js     800659 <dup+0xe4>
		return r;
	close(newfdnum);
  800598:	83 ec 0c             	sub    $0xc,%esp
  80059b:	56                   	push   %esi
  80059c:	e8 84 ff ff ff       	call   800525 <close>

	newfd = INDEX2FD(newfdnum);
  8005a1:	89 f3                	mov    %esi,%ebx
  8005a3:	c1 e3 0c             	shl    $0xc,%ebx
  8005a6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ac:	83 c4 04             	add    $0x4,%esp
  8005af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b2:	e8 de fd ff ff       	call   800395 <fd2data>
  8005b7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005b9:	89 1c 24             	mov    %ebx,(%esp)
  8005bc:	e8 d4 fd ff ff       	call   800395 <fd2data>
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005c7:	89 f8                	mov    %edi,%eax
  8005c9:	c1 e8 16             	shr    $0x16,%eax
  8005cc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005d3:	a8 01                	test   $0x1,%al
  8005d5:	74 37                	je     80060e <dup+0x99>
  8005d7:	89 f8                	mov    %edi,%eax
  8005d9:	c1 e8 0c             	shr    $0xc,%eax
  8005dc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005e3:	f6 c2 01             	test   $0x1,%dl
  8005e6:	74 26                	je     80060e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005fb:	6a 00                	push   $0x0
  8005fd:	57                   	push   %edi
  8005fe:	6a 00                	push   $0x0
  800600:	e8 ae fb ff ff       	call   8001b3 <sys_page_map>
  800605:	89 c7                	mov    %eax,%edi
  800607:	83 c4 20             	add    $0x20,%esp
  80060a:	85 c0                	test   %eax,%eax
  80060c:	78 2e                	js     80063c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800611:	89 d0                	mov    %edx,%eax
  800613:	c1 e8 0c             	shr    $0xc,%eax
  800616:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061d:	83 ec 0c             	sub    $0xc,%esp
  800620:	25 07 0e 00 00       	and    $0xe07,%eax
  800625:	50                   	push   %eax
  800626:	53                   	push   %ebx
  800627:	6a 00                	push   $0x0
  800629:	52                   	push   %edx
  80062a:	6a 00                	push   $0x0
  80062c:	e8 82 fb ff ff       	call   8001b3 <sys_page_map>
  800631:	89 c7                	mov    %eax,%edi
  800633:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800636:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800638:	85 ff                	test   %edi,%edi
  80063a:	79 1d                	jns    800659 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 00                	push   $0x0
  800642:	e8 ae fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064d:	6a 00                	push   $0x0
  80064f:	e8 a1 fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	89 f8                	mov    %edi,%eax
}
  800659:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065c:	5b                   	pop    %ebx
  80065d:	5e                   	pop    %esi
  80065e:	5f                   	pop    %edi
  80065f:	5d                   	pop    %ebp
  800660:	c3                   	ret    

00800661 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800661:	55                   	push   %ebp
  800662:	89 e5                	mov    %esp,%ebp
  800664:	53                   	push   %ebx
  800665:	83 ec 14             	sub    $0x14,%esp
  800668:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80066b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80066e:	50                   	push   %eax
  80066f:	53                   	push   %ebx
  800670:	e8 86 fd ff ff       	call   8003fb <fd_lookup>
  800675:	83 c4 08             	add    $0x8,%esp
  800678:	89 c2                	mov    %eax,%edx
  80067a:	85 c0                	test   %eax,%eax
  80067c:	78 6d                	js     8006eb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800684:	50                   	push   %eax
  800685:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800688:	ff 30                	pushl  (%eax)
  80068a:	e8 c2 fd ff ff       	call   800451 <dev_lookup>
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	85 c0                	test   %eax,%eax
  800694:	78 4c                	js     8006e2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800696:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800699:	8b 42 08             	mov    0x8(%edx),%eax
  80069c:	83 e0 03             	and    $0x3,%eax
  80069f:	83 f8 01             	cmp    $0x1,%eax
  8006a2:	75 21                	jne    8006c5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8006a9:	8b 40 48             	mov    0x48(%eax),%eax
  8006ac:	83 ec 04             	sub    $0x4,%esp
  8006af:	53                   	push   %ebx
  8006b0:	50                   	push   %eax
  8006b1:	68 79 1e 80 00       	push   $0x801e79
  8006b6:	e8 61 0a 00 00       	call   80111c <cprintf>
		return -E_INVAL;
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006c3:	eb 26                	jmp    8006eb <read+0x8a>
	}
	if (!dev->dev_read)
  8006c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c8:	8b 40 08             	mov    0x8(%eax),%eax
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	74 17                	je     8006e6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006cf:	83 ec 04             	sub    $0x4,%esp
  8006d2:	ff 75 10             	pushl  0x10(%ebp)
  8006d5:	ff 75 0c             	pushl  0xc(%ebp)
  8006d8:	52                   	push   %edx
  8006d9:	ff d0                	call   *%eax
  8006db:	89 c2                	mov    %eax,%edx
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb 09                	jmp    8006eb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e2:	89 c2                	mov    %eax,%edx
  8006e4:	eb 05                	jmp    8006eb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006eb:	89 d0                	mov    %edx,%eax
  8006ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	57                   	push   %edi
  8006f6:	56                   	push   %esi
  8006f7:	53                   	push   %ebx
  8006f8:	83 ec 0c             	sub    $0xc,%esp
  8006fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006fe:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800701:	bb 00 00 00 00       	mov    $0x0,%ebx
  800706:	eb 21                	jmp    800729 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800708:	83 ec 04             	sub    $0x4,%esp
  80070b:	89 f0                	mov    %esi,%eax
  80070d:	29 d8                	sub    %ebx,%eax
  80070f:	50                   	push   %eax
  800710:	89 d8                	mov    %ebx,%eax
  800712:	03 45 0c             	add    0xc(%ebp),%eax
  800715:	50                   	push   %eax
  800716:	57                   	push   %edi
  800717:	e8 45 ff ff ff       	call   800661 <read>
		if (m < 0)
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	85 c0                	test   %eax,%eax
  800721:	78 10                	js     800733 <readn+0x41>
			return m;
		if (m == 0)
  800723:	85 c0                	test   %eax,%eax
  800725:	74 0a                	je     800731 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800727:	01 c3                	add    %eax,%ebx
  800729:	39 f3                	cmp    %esi,%ebx
  80072b:	72 db                	jb     800708 <readn+0x16>
  80072d:	89 d8                	mov    %ebx,%eax
  80072f:	eb 02                	jmp    800733 <readn+0x41>
  800731:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800733:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800736:	5b                   	pop    %ebx
  800737:	5e                   	pop    %esi
  800738:	5f                   	pop    %edi
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	83 ec 14             	sub    $0x14,%esp
  800742:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800745:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	53                   	push   %ebx
  80074a:	e8 ac fc ff ff       	call   8003fb <fd_lookup>
  80074f:	83 c4 08             	add    $0x8,%esp
  800752:	89 c2                	mov    %eax,%edx
  800754:	85 c0                	test   %eax,%eax
  800756:	78 68                	js     8007c0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80075e:	50                   	push   %eax
  80075f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800762:	ff 30                	pushl  (%eax)
  800764:	e8 e8 fc ff ff       	call   800451 <dev_lookup>
  800769:	83 c4 10             	add    $0x10,%esp
  80076c:	85 c0                	test   %eax,%eax
  80076e:	78 47                	js     8007b7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800770:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800773:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800777:	75 21                	jne    80079a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800779:	a1 04 40 80 00       	mov    0x804004,%eax
  80077e:	8b 40 48             	mov    0x48(%eax),%eax
  800781:	83 ec 04             	sub    $0x4,%esp
  800784:	53                   	push   %ebx
  800785:	50                   	push   %eax
  800786:	68 95 1e 80 00       	push   $0x801e95
  80078b:	e8 8c 09 00 00       	call   80111c <cprintf>
		return -E_INVAL;
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800798:	eb 26                	jmp    8007c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80079a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80079d:	8b 52 0c             	mov    0xc(%edx),%edx
  8007a0:	85 d2                	test   %edx,%edx
  8007a2:	74 17                	je     8007bb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007a4:	83 ec 04             	sub    $0x4,%esp
  8007a7:	ff 75 10             	pushl  0x10(%ebp)
  8007aa:	ff 75 0c             	pushl  0xc(%ebp)
  8007ad:	50                   	push   %eax
  8007ae:	ff d2                	call   *%edx
  8007b0:	89 c2                	mov    %eax,%edx
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	eb 09                	jmp    8007c0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b7:	89 c2                	mov    %eax,%edx
  8007b9:	eb 05                	jmp    8007c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007c0:	89 d0                	mov    %edx,%eax
  8007c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007cd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	ff 75 08             	pushl  0x8(%ebp)
  8007d4:	e8 22 fc ff ff       	call   8003fb <fd_lookup>
  8007d9:	83 c4 08             	add    $0x8,%esp
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	78 0e                	js     8007ee <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	83 ec 14             	sub    $0x14,%esp
  8007f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007fd:	50                   	push   %eax
  8007fe:	53                   	push   %ebx
  8007ff:	e8 f7 fb ff ff       	call   8003fb <fd_lookup>
  800804:	83 c4 08             	add    $0x8,%esp
  800807:	89 c2                	mov    %eax,%edx
  800809:	85 c0                	test   %eax,%eax
  80080b:	78 65                	js     800872 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800813:	50                   	push   %eax
  800814:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800817:	ff 30                	pushl  (%eax)
  800819:	e8 33 fc ff ff       	call   800451 <dev_lookup>
  80081e:	83 c4 10             	add    $0x10,%esp
  800821:	85 c0                	test   %eax,%eax
  800823:	78 44                	js     800869 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800828:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082c:	75 21                	jne    80084f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80082e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800833:	8b 40 48             	mov    0x48(%eax),%eax
  800836:	83 ec 04             	sub    $0x4,%esp
  800839:	53                   	push   %ebx
  80083a:	50                   	push   %eax
  80083b:	68 58 1e 80 00       	push   $0x801e58
  800840:	e8 d7 08 00 00       	call   80111c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80084d:	eb 23                	jmp    800872 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80084f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800852:	8b 52 18             	mov    0x18(%edx),%edx
  800855:	85 d2                	test   %edx,%edx
  800857:	74 14                	je     80086d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	50                   	push   %eax
  800860:	ff d2                	call   *%edx
  800862:	89 c2                	mov    %eax,%edx
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	eb 09                	jmp    800872 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800869:	89 c2                	mov    %eax,%edx
  80086b:	eb 05                	jmp    800872 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80086d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800872:	89 d0                	mov    %edx,%eax
  800874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	83 ec 14             	sub    $0x14,%esp
  800880:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800883:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	ff 75 08             	pushl  0x8(%ebp)
  80088a:	e8 6c fb ff ff       	call   8003fb <fd_lookup>
  80088f:	83 c4 08             	add    $0x8,%esp
  800892:	89 c2                	mov    %eax,%edx
  800894:	85 c0                	test   %eax,%eax
  800896:	78 58                	js     8008f0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089e:	50                   	push   %eax
  80089f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a2:	ff 30                	pushl  (%eax)
  8008a4:	e8 a8 fb ff ff       	call   800451 <dev_lookup>
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	78 37                	js     8008e7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b7:	74 32                	je     8008eb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008b9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008bc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c3:	00 00 00 
	stat->st_isdir = 0;
  8008c6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008cd:	00 00 00 
	stat->st_dev = dev;
  8008d0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	53                   	push   %ebx
  8008da:	ff 75 f0             	pushl  -0x10(%ebp)
  8008dd:	ff 50 14             	call   *0x14(%eax)
  8008e0:	89 c2                	mov    %eax,%edx
  8008e2:	83 c4 10             	add    $0x10,%esp
  8008e5:	eb 09                	jmp    8008f0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e7:	89 c2                	mov    %eax,%edx
  8008e9:	eb 05                	jmp    8008f0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	6a 00                	push   $0x0
  800901:	ff 75 08             	pushl  0x8(%ebp)
  800904:	e8 b7 01 00 00       	call   800ac0 <open>
  800909:	89 c3                	mov    %eax,%ebx
  80090b:	83 c4 10             	add    $0x10,%esp
  80090e:	85 c0                	test   %eax,%eax
  800910:	78 1b                	js     80092d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800912:	83 ec 08             	sub    $0x8,%esp
  800915:	ff 75 0c             	pushl  0xc(%ebp)
  800918:	50                   	push   %eax
  800919:	e8 5b ff ff ff       	call   800879 <fstat>
  80091e:	89 c6                	mov    %eax,%esi
	close(fd);
  800920:	89 1c 24             	mov    %ebx,(%esp)
  800923:	e8 fd fb ff ff       	call   800525 <close>
	return r;
  800928:	83 c4 10             	add    $0x10,%esp
  80092b:	89 f0                	mov    %esi,%eax
}
  80092d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	89 c6                	mov    %eax,%esi
  80093b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800944:	75 12                	jne    800958 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800946:	83 ec 0c             	sub    $0xc,%esp
  800949:	6a 01                	push   $0x1
  80094b:	e8 9a 11 00 00       	call   801aea <ipc_find_env>
  800950:	a3 00 40 80 00       	mov    %eax,0x804000
  800955:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800958:	6a 07                	push   $0x7
  80095a:	68 00 50 80 00       	push   $0x805000
  80095f:	56                   	push   %esi
  800960:	ff 35 00 40 80 00    	pushl  0x804000
  800966:	e8 2b 11 00 00       	call   801a96 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80096b:	83 c4 0c             	add    $0xc,%esp
  80096e:	6a 00                	push   $0x0
  800970:	53                   	push   %ebx
  800971:	6a 00                	push   $0x0
  800973:	e8 b7 10 00 00       	call   801a2f <ipc_recv>
}
  800978:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800990:	8b 45 0c             	mov    0xc(%ebp),%eax
  800993:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800998:	ba 00 00 00 00       	mov    $0x0,%edx
  80099d:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a2:	e8 8d ff ff ff       	call   800934 <fsipc>
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c4:	e8 6b ff ff ff       	call   800934 <fsipc>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	83 ec 04             	sub    $0x4,%esp
  8009d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009db:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ea:	e8 45 ff ff ff       	call   800934 <fsipc>
  8009ef:	85 c0                	test   %eax,%eax
  8009f1:	78 2c                	js     800a1f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f3:	83 ec 08             	sub    $0x8,%esp
  8009f6:	68 00 50 80 00       	push   $0x805000
  8009fb:	53                   	push   %ebx
  8009fc:	e8 a0 0c 00 00       	call   8016a1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a01:	a1 80 50 80 00       	mov    0x805080,%eax
  800a06:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0c:	a1 84 50 80 00       	mov    0x805084,%eax
  800a11:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a17:	83 c4 10             	add    $0x10,%esp
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800a2a:	68 c4 1e 80 00       	push   $0x801ec4
  800a2f:	68 90 00 00 00       	push   $0x90
  800a34:	68 e2 1e 80 00       	push   $0x801ee2
  800a39:	e8 05 06 00 00       	call   801043 <_panic>

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
  800a61:	e8 ce fe ff ff       	call   800934 <fsipc>
  800a66:	89 c3                	mov    %eax,%ebx
  800a68:	85 c0                	test   %eax,%eax
  800a6a:	78 4b                	js     800ab7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a6c:	39 c6                	cmp    %eax,%esi
  800a6e:	73 16                	jae    800a86 <devfile_read+0x48>
  800a70:	68 ed 1e 80 00       	push   $0x801eed
  800a75:	68 f4 1e 80 00       	push   $0x801ef4
  800a7a:	6a 7c                	push   $0x7c
  800a7c:	68 e2 1e 80 00       	push   $0x801ee2
  800a81:	e8 bd 05 00 00       	call   801043 <_panic>
	assert(r <= PGSIZE);
  800a86:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a8b:	7e 16                	jle    800aa3 <devfile_read+0x65>
  800a8d:	68 09 1f 80 00       	push   $0x801f09
  800a92:	68 f4 1e 80 00       	push   $0x801ef4
  800a97:	6a 7d                	push   $0x7d
  800a99:	68 e2 1e 80 00       	push   $0x801ee2
  800a9e:	e8 a0 05 00 00       	call   801043 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa3:	83 ec 04             	sub    $0x4,%esp
  800aa6:	50                   	push   %eax
  800aa7:	68 00 50 80 00       	push   $0x805000
  800aac:	ff 75 0c             	pushl  0xc(%ebp)
  800aaf:	e8 7f 0d 00 00       	call   801833 <memmove>
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
  800acb:	e8 98 0b 00 00       	call   801668 <strlen>
  800ad0:	83 c4 10             	add    $0x10,%esp
  800ad3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad8:	7f 67                	jg     800b41 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ada:	83 ec 0c             	sub    $0xc,%esp
  800add:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae0:	50                   	push   %eax
  800ae1:	e8 c6 f8 ff ff       	call   8003ac <fd_alloc>
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
  800af8:	e8 a4 0b 00 00       	call   8016a1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b00:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b08:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0d:	e8 22 fe ff ff       	call   800934 <fsipc>
  800b12:	89 c3                	mov    %eax,%ebx
  800b14:	83 c4 10             	add    $0x10,%esp
  800b17:	85 c0                	test   %eax,%eax
  800b19:	79 14                	jns    800b2f <open+0x6f>
		fd_close(fd, 0);
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	6a 00                	push   $0x0
  800b20:	ff 75 f4             	pushl  -0xc(%ebp)
  800b23:	e8 7c f9 ff ff       	call   8004a4 <fd_close>
		return r;
  800b28:	83 c4 10             	add    $0x10,%esp
  800b2b:	89 da                	mov    %ebx,%edx
  800b2d:	eb 17                	jmp    800b46 <open+0x86>
	}

	return fd2num(fd);
  800b2f:	83 ec 0c             	sub    $0xc,%esp
  800b32:	ff 75 f4             	pushl  -0xc(%ebp)
  800b35:	e8 4b f8 ff ff       	call   800385 <fd2num>
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
  800b5d:	e8 d2 fd ff ff       	call   800934 <fsipc>
}
  800b62:	c9                   	leave  
  800b63:	c3                   	ret    

00800b64 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b6c:	83 ec 0c             	sub    $0xc,%esp
  800b6f:	ff 75 08             	pushl  0x8(%ebp)
  800b72:	e8 1e f8 ff ff       	call   800395 <fd2data>
  800b77:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b79:	83 c4 08             	add    $0x8,%esp
  800b7c:	68 15 1f 80 00       	push   $0x801f15
  800b81:	53                   	push   %ebx
  800b82:	e8 1a 0b 00 00       	call   8016a1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b87:	8b 46 04             	mov    0x4(%esi),%eax
  800b8a:	2b 06                	sub    (%esi),%eax
  800b8c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b92:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b99:	00 00 00 
	stat->st_dev = &devpipe;
  800b9c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ba3:	30 80 00 
	return 0;
}
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 0c             	sub    $0xc,%esp
  800bb9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bbc:	53                   	push   %ebx
  800bbd:	6a 00                	push   $0x0
  800bbf:	e8 31 f6 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc4:	89 1c 24             	mov    %ebx,(%esp)
  800bc7:	e8 c9 f7 ff ff       	call   800395 <fd2data>
  800bcc:	83 c4 08             	add    $0x8,%esp
  800bcf:	50                   	push   %eax
  800bd0:	6a 00                	push   $0x0
  800bd2:	e8 1e f6 ff ff       	call   8001f5 <sys_page_unmap>
}
  800bd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    

00800bdc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 1c             	sub    $0x1c,%esp
  800be5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800be8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bea:	a1 04 40 80 00       	mov    0x804004,%eax
  800bef:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bf2:	83 ec 0c             	sub    $0xc,%esp
  800bf5:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf8:	e8 26 0f 00 00       	call   801b23 <pageref>
  800bfd:	89 c3                	mov    %eax,%ebx
  800bff:	89 3c 24             	mov    %edi,(%esp)
  800c02:	e8 1c 0f 00 00       	call   801b23 <pageref>
  800c07:	83 c4 10             	add    $0x10,%esp
  800c0a:	39 c3                	cmp    %eax,%ebx
  800c0c:	0f 94 c1             	sete   %cl
  800c0f:	0f b6 c9             	movzbl %cl,%ecx
  800c12:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c15:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c1b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c1e:	39 ce                	cmp    %ecx,%esi
  800c20:	74 1b                	je     800c3d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c22:	39 c3                	cmp    %eax,%ebx
  800c24:	75 c4                	jne    800bea <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c26:	8b 42 58             	mov    0x58(%edx),%eax
  800c29:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c2c:	50                   	push   %eax
  800c2d:	56                   	push   %esi
  800c2e:	68 1c 1f 80 00       	push   $0x801f1c
  800c33:	e8 e4 04 00 00       	call   80111c <cprintf>
  800c38:	83 c4 10             	add    $0x10,%esp
  800c3b:	eb ad                	jmp    800bea <_pipeisclosed+0xe>
	}
}
  800c3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 28             	sub    $0x28,%esp
  800c51:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c54:	56                   	push   %esi
  800c55:	e8 3b f7 ff ff       	call   800395 <fd2data>
  800c5a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c5c:	83 c4 10             	add    $0x10,%esp
  800c5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c64:	eb 4b                	jmp    800cb1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c66:	89 da                	mov    %ebx,%edx
  800c68:	89 f0                	mov    %esi,%eax
  800c6a:	e8 6d ff ff ff       	call   800bdc <_pipeisclosed>
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	75 48                	jne    800cbb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c73:	e8 d9 f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c78:	8b 43 04             	mov    0x4(%ebx),%eax
  800c7b:	8b 0b                	mov    (%ebx),%ecx
  800c7d:	8d 51 20             	lea    0x20(%ecx),%edx
  800c80:	39 d0                	cmp    %edx,%eax
  800c82:	73 e2                	jae    800c66 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c87:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c8b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c8e:	89 c2                	mov    %eax,%edx
  800c90:	c1 fa 1f             	sar    $0x1f,%edx
  800c93:	89 d1                	mov    %edx,%ecx
  800c95:	c1 e9 1b             	shr    $0x1b,%ecx
  800c98:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c9b:	83 e2 1f             	and    $0x1f,%edx
  800c9e:	29 ca                	sub    %ecx,%edx
  800ca0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca8:	83 c0 01             	add    $0x1,%eax
  800cab:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cae:	83 c7 01             	add    $0x1,%edi
  800cb1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb4:	75 c2                	jne    800c78 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cb6:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb9:	eb 05                	jmp    800cc0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cbb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 18             	sub    $0x18,%esp
  800cd1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cd4:	57                   	push   %edi
  800cd5:	e8 bb f6 ff ff       	call   800395 <fd2data>
  800cda:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cdc:	83 c4 10             	add    $0x10,%esp
  800cdf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce4:	eb 3d                	jmp    800d23 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ce6:	85 db                	test   %ebx,%ebx
  800ce8:	74 04                	je     800cee <devpipe_read+0x26>
				return i;
  800cea:	89 d8                	mov    %ebx,%eax
  800cec:	eb 44                	jmp    800d32 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cee:	89 f2                	mov    %esi,%edx
  800cf0:	89 f8                	mov    %edi,%eax
  800cf2:	e8 e5 fe ff ff       	call   800bdc <_pipeisclosed>
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	75 32                	jne    800d2d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cfb:	e8 51 f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d00:	8b 06                	mov    (%esi),%eax
  800d02:	3b 46 04             	cmp    0x4(%esi),%eax
  800d05:	74 df                	je     800ce6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d07:	99                   	cltd   
  800d08:	c1 ea 1b             	shr    $0x1b,%edx
  800d0b:	01 d0                	add    %edx,%eax
  800d0d:	83 e0 1f             	and    $0x1f,%eax
  800d10:	29 d0                	sub    %edx,%eax
  800d12:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d1d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d20:	83 c3 01             	add    $0x1,%ebx
  800d23:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d26:	75 d8                	jne    800d00 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d28:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2b:	eb 05                	jmp    800d32 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d2d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
  800d3f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d45:	50                   	push   %eax
  800d46:	e8 61 f6 ff ff       	call   8003ac <fd_alloc>
  800d4b:	83 c4 10             	add    $0x10,%esp
  800d4e:	89 c2                	mov    %eax,%edx
  800d50:	85 c0                	test   %eax,%eax
  800d52:	0f 88 2c 01 00 00    	js     800e84 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d58:	83 ec 04             	sub    $0x4,%esp
  800d5b:	68 07 04 00 00       	push   $0x407
  800d60:	ff 75 f4             	pushl  -0xc(%ebp)
  800d63:	6a 00                	push   $0x0
  800d65:	e8 06 f4 ff ff       	call   800170 <sys_page_alloc>
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	89 c2                	mov    %eax,%edx
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	0f 88 0d 01 00 00    	js     800e84 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d77:	83 ec 0c             	sub    $0xc,%esp
  800d7a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d7d:	50                   	push   %eax
  800d7e:	e8 29 f6 ff ff       	call   8003ac <fd_alloc>
  800d83:	89 c3                	mov    %eax,%ebx
  800d85:	83 c4 10             	add    $0x10,%esp
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	0f 88 e2 00 00 00    	js     800e72 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d90:	83 ec 04             	sub    $0x4,%esp
  800d93:	68 07 04 00 00       	push   $0x407
  800d98:	ff 75 f0             	pushl  -0x10(%ebp)
  800d9b:	6a 00                	push   $0x0
  800d9d:	e8 ce f3 ff ff       	call   800170 <sys_page_alloc>
  800da2:	89 c3                	mov    %eax,%ebx
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	0f 88 c3 00 00 00    	js     800e72 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	ff 75 f4             	pushl  -0xc(%ebp)
  800db5:	e8 db f5 ff ff       	call   800395 <fd2data>
  800dba:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbc:	83 c4 0c             	add    $0xc,%esp
  800dbf:	68 07 04 00 00       	push   $0x407
  800dc4:	50                   	push   %eax
  800dc5:	6a 00                	push   $0x0
  800dc7:	e8 a4 f3 ff ff       	call   800170 <sys_page_alloc>
  800dcc:	89 c3                	mov    %eax,%ebx
  800dce:	83 c4 10             	add    $0x10,%esp
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	0f 88 89 00 00 00    	js     800e62 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	ff 75 f0             	pushl  -0x10(%ebp)
  800ddf:	e8 b1 f5 ff ff       	call   800395 <fd2data>
  800de4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800deb:	50                   	push   %eax
  800dec:	6a 00                	push   $0x0
  800dee:	56                   	push   %esi
  800def:	6a 00                	push   $0x0
  800df1:	e8 bd f3 ff ff       	call   8001b3 <sys_page_map>
  800df6:	89 c3                	mov    %eax,%ebx
  800df8:	83 c4 20             	add    $0x20,%esp
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	78 55                	js     800e54 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e08:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e14:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e22:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e29:	83 ec 0c             	sub    $0xc,%esp
  800e2c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e2f:	e8 51 f5 ff ff       	call   800385 <fd2num>
  800e34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e37:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e39:	83 c4 04             	add    $0x4,%esp
  800e3c:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3f:	e8 41 f5 ff ff       	call   800385 <fd2num>
  800e44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e47:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e4a:	83 c4 10             	add    $0x10,%esp
  800e4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e52:	eb 30                	jmp    800e84 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e54:	83 ec 08             	sub    $0x8,%esp
  800e57:	56                   	push   %esi
  800e58:	6a 00                	push   $0x0
  800e5a:	e8 96 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e5f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e62:	83 ec 08             	sub    $0x8,%esp
  800e65:	ff 75 f0             	pushl  -0x10(%ebp)
  800e68:	6a 00                	push   $0x0
  800e6a:	e8 86 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e6f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e72:	83 ec 08             	sub    $0x8,%esp
  800e75:	ff 75 f4             	pushl  -0xc(%ebp)
  800e78:	6a 00                	push   $0x0
  800e7a:	e8 76 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e7f:	83 c4 10             	add    $0x10,%esp
  800e82:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e84:	89 d0                	mov    %edx,%eax
  800e86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e96:	50                   	push   %eax
  800e97:	ff 75 08             	pushl  0x8(%ebp)
  800e9a:	e8 5c f5 ff ff       	call   8003fb <fd_lookup>
  800e9f:	83 c4 10             	add    $0x10,%esp
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	78 18                	js     800ebe <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ea6:	83 ec 0c             	sub    $0xc,%esp
  800ea9:	ff 75 f4             	pushl  -0xc(%ebp)
  800eac:	e8 e4 f4 ff ff       	call   800395 <fd2data>
	return _pipeisclosed(fd, p);
  800eb1:	89 c2                	mov    %eax,%edx
  800eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb6:	e8 21 fd ff ff       	call   800bdc <_pipeisclosed>
  800ebb:	83 c4 10             	add    $0x10,%esp
}
  800ebe:	c9                   	leave  
  800ebf:	c3                   	ret    

00800ec0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ec3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed0:	68 34 1f 80 00       	push   $0x801f34
  800ed5:	ff 75 0c             	pushl  0xc(%ebp)
  800ed8:	e8 c4 07 00 00       	call   8016a1 <strcpy>
	return 0;
}
  800edd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    

00800ee4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	57                   	push   %edi
  800ee8:	56                   	push   %esi
  800ee9:	53                   	push   %ebx
  800eea:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800efb:	eb 2d                	jmp    800f2a <devcons_write+0x46>
		m = n - tot;
  800efd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f00:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f02:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f05:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f0a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f0d:	83 ec 04             	sub    $0x4,%esp
  800f10:	53                   	push   %ebx
  800f11:	03 45 0c             	add    0xc(%ebp),%eax
  800f14:	50                   	push   %eax
  800f15:	57                   	push   %edi
  800f16:	e8 18 09 00 00       	call   801833 <memmove>
		sys_cputs(buf, m);
  800f1b:	83 c4 08             	add    $0x8,%esp
  800f1e:	53                   	push   %ebx
  800f1f:	57                   	push   %edi
  800f20:	e8 8f f1 ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f25:	01 de                	add    %ebx,%esi
  800f27:	83 c4 10             	add    $0x10,%esp
  800f2a:	89 f0                	mov    %esi,%eax
  800f2c:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f2f:	72 cc                	jb     800efd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	83 ec 08             	sub    $0x8,%esp
  800f3f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f48:	74 2a                	je     800f74 <devcons_read+0x3b>
  800f4a:	eb 05                	jmp    800f51 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f4c:	e8 00 f2 ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f51:	e8 7c f1 ff ff       	call   8000d2 <sys_cgetc>
  800f56:	85 c0                	test   %eax,%eax
  800f58:	74 f2                	je     800f4c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	78 16                	js     800f74 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f5e:	83 f8 04             	cmp    $0x4,%eax
  800f61:	74 0c                	je     800f6f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f63:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f66:	88 02                	mov    %al,(%edx)
	return 1;
  800f68:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6d:	eb 05                	jmp    800f74 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f6f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    

00800f76 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f82:	6a 01                	push   $0x1
  800f84:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f87:	50                   	push   %eax
  800f88:	e8 27 f1 ff ff       	call   8000b4 <sys_cputs>
}
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	c9                   	leave  
  800f91:	c3                   	ret    

00800f92 <getchar>:

int
getchar(void)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f98:	6a 01                	push   $0x1
  800f9a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9d:	50                   	push   %eax
  800f9e:	6a 00                	push   $0x0
  800fa0:	e8 bc f6 ff ff       	call   800661 <read>
	if (r < 0)
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	78 0f                	js     800fbb <getchar+0x29>
		return r;
	if (r < 1)
  800fac:	85 c0                	test   %eax,%eax
  800fae:	7e 06                	jle    800fb6 <getchar+0x24>
		return -E_EOF;
	return c;
  800fb0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fb4:	eb 05                	jmp    800fbb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fb6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc6:	50                   	push   %eax
  800fc7:	ff 75 08             	pushl  0x8(%ebp)
  800fca:	e8 2c f4 ff ff       	call   8003fb <fd_lookup>
  800fcf:	83 c4 10             	add    $0x10,%esp
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	78 11                	js     800fe7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fdf:	39 10                	cmp    %edx,(%eax)
  800fe1:	0f 94 c0             	sete   %al
  800fe4:	0f b6 c0             	movzbl %al,%eax
}
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    

00800fe9 <opencons>:

int
opencons(void)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff2:	50                   	push   %eax
  800ff3:	e8 b4 f3 ff ff       	call   8003ac <fd_alloc>
  800ff8:	83 c4 10             	add    $0x10,%esp
		return r;
  800ffb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	78 3e                	js     80103f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801001:	83 ec 04             	sub    $0x4,%esp
  801004:	68 07 04 00 00       	push   $0x407
  801009:	ff 75 f4             	pushl  -0xc(%ebp)
  80100c:	6a 00                	push   $0x0
  80100e:	e8 5d f1 ff ff       	call   800170 <sys_page_alloc>
  801013:	83 c4 10             	add    $0x10,%esp
		return r;
  801016:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 23                	js     80103f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80101c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801022:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801025:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801027:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801031:	83 ec 0c             	sub    $0xc,%esp
  801034:	50                   	push   %eax
  801035:	e8 4b f3 ff ff       	call   800385 <fd2num>
  80103a:	89 c2                	mov    %eax,%edx
  80103c:	83 c4 10             	add    $0x10,%esp
}
  80103f:	89 d0                	mov    %edx,%eax
  801041:	c9                   	leave  
  801042:	c3                   	ret    

00801043 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801048:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80104b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801051:	e8 dc f0 ff ff       	call   800132 <sys_getenvid>
  801056:	83 ec 0c             	sub    $0xc,%esp
  801059:	ff 75 0c             	pushl  0xc(%ebp)
  80105c:	ff 75 08             	pushl  0x8(%ebp)
  80105f:	56                   	push   %esi
  801060:	50                   	push   %eax
  801061:	68 40 1f 80 00       	push   $0x801f40
  801066:	e8 b1 00 00 00       	call   80111c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80106b:	83 c4 18             	add    $0x18,%esp
  80106e:	53                   	push   %ebx
  80106f:	ff 75 10             	pushl  0x10(%ebp)
  801072:	e8 54 00 00 00       	call   8010cb <vcprintf>
	cprintf("\n");
  801077:	c7 04 24 2d 1f 80 00 	movl   $0x801f2d,(%esp)
  80107e:	e8 99 00 00 00       	call   80111c <cprintf>
  801083:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801086:	cc                   	int3   
  801087:	eb fd                	jmp    801086 <_panic+0x43>

00801089 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	53                   	push   %ebx
  80108d:	83 ec 04             	sub    $0x4,%esp
  801090:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801093:	8b 13                	mov    (%ebx),%edx
  801095:	8d 42 01             	lea    0x1(%edx),%eax
  801098:	89 03                	mov    %eax,(%ebx)
  80109a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010a1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010a6:	75 1a                	jne    8010c2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010a8:	83 ec 08             	sub    $0x8,%esp
  8010ab:	68 ff 00 00 00       	push   $0xff
  8010b0:	8d 43 08             	lea    0x8(%ebx),%eax
  8010b3:	50                   	push   %eax
  8010b4:	e8 fb ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8010b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010bf:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010c2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c9:	c9                   	leave  
  8010ca:	c3                   	ret    

008010cb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010db:	00 00 00 
	b.cnt = 0;
  8010de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010e8:	ff 75 0c             	pushl  0xc(%ebp)
  8010eb:	ff 75 08             	pushl  0x8(%ebp)
  8010ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010f4:	50                   	push   %eax
  8010f5:	68 89 10 80 00       	push   $0x801089
  8010fa:	e8 54 01 00 00       	call   801253 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ff:	83 c4 08             	add    $0x8,%esp
  801102:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801108:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80110e:	50                   	push   %eax
  80110f:	e8 a0 ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  801114:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80111a:	c9                   	leave  
  80111b:	c3                   	ret    

0080111c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801122:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801125:	50                   	push   %eax
  801126:	ff 75 08             	pushl  0x8(%ebp)
  801129:	e8 9d ff ff ff       	call   8010cb <vcprintf>
	va_end(ap);

	return cnt;
}
  80112e:	c9                   	leave  
  80112f:	c3                   	ret    

00801130 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	57                   	push   %edi
  801134:	56                   	push   %esi
  801135:	53                   	push   %ebx
  801136:	83 ec 1c             	sub    $0x1c,%esp
  801139:	89 c7                	mov    %eax,%edi
  80113b:	89 d6                	mov    %edx,%esi
  80113d:	8b 45 08             	mov    0x8(%ebp),%eax
  801140:	8b 55 0c             	mov    0xc(%ebp),%edx
  801143:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801146:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801149:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80114c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801151:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801154:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801157:	39 d3                	cmp    %edx,%ebx
  801159:	72 05                	jb     801160 <printnum+0x30>
  80115b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80115e:	77 45                	ja     8011a5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801160:	83 ec 0c             	sub    $0xc,%esp
  801163:	ff 75 18             	pushl  0x18(%ebp)
  801166:	8b 45 14             	mov    0x14(%ebp),%eax
  801169:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80116c:	53                   	push   %ebx
  80116d:	ff 75 10             	pushl  0x10(%ebp)
  801170:	83 ec 08             	sub    $0x8,%esp
  801173:	ff 75 e4             	pushl  -0x1c(%ebp)
  801176:	ff 75 e0             	pushl  -0x20(%ebp)
  801179:	ff 75 dc             	pushl  -0x24(%ebp)
  80117c:	ff 75 d8             	pushl  -0x28(%ebp)
  80117f:	e8 dc 09 00 00       	call   801b60 <__udivdi3>
  801184:	83 c4 18             	add    $0x18,%esp
  801187:	52                   	push   %edx
  801188:	50                   	push   %eax
  801189:	89 f2                	mov    %esi,%edx
  80118b:	89 f8                	mov    %edi,%eax
  80118d:	e8 9e ff ff ff       	call   801130 <printnum>
  801192:	83 c4 20             	add    $0x20,%esp
  801195:	eb 18                	jmp    8011af <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801197:	83 ec 08             	sub    $0x8,%esp
  80119a:	56                   	push   %esi
  80119b:	ff 75 18             	pushl  0x18(%ebp)
  80119e:	ff d7                	call   *%edi
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	eb 03                	jmp    8011a8 <printnum+0x78>
  8011a5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011a8:	83 eb 01             	sub    $0x1,%ebx
  8011ab:	85 db                	test   %ebx,%ebx
  8011ad:	7f e8                	jg     801197 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011af:	83 ec 08             	sub    $0x8,%esp
  8011b2:	56                   	push   %esi
  8011b3:	83 ec 04             	sub    $0x4,%esp
  8011b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8011bc:	ff 75 dc             	pushl  -0x24(%ebp)
  8011bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c2:	e8 c9 0a 00 00       	call   801c90 <__umoddi3>
  8011c7:	83 c4 14             	add    $0x14,%esp
  8011ca:	0f be 80 63 1f 80 00 	movsbl 0x801f63(%eax),%eax
  8011d1:	50                   	push   %eax
  8011d2:	ff d7                	call   *%edi
}
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011da:	5b                   	pop    %ebx
  8011db:	5e                   	pop    %esi
  8011dc:	5f                   	pop    %edi
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011e2:	83 fa 01             	cmp    $0x1,%edx
  8011e5:	7e 0e                	jle    8011f5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011e7:	8b 10                	mov    (%eax),%edx
  8011e9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011ec:	89 08                	mov    %ecx,(%eax)
  8011ee:	8b 02                	mov    (%edx),%eax
  8011f0:	8b 52 04             	mov    0x4(%edx),%edx
  8011f3:	eb 22                	jmp    801217 <getuint+0x38>
	else if (lflag)
  8011f5:	85 d2                	test   %edx,%edx
  8011f7:	74 10                	je     801209 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011f9:	8b 10                	mov    (%eax),%edx
  8011fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011fe:	89 08                	mov    %ecx,(%eax)
  801200:	8b 02                	mov    (%edx),%eax
  801202:	ba 00 00 00 00       	mov    $0x0,%edx
  801207:	eb 0e                	jmp    801217 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801209:	8b 10                	mov    (%eax),%edx
  80120b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80120e:	89 08                	mov    %ecx,(%eax)
  801210:	8b 02                	mov    (%edx),%eax
  801212:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80121f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801223:	8b 10                	mov    (%eax),%edx
  801225:	3b 50 04             	cmp    0x4(%eax),%edx
  801228:	73 0a                	jae    801234 <sprintputch+0x1b>
		*b->buf++ = ch;
  80122a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80122d:	89 08                	mov    %ecx,(%eax)
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
  801232:	88 02                	mov    %al,(%edx)
}
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80123c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80123f:	50                   	push   %eax
  801240:	ff 75 10             	pushl  0x10(%ebp)
  801243:	ff 75 0c             	pushl  0xc(%ebp)
  801246:	ff 75 08             	pushl  0x8(%ebp)
  801249:	e8 05 00 00 00       	call   801253 <vprintfmt>
	va_end(ap);
}
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	57                   	push   %edi
  801257:	56                   	push   %esi
  801258:	53                   	push   %ebx
  801259:	83 ec 2c             	sub    $0x2c,%esp
  80125c:	8b 75 08             	mov    0x8(%ebp),%esi
  80125f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801262:	8b 7d 10             	mov    0x10(%ebp),%edi
  801265:	eb 12                	jmp    801279 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801267:	85 c0                	test   %eax,%eax
  801269:	0f 84 89 03 00 00    	je     8015f8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80126f:	83 ec 08             	sub    $0x8,%esp
  801272:	53                   	push   %ebx
  801273:	50                   	push   %eax
  801274:	ff d6                	call   *%esi
  801276:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801279:	83 c7 01             	add    $0x1,%edi
  80127c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801280:	83 f8 25             	cmp    $0x25,%eax
  801283:	75 e2                	jne    801267 <vprintfmt+0x14>
  801285:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801289:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801290:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801297:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80129e:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a3:	eb 07                	jmp    8012ac <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012a8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ac:	8d 47 01             	lea    0x1(%edi),%eax
  8012af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012b2:	0f b6 07             	movzbl (%edi),%eax
  8012b5:	0f b6 c8             	movzbl %al,%ecx
  8012b8:	83 e8 23             	sub    $0x23,%eax
  8012bb:	3c 55                	cmp    $0x55,%al
  8012bd:	0f 87 1a 03 00 00    	ja     8015dd <vprintfmt+0x38a>
  8012c3:	0f b6 c0             	movzbl %al,%eax
  8012c6:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  8012cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012d0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012d4:	eb d6                	jmp    8012ac <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012de:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012e1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012e4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012e8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012eb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012ee:	83 fa 09             	cmp    $0x9,%edx
  8012f1:	77 39                	ja     80132c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012f3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012f6:	eb e9                	jmp    8012e1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8012fb:	8d 48 04             	lea    0x4(%eax),%ecx
  8012fe:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801301:	8b 00                	mov    (%eax),%eax
  801303:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801309:	eb 27                	jmp    801332 <vprintfmt+0xdf>
  80130b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80130e:	85 c0                	test   %eax,%eax
  801310:	b9 00 00 00 00       	mov    $0x0,%ecx
  801315:	0f 49 c8             	cmovns %eax,%ecx
  801318:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131e:	eb 8c                	jmp    8012ac <vprintfmt+0x59>
  801320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801323:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80132a:	eb 80                	jmp    8012ac <vprintfmt+0x59>
  80132c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80132f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801332:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801336:	0f 89 70 ff ff ff    	jns    8012ac <vprintfmt+0x59>
				width = precision, precision = -1;
  80133c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80133f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801342:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801349:	e9 5e ff ff ff       	jmp    8012ac <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80134e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801354:	e9 53 ff ff ff       	jmp    8012ac <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801359:	8b 45 14             	mov    0x14(%ebp),%eax
  80135c:	8d 50 04             	lea    0x4(%eax),%edx
  80135f:	89 55 14             	mov    %edx,0x14(%ebp)
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	53                   	push   %ebx
  801366:	ff 30                	pushl  (%eax)
  801368:	ff d6                	call   *%esi
			break;
  80136a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801370:	e9 04 ff ff ff       	jmp    801279 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801375:	8b 45 14             	mov    0x14(%ebp),%eax
  801378:	8d 50 04             	lea    0x4(%eax),%edx
  80137b:	89 55 14             	mov    %edx,0x14(%ebp)
  80137e:	8b 00                	mov    (%eax),%eax
  801380:	99                   	cltd   
  801381:	31 d0                	xor    %edx,%eax
  801383:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801385:	83 f8 0f             	cmp    $0xf,%eax
  801388:	7f 0b                	jg     801395 <vprintfmt+0x142>
  80138a:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  801391:	85 d2                	test   %edx,%edx
  801393:	75 18                	jne    8013ad <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801395:	50                   	push   %eax
  801396:	68 7b 1f 80 00       	push   $0x801f7b
  80139b:	53                   	push   %ebx
  80139c:	56                   	push   %esi
  80139d:	e8 94 fe ff ff       	call   801236 <printfmt>
  8013a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013a8:	e9 cc fe ff ff       	jmp    801279 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013ad:	52                   	push   %edx
  8013ae:	68 06 1f 80 00       	push   $0x801f06
  8013b3:	53                   	push   %ebx
  8013b4:	56                   	push   %esi
  8013b5:	e8 7c fe ff ff       	call   801236 <printfmt>
  8013ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013c0:	e9 b4 fe ff ff       	jmp    801279 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c8:	8d 50 04             	lea    0x4(%eax),%edx
  8013cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ce:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013d0:	85 ff                	test   %edi,%edi
  8013d2:	b8 74 1f 80 00       	mov    $0x801f74,%eax
  8013d7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013de:	0f 8e 94 00 00 00    	jle    801478 <vprintfmt+0x225>
  8013e4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013e8:	0f 84 98 00 00 00    	je     801486 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ee:	83 ec 08             	sub    $0x8,%esp
  8013f1:	ff 75 d0             	pushl  -0x30(%ebp)
  8013f4:	57                   	push   %edi
  8013f5:	e8 86 02 00 00       	call   801680 <strnlen>
  8013fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013fd:	29 c1                	sub    %eax,%ecx
  8013ff:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801402:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801405:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801409:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80140c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80140f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801411:	eb 0f                	jmp    801422 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801413:	83 ec 08             	sub    $0x8,%esp
  801416:	53                   	push   %ebx
  801417:	ff 75 e0             	pushl  -0x20(%ebp)
  80141a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80141c:	83 ef 01             	sub    $0x1,%edi
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	85 ff                	test   %edi,%edi
  801424:	7f ed                	jg     801413 <vprintfmt+0x1c0>
  801426:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801429:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80142c:	85 c9                	test   %ecx,%ecx
  80142e:	b8 00 00 00 00       	mov    $0x0,%eax
  801433:	0f 49 c1             	cmovns %ecx,%eax
  801436:	29 c1                	sub    %eax,%ecx
  801438:	89 75 08             	mov    %esi,0x8(%ebp)
  80143b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80143e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801441:	89 cb                	mov    %ecx,%ebx
  801443:	eb 4d                	jmp    801492 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801445:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801449:	74 1b                	je     801466 <vprintfmt+0x213>
  80144b:	0f be c0             	movsbl %al,%eax
  80144e:	83 e8 20             	sub    $0x20,%eax
  801451:	83 f8 5e             	cmp    $0x5e,%eax
  801454:	76 10                	jbe    801466 <vprintfmt+0x213>
					putch('?', putdat);
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	ff 75 0c             	pushl  0xc(%ebp)
  80145c:	6a 3f                	push   $0x3f
  80145e:	ff 55 08             	call   *0x8(%ebp)
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	eb 0d                	jmp    801473 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801466:	83 ec 08             	sub    $0x8,%esp
  801469:	ff 75 0c             	pushl  0xc(%ebp)
  80146c:	52                   	push   %edx
  80146d:	ff 55 08             	call   *0x8(%ebp)
  801470:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801473:	83 eb 01             	sub    $0x1,%ebx
  801476:	eb 1a                	jmp    801492 <vprintfmt+0x23f>
  801478:	89 75 08             	mov    %esi,0x8(%ebp)
  80147b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80147e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801481:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801484:	eb 0c                	jmp    801492 <vprintfmt+0x23f>
  801486:	89 75 08             	mov    %esi,0x8(%ebp)
  801489:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80148c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80148f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801492:	83 c7 01             	add    $0x1,%edi
  801495:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801499:	0f be d0             	movsbl %al,%edx
  80149c:	85 d2                	test   %edx,%edx
  80149e:	74 23                	je     8014c3 <vprintfmt+0x270>
  8014a0:	85 f6                	test   %esi,%esi
  8014a2:	78 a1                	js     801445 <vprintfmt+0x1f2>
  8014a4:	83 ee 01             	sub    $0x1,%esi
  8014a7:	79 9c                	jns    801445 <vprintfmt+0x1f2>
  8014a9:	89 df                	mov    %ebx,%edi
  8014ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014b1:	eb 18                	jmp    8014cb <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014b3:	83 ec 08             	sub    $0x8,%esp
  8014b6:	53                   	push   %ebx
  8014b7:	6a 20                	push   $0x20
  8014b9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014bb:	83 ef 01             	sub    $0x1,%edi
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	eb 08                	jmp    8014cb <vprintfmt+0x278>
  8014c3:	89 df                	mov    %ebx,%edi
  8014c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014cb:	85 ff                	test   %edi,%edi
  8014cd:	7f e4                	jg     8014b3 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014d2:	e9 a2 fd ff ff       	jmp    801279 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014d7:	83 fa 01             	cmp    $0x1,%edx
  8014da:	7e 16                	jle    8014f2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014df:	8d 50 08             	lea    0x8(%eax),%edx
  8014e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e5:	8b 50 04             	mov    0x4(%eax),%edx
  8014e8:	8b 00                	mov    (%eax),%eax
  8014ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014f0:	eb 32                	jmp    801524 <vprintfmt+0x2d1>
	else if (lflag)
  8014f2:	85 d2                	test   %edx,%edx
  8014f4:	74 18                	je     80150e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f9:	8d 50 04             	lea    0x4(%eax),%edx
  8014fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ff:	8b 00                	mov    (%eax),%eax
  801501:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801504:	89 c1                	mov    %eax,%ecx
  801506:	c1 f9 1f             	sar    $0x1f,%ecx
  801509:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80150c:	eb 16                	jmp    801524 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80150e:	8b 45 14             	mov    0x14(%ebp),%eax
  801511:	8d 50 04             	lea    0x4(%eax),%edx
  801514:	89 55 14             	mov    %edx,0x14(%ebp)
  801517:	8b 00                	mov    (%eax),%eax
  801519:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80151c:	89 c1                	mov    %eax,%ecx
  80151e:	c1 f9 1f             	sar    $0x1f,%ecx
  801521:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801524:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801527:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80152a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80152f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801533:	79 74                	jns    8015a9 <vprintfmt+0x356>
				putch('-', putdat);
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	53                   	push   %ebx
  801539:	6a 2d                	push   $0x2d
  80153b:	ff d6                	call   *%esi
				num = -(long long) num;
  80153d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801540:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801543:	f7 d8                	neg    %eax
  801545:	83 d2 00             	adc    $0x0,%edx
  801548:	f7 da                	neg    %edx
  80154a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80154d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801552:	eb 55                	jmp    8015a9 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801554:	8d 45 14             	lea    0x14(%ebp),%eax
  801557:	e8 83 fc ff ff       	call   8011df <getuint>
			base = 10;
  80155c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801561:	eb 46                	jmp    8015a9 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801563:	8d 45 14             	lea    0x14(%ebp),%eax
  801566:	e8 74 fc ff ff       	call   8011df <getuint>
			base = 8;
  80156b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801570:	eb 37                	jmp    8015a9 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801572:	83 ec 08             	sub    $0x8,%esp
  801575:	53                   	push   %ebx
  801576:	6a 30                	push   $0x30
  801578:	ff d6                	call   *%esi
			putch('x', putdat);
  80157a:	83 c4 08             	add    $0x8,%esp
  80157d:	53                   	push   %ebx
  80157e:	6a 78                	push   $0x78
  801580:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801582:	8b 45 14             	mov    0x14(%ebp),%eax
  801585:	8d 50 04             	lea    0x4(%eax),%edx
  801588:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80158b:	8b 00                	mov    (%eax),%eax
  80158d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801592:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801595:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80159a:	eb 0d                	jmp    8015a9 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80159c:	8d 45 14             	lea    0x14(%ebp),%eax
  80159f:	e8 3b fc ff ff       	call   8011df <getuint>
			base = 16;
  8015a4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015a9:	83 ec 0c             	sub    $0xc,%esp
  8015ac:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015b0:	57                   	push   %edi
  8015b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015b4:	51                   	push   %ecx
  8015b5:	52                   	push   %edx
  8015b6:	50                   	push   %eax
  8015b7:	89 da                	mov    %ebx,%edx
  8015b9:	89 f0                	mov    %esi,%eax
  8015bb:	e8 70 fb ff ff       	call   801130 <printnum>
			break;
  8015c0:	83 c4 20             	add    $0x20,%esp
  8015c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015c6:	e9 ae fc ff ff       	jmp    801279 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	53                   	push   %ebx
  8015cf:	51                   	push   %ecx
  8015d0:	ff d6                	call   *%esi
			break;
  8015d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015d8:	e9 9c fc ff ff       	jmp    801279 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	53                   	push   %ebx
  8015e1:	6a 25                	push   $0x25
  8015e3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	eb 03                	jmp    8015ed <vprintfmt+0x39a>
  8015ea:	83 ef 01             	sub    $0x1,%edi
  8015ed:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015f1:	75 f7                	jne    8015ea <vprintfmt+0x397>
  8015f3:	e9 81 fc ff ff       	jmp    801279 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015fb:	5b                   	pop    %ebx
  8015fc:	5e                   	pop    %esi
  8015fd:	5f                   	pop    %edi
  8015fe:	5d                   	pop    %ebp
  8015ff:	c3                   	ret    

00801600 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	83 ec 18             	sub    $0x18,%esp
  801606:	8b 45 08             	mov    0x8(%ebp),%eax
  801609:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80160c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80160f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801613:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801616:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80161d:	85 c0                	test   %eax,%eax
  80161f:	74 26                	je     801647 <vsnprintf+0x47>
  801621:	85 d2                	test   %edx,%edx
  801623:	7e 22                	jle    801647 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801625:	ff 75 14             	pushl  0x14(%ebp)
  801628:	ff 75 10             	pushl  0x10(%ebp)
  80162b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80162e:	50                   	push   %eax
  80162f:	68 19 12 80 00       	push   $0x801219
  801634:	e8 1a fc ff ff       	call   801253 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801639:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80163c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80163f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	eb 05                	jmp    80164c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801647:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    

0080164e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801654:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801657:	50                   	push   %eax
  801658:	ff 75 10             	pushl  0x10(%ebp)
  80165b:	ff 75 0c             	pushl  0xc(%ebp)
  80165e:	ff 75 08             	pushl  0x8(%ebp)
  801661:	e8 9a ff ff ff       	call   801600 <vsnprintf>
	va_end(ap);

	return rc;
}
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80166e:	b8 00 00 00 00       	mov    $0x0,%eax
  801673:	eb 03                	jmp    801678 <strlen+0x10>
		n++;
  801675:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801678:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80167c:	75 f7                	jne    801675 <strlen+0xd>
		n++;
	return n;
}
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801686:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801689:	ba 00 00 00 00       	mov    $0x0,%edx
  80168e:	eb 03                	jmp    801693 <strnlen+0x13>
		n++;
  801690:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801693:	39 c2                	cmp    %eax,%edx
  801695:	74 08                	je     80169f <strnlen+0x1f>
  801697:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80169b:	75 f3                	jne    801690 <strnlen+0x10>
  80169d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80169f:	5d                   	pop    %ebp
  8016a0:	c3                   	ret    

008016a1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	53                   	push   %ebx
  8016a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016ab:	89 c2                	mov    %eax,%edx
  8016ad:	83 c2 01             	add    $0x1,%edx
  8016b0:	83 c1 01             	add    $0x1,%ecx
  8016b3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016b7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016ba:	84 db                	test   %bl,%bl
  8016bc:	75 ef                	jne    8016ad <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016be:	5b                   	pop    %ebx
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    

008016c1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	53                   	push   %ebx
  8016c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016c8:	53                   	push   %ebx
  8016c9:	e8 9a ff ff ff       	call   801668 <strlen>
  8016ce:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016d1:	ff 75 0c             	pushl  0xc(%ebp)
  8016d4:	01 d8                	add    %ebx,%eax
  8016d6:	50                   	push   %eax
  8016d7:	e8 c5 ff ff ff       	call   8016a1 <strcpy>
	return dst;
}
  8016dc:	89 d8                	mov    %ebx,%eax
  8016de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	56                   	push   %esi
  8016e7:	53                   	push   %ebx
  8016e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8016eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ee:	89 f3                	mov    %esi,%ebx
  8016f0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f3:	89 f2                	mov    %esi,%edx
  8016f5:	eb 0f                	jmp    801706 <strncpy+0x23>
		*dst++ = *src;
  8016f7:	83 c2 01             	add    $0x1,%edx
  8016fa:	0f b6 01             	movzbl (%ecx),%eax
  8016fd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801700:	80 39 01             	cmpb   $0x1,(%ecx)
  801703:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801706:	39 da                	cmp    %ebx,%edx
  801708:	75 ed                	jne    8016f7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80170a:	89 f0                	mov    %esi,%eax
  80170c:	5b                   	pop    %ebx
  80170d:	5e                   	pop    %esi
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	56                   	push   %esi
  801714:	53                   	push   %ebx
  801715:	8b 75 08             	mov    0x8(%ebp),%esi
  801718:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80171b:	8b 55 10             	mov    0x10(%ebp),%edx
  80171e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801720:	85 d2                	test   %edx,%edx
  801722:	74 21                	je     801745 <strlcpy+0x35>
  801724:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801728:	89 f2                	mov    %esi,%edx
  80172a:	eb 09                	jmp    801735 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80172c:	83 c2 01             	add    $0x1,%edx
  80172f:	83 c1 01             	add    $0x1,%ecx
  801732:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801735:	39 c2                	cmp    %eax,%edx
  801737:	74 09                	je     801742 <strlcpy+0x32>
  801739:	0f b6 19             	movzbl (%ecx),%ebx
  80173c:	84 db                	test   %bl,%bl
  80173e:	75 ec                	jne    80172c <strlcpy+0x1c>
  801740:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801742:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801745:	29 f0                	sub    %esi,%eax
}
  801747:	5b                   	pop    %ebx
  801748:	5e                   	pop    %esi
  801749:	5d                   	pop    %ebp
  80174a:	c3                   	ret    

0080174b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801751:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801754:	eb 06                	jmp    80175c <strcmp+0x11>
		p++, q++;
  801756:	83 c1 01             	add    $0x1,%ecx
  801759:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80175c:	0f b6 01             	movzbl (%ecx),%eax
  80175f:	84 c0                	test   %al,%al
  801761:	74 04                	je     801767 <strcmp+0x1c>
  801763:	3a 02                	cmp    (%edx),%al
  801765:	74 ef                	je     801756 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801767:	0f b6 c0             	movzbl %al,%eax
  80176a:	0f b6 12             	movzbl (%edx),%edx
  80176d:	29 d0                	sub    %edx,%eax
}
  80176f:	5d                   	pop    %ebp
  801770:	c3                   	ret    

00801771 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	53                   	push   %ebx
  801775:	8b 45 08             	mov    0x8(%ebp),%eax
  801778:	8b 55 0c             	mov    0xc(%ebp),%edx
  80177b:	89 c3                	mov    %eax,%ebx
  80177d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801780:	eb 06                	jmp    801788 <strncmp+0x17>
		n--, p++, q++;
  801782:	83 c0 01             	add    $0x1,%eax
  801785:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801788:	39 d8                	cmp    %ebx,%eax
  80178a:	74 15                	je     8017a1 <strncmp+0x30>
  80178c:	0f b6 08             	movzbl (%eax),%ecx
  80178f:	84 c9                	test   %cl,%cl
  801791:	74 04                	je     801797 <strncmp+0x26>
  801793:	3a 0a                	cmp    (%edx),%cl
  801795:	74 eb                	je     801782 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801797:	0f b6 00             	movzbl (%eax),%eax
  80179a:	0f b6 12             	movzbl (%edx),%edx
  80179d:	29 d0                	sub    %edx,%eax
  80179f:	eb 05                	jmp    8017a6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017a1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017a6:	5b                   	pop    %ebx
  8017a7:	5d                   	pop    %ebp
  8017a8:	c3                   	ret    

008017a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017b3:	eb 07                	jmp    8017bc <strchr+0x13>
		if (*s == c)
  8017b5:	38 ca                	cmp    %cl,%dl
  8017b7:	74 0f                	je     8017c8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017b9:	83 c0 01             	add    $0x1,%eax
  8017bc:	0f b6 10             	movzbl (%eax),%edx
  8017bf:	84 d2                	test   %dl,%dl
  8017c1:	75 f2                	jne    8017b5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c8:	5d                   	pop    %ebp
  8017c9:	c3                   	ret    

008017ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017d4:	eb 03                	jmp    8017d9 <strfind+0xf>
  8017d6:	83 c0 01             	add    $0x1,%eax
  8017d9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017dc:	38 ca                	cmp    %cl,%dl
  8017de:	74 04                	je     8017e4 <strfind+0x1a>
  8017e0:	84 d2                	test   %dl,%dl
  8017e2:	75 f2                	jne    8017d6 <strfind+0xc>
			break;
	return (char *) s;
}
  8017e4:	5d                   	pop    %ebp
  8017e5:	c3                   	ret    

008017e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	57                   	push   %edi
  8017ea:	56                   	push   %esi
  8017eb:	53                   	push   %ebx
  8017ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017f2:	85 c9                	test   %ecx,%ecx
  8017f4:	74 36                	je     80182c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017f6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017fc:	75 28                	jne    801826 <memset+0x40>
  8017fe:	f6 c1 03             	test   $0x3,%cl
  801801:	75 23                	jne    801826 <memset+0x40>
		c &= 0xFF;
  801803:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801807:	89 d3                	mov    %edx,%ebx
  801809:	c1 e3 08             	shl    $0x8,%ebx
  80180c:	89 d6                	mov    %edx,%esi
  80180e:	c1 e6 18             	shl    $0x18,%esi
  801811:	89 d0                	mov    %edx,%eax
  801813:	c1 e0 10             	shl    $0x10,%eax
  801816:	09 f0                	or     %esi,%eax
  801818:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80181a:	89 d8                	mov    %ebx,%eax
  80181c:	09 d0                	or     %edx,%eax
  80181e:	c1 e9 02             	shr    $0x2,%ecx
  801821:	fc                   	cld    
  801822:	f3 ab                	rep stos %eax,%es:(%edi)
  801824:	eb 06                	jmp    80182c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801826:	8b 45 0c             	mov    0xc(%ebp),%eax
  801829:	fc                   	cld    
  80182a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80182c:	89 f8                	mov    %edi,%eax
  80182e:	5b                   	pop    %ebx
  80182f:	5e                   	pop    %esi
  801830:	5f                   	pop    %edi
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	57                   	push   %edi
  801837:	56                   	push   %esi
  801838:	8b 45 08             	mov    0x8(%ebp),%eax
  80183b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80183e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801841:	39 c6                	cmp    %eax,%esi
  801843:	73 35                	jae    80187a <memmove+0x47>
  801845:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801848:	39 d0                	cmp    %edx,%eax
  80184a:	73 2e                	jae    80187a <memmove+0x47>
		s += n;
		d += n;
  80184c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80184f:	89 d6                	mov    %edx,%esi
  801851:	09 fe                	or     %edi,%esi
  801853:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801859:	75 13                	jne    80186e <memmove+0x3b>
  80185b:	f6 c1 03             	test   $0x3,%cl
  80185e:	75 0e                	jne    80186e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801860:	83 ef 04             	sub    $0x4,%edi
  801863:	8d 72 fc             	lea    -0x4(%edx),%esi
  801866:	c1 e9 02             	shr    $0x2,%ecx
  801869:	fd                   	std    
  80186a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80186c:	eb 09                	jmp    801877 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80186e:	83 ef 01             	sub    $0x1,%edi
  801871:	8d 72 ff             	lea    -0x1(%edx),%esi
  801874:	fd                   	std    
  801875:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801877:	fc                   	cld    
  801878:	eb 1d                	jmp    801897 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80187a:	89 f2                	mov    %esi,%edx
  80187c:	09 c2                	or     %eax,%edx
  80187e:	f6 c2 03             	test   $0x3,%dl
  801881:	75 0f                	jne    801892 <memmove+0x5f>
  801883:	f6 c1 03             	test   $0x3,%cl
  801886:	75 0a                	jne    801892 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801888:	c1 e9 02             	shr    $0x2,%ecx
  80188b:	89 c7                	mov    %eax,%edi
  80188d:	fc                   	cld    
  80188e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801890:	eb 05                	jmp    801897 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801892:	89 c7                	mov    %eax,%edi
  801894:	fc                   	cld    
  801895:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801897:	5e                   	pop    %esi
  801898:	5f                   	pop    %edi
  801899:	5d                   	pop    %ebp
  80189a:	c3                   	ret    

0080189b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80189e:	ff 75 10             	pushl  0x10(%ebp)
  8018a1:	ff 75 0c             	pushl  0xc(%ebp)
  8018a4:	ff 75 08             	pushl  0x8(%ebp)
  8018a7:	e8 87 ff ff ff       	call   801833 <memmove>
}
  8018ac:	c9                   	leave  
  8018ad:	c3                   	ret    

008018ae <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	56                   	push   %esi
  8018b2:	53                   	push   %ebx
  8018b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b9:	89 c6                	mov    %eax,%esi
  8018bb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018be:	eb 1a                	jmp    8018da <memcmp+0x2c>
		if (*s1 != *s2)
  8018c0:	0f b6 08             	movzbl (%eax),%ecx
  8018c3:	0f b6 1a             	movzbl (%edx),%ebx
  8018c6:	38 d9                	cmp    %bl,%cl
  8018c8:	74 0a                	je     8018d4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018ca:	0f b6 c1             	movzbl %cl,%eax
  8018cd:	0f b6 db             	movzbl %bl,%ebx
  8018d0:	29 d8                	sub    %ebx,%eax
  8018d2:	eb 0f                	jmp    8018e3 <memcmp+0x35>
		s1++, s2++;
  8018d4:	83 c0 01             	add    $0x1,%eax
  8018d7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018da:	39 f0                	cmp    %esi,%eax
  8018dc:	75 e2                	jne    8018c0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e3:	5b                   	pop    %ebx
  8018e4:	5e                   	pop    %esi
  8018e5:	5d                   	pop    %ebp
  8018e6:	c3                   	ret    

008018e7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	53                   	push   %ebx
  8018eb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018ee:	89 c1                	mov    %eax,%ecx
  8018f0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018f3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018f7:	eb 0a                	jmp    801903 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018f9:	0f b6 10             	movzbl (%eax),%edx
  8018fc:	39 da                	cmp    %ebx,%edx
  8018fe:	74 07                	je     801907 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801900:	83 c0 01             	add    $0x1,%eax
  801903:	39 c8                	cmp    %ecx,%eax
  801905:	72 f2                	jb     8018f9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801907:	5b                   	pop    %ebx
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	57                   	push   %edi
  80190e:	56                   	push   %esi
  80190f:	53                   	push   %ebx
  801910:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801913:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801916:	eb 03                	jmp    80191b <strtol+0x11>
		s++;
  801918:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80191b:	0f b6 01             	movzbl (%ecx),%eax
  80191e:	3c 20                	cmp    $0x20,%al
  801920:	74 f6                	je     801918 <strtol+0xe>
  801922:	3c 09                	cmp    $0x9,%al
  801924:	74 f2                	je     801918 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801926:	3c 2b                	cmp    $0x2b,%al
  801928:	75 0a                	jne    801934 <strtol+0x2a>
		s++;
  80192a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80192d:	bf 00 00 00 00       	mov    $0x0,%edi
  801932:	eb 11                	jmp    801945 <strtol+0x3b>
  801934:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801939:	3c 2d                	cmp    $0x2d,%al
  80193b:	75 08                	jne    801945 <strtol+0x3b>
		s++, neg = 1;
  80193d:	83 c1 01             	add    $0x1,%ecx
  801940:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801945:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80194b:	75 15                	jne    801962 <strtol+0x58>
  80194d:	80 39 30             	cmpb   $0x30,(%ecx)
  801950:	75 10                	jne    801962 <strtol+0x58>
  801952:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801956:	75 7c                	jne    8019d4 <strtol+0xca>
		s += 2, base = 16;
  801958:	83 c1 02             	add    $0x2,%ecx
  80195b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801960:	eb 16                	jmp    801978 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801962:	85 db                	test   %ebx,%ebx
  801964:	75 12                	jne    801978 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801966:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80196b:	80 39 30             	cmpb   $0x30,(%ecx)
  80196e:	75 08                	jne    801978 <strtol+0x6e>
		s++, base = 8;
  801970:	83 c1 01             	add    $0x1,%ecx
  801973:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801978:	b8 00 00 00 00       	mov    $0x0,%eax
  80197d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801980:	0f b6 11             	movzbl (%ecx),%edx
  801983:	8d 72 d0             	lea    -0x30(%edx),%esi
  801986:	89 f3                	mov    %esi,%ebx
  801988:	80 fb 09             	cmp    $0x9,%bl
  80198b:	77 08                	ja     801995 <strtol+0x8b>
			dig = *s - '0';
  80198d:	0f be d2             	movsbl %dl,%edx
  801990:	83 ea 30             	sub    $0x30,%edx
  801993:	eb 22                	jmp    8019b7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801995:	8d 72 9f             	lea    -0x61(%edx),%esi
  801998:	89 f3                	mov    %esi,%ebx
  80199a:	80 fb 19             	cmp    $0x19,%bl
  80199d:	77 08                	ja     8019a7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80199f:	0f be d2             	movsbl %dl,%edx
  8019a2:	83 ea 57             	sub    $0x57,%edx
  8019a5:	eb 10                	jmp    8019b7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019a7:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019aa:	89 f3                	mov    %esi,%ebx
  8019ac:	80 fb 19             	cmp    $0x19,%bl
  8019af:	77 16                	ja     8019c7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019b1:	0f be d2             	movsbl %dl,%edx
  8019b4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019b7:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019ba:	7d 0b                	jge    8019c7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019bc:	83 c1 01             	add    $0x1,%ecx
  8019bf:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019c3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019c5:	eb b9                	jmp    801980 <strtol+0x76>

	if (endptr)
  8019c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019cb:	74 0d                	je     8019da <strtol+0xd0>
		*endptr = (char *) s;
  8019cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019d0:	89 0e                	mov    %ecx,(%esi)
  8019d2:	eb 06                	jmp    8019da <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019d4:	85 db                	test   %ebx,%ebx
  8019d6:	74 98                	je     801970 <strtol+0x66>
  8019d8:	eb 9e                	jmp    801978 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019da:	89 c2                	mov    %eax,%edx
  8019dc:	f7 da                	neg    %edx
  8019de:	85 ff                	test   %edi,%edi
  8019e0:	0f 45 c2             	cmovne %edx,%eax
}
  8019e3:	5b                   	pop    %ebx
  8019e4:	5e                   	pop    %esi
  8019e5:	5f                   	pop    %edi
  8019e6:	5d                   	pop    %ebp
  8019e7:	c3                   	ret    

008019e8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8019ee:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8019f5:	75 2e                	jne    801a25 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8019f7:	e8 36 e7 ff ff       	call   800132 <sys_getenvid>
  8019fc:	83 ec 04             	sub    $0x4,%esp
  8019ff:	68 07 0e 00 00       	push   $0xe07
  801a04:	68 00 f0 bf ee       	push   $0xeebff000
  801a09:	50                   	push   %eax
  801a0a:	e8 61 e7 ff ff       	call   800170 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801a0f:	e8 1e e7 ff ff       	call   800132 <sys_getenvid>
  801a14:	83 c4 08             	add    $0x8,%esp
  801a17:	68 61 03 80 00       	push   $0x800361
  801a1c:	50                   	push   %eax
  801a1d:	e8 99 e8 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801a22:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a25:	8b 45 08             	mov    0x8(%ebp),%eax
  801a28:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	56                   	push   %esi
  801a33:	53                   	push   %ebx
  801a34:	8b 75 08             	mov    0x8(%ebp),%esi
  801a37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801a3d:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801a3f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a44:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801a47:	83 ec 0c             	sub    $0xc,%esp
  801a4a:	50                   	push   %eax
  801a4b:	e8 d0 e8 ff ff       	call   800320 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	85 f6                	test   %esi,%esi
  801a55:	74 14                	je     801a6b <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801a57:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 09                	js     801a69 <ipc_recv+0x3a>
  801a60:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a66:	8b 52 74             	mov    0x74(%edx),%edx
  801a69:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a6b:	85 db                	test   %ebx,%ebx
  801a6d:	74 14                	je     801a83 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a74:	85 c0                	test   %eax,%eax
  801a76:	78 09                	js     801a81 <ipc_recv+0x52>
  801a78:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a7e:	8b 52 78             	mov    0x78(%edx),%edx
  801a81:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 08                	js     801a8f <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a87:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5e                   	pop    %esi
  801a94:	5d                   	pop    %ebp
  801a95:	c3                   	ret    

00801a96 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	57                   	push   %edi
  801a9a:	56                   	push   %esi
  801a9b:	53                   	push   %ebx
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aa5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801aa8:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801aaa:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801aaf:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ab2:	ff 75 14             	pushl  0x14(%ebp)
  801ab5:	53                   	push   %ebx
  801ab6:	56                   	push   %esi
  801ab7:	57                   	push   %edi
  801ab8:	e8 40 e8 ff ff       	call   8002fd <sys_ipc_try_send>

		if (err < 0) {
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	79 1e                	jns    801ae2 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801ac4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ac7:	75 07                	jne    801ad0 <ipc_send+0x3a>
				sys_yield();
  801ac9:	e8 83 e6 ff ff       	call   800151 <sys_yield>
  801ace:	eb e2                	jmp    801ab2 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801ad0:	50                   	push   %eax
  801ad1:	68 60 22 80 00       	push   $0x802260
  801ad6:	6a 49                	push   $0x49
  801ad8:	68 6d 22 80 00       	push   $0x80226d
  801add:	e8 61 f5 ff ff       	call   801043 <_panic>
		}

	} while (err < 0);

}
  801ae2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae5:	5b                   	pop    %ebx
  801ae6:	5e                   	pop    %esi
  801ae7:	5f                   	pop    %edi
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801af0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801af5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801af8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801afe:	8b 52 50             	mov    0x50(%edx),%edx
  801b01:	39 ca                	cmp    %ecx,%edx
  801b03:	75 0d                	jne    801b12 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b05:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b08:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b0d:	8b 40 48             	mov    0x48(%eax),%eax
  801b10:	eb 0f                	jmp    801b21 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b12:	83 c0 01             	add    $0x1,%eax
  801b15:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b1a:	75 d9                	jne    801af5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    

00801b23 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b29:	89 d0                	mov    %edx,%eax
  801b2b:	c1 e8 16             	shr    $0x16,%eax
  801b2e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b35:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b3a:	f6 c1 01             	test   $0x1,%cl
  801b3d:	74 1d                	je     801b5c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b3f:	c1 ea 0c             	shr    $0xc,%edx
  801b42:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b49:	f6 c2 01             	test   $0x1,%dl
  801b4c:	74 0e                	je     801b5c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b4e:	c1 ea 0c             	shr    $0xc,%edx
  801b51:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b58:	ef 
  801b59:	0f b7 c0             	movzwl %ax,%eax
}
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    
  801b5e:	66 90                	xchg   %ax,%ax

00801b60 <__udivdi3>:
  801b60:	55                   	push   %ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 1c             	sub    $0x1c,%esp
  801b67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b77:	85 f6                	test   %esi,%esi
  801b79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b7d:	89 ca                	mov    %ecx,%edx
  801b7f:	89 f8                	mov    %edi,%eax
  801b81:	75 3d                	jne    801bc0 <__udivdi3+0x60>
  801b83:	39 cf                	cmp    %ecx,%edi
  801b85:	0f 87 c5 00 00 00    	ja     801c50 <__udivdi3+0xf0>
  801b8b:	85 ff                	test   %edi,%edi
  801b8d:	89 fd                	mov    %edi,%ebp
  801b8f:	75 0b                	jne    801b9c <__udivdi3+0x3c>
  801b91:	b8 01 00 00 00       	mov    $0x1,%eax
  801b96:	31 d2                	xor    %edx,%edx
  801b98:	f7 f7                	div    %edi
  801b9a:	89 c5                	mov    %eax,%ebp
  801b9c:	89 c8                	mov    %ecx,%eax
  801b9e:	31 d2                	xor    %edx,%edx
  801ba0:	f7 f5                	div    %ebp
  801ba2:	89 c1                	mov    %eax,%ecx
  801ba4:	89 d8                	mov    %ebx,%eax
  801ba6:	89 cf                	mov    %ecx,%edi
  801ba8:	f7 f5                	div    %ebp
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	89 d8                	mov    %ebx,%eax
  801bae:	89 fa                	mov    %edi,%edx
  801bb0:	83 c4 1c             	add    $0x1c,%esp
  801bb3:	5b                   	pop    %ebx
  801bb4:	5e                   	pop    %esi
  801bb5:	5f                   	pop    %edi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    
  801bb8:	90                   	nop
  801bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bc0:	39 ce                	cmp    %ecx,%esi
  801bc2:	77 74                	ja     801c38 <__udivdi3+0xd8>
  801bc4:	0f bd fe             	bsr    %esi,%edi
  801bc7:	83 f7 1f             	xor    $0x1f,%edi
  801bca:	0f 84 98 00 00 00    	je     801c68 <__udivdi3+0x108>
  801bd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	89 c5                	mov    %eax,%ebp
  801bd9:	29 fb                	sub    %edi,%ebx
  801bdb:	d3 e6                	shl    %cl,%esi
  801bdd:	89 d9                	mov    %ebx,%ecx
  801bdf:	d3 ed                	shr    %cl,%ebp
  801be1:	89 f9                	mov    %edi,%ecx
  801be3:	d3 e0                	shl    %cl,%eax
  801be5:	09 ee                	or     %ebp,%esi
  801be7:	89 d9                	mov    %ebx,%ecx
  801be9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bed:	89 d5                	mov    %edx,%ebp
  801bef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bf3:	d3 ed                	shr    %cl,%ebp
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e2                	shl    %cl,%edx
  801bf9:	89 d9                	mov    %ebx,%ecx
  801bfb:	d3 e8                	shr    %cl,%eax
  801bfd:	09 c2                	or     %eax,%edx
  801bff:	89 d0                	mov    %edx,%eax
  801c01:	89 ea                	mov    %ebp,%edx
  801c03:	f7 f6                	div    %esi
  801c05:	89 d5                	mov    %edx,%ebp
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	f7 64 24 0c          	mull   0xc(%esp)
  801c0d:	39 d5                	cmp    %edx,%ebp
  801c0f:	72 10                	jb     801c21 <__udivdi3+0xc1>
  801c11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e6                	shl    %cl,%esi
  801c19:	39 c6                	cmp    %eax,%esi
  801c1b:	73 07                	jae    801c24 <__udivdi3+0xc4>
  801c1d:	39 d5                	cmp    %edx,%ebp
  801c1f:	75 03                	jne    801c24 <__udivdi3+0xc4>
  801c21:	83 eb 01             	sub    $0x1,%ebx
  801c24:	31 ff                	xor    %edi,%edi
  801c26:	89 d8                	mov    %ebx,%eax
  801c28:	89 fa                	mov    %edi,%edx
  801c2a:	83 c4 1c             	add    $0x1c,%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5f                   	pop    %edi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    
  801c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c38:	31 ff                	xor    %edi,%edi
  801c3a:	31 db                	xor    %ebx,%ebx
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	89 fa                	mov    %edi,%edx
  801c40:	83 c4 1c             	add    $0x1c,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    
  801c48:	90                   	nop
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	89 d8                	mov    %ebx,%eax
  801c52:	f7 f7                	div    %edi
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	89 d8                	mov    %ebx,%eax
  801c5a:	89 fa                	mov    %edi,%edx
  801c5c:	83 c4 1c             	add    $0x1c,%esp
  801c5f:	5b                   	pop    %ebx
  801c60:	5e                   	pop    %esi
  801c61:	5f                   	pop    %edi
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    
  801c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c68:	39 ce                	cmp    %ecx,%esi
  801c6a:	72 0c                	jb     801c78 <__udivdi3+0x118>
  801c6c:	31 db                	xor    %ebx,%ebx
  801c6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c72:	0f 87 34 ff ff ff    	ja     801bac <__udivdi3+0x4c>
  801c78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c7d:	e9 2a ff ff ff       	jmp    801bac <__udivdi3+0x4c>
  801c82:	66 90                	xchg   %ax,%ax
  801c84:	66 90                	xchg   %ax,%ax
  801c86:	66 90                	xchg   %ax,%ax
  801c88:	66 90                	xchg   %ax,%ax
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__umoddi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 d2                	test   %edx,%edx
  801ca9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cb1:	89 f3                	mov    %esi,%ebx
  801cb3:	89 3c 24             	mov    %edi,(%esp)
  801cb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cba:	75 1c                	jne    801cd8 <__umoddi3+0x48>
  801cbc:	39 f7                	cmp    %esi,%edi
  801cbe:	76 50                	jbe    801d10 <__umoddi3+0x80>
  801cc0:	89 c8                	mov    %ecx,%eax
  801cc2:	89 f2                	mov    %esi,%edx
  801cc4:	f7 f7                	div    %edi
  801cc6:	89 d0                	mov    %edx,%eax
  801cc8:	31 d2                	xor    %edx,%edx
  801cca:	83 c4 1c             	add    $0x1c,%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    
  801cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	89 d0                	mov    %edx,%eax
  801cdc:	77 52                	ja     801d30 <__umoddi3+0xa0>
  801cde:	0f bd ea             	bsr    %edx,%ebp
  801ce1:	83 f5 1f             	xor    $0x1f,%ebp
  801ce4:	75 5a                	jne    801d40 <__umoddi3+0xb0>
  801ce6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cea:	0f 82 e0 00 00 00    	jb     801dd0 <__umoddi3+0x140>
  801cf0:	39 0c 24             	cmp    %ecx,(%esp)
  801cf3:	0f 86 d7 00 00 00    	jbe    801dd0 <__umoddi3+0x140>
  801cf9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d01:	83 c4 1c             	add    $0x1c,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	85 ff                	test   %edi,%edi
  801d12:	89 fd                	mov    %edi,%ebp
  801d14:	75 0b                	jne    801d21 <__umoddi3+0x91>
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	f7 f7                	div    %edi
  801d1f:	89 c5                	mov    %eax,%ebp
  801d21:	89 f0                	mov    %esi,%eax
  801d23:	31 d2                	xor    %edx,%edx
  801d25:	f7 f5                	div    %ebp
  801d27:	89 c8                	mov    %ecx,%eax
  801d29:	f7 f5                	div    %ebp
  801d2b:	89 d0                	mov    %edx,%eax
  801d2d:	eb 99                	jmp    801cc8 <__umoddi3+0x38>
  801d2f:	90                   	nop
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	83 c4 1c             	add    $0x1c,%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    
  801d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d40:	8b 34 24             	mov    (%esp),%esi
  801d43:	bf 20 00 00 00       	mov    $0x20,%edi
  801d48:	89 e9                	mov    %ebp,%ecx
  801d4a:	29 ef                	sub    %ebp,%edi
  801d4c:	d3 e0                	shl    %cl,%eax
  801d4e:	89 f9                	mov    %edi,%ecx
  801d50:	89 f2                	mov    %esi,%edx
  801d52:	d3 ea                	shr    %cl,%edx
  801d54:	89 e9                	mov    %ebp,%ecx
  801d56:	09 c2                	or     %eax,%edx
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	89 14 24             	mov    %edx,(%esp)
  801d5d:	89 f2                	mov    %esi,%edx
  801d5f:	d3 e2                	shl    %cl,%edx
  801d61:	89 f9                	mov    %edi,%ecx
  801d63:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d6b:	d3 e8                	shr    %cl,%eax
  801d6d:	89 e9                	mov    %ebp,%ecx
  801d6f:	89 c6                	mov    %eax,%esi
  801d71:	d3 e3                	shl    %cl,%ebx
  801d73:	89 f9                	mov    %edi,%ecx
  801d75:	89 d0                	mov    %edx,%eax
  801d77:	d3 e8                	shr    %cl,%eax
  801d79:	89 e9                	mov    %ebp,%ecx
  801d7b:	09 d8                	or     %ebx,%eax
  801d7d:	89 d3                	mov    %edx,%ebx
  801d7f:	89 f2                	mov    %esi,%edx
  801d81:	f7 34 24             	divl   (%esp)
  801d84:	89 d6                	mov    %edx,%esi
  801d86:	d3 e3                	shl    %cl,%ebx
  801d88:	f7 64 24 04          	mull   0x4(%esp)
  801d8c:	39 d6                	cmp    %edx,%esi
  801d8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d92:	89 d1                	mov    %edx,%ecx
  801d94:	89 c3                	mov    %eax,%ebx
  801d96:	72 08                	jb     801da0 <__umoddi3+0x110>
  801d98:	75 11                	jne    801dab <__umoddi3+0x11b>
  801d9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d9e:	73 0b                	jae    801dab <__umoddi3+0x11b>
  801da0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801da4:	1b 14 24             	sbb    (%esp),%edx
  801da7:	89 d1                	mov    %edx,%ecx
  801da9:	89 c3                	mov    %eax,%ebx
  801dab:	8b 54 24 08          	mov    0x8(%esp),%edx
  801daf:	29 da                	sub    %ebx,%edx
  801db1:	19 ce                	sbb    %ecx,%esi
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	89 f0                	mov    %esi,%eax
  801db7:	d3 e0                	shl    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	d3 ea                	shr    %cl,%edx
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	d3 ee                	shr    %cl,%esi
  801dc1:	09 d0                	or     %edx,%eax
  801dc3:	89 f2                	mov    %esi,%edx
  801dc5:	83 c4 1c             	add    $0x1c,%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    
  801dcd:	8d 76 00             	lea    0x0(%esi),%esi
  801dd0:	29 f9                	sub    %edi,%ecx
  801dd2:	19 d6                	sbb    %edx,%esi
  801dd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ddc:	e9 18 ff ff ff       	jmp    801cf9 <__umoddi3+0x69>
