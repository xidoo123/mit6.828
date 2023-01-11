
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
  800039:	68 04 04 80 00       	push   $0x800404
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
  800071:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8000a0:	e8 4e 05 00 00       	call   8005f3 <close_all>
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
  800119:	68 2a 23 80 00       	push   $0x80232a
  80011e:	6a 23                	push   $0x23
  800120:	68 47 23 80 00       	push   $0x802347
  800125:	e8 42 14 00 00       	call   80156c <_panic>

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
  80019a:	68 2a 23 80 00       	push   $0x80232a
  80019f:	6a 23                	push   $0x23
  8001a1:	68 47 23 80 00       	push   $0x802347
  8001a6:	e8 c1 13 00 00       	call   80156c <_panic>

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
  8001dc:	68 2a 23 80 00       	push   $0x80232a
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 47 23 80 00       	push   $0x802347
  8001e8:	e8 7f 13 00 00       	call   80156c <_panic>

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
  80021e:	68 2a 23 80 00       	push   $0x80232a
  800223:	6a 23                	push   $0x23
  800225:	68 47 23 80 00       	push   $0x802347
  80022a:	e8 3d 13 00 00       	call   80156c <_panic>

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
  800260:	68 2a 23 80 00       	push   $0x80232a
  800265:	6a 23                	push   $0x23
  800267:	68 47 23 80 00       	push   $0x802347
  80026c:	e8 fb 12 00 00       	call   80156c <_panic>

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
  8002a2:	68 2a 23 80 00       	push   $0x80232a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 47 23 80 00       	push   $0x802347
  8002ae:	e8 b9 12 00 00       	call   80156c <_panic>

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
  8002e4:	68 2a 23 80 00       	push   $0x80232a
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 47 23 80 00       	push   $0x802347
  8002f0:	e8 77 12 00 00       	call   80156c <_panic>

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
  800348:	68 2a 23 80 00       	push   $0x80232a
  80034d:	6a 23                	push   $0x23
  80034f:	68 47 23 80 00       	push   $0x802347
  800354:	e8 13 12 00 00       	call   80156c <_panic>

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

00800361 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	57                   	push   %edi
  800365:	56                   	push   %esi
  800366:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800367:	ba 00 00 00 00       	mov    $0x0,%edx
  80036c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800371:	89 d1                	mov    %edx,%ecx
  800373:	89 d3                	mov    %edx,%ebx
  800375:	89 d7                	mov    %edx,%edi
  800377:	89 d6                	mov    %edx,%esi
  800379:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5f                   	pop    %edi
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	57                   	push   %edi
  800384:	56                   	push   %esi
  800385:	53                   	push   %ebx
  800386:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800389:	bb 00 00 00 00       	mov    $0x0,%ebx
  80038e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800393:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800396:	8b 55 08             	mov    0x8(%ebp),%edx
  800399:	89 df                	mov    %ebx,%edi
  80039b:	89 de                	mov    %ebx,%esi
  80039d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80039f:	85 c0                	test   %eax,%eax
  8003a1:	7e 17                	jle    8003ba <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a3:	83 ec 0c             	sub    $0xc,%esp
  8003a6:	50                   	push   %eax
  8003a7:	6a 0f                	push   $0xf
  8003a9:	68 2a 23 80 00       	push   $0x80232a
  8003ae:	6a 23                	push   $0x23
  8003b0:	68 47 23 80 00       	push   $0x802347
  8003b5:	e8 b2 11 00 00       	call   80156c <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8003ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003bd:	5b                   	pop    %ebx
  8003be:	5e                   	pop    %esi
  8003bf:	5f                   	pop    %edi
  8003c0:	5d                   	pop    %ebp
  8003c1:	c3                   	ret    

008003c2 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
  8003c5:	57                   	push   %edi
  8003c6:	56                   	push   %esi
  8003c7:	53                   	push   %ebx
  8003c8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003d0:	b8 10 00 00 00       	mov    $0x10,%eax
  8003d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003db:	89 df                	mov    %ebx,%edi
  8003dd:	89 de                	mov    %ebx,%esi
  8003df:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	7e 17                	jle    8003fc <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003e5:	83 ec 0c             	sub    $0xc,%esp
  8003e8:	50                   	push   %eax
  8003e9:	6a 10                	push   $0x10
  8003eb:	68 2a 23 80 00       	push   $0x80232a
  8003f0:	6a 23                	push   $0x23
  8003f2:	68 47 23 80 00       	push   $0x802347
  8003f7:	e8 70 11 00 00       	call   80156c <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  8003fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ff:	5b                   	pop    %ebx
  800400:	5e                   	pop    %esi
  800401:	5f                   	pop    %edi
  800402:	5d                   	pop    %ebp
  800403:	c3                   	ret    

00800404 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800404:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800405:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80040a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80040c:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80040f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  800413:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  800417:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  80041a:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80041d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80041e:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  800421:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  800422:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  800423:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800427:	c3                   	ret    

00800428 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80042b:	8b 45 08             	mov    0x8(%ebp),%eax
  80042e:	05 00 00 00 30       	add    $0x30000000,%eax
  800433:	c1 e8 0c             	shr    $0xc,%eax
}
  800436:	5d                   	pop    %ebp
  800437:	c3                   	ret    

00800438 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80043b:	8b 45 08             	mov    0x8(%ebp),%eax
  80043e:	05 00 00 00 30       	add    $0x30000000,%eax
  800443:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800448:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800455:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80045a:	89 c2                	mov    %eax,%edx
  80045c:	c1 ea 16             	shr    $0x16,%edx
  80045f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800466:	f6 c2 01             	test   $0x1,%dl
  800469:	74 11                	je     80047c <fd_alloc+0x2d>
  80046b:	89 c2                	mov    %eax,%edx
  80046d:	c1 ea 0c             	shr    $0xc,%edx
  800470:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800477:	f6 c2 01             	test   $0x1,%dl
  80047a:	75 09                	jne    800485 <fd_alloc+0x36>
			*fd_store = fd;
  80047c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80047e:	b8 00 00 00 00       	mov    $0x0,%eax
  800483:	eb 17                	jmp    80049c <fd_alloc+0x4d>
  800485:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80048a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80048f:	75 c9                	jne    80045a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800491:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800497:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80049c:	5d                   	pop    %ebp
  80049d:	c3                   	ret    

0080049e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80049e:	55                   	push   %ebp
  80049f:	89 e5                	mov    %esp,%ebp
  8004a1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004a4:	83 f8 1f             	cmp    $0x1f,%eax
  8004a7:	77 36                	ja     8004df <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004a9:	c1 e0 0c             	shl    $0xc,%eax
  8004ac:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004b1:	89 c2                	mov    %eax,%edx
  8004b3:	c1 ea 16             	shr    $0x16,%edx
  8004b6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004bd:	f6 c2 01             	test   $0x1,%dl
  8004c0:	74 24                	je     8004e6 <fd_lookup+0x48>
  8004c2:	89 c2                	mov    %eax,%edx
  8004c4:	c1 ea 0c             	shr    $0xc,%edx
  8004c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004ce:	f6 c2 01             	test   $0x1,%dl
  8004d1:	74 1a                	je     8004ed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d6:	89 02                	mov    %eax,(%edx)
	return 0;
  8004d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dd:	eb 13                	jmp    8004f2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004e4:	eb 0c                	jmp    8004f2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004eb:	eb 05                	jmp    8004f2 <fd_lookup+0x54>
  8004ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004fd:	ba d4 23 80 00       	mov    $0x8023d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800502:	eb 13                	jmp    800517 <dev_lookup+0x23>
  800504:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800507:	39 08                	cmp    %ecx,(%eax)
  800509:	75 0c                	jne    800517 <dev_lookup+0x23>
			*dev = devtab[i];
  80050b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80050e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800510:	b8 00 00 00 00       	mov    $0x0,%eax
  800515:	eb 2e                	jmp    800545 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800517:	8b 02                	mov    (%edx),%eax
  800519:	85 c0                	test   %eax,%eax
  80051b:	75 e7                	jne    800504 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80051d:	a1 08 40 80 00       	mov    0x804008,%eax
  800522:	8b 40 48             	mov    0x48(%eax),%eax
  800525:	83 ec 04             	sub    $0x4,%esp
  800528:	51                   	push   %ecx
  800529:	50                   	push   %eax
  80052a:	68 58 23 80 00       	push   $0x802358
  80052f:	e8 11 11 00 00       	call   801645 <cprintf>
	*dev = 0;
  800534:	8b 45 0c             	mov    0xc(%ebp),%eax
  800537:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800545:	c9                   	leave  
  800546:	c3                   	ret    

00800547 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	56                   	push   %esi
  80054b:	53                   	push   %ebx
  80054c:	83 ec 10             	sub    $0x10,%esp
  80054f:	8b 75 08             	mov    0x8(%ebp),%esi
  800552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800555:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800558:	50                   	push   %eax
  800559:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80055f:	c1 e8 0c             	shr    $0xc,%eax
  800562:	50                   	push   %eax
  800563:	e8 36 ff ff ff       	call   80049e <fd_lookup>
  800568:	83 c4 08             	add    $0x8,%esp
  80056b:	85 c0                	test   %eax,%eax
  80056d:	78 05                	js     800574 <fd_close+0x2d>
	    || fd != fd2)
  80056f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800572:	74 0c                	je     800580 <fd_close+0x39>
		return (must_exist ? r : 0);
  800574:	84 db                	test   %bl,%bl
  800576:	ba 00 00 00 00       	mov    $0x0,%edx
  80057b:	0f 44 c2             	cmove  %edx,%eax
  80057e:	eb 41                	jmp    8005c1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800586:	50                   	push   %eax
  800587:	ff 36                	pushl  (%esi)
  800589:	e8 66 ff ff ff       	call   8004f4 <dev_lookup>
  80058e:	89 c3                	mov    %eax,%ebx
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	85 c0                	test   %eax,%eax
  800595:	78 1a                	js     8005b1 <fd_close+0x6a>
		if (dev->dev_close)
  800597:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80059a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80059d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	74 0b                	je     8005b1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005a6:	83 ec 0c             	sub    $0xc,%esp
  8005a9:	56                   	push   %esi
  8005aa:	ff d0                	call   *%eax
  8005ac:	89 c3                	mov    %eax,%ebx
  8005ae:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	56                   	push   %esi
  8005b5:	6a 00                	push   $0x0
  8005b7:	e8 39 fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  8005bc:	83 c4 10             	add    $0x10,%esp
  8005bf:	89 d8                	mov    %ebx,%eax
}
  8005c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005c4:	5b                   	pop    %ebx
  8005c5:	5e                   	pop    %esi
  8005c6:	5d                   	pop    %ebp
  8005c7:	c3                   	ret    

008005c8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005c8:	55                   	push   %ebp
  8005c9:	89 e5                	mov    %esp,%ebp
  8005cb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005d1:	50                   	push   %eax
  8005d2:	ff 75 08             	pushl  0x8(%ebp)
  8005d5:	e8 c4 fe ff ff       	call   80049e <fd_lookup>
  8005da:	83 c4 08             	add    $0x8,%esp
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	78 10                	js     8005f1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	6a 01                	push   $0x1
  8005e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8005e9:	e8 59 ff ff ff       	call   800547 <fd_close>
  8005ee:	83 c4 10             	add    $0x10,%esp
}
  8005f1:	c9                   	leave  
  8005f2:	c3                   	ret    

008005f3 <close_all>:

void
close_all(void)
{
  8005f3:	55                   	push   %ebp
  8005f4:	89 e5                	mov    %esp,%ebp
  8005f6:	53                   	push   %ebx
  8005f7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005fa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005ff:	83 ec 0c             	sub    $0xc,%esp
  800602:	53                   	push   %ebx
  800603:	e8 c0 ff ff ff       	call   8005c8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800608:	83 c3 01             	add    $0x1,%ebx
  80060b:	83 c4 10             	add    $0x10,%esp
  80060e:	83 fb 20             	cmp    $0x20,%ebx
  800611:	75 ec                	jne    8005ff <close_all+0xc>
		close(i);
}
  800613:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800616:	c9                   	leave  
  800617:	c3                   	ret    

00800618 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800618:	55                   	push   %ebp
  800619:	89 e5                	mov    %esp,%ebp
  80061b:	57                   	push   %edi
  80061c:	56                   	push   %esi
  80061d:	53                   	push   %ebx
  80061e:	83 ec 2c             	sub    $0x2c,%esp
  800621:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800624:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800627:	50                   	push   %eax
  800628:	ff 75 08             	pushl  0x8(%ebp)
  80062b:	e8 6e fe ff ff       	call   80049e <fd_lookup>
  800630:	83 c4 08             	add    $0x8,%esp
  800633:	85 c0                	test   %eax,%eax
  800635:	0f 88 c1 00 00 00    	js     8006fc <dup+0xe4>
		return r;
	close(newfdnum);
  80063b:	83 ec 0c             	sub    $0xc,%esp
  80063e:	56                   	push   %esi
  80063f:	e8 84 ff ff ff       	call   8005c8 <close>

	newfd = INDEX2FD(newfdnum);
  800644:	89 f3                	mov    %esi,%ebx
  800646:	c1 e3 0c             	shl    $0xc,%ebx
  800649:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80064f:	83 c4 04             	add    $0x4,%esp
  800652:	ff 75 e4             	pushl  -0x1c(%ebp)
  800655:	e8 de fd ff ff       	call   800438 <fd2data>
  80065a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80065c:	89 1c 24             	mov    %ebx,(%esp)
  80065f:	e8 d4 fd ff ff       	call   800438 <fd2data>
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80066a:	89 f8                	mov    %edi,%eax
  80066c:	c1 e8 16             	shr    $0x16,%eax
  80066f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800676:	a8 01                	test   $0x1,%al
  800678:	74 37                	je     8006b1 <dup+0x99>
  80067a:	89 f8                	mov    %edi,%eax
  80067c:	c1 e8 0c             	shr    $0xc,%eax
  80067f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800686:	f6 c2 01             	test   $0x1,%dl
  800689:	74 26                	je     8006b1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80068b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800692:	83 ec 0c             	sub    $0xc,%esp
  800695:	25 07 0e 00 00       	and    $0xe07,%eax
  80069a:	50                   	push   %eax
  80069b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80069e:	6a 00                	push   $0x0
  8006a0:	57                   	push   %edi
  8006a1:	6a 00                	push   $0x0
  8006a3:	e8 0b fb ff ff       	call   8001b3 <sys_page_map>
  8006a8:	89 c7                	mov    %eax,%edi
  8006aa:	83 c4 20             	add    $0x20,%esp
  8006ad:	85 c0                	test   %eax,%eax
  8006af:	78 2e                	js     8006df <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006b4:	89 d0                	mov    %edx,%eax
  8006b6:	c1 e8 0c             	shr    $0xc,%eax
  8006b9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006c0:	83 ec 0c             	sub    $0xc,%esp
  8006c3:	25 07 0e 00 00       	and    $0xe07,%eax
  8006c8:	50                   	push   %eax
  8006c9:	53                   	push   %ebx
  8006ca:	6a 00                	push   $0x0
  8006cc:	52                   	push   %edx
  8006cd:	6a 00                	push   $0x0
  8006cf:	e8 df fa ff ff       	call   8001b3 <sys_page_map>
  8006d4:	89 c7                	mov    %eax,%edi
  8006d6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006d9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006db:	85 ff                	test   %edi,%edi
  8006dd:	79 1d                	jns    8006fc <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	6a 00                	push   $0x0
  8006e5:	e8 0b fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006ea:	83 c4 08             	add    $0x8,%esp
  8006ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006f0:	6a 00                	push   $0x0
  8006f2:	e8 fe fa ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  8006f7:	83 c4 10             	add    $0x10,%esp
  8006fa:	89 f8                	mov    %edi,%eax
}
  8006fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ff:	5b                   	pop    %ebx
  800700:	5e                   	pop    %esi
  800701:	5f                   	pop    %edi
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	53                   	push   %ebx
  800708:	83 ec 14             	sub    $0x14,%esp
  80070b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800711:	50                   	push   %eax
  800712:	53                   	push   %ebx
  800713:	e8 86 fd ff ff       	call   80049e <fd_lookup>
  800718:	83 c4 08             	add    $0x8,%esp
  80071b:	89 c2                	mov    %eax,%edx
  80071d:	85 c0                	test   %eax,%eax
  80071f:	78 6d                	js     80078e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800727:	50                   	push   %eax
  800728:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072b:	ff 30                	pushl  (%eax)
  80072d:	e8 c2 fd ff ff       	call   8004f4 <dev_lookup>
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	85 c0                	test   %eax,%eax
  800737:	78 4c                	js     800785 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800739:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80073c:	8b 42 08             	mov    0x8(%edx),%eax
  80073f:	83 e0 03             	and    $0x3,%eax
  800742:	83 f8 01             	cmp    $0x1,%eax
  800745:	75 21                	jne    800768 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800747:	a1 08 40 80 00       	mov    0x804008,%eax
  80074c:	8b 40 48             	mov    0x48(%eax),%eax
  80074f:	83 ec 04             	sub    $0x4,%esp
  800752:	53                   	push   %ebx
  800753:	50                   	push   %eax
  800754:	68 99 23 80 00       	push   $0x802399
  800759:	e8 e7 0e 00 00       	call   801645 <cprintf>
		return -E_INVAL;
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800766:	eb 26                	jmp    80078e <read+0x8a>
	}
	if (!dev->dev_read)
  800768:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076b:	8b 40 08             	mov    0x8(%eax),%eax
  80076e:	85 c0                	test   %eax,%eax
  800770:	74 17                	je     800789 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800772:	83 ec 04             	sub    $0x4,%esp
  800775:	ff 75 10             	pushl  0x10(%ebp)
  800778:	ff 75 0c             	pushl  0xc(%ebp)
  80077b:	52                   	push   %edx
  80077c:	ff d0                	call   *%eax
  80077e:	89 c2                	mov    %eax,%edx
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	eb 09                	jmp    80078e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800785:	89 c2                	mov    %eax,%edx
  800787:	eb 05                	jmp    80078e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800789:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80078e:	89 d0                	mov    %edx,%eax
  800790:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800793:	c9                   	leave  
  800794:	c3                   	ret    

00800795 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	57                   	push   %edi
  800799:	56                   	push   %esi
  80079a:	53                   	push   %ebx
  80079b:	83 ec 0c             	sub    $0xc,%esp
  80079e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007a1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a9:	eb 21                	jmp    8007cc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007ab:	83 ec 04             	sub    $0x4,%esp
  8007ae:	89 f0                	mov    %esi,%eax
  8007b0:	29 d8                	sub    %ebx,%eax
  8007b2:	50                   	push   %eax
  8007b3:	89 d8                	mov    %ebx,%eax
  8007b5:	03 45 0c             	add    0xc(%ebp),%eax
  8007b8:	50                   	push   %eax
  8007b9:	57                   	push   %edi
  8007ba:	e8 45 ff ff ff       	call   800704 <read>
		if (m < 0)
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	85 c0                	test   %eax,%eax
  8007c4:	78 10                	js     8007d6 <readn+0x41>
			return m;
		if (m == 0)
  8007c6:	85 c0                	test   %eax,%eax
  8007c8:	74 0a                	je     8007d4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007ca:	01 c3                	add    %eax,%ebx
  8007cc:	39 f3                	cmp    %esi,%ebx
  8007ce:	72 db                	jb     8007ab <readn+0x16>
  8007d0:	89 d8                	mov    %ebx,%eax
  8007d2:	eb 02                	jmp    8007d6 <readn+0x41>
  8007d4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8007d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d9:	5b                   	pop    %ebx
  8007da:	5e                   	pop    %esi
  8007db:	5f                   	pop    %edi
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	53                   	push   %ebx
  8007e2:	83 ec 14             	sub    $0x14,%esp
  8007e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007eb:	50                   	push   %eax
  8007ec:	53                   	push   %ebx
  8007ed:	e8 ac fc ff ff       	call   80049e <fd_lookup>
  8007f2:	83 c4 08             	add    $0x8,%esp
  8007f5:	89 c2                	mov    %eax,%edx
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 68                	js     800863 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800801:	50                   	push   %eax
  800802:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800805:	ff 30                	pushl  (%eax)
  800807:	e8 e8 fc ff ff       	call   8004f4 <dev_lookup>
  80080c:	83 c4 10             	add    $0x10,%esp
  80080f:	85 c0                	test   %eax,%eax
  800811:	78 47                	js     80085a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800813:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800816:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80081a:	75 21                	jne    80083d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80081c:	a1 08 40 80 00       	mov    0x804008,%eax
  800821:	8b 40 48             	mov    0x48(%eax),%eax
  800824:	83 ec 04             	sub    $0x4,%esp
  800827:	53                   	push   %ebx
  800828:	50                   	push   %eax
  800829:	68 b5 23 80 00       	push   $0x8023b5
  80082e:	e8 12 0e 00 00       	call   801645 <cprintf>
		return -E_INVAL;
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083b:	eb 26                	jmp    800863 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80083d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800840:	8b 52 0c             	mov    0xc(%edx),%edx
  800843:	85 d2                	test   %edx,%edx
  800845:	74 17                	je     80085e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800847:	83 ec 04             	sub    $0x4,%esp
  80084a:	ff 75 10             	pushl  0x10(%ebp)
  80084d:	ff 75 0c             	pushl  0xc(%ebp)
  800850:	50                   	push   %eax
  800851:	ff d2                	call   *%edx
  800853:	89 c2                	mov    %eax,%edx
  800855:	83 c4 10             	add    $0x10,%esp
  800858:	eb 09                	jmp    800863 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085a:	89 c2                	mov    %eax,%edx
  80085c:	eb 05                	jmp    800863 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80085e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800863:	89 d0                	mov    %edx,%eax
  800865:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800868:	c9                   	leave  
  800869:	c3                   	ret    

0080086a <seek>:

int
seek(int fdnum, off_t offset)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800870:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 22 fc ff ff       	call   80049e <fd_lookup>
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	85 c0                	test   %eax,%eax
  800881:	78 0e                	js     800891 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800883:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
  800889:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800891:	c9                   	leave  
  800892:	c3                   	ret    

00800893 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	83 ec 14             	sub    $0x14,%esp
  80089a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80089d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a0:	50                   	push   %eax
  8008a1:	53                   	push   %ebx
  8008a2:	e8 f7 fb ff ff       	call   80049e <fd_lookup>
  8008a7:	83 c4 08             	add    $0x8,%esp
  8008aa:	89 c2                	mov    %eax,%edx
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	78 65                	js     800915 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b0:	83 ec 08             	sub    $0x8,%esp
  8008b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b6:	50                   	push   %eax
  8008b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ba:	ff 30                	pushl  (%eax)
  8008bc:	e8 33 fc ff ff       	call   8004f4 <dev_lookup>
  8008c1:	83 c4 10             	add    $0x10,%esp
  8008c4:	85 c0                	test   %eax,%eax
  8008c6:	78 44                	js     80090c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008cb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008cf:	75 21                	jne    8008f2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008d1:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008d6:	8b 40 48             	mov    0x48(%eax),%eax
  8008d9:	83 ec 04             	sub    $0x4,%esp
  8008dc:	53                   	push   %ebx
  8008dd:	50                   	push   %eax
  8008de:	68 78 23 80 00       	push   $0x802378
  8008e3:	e8 5d 0d 00 00       	call   801645 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008e8:	83 c4 10             	add    $0x10,%esp
  8008eb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008f0:	eb 23                	jmp    800915 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008f5:	8b 52 18             	mov    0x18(%edx),%edx
  8008f8:	85 d2                	test   %edx,%edx
  8008fa:	74 14                	je     800910 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	ff 75 0c             	pushl  0xc(%ebp)
  800902:	50                   	push   %eax
  800903:	ff d2                	call   *%edx
  800905:	89 c2                	mov    %eax,%edx
  800907:	83 c4 10             	add    $0x10,%esp
  80090a:	eb 09                	jmp    800915 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80090c:	89 c2                	mov    %eax,%edx
  80090e:	eb 05                	jmp    800915 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800910:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800915:	89 d0                	mov    %edx,%eax
  800917:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091a:	c9                   	leave  
  80091b:	c3                   	ret    

0080091c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	53                   	push   %ebx
  800920:	83 ec 14             	sub    $0x14,%esp
  800923:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800926:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800929:	50                   	push   %eax
  80092a:	ff 75 08             	pushl  0x8(%ebp)
  80092d:	e8 6c fb ff ff       	call   80049e <fd_lookup>
  800932:	83 c4 08             	add    $0x8,%esp
  800935:	89 c2                	mov    %eax,%edx
  800937:	85 c0                	test   %eax,%eax
  800939:	78 58                	js     800993 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80093b:	83 ec 08             	sub    $0x8,%esp
  80093e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800941:	50                   	push   %eax
  800942:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800945:	ff 30                	pushl  (%eax)
  800947:	e8 a8 fb ff ff       	call   8004f4 <dev_lookup>
  80094c:	83 c4 10             	add    $0x10,%esp
  80094f:	85 c0                	test   %eax,%eax
  800951:	78 37                	js     80098a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800953:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800956:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80095a:	74 32                	je     80098e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80095c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80095f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800966:	00 00 00 
	stat->st_isdir = 0;
  800969:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800970:	00 00 00 
	stat->st_dev = dev;
  800973:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800979:	83 ec 08             	sub    $0x8,%esp
  80097c:	53                   	push   %ebx
  80097d:	ff 75 f0             	pushl  -0x10(%ebp)
  800980:	ff 50 14             	call   *0x14(%eax)
  800983:	89 c2                	mov    %eax,%edx
  800985:	83 c4 10             	add    $0x10,%esp
  800988:	eb 09                	jmp    800993 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80098a:	89 c2                	mov    %eax,%edx
  80098c:	eb 05                	jmp    800993 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80098e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800993:	89 d0                	mov    %edx,%eax
  800995:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	56                   	push   %esi
  80099e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80099f:	83 ec 08             	sub    $0x8,%esp
  8009a2:	6a 00                	push   $0x0
  8009a4:	ff 75 08             	pushl  0x8(%ebp)
  8009a7:	e8 d6 01 00 00       	call   800b82 <open>
  8009ac:	89 c3                	mov    %eax,%ebx
  8009ae:	83 c4 10             	add    $0x10,%esp
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	78 1b                	js     8009d0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8009b5:	83 ec 08             	sub    $0x8,%esp
  8009b8:	ff 75 0c             	pushl  0xc(%ebp)
  8009bb:	50                   	push   %eax
  8009bc:	e8 5b ff ff ff       	call   80091c <fstat>
  8009c1:	89 c6                	mov    %eax,%esi
	close(fd);
  8009c3:	89 1c 24             	mov    %ebx,(%esp)
  8009c6:	e8 fd fb ff ff       	call   8005c8 <close>
	return r;
  8009cb:	83 c4 10             	add    $0x10,%esp
  8009ce:	89 f0                	mov    %esi,%eax
}
  8009d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009d3:	5b                   	pop    %ebx
  8009d4:	5e                   	pop    %esi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	56                   	push   %esi
  8009db:	53                   	push   %ebx
  8009dc:	89 c6                	mov    %eax,%esi
  8009de:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009e0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009e7:	75 12                	jne    8009fb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009e9:	83 ec 0c             	sub    $0xc,%esp
  8009ec:	6a 01                	push   $0x1
  8009ee:	e8 20 16 00 00       	call   802013 <ipc_find_env>
  8009f3:	a3 00 40 80 00       	mov    %eax,0x804000
  8009f8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009fb:	6a 07                	push   $0x7
  8009fd:	68 00 50 80 00       	push   $0x805000
  800a02:	56                   	push   %esi
  800a03:	ff 35 00 40 80 00    	pushl  0x804000
  800a09:	e8 b1 15 00 00       	call   801fbf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a0e:	83 c4 0c             	add    $0xc,%esp
  800a11:	6a 00                	push   $0x0
  800a13:	53                   	push   %ebx
  800a14:	6a 00                	push   $0x0
  800a16:	e8 3d 15 00 00       	call   801f58 <ipc_recv>
}
  800a1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a1e:	5b                   	pop    %ebx
  800a1f:	5e                   	pop    %esi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a36:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a40:	b8 02 00 00 00       	mov    $0x2,%eax
  800a45:	e8 8d ff ff ff       	call   8009d7 <fsipc>
}
  800a4a:	c9                   	leave  
  800a4b:	c3                   	ret    

00800a4c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	8b 40 0c             	mov    0xc(%eax),%eax
  800a58:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a62:	b8 06 00 00 00       	mov    $0x6,%eax
  800a67:	e8 6b ff ff ff       	call   8009d7 <fsipc>
}
  800a6c:	c9                   	leave  
  800a6d:	c3                   	ret    

00800a6e <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	53                   	push   %ebx
  800a72:	83 ec 04             	sub    $0x4,%esp
  800a75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a7e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a83:	ba 00 00 00 00       	mov    $0x0,%edx
  800a88:	b8 05 00 00 00       	mov    $0x5,%eax
  800a8d:	e8 45 ff ff ff       	call   8009d7 <fsipc>
  800a92:	85 c0                	test   %eax,%eax
  800a94:	78 2c                	js     800ac2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a96:	83 ec 08             	sub    $0x8,%esp
  800a99:	68 00 50 80 00       	push   $0x805000
  800a9e:	53                   	push   %ebx
  800a9f:	e8 26 11 00 00       	call   801bca <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800aa4:	a1 80 50 80 00       	mov    0x805080,%eax
  800aa9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800aaf:	a1 84 50 80 00       	mov    0x805084,%eax
  800ab4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800aba:	83 c4 10             	add    $0x10,%esp
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac5:	c9                   	leave  
  800ac6:	c3                   	ret    

00800ac7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	83 ec 0c             	sub    $0xc,%esp
  800acd:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	8b 52 0c             	mov    0xc(%edx),%edx
  800ad6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800adc:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800ae1:	50                   	push   %eax
  800ae2:	ff 75 0c             	pushl  0xc(%ebp)
  800ae5:	68 08 50 80 00       	push   $0x805008
  800aea:	e8 6d 12 00 00       	call   801d5c <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800aef:	ba 00 00 00 00       	mov    $0x0,%edx
  800af4:	b8 04 00 00 00       	mov    $0x4,%eax
  800af9:	e8 d9 fe ff ff       	call   8009d7 <fsipc>

}
  800afe:	c9                   	leave  
  800aff:	c3                   	ret    

00800b00 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 40 0c             	mov    0xc(%eax),%eax
  800b0e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b13:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b23:	e8 af fe ff ff       	call   8009d7 <fsipc>
  800b28:	89 c3                	mov    %eax,%ebx
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	78 4b                	js     800b79 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b2e:	39 c6                	cmp    %eax,%esi
  800b30:	73 16                	jae    800b48 <devfile_read+0x48>
  800b32:	68 e8 23 80 00       	push   $0x8023e8
  800b37:	68 ef 23 80 00       	push   $0x8023ef
  800b3c:	6a 7c                	push   $0x7c
  800b3e:	68 04 24 80 00       	push   $0x802404
  800b43:	e8 24 0a 00 00       	call   80156c <_panic>
	assert(r <= PGSIZE);
  800b48:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b4d:	7e 16                	jle    800b65 <devfile_read+0x65>
  800b4f:	68 0f 24 80 00       	push   $0x80240f
  800b54:	68 ef 23 80 00       	push   $0x8023ef
  800b59:	6a 7d                	push   $0x7d
  800b5b:	68 04 24 80 00       	push   $0x802404
  800b60:	e8 07 0a 00 00       	call   80156c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b65:	83 ec 04             	sub    $0x4,%esp
  800b68:	50                   	push   %eax
  800b69:	68 00 50 80 00       	push   $0x805000
  800b6e:	ff 75 0c             	pushl  0xc(%ebp)
  800b71:	e8 e6 11 00 00       	call   801d5c <memmove>
	return r;
  800b76:	83 c4 10             	add    $0x10,%esp
}
  800b79:	89 d8                	mov    %ebx,%eax
  800b7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	53                   	push   %ebx
  800b86:	83 ec 20             	sub    $0x20,%esp
  800b89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b8c:	53                   	push   %ebx
  800b8d:	e8 ff 0f 00 00       	call   801b91 <strlen>
  800b92:	83 c4 10             	add    $0x10,%esp
  800b95:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b9a:	7f 67                	jg     800c03 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b9c:	83 ec 0c             	sub    $0xc,%esp
  800b9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ba2:	50                   	push   %eax
  800ba3:	e8 a7 f8 ff ff       	call   80044f <fd_alloc>
  800ba8:	83 c4 10             	add    $0x10,%esp
		return r;
  800bab:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bad:	85 c0                	test   %eax,%eax
  800baf:	78 57                	js     800c08 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800bb1:	83 ec 08             	sub    $0x8,%esp
  800bb4:	53                   	push   %ebx
  800bb5:	68 00 50 80 00       	push   $0x805000
  800bba:	e8 0b 10 00 00       	call   801bca <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bca:	b8 01 00 00 00       	mov    $0x1,%eax
  800bcf:	e8 03 fe ff ff       	call   8009d7 <fsipc>
  800bd4:	89 c3                	mov    %eax,%ebx
  800bd6:	83 c4 10             	add    $0x10,%esp
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	79 14                	jns    800bf1 <open+0x6f>
		fd_close(fd, 0);
  800bdd:	83 ec 08             	sub    $0x8,%esp
  800be0:	6a 00                	push   $0x0
  800be2:	ff 75 f4             	pushl  -0xc(%ebp)
  800be5:	e8 5d f9 ff ff       	call   800547 <fd_close>
		return r;
  800bea:	83 c4 10             	add    $0x10,%esp
  800bed:	89 da                	mov    %ebx,%edx
  800bef:	eb 17                	jmp    800c08 <open+0x86>
	}

	return fd2num(fd);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	ff 75 f4             	pushl  -0xc(%ebp)
  800bf7:	e8 2c f8 ff ff       	call   800428 <fd2num>
  800bfc:	89 c2                	mov    %eax,%edx
  800bfe:	83 c4 10             	add    $0x10,%esp
  800c01:	eb 05                	jmp    800c08 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c03:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c08:	89 d0                	mov    %edx,%eax
  800c0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c0d:	c9                   	leave  
  800c0e:	c3                   	ret    

00800c0f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1a:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1f:	e8 b3 fd ff ff       	call   8009d7 <fsipc>
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c2c:	68 1b 24 80 00       	push   $0x80241b
  800c31:	ff 75 0c             	pushl  0xc(%ebp)
  800c34:	e8 91 0f 00 00       	call   801bca <strcpy>
	return 0;
}
  800c39:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	53                   	push   %ebx
  800c44:	83 ec 10             	sub    $0x10,%esp
  800c47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c4a:	53                   	push   %ebx
  800c4b:	e8 fc 13 00 00       	call   80204c <pageref>
  800c50:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c53:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c58:	83 f8 01             	cmp    $0x1,%eax
  800c5b:	75 10                	jne    800c6d <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	ff 73 0c             	pushl  0xc(%ebx)
  800c63:	e8 c0 02 00 00       	call   800f28 <nsipc_close>
  800c68:	89 c2                	mov    %eax,%edx
  800c6a:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c6d:	89 d0                	mov    %edx,%eax
  800c6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c72:	c9                   	leave  
  800c73:	c3                   	ret    

00800c74 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c7a:	6a 00                	push   $0x0
  800c7c:	ff 75 10             	pushl  0x10(%ebp)
  800c7f:	ff 75 0c             	pushl  0xc(%ebp)
  800c82:	8b 45 08             	mov    0x8(%ebp),%eax
  800c85:	ff 70 0c             	pushl  0xc(%eax)
  800c88:	e8 78 03 00 00       	call   801005 <nsipc_send>
}
  800c8d:	c9                   	leave  
  800c8e:	c3                   	ret    

00800c8f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c95:	6a 00                	push   $0x0
  800c97:	ff 75 10             	pushl  0x10(%ebp)
  800c9a:	ff 75 0c             	pushl  0xc(%ebp)
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca0:	ff 70 0c             	pushl  0xc(%eax)
  800ca3:	e8 f1 02 00 00       	call   800f99 <nsipc_recv>
}
  800ca8:	c9                   	leave  
  800ca9:	c3                   	ret    

00800caa <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800cb0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800cb3:	52                   	push   %edx
  800cb4:	50                   	push   %eax
  800cb5:	e8 e4 f7 ff ff       	call   80049e <fd_lookup>
  800cba:	83 c4 10             	add    $0x10,%esp
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	78 17                	js     800cd8 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc4:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800cca:	39 08                	cmp    %ecx,(%eax)
  800ccc:	75 05                	jne    800cd3 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800cce:	8b 40 0c             	mov    0xc(%eax),%eax
  800cd1:	eb 05                	jmp    800cd8 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800cd3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800cd8:	c9                   	leave  
  800cd9:	c3                   	ret    

00800cda <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 1c             	sub    $0x1c,%esp
  800ce2:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800ce4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ce7:	50                   	push   %eax
  800ce8:	e8 62 f7 ff ff       	call   80044f <fd_alloc>
  800ced:	89 c3                	mov    %eax,%ebx
  800cef:	83 c4 10             	add    $0x10,%esp
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	78 1b                	js     800d11 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cf6:	83 ec 04             	sub    $0x4,%esp
  800cf9:	68 07 04 00 00       	push   $0x407
  800cfe:	ff 75 f4             	pushl  -0xc(%ebp)
  800d01:	6a 00                	push   $0x0
  800d03:	e8 68 f4 ff ff       	call   800170 <sys_page_alloc>
  800d08:	89 c3                	mov    %eax,%ebx
  800d0a:	83 c4 10             	add    $0x10,%esp
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	79 10                	jns    800d21 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	56                   	push   %esi
  800d15:	e8 0e 02 00 00       	call   800f28 <nsipc_close>
		return r;
  800d1a:	83 c4 10             	add    $0x10,%esp
  800d1d:	89 d8                	mov    %ebx,%eax
  800d1f:	eb 24                	jmp    800d45 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d21:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d2a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d2f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800d36:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	50                   	push   %eax
  800d3d:	e8 e6 f6 ff ff       	call   800428 <fd2num>
  800d42:	83 c4 10             	add    $0x10,%esp
}
  800d45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	e8 50 ff ff ff       	call   800caa <fd2sockid>
		return r;
  800d5a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	78 1f                	js     800d7f <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d60:	83 ec 04             	sub    $0x4,%esp
  800d63:	ff 75 10             	pushl  0x10(%ebp)
  800d66:	ff 75 0c             	pushl  0xc(%ebp)
  800d69:	50                   	push   %eax
  800d6a:	e8 12 01 00 00       	call   800e81 <nsipc_accept>
  800d6f:	83 c4 10             	add    $0x10,%esp
		return r;
  800d72:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	78 07                	js     800d7f <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d78:	e8 5d ff ff ff       	call   800cda <alloc_sockfd>
  800d7d:	89 c1                	mov    %eax,%ecx
}
  800d7f:	89 c8                	mov    %ecx,%eax
  800d81:	c9                   	leave  
  800d82:	c3                   	ret    

00800d83 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	e8 19 ff ff ff       	call   800caa <fd2sockid>
  800d91:	85 c0                	test   %eax,%eax
  800d93:	78 12                	js     800da7 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d95:	83 ec 04             	sub    $0x4,%esp
  800d98:	ff 75 10             	pushl  0x10(%ebp)
  800d9b:	ff 75 0c             	pushl  0xc(%ebp)
  800d9e:	50                   	push   %eax
  800d9f:	e8 2d 01 00 00       	call   800ed1 <nsipc_bind>
  800da4:	83 c4 10             	add    $0x10,%esp
}
  800da7:	c9                   	leave  
  800da8:	c3                   	ret    

00800da9 <shutdown>:

int
shutdown(int s, int how)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
  800db2:	e8 f3 fe ff ff       	call   800caa <fd2sockid>
  800db7:	85 c0                	test   %eax,%eax
  800db9:	78 0f                	js     800dca <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800dbb:	83 ec 08             	sub    $0x8,%esp
  800dbe:	ff 75 0c             	pushl  0xc(%ebp)
  800dc1:	50                   	push   %eax
  800dc2:	e8 3f 01 00 00       	call   800f06 <nsipc_shutdown>
  800dc7:	83 c4 10             	add    $0x10,%esp
}
  800dca:	c9                   	leave  
  800dcb:	c3                   	ret    

00800dcc <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd5:	e8 d0 fe ff ff       	call   800caa <fd2sockid>
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	78 12                	js     800df0 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800dde:	83 ec 04             	sub    $0x4,%esp
  800de1:	ff 75 10             	pushl  0x10(%ebp)
  800de4:	ff 75 0c             	pushl  0xc(%ebp)
  800de7:	50                   	push   %eax
  800de8:	e8 55 01 00 00       	call   800f42 <nsipc_connect>
  800ded:	83 c4 10             	add    $0x10,%esp
}
  800df0:	c9                   	leave  
  800df1:	c3                   	ret    

00800df2 <listen>:

int
listen(int s, int backlog)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	e8 aa fe ff ff       	call   800caa <fd2sockid>
  800e00:	85 c0                	test   %eax,%eax
  800e02:	78 0f                	js     800e13 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800e04:	83 ec 08             	sub    $0x8,%esp
  800e07:	ff 75 0c             	pushl  0xc(%ebp)
  800e0a:	50                   	push   %eax
  800e0b:	e8 67 01 00 00       	call   800f77 <nsipc_listen>
  800e10:	83 c4 10             	add    $0x10,%esp
}
  800e13:	c9                   	leave  
  800e14:	c3                   	ret    

00800e15 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e1b:	ff 75 10             	pushl  0x10(%ebp)
  800e1e:	ff 75 0c             	pushl  0xc(%ebp)
  800e21:	ff 75 08             	pushl  0x8(%ebp)
  800e24:	e8 3a 02 00 00       	call   801063 <nsipc_socket>
  800e29:	83 c4 10             	add    $0x10,%esp
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	78 05                	js     800e35 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800e30:	e8 a5 fe ff ff       	call   800cda <alloc_sockfd>
}
  800e35:	c9                   	leave  
  800e36:	c3                   	ret    

00800e37 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	53                   	push   %ebx
  800e3b:	83 ec 04             	sub    $0x4,%esp
  800e3e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e40:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e47:	75 12                	jne    800e5b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e49:	83 ec 0c             	sub    $0xc,%esp
  800e4c:	6a 02                	push   $0x2
  800e4e:	e8 c0 11 00 00       	call   802013 <ipc_find_env>
  800e53:	a3 04 40 80 00       	mov    %eax,0x804004
  800e58:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e5b:	6a 07                	push   $0x7
  800e5d:	68 00 60 80 00       	push   $0x806000
  800e62:	53                   	push   %ebx
  800e63:	ff 35 04 40 80 00    	pushl  0x804004
  800e69:	e8 51 11 00 00       	call   801fbf <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e6e:	83 c4 0c             	add    $0xc,%esp
  800e71:	6a 00                	push   $0x0
  800e73:	6a 00                	push   $0x0
  800e75:	6a 00                	push   $0x0
  800e77:	e8 dc 10 00 00       	call   801f58 <ipc_recv>
}
  800e7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7f:	c9                   	leave  
  800e80:	c3                   	ret    

00800e81 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
  800e86:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e91:	8b 06                	mov    (%esi),%eax
  800e93:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e98:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9d:	e8 95 ff ff ff       	call   800e37 <nsipc>
  800ea2:	89 c3                	mov    %eax,%ebx
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	78 20                	js     800ec8 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800ea8:	83 ec 04             	sub    $0x4,%esp
  800eab:	ff 35 10 60 80 00    	pushl  0x806010
  800eb1:	68 00 60 80 00       	push   $0x806000
  800eb6:	ff 75 0c             	pushl  0xc(%ebp)
  800eb9:	e8 9e 0e 00 00       	call   801d5c <memmove>
		*addrlen = ret->ret_addrlen;
  800ebe:	a1 10 60 80 00       	mov    0x806010,%eax
  800ec3:	89 06                	mov    %eax,(%esi)
  800ec5:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800ec8:	89 d8                	mov    %ebx,%eax
  800eca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	53                   	push   %ebx
  800ed5:	83 ec 08             	sub    $0x8,%esp
  800ed8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800edb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ede:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ee3:	53                   	push   %ebx
  800ee4:	ff 75 0c             	pushl  0xc(%ebp)
  800ee7:	68 04 60 80 00       	push   $0x806004
  800eec:	e8 6b 0e 00 00       	call   801d5c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800ef1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800ef7:	b8 02 00 00 00       	mov    $0x2,%eax
  800efc:	e8 36 ff ff ff       	call   800e37 <nsipc>
}
  800f01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800f0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f17:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f1c:	b8 03 00 00 00       	mov    $0x3,%eax
  800f21:	e8 11 ff ff ff       	call   800e37 <nsipc>
}
  800f26:	c9                   	leave  
  800f27:	c3                   	ret    

00800f28 <nsipc_close>:

int
nsipc_close(int s)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f31:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f36:	b8 04 00 00 00       	mov    $0x4,%eax
  800f3b:	e8 f7 fe ff ff       	call   800e37 <nsipc>
}
  800f40:	c9                   	leave  
  800f41:	c3                   	ret    

00800f42 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	53                   	push   %ebx
  800f46:	83 ec 08             	sub    $0x8,%esp
  800f49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f54:	53                   	push   %ebx
  800f55:	ff 75 0c             	pushl  0xc(%ebp)
  800f58:	68 04 60 80 00       	push   $0x806004
  800f5d:	e8 fa 0d 00 00       	call   801d5c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f62:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f68:	b8 05 00 00 00       	mov    $0x5,%eax
  800f6d:	e8 c5 fe ff ff       	call   800e37 <nsipc>
}
  800f72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f80:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f88:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f8d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f92:	e8 a0 fe ff ff       	call   800e37 <nsipc>
}
  800f97:	c9                   	leave  
  800f98:	c3                   	ret    

00800f99 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	56                   	push   %esi
  800f9d:	53                   	push   %ebx
  800f9e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800fa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800fa9:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800faf:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb2:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800fb7:	b8 07 00 00 00       	mov    $0x7,%eax
  800fbc:	e8 76 fe ff ff       	call   800e37 <nsipc>
  800fc1:	89 c3                	mov    %eax,%ebx
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	78 35                	js     800ffc <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800fc7:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800fcc:	7f 04                	jg     800fd2 <nsipc_recv+0x39>
  800fce:	39 c6                	cmp    %eax,%esi
  800fd0:	7d 16                	jge    800fe8 <nsipc_recv+0x4f>
  800fd2:	68 27 24 80 00       	push   $0x802427
  800fd7:	68 ef 23 80 00       	push   $0x8023ef
  800fdc:	6a 62                	push   $0x62
  800fde:	68 3c 24 80 00       	push   $0x80243c
  800fe3:	e8 84 05 00 00       	call   80156c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800fe8:	83 ec 04             	sub    $0x4,%esp
  800feb:	50                   	push   %eax
  800fec:	68 00 60 80 00       	push   $0x806000
  800ff1:	ff 75 0c             	pushl  0xc(%ebp)
  800ff4:	e8 63 0d 00 00       	call   801d5c <memmove>
  800ff9:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800ffc:	89 d8                	mov    %ebx,%eax
  800ffe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    

00801005 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	53                   	push   %ebx
  801009:	83 ec 04             	sub    $0x4,%esp
  80100c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80100f:	8b 45 08             	mov    0x8(%ebp),%eax
  801012:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801017:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80101d:	7e 16                	jle    801035 <nsipc_send+0x30>
  80101f:	68 48 24 80 00       	push   $0x802448
  801024:	68 ef 23 80 00       	push   $0x8023ef
  801029:	6a 6d                	push   $0x6d
  80102b:	68 3c 24 80 00       	push   $0x80243c
  801030:	e8 37 05 00 00       	call   80156c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801035:	83 ec 04             	sub    $0x4,%esp
  801038:	53                   	push   %ebx
  801039:	ff 75 0c             	pushl  0xc(%ebp)
  80103c:	68 0c 60 80 00       	push   $0x80600c
  801041:	e8 16 0d 00 00       	call   801d5c <memmove>
	nsipcbuf.send.req_size = size;
  801046:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80104c:	8b 45 14             	mov    0x14(%ebp),%eax
  80104f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801054:	b8 08 00 00 00       	mov    $0x8,%eax
  801059:	e8 d9 fd ff ff       	call   800e37 <nsipc>
}
  80105e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801061:	c9                   	leave  
  801062:	c3                   	ret    

00801063 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801069:	8b 45 08             	mov    0x8(%ebp),%eax
  80106c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801071:	8b 45 0c             	mov    0xc(%ebp),%eax
  801074:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801079:	8b 45 10             	mov    0x10(%ebp),%eax
  80107c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801081:	b8 09 00 00 00       	mov    $0x9,%eax
  801086:	e8 ac fd ff ff       	call   800e37 <nsipc>
}
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	56                   	push   %esi
  801091:	53                   	push   %ebx
  801092:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	ff 75 08             	pushl  0x8(%ebp)
  80109b:	e8 98 f3 ff ff       	call   800438 <fd2data>
  8010a0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010a2:	83 c4 08             	add    $0x8,%esp
  8010a5:	68 54 24 80 00       	push   $0x802454
  8010aa:	53                   	push   %ebx
  8010ab:	e8 1a 0b 00 00       	call   801bca <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010b0:	8b 46 04             	mov    0x4(%esi),%eax
  8010b3:	2b 06                	sub    (%esi),%eax
  8010b5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8010bb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8010c2:	00 00 00 
	stat->st_dev = &devpipe;
  8010c5:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8010cc:	30 80 00 
	return 0;
}
  8010cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	53                   	push   %ebx
  8010df:	83 ec 0c             	sub    $0xc,%esp
  8010e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010e5:	53                   	push   %ebx
  8010e6:	6a 00                	push   $0x0
  8010e8:	e8 08 f1 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010ed:	89 1c 24             	mov    %ebx,(%esp)
  8010f0:	e8 43 f3 ff ff       	call   800438 <fd2data>
  8010f5:	83 c4 08             	add    $0x8,%esp
  8010f8:	50                   	push   %eax
  8010f9:	6a 00                	push   $0x0
  8010fb:	e8 f5 f0 ff ff       	call   8001f5 <sys_page_unmap>
}
  801100:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801103:	c9                   	leave  
  801104:	c3                   	ret    

00801105 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	57                   	push   %edi
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
  80110b:	83 ec 1c             	sub    $0x1c,%esp
  80110e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801111:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801113:	a1 08 40 80 00       	mov    0x804008,%eax
  801118:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80111b:	83 ec 0c             	sub    $0xc,%esp
  80111e:	ff 75 e0             	pushl  -0x20(%ebp)
  801121:	e8 26 0f 00 00       	call   80204c <pageref>
  801126:	89 c3                	mov    %eax,%ebx
  801128:	89 3c 24             	mov    %edi,(%esp)
  80112b:	e8 1c 0f 00 00       	call   80204c <pageref>
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	39 c3                	cmp    %eax,%ebx
  801135:	0f 94 c1             	sete   %cl
  801138:	0f b6 c9             	movzbl %cl,%ecx
  80113b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80113e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801144:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801147:	39 ce                	cmp    %ecx,%esi
  801149:	74 1b                	je     801166 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80114b:	39 c3                	cmp    %eax,%ebx
  80114d:	75 c4                	jne    801113 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80114f:	8b 42 58             	mov    0x58(%edx),%eax
  801152:	ff 75 e4             	pushl  -0x1c(%ebp)
  801155:	50                   	push   %eax
  801156:	56                   	push   %esi
  801157:	68 5b 24 80 00       	push   $0x80245b
  80115c:	e8 e4 04 00 00       	call   801645 <cprintf>
  801161:	83 c4 10             	add    $0x10,%esp
  801164:	eb ad                	jmp    801113 <_pipeisclosed+0xe>
	}
}
  801166:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801169:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5f                   	pop    %edi
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	57                   	push   %edi
  801175:	56                   	push   %esi
  801176:	53                   	push   %ebx
  801177:	83 ec 28             	sub    $0x28,%esp
  80117a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80117d:	56                   	push   %esi
  80117e:	e8 b5 f2 ff ff       	call   800438 <fd2data>
  801183:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	bf 00 00 00 00       	mov    $0x0,%edi
  80118d:	eb 4b                	jmp    8011da <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80118f:	89 da                	mov    %ebx,%edx
  801191:	89 f0                	mov    %esi,%eax
  801193:	e8 6d ff ff ff       	call   801105 <_pipeisclosed>
  801198:	85 c0                	test   %eax,%eax
  80119a:	75 48                	jne    8011e4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80119c:	e8 b0 ef ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011a1:	8b 43 04             	mov    0x4(%ebx),%eax
  8011a4:	8b 0b                	mov    (%ebx),%ecx
  8011a6:	8d 51 20             	lea    0x20(%ecx),%edx
  8011a9:	39 d0                	cmp    %edx,%eax
  8011ab:	73 e2                	jae    80118f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8011b4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8011b7:	89 c2                	mov    %eax,%edx
  8011b9:	c1 fa 1f             	sar    $0x1f,%edx
  8011bc:	89 d1                	mov    %edx,%ecx
  8011be:	c1 e9 1b             	shr    $0x1b,%ecx
  8011c1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8011c4:	83 e2 1f             	and    $0x1f,%edx
  8011c7:	29 ca                	sub    %ecx,%edx
  8011c9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8011cd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011d1:	83 c0 01             	add    $0x1,%eax
  8011d4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d7:	83 c7 01             	add    $0x1,%edi
  8011da:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011dd:	75 c2                	jne    8011a1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011df:	8b 45 10             	mov    0x10(%ebp),%eax
  8011e2:	eb 05                	jmp    8011e9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011e4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ec:	5b                   	pop    %ebx
  8011ed:	5e                   	pop    %esi
  8011ee:	5f                   	pop    %edi
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	57                   	push   %edi
  8011f5:	56                   	push   %esi
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 18             	sub    $0x18,%esp
  8011fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011fd:	57                   	push   %edi
  8011fe:	e8 35 f2 ff ff       	call   800438 <fd2data>
  801203:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120d:	eb 3d                	jmp    80124c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80120f:	85 db                	test   %ebx,%ebx
  801211:	74 04                	je     801217 <devpipe_read+0x26>
				return i;
  801213:	89 d8                	mov    %ebx,%eax
  801215:	eb 44                	jmp    80125b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801217:	89 f2                	mov    %esi,%edx
  801219:	89 f8                	mov    %edi,%eax
  80121b:	e8 e5 fe ff ff       	call   801105 <_pipeisclosed>
  801220:	85 c0                	test   %eax,%eax
  801222:	75 32                	jne    801256 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801224:	e8 28 ef ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801229:	8b 06                	mov    (%esi),%eax
  80122b:	3b 46 04             	cmp    0x4(%esi),%eax
  80122e:	74 df                	je     80120f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801230:	99                   	cltd   
  801231:	c1 ea 1b             	shr    $0x1b,%edx
  801234:	01 d0                	add    %edx,%eax
  801236:	83 e0 1f             	and    $0x1f,%eax
  801239:	29 d0                	sub    %edx,%eax
  80123b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801243:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801246:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801249:	83 c3 01             	add    $0x1,%ebx
  80124c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80124f:	75 d8                	jne    801229 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801251:	8b 45 10             	mov    0x10(%ebp),%eax
  801254:	eb 05                	jmp    80125b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801256:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80125b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125e:	5b                   	pop    %ebx
  80125f:	5e                   	pop    %esi
  801260:	5f                   	pop    %edi
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	56                   	push   %esi
  801267:	53                   	push   %ebx
  801268:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80126b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126e:	50                   	push   %eax
  80126f:	e8 db f1 ff ff       	call   80044f <fd_alloc>
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	89 c2                	mov    %eax,%edx
  801279:	85 c0                	test   %eax,%eax
  80127b:	0f 88 2c 01 00 00    	js     8013ad <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801281:	83 ec 04             	sub    $0x4,%esp
  801284:	68 07 04 00 00       	push   $0x407
  801289:	ff 75 f4             	pushl  -0xc(%ebp)
  80128c:	6a 00                	push   $0x0
  80128e:	e8 dd ee ff ff       	call   800170 <sys_page_alloc>
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	89 c2                	mov    %eax,%edx
  801298:	85 c0                	test   %eax,%eax
  80129a:	0f 88 0d 01 00 00    	js     8013ad <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012a0:	83 ec 0c             	sub    $0xc,%esp
  8012a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a6:	50                   	push   %eax
  8012a7:	e8 a3 f1 ff ff       	call   80044f <fd_alloc>
  8012ac:	89 c3                	mov    %eax,%ebx
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	0f 88 e2 00 00 00    	js     80139b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012b9:	83 ec 04             	sub    $0x4,%esp
  8012bc:	68 07 04 00 00       	push   $0x407
  8012c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c4:	6a 00                	push   $0x0
  8012c6:	e8 a5 ee ff ff       	call   800170 <sys_page_alloc>
  8012cb:	89 c3                	mov    %eax,%ebx
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	0f 88 c3 00 00 00    	js     80139b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012d8:	83 ec 0c             	sub    $0xc,%esp
  8012db:	ff 75 f4             	pushl  -0xc(%ebp)
  8012de:	e8 55 f1 ff ff       	call   800438 <fd2data>
  8012e3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012e5:	83 c4 0c             	add    $0xc,%esp
  8012e8:	68 07 04 00 00       	push   $0x407
  8012ed:	50                   	push   %eax
  8012ee:	6a 00                	push   $0x0
  8012f0:	e8 7b ee ff ff       	call   800170 <sys_page_alloc>
  8012f5:	89 c3                	mov    %eax,%ebx
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	0f 88 89 00 00 00    	js     80138b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801302:	83 ec 0c             	sub    $0xc,%esp
  801305:	ff 75 f0             	pushl  -0x10(%ebp)
  801308:	e8 2b f1 ff ff       	call   800438 <fd2data>
  80130d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801314:	50                   	push   %eax
  801315:	6a 00                	push   $0x0
  801317:	56                   	push   %esi
  801318:	6a 00                	push   $0x0
  80131a:	e8 94 ee ff ff       	call   8001b3 <sys_page_map>
  80131f:	89 c3                	mov    %eax,%ebx
  801321:	83 c4 20             	add    $0x20,%esp
  801324:	85 c0                	test   %eax,%eax
  801326:	78 55                	js     80137d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801328:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80132e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801331:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801333:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801336:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80133d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801343:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801346:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801348:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801352:	83 ec 0c             	sub    $0xc,%esp
  801355:	ff 75 f4             	pushl  -0xc(%ebp)
  801358:	e8 cb f0 ff ff       	call   800428 <fd2num>
  80135d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801360:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801362:	83 c4 04             	add    $0x4,%esp
  801365:	ff 75 f0             	pushl  -0x10(%ebp)
  801368:	e8 bb f0 ff ff       	call   800428 <fd2num>
  80136d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801370:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	ba 00 00 00 00       	mov    $0x0,%edx
  80137b:	eb 30                	jmp    8013ad <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80137d:	83 ec 08             	sub    $0x8,%esp
  801380:	56                   	push   %esi
  801381:	6a 00                	push   $0x0
  801383:	e8 6d ee ff ff       	call   8001f5 <sys_page_unmap>
  801388:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80138b:	83 ec 08             	sub    $0x8,%esp
  80138e:	ff 75 f0             	pushl  -0x10(%ebp)
  801391:	6a 00                	push   $0x0
  801393:	e8 5d ee ff ff       	call   8001f5 <sys_page_unmap>
  801398:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80139b:	83 ec 08             	sub    $0x8,%esp
  80139e:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a1:	6a 00                	push   $0x0
  8013a3:	e8 4d ee ff ff       	call   8001f5 <sys_page_unmap>
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8013ad:	89 d0                	mov    %edx,%eax
  8013af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b2:	5b                   	pop    %ebx
  8013b3:	5e                   	pop    %esi
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    

008013b6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bf:	50                   	push   %eax
  8013c0:	ff 75 08             	pushl  0x8(%ebp)
  8013c3:	e8 d6 f0 ff ff       	call   80049e <fd_lookup>
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	78 18                	js     8013e7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013cf:	83 ec 0c             	sub    $0xc,%esp
  8013d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8013d5:	e8 5e f0 ff ff       	call   800438 <fd2data>
	return _pipeisclosed(fd, p);
  8013da:	89 c2                	mov    %eax,%edx
  8013dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013df:	e8 21 fd ff ff       	call   801105 <_pipeisclosed>
  8013e4:	83 c4 10             	add    $0x10,%esp
}
  8013e7:	c9                   	leave  
  8013e8:	c3                   	ret    

008013e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f1:	5d                   	pop    %ebp
  8013f2:	c3                   	ret    

008013f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013f9:	68 73 24 80 00       	push   $0x802473
  8013fe:	ff 75 0c             	pushl  0xc(%ebp)
  801401:	e8 c4 07 00 00       	call   801bca <strcpy>
	return 0;
}
  801406:	b8 00 00 00 00       	mov    $0x0,%eax
  80140b:	c9                   	leave  
  80140c:	c3                   	ret    

0080140d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	57                   	push   %edi
  801411:	56                   	push   %esi
  801412:	53                   	push   %ebx
  801413:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801419:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80141e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801424:	eb 2d                	jmp    801453 <devcons_write+0x46>
		m = n - tot;
  801426:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801429:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80142b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80142e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801433:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801436:	83 ec 04             	sub    $0x4,%esp
  801439:	53                   	push   %ebx
  80143a:	03 45 0c             	add    0xc(%ebp),%eax
  80143d:	50                   	push   %eax
  80143e:	57                   	push   %edi
  80143f:	e8 18 09 00 00       	call   801d5c <memmove>
		sys_cputs(buf, m);
  801444:	83 c4 08             	add    $0x8,%esp
  801447:	53                   	push   %ebx
  801448:	57                   	push   %edi
  801449:	e8 66 ec ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80144e:	01 de                	add    %ebx,%esi
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	89 f0                	mov    %esi,%eax
  801455:	3b 75 10             	cmp    0x10(%ebp),%esi
  801458:	72 cc                	jb     801426 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80145a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145d:	5b                   	pop    %ebx
  80145e:	5e                   	pop    %esi
  80145f:	5f                   	pop    %edi
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    

00801462 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	83 ec 08             	sub    $0x8,%esp
  801468:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80146d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801471:	74 2a                	je     80149d <devcons_read+0x3b>
  801473:	eb 05                	jmp    80147a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801475:	e8 d7 ec ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80147a:	e8 53 ec ff ff       	call   8000d2 <sys_cgetc>
  80147f:	85 c0                	test   %eax,%eax
  801481:	74 f2                	je     801475 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801483:	85 c0                	test   %eax,%eax
  801485:	78 16                	js     80149d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801487:	83 f8 04             	cmp    $0x4,%eax
  80148a:	74 0c                	je     801498 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80148c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80148f:	88 02                	mov    %al,(%edx)
	return 1;
  801491:	b8 01 00 00 00       	mov    $0x1,%eax
  801496:	eb 05                	jmp    80149d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801498:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80149d:	c9                   	leave  
  80149e:	c3                   	ret    

0080149f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014ab:	6a 01                	push   $0x1
  8014ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014b0:	50                   	push   %eax
  8014b1:	e8 fe eb ff ff       	call   8000b4 <sys_cputs>
}
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <getchar>:

int
getchar(void)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014c1:	6a 01                	push   $0x1
  8014c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014c6:	50                   	push   %eax
  8014c7:	6a 00                	push   $0x0
  8014c9:	e8 36 f2 ff ff       	call   800704 <read>
	if (r < 0)
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 0f                	js     8014e4 <getchar+0x29>
		return r;
	if (r < 1)
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	7e 06                	jle    8014df <getchar+0x24>
		return -E_EOF;
	return c;
  8014d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014dd:	eb 05                	jmp    8014e4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014e4:	c9                   	leave  
  8014e5:	c3                   	ret    

008014e6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ef:	50                   	push   %eax
  8014f0:	ff 75 08             	pushl  0x8(%ebp)
  8014f3:	e8 a6 ef ff ff       	call   80049e <fd_lookup>
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 11                	js     801510 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801502:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801508:	39 10                	cmp    %edx,(%eax)
  80150a:	0f 94 c0             	sete   %al
  80150d:	0f b6 c0             	movzbl %al,%eax
}
  801510:	c9                   	leave  
  801511:	c3                   	ret    

00801512 <opencons>:

int
opencons(void)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	e8 2e ef ff ff       	call   80044f <fd_alloc>
  801521:	83 c4 10             	add    $0x10,%esp
		return r;
  801524:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801526:	85 c0                	test   %eax,%eax
  801528:	78 3e                	js     801568 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80152a:	83 ec 04             	sub    $0x4,%esp
  80152d:	68 07 04 00 00       	push   $0x407
  801532:	ff 75 f4             	pushl  -0xc(%ebp)
  801535:	6a 00                	push   $0x0
  801537:	e8 34 ec ff ff       	call   800170 <sys_page_alloc>
  80153c:	83 c4 10             	add    $0x10,%esp
		return r;
  80153f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801541:	85 c0                	test   %eax,%eax
  801543:	78 23                	js     801568 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801545:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80154b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801550:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801553:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80155a:	83 ec 0c             	sub    $0xc,%esp
  80155d:	50                   	push   %eax
  80155e:	e8 c5 ee ff ff       	call   800428 <fd2num>
  801563:	89 c2                	mov    %eax,%edx
  801565:	83 c4 10             	add    $0x10,%esp
}
  801568:	89 d0                	mov    %edx,%eax
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	56                   	push   %esi
  801570:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801571:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801574:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80157a:	e8 b3 eb ff ff       	call   800132 <sys_getenvid>
  80157f:	83 ec 0c             	sub    $0xc,%esp
  801582:	ff 75 0c             	pushl  0xc(%ebp)
  801585:	ff 75 08             	pushl  0x8(%ebp)
  801588:	56                   	push   %esi
  801589:	50                   	push   %eax
  80158a:	68 80 24 80 00       	push   $0x802480
  80158f:	e8 b1 00 00 00       	call   801645 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801594:	83 c4 18             	add    $0x18,%esp
  801597:	53                   	push   %ebx
  801598:	ff 75 10             	pushl  0x10(%ebp)
  80159b:	e8 54 00 00 00       	call   8015f4 <vcprintf>
	cprintf("\n");
  8015a0:	c7 04 24 6c 24 80 00 	movl   $0x80246c,(%esp)
  8015a7:	e8 99 00 00 00       	call   801645 <cprintf>
  8015ac:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015af:	cc                   	int3   
  8015b0:	eb fd                	jmp    8015af <_panic+0x43>

008015b2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 04             	sub    $0x4,%esp
  8015b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015bc:	8b 13                	mov    (%ebx),%edx
  8015be:	8d 42 01             	lea    0x1(%edx),%eax
  8015c1:	89 03                	mov    %eax,(%ebx)
  8015c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015c6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8015ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015cf:	75 1a                	jne    8015eb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8015d1:	83 ec 08             	sub    $0x8,%esp
  8015d4:	68 ff 00 00 00       	push   $0xff
  8015d9:	8d 43 08             	lea    0x8(%ebx),%eax
  8015dc:	50                   	push   %eax
  8015dd:	e8 d2 ea ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8015e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015e8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015eb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f2:	c9                   	leave  
  8015f3:	c3                   	ret    

008015f4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015fd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801604:	00 00 00 
	b.cnt = 0;
  801607:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80160e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801611:	ff 75 0c             	pushl  0xc(%ebp)
  801614:	ff 75 08             	pushl  0x8(%ebp)
  801617:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80161d:	50                   	push   %eax
  80161e:	68 b2 15 80 00       	push   $0x8015b2
  801623:	e8 54 01 00 00       	call   80177c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801628:	83 c4 08             	add    $0x8,%esp
  80162b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801631:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801637:	50                   	push   %eax
  801638:	e8 77 ea ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  80163d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80164b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80164e:	50                   	push   %eax
  80164f:	ff 75 08             	pushl  0x8(%ebp)
  801652:	e8 9d ff ff ff       	call   8015f4 <vcprintf>
	va_end(ap);

	return cnt;
}
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	57                   	push   %edi
  80165d:	56                   	push   %esi
  80165e:	53                   	push   %ebx
  80165f:	83 ec 1c             	sub    $0x1c,%esp
  801662:	89 c7                	mov    %eax,%edi
  801664:	89 d6                	mov    %edx,%esi
  801666:	8b 45 08             	mov    0x8(%ebp),%eax
  801669:	8b 55 0c             	mov    0xc(%ebp),%edx
  80166c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80166f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801672:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801675:	bb 00 00 00 00       	mov    $0x0,%ebx
  80167a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80167d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801680:	39 d3                	cmp    %edx,%ebx
  801682:	72 05                	jb     801689 <printnum+0x30>
  801684:	39 45 10             	cmp    %eax,0x10(%ebp)
  801687:	77 45                	ja     8016ce <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801689:	83 ec 0c             	sub    $0xc,%esp
  80168c:	ff 75 18             	pushl  0x18(%ebp)
  80168f:	8b 45 14             	mov    0x14(%ebp),%eax
  801692:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801695:	53                   	push   %ebx
  801696:	ff 75 10             	pushl  0x10(%ebp)
  801699:	83 ec 08             	sub    $0x8,%esp
  80169c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80169f:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8016a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8016a8:	e8 e3 09 00 00       	call   802090 <__udivdi3>
  8016ad:	83 c4 18             	add    $0x18,%esp
  8016b0:	52                   	push   %edx
  8016b1:	50                   	push   %eax
  8016b2:	89 f2                	mov    %esi,%edx
  8016b4:	89 f8                	mov    %edi,%eax
  8016b6:	e8 9e ff ff ff       	call   801659 <printnum>
  8016bb:	83 c4 20             	add    $0x20,%esp
  8016be:	eb 18                	jmp    8016d8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	56                   	push   %esi
  8016c4:	ff 75 18             	pushl  0x18(%ebp)
  8016c7:	ff d7                	call   *%edi
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	eb 03                	jmp    8016d1 <printnum+0x78>
  8016ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8016d1:	83 eb 01             	sub    $0x1,%ebx
  8016d4:	85 db                	test   %ebx,%ebx
  8016d6:	7f e8                	jg     8016c0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016d8:	83 ec 08             	sub    $0x8,%esp
  8016db:	56                   	push   %esi
  8016dc:	83 ec 04             	sub    $0x4,%esp
  8016df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8016e5:	ff 75 dc             	pushl  -0x24(%ebp)
  8016e8:	ff 75 d8             	pushl  -0x28(%ebp)
  8016eb:	e8 d0 0a 00 00       	call   8021c0 <__umoddi3>
  8016f0:	83 c4 14             	add    $0x14,%esp
  8016f3:	0f be 80 a3 24 80 00 	movsbl 0x8024a3(%eax),%eax
  8016fa:	50                   	push   %eax
  8016fb:	ff d7                	call   *%edi
}
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801703:	5b                   	pop    %ebx
  801704:	5e                   	pop    %esi
  801705:	5f                   	pop    %edi
  801706:	5d                   	pop    %ebp
  801707:	c3                   	ret    

00801708 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80170b:	83 fa 01             	cmp    $0x1,%edx
  80170e:	7e 0e                	jle    80171e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801710:	8b 10                	mov    (%eax),%edx
  801712:	8d 4a 08             	lea    0x8(%edx),%ecx
  801715:	89 08                	mov    %ecx,(%eax)
  801717:	8b 02                	mov    (%edx),%eax
  801719:	8b 52 04             	mov    0x4(%edx),%edx
  80171c:	eb 22                	jmp    801740 <getuint+0x38>
	else if (lflag)
  80171e:	85 d2                	test   %edx,%edx
  801720:	74 10                	je     801732 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801722:	8b 10                	mov    (%eax),%edx
  801724:	8d 4a 04             	lea    0x4(%edx),%ecx
  801727:	89 08                	mov    %ecx,(%eax)
  801729:	8b 02                	mov    (%edx),%eax
  80172b:	ba 00 00 00 00       	mov    $0x0,%edx
  801730:	eb 0e                	jmp    801740 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801732:	8b 10                	mov    (%eax),%edx
  801734:	8d 4a 04             	lea    0x4(%edx),%ecx
  801737:	89 08                	mov    %ecx,(%eax)
  801739:	8b 02                	mov    (%edx),%eax
  80173b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    

00801742 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801748:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80174c:	8b 10                	mov    (%eax),%edx
  80174e:	3b 50 04             	cmp    0x4(%eax),%edx
  801751:	73 0a                	jae    80175d <sprintputch+0x1b>
		*b->buf++ = ch;
  801753:	8d 4a 01             	lea    0x1(%edx),%ecx
  801756:	89 08                	mov    %ecx,(%eax)
  801758:	8b 45 08             	mov    0x8(%ebp),%eax
  80175b:	88 02                	mov    %al,(%edx)
}
  80175d:	5d                   	pop    %ebp
  80175e:	c3                   	ret    

0080175f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801765:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801768:	50                   	push   %eax
  801769:	ff 75 10             	pushl  0x10(%ebp)
  80176c:	ff 75 0c             	pushl  0xc(%ebp)
  80176f:	ff 75 08             	pushl  0x8(%ebp)
  801772:	e8 05 00 00 00       	call   80177c <vprintfmt>
	va_end(ap);
}
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	c9                   	leave  
  80177b:	c3                   	ret    

0080177c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	57                   	push   %edi
  801780:	56                   	push   %esi
  801781:	53                   	push   %ebx
  801782:	83 ec 2c             	sub    $0x2c,%esp
  801785:	8b 75 08             	mov    0x8(%ebp),%esi
  801788:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80178b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80178e:	eb 12                	jmp    8017a2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801790:	85 c0                	test   %eax,%eax
  801792:	0f 84 89 03 00 00    	je     801b21 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801798:	83 ec 08             	sub    $0x8,%esp
  80179b:	53                   	push   %ebx
  80179c:	50                   	push   %eax
  80179d:	ff d6                	call   *%esi
  80179f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017a2:	83 c7 01             	add    $0x1,%edi
  8017a5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017a9:	83 f8 25             	cmp    $0x25,%eax
  8017ac:	75 e2                	jne    801790 <vprintfmt+0x14>
  8017ae:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8017b2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8017b9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017c0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8017c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cc:	eb 07                	jmp    8017d5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8017d1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d5:	8d 47 01             	lea    0x1(%edi),%eax
  8017d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017db:	0f b6 07             	movzbl (%edi),%eax
  8017de:	0f b6 c8             	movzbl %al,%ecx
  8017e1:	83 e8 23             	sub    $0x23,%eax
  8017e4:	3c 55                	cmp    $0x55,%al
  8017e6:	0f 87 1a 03 00 00    	ja     801b06 <vprintfmt+0x38a>
  8017ec:	0f b6 c0             	movzbl %al,%eax
  8017ef:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  8017f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017f9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017fd:	eb d6                	jmp    8017d5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801802:	b8 00 00 00 00       	mov    $0x0,%eax
  801807:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80180a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80180d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801811:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801814:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801817:	83 fa 09             	cmp    $0x9,%edx
  80181a:	77 39                	ja     801855 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80181c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80181f:	eb e9                	jmp    80180a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801821:	8b 45 14             	mov    0x14(%ebp),%eax
  801824:	8d 48 04             	lea    0x4(%eax),%ecx
  801827:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80182a:	8b 00                	mov    (%eax),%eax
  80182c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801832:	eb 27                	jmp    80185b <vprintfmt+0xdf>
  801834:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801837:	85 c0                	test   %eax,%eax
  801839:	b9 00 00 00 00       	mov    $0x0,%ecx
  80183e:	0f 49 c8             	cmovns %eax,%ecx
  801841:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801844:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801847:	eb 8c                	jmp    8017d5 <vprintfmt+0x59>
  801849:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80184c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801853:	eb 80                	jmp    8017d5 <vprintfmt+0x59>
  801855:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801858:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80185b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80185f:	0f 89 70 ff ff ff    	jns    8017d5 <vprintfmt+0x59>
				width = precision, precision = -1;
  801865:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801868:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80186b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801872:	e9 5e ff ff ff       	jmp    8017d5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801877:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80187a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80187d:	e9 53 ff ff ff       	jmp    8017d5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801882:	8b 45 14             	mov    0x14(%ebp),%eax
  801885:	8d 50 04             	lea    0x4(%eax),%edx
  801888:	89 55 14             	mov    %edx,0x14(%ebp)
  80188b:	83 ec 08             	sub    $0x8,%esp
  80188e:	53                   	push   %ebx
  80188f:	ff 30                	pushl  (%eax)
  801891:	ff d6                	call   *%esi
			break;
  801893:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801896:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801899:	e9 04 ff ff ff       	jmp    8017a2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80189e:	8b 45 14             	mov    0x14(%ebp),%eax
  8018a1:	8d 50 04             	lea    0x4(%eax),%edx
  8018a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8018a7:	8b 00                	mov    (%eax),%eax
  8018a9:	99                   	cltd   
  8018aa:	31 d0                	xor    %edx,%eax
  8018ac:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018ae:	83 f8 0f             	cmp    $0xf,%eax
  8018b1:	7f 0b                	jg     8018be <vprintfmt+0x142>
  8018b3:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  8018ba:	85 d2                	test   %edx,%edx
  8018bc:	75 18                	jne    8018d6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8018be:	50                   	push   %eax
  8018bf:	68 bb 24 80 00       	push   $0x8024bb
  8018c4:	53                   	push   %ebx
  8018c5:	56                   	push   %esi
  8018c6:	e8 94 fe ff ff       	call   80175f <printfmt>
  8018cb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8018d1:	e9 cc fe ff ff       	jmp    8017a2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8018d6:	52                   	push   %edx
  8018d7:	68 01 24 80 00       	push   $0x802401
  8018dc:	53                   	push   %ebx
  8018dd:	56                   	push   %esi
  8018de:	e8 7c fe ff ff       	call   80175f <printfmt>
  8018e3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018e9:	e9 b4 fe ff ff       	jmp    8017a2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f1:	8d 50 04             	lea    0x4(%eax),%edx
  8018f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8018f7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018f9:	85 ff                	test   %edi,%edi
  8018fb:	b8 b4 24 80 00       	mov    $0x8024b4,%eax
  801900:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801903:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801907:	0f 8e 94 00 00 00    	jle    8019a1 <vprintfmt+0x225>
  80190d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801911:	0f 84 98 00 00 00    	je     8019af <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	ff 75 d0             	pushl  -0x30(%ebp)
  80191d:	57                   	push   %edi
  80191e:	e8 86 02 00 00       	call   801ba9 <strnlen>
  801923:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801926:	29 c1                	sub    %eax,%ecx
  801928:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80192b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80192e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801932:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801935:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801938:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80193a:	eb 0f                	jmp    80194b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80193c:	83 ec 08             	sub    $0x8,%esp
  80193f:	53                   	push   %ebx
  801940:	ff 75 e0             	pushl  -0x20(%ebp)
  801943:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801945:	83 ef 01             	sub    $0x1,%edi
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	85 ff                	test   %edi,%edi
  80194d:	7f ed                	jg     80193c <vprintfmt+0x1c0>
  80194f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801952:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801955:	85 c9                	test   %ecx,%ecx
  801957:	b8 00 00 00 00       	mov    $0x0,%eax
  80195c:	0f 49 c1             	cmovns %ecx,%eax
  80195f:	29 c1                	sub    %eax,%ecx
  801961:	89 75 08             	mov    %esi,0x8(%ebp)
  801964:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801967:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80196a:	89 cb                	mov    %ecx,%ebx
  80196c:	eb 4d                	jmp    8019bb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80196e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801972:	74 1b                	je     80198f <vprintfmt+0x213>
  801974:	0f be c0             	movsbl %al,%eax
  801977:	83 e8 20             	sub    $0x20,%eax
  80197a:	83 f8 5e             	cmp    $0x5e,%eax
  80197d:	76 10                	jbe    80198f <vprintfmt+0x213>
					putch('?', putdat);
  80197f:	83 ec 08             	sub    $0x8,%esp
  801982:	ff 75 0c             	pushl  0xc(%ebp)
  801985:	6a 3f                	push   $0x3f
  801987:	ff 55 08             	call   *0x8(%ebp)
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	eb 0d                	jmp    80199c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	ff 75 0c             	pushl  0xc(%ebp)
  801995:	52                   	push   %edx
  801996:	ff 55 08             	call   *0x8(%ebp)
  801999:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80199c:	83 eb 01             	sub    $0x1,%ebx
  80199f:	eb 1a                	jmp    8019bb <vprintfmt+0x23f>
  8019a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8019a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019aa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019ad:	eb 0c                	jmp    8019bb <vprintfmt+0x23f>
  8019af:	89 75 08             	mov    %esi,0x8(%ebp)
  8019b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019bb:	83 c7 01             	add    $0x1,%edi
  8019be:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019c2:	0f be d0             	movsbl %al,%edx
  8019c5:	85 d2                	test   %edx,%edx
  8019c7:	74 23                	je     8019ec <vprintfmt+0x270>
  8019c9:	85 f6                	test   %esi,%esi
  8019cb:	78 a1                	js     80196e <vprintfmt+0x1f2>
  8019cd:	83 ee 01             	sub    $0x1,%esi
  8019d0:	79 9c                	jns    80196e <vprintfmt+0x1f2>
  8019d2:	89 df                	mov    %ebx,%edi
  8019d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8019d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019da:	eb 18                	jmp    8019f4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019dc:	83 ec 08             	sub    $0x8,%esp
  8019df:	53                   	push   %ebx
  8019e0:	6a 20                	push   $0x20
  8019e2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019e4:	83 ef 01             	sub    $0x1,%edi
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	eb 08                	jmp    8019f4 <vprintfmt+0x278>
  8019ec:	89 df                	mov    %ebx,%edi
  8019ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8019f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019f4:	85 ff                	test   %edi,%edi
  8019f6:	7f e4                	jg     8019dc <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019fb:	e9 a2 fd ff ff       	jmp    8017a2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a00:	83 fa 01             	cmp    $0x1,%edx
  801a03:	7e 16                	jle    801a1b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a05:	8b 45 14             	mov    0x14(%ebp),%eax
  801a08:	8d 50 08             	lea    0x8(%eax),%edx
  801a0b:	89 55 14             	mov    %edx,0x14(%ebp)
  801a0e:	8b 50 04             	mov    0x4(%eax),%edx
  801a11:	8b 00                	mov    (%eax),%eax
  801a13:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a16:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a19:	eb 32                	jmp    801a4d <vprintfmt+0x2d1>
	else if (lflag)
  801a1b:	85 d2                	test   %edx,%edx
  801a1d:	74 18                	je     801a37 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a1f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a22:	8d 50 04             	lea    0x4(%eax),%edx
  801a25:	89 55 14             	mov    %edx,0x14(%ebp)
  801a28:	8b 00                	mov    (%eax),%eax
  801a2a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a2d:	89 c1                	mov    %eax,%ecx
  801a2f:	c1 f9 1f             	sar    $0x1f,%ecx
  801a32:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a35:	eb 16                	jmp    801a4d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a37:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3a:	8d 50 04             	lea    0x4(%eax),%edx
  801a3d:	89 55 14             	mov    %edx,0x14(%ebp)
  801a40:	8b 00                	mov    (%eax),%eax
  801a42:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a45:	89 c1                	mov    %eax,%ecx
  801a47:	c1 f9 1f             	sar    $0x1f,%ecx
  801a4a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a4d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a50:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a53:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a58:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a5c:	79 74                	jns    801ad2 <vprintfmt+0x356>
				putch('-', putdat);
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	53                   	push   %ebx
  801a62:	6a 2d                	push   $0x2d
  801a64:	ff d6                	call   *%esi
				num = -(long long) num;
  801a66:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a69:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a6c:	f7 d8                	neg    %eax
  801a6e:	83 d2 00             	adc    $0x0,%edx
  801a71:	f7 da                	neg    %edx
  801a73:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a76:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a7b:	eb 55                	jmp    801ad2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a7d:	8d 45 14             	lea    0x14(%ebp),%eax
  801a80:	e8 83 fc ff ff       	call   801708 <getuint>
			base = 10;
  801a85:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a8a:	eb 46                	jmp    801ad2 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a8c:	8d 45 14             	lea    0x14(%ebp),%eax
  801a8f:	e8 74 fc ff ff       	call   801708 <getuint>
			base = 8;
  801a94:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a99:	eb 37                	jmp    801ad2 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a9b:	83 ec 08             	sub    $0x8,%esp
  801a9e:	53                   	push   %ebx
  801a9f:	6a 30                	push   $0x30
  801aa1:	ff d6                	call   *%esi
			putch('x', putdat);
  801aa3:	83 c4 08             	add    $0x8,%esp
  801aa6:	53                   	push   %ebx
  801aa7:	6a 78                	push   $0x78
  801aa9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801aab:	8b 45 14             	mov    0x14(%ebp),%eax
  801aae:	8d 50 04             	lea    0x4(%eax),%edx
  801ab1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ab4:	8b 00                	mov    (%eax),%eax
  801ab6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801abb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801abe:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ac3:	eb 0d                	jmp    801ad2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ac5:	8d 45 14             	lea    0x14(%ebp),%eax
  801ac8:	e8 3b fc ff ff       	call   801708 <getuint>
			base = 16;
  801acd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ad2:	83 ec 0c             	sub    $0xc,%esp
  801ad5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ad9:	57                   	push   %edi
  801ada:	ff 75 e0             	pushl  -0x20(%ebp)
  801add:	51                   	push   %ecx
  801ade:	52                   	push   %edx
  801adf:	50                   	push   %eax
  801ae0:	89 da                	mov    %ebx,%edx
  801ae2:	89 f0                	mov    %esi,%eax
  801ae4:	e8 70 fb ff ff       	call   801659 <printnum>
			break;
  801ae9:	83 c4 20             	add    $0x20,%esp
  801aec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801aef:	e9 ae fc ff ff       	jmp    8017a2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801af4:	83 ec 08             	sub    $0x8,%esp
  801af7:	53                   	push   %ebx
  801af8:	51                   	push   %ecx
  801af9:	ff d6                	call   *%esi
			break;
  801afb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801afe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b01:	e9 9c fc ff ff       	jmp    8017a2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b06:	83 ec 08             	sub    $0x8,%esp
  801b09:	53                   	push   %ebx
  801b0a:	6a 25                	push   $0x25
  801b0c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	eb 03                	jmp    801b16 <vprintfmt+0x39a>
  801b13:	83 ef 01             	sub    $0x1,%edi
  801b16:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b1a:	75 f7                	jne    801b13 <vprintfmt+0x397>
  801b1c:	e9 81 fc ff ff       	jmp    8017a2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b24:	5b                   	pop    %ebx
  801b25:	5e                   	pop    %esi
  801b26:	5f                   	pop    %edi
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	83 ec 18             	sub    $0x18,%esp
  801b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b32:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b35:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b38:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b3c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b3f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b46:	85 c0                	test   %eax,%eax
  801b48:	74 26                	je     801b70 <vsnprintf+0x47>
  801b4a:	85 d2                	test   %edx,%edx
  801b4c:	7e 22                	jle    801b70 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b4e:	ff 75 14             	pushl  0x14(%ebp)
  801b51:	ff 75 10             	pushl  0x10(%ebp)
  801b54:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b57:	50                   	push   %eax
  801b58:	68 42 17 80 00       	push   $0x801742
  801b5d:	e8 1a fc ff ff       	call   80177c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b62:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b65:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	eb 05                	jmp    801b75 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b70:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b7d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b80:	50                   	push   %eax
  801b81:	ff 75 10             	pushl  0x10(%ebp)
  801b84:	ff 75 0c             	pushl  0xc(%ebp)
  801b87:	ff 75 08             	pushl  0x8(%ebp)
  801b8a:	e8 9a ff ff ff       	call   801b29 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b8f:	c9                   	leave  
  801b90:	c3                   	ret    

00801b91 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b97:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9c:	eb 03                	jmp    801ba1 <strlen+0x10>
		n++;
  801b9e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801ba1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801ba5:	75 f7                	jne    801b9e <strlen+0xd>
		n++;
	return n;
}
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    

00801ba9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801baf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb7:	eb 03                	jmp    801bbc <strnlen+0x13>
		n++;
  801bb9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bbc:	39 c2                	cmp    %eax,%edx
  801bbe:	74 08                	je     801bc8 <strnlen+0x1f>
  801bc0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bc4:	75 f3                	jne    801bb9 <strnlen+0x10>
  801bc6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bc8:	5d                   	pop    %ebp
  801bc9:	c3                   	ret    

00801bca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	53                   	push   %ebx
  801bce:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bd4:	89 c2                	mov    %eax,%edx
  801bd6:	83 c2 01             	add    $0x1,%edx
  801bd9:	83 c1 01             	add    $0x1,%ecx
  801bdc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801be0:	88 5a ff             	mov    %bl,-0x1(%edx)
  801be3:	84 db                	test   %bl,%bl
  801be5:	75 ef                	jne    801bd6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801be7:	5b                   	pop    %ebx
  801be8:	5d                   	pop    %ebp
  801be9:	c3                   	ret    

00801bea <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	53                   	push   %ebx
  801bee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bf1:	53                   	push   %ebx
  801bf2:	e8 9a ff ff ff       	call   801b91 <strlen>
  801bf7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bfa:	ff 75 0c             	pushl  0xc(%ebp)
  801bfd:	01 d8                	add    %ebx,%eax
  801bff:	50                   	push   %eax
  801c00:	e8 c5 ff ff ff       	call   801bca <strcpy>
	return dst;
}
  801c05:	89 d8                	mov    %ebx,%eax
  801c07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	56                   	push   %esi
  801c10:	53                   	push   %ebx
  801c11:	8b 75 08             	mov    0x8(%ebp),%esi
  801c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c17:	89 f3                	mov    %esi,%ebx
  801c19:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c1c:	89 f2                	mov    %esi,%edx
  801c1e:	eb 0f                	jmp    801c2f <strncpy+0x23>
		*dst++ = *src;
  801c20:	83 c2 01             	add    $0x1,%edx
  801c23:	0f b6 01             	movzbl (%ecx),%eax
  801c26:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c29:	80 39 01             	cmpb   $0x1,(%ecx)
  801c2c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c2f:	39 da                	cmp    %ebx,%edx
  801c31:	75 ed                	jne    801c20 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c33:	89 f0                	mov    %esi,%eax
  801c35:	5b                   	pop    %ebx
  801c36:	5e                   	pop    %esi
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    

00801c39 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	56                   	push   %esi
  801c3d:	53                   	push   %ebx
  801c3e:	8b 75 08             	mov    0x8(%ebp),%esi
  801c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c44:	8b 55 10             	mov    0x10(%ebp),%edx
  801c47:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c49:	85 d2                	test   %edx,%edx
  801c4b:	74 21                	je     801c6e <strlcpy+0x35>
  801c4d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c51:	89 f2                	mov    %esi,%edx
  801c53:	eb 09                	jmp    801c5e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c55:	83 c2 01             	add    $0x1,%edx
  801c58:	83 c1 01             	add    $0x1,%ecx
  801c5b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c5e:	39 c2                	cmp    %eax,%edx
  801c60:	74 09                	je     801c6b <strlcpy+0x32>
  801c62:	0f b6 19             	movzbl (%ecx),%ebx
  801c65:	84 db                	test   %bl,%bl
  801c67:	75 ec                	jne    801c55 <strlcpy+0x1c>
  801c69:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c6b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c6e:	29 f0                	sub    %esi,%eax
}
  801c70:	5b                   	pop    %ebx
  801c71:	5e                   	pop    %esi
  801c72:	5d                   	pop    %ebp
  801c73:	c3                   	ret    

00801c74 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c7d:	eb 06                	jmp    801c85 <strcmp+0x11>
		p++, q++;
  801c7f:	83 c1 01             	add    $0x1,%ecx
  801c82:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c85:	0f b6 01             	movzbl (%ecx),%eax
  801c88:	84 c0                	test   %al,%al
  801c8a:	74 04                	je     801c90 <strcmp+0x1c>
  801c8c:	3a 02                	cmp    (%edx),%al
  801c8e:	74 ef                	je     801c7f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c90:	0f b6 c0             	movzbl %al,%eax
  801c93:	0f b6 12             	movzbl (%edx),%edx
  801c96:	29 d0                	sub    %edx,%eax
}
  801c98:	5d                   	pop    %ebp
  801c99:	c3                   	ret    

00801c9a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c9a:	55                   	push   %ebp
  801c9b:	89 e5                	mov    %esp,%ebp
  801c9d:	53                   	push   %ebx
  801c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ca4:	89 c3                	mov    %eax,%ebx
  801ca6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ca9:	eb 06                	jmp    801cb1 <strncmp+0x17>
		n--, p++, q++;
  801cab:	83 c0 01             	add    $0x1,%eax
  801cae:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cb1:	39 d8                	cmp    %ebx,%eax
  801cb3:	74 15                	je     801cca <strncmp+0x30>
  801cb5:	0f b6 08             	movzbl (%eax),%ecx
  801cb8:	84 c9                	test   %cl,%cl
  801cba:	74 04                	je     801cc0 <strncmp+0x26>
  801cbc:	3a 0a                	cmp    (%edx),%cl
  801cbe:	74 eb                	je     801cab <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cc0:	0f b6 00             	movzbl (%eax),%eax
  801cc3:	0f b6 12             	movzbl (%edx),%edx
  801cc6:	29 d0                	sub    %edx,%eax
  801cc8:	eb 05                	jmp    801ccf <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cca:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801ccf:	5b                   	pop    %ebx
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    

00801cd2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cdc:	eb 07                	jmp    801ce5 <strchr+0x13>
		if (*s == c)
  801cde:	38 ca                	cmp    %cl,%dl
  801ce0:	74 0f                	je     801cf1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ce2:	83 c0 01             	add    $0x1,%eax
  801ce5:	0f b6 10             	movzbl (%eax),%edx
  801ce8:	84 d2                	test   %dl,%dl
  801cea:	75 f2                	jne    801cde <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf1:	5d                   	pop    %ebp
  801cf2:	c3                   	ret    

00801cf3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cfd:	eb 03                	jmp    801d02 <strfind+0xf>
  801cff:	83 c0 01             	add    $0x1,%eax
  801d02:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d05:	38 ca                	cmp    %cl,%dl
  801d07:	74 04                	je     801d0d <strfind+0x1a>
  801d09:	84 d2                	test   %dl,%dl
  801d0b:	75 f2                	jne    801cff <strfind+0xc>
			break;
	return (char *) s;
}
  801d0d:	5d                   	pop    %ebp
  801d0e:	c3                   	ret    

00801d0f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	57                   	push   %edi
  801d13:	56                   	push   %esi
  801d14:	53                   	push   %ebx
  801d15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d1b:	85 c9                	test   %ecx,%ecx
  801d1d:	74 36                	je     801d55 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d25:	75 28                	jne    801d4f <memset+0x40>
  801d27:	f6 c1 03             	test   $0x3,%cl
  801d2a:	75 23                	jne    801d4f <memset+0x40>
		c &= 0xFF;
  801d2c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d30:	89 d3                	mov    %edx,%ebx
  801d32:	c1 e3 08             	shl    $0x8,%ebx
  801d35:	89 d6                	mov    %edx,%esi
  801d37:	c1 e6 18             	shl    $0x18,%esi
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	c1 e0 10             	shl    $0x10,%eax
  801d3f:	09 f0                	or     %esi,%eax
  801d41:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d43:	89 d8                	mov    %ebx,%eax
  801d45:	09 d0                	or     %edx,%eax
  801d47:	c1 e9 02             	shr    $0x2,%ecx
  801d4a:	fc                   	cld    
  801d4b:	f3 ab                	rep stos %eax,%es:(%edi)
  801d4d:	eb 06                	jmp    801d55 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d52:	fc                   	cld    
  801d53:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d55:	89 f8                	mov    %edi,%eax
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5f                   	pop    %edi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    

00801d5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	57                   	push   %edi
  801d60:	56                   	push   %esi
  801d61:	8b 45 08             	mov    0x8(%ebp),%eax
  801d64:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d6a:	39 c6                	cmp    %eax,%esi
  801d6c:	73 35                	jae    801da3 <memmove+0x47>
  801d6e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d71:	39 d0                	cmp    %edx,%eax
  801d73:	73 2e                	jae    801da3 <memmove+0x47>
		s += n;
		d += n;
  801d75:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d78:	89 d6                	mov    %edx,%esi
  801d7a:	09 fe                	or     %edi,%esi
  801d7c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d82:	75 13                	jne    801d97 <memmove+0x3b>
  801d84:	f6 c1 03             	test   $0x3,%cl
  801d87:	75 0e                	jne    801d97 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d89:	83 ef 04             	sub    $0x4,%edi
  801d8c:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d8f:	c1 e9 02             	shr    $0x2,%ecx
  801d92:	fd                   	std    
  801d93:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d95:	eb 09                	jmp    801da0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d97:	83 ef 01             	sub    $0x1,%edi
  801d9a:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d9d:	fd                   	std    
  801d9e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801da0:	fc                   	cld    
  801da1:	eb 1d                	jmp    801dc0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801da3:	89 f2                	mov    %esi,%edx
  801da5:	09 c2                	or     %eax,%edx
  801da7:	f6 c2 03             	test   $0x3,%dl
  801daa:	75 0f                	jne    801dbb <memmove+0x5f>
  801dac:	f6 c1 03             	test   $0x3,%cl
  801daf:	75 0a                	jne    801dbb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801db1:	c1 e9 02             	shr    $0x2,%ecx
  801db4:	89 c7                	mov    %eax,%edi
  801db6:	fc                   	cld    
  801db7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801db9:	eb 05                	jmp    801dc0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801dbb:	89 c7                	mov    %eax,%edi
  801dbd:	fc                   	cld    
  801dbe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dc0:	5e                   	pop    %esi
  801dc1:	5f                   	pop    %edi
  801dc2:	5d                   	pop    %ebp
  801dc3:	c3                   	ret    

00801dc4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801dc7:	ff 75 10             	pushl  0x10(%ebp)
  801dca:	ff 75 0c             	pushl  0xc(%ebp)
  801dcd:	ff 75 08             	pushl  0x8(%ebp)
  801dd0:	e8 87 ff ff ff       	call   801d5c <memmove>
}
  801dd5:	c9                   	leave  
  801dd6:	c3                   	ret    

00801dd7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	56                   	push   %esi
  801ddb:	53                   	push   %ebx
  801ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de2:	89 c6                	mov    %eax,%esi
  801de4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801de7:	eb 1a                	jmp    801e03 <memcmp+0x2c>
		if (*s1 != *s2)
  801de9:	0f b6 08             	movzbl (%eax),%ecx
  801dec:	0f b6 1a             	movzbl (%edx),%ebx
  801def:	38 d9                	cmp    %bl,%cl
  801df1:	74 0a                	je     801dfd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801df3:	0f b6 c1             	movzbl %cl,%eax
  801df6:	0f b6 db             	movzbl %bl,%ebx
  801df9:	29 d8                	sub    %ebx,%eax
  801dfb:	eb 0f                	jmp    801e0c <memcmp+0x35>
		s1++, s2++;
  801dfd:	83 c0 01             	add    $0x1,%eax
  801e00:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e03:	39 f0                	cmp    %esi,%eax
  801e05:	75 e2                	jne    801de9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e0c:	5b                   	pop    %ebx
  801e0d:	5e                   	pop    %esi
  801e0e:	5d                   	pop    %ebp
  801e0f:	c3                   	ret    

00801e10 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	53                   	push   %ebx
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e17:	89 c1                	mov    %eax,%ecx
  801e19:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e1c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e20:	eb 0a                	jmp    801e2c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e22:	0f b6 10             	movzbl (%eax),%edx
  801e25:	39 da                	cmp    %ebx,%edx
  801e27:	74 07                	je     801e30 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e29:	83 c0 01             	add    $0x1,%eax
  801e2c:	39 c8                	cmp    %ecx,%eax
  801e2e:	72 f2                	jb     801e22 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e30:	5b                   	pop    %ebx
  801e31:	5d                   	pop    %ebp
  801e32:	c3                   	ret    

00801e33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	57                   	push   %edi
  801e37:	56                   	push   %esi
  801e38:	53                   	push   %ebx
  801e39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e3f:	eb 03                	jmp    801e44 <strtol+0x11>
		s++;
  801e41:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e44:	0f b6 01             	movzbl (%ecx),%eax
  801e47:	3c 20                	cmp    $0x20,%al
  801e49:	74 f6                	je     801e41 <strtol+0xe>
  801e4b:	3c 09                	cmp    $0x9,%al
  801e4d:	74 f2                	je     801e41 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e4f:	3c 2b                	cmp    $0x2b,%al
  801e51:	75 0a                	jne    801e5d <strtol+0x2a>
		s++;
  801e53:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e56:	bf 00 00 00 00       	mov    $0x0,%edi
  801e5b:	eb 11                	jmp    801e6e <strtol+0x3b>
  801e5d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e62:	3c 2d                	cmp    $0x2d,%al
  801e64:	75 08                	jne    801e6e <strtol+0x3b>
		s++, neg = 1;
  801e66:	83 c1 01             	add    $0x1,%ecx
  801e69:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e6e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e74:	75 15                	jne    801e8b <strtol+0x58>
  801e76:	80 39 30             	cmpb   $0x30,(%ecx)
  801e79:	75 10                	jne    801e8b <strtol+0x58>
  801e7b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e7f:	75 7c                	jne    801efd <strtol+0xca>
		s += 2, base = 16;
  801e81:	83 c1 02             	add    $0x2,%ecx
  801e84:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e89:	eb 16                	jmp    801ea1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e8b:	85 db                	test   %ebx,%ebx
  801e8d:	75 12                	jne    801ea1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e8f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e94:	80 39 30             	cmpb   $0x30,(%ecx)
  801e97:	75 08                	jne    801ea1 <strtol+0x6e>
		s++, base = 8;
  801e99:	83 c1 01             	add    $0x1,%ecx
  801e9c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801ea1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ea9:	0f b6 11             	movzbl (%ecx),%edx
  801eac:	8d 72 d0             	lea    -0x30(%edx),%esi
  801eaf:	89 f3                	mov    %esi,%ebx
  801eb1:	80 fb 09             	cmp    $0x9,%bl
  801eb4:	77 08                	ja     801ebe <strtol+0x8b>
			dig = *s - '0';
  801eb6:	0f be d2             	movsbl %dl,%edx
  801eb9:	83 ea 30             	sub    $0x30,%edx
  801ebc:	eb 22                	jmp    801ee0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ebe:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ec1:	89 f3                	mov    %esi,%ebx
  801ec3:	80 fb 19             	cmp    $0x19,%bl
  801ec6:	77 08                	ja     801ed0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801ec8:	0f be d2             	movsbl %dl,%edx
  801ecb:	83 ea 57             	sub    $0x57,%edx
  801ece:	eb 10                	jmp    801ee0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ed0:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ed3:	89 f3                	mov    %esi,%ebx
  801ed5:	80 fb 19             	cmp    $0x19,%bl
  801ed8:	77 16                	ja     801ef0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801eda:	0f be d2             	movsbl %dl,%edx
  801edd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ee0:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ee3:	7d 0b                	jge    801ef0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ee5:	83 c1 01             	add    $0x1,%ecx
  801ee8:	0f af 45 10          	imul   0x10(%ebp),%eax
  801eec:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801eee:	eb b9                	jmp    801ea9 <strtol+0x76>

	if (endptr)
  801ef0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ef4:	74 0d                	je     801f03 <strtol+0xd0>
		*endptr = (char *) s;
  801ef6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef9:	89 0e                	mov    %ecx,(%esi)
  801efb:	eb 06                	jmp    801f03 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801efd:	85 db                	test   %ebx,%ebx
  801eff:	74 98                	je     801e99 <strtol+0x66>
  801f01:	eb 9e                	jmp    801ea1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f03:	89 c2                	mov    %eax,%edx
  801f05:	f7 da                	neg    %edx
  801f07:	85 ff                	test   %edi,%edi
  801f09:	0f 45 c2             	cmovne %edx,%eax
}
  801f0c:	5b                   	pop    %ebx
  801f0d:	5e                   	pop    %esi
  801f0e:	5f                   	pop    %edi
  801f0f:	5d                   	pop    %ebp
  801f10:	c3                   	ret    

00801f11 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f11:	55                   	push   %ebp
  801f12:	89 e5                	mov    %esp,%ebp
  801f14:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f17:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801f1e:	75 2e                	jne    801f4e <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801f20:	e8 0d e2 ff ff       	call   800132 <sys_getenvid>
  801f25:	83 ec 04             	sub    $0x4,%esp
  801f28:	68 07 0e 00 00       	push   $0xe07
  801f2d:	68 00 f0 bf ee       	push   $0xeebff000
  801f32:	50                   	push   %eax
  801f33:	e8 38 e2 ff ff       	call   800170 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801f38:	e8 f5 e1 ff ff       	call   800132 <sys_getenvid>
  801f3d:	83 c4 08             	add    $0x8,%esp
  801f40:	68 04 04 80 00       	push   $0x800404
  801f45:	50                   	push   %eax
  801f46:	e8 70 e3 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801f4b:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f51:	a3 00 70 80 00       	mov    %eax,0x807000
}
  801f56:	c9                   	leave  
  801f57:	c3                   	ret    

00801f58 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	56                   	push   %esi
  801f5c:	53                   	push   %ebx
  801f5d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f66:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f68:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f6d:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f70:	83 ec 0c             	sub    $0xc,%esp
  801f73:	50                   	push   %eax
  801f74:	e8 a7 e3 ff ff       	call   800320 <sys_ipc_recv>

	if (from_env_store != NULL)
  801f79:	83 c4 10             	add    $0x10,%esp
  801f7c:	85 f6                	test   %esi,%esi
  801f7e:	74 14                	je     801f94 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f80:	ba 00 00 00 00       	mov    $0x0,%edx
  801f85:	85 c0                	test   %eax,%eax
  801f87:	78 09                	js     801f92 <ipc_recv+0x3a>
  801f89:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f8f:	8b 52 74             	mov    0x74(%edx),%edx
  801f92:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f94:	85 db                	test   %ebx,%ebx
  801f96:	74 14                	je     801fac <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f98:	ba 00 00 00 00       	mov    $0x0,%edx
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	78 09                	js     801faa <ipc_recv+0x52>
  801fa1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fa7:	8b 52 78             	mov    0x78(%edx),%edx
  801faa:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801fac:	85 c0                	test   %eax,%eax
  801fae:	78 08                	js     801fb8 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801fb0:	a1 08 40 80 00       	mov    0x804008,%eax
  801fb5:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fbb:	5b                   	pop    %ebx
  801fbc:	5e                   	pop    %esi
  801fbd:	5d                   	pop    %ebp
  801fbe:	c3                   	ret    

00801fbf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fbf:	55                   	push   %ebp
  801fc0:	89 e5                	mov    %esp,%ebp
  801fc2:	57                   	push   %edi
  801fc3:	56                   	push   %esi
  801fc4:	53                   	push   %ebx
  801fc5:	83 ec 0c             	sub    $0xc,%esp
  801fc8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fcb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801fd1:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801fd3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fd8:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801fdb:	ff 75 14             	pushl  0x14(%ebp)
  801fde:	53                   	push   %ebx
  801fdf:	56                   	push   %esi
  801fe0:	57                   	push   %edi
  801fe1:	e8 17 e3 ff ff       	call   8002fd <sys_ipc_try_send>

		if (err < 0) {
  801fe6:	83 c4 10             	add    $0x10,%esp
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	79 1e                	jns    80200b <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801fed:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ff0:	75 07                	jne    801ff9 <ipc_send+0x3a>
				sys_yield();
  801ff2:	e8 5a e1 ff ff       	call   800151 <sys_yield>
  801ff7:	eb e2                	jmp    801fdb <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801ff9:	50                   	push   %eax
  801ffa:	68 a0 27 80 00       	push   $0x8027a0
  801fff:	6a 49                	push   $0x49
  802001:	68 ad 27 80 00       	push   $0x8027ad
  802006:	e8 61 f5 ff ff       	call   80156c <_panic>
		}

	} while (err < 0);

}
  80200b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80200e:	5b                   	pop    %ebx
  80200f:	5e                   	pop    %esi
  802010:	5f                   	pop    %edi
  802011:	5d                   	pop    %ebp
  802012:	c3                   	ret    

00802013 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802013:	55                   	push   %ebp
  802014:	89 e5                	mov    %esp,%ebp
  802016:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802019:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80201e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802021:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802027:	8b 52 50             	mov    0x50(%edx),%edx
  80202a:	39 ca                	cmp    %ecx,%edx
  80202c:	75 0d                	jne    80203b <ipc_find_env+0x28>
			return envs[i].env_id;
  80202e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802031:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802036:	8b 40 48             	mov    0x48(%eax),%eax
  802039:	eb 0f                	jmp    80204a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80203b:	83 c0 01             	add    $0x1,%eax
  80203e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802043:	75 d9                	jne    80201e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802045:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80204a:	5d                   	pop    %ebp
  80204b:	c3                   	ret    

0080204c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80204c:	55                   	push   %ebp
  80204d:	89 e5                	mov    %esp,%ebp
  80204f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802052:	89 d0                	mov    %edx,%eax
  802054:	c1 e8 16             	shr    $0x16,%eax
  802057:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80205e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802063:	f6 c1 01             	test   $0x1,%cl
  802066:	74 1d                	je     802085 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802068:	c1 ea 0c             	shr    $0xc,%edx
  80206b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802072:	f6 c2 01             	test   $0x1,%dl
  802075:	74 0e                	je     802085 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802077:	c1 ea 0c             	shr    $0xc,%edx
  80207a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802081:	ef 
  802082:	0f b7 c0             	movzwl %ax,%eax
}
  802085:	5d                   	pop    %ebp
  802086:	c3                   	ret    
  802087:	66 90                	xchg   %ax,%ax
  802089:	66 90                	xchg   %ax,%ax
  80208b:	66 90                	xchg   %ax,%ax
  80208d:	66 90                	xchg   %ax,%ax
  80208f:	90                   	nop

00802090 <__udivdi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80209b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80209f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 f6                	test   %esi,%esi
  8020a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ad:	89 ca                	mov    %ecx,%edx
  8020af:	89 f8                	mov    %edi,%eax
  8020b1:	75 3d                	jne    8020f0 <__udivdi3+0x60>
  8020b3:	39 cf                	cmp    %ecx,%edi
  8020b5:	0f 87 c5 00 00 00    	ja     802180 <__udivdi3+0xf0>
  8020bb:	85 ff                	test   %edi,%edi
  8020bd:	89 fd                	mov    %edi,%ebp
  8020bf:	75 0b                	jne    8020cc <__udivdi3+0x3c>
  8020c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020c6:	31 d2                	xor    %edx,%edx
  8020c8:	f7 f7                	div    %edi
  8020ca:	89 c5                	mov    %eax,%ebp
  8020cc:	89 c8                	mov    %ecx,%eax
  8020ce:	31 d2                	xor    %edx,%edx
  8020d0:	f7 f5                	div    %ebp
  8020d2:	89 c1                	mov    %eax,%ecx
  8020d4:	89 d8                	mov    %ebx,%eax
  8020d6:	89 cf                	mov    %ecx,%edi
  8020d8:	f7 f5                	div    %ebp
  8020da:	89 c3                	mov    %eax,%ebx
  8020dc:	89 d8                	mov    %ebx,%eax
  8020de:	89 fa                	mov    %edi,%edx
  8020e0:	83 c4 1c             	add    $0x1c,%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5f                   	pop    %edi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    
  8020e8:	90                   	nop
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	39 ce                	cmp    %ecx,%esi
  8020f2:	77 74                	ja     802168 <__udivdi3+0xd8>
  8020f4:	0f bd fe             	bsr    %esi,%edi
  8020f7:	83 f7 1f             	xor    $0x1f,%edi
  8020fa:	0f 84 98 00 00 00    	je     802198 <__udivdi3+0x108>
  802100:	bb 20 00 00 00       	mov    $0x20,%ebx
  802105:	89 f9                	mov    %edi,%ecx
  802107:	89 c5                	mov    %eax,%ebp
  802109:	29 fb                	sub    %edi,%ebx
  80210b:	d3 e6                	shl    %cl,%esi
  80210d:	89 d9                	mov    %ebx,%ecx
  80210f:	d3 ed                	shr    %cl,%ebp
  802111:	89 f9                	mov    %edi,%ecx
  802113:	d3 e0                	shl    %cl,%eax
  802115:	09 ee                	or     %ebp,%esi
  802117:	89 d9                	mov    %ebx,%ecx
  802119:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80211d:	89 d5                	mov    %edx,%ebp
  80211f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802123:	d3 ed                	shr    %cl,%ebp
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e2                	shl    %cl,%edx
  802129:	89 d9                	mov    %ebx,%ecx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	09 c2                	or     %eax,%edx
  80212f:	89 d0                	mov    %edx,%eax
  802131:	89 ea                	mov    %ebp,%edx
  802133:	f7 f6                	div    %esi
  802135:	89 d5                	mov    %edx,%ebp
  802137:	89 c3                	mov    %eax,%ebx
  802139:	f7 64 24 0c          	mull   0xc(%esp)
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	72 10                	jb     802151 <__udivdi3+0xc1>
  802141:	8b 74 24 08          	mov    0x8(%esp),%esi
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e6                	shl    %cl,%esi
  802149:	39 c6                	cmp    %eax,%esi
  80214b:	73 07                	jae    802154 <__udivdi3+0xc4>
  80214d:	39 d5                	cmp    %edx,%ebp
  80214f:	75 03                	jne    802154 <__udivdi3+0xc4>
  802151:	83 eb 01             	sub    $0x1,%ebx
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 d8                	mov    %ebx,%eax
  802158:	89 fa                	mov    %edi,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	31 ff                	xor    %edi,%edi
  80216a:	31 db                	xor    %ebx,%ebx
  80216c:	89 d8                	mov    %ebx,%eax
  80216e:	89 fa                	mov    %edi,%edx
  802170:	83 c4 1c             	add    $0x1c,%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 d8                	mov    %ebx,%eax
  802182:	f7 f7                	div    %edi
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 c3                	mov    %eax,%ebx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 fa                	mov    %edi,%edx
  80218c:	83 c4 1c             	add    $0x1c,%esp
  80218f:	5b                   	pop    %ebx
  802190:	5e                   	pop    %esi
  802191:	5f                   	pop    %edi
  802192:	5d                   	pop    %ebp
  802193:	c3                   	ret    
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	39 ce                	cmp    %ecx,%esi
  80219a:	72 0c                	jb     8021a8 <__udivdi3+0x118>
  80219c:	31 db                	xor    %ebx,%ebx
  80219e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021a2:	0f 87 34 ff ff ff    	ja     8020dc <__udivdi3+0x4c>
  8021a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ad:	e9 2a ff ff ff       	jmp    8020dc <__udivdi3+0x4c>
  8021b2:	66 90                	xchg   %ax,%ax
  8021b4:	66 90                	xchg   %ax,%ax
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__umoddi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021d7:	85 d2                	test   %edx,%edx
  8021d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021e1:	89 f3                	mov    %esi,%ebx
  8021e3:	89 3c 24             	mov    %edi,(%esp)
  8021e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ea:	75 1c                	jne    802208 <__umoddi3+0x48>
  8021ec:	39 f7                	cmp    %esi,%edi
  8021ee:	76 50                	jbe    802240 <__umoddi3+0x80>
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	f7 f7                	div    %edi
  8021f6:	89 d0                	mov    %edx,%eax
  8021f8:	31 d2                	xor    %edx,%edx
  8021fa:	83 c4 1c             	add    $0x1c,%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5f                   	pop    %edi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    
  802202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802208:	39 f2                	cmp    %esi,%edx
  80220a:	89 d0                	mov    %edx,%eax
  80220c:	77 52                	ja     802260 <__umoddi3+0xa0>
  80220e:	0f bd ea             	bsr    %edx,%ebp
  802211:	83 f5 1f             	xor    $0x1f,%ebp
  802214:	75 5a                	jne    802270 <__umoddi3+0xb0>
  802216:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80221a:	0f 82 e0 00 00 00    	jb     802300 <__umoddi3+0x140>
  802220:	39 0c 24             	cmp    %ecx,(%esp)
  802223:	0f 86 d7 00 00 00    	jbe    802300 <__umoddi3+0x140>
  802229:	8b 44 24 08          	mov    0x8(%esp),%eax
  80222d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802231:	83 c4 1c             	add    $0x1c,%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5f                   	pop    %edi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	85 ff                	test   %edi,%edi
  802242:	89 fd                	mov    %edi,%ebp
  802244:	75 0b                	jne    802251 <__umoddi3+0x91>
  802246:	b8 01 00 00 00       	mov    $0x1,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	f7 f7                	div    %edi
  80224f:	89 c5                	mov    %eax,%ebp
  802251:	89 f0                	mov    %esi,%eax
  802253:	31 d2                	xor    %edx,%edx
  802255:	f7 f5                	div    %ebp
  802257:	89 c8                	mov    %ecx,%eax
  802259:	f7 f5                	div    %ebp
  80225b:	89 d0                	mov    %edx,%eax
  80225d:	eb 99                	jmp    8021f8 <__umoddi3+0x38>
  80225f:	90                   	nop
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	83 c4 1c             	add    $0x1c,%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5f                   	pop    %edi
  80226a:	5d                   	pop    %ebp
  80226b:	c3                   	ret    
  80226c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802270:	8b 34 24             	mov    (%esp),%esi
  802273:	bf 20 00 00 00       	mov    $0x20,%edi
  802278:	89 e9                	mov    %ebp,%ecx
  80227a:	29 ef                	sub    %ebp,%edi
  80227c:	d3 e0                	shl    %cl,%eax
  80227e:	89 f9                	mov    %edi,%ecx
  802280:	89 f2                	mov    %esi,%edx
  802282:	d3 ea                	shr    %cl,%edx
  802284:	89 e9                	mov    %ebp,%ecx
  802286:	09 c2                	or     %eax,%edx
  802288:	89 d8                	mov    %ebx,%eax
  80228a:	89 14 24             	mov    %edx,(%esp)
  80228d:	89 f2                	mov    %esi,%edx
  80228f:	d3 e2                	shl    %cl,%edx
  802291:	89 f9                	mov    %edi,%ecx
  802293:	89 54 24 04          	mov    %edx,0x4(%esp)
  802297:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80229b:	d3 e8                	shr    %cl,%eax
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	89 c6                	mov    %eax,%esi
  8022a1:	d3 e3                	shl    %cl,%ebx
  8022a3:	89 f9                	mov    %edi,%ecx
  8022a5:	89 d0                	mov    %edx,%eax
  8022a7:	d3 e8                	shr    %cl,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	09 d8                	or     %ebx,%eax
  8022ad:	89 d3                	mov    %edx,%ebx
  8022af:	89 f2                	mov    %esi,%edx
  8022b1:	f7 34 24             	divl   (%esp)
  8022b4:	89 d6                	mov    %edx,%esi
  8022b6:	d3 e3                	shl    %cl,%ebx
  8022b8:	f7 64 24 04          	mull   0x4(%esp)
  8022bc:	39 d6                	cmp    %edx,%esi
  8022be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022c2:	89 d1                	mov    %edx,%ecx
  8022c4:	89 c3                	mov    %eax,%ebx
  8022c6:	72 08                	jb     8022d0 <__umoddi3+0x110>
  8022c8:	75 11                	jne    8022db <__umoddi3+0x11b>
  8022ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ce:	73 0b                	jae    8022db <__umoddi3+0x11b>
  8022d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022d4:	1b 14 24             	sbb    (%esp),%edx
  8022d7:	89 d1                	mov    %edx,%ecx
  8022d9:	89 c3                	mov    %eax,%ebx
  8022db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022df:	29 da                	sub    %ebx,%edx
  8022e1:	19 ce                	sbb    %ecx,%esi
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 f0                	mov    %esi,%eax
  8022e7:	d3 e0                	shl    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	d3 ea                	shr    %cl,%edx
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	d3 ee                	shr    %cl,%esi
  8022f1:	09 d0                	or     %edx,%eax
  8022f3:	89 f2                	mov    %esi,%edx
  8022f5:	83 c4 1c             	add    $0x1c,%esp
  8022f8:	5b                   	pop    %ebx
  8022f9:	5e                   	pop    %esi
  8022fa:	5f                   	pop    %edi
  8022fb:	5d                   	pop    %ebp
  8022fc:	c3                   	ret    
  8022fd:	8d 76 00             	lea    0x0(%esi),%esi
  802300:	29 f9                	sub    %edi,%ecx
  802302:	19 d6                	sbb    %edx,%esi
  802304:	89 74 24 04          	mov    %esi,0x4(%esp)
  802308:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80230c:	e9 18 ff ff ff       	jmp    802229 <__umoddi3+0x69>
