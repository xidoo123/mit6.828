
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
  800039:	68 c2 03 80 00       	push   $0x8003c2
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
  8000a0:	e8 0c 05 00 00       	call   8005b1 <close_all>
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
  800119:	68 ea 22 80 00       	push   $0x8022ea
  80011e:	6a 23                	push   $0x23
  800120:	68 07 23 80 00       	push   $0x802307
  800125:	e8 00 14 00 00       	call   80152a <_panic>

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
  80019a:	68 ea 22 80 00       	push   $0x8022ea
  80019f:	6a 23                	push   $0x23
  8001a1:	68 07 23 80 00       	push   $0x802307
  8001a6:	e8 7f 13 00 00       	call   80152a <_panic>

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
  8001dc:	68 ea 22 80 00       	push   $0x8022ea
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 07 23 80 00       	push   $0x802307
  8001e8:	e8 3d 13 00 00       	call   80152a <_panic>

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
  80021e:	68 ea 22 80 00       	push   $0x8022ea
  800223:	6a 23                	push   $0x23
  800225:	68 07 23 80 00       	push   $0x802307
  80022a:	e8 fb 12 00 00       	call   80152a <_panic>

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
  800260:	68 ea 22 80 00       	push   $0x8022ea
  800265:	6a 23                	push   $0x23
  800267:	68 07 23 80 00       	push   $0x802307
  80026c:	e8 b9 12 00 00       	call   80152a <_panic>

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
  8002a2:	68 ea 22 80 00       	push   $0x8022ea
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 07 23 80 00       	push   $0x802307
  8002ae:	e8 77 12 00 00       	call   80152a <_panic>

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
  8002e4:	68 ea 22 80 00       	push   $0x8022ea
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 07 23 80 00       	push   $0x802307
  8002f0:	e8 35 12 00 00       	call   80152a <_panic>

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
  800348:	68 ea 22 80 00       	push   $0x8022ea
  80034d:	6a 23                	push   $0x23
  80034f:	68 07 23 80 00       	push   $0x802307
  800354:	e8 d1 11 00 00       	call   80152a <_panic>

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
  8003a9:	68 ea 22 80 00       	push   $0x8022ea
  8003ae:	6a 23                	push   $0x23
  8003b0:	68 07 23 80 00       	push   $0x802307
  8003b5:	e8 70 11 00 00       	call   80152a <_panic>

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

008003c2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003c2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003c3:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8003c8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003ca:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8003cd:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8003d1:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8003d5:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8003d8:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8003db:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8003dc:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8003df:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8003e0:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8003e1:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8003e5:	c3                   	ret    

008003e6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ec:	05 00 00 00 30       	add    $0x30000000,%eax
  8003f1:	c1 e8 0c             	shr    $0xc,%eax
}
  8003f4:	5d                   	pop    %ebp
  8003f5:	c3                   	ret    

008003f6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fc:	05 00 00 00 30       	add    $0x30000000,%eax
  800401:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800406:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80040b:	5d                   	pop    %ebp
  80040c:	c3                   	ret    

0080040d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800413:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800418:	89 c2                	mov    %eax,%edx
  80041a:	c1 ea 16             	shr    $0x16,%edx
  80041d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800424:	f6 c2 01             	test   $0x1,%dl
  800427:	74 11                	je     80043a <fd_alloc+0x2d>
  800429:	89 c2                	mov    %eax,%edx
  80042b:	c1 ea 0c             	shr    $0xc,%edx
  80042e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800435:	f6 c2 01             	test   $0x1,%dl
  800438:	75 09                	jne    800443 <fd_alloc+0x36>
			*fd_store = fd;
  80043a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	eb 17                	jmp    80045a <fd_alloc+0x4d>
  800443:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800448:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80044d:	75 c9                	jne    800418 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80044f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800455:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80045a:	5d                   	pop    %ebp
  80045b:	c3                   	ret    

0080045c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800462:	83 f8 1f             	cmp    $0x1f,%eax
  800465:	77 36                	ja     80049d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800467:	c1 e0 0c             	shl    $0xc,%eax
  80046a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80046f:	89 c2                	mov    %eax,%edx
  800471:	c1 ea 16             	shr    $0x16,%edx
  800474:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80047b:	f6 c2 01             	test   $0x1,%dl
  80047e:	74 24                	je     8004a4 <fd_lookup+0x48>
  800480:	89 c2                	mov    %eax,%edx
  800482:	c1 ea 0c             	shr    $0xc,%edx
  800485:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80048c:	f6 c2 01             	test   $0x1,%dl
  80048f:	74 1a                	je     8004ab <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800491:	8b 55 0c             	mov    0xc(%ebp),%edx
  800494:	89 02                	mov    %eax,(%edx)
	return 0;
  800496:	b8 00 00 00 00       	mov    $0x0,%eax
  80049b:	eb 13                	jmp    8004b0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80049d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a2:	eb 0c                	jmp    8004b0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a9:	eb 05                	jmp    8004b0 <fd_lookup+0x54>
  8004ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004b0:	5d                   	pop    %ebp
  8004b1:	c3                   	ret    

008004b2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004bb:	ba 94 23 80 00       	mov    $0x802394,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004c0:	eb 13                	jmp    8004d5 <dev_lookup+0x23>
  8004c2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004c5:	39 08                	cmp    %ecx,(%eax)
  8004c7:	75 0c                	jne    8004d5 <dev_lookup+0x23>
			*dev = devtab[i];
  8004c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004cc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d3:	eb 2e                	jmp    800503 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004d5:	8b 02                	mov    (%edx),%eax
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	75 e7                	jne    8004c2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004db:	a1 08 40 80 00       	mov    0x804008,%eax
  8004e0:	8b 40 48             	mov    0x48(%eax),%eax
  8004e3:	83 ec 04             	sub    $0x4,%esp
  8004e6:	51                   	push   %ecx
  8004e7:	50                   	push   %eax
  8004e8:	68 18 23 80 00       	push   $0x802318
  8004ed:	e8 11 11 00 00       	call   801603 <cprintf>
	*dev = 0;
  8004f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800503:	c9                   	leave  
  800504:	c3                   	ret    

00800505 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	56                   	push   %esi
  800509:	53                   	push   %ebx
  80050a:	83 ec 10             	sub    $0x10,%esp
  80050d:	8b 75 08             	mov    0x8(%ebp),%esi
  800510:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800513:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800516:	50                   	push   %eax
  800517:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80051d:	c1 e8 0c             	shr    $0xc,%eax
  800520:	50                   	push   %eax
  800521:	e8 36 ff ff ff       	call   80045c <fd_lookup>
  800526:	83 c4 08             	add    $0x8,%esp
  800529:	85 c0                	test   %eax,%eax
  80052b:	78 05                	js     800532 <fd_close+0x2d>
	    || fd != fd2)
  80052d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800530:	74 0c                	je     80053e <fd_close+0x39>
		return (must_exist ? r : 0);
  800532:	84 db                	test   %bl,%bl
  800534:	ba 00 00 00 00       	mov    $0x0,%edx
  800539:	0f 44 c2             	cmove  %edx,%eax
  80053c:	eb 41                	jmp    80057f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800544:	50                   	push   %eax
  800545:	ff 36                	pushl  (%esi)
  800547:	e8 66 ff ff ff       	call   8004b2 <dev_lookup>
  80054c:	89 c3                	mov    %eax,%ebx
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	85 c0                	test   %eax,%eax
  800553:	78 1a                	js     80056f <fd_close+0x6a>
		if (dev->dev_close)
  800555:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800558:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80055b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800560:	85 c0                	test   %eax,%eax
  800562:	74 0b                	je     80056f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800564:	83 ec 0c             	sub    $0xc,%esp
  800567:	56                   	push   %esi
  800568:	ff d0                	call   *%eax
  80056a:	89 c3                	mov    %eax,%ebx
  80056c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	56                   	push   %esi
  800573:	6a 00                	push   $0x0
  800575:	e8 7b fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  80057a:	83 c4 10             	add    $0x10,%esp
  80057d:	89 d8                	mov    %ebx,%eax
}
  80057f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800582:	5b                   	pop    %ebx
  800583:	5e                   	pop    %esi
  800584:	5d                   	pop    %ebp
  800585:	c3                   	ret    

00800586 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800586:	55                   	push   %ebp
  800587:	89 e5                	mov    %esp,%ebp
  800589:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80058c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80058f:	50                   	push   %eax
  800590:	ff 75 08             	pushl  0x8(%ebp)
  800593:	e8 c4 fe ff ff       	call   80045c <fd_lookup>
  800598:	83 c4 08             	add    $0x8,%esp
  80059b:	85 c0                	test   %eax,%eax
  80059d:	78 10                	js     8005af <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	6a 01                	push   $0x1
  8005a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8005a7:	e8 59 ff ff ff       	call   800505 <fd_close>
  8005ac:	83 c4 10             	add    $0x10,%esp
}
  8005af:	c9                   	leave  
  8005b0:	c3                   	ret    

008005b1 <close_all>:

void
close_all(void)
{
  8005b1:	55                   	push   %ebp
  8005b2:	89 e5                	mov    %esp,%ebp
  8005b4:	53                   	push   %ebx
  8005b5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005b8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005bd:	83 ec 0c             	sub    $0xc,%esp
  8005c0:	53                   	push   %ebx
  8005c1:	e8 c0 ff ff ff       	call   800586 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005c6:	83 c3 01             	add    $0x1,%ebx
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	83 fb 20             	cmp    $0x20,%ebx
  8005cf:	75 ec                	jne    8005bd <close_all+0xc>
		close(i);
}
  8005d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005d4:	c9                   	leave  
  8005d5:	c3                   	ret    

008005d6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005d6:	55                   	push   %ebp
  8005d7:	89 e5                	mov    %esp,%ebp
  8005d9:	57                   	push   %edi
  8005da:	56                   	push   %esi
  8005db:	53                   	push   %ebx
  8005dc:	83 ec 2c             	sub    $0x2c,%esp
  8005df:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005e2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005e5:	50                   	push   %eax
  8005e6:	ff 75 08             	pushl  0x8(%ebp)
  8005e9:	e8 6e fe ff ff       	call   80045c <fd_lookup>
  8005ee:	83 c4 08             	add    $0x8,%esp
  8005f1:	85 c0                	test   %eax,%eax
  8005f3:	0f 88 c1 00 00 00    	js     8006ba <dup+0xe4>
		return r;
	close(newfdnum);
  8005f9:	83 ec 0c             	sub    $0xc,%esp
  8005fc:	56                   	push   %esi
  8005fd:	e8 84 ff ff ff       	call   800586 <close>

	newfd = INDEX2FD(newfdnum);
  800602:	89 f3                	mov    %esi,%ebx
  800604:	c1 e3 0c             	shl    $0xc,%ebx
  800607:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80060d:	83 c4 04             	add    $0x4,%esp
  800610:	ff 75 e4             	pushl  -0x1c(%ebp)
  800613:	e8 de fd ff ff       	call   8003f6 <fd2data>
  800618:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80061a:	89 1c 24             	mov    %ebx,(%esp)
  80061d:	e8 d4 fd ff ff       	call   8003f6 <fd2data>
  800622:	83 c4 10             	add    $0x10,%esp
  800625:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800628:	89 f8                	mov    %edi,%eax
  80062a:	c1 e8 16             	shr    $0x16,%eax
  80062d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800634:	a8 01                	test   $0x1,%al
  800636:	74 37                	je     80066f <dup+0x99>
  800638:	89 f8                	mov    %edi,%eax
  80063a:	c1 e8 0c             	shr    $0xc,%eax
  80063d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800644:	f6 c2 01             	test   $0x1,%dl
  800647:	74 26                	je     80066f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800649:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800650:	83 ec 0c             	sub    $0xc,%esp
  800653:	25 07 0e 00 00       	and    $0xe07,%eax
  800658:	50                   	push   %eax
  800659:	ff 75 d4             	pushl  -0x2c(%ebp)
  80065c:	6a 00                	push   $0x0
  80065e:	57                   	push   %edi
  80065f:	6a 00                	push   $0x0
  800661:	e8 4d fb ff ff       	call   8001b3 <sys_page_map>
  800666:	89 c7                	mov    %eax,%edi
  800668:	83 c4 20             	add    $0x20,%esp
  80066b:	85 c0                	test   %eax,%eax
  80066d:	78 2e                	js     80069d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80066f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800672:	89 d0                	mov    %edx,%eax
  800674:	c1 e8 0c             	shr    $0xc,%eax
  800677:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80067e:	83 ec 0c             	sub    $0xc,%esp
  800681:	25 07 0e 00 00       	and    $0xe07,%eax
  800686:	50                   	push   %eax
  800687:	53                   	push   %ebx
  800688:	6a 00                	push   $0x0
  80068a:	52                   	push   %edx
  80068b:	6a 00                	push   $0x0
  80068d:	e8 21 fb ff ff       	call   8001b3 <sys_page_map>
  800692:	89 c7                	mov    %eax,%edi
  800694:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800697:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800699:	85 ff                	test   %edi,%edi
  80069b:	79 1d                	jns    8006ba <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 00                	push   $0x0
  8006a3:	e8 4d fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006a8:	83 c4 08             	add    $0x8,%esp
  8006ab:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006ae:	6a 00                	push   $0x0
  8006b0:	e8 40 fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	89 f8                	mov    %edi,%eax
}
  8006ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006bd:	5b                   	pop    %ebx
  8006be:	5e                   	pop    %esi
  8006bf:	5f                   	pop    %edi
  8006c0:	5d                   	pop    %ebp
  8006c1:	c3                   	ret    

008006c2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	53                   	push   %ebx
  8006c6:	83 ec 14             	sub    $0x14,%esp
  8006c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006cf:	50                   	push   %eax
  8006d0:	53                   	push   %ebx
  8006d1:	e8 86 fd ff ff       	call   80045c <fd_lookup>
  8006d6:	83 c4 08             	add    $0x8,%esp
  8006d9:	89 c2                	mov    %eax,%edx
  8006db:	85 c0                	test   %eax,%eax
  8006dd:	78 6d                	js     80074c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006e5:	50                   	push   %eax
  8006e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006e9:	ff 30                	pushl  (%eax)
  8006eb:	e8 c2 fd ff ff       	call   8004b2 <dev_lookup>
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	78 4c                	js     800743 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006fa:	8b 42 08             	mov    0x8(%edx),%eax
  8006fd:	83 e0 03             	and    $0x3,%eax
  800700:	83 f8 01             	cmp    $0x1,%eax
  800703:	75 21                	jne    800726 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800705:	a1 08 40 80 00       	mov    0x804008,%eax
  80070a:	8b 40 48             	mov    0x48(%eax),%eax
  80070d:	83 ec 04             	sub    $0x4,%esp
  800710:	53                   	push   %ebx
  800711:	50                   	push   %eax
  800712:	68 59 23 80 00       	push   $0x802359
  800717:	e8 e7 0e 00 00       	call   801603 <cprintf>
		return -E_INVAL;
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800724:	eb 26                	jmp    80074c <read+0x8a>
	}
	if (!dev->dev_read)
  800726:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800729:	8b 40 08             	mov    0x8(%eax),%eax
  80072c:	85 c0                	test   %eax,%eax
  80072e:	74 17                	je     800747 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800730:	83 ec 04             	sub    $0x4,%esp
  800733:	ff 75 10             	pushl  0x10(%ebp)
  800736:	ff 75 0c             	pushl  0xc(%ebp)
  800739:	52                   	push   %edx
  80073a:	ff d0                	call   *%eax
  80073c:	89 c2                	mov    %eax,%edx
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	eb 09                	jmp    80074c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800743:	89 c2                	mov    %eax,%edx
  800745:	eb 05                	jmp    80074c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800747:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80074c:	89 d0                	mov    %edx,%eax
  80074e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	57                   	push   %edi
  800757:	56                   	push   %esi
  800758:	53                   	push   %ebx
  800759:	83 ec 0c             	sub    $0xc,%esp
  80075c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80075f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800762:	bb 00 00 00 00       	mov    $0x0,%ebx
  800767:	eb 21                	jmp    80078a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800769:	83 ec 04             	sub    $0x4,%esp
  80076c:	89 f0                	mov    %esi,%eax
  80076e:	29 d8                	sub    %ebx,%eax
  800770:	50                   	push   %eax
  800771:	89 d8                	mov    %ebx,%eax
  800773:	03 45 0c             	add    0xc(%ebp),%eax
  800776:	50                   	push   %eax
  800777:	57                   	push   %edi
  800778:	e8 45 ff ff ff       	call   8006c2 <read>
		if (m < 0)
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	85 c0                	test   %eax,%eax
  800782:	78 10                	js     800794 <readn+0x41>
			return m;
		if (m == 0)
  800784:	85 c0                	test   %eax,%eax
  800786:	74 0a                	je     800792 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800788:	01 c3                	add    %eax,%ebx
  80078a:	39 f3                	cmp    %esi,%ebx
  80078c:	72 db                	jb     800769 <readn+0x16>
  80078e:	89 d8                	mov    %ebx,%eax
  800790:	eb 02                	jmp    800794 <readn+0x41>
  800792:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800794:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800797:	5b                   	pop    %ebx
  800798:	5e                   	pop    %esi
  800799:	5f                   	pop    %edi
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	53                   	push   %ebx
  8007a0:	83 ec 14             	sub    $0x14,%esp
  8007a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a9:	50                   	push   %eax
  8007aa:	53                   	push   %ebx
  8007ab:	e8 ac fc ff ff       	call   80045c <fd_lookup>
  8007b0:	83 c4 08             	add    $0x8,%esp
  8007b3:	89 c2                	mov    %eax,%edx
  8007b5:	85 c0                	test   %eax,%eax
  8007b7:	78 68                	js     800821 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007bf:	50                   	push   %eax
  8007c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c3:	ff 30                	pushl  (%eax)
  8007c5:	e8 e8 fc ff ff       	call   8004b2 <dev_lookup>
  8007ca:	83 c4 10             	add    $0x10,%esp
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	78 47                	js     800818 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007d8:	75 21                	jne    8007fb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007da:	a1 08 40 80 00       	mov    0x804008,%eax
  8007df:	8b 40 48             	mov    0x48(%eax),%eax
  8007e2:	83 ec 04             	sub    $0x4,%esp
  8007e5:	53                   	push   %ebx
  8007e6:	50                   	push   %eax
  8007e7:	68 75 23 80 00       	push   $0x802375
  8007ec:	e8 12 0e 00 00       	call   801603 <cprintf>
		return -E_INVAL;
  8007f1:	83 c4 10             	add    $0x10,%esp
  8007f4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007f9:	eb 26                	jmp    800821 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007fe:	8b 52 0c             	mov    0xc(%edx),%edx
  800801:	85 d2                	test   %edx,%edx
  800803:	74 17                	je     80081c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	ff 75 10             	pushl  0x10(%ebp)
  80080b:	ff 75 0c             	pushl  0xc(%ebp)
  80080e:	50                   	push   %eax
  80080f:	ff d2                	call   *%edx
  800811:	89 c2                	mov    %eax,%edx
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	eb 09                	jmp    800821 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800818:	89 c2                	mov    %eax,%edx
  80081a:	eb 05                	jmp    800821 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80081c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800821:	89 d0                	mov    %edx,%eax
  800823:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800826:	c9                   	leave  
  800827:	c3                   	ret    

00800828 <seek>:

int
seek(int fdnum, off_t offset)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80082e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800831:	50                   	push   %eax
  800832:	ff 75 08             	pushl  0x8(%ebp)
  800835:	e8 22 fc ff ff       	call   80045c <fd_lookup>
  80083a:	83 c4 08             	add    $0x8,%esp
  80083d:	85 c0                	test   %eax,%eax
  80083f:	78 0e                	js     80084f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800841:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
  800847:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80084a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80084f:	c9                   	leave  
  800850:	c3                   	ret    

00800851 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	83 ec 14             	sub    $0x14,%esp
  800858:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80085b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085e:	50                   	push   %eax
  80085f:	53                   	push   %ebx
  800860:	e8 f7 fb ff ff       	call   80045c <fd_lookup>
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	89 c2                	mov    %eax,%edx
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 65                	js     8008d3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800878:	ff 30                	pushl  (%eax)
  80087a:	e8 33 fc ff ff       	call   8004b2 <dev_lookup>
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 44                	js     8008ca <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800886:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800889:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80088d:	75 21                	jne    8008b0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80088f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800894:	8b 40 48             	mov    0x48(%eax),%eax
  800897:	83 ec 04             	sub    $0x4,%esp
  80089a:	53                   	push   %ebx
  80089b:	50                   	push   %eax
  80089c:	68 38 23 80 00       	push   $0x802338
  8008a1:	e8 5d 0d 00 00       	call   801603 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008a6:	83 c4 10             	add    $0x10,%esp
  8008a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008ae:	eb 23                	jmp    8008d3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008b3:	8b 52 18             	mov    0x18(%edx),%edx
  8008b6:	85 d2                	test   %edx,%edx
  8008b8:	74 14                	je     8008ce <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008ba:	83 ec 08             	sub    $0x8,%esp
  8008bd:	ff 75 0c             	pushl  0xc(%ebp)
  8008c0:	50                   	push   %eax
  8008c1:	ff d2                	call   *%edx
  8008c3:	89 c2                	mov    %eax,%edx
  8008c5:	83 c4 10             	add    $0x10,%esp
  8008c8:	eb 09                	jmp    8008d3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ca:	89 c2                	mov    %eax,%edx
  8008cc:	eb 05                	jmp    8008d3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008d3:	89 d0                	mov    %edx,%eax
  8008d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d8:	c9                   	leave  
  8008d9:	c3                   	ret    

008008da <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	53                   	push   %ebx
  8008de:	83 ec 14             	sub    $0x14,%esp
  8008e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008e7:	50                   	push   %eax
  8008e8:	ff 75 08             	pushl  0x8(%ebp)
  8008eb:	e8 6c fb ff ff       	call   80045c <fd_lookup>
  8008f0:	83 c4 08             	add    $0x8,%esp
  8008f3:	89 c2                	mov    %eax,%edx
  8008f5:	85 c0                	test   %eax,%eax
  8008f7:	78 58                	js     800951 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f9:	83 ec 08             	sub    $0x8,%esp
  8008fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ff:	50                   	push   %eax
  800900:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800903:	ff 30                	pushl  (%eax)
  800905:	e8 a8 fb ff ff       	call   8004b2 <dev_lookup>
  80090a:	83 c4 10             	add    $0x10,%esp
  80090d:	85 c0                	test   %eax,%eax
  80090f:	78 37                	js     800948 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800911:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800914:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800918:	74 32                	je     80094c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80091a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80091d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800924:	00 00 00 
	stat->st_isdir = 0;
  800927:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80092e:	00 00 00 
	stat->st_dev = dev;
  800931:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800937:	83 ec 08             	sub    $0x8,%esp
  80093a:	53                   	push   %ebx
  80093b:	ff 75 f0             	pushl  -0x10(%ebp)
  80093e:	ff 50 14             	call   *0x14(%eax)
  800941:	89 c2                	mov    %eax,%edx
  800943:	83 c4 10             	add    $0x10,%esp
  800946:	eb 09                	jmp    800951 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800948:	89 c2                	mov    %eax,%edx
  80094a:	eb 05                	jmp    800951 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80094c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800951:	89 d0                	mov    %edx,%eax
  800953:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80095d:	83 ec 08             	sub    $0x8,%esp
  800960:	6a 00                	push   $0x0
  800962:	ff 75 08             	pushl  0x8(%ebp)
  800965:	e8 d6 01 00 00       	call   800b40 <open>
  80096a:	89 c3                	mov    %eax,%ebx
  80096c:	83 c4 10             	add    $0x10,%esp
  80096f:	85 c0                	test   %eax,%eax
  800971:	78 1b                	js     80098e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800973:	83 ec 08             	sub    $0x8,%esp
  800976:	ff 75 0c             	pushl  0xc(%ebp)
  800979:	50                   	push   %eax
  80097a:	e8 5b ff ff ff       	call   8008da <fstat>
  80097f:	89 c6                	mov    %eax,%esi
	close(fd);
  800981:	89 1c 24             	mov    %ebx,(%esp)
  800984:	e8 fd fb ff ff       	call   800586 <close>
	return r;
  800989:	83 c4 10             	add    $0x10,%esp
  80098c:	89 f0                	mov    %esi,%eax
}
  80098e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800991:	5b                   	pop    %ebx
  800992:	5e                   	pop    %esi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	89 c6                	mov    %eax,%esi
  80099c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80099e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009a5:	75 12                	jne    8009b9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009a7:	83 ec 0c             	sub    $0xc,%esp
  8009aa:	6a 01                	push   $0x1
  8009ac:	e8 20 16 00 00       	call   801fd1 <ipc_find_env>
  8009b1:	a3 00 40 80 00       	mov    %eax,0x804000
  8009b6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009b9:	6a 07                	push   $0x7
  8009bb:	68 00 50 80 00       	push   $0x805000
  8009c0:	56                   	push   %esi
  8009c1:	ff 35 00 40 80 00    	pushl  0x804000
  8009c7:	e8 b1 15 00 00       	call   801f7d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009cc:	83 c4 0c             	add    $0xc,%esp
  8009cf:	6a 00                	push   $0x0
  8009d1:	53                   	push   %ebx
  8009d2:	6a 00                	push   $0x0
  8009d4:	e8 3d 15 00 00       	call   801f16 <ipc_recv>
}
  8009d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009dc:	5b                   	pop    %ebx
  8009dd:	5e                   	pop    %esi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ec:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fe:	b8 02 00 00 00       	mov    $0x2,%eax
  800a03:	e8 8d ff ff ff       	call   800995 <fsipc>
}
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	8b 40 0c             	mov    0xc(%eax),%eax
  800a16:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a20:	b8 06 00 00 00       	mov    $0x6,%eax
  800a25:	e8 6b ff ff ff       	call   800995 <fsipc>
}
  800a2a:	c9                   	leave  
  800a2b:	c3                   	ret    

00800a2c <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	53                   	push   %ebx
  800a30:	83 ec 04             	sub    $0x4,%esp
  800a33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	8b 40 0c             	mov    0xc(%eax),%eax
  800a3c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a41:	ba 00 00 00 00       	mov    $0x0,%edx
  800a46:	b8 05 00 00 00       	mov    $0x5,%eax
  800a4b:	e8 45 ff ff ff       	call   800995 <fsipc>
  800a50:	85 c0                	test   %eax,%eax
  800a52:	78 2c                	js     800a80 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a54:	83 ec 08             	sub    $0x8,%esp
  800a57:	68 00 50 80 00       	push   $0x805000
  800a5c:	53                   	push   %ebx
  800a5d:	e8 26 11 00 00       	call   801b88 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a62:	a1 80 50 80 00       	mov    0x805080,%eax
  800a67:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a6d:	a1 84 50 80 00       	mov    0x805084,%eax
  800a72:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a78:	83 c4 10             	add    $0x10,%esp
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    

00800a85 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	83 ec 0c             	sub    $0xc,%esp
  800a8b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a91:	8b 52 0c             	mov    0xc(%edx),%edx
  800a94:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a9a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a9f:	50                   	push   %eax
  800aa0:	ff 75 0c             	pushl  0xc(%ebp)
  800aa3:	68 08 50 80 00       	push   $0x805008
  800aa8:	e8 6d 12 00 00       	call   801d1a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800aad:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ab7:	e8 d9 fe ff ff       	call   800995 <fsipc>

}
  800abc:	c9                   	leave  
  800abd:	c3                   	ret    

00800abe <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	8b 40 0c             	mov    0xc(%eax),%eax
  800acc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ad1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ad7:	ba 00 00 00 00       	mov    $0x0,%edx
  800adc:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae1:	e8 af fe ff ff       	call   800995 <fsipc>
  800ae6:	89 c3                	mov    %eax,%ebx
  800ae8:	85 c0                	test   %eax,%eax
  800aea:	78 4b                	js     800b37 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aec:	39 c6                	cmp    %eax,%esi
  800aee:	73 16                	jae    800b06 <devfile_read+0x48>
  800af0:	68 a8 23 80 00       	push   $0x8023a8
  800af5:	68 af 23 80 00       	push   $0x8023af
  800afa:	6a 7c                	push   $0x7c
  800afc:	68 c4 23 80 00       	push   $0x8023c4
  800b01:	e8 24 0a 00 00       	call   80152a <_panic>
	assert(r <= PGSIZE);
  800b06:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b0b:	7e 16                	jle    800b23 <devfile_read+0x65>
  800b0d:	68 cf 23 80 00       	push   $0x8023cf
  800b12:	68 af 23 80 00       	push   $0x8023af
  800b17:	6a 7d                	push   $0x7d
  800b19:	68 c4 23 80 00       	push   $0x8023c4
  800b1e:	e8 07 0a 00 00       	call   80152a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b23:	83 ec 04             	sub    $0x4,%esp
  800b26:	50                   	push   %eax
  800b27:	68 00 50 80 00       	push   $0x805000
  800b2c:	ff 75 0c             	pushl  0xc(%ebp)
  800b2f:	e8 e6 11 00 00       	call   801d1a <memmove>
	return r;
  800b34:	83 c4 10             	add    $0x10,%esp
}
  800b37:	89 d8                	mov    %ebx,%eax
  800b39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	53                   	push   %ebx
  800b44:	83 ec 20             	sub    $0x20,%esp
  800b47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b4a:	53                   	push   %ebx
  800b4b:	e8 ff 0f 00 00       	call   801b4f <strlen>
  800b50:	83 c4 10             	add    $0x10,%esp
  800b53:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b58:	7f 67                	jg     800bc1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b60:	50                   	push   %eax
  800b61:	e8 a7 f8 ff ff       	call   80040d <fd_alloc>
  800b66:	83 c4 10             	add    $0x10,%esp
		return r;
  800b69:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b6b:	85 c0                	test   %eax,%eax
  800b6d:	78 57                	js     800bc6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b6f:	83 ec 08             	sub    $0x8,%esp
  800b72:	53                   	push   %ebx
  800b73:	68 00 50 80 00       	push   $0x805000
  800b78:	e8 0b 10 00 00       	call   801b88 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b80:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b85:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b88:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8d:	e8 03 fe ff ff       	call   800995 <fsipc>
  800b92:	89 c3                	mov    %eax,%ebx
  800b94:	83 c4 10             	add    $0x10,%esp
  800b97:	85 c0                	test   %eax,%eax
  800b99:	79 14                	jns    800baf <open+0x6f>
		fd_close(fd, 0);
  800b9b:	83 ec 08             	sub    $0x8,%esp
  800b9e:	6a 00                	push   $0x0
  800ba0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ba3:	e8 5d f9 ff ff       	call   800505 <fd_close>
		return r;
  800ba8:	83 c4 10             	add    $0x10,%esp
  800bab:	89 da                	mov    %ebx,%edx
  800bad:	eb 17                	jmp    800bc6 <open+0x86>
	}

	return fd2num(fd);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	ff 75 f4             	pushl  -0xc(%ebp)
  800bb5:	e8 2c f8 ff ff       	call   8003e6 <fd2num>
  800bba:	89 c2                	mov    %eax,%edx
  800bbc:	83 c4 10             	add    $0x10,%esp
  800bbf:	eb 05                	jmp    800bc6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bc1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bc6:	89 d0                	mov    %edx,%eax
  800bc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd8:	b8 08 00 00 00       	mov    $0x8,%eax
  800bdd:	e8 b3 fd ff ff       	call   800995 <fsipc>
}
  800be2:	c9                   	leave  
  800be3:	c3                   	ret    

00800be4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bea:	68 db 23 80 00       	push   $0x8023db
  800bef:	ff 75 0c             	pushl  0xc(%ebp)
  800bf2:	e8 91 0f 00 00       	call   801b88 <strcpy>
	return 0;
}
  800bf7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    

00800bfe <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	53                   	push   %ebx
  800c02:	83 ec 10             	sub    $0x10,%esp
  800c05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c08:	53                   	push   %ebx
  800c09:	e8 fc 13 00 00       	call   80200a <pageref>
  800c0e:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c11:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c16:	83 f8 01             	cmp    $0x1,%eax
  800c19:	75 10                	jne    800c2b <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c1b:	83 ec 0c             	sub    $0xc,%esp
  800c1e:	ff 73 0c             	pushl  0xc(%ebx)
  800c21:	e8 c0 02 00 00       	call   800ee6 <nsipc_close>
  800c26:	89 c2                	mov    %eax,%edx
  800c28:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c2b:	89 d0                	mov    %edx,%eax
  800c2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c30:	c9                   	leave  
  800c31:	c3                   	ret    

00800c32 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c38:	6a 00                	push   $0x0
  800c3a:	ff 75 10             	pushl  0x10(%ebp)
  800c3d:	ff 75 0c             	pushl  0xc(%ebp)
  800c40:	8b 45 08             	mov    0x8(%ebp),%eax
  800c43:	ff 70 0c             	pushl  0xc(%eax)
  800c46:	e8 78 03 00 00       	call   800fc3 <nsipc_send>
}
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    

00800c4d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c53:	6a 00                	push   $0x0
  800c55:	ff 75 10             	pushl  0x10(%ebp)
  800c58:	ff 75 0c             	pushl  0xc(%ebp)
  800c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5e:	ff 70 0c             	pushl  0xc(%eax)
  800c61:	e8 f1 02 00 00       	call   800f57 <nsipc_recv>
}
  800c66:	c9                   	leave  
  800c67:	c3                   	ret    

00800c68 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c6e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c71:	52                   	push   %edx
  800c72:	50                   	push   %eax
  800c73:	e8 e4 f7 ff ff       	call   80045c <fd_lookup>
  800c78:	83 c4 10             	add    $0x10,%esp
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	78 17                	js     800c96 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c82:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c88:	39 08                	cmp    %ecx,(%eax)
  800c8a:	75 05                	jne    800c91 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c8c:	8b 40 0c             	mov    0xc(%eax),%eax
  800c8f:	eb 05                	jmp    800c96 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c91:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c96:	c9                   	leave  
  800c97:	c3                   	ret    

00800c98 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 1c             	sub    $0x1c,%esp
  800ca0:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800ca2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca5:	50                   	push   %eax
  800ca6:	e8 62 f7 ff ff       	call   80040d <fd_alloc>
  800cab:	89 c3                	mov    %eax,%ebx
  800cad:	83 c4 10             	add    $0x10,%esp
  800cb0:	85 c0                	test   %eax,%eax
  800cb2:	78 1b                	js     800ccf <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cb4:	83 ec 04             	sub    $0x4,%esp
  800cb7:	68 07 04 00 00       	push   $0x407
  800cbc:	ff 75 f4             	pushl  -0xc(%ebp)
  800cbf:	6a 00                	push   $0x0
  800cc1:	e8 aa f4 ff ff       	call   800170 <sys_page_alloc>
  800cc6:	89 c3                	mov    %eax,%ebx
  800cc8:	83 c4 10             	add    $0x10,%esp
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	79 10                	jns    800cdf <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	56                   	push   %esi
  800cd3:	e8 0e 02 00 00       	call   800ee6 <nsipc_close>
		return r;
  800cd8:	83 c4 10             	add    $0x10,%esp
  800cdb:	89 d8                	mov    %ebx,%eax
  800cdd:	eb 24                	jmp    800d03 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800cdf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce8:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ced:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cf4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cf7:	83 ec 0c             	sub    $0xc,%esp
  800cfa:	50                   	push   %eax
  800cfb:	e8 e6 f6 ff ff       	call   8003e6 <fd2num>
  800d00:	83 c4 10             	add    $0x10,%esp
}
  800d03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d10:	8b 45 08             	mov    0x8(%ebp),%eax
  800d13:	e8 50 ff ff ff       	call   800c68 <fd2sockid>
		return r;
  800d18:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	78 1f                	js     800d3d <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d1e:	83 ec 04             	sub    $0x4,%esp
  800d21:	ff 75 10             	pushl  0x10(%ebp)
  800d24:	ff 75 0c             	pushl  0xc(%ebp)
  800d27:	50                   	push   %eax
  800d28:	e8 12 01 00 00       	call   800e3f <nsipc_accept>
  800d2d:	83 c4 10             	add    $0x10,%esp
		return r;
  800d30:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	78 07                	js     800d3d <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d36:	e8 5d ff ff ff       	call   800c98 <alloc_sockfd>
  800d3b:	89 c1                	mov    %eax,%ecx
}
  800d3d:	89 c8                	mov    %ecx,%eax
  800d3f:	c9                   	leave  
  800d40:	c3                   	ret    

00800d41 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d47:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4a:	e8 19 ff ff ff       	call   800c68 <fd2sockid>
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	78 12                	js     800d65 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d53:	83 ec 04             	sub    $0x4,%esp
  800d56:	ff 75 10             	pushl  0x10(%ebp)
  800d59:	ff 75 0c             	pushl  0xc(%ebp)
  800d5c:	50                   	push   %eax
  800d5d:	e8 2d 01 00 00       	call   800e8f <nsipc_bind>
  800d62:	83 c4 10             	add    $0x10,%esp
}
  800d65:	c9                   	leave  
  800d66:	c3                   	ret    

00800d67 <shutdown>:

int
shutdown(int s, int how)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	e8 f3 fe ff ff       	call   800c68 <fd2sockid>
  800d75:	85 c0                	test   %eax,%eax
  800d77:	78 0f                	js     800d88 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d79:	83 ec 08             	sub    $0x8,%esp
  800d7c:	ff 75 0c             	pushl  0xc(%ebp)
  800d7f:	50                   	push   %eax
  800d80:	e8 3f 01 00 00       	call   800ec4 <nsipc_shutdown>
  800d85:	83 c4 10             	add    $0x10,%esp
}
  800d88:	c9                   	leave  
  800d89:	c3                   	ret    

00800d8a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  800d93:	e8 d0 fe ff ff       	call   800c68 <fd2sockid>
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	78 12                	js     800dae <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d9c:	83 ec 04             	sub    $0x4,%esp
  800d9f:	ff 75 10             	pushl  0x10(%ebp)
  800da2:	ff 75 0c             	pushl  0xc(%ebp)
  800da5:	50                   	push   %eax
  800da6:	e8 55 01 00 00       	call   800f00 <nsipc_connect>
  800dab:	83 c4 10             	add    $0x10,%esp
}
  800dae:	c9                   	leave  
  800daf:	c3                   	ret    

00800db0 <listen>:

int
listen(int s, int backlog)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	e8 aa fe ff ff       	call   800c68 <fd2sockid>
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	78 0f                	js     800dd1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800dc2:	83 ec 08             	sub    $0x8,%esp
  800dc5:	ff 75 0c             	pushl  0xc(%ebp)
  800dc8:	50                   	push   %eax
  800dc9:	e8 67 01 00 00       	call   800f35 <nsipc_listen>
  800dce:	83 c4 10             	add    $0x10,%esp
}
  800dd1:	c9                   	leave  
  800dd2:	c3                   	ret    

00800dd3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800dd9:	ff 75 10             	pushl  0x10(%ebp)
  800ddc:	ff 75 0c             	pushl  0xc(%ebp)
  800ddf:	ff 75 08             	pushl  0x8(%ebp)
  800de2:	e8 3a 02 00 00       	call   801021 <nsipc_socket>
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	78 05                	js     800df3 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dee:	e8 a5 fe ff ff       	call   800c98 <alloc_sockfd>
}
  800df3:	c9                   	leave  
  800df4:	c3                   	ret    

00800df5 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	53                   	push   %ebx
  800df9:	83 ec 04             	sub    $0x4,%esp
  800dfc:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dfe:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e05:	75 12                	jne    800e19 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e07:	83 ec 0c             	sub    $0xc,%esp
  800e0a:	6a 02                	push   $0x2
  800e0c:	e8 c0 11 00 00       	call   801fd1 <ipc_find_env>
  800e11:	a3 04 40 80 00       	mov    %eax,0x804004
  800e16:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e19:	6a 07                	push   $0x7
  800e1b:	68 00 60 80 00       	push   $0x806000
  800e20:	53                   	push   %ebx
  800e21:	ff 35 04 40 80 00    	pushl  0x804004
  800e27:	e8 51 11 00 00       	call   801f7d <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e2c:	83 c4 0c             	add    $0xc,%esp
  800e2f:	6a 00                	push   $0x0
  800e31:	6a 00                	push   $0x0
  800e33:	6a 00                	push   $0x0
  800e35:	e8 dc 10 00 00       	call   801f16 <ipc_recv>
}
  800e3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e3d:	c9                   	leave  
  800e3e:	c3                   	ret    

00800e3f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e4f:	8b 06                	mov    (%esi),%eax
  800e51:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e56:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5b:	e8 95 ff ff ff       	call   800df5 <nsipc>
  800e60:	89 c3                	mov    %eax,%ebx
  800e62:	85 c0                	test   %eax,%eax
  800e64:	78 20                	js     800e86 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e66:	83 ec 04             	sub    $0x4,%esp
  800e69:	ff 35 10 60 80 00    	pushl  0x806010
  800e6f:	68 00 60 80 00       	push   $0x806000
  800e74:	ff 75 0c             	pushl  0xc(%ebp)
  800e77:	e8 9e 0e 00 00       	call   801d1a <memmove>
		*addrlen = ret->ret_addrlen;
  800e7c:	a1 10 60 80 00       	mov    0x806010,%eax
  800e81:	89 06                	mov    %eax,(%esi)
  800e83:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e86:	89 d8                	mov    %ebx,%eax
  800e88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	53                   	push   %ebx
  800e93:	83 ec 08             	sub    $0x8,%esp
  800e96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ea1:	53                   	push   %ebx
  800ea2:	ff 75 0c             	pushl  0xc(%ebp)
  800ea5:	68 04 60 80 00       	push   $0x806004
  800eaa:	e8 6b 0e 00 00       	call   801d1a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800eaf:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800eb5:	b8 02 00 00 00       	mov    $0x2,%eax
  800eba:	e8 36 ff ff ff       	call   800df5 <nsipc>
}
  800ebf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800eca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800ed2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800eda:	b8 03 00 00 00       	mov    $0x3,%eax
  800edf:	e8 11 ff ff ff       	call   800df5 <nsipc>
}
  800ee4:	c9                   	leave  
  800ee5:	c3                   	ret    

00800ee6 <nsipc_close>:

int
nsipc_close(int s)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eec:	8b 45 08             	mov    0x8(%ebp),%eax
  800eef:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ef4:	b8 04 00 00 00       	mov    $0x4,%eax
  800ef9:	e8 f7 fe ff ff       	call   800df5 <nsipc>
}
  800efe:	c9                   	leave  
  800eff:	c3                   	ret    

00800f00 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	53                   	push   %ebx
  800f04:	83 ec 08             	sub    $0x8,%esp
  800f07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f12:	53                   	push   %ebx
  800f13:	ff 75 0c             	pushl  0xc(%ebp)
  800f16:	68 04 60 80 00       	push   $0x806004
  800f1b:	e8 fa 0d 00 00       	call   801d1a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f20:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f26:	b8 05 00 00 00       	mov    $0x5,%eax
  800f2b:	e8 c5 fe ff ff       	call   800df5 <nsipc>
}
  800f30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f33:	c9                   	leave  
  800f34:	c3                   	ret    

00800f35 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f46:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f4b:	b8 06 00 00 00       	mov    $0x6,%eax
  800f50:	e8 a0 fe ff ff       	call   800df5 <nsipc>
}
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	56                   	push   %esi
  800f5b:	53                   	push   %ebx
  800f5c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f62:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f67:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f6d:	8b 45 14             	mov    0x14(%ebp),%eax
  800f70:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f75:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7a:	e8 76 fe ff ff       	call   800df5 <nsipc>
  800f7f:	89 c3                	mov    %eax,%ebx
  800f81:	85 c0                	test   %eax,%eax
  800f83:	78 35                	js     800fba <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f85:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f8a:	7f 04                	jg     800f90 <nsipc_recv+0x39>
  800f8c:	39 c6                	cmp    %eax,%esi
  800f8e:	7d 16                	jge    800fa6 <nsipc_recv+0x4f>
  800f90:	68 e7 23 80 00       	push   $0x8023e7
  800f95:	68 af 23 80 00       	push   $0x8023af
  800f9a:	6a 62                	push   $0x62
  800f9c:	68 fc 23 80 00       	push   $0x8023fc
  800fa1:	e8 84 05 00 00       	call   80152a <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800fa6:	83 ec 04             	sub    $0x4,%esp
  800fa9:	50                   	push   %eax
  800faa:	68 00 60 80 00       	push   $0x806000
  800faf:	ff 75 0c             	pushl  0xc(%ebp)
  800fb2:	e8 63 0d 00 00       	call   801d1a <memmove>
  800fb7:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800fba:	89 d8                	mov    %ebx,%eax
  800fbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fbf:	5b                   	pop    %ebx
  800fc0:	5e                   	pop    %esi
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    

00800fc3 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	53                   	push   %ebx
  800fc7:	83 ec 04             	sub    $0x4,%esp
  800fca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd0:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fd5:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fdb:	7e 16                	jle    800ff3 <nsipc_send+0x30>
  800fdd:	68 08 24 80 00       	push   $0x802408
  800fe2:	68 af 23 80 00       	push   $0x8023af
  800fe7:	6a 6d                	push   $0x6d
  800fe9:	68 fc 23 80 00       	push   $0x8023fc
  800fee:	e8 37 05 00 00       	call   80152a <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800ff3:	83 ec 04             	sub    $0x4,%esp
  800ff6:	53                   	push   %ebx
  800ff7:	ff 75 0c             	pushl  0xc(%ebp)
  800ffa:	68 0c 60 80 00       	push   $0x80600c
  800fff:	e8 16 0d 00 00       	call   801d1a <memmove>
	nsipcbuf.send.req_size = size;
  801004:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80100a:	8b 45 14             	mov    0x14(%ebp),%eax
  80100d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801012:	b8 08 00 00 00       	mov    $0x8,%eax
  801017:	e8 d9 fd ff ff       	call   800df5 <nsipc>
}
  80101c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801027:	8b 45 08             	mov    0x8(%ebp),%eax
  80102a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80102f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801032:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801037:	8b 45 10             	mov    0x10(%ebp),%eax
  80103a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80103f:	b8 09 00 00 00       	mov    $0x9,%eax
  801044:	e8 ac fd ff ff       	call   800df5 <nsipc>
}
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	56                   	push   %esi
  80104f:	53                   	push   %ebx
  801050:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801053:	83 ec 0c             	sub    $0xc,%esp
  801056:	ff 75 08             	pushl  0x8(%ebp)
  801059:	e8 98 f3 ff ff       	call   8003f6 <fd2data>
  80105e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801060:	83 c4 08             	add    $0x8,%esp
  801063:	68 14 24 80 00       	push   $0x802414
  801068:	53                   	push   %ebx
  801069:	e8 1a 0b 00 00       	call   801b88 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80106e:	8b 46 04             	mov    0x4(%esi),%eax
  801071:	2b 06                	sub    (%esi),%eax
  801073:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801079:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801080:	00 00 00 
	stat->st_dev = &devpipe;
  801083:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80108a:	30 80 00 
	return 0;
}
  80108d:	b8 00 00 00 00       	mov    $0x0,%eax
  801092:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801095:	5b                   	pop    %ebx
  801096:	5e                   	pop    %esi
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	53                   	push   %ebx
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010a3:	53                   	push   %ebx
  8010a4:	6a 00                	push   $0x0
  8010a6:	e8 4a f1 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010ab:	89 1c 24             	mov    %ebx,(%esp)
  8010ae:	e8 43 f3 ff ff       	call   8003f6 <fd2data>
  8010b3:	83 c4 08             	add    $0x8,%esp
  8010b6:	50                   	push   %eax
  8010b7:	6a 00                	push   $0x0
  8010b9:	e8 37 f1 ff ff       	call   8001f5 <sys_page_unmap>
}
  8010be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c1:	c9                   	leave  
  8010c2:	c3                   	ret    

008010c3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	57                   	push   %edi
  8010c7:	56                   	push   %esi
  8010c8:	53                   	push   %ebx
  8010c9:	83 ec 1c             	sub    $0x1c,%esp
  8010cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010cf:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010d1:	a1 08 40 80 00       	mov    0x804008,%eax
  8010d6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010d9:	83 ec 0c             	sub    $0xc,%esp
  8010dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8010df:	e8 26 0f 00 00       	call   80200a <pageref>
  8010e4:	89 c3                	mov    %eax,%ebx
  8010e6:	89 3c 24             	mov    %edi,(%esp)
  8010e9:	e8 1c 0f 00 00       	call   80200a <pageref>
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	39 c3                	cmp    %eax,%ebx
  8010f3:	0f 94 c1             	sete   %cl
  8010f6:	0f b6 c9             	movzbl %cl,%ecx
  8010f9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010fc:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801102:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801105:	39 ce                	cmp    %ecx,%esi
  801107:	74 1b                	je     801124 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801109:	39 c3                	cmp    %eax,%ebx
  80110b:	75 c4                	jne    8010d1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80110d:	8b 42 58             	mov    0x58(%edx),%eax
  801110:	ff 75 e4             	pushl  -0x1c(%ebp)
  801113:	50                   	push   %eax
  801114:	56                   	push   %esi
  801115:	68 1b 24 80 00       	push   $0x80241b
  80111a:	e8 e4 04 00 00       	call   801603 <cprintf>
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	eb ad                	jmp    8010d1 <_pipeisclosed+0xe>
	}
}
  801124:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112a:	5b                   	pop    %ebx
  80112b:	5e                   	pop    %esi
  80112c:	5f                   	pop    %edi
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    

0080112f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	57                   	push   %edi
  801133:	56                   	push   %esi
  801134:	53                   	push   %ebx
  801135:	83 ec 28             	sub    $0x28,%esp
  801138:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80113b:	56                   	push   %esi
  80113c:	e8 b5 f2 ff ff       	call   8003f6 <fd2data>
  801141:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	bf 00 00 00 00       	mov    $0x0,%edi
  80114b:	eb 4b                	jmp    801198 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80114d:	89 da                	mov    %ebx,%edx
  80114f:	89 f0                	mov    %esi,%eax
  801151:	e8 6d ff ff ff       	call   8010c3 <_pipeisclosed>
  801156:	85 c0                	test   %eax,%eax
  801158:	75 48                	jne    8011a2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80115a:	e8 f2 ef ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80115f:	8b 43 04             	mov    0x4(%ebx),%eax
  801162:	8b 0b                	mov    (%ebx),%ecx
  801164:	8d 51 20             	lea    0x20(%ecx),%edx
  801167:	39 d0                	cmp    %edx,%eax
  801169:	73 e2                	jae    80114d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80116b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801172:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801175:	89 c2                	mov    %eax,%edx
  801177:	c1 fa 1f             	sar    $0x1f,%edx
  80117a:	89 d1                	mov    %edx,%ecx
  80117c:	c1 e9 1b             	shr    $0x1b,%ecx
  80117f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801182:	83 e2 1f             	and    $0x1f,%edx
  801185:	29 ca                	sub    %ecx,%edx
  801187:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80118b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80118f:	83 c0 01             	add    $0x1,%eax
  801192:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801195:	83 c7 01             	add    $0x1,%edi
  801198:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80119b:	75 c2                	jne    80115f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80119d:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a0:	eb 05                	jmp    8011a7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011a2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011aa:	5b                   	pop    %ebx
  8011ab:	5e                   	pop    %esi
  8011ac:	5f                   	pop    %edi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	57                   	push   %edi
  8011b3:	56                   	push   %esi
  8011b4:	53                   	push   %ebx
  8011b5:	83 ec 18             	sub    $0x18,%esp
  8011b8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011bb:	57                   	push   %edi
  8011bc:	e8 35 f2 ff ff       	call   8003f6 <fd2data>
  8011c1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cb:	eb 3d                	jmp    80120a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011cd:	85 db                	test   %ebx,%ebx
  8011cf:	74 04                	je     8011d5 <devpipe_read+0x26>
				return i;
  8011d1:	89 d8                	mov    %ebx,%eax
  8011d3:	eb 44                	jmp    801219 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011d5:	89 f2                	mov    %esi,%edx
  8011d7:	89 f8                	mov    %edi,%eax
  8011d9:	e8 e5 fe ff ff       	call   8010c3 <_pipeisclosed>
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	75 32                	jne    801214 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011e2:	e8 6a ef ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011e7:	8b 06                	mov    (%esi),%eax
  8011e9:	3b 46 04             	cmp    0x4(%esi),%eax
  8011ec:	74 df                	je     8011cd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011ee:	99                   	cltd   
  8011ef:	c1 ea 1b             	shr    $0x1b,%edx
  8011f2:	01 d0                	add    %edx,%eax
  8011f4:	83 e0 1f             	and    $0x1f,%eax
  8011f7:	29 d0                	sub    %edx,%eax
  8011f9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801201:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801204:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801207:	83 c3 01             	add    $0x1,%ebx
  80120a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80120d:	75 d8                	jne    8011e7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80120f:	8b 45 10             	mov    0x10(%ebp),%eax
  801212:	eb 05                	jmp    801219 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801214:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121c:	5b                   	pop    %ebx
  80121d:	5e                   	pop    %esi
  80121e:	5f                   	pop    %edi
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	56                   	push   %esi
  801225:	53                   	push   %ebx
  801226:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801229:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122c:	50                   	push   %eax
  80122d:	e8 db f1 ff ff       	call   80040d <fd_alloc>
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	89 c2                	mov    %eax,%edx
  801237:	85 c0                	test   %eax,%eax
  801239:	0f 88 2c 01 00 00    	js     80136b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80123f:	83 ec 04             	sub    $0x4,%esp
  801242:	68 07 04 00 00       	push   $0x407
  801247:	ff 75 f4             	pushl  -0xc(%ebp)
  80124a:	6a 00                	push   $0x0
  80124c:	e8 1f ef ff ff       	call   800170 <sys_page_alloc>
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	89 c2                	mov    %eax,%edx
  801256:	85 c0                	test   %eax,%eax
  801258:	0f 88 0d 01 00 00    	js     80136b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80125e:	83 ec 0c             	sub    $0xc,%esp
  801261:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801264:	50                   	push   %eax
  801265:	e8 a3 f1 ff ff       	call   80040d <fd_alloc>
  80126a:	89 c3                	mov    %eax,%ebx
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	85 c0                	test   %eax,%eax
  801271:	0f 88 e2 00 00 00    	js     801359 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801277:	83 ec 04             	sub    $0x4,%esp
  80127a:	68 07 04 00 00       	push   $0x407
  80127f:	ff 75 f0             	pushl  -0x10(%ebp)
  801282:	6a 00                	push   $0x0
  801284:	e8 e7 ee ff ff       	call   800170 <sys_page_alloc>
  801289:	89 c3                	mov    %eax,%ebx
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	0f 88 c3 00 00 00    	js     801359 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801296:	83 ec 0c             	sub    $0xc,%esp
  801299:	ff 75 f4             	pushl  -0xc(%ebp)
  80129c:	e8 55 f1 ff ff       	call   8003f6 <fd2data>
  8012a1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012a3:	83 c4 0c             	add    $0xc,%esp
  8012a6:	68 07 04 00 00       	push   $0x407
  8012ab:	50                   	push   %eax
  8012ac:	6a 00                	push   $0x0
  8012ae:	e8 bd ee ff ff       	call   800170 <sys_page_alloc>
  8012b3:	89 c3                	mov    %eax,%ebx
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	0f 88 89 00 00 00    	js     801349 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012c0:	83 ec 0c             	sub    $0xc,%esp
  8012c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c6:	e8 2b f1 ff ff       	call   8003f6 <fd2data>
  8012cb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012d2:	50                   	push   %eax
  8012d3:	6a 00                	push   $0x0
  8012d5:	56                   	push   %esi
  8012d6:	6a 00                	push   $0x0
  8012d8:	e8 d6 ee ff ff       	call   8001b3 <sys_page_map>
  8012dd:	89 c3                	mov    %eax,%ebx
  8012df:	83 c4 20             	add    $0x20,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 55                	js     80133b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012e6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ef:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012fb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801301:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801304:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801306:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801309:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801310:	83 ec 0c             	sub    $0xc,%esp
  801313:	ff 75 f4             	pushl  -0xc(%ebp)
  801316:	e8 cb f0 ff ff       	call   8003e6 <fd2num>
  80131b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80131e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801320:	83 c4 04             	add    $0x4,%esp
  801323:	ff 75 f0             	pushl  -0x10(%ebp)
  801326:	e8 bb f0 ff ff       	call   8003e6 <fd2num>
  80132b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	ba 00 00 00 00       	mov    $0x0,%edx
  801339:	eb 30                	jmp    80136b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	56                   	push   %esi
  80133f:	6a 00                	push   $0x0
  801341:	e8 af ee ff ff       	call   8001f5 <sys_page_unmap>
  801346:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	ff 75 f0             	pushl  -0x10(%ebp)
  80134f:	6a 00                	push   $0x0
  801351:	e8 9f ee ff ff       	call   8001f5 <sys_page_unmap>
  801356:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801359:	83 ec 08             	sub    $0x8,%esp
  80135c:	ff 75 f4             	pushl  -0xc(%ebp)
  80135f:	6a 00                	push   $0x0
  801361:	e8 8f ee ff ff       	call   8001f5 <sys_page_unmap>
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80136b:	89 d0                	mov    %edx,%eax
  80136d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137d:	50                   	push   %eax
  80137e:	ff 75 08             	pushl  0x8(%ebp)
  801381:	e8 d6 f0 ff ff       	call   80045c <fd_lookup>
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	85 c0                	test   %eax,%eax
  80138b:	78 18                	js     8013a5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80138d:	83 ec 0c             	sub    $0xc,%esp
  801390:	ff 75 f4             	pushl  -0xc(%ebp)
  801393:	e8 5e f0 ff ff       	call   8003f6 <fd2data>
	return _pipeisclosed(fd, p);
  801398:	89 c2                	mov    %eax,%edx
  80139a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139d:	e8 21 fd ff ff       	call   8010c3 <_pipeisclosed>
  8013a2:	83 c4 10             	add    $0x10,%esp
}
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8013af:	5d                   	pop    %ebp
  8013b0:	c3                   	ret    

008013b1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013b7:	68 33 24 80 00       	push   $0x802433
  8013bc:	ff 75 0c             	pushl  0xc(%ebp)
  8013bf:	e8 c4 07 00 00       	call   801b88 <strcpy>
	return 0;
}
  8013c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    

008013cb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	57                   	push   %edi
  8013cf:	56                   	push   %esi
  8013d0:	53                   	push   %ebx
  8013d1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013d7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013dc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013e2:	eb 2d                	jmp    801411 <devcons_write+0x46>
		m = n - tot;
  8013e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013e7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013e9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013ec:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013f1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013f4:	83 ec 04             	sub    $0x4,%esp
  8013f7:	53                   	push   %ebx
  8013f8:	03 45 0c             	add    0xc(%ebp),%eax
  8013fb:	50                   	push   %eax
  8013fc:	57                   	push   %edi
  8013fd:	e8 18 09 00 00       	call   801d1a <memmove>
		sys_cputs(buf, m);
  801402:	83 c4 08             	add    $0x8,%esp
  801405:	53                   	push   %ebx
  801406:	57                   	push   %edi
  801407:	e8 a8 ec ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80140c:	01 de                	add    %ebx,%esi
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	89 f0                	mov    %esi,%eax
  801413:	3b 75 10             	cmp    0x10(%ebp),%esi
  801416:	72 cc                	jb     8013e4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801418:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141b:	5b                   	pop    %ebx
  80141c:	5e                   	pop    %esi
  80141d:	5f                   	pop    %edi
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80142b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80142f:	74 2a                	je     80145b <devcons_read+0x3b>
  801431:	eb 05                	jmp    801438 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801433:	e8 19 ed ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801438:	e8 95 ec ff ff       	call   8000d2 <sys_cgetc>
  80143d:	85 c0                	test   %eax,%eax
  80143f:	74 f2                	je     801433 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801441:	85 c0                	test   %eax,%eax
  801443:	78 16                	js     80145b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801445:	83 f8 04             	cmp    $0x4,%eax
  801448:	74 0c                	je     801456 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80144a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80144d:	88 02                	mov    %al,(%edx)
	return 1;
  80144f:	b8 01 00 00 00       	mov    $0x1,%eax
  801454:	eb 05                	jmp    80145b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801456:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801463:	8b 45 08             	mov    0x8(%ebp),%eax
  801466:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801469:	6a 01                	push   $0x1
  80146b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80146e:	50                   	push   %eax
  80146f:	e8 40 ec ff ff       	call   8000b4 <sys_cputs>
}
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	c9                   	leave  
  801478:	c3                   	ret    

00801479 <getchar>:

int
getchar(void)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80147f:	6a 01                	push   $0x1
  801481:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801484:	50                   	push   %eax
  801485:	6a 00                	push   $0x0
  801487:	e8 36 f2 ff ff       	call   8006c2 <read>
	if (r < 0)
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 0f                	js     8014a2 <getchar+0x29>
		return r;
	if (r < 1)
  801493:	85 c0                	test   %eax,%eax
  801495:	7e 06                	jle    80149d <getchar+0x24>
		return -E_EOF;
	return c;
  801497:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80149b:	eb 05                	jmp    8014a2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80149d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014a2:	c9                   	leave  
  8014a3:	c3                   	ret    

008014a4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	ff 75 08             	pushl  0x8(%ebp)
  8014b1:	e8 a6 ef ff ff       	call   80045c <fd_lookup>
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 11                	js     8014ce <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014c6:	39 10                	cmp    %edx,(%eax)
  8014c8:	0f 94 c0             	sete   %al
  8014cb:	0f b6 c0             	movzbl %al,%eax
}
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <opencons>:

int
opencons(void)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d9:	50                   	push   %eax
  8014da:	e8 2e ef ff ff       	call   80040d <fd_alloc>
  8014df:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 3e                	js     801526 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014e8:	83 ec 04             	sub    $0x4,%esp
  8014eb:	68 07 04 00 00       	push   $0x407
  8014f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f3:	6a 00                	push   $0x0
  8014f5:	e8 76 ec ff ff       	call   800170 <sys_page_alloc>
  8014fa:	83 c4 10             	add    $0x10,%esp
		return r;
  8014fd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ff:	85 c0                	test   %eax,%eax
  801501:	78 23                	js     801526 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801503:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801509:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80150e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801511:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801518:	83 ec 0c             	sub    $0xc,%esp
  80151b:	50                   	push   %eax
  80151c:	e8 c5 ee ff ff       	call   8003e6 <fd2num>
  801521:	89 c2                	mov    %eax,%edx
  801523:	83 c4 10             	add    $0x10,%esp
}
  801526:	89 d0                	mov    %edx,%eax
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	56                   	push   %esi
  80152e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80152f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801532:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801538:	e8 f5 eb ff ff       	call   800132 <sys_getenvid>
  80153d:	83 ec 0c             	sub    $0xc,%esp
  801540:	ff 75 0c             	pushl  0xc(%ebp)
  801543:	ff 75 08             	pushl  0x8(%ebp)
  801546:	56                   	push   %esi
  801547:	50                   	push   %eax
  801548:	68 40 24 80 00       	push   $0x802440
  80154d:	e8 b1 00 00 00       	call   801603 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801552:	83 c4 18             	add    $0x18,%esp
  801555:	53                   	push   %ebx
  801556:	ff 75 10             	pushl  0x10(%ebp)
  801559:	e8 54 00 00 00       	call   8015b2 <vcprintf>
	cprintf("\n");
  80155e:	c7 04 24 2c 24 80 00 	movl   $0x80242c,(%esp)
  801565:	e8 99 00 00 00       	call   801603 <cprintf>
  80156a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80156d:	cc                   	int3   
  80156e:	eb fd                	jmp    80156d <_panic+0x43>

00801570 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	53                   	push   %ebx
  801574:	83 ec 04             	sub    $0x4,%esp
  801577:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80157a:	8b 13                	mov    (%ebx),%edx
  80157c:	8d 42 01             	lea    0x1(%edx),%eax
  80157f:	89 03                	mov    %eax,(%ebx)
  801581:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801584:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801588:	3d ff 00 00 00       	cmp    $0xff,%eax
  80158d:	75 1a                	jne    8015a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	68 ff 00 00 00       	push   $0xff
  801597:	8d 43 08             	lea    0x8(%ebx),%eax
  80159a:	50                   	push   %eax
  80159b:	e8 14 eb ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8015a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b0:	c9                   	leave  
  8015b1:	c3                   	ret    

008015b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015c2:	00 00 00 
	b.cnt = 0;
  8015c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015cf:	ff 75 0c             	pushl  0xc(%ebp)
  8015d2:	ff 75 08             	pushl  0x8(%ebp)
  8015d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015db:	50                   	push   %eax
  8015dc:	68 70 15 80 00       	push   $0x801570
  8015e1:	e8 54 01 00 00       	call   80173a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015e6:	83 c4 08             	add    $0x8,%esp
  8015e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015f5:	50                   	push   %eax
  8015f6:	e8 b9 ea ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  8015fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801601:	c9                   	leave  
  801602:	c3                   	ret    

00801603 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801609:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80160c:	50                   	push   %eax
  80160d:	ff 75 08             	pushl  0x8(%ebp)
  801610:	e8 9d ff ff ff       	call   8015b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  801615:	c9                   	leave  
  801616:	c3                   	ret    

00801617 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	57                   	push   %edi
  80161b:	56                   	push   %esi
  80161c:	53                   	push   %ebx
  80161d:	83 ec 1c             	sub    $0x1c,%esp
  801620:	89 c7                	mov    %eax,%edi
  801622:	89 d6                	mov    %edx,%esi
  801624:	8b 45 08             	mov    0x8(%ebp),%eax
  801627:	8b 55 0c             	mov    0xc(%ebp),%edx
  80162a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80162d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801630:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801633:	bb 00 00 00 00       	mov    $0x0,%ebx
  801638:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80163b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80163e:	39 d3                	cmp    %edx,%ebx
  801640:	72 05                	jb     801647 <printnum+0x30>
  801642:	39 45 10             	cmp    %eax,0x10(%ebp)
  801645:	77 45                	ja     80168c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801647:	83 ec 0c             	sub    $0xc,%esp
  80164a:	ff 75 18             	pushl  0x18(%ebp)
  80164d:	8b 45 14             	mov    0x14(%ebp),%eax
  801650:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801653:	53                   	push   %ebx
  801654:	ff 75 10             	pushl  0x10(%ebp)
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165d:	ff 75 e0             	pushl  -0x20(%ebp)
  801660:	ff 75 dc             	pushl  -0x24(%ebp)
  801663:	ff 75 d8             	pushl  -0x28(%ebp)
  801666:	e8 e5 09 00 00       	call   802050 <__udivdi3>
  80166b:	83 c4 18             	add    $0x18,%esp
  80166e:	52                   	push   %edx
  80166f:	50                   	push   %eax
  801670:	89 f2                	mov    %esi,%edx
  801672:	89 f8                	mov    %edi,%eax
  801674:	e8 9e ff ff ff       	call   801617 <printnum>
  801679:	83 c4 20             	add    $0x20,%esp
  80167c:	eb 18                	jmp    801696 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80167e:	83 ec 08             	sub    $0x8,%esp
  801681:	56                   	push   %esi
  801682:	ff 75 18             	pushl  0x18(%ebp)
  801685:	ff d7                	call   *%edi
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	eb 03                	jmp    80168f <printnum+0x78>
  80168c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80168f:	83 eb 01             	sub    $0x1,%ebx
  801692:	85 db                	test   %ebx,%ebx
  801694:	7f e8                	jg     80167e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801696:	83 ec 08             	sub    $0x8,%esp
  801699:	56                   	push   %esi
  80169a:	83 ec 04             	sub    $0x4,%esp
  80169d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8016a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8016a9:	e8 d2 0a 00 00       	call   802180 <__umoddi3>
  8016ae:	83 c4 14             	add    $0x14,%esp
  8016b1:	0f be 80 63 24 80 00 	movsbl 0x802463(%eax),%eax
  8016b8:	50                   	push   %eax
  8016b9:	ff d7                	call   *%edi
}
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c1:	5b                   	pop    %ebx
  8016c2:	5e                   	pop    %esi
  8016c3:	5f                   	pop    %edi
  8016c4:	5d                   	pop    %ebp
  8016c5:	c3                   	ret    

008016c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016c9:	83 fa 01             	cmp    $0x1,%edx
  8016cc:	7e 0e                	jle    8016dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016ce:	8b 10                	mov    (%eax),%edx
  8016d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016d3:	89 08                	mov    %ecx,(%eax)
  8016d5:	8b 02                	mov    (%edx),%eax
  8016d7:	8b 52 04             	mov    0x4(%edx),%edx
  8016da:	eb 22                	jmp    8016fe <getuint+0x38>
	else if (lflag)
  8016dc:	85 d2                	test   %edx,%edx
  8016de:	74 10                	je     8016f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016e0:	8b 10                	mov    (%eax),%edx
  8016e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016e5:	89 08                	mov    %ecx,(%eax)
  8016e7:	8b 02                	mov    (%edx),%eax
  8016e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ee:	eb 0e                	jmp    8016fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016f0:	8b 10                	mov    (%eax),%edx
  8016f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016f5:	89 08                	mov    %ecx,(%eax)
  8016f7:	8b 02                	mov    (%edx),%eax
  8016f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016fe:	5d                   	pop    %ebp
  8016ff:	c3                   	ret    

00801700 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801706:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80170a:	8b 10                	mov    (%eax),%edx
  80170c:	3b 50 04             	cmp    0x4(%eax),%edx
  80170f:	73 0a                	jae    80171b <sprintputch+0x1b>
		*b->buf++ = ch;
  801711:	8d 4a 01             	lea    0x1(%edx),%ecx
  801714:	89 08                	mov    %ecx,(%eax)
  801716:	8b 45 08             	mov    0x8(%ebp),%eax
  801719:	88 02                	mov    %al,(%edx)
}
  80171b:	5d                   	pop    %ebp
  80171c:	c3                   	ret    

0080171d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801723:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801726:	50                   	push   %eax
  801727:	ff 75 10             	pushl  0x10(%ebp)
  80172a:	ff 75 0c             	pushl  0xc(%ebp)
  80172d:	ff 75 08             	pushl  0x8(%ebp)
  801730:	e8 05 00 00 00       	call   80173a <vprintfmt>
	va_end(ap);
}
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	57                   	push   %edi
  80173e:	56                   	push   %esi
  80173f:	53                   	push   %ebx
  801740:	83 ec 2c             	sub    $0x2c,%esp
  801743:	8b 75 08             	mov    0x8(%ebp),%esi
  801746:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801749:	8b 7d 10             	mov    0x10(%ebp),%edi
  80174c:	eb 12                	jmp    801760 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80174e:	85 c0                	test   %eax,%eax
  801750:	0f 84 89 03 00 00    	je     801adf <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801756:	83 ec 08             	sub    $0x8,%esp
  801759:	53                   	push   %ebx
  80175a:	50                   	push   %eax
  80175b:	ff d6                	call   *%esi
  80175d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801760:	83 c7 01             	add    $0x1,%edi
  801763:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801767:	83 f8 25             	cmp    $0x25,%eax
  80176a:	75 e2                	jne    80174e <vprintfmt+0x14>
  80176c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801770:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801777:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80177e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801785:	ba 00 00 00 00       	mov    $0x0,%edx
  80178a:	eb 07                	jmp    801793 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80178f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801793:	8d 47 01             	lea    0x1(%edi),%eax
  801796:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801799:	0f b6 07             	movzbl (%edi),%eax
  80179c:	0f b6 c8             	movzbl %al,%ecx
  80179f:	83 e8 23             	sub    $0x23,%eax
  8017a2:	3c 55                	cmp    $0x55,%al
  8017a4:	0f 87 1a 03 00 00    	ja     801ac4 <vprintfmt+0x38a>
  8017aa:	0f b6 c0             	movzbl %al,%eax
  8017ad:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
  8017b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017b7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017bb:	eb d6                	jmp    801793 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017c8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017cb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017cf:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017d2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017d5:	83 fa 09             	cmp    $0x9,%edx
  8017d8:	77 39                	ja     801813 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017da:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017dd:	eb e9                	jmp    8017c8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017df:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e2:	8d 48 04             	lea    0x4(%eax),%ecx
  8017e5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017e8:	8b 00                	mov    (%eax),%eax
  8017ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017f0:	eb 27                	jmp    801819 <vprintfmt+0xdf>
  8017f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017fc:	0f 49 c8             	cmovns %eax,%ecx
  8017ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801802:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801805:	eb 8c                	jmp    801793 <vprintfmt+0x59>
  801807:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80180a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801811:	eb 80                	jmp    801793 <vprintfmt+0x59>
  801813:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801816:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801819:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80181d:	0f 89 70 ff ff ff    	jns    801793 <vprintfmt+0x59>
				width = precision, precision = -1;
  801823:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801826:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801829:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801830:	e9 5e ff ff ff       	jmp    801793 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801835:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801838:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80183b:	e9 53 ff ff ff       	jmp    801793 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801840:	8b 45 14             	mov    0x14(%ebp),%eax
  801843:	8d 50 04             	lea    0x4(%eax),%edx
  801846:	89 55 14             	mov    %edx,0x14(%ebp)
  801849:	83 ec 08             	sub    $0x8,%esp
  80184c:	53                   	push   %ebx
  80184d:	ff 30                	pushl  (%eax)
  80184f:	ff d6                	call   *%esi
			break;
  801851:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801854:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801857:	e9 04 ff ff ff       	jmp    801760 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80185c:	8b 45 14             	mov    0x14(%ebp),%eax
  80185f:	8d 50 04             	lea    0x4(%eax),%edx
  801862:	89 55 14             	mov    %edx,0x14(%ebp)
  801865:	8b 00                	mov    (%eax),%eax
  801867:	99                   	cltd   
  801868:	31 d0                	xor    %edx,%eax
  80186a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80186c:	83 f8 0f             	cmp    $0xf,%eax
  80186f:	7f 0b                	jg     80187c <vprintfmt+0x142>
  801871:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  801878:	85 d2                	test   %edx,%edx
  80187a:	75 18                	jne    801894 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80187c:	50                   	push   %eax
  80187d:	68 7b 24 80 00       	push   $0x80247b
  801882:	53                   	push   %ebx
  801883:	56                   	push   %esi
  801884:	e8 94 fe ff ff       	call   80171d <printfmt>
  801889:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80188c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80188f:	e9 cc fe ff ff       	jmp    801760 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801894:	52                   	push   %edx
  801895:	68 c1 23 80 00       	push   $0x8023c1
  80189a:	53                   	push   %ebx
  80189b:	56                   	push   %esi
  80189c:	e8 7c fe ff ff       	call   80171d <printfmt>
  8018a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018a7:	e9 b4 fe ff ff       	jmp    801760 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8018af:	8d 50 04             	lea    0x4(%eax),%edx
  8018b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8018b5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018b7:	85 ff                	test   %edi,%edi
  8018b9:	b8 74 24 80 00       	mov    $0x802474,%eax
  8018be:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8018c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018c5:	0f 8e 94 00 00 00    	jle    80195f <vprintfmt+0x225>
  8018cb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018cf:	0f 84 98 00 00 00    	je     80196d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018d5:	83 ec 08             	sub    $0x8,%esp
  8018d8:	ff 75 d0             	pushl  -0x30(%ebp)
  8018db:	57                   	push   %edi
  8018dc:	e8 86 02 00 00       	call   801b67 <strnlen>
  8018e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018e4:	29 c1                	sub    %eax,%ecx
  8018e6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018e9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018ec:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018f3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018f6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018f8:	eb 0f                	jmp    801909 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	53                   	push   %ebx
  8018fe:	ff 75 e0             	pushl  -0x20(%ebp)
  801901:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801903:	83 ef 01             	sub    $0x1,%edi
  801906:	83 c4 10             	add    $0x10,%esp
  801909:	85 ff                	test   %edi,%edi
  80190b:	7f ed                	jg     8018fa <vprintfmt+0x1c0>
  80190d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801910:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801913:	85 c9                	test   %ecx,%ecx
  801915:	b8 00 00 00 00       	mov    $0x0,%eax
  80191a:	0f 49 c1             	cmovns %ecx,%eax
  80191d:	29 c1                	sub    %eax,%ecx
  80191f:	89 75 08             	mov    %esi,0x8(%ebp)
  801922:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801925:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801928:	89 cb                	mov    %ecx,%ebx
  80192a:	eb 4d                	jmp    801979 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80192c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801930:	74 1b                	je     80194d <vprintfmt+0x213>
  801932:	0f be c0             	movsbl %al,%eax
  801935:	83 e8 20             	sub    $0x20,%eax
  801938:	83 f8 5e             	cmp    $0x5e,%eax
  80193b:	76 10                	jbe    80194d <vprintfmt+0x213>
					putch('?', putdat);
  80193d:	83 ec 08             	sub    $0x8,%esp
  801940:	ff 75 0c             	pushl  0xc(%ebp)
  801943:	6a 3f                	push   $0x3f
  801945:	ff 55 08             	call   *0x8(%ebp)
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	eb 0d                	jmp    80195a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80194d:	83 ec 08             	sub    $0x8,%esp
  801950:	ff 75 0c             	pushl  0xc(%ebp)
  801953:	52                   	push   %edx
  801954:	ff 55 08             	call   *0x8(%ebp)
  801957:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80195a:	83 eb 01             	sub    $0x1,%ebx
  80195d:	eb 1a                	jmp    801979 <vprintfmt+0x23f>
  80195f:	89 75 08             	mov    %esi,0x8(%ebp)
  801962:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801965:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801968:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80196b:	eb 0c                	jmp    801979 <vprintfmt+0x23f>
  80196d:	89 75 08             	mov    %esi,0x8(%ebp)
  801970:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801973:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801976:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801979:	83 c7 01             	add    $0x1,%edi
  80197c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801980:	0f be d0             	movsbl %al,%edx
  801983:	85 d2                	test   %edx,%edx
  801985:	74 23                	je     8019aa <vprintfmt+0x270>
  801987:	85 f6                	test   %esi,%esi
  801989:	78 a1                	js     80192c <vprintfmt+0x1f2>
  80198b:	83 ee 01             	sub    $0x1,%esi
  80198e:	79 9c                	jns    80192c <vprintfmt+0x1f2>
  801990:	89 df                	mov    %ebx,%edi
  801992:	8b 75 08             	mov    0x8(%ebp),%esi
  801995:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801998:	eb 18                	jmp    8019b2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80199a:	83 ec 08             	sub    $0x8,%esp
  80199d:	53                   	push   %ebx
  80199e:	6a 20                	push   $0x20
  8019a0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019a2:	83 ef 01             	sub    $0x1,%edi
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	eb 08                	jmp    8019b2 <vprintfmt+0x278>
  8019aa:	89 df                	mov    %ebx,%edi
  8019ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8019af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019b2:	85 ff                	test   %edi,%edi
  8019b4:	7f e4                	jg     80199a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019b9:	e9 a2 fd ff ff       	jmp    801760 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019be:	83 fa 01             	cmp    $0x1,%edx
  8019c1:	7e 16                	jle    8019d9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8019c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c6:	8d 50 08             	lea    0x8(%eax),%edx
  8019c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8019cc:	8b 50 04             	mov    0x4(%eax),%edx
  8019cf:	8b 00                	mov    (%eax),%eax
  8019d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019d7:	eb 32                	jmp    801a0b <vprintfmt+0x2d1>
	else if (lflag)
  8019d9:	85 d2                	test   %edx,%edx
  8019db:	74 18                	je     8019f5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e0:	8d 50 04             	lea    0x4(%eax),%edx
  8019e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8019e6:	8b 00                	mov    (%eax),%eax
  8019e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019eb:	89 c1                	mov    %eax,%ecx
  8019ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8019f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019f3:	eb 16                	jmp    801a0b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f8:	8d 50 04             	lea    0x4(%eax),%edx
  8019fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8019fe:	8b 00                	mov    (%eax),%eax
  801a00:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a03:	89 c1                	mov    %eax,%ecx
  801a05:	c1 f9 1f             	sar    $0x1f,%ecx
  801a08:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a0b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a0e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a11:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a16:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a1a:	79 74                	jns    801a90 <vprintfmt+0x356>
				putch('-', putdat);
  801a1c:	83 ec 08             	sub    $0x8,%esp
  801a1f:	53                   	push   %ebx
  801a20:	6a 2d                	push   $0x2d
  801a22:	ff d6                	call   *%esi
				num = -(long long) num;
  801a24:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a27:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a2a:	f7 d8                	neg    %eax
  801a2c:	83 d2 00             	adc    $0x0,%edx
  801a2f:	f7 da                	neg    %edx
  801a31:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a34:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a39:	eb 55                	jmp    801a90 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a3b:	8d 45 14             	lea    0x14(%ebp),%eax
  801a3e:	e8 83 fc ff ff       	call   8016c6 <getuint>
			base = 10;
  801a43:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a48:	eb 46                	jmp    801a90 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a4a:	8d 45 14             	lea    0x14(%ebp),%eax
  801a4d:	e8 74 fc ff ff       	call   8016c6 <getuint>
			base = 8;
  801a52:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a57:	eb 37                	jmp    801a90 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a59:	83 ec 08             	sub    $0x8,%esp
  801a5c:	53                   	push   %ebx
  801a5d:	6a 30                	push   $0x30
  801a5f:	ff d6                	call   *%esi
			putch('x', putdat);
  801a61:	83 c4 08             	add    $0x8,%esp
  801a64:	53                   	push   %ebx
  801a65:	6a 78                	push   $0x78
  801a67:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a69:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6c:	8d 50 04             	lea    0x4(%eax),%edx
  801a6f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a72:	8b 00                	mov    (%eax),%eax
  801a74:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a79:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a7c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a81:	eb 0d                	jmp    801a90 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a83:	8d 45 14             	lea    0x14(%ebp),%eax
  801a86:	e8 3b fc ff ff       	call   8016c6 <getuint>
			base = 16;
  801a8b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a90:	83 ec 0c             	sub    $0xc,%esp
  801a93:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a97:	57                   	push   %edi
  801a98:	ff 75 e0             	pushl  -0x20(%ebp)
  801a9b:	51                   	push   %ecx
  801a9c:	52                   	push   %edx
  801a9d:	50                   	push   %eax
  801a9e:	89 da                	mov    %ebx,%edx
  801aa0:	89 f0                	mov    %esi,%eax
  801aa2:	e8 70 fb ff ff       	call   801617 <printnum>
			break;
  801aa7:	83 c4 20             	add    $0x20,%esp
  801aaa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801aad:	e9 ae fc ff ff       	jmp    801760 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ab2:	83 ec 08             	sub    $0x8,%esp
  801ab5:	53                   	push   %ebx
  801ab6:	51                   	push   %ecx
  801ab7:	ff d6                	call   *%esi
			break;
  801ab9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801abc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801abf:	e9 9c fc ff ff       	jmp    801760 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801ac4:	83 ec 08             	sub    $0x8,%esp
  801ac7:	53                   	push   %ebx
  801ac8:	6a 25                	push   $0x25
  801aca:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	eb 03                	jmp    801ad4 <vprintfmt+0x39a>
  801ad1:	83 ef 01             	sub    $0x1,%edi
  801ad4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801ad8:	75 f7                	jne    801ad1 <vprintfmt+0x397>
  801ada:	e9 81 fc ff ff       	jmp    801760 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801adf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae2:	5b                   	pop    %ebx
  801ae3:	5e                   	pop    %esi
  801ae4:	5f                   	pop    %edi
  801ae5:	5d                   	pop    %ebp
  801ae6:	c3                   	ret    

00801ae7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	83 ec 18             	sub    $0x18,%esp
  801aed:	8b 45 08             	mov    0x8(%ebp),%eax
  801af0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801af3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801af6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801afa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801afd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b04:	85 c0                	test   %eax,%eax
  801b06:	74 26                	je     801b2e <vsnprintf+0x47>
  801b08:	85 d2                	test   %edx,%edx
  801b0a:	7e 22                	jle    801b2e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b0c:	ff 75 14             	pushl  0x14(%ebp)
  801b0f:	ff 75 10             	pushl  0x10(%ebp)
  801b12:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b15:	50                   	push   %eax
  801b16:	68 00 17 80 00       	push   $0x801700
  801b1b:	e8 1a fc ff ff       	call   80173a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b23:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b29:	83 c4 10             	add    $0x10,%esp
  801b2c:	eb 05                	jmp    801b33 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b33:	c9                   	leave  
  801b34:	c3                   	ret    

00801b35 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b3b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b3e:	50                   	push   %eax
  801b3f:	ff 75 10             	pushl  0x10(%ebp)
  801b42:	ff 75 0c             	pushl  0xc(%ebp)
  801b45:	ff 75 08             	pushl  0x8(%ebp)
  801b48:	e8 9a ff ff ff       	call   801ae7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b4d:	c9                   	leave  
  801b4e:	c3                   	ret    

00801b4f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b55:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5a:	eb 03                	jmp    801b5f <strlen+0x10>
		n++;
  801b5c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b5f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b63:	75 f7                	jne    801b5c <strlen+0xd>
		n++;
	return n;
}
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    

00801b67 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b70:	ba 00 00 00 00       	mov    $0x0,%edx
  801b75:	eb 03                	jmp    801b7a <strnlen+0x13>
		n++;
  801b77:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b7a:	39 c2                	cmp    %eax,%edx
  801b7c:	74 08                	je     801b86 <strnlen+0x1f>
  801b7e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b82:	75 f3                	jne    801b77 <strnlen+0x10>
  801b84:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    

00801b88 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	53                   	push   %ebx
  801b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b92:	89 c2                	mov    %eax,%edx
  801b94:	83 c2 01             	add    $0x1,%edx
  801b97:	83 c1 01             	add    $0x1,%ecx
  801b9a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b9e:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ba1:	84 db                	test   %bl,%bl
  801ba3:	75 ef                	jne    801b94 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801ba5:	5b                   	pop    %ebx
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    

00801ba8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	53                   	push   %ebx
  801bac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801baf:	53                   	push   %ebx
  801bb0:	e8 9a ff ff ff       	call   801b4f <strlen>
  801bb5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bb8:	ff 75 0c             	pushl  0xc(%ebp)
  801bbb:	01 d8                	add    %ebx,%eax
  801bbd:	50                   	push   %eax
  801bbe:	e8 c5 ff ff ff       	call   801b88 <strcpy>
	return dst;
}
  801bc3:	89 d8                	mov    %ebx,%eax
  801bc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc8:	c9                   	leave  
  801bc9:	c3                   	ret    

00801bca <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	56                   	push   %esi
  801bce:	53                   	push   %ebx
  801bcf:	8b 75 08             	mov    0x8(%ebp),%esi
  801bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd5:	89 f3                	mov    %esi,%ebx
  801bd7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bda:	89 f2                	mov    %esi,%edx
  801bdc:	eb 0f                	jmp    801bed <strncpy+0x23>
		*dst++ = *src;
  801bde:	83 c2 01             	add    $0x1,%edx
  801be1:	0f b6 01             	movzbl (%ecx),%eax
  801be4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801be7:	80 39 01             	cmpb   $0x1,(%ecx)
  801bea:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bed:	39 da                	cmp    %ebx,%edx
  801bef:	75 ed                	jne    801bde <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bf1:	89 f0                	mov    %esi,%eax
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5d                   	pop    %ebp
  801bf6:	c3                   	ret    

00801bf7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	56                   	push   %esi
  801bfb:	53                   	push   %ebx
  801bfc:	8b 75 08             	mov    0x8(%ebp),%esi
  801bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c02:	8b 55 10             	mov    0x10(%ebp),%edx
  801c05:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c07:	85 d2                	test   %edx,%edx
  801c09:	74 21                	je     801c2c <strlcpy+0x35>
  801c0b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c0f:	89 f2                	mov    %esi,%edx
  801c11:	eb 09                	jmp    801c1c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c13:	83 c2 01             	add    $0x1,%edx
  801c16:	83 c1 01             	add    $0x1,%ecx
  801c19:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c1c:	39 c2                	cmp    %eax,%edx
  801c1e:	74 09                	je     801c29 <strlcpy+0x32>
  801c20:	0f b6 19             	movzbl (%ecx),%ebx
  801c23:	84 db                	test   %bl,%bl
  801c25:	75 ec                	jne    801c13 <strlcpy+0x1c>
  801c27:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c29:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c2c:	29 f0                	sub    %esi,%eax
}
  801c2e:	5b                   	pop    %ebx
  801c2f:	5e                   	pop    %esi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    

00801c32 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c38:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c3b:	eb 06                	jmp    801c43 <strcmp+0x11>
		p++, q++;
  801c3d:	83 c1 01             	add    $0x1,%ecx
  801c40:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c43:	0f b6 01             	movzbl (%ecx),%eax
  801c46:	84 c0                	test   %al,%al
  801c48:	74 04                	je     801c4e <strcmp+0x1c>
  801c4a:	3a 02                	cmp    (%edx),%al
  801c4c:	74 ef                	je     801c3d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c4e:	0f b6 c0             	movzbl %al,%eax
  801c51:	0f b6 12             	movzbl (%edx),%edx
  801c54:	29 d0                	sub    %edx,%eax
}
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    

00801c58 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	53                   	push   %ebx
  801c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c62:	89 c3                	mov    %eax,%ebx
  801c64:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c67:	eb 06                	jmp    801c6f <strncmp+0x17>
		n--, p++, q++;
  801c69:	83 c0 01             	add    $0x1,%eax
  801c6c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c6f:	39 d8                	cmp    %ebx,%eax
  801c71:	74 15                	je     801c88 <strncmp+0x30>
  801c73:	0f b6 08             	movzbl (%eax),%ecx
  801c76:	84 c9                	test   %cl,%cl
  801c78:	74 04                	je     801c7e <strncmp+0x26>
  801c7a:	3a 0a                	cmp    (%edx),%cl
  801c7c:	74 eb                	je     801c69 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c7e:	0f b6 00             	movzbl (%eax),%eax
  801c81:	0f b6 12             	movzbl (%edx),%edx
  801c84:	29 d0                	sub    %edx,%eax
  801c86:	eb 05                	jmp    801c8d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c88:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c8d:	5b                   	pop    %ebx
  801c8e:	5d                   	pop    %ebp
  801c8f:	c3                   	ret    

00801c90 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	8b 45 08             	mov    0x8(%ebp),%eax
  801c96:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c9a:	eb 07                	jmp    801ca3 <strchr+0x13>
		if (*s == c)
  801c9c:	38 ca                	cmp    %cl,%dl
  801c9e:	74 0f                	je     801caf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ca0:	83 c0 01             	add    $0x1,%eax
  801ca3:	0f b6 10             	movzbl (%eax),%edx
  801ca6:	84 d2                	test   %dl,%dl
  801ca8:	75 f2                	jne    801c9c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801caa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cbb:	eb 03                	jmp    801cc0 <strfind+0xf>
  801cbd:	83 c0 01             	add    $0x1,%eax
  801cc0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cc3:	38 ca                	cmp    %cl,%dl
  801cc5:	74 04                	je     801ccb <strfind+0x1a>
  801cc7:	84 d2                	test   %dl,%dl
  801cc9:	75 f2                	jne    801cbd <strfind+0xc>
			break;
	return (char *) s;
}
  801ccb:	5d                   	pop    %ebp
  801ccc:	c3                   	ret    

00801ccd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ccd:	55                   	push   %ebp
  801cce:	89 e5                	mov    %esp,%ebp
  801cd0:	57                   	push   %edi
  801cd1:	56                   	push   %esi
  801cd2:	53                   	push   %ebx
  801cd3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cd6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cd9:	85 c9                	test   %ecx,%ecx
  801cdb:	74 36                	je     801d13 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cdd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ce3:	75 28                	jne    801d0d <memset+0x40>
  801ce5:	f6 c1 03             	test   $0x3,%cl
  801ce8:	75 23                	jne    801d0d <memset+0x40>
		c &= 0xFF;
  801cea:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cee:	89 d3                	mov    %edx,%ebx
  801cf0:	c1 e3 08             	shl    $0x8,%ebx
  801cf3:	89 d6                	mov    %edx,%esi
  801cf5:	c1 e6 18             	shl    $0x18,%esi
  801cf8:	89 d0                	mov    %edx,%eax
  801cfa:	c1 e0 10             	shl    $0x10,%eax
  801cfd:	09 f0                	or     %esi,%eax
  801cff:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d01:	89 d8                	mov    %ebx,%eax
  801d03:	09 d0                	or     %edx,%eax
  801d05:	c1 e9 02             	shr    $0x2,%ecx
  801d08:	fc                   	cld    
  801d09:	f3 ab                	rep stos %eax,%es:(%edi)
  801d0b:	eb 06                	jmp    801d13 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d10:	fc                   	cld    
  801d11:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d13:	89 f8                	mov    %edi,%eax
  801d15:	5b                   	pop    %ebx
  801d16:	5e                   	pop    %esi
  801d17:	5f                   	pop    %edi
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    

00801d1a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	57                   	push   %edi
  801d1e:	56                   	push   %esi
  801d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d22:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d28:	39 c6                	cmp    %eax,%esi
  801d2a:	73 35                	jae    801d61 <memmove+0x47>
  801d2c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d2f:	39 d0                	cmp    %edx,%eax
  801d31:	73 2e                	jae    801d61 <memmove+0x47>
		s += n;
		d += n;
  801d33:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d36:	89 d6                	mov    %edx,%esi
  801d38:	09 fe                	or     %edi,%esi
  801d3a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d40:	75 13                	jne    801d55 <memmove+0x3b>
  801d42:	f6 c1 03             	test   $0x3,%cl
  801d45:	75 0e                	jne    801d55 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d47:	83 ef 04             	sub    $0x4,%edi
  801d4a:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d4d:	c1 e9 02             	shr    $0x2,%ecx
  801d50:	fd                   	std    
  801d51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d53:	eb 09                	jmp    801d5e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d55:	83 ef 01             	sub    $0x1,%edi
  801d58:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d5b:	fd                   	std    
  801d5c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d5e:	fc                   	cld    
  801d5f:	eb 1d                	jmp    801d7e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d61:	89 f2                	mov    %esi,%edx
  801d63:	09 c2                	or     %eax,%edx
  801d65:	f6 c2 03             	test   $0x3,%dl
  801d68:	75 0f                	jne    801d79 <memmove+0x5f>
  801d6a:	f6 c1 03             	test   $0x3,%cl
  801d6d:	75 0a                	jne    801d79 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d6f:	c1 e9 02             	shr    $0x2,%ecx
  801d72:	89 c7                	mov    %eax,%edi
  801d74:	fc                   	cld    
  801d75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d77:	eb 05                	jmp    801d7e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d79:	89 c7                	mov    %eax,%edi
  801d7b:	fc                   	cld    
  801d7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d7e:	5e                   	pop    %esi
  801d7f:	5f                   	pop    %edi
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    

00801d82 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d85:	ff 75 10             	pushl  0x10(%ebp)
  801d88:	ff 75 0c             	pushl  0xc(%ebp)
  801d8b:	ff 75 08             	pushl  0x8(%ebp)
  801d8e:	e8 87 ff ff ff       	call   801d1a <memmove>
}
  801d93:	c9                   	leave  
  801d94:	c3                   	ret    

00801d95 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	56                   	push   %esi
  801d99:	53                   	push   %ebx
  801d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da0:	89 c6                	mov    %eax,%esi
  801da2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801da5:	eb 1a                	jmp    801dc1 <memcmp+0x2c>
		if (*s1 != *s2)
  801da7:	0f b6 08             	movzbl (%eax),%ecx
  801daa:	0f b6 1a             	movzbl (%edx),%ebx
  801dad:	38 d9                	cmp    %bl,%cl
  801daf:	74 0a                	je     801dbb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801db1:	0f b6 c1             	movzbl %cl,%eax
  801db4:	0f b6 db             	movzbl %bl,%ebx
  801db7:	29 d8                	sub    %ebx,%eax
  801db9:	eb 0f                	jmp    801dca <memcmp+0x35>
		s1++, s2++;
  801dbb:	83 c0 01             	add    $0x1,%eax
  801dbe:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dc1:	39 f0                	cmp    %esi,%eax
  801dc3:	75 e2                	jne    801da7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801dc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dca:	5b                   	pop    %ebx
  801dcb:	5e                   	pop    %esi
  801dcc:	5d                   	pop    %ebp
  801dcd:	c3                   	ret    

00801dce <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	53                   	push   %ebx
  801dd2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801dd5:	89 c1                	mov    %eax,%ecx
  801dd7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801dda:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dde:	eb 0a                	jmp    801dea <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801de0:	0f b6 10             	movzbl (%eax),%edx
  801de3:	39 da                	cmp    %ebx,%edx
  801de5:	74 07                	je     801dee <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801de7:	83 c0 01             	add    $0x1,%eax
  801dea:	39 c8                	cmp    %ecx,%eax
  801dec:	72 f2                	jb     801de0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dee:	5b                   	pop    %ebx
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	57                   	push   %edi
  801df5:	56                   	push   %esi
  801df6:	53                   	push   %ebx
  801df7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dfd:	eb 03                	jmp    801e02 <strtol+0x11>
		s++;
  801dff:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e02:	0f b6 01             	movzbl (%ecx),%eax
  801e05:	3c 20                	cmp    $0x20,%al
  801e07:	74 f6                	je     801dff <strtol+0xe>
  801e09:	3c 09                	cmp    $0x9,%al
  801e0b:	74 f2                	je     801dff <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e0d:	3c 2b                	cmp    $0x2b,%al
  801e0f:	75 0a                	jne    801e1b <strtol+0x2a>
		s++;
  801e11:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e14:	bf 00 00 00 00       	mov    $0x0,%edi
  801e19:	eb 11                	jmp    801e2c <strtol+0x3b>
  801e1b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e20:	3c 2d                	cmp    $0x2d,%al
  801e22:	75 08                	jne    801e2c <strtol+0x3b>
		s++, neg = 1;
  801e24:	83 c1 01             	add    $0x1,%ecx
  801e27:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e2c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e32:	75 15                	jne    801e49 <strtol+0x58>
  801e34:	80 39 30             	cmpb   $0x30,(%ecx)
  801e37:	75 10                	jne    801e49 <strtol+0x58>
  801e39:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e3d:	75 7c                	jne    801ebb <strtol+0xca>
		s += 2, base = 16;
  801e3f:	83 c1 02             	add    $0x2,%ecx
  801e42:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e47:	eb 16                	jmp    801e5f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e49:	85 db                	test   %ebx,%ebx
  801e4b:	75 12                	jne    801e5f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e4d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e52:	80 39 30             	cmpb   $0x30,(%ecx)
  801e55:	75 08                	jne    801e5f <strtol+0x6e>
		s++, base = 8;
  801e57:	83 c1 01             	add    $0x1,%ecx
  801e5a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e64:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e67:	0f b6 11             	movzbl (%ecx),%edx
  801e6a:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e6d:	89 f3                	mov    %esi,%ebx
  801e6f:	80 fb 09             	cmp    $0x9,%bl
  801e72:	77 08                	ja     801e7c <strtol+0x8b>
			dig = *s - '0';
  801e74:	0f be d2             	movsbl %dl,%edx
  801e77:	83 ea 30             	sub    $0x30,%edx
  801e7a:	eb 22                	jmp    801e9e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e7c:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e7f:	89 f3                	mov    %esi,%ebx
  801e81:	80 fb 19             	cmp    $0x19,%bl
  801e84:	77 08                	ja     801e8e <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e86:	0f be d2             	movsbl %dl,%edx
  801e89:	83 ea 57             	sub    $0x57,%edx
  801e8c:	eb 10                	jmp    801e9e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e8e:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e91:	89 f3                	mov    %esi,%ebx
  801e93:	80 fb 19             	cmp    $0x19,%bl
  801e96:	77 16                	ja     801eae <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e98:	0f be d2             	movsbl %dl,%edx
  801e9b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e9e:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ea1:	7d 0b                	jge    801eae <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ea3:	83 c1 01             	add    $0x1,%ecx
  801ea6:	0f af 45 10          	imul   0x10(%ebp),%eax
  801eaa:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801eac:	eb b9                	jmp    801e67 <strtol+0x76>

	if (endptr)
  801eae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801eb2:	74 0d                	je     801ec1 <strtol+0xd0>
		*endptr = (char *) s;
  801eb4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eb7:	89 0e                	mov    %ecx,(%esi)
  801eb9:	eb 06                	jmp    801ec1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ebb:	85 db                	test   %ebx,%ebx
  801ebd:	74 98                	je     801e57 <strtol+0x66>
  801ebf:	eb 9e                	jmp    801e5f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ec1:	89 c2                	mov    %eax,%edx
  801ec3:	f7 da                	neg    %edx
  801ec5:	85 ff                	test   %edi,%edi
  801ec7:	0f 45 c2             	cmovne %edx,%eax
}
  801eca:	5b                   	pop    %ebx
  801ecb:	5e                   	pop    %esi
  801ecc:	5f                   	pop    %edi
  801ecd:	5d                   	pop    %ebp
  801ece:	c3                   	ret    

00801ecf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ed5:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801edc:	75 2e                	jne    801f0c <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801ede:	e8 4f e2 ff ff       	call   800132 <sys_getenvid>
  801ee3:	83 ec 04             	sub    $0x4,%esp
  801ee6:	68 07 0e 00 00       	push   $0xe07
  801eeb:	68 00 f0 bf ee       	push   $0xeebff000
  801ef0:	50                   	push   %eax
  801ef1:	e8 7a e2 ff ff       	call   800170 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801ef6:	e8 37 e2 ff ff       	call   800132 <sys_getenvid>
  801efb:	83 c4 08             	add    $0x8,%esp
  801efe:	68 c2 03 80 00       	push   $0x8003c2
  801f03:	50                   	push   %eax
  801f04:	e8 b2 e3 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801f09:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0f:	a3 00 70 80 00       	mov    %eax,0x807000
}
  801f14:	c9                   	leave  
  801f15:	c3                   	ret    

00801f16 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	56                   	push   %esi
  801f1a:	53                   	push   %ebx
  801f1b:	8b 75 08             	mov    0x8(%ebp),%esi
  801f1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f24:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f26:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f2b:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f2e:	83 ec 0c             	sub    $0xc,%esp
  801f31:	50                   	push   %eax
  801f32:	e8 e9 e3 ff ff       	call   800320 <sys_ipc_recv>

	if (from_env_store != NULL)
  801f37:	83 c4 10             	add    $0x10,%esp
  801f3a:	85 f6                	test   %esi,%esi
  801f3c:	74 14                	je     801f52 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801f43:	85 c0                	test   %eax,%eax
  801f45:	78 09                	js     801f50 <ipc_recv+0x3a>
  801f47:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f4d:	8b 52 74             	mov    0x74(%edx),%edx
  801f50:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f52:	85 db                	test   %ebx,%ebx
  801f54:	74 14                	je     801f6a <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f56:	ba 00 00 00 00       	mov    $0x0,%edx
  801f5b:	85 c0                	test   %eax,%eax
  801f5d:	78 09                	js     801f68 <ipc_recv+0x52>
  801f5f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f65:	8b 52 78             	mov    0x78(%edx),%edx
  801f68:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f6a:	85 c0                	test   %eax,%eax
  801f6c:	78 08                	js     801f76 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f6e:	a1 08 40 80 00       	mov    0x804008,%eax
  801f73:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f79:	5b                   	pop    %ebx
  801f7a:	5e                   	pop    %esi
  801f7b:	5d                   	pop    %ebp
  801f7c:	c3                   	ret    

00801f7d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f7d:	55                   	push   %ebp
  801f7e:	89 e5                	mov    %esp,%ebp
  801f80:	57                   	push   %edi
  801f81:	56                   	push   %esi
  801f82:	53                   	push   %ebx
  801f83:	83 ec 0c             	sub    $0xc,%esp
  801f86:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f89:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f8f:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f91:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f96:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f99:	ff 75 14             	pushl  0x14(%ebp)
  801f9c:	53                   	push   %ebx
  801f9d:	56                   	push   %esi
  801f9e:	57                   	push   %edi
  801f9f:	e8 59 e3 ff ff       	call   8002fd <sys_ipc_try_send>

		if (err < 0) {
  801fa4:	83 c4 10             	add    $0x10,%esp
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	79 1e                	jns    801fc9 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801fab:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fae:	75 07                	jne    801fb7 <ipc_send+0x3a>
				sys_yield();
  801fb0:	e8 9c e1 ff ff       	call   800151 <sys_yield>
  801fb5:	eb e2                	jmp    801f99 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801fb7:	50                   	push   %eax
  801fb8:	68 60 27 80 00       	push   $0x802760
  801fbd:	6a 49                	push   $0x49
  801fbf:	68 6d 27 80 00       	push   $0x80276d
  801fc4:	e8 61 f5 ff ff       	call   80152a <_panic>
		}

	} while (err < 0);

}
  801fc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fcc:	5b                   	pop    %ebx
  801fcd:	5e                   	pop    %esi
  801fce:	5f                   	pop    %edi
  801fcf:	5d                   	pop    %ebp
  801fd0:	c3                   	ret    

00801fd1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fd7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fdc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fdf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fe5:	8b 52 50             	mov    0x50(%edx),%edx
  801fe8:	39 ca                	cmp    %ecx,%edx
  801fea:	75 0d                	jne    801ff9 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fec:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ff4:	8b 40 48             	mov    0x48(%eax),%eax
  801ff7:	eb 0f                	jmp    802008 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ff9:	83 c0 01             	add    $0x1,%eax
  801ffc:	3d 00 04 00 00       	cmp    $0x400,%eax
  802001:	75 d9                	jne    801fdc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802003:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    

0080200a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802010:	89 d0                	mov    %edx,%eax
  802012:	c1 e8 16             	shr    $0x16,%eax
  802015:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80201c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802021:	f6 c1 01             	test   $0x1,%cl
  802024:	74 1d                	je     802043 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802026:	c1 ea 0c             	shr    $0xc,%edx
  802029:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802030:	f6 c2 01             	test   $0x1,%dl
  802033:	74 0e                	je     802043 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802035:	c1 ea 0c             	shr    $0xc,%edx
  802038:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80203f:	ef 
  802040:	0f b7 c0             	movzwl %ax,%eax
}
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    
  802045:	66 90                	xchg   %ax,%ax
  802047:	66 90                	xchg   %ax,%ax
  802049:	66 90                	xchg   %ax,%ax
  80204b:	66 90                	xchg   %ax,%ax
  80204d:	66 90                	xchg   %ax,%ax
  80204f:	90                   	nop

00802050 <__udivdi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80205b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80205f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802063:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802067:	85 f6                	test   %esi,%esi
  802069:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80206d:	89 ca                	mov    %ecx,%edx
  80206f:	89 f8                	mov    %edi,%eax
  802071:	75 3d                	jne    8020b0 <__udivdi3+0x60>
  802073:	39 cf                	cmp    %ecx,%edi
  802075:	0f 87 c5 00 00 00    	ja     802140 <__udivdi3+0xf0>
  80207b:	85 ff                	test   %edi,%edi
  80207d:	89 fd                	mov    %edi,%ebp
  80207f:	75 0b                	jne    80208c <__udivdi3+0x3c>
  802081:	b8 01 00 00 00       	mov    $0x1,%eax
  802086:	31 d2                	xor    %edx,%edx
  802088:	f7 f7                	div    %edi
  80208a:	89 c5                	mov    %eax,%ebp
  80208c:	89 c8                	mov    %ecx,%eax
  80208e:	31 d2                	xor    %edx,%edx
  802090:	f7 f5                	div    %ebp
  802092:	89 c1                	mov    %eax,%ecx
  802094:	89 d8                	mov    %ebx,%eax
  802096:	89 cf                	mov    %ecx,%edi
  802098:	f7 f5                	div    %ebp
  80209a:	89 c3                	mov    %eax,%ebx
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
  8020b0:	39 ce                	cmp    %ecx,%esi
  8020b2:	77 74                	ja     802128 <__udivdi3+0xd8>
  8020b4:	0f bd fe             	bsr    %esi,%edi
  8020b7:	83 f7 1f             	xor    $0x1f,%edi
  8020ba:	0f 84 98 00 00 00    	je     802158 <__udivdi3+0x108>
  8020c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	89 c5                	mov    %eax,%ebp
  8020c9:	29 fb                	sub    %edi,%ebx
  8020cb:	d3 e6                	shl    %cl,%esi
  8020cd:	89 d9                	mov    %ebx,%ecx
  8020cf:	d3 ed                	shr    %cl,%ebp
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	d3 e0                	shl    %cl,%eax
  8020d5:	09 ee                	or     %ebp,%esi
  8020d7:	89 d9                	mov    %ebx,%ecx
  8020d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020dd:	89 d5                	mov    %edx,%ebp
  8020df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020e3:	d3 ed                	shr    %cl,%ebp
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e2                	shl    %cl,%edx
  8020e9:	89 d9                	mov    %ebx,%ecx
  8020eb:	d3 e8                	shr    %cl,%eax
  8020ed:	09 c2                	or     %eax,%edx
  8020ef:	89 d0                	mov    %edx,%eax
  8020f1:	89 ea                	mov    %ebp,%edx
  8020f3:	f7 f6                	div    %esi
  8020f5:	89 d5                	mov    %edx,%ebp
  8020f7:	89 c3                	mov    %eax,%ebx
  8020f9:	f7 64 24 0c          	mull   0xc(%esp)
  8020fd:	39 d5                	cmp    %edx,%ebp
  8020ff:	72 10                	jb     802111 <__udivdi3+0xc1>
  802101:	8b 74 24 08          	mov    0x8(%esp),%esi
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e6                	shl    %cl,%esi
  802109:	39 c6                	cmp    %eax,%esi
  80210b:	73 07                	jae    802114 <__udivdi3+0xc4>
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	75 03                	jne    802114 <__udivdi3+0xc4>
  802111:	83 eb 01             	sub    $0x1,%ebx
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 d8                	mov    %ebx,%eax
  802118:	89 fa                	mov    %edi,%edx
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	31 ff                	xor    %edi,%edi
  80212a:	31 db                	xor    %ebx,%ebx
  80212c:	89 d8                	mov    %ebx,%eax
  80212e:	89 fa                	mov    %edi,%edx
  802130:	83 c4 1c             	add    $0x1c,%esp
  802133:	5b                   	pop    %ebx
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	90                   	nop
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	89 d8                	mov    %ebx,%eax
  802142:	f7 f7                	div    %edi
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 c3                	mov    %eax,%ebx
  802148:	89 d8                	mov    %ebx,%eax
  80214a:	89 fa                	mov    %edi,%edx
  80214c:	83 c4 1c             	add    $0x1c,%esp
  80214f:	5b                   	pop    %ebx
  802150:	5e                   	pop    %esi
  802151:	5f                   	pop    %edi
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	39 ce                	cmp    %ecx,%esi
  80215a:	72 0c                	jb     802168 <__udivdi3+0x118>
  80215c:	31 db                	xor    %ebx,%ebx
  80215e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802162:	0f 87 34 ff ff ff    	ja     80209c <__udivdi3+0x4c>
  802168:	bb 01 00 00 00       	mov    $0x1,%ebx
  80216d:	e9 2a ff ff ff       	jmp    80209c <__udivdi3+0x4c>
  802172:	66 90                	xchg   %ax,%ax
  802174:	66 90                	xchg   %ax,%ax
  802176:	66 90                	xchg   %ax,%ax
  802178:	66 90                	xchg   %ax,%ax
  80217a:	66 90                	xchg   %ax,%ax
  80217c:	66 90                	xchg   %ax,%ax
  80217e:	66 90                	xchg   %ax,%ax

00802180 <__umoddi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80218b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80218f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 d2                	test   %edx,%edx
  802199:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80219d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021a1:	89 f3                	mov    %esi,%ebx
  8021a3:	89 3c 24             	mov    %edi,(%esp)
  8021a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021aa:	75 1c                	jne    8021c8 <__umoddi3+0x48>
  8021ac:	39 f7                	cmp    %esi,%edi
  8021ae:	76 50                	jbe    802200 <__umoddi3+0x80>
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	f7 f7                	div    %edi
  8021b6:	89 d0                	mov    %edx,%eax
  8021b8:	31 d2                	xor    %edx,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	39 f2                	cmp    %esi,%edx
  8021ca:	89 d0                	mov    %edx,%eax
  8021cc:	77 52                	ja     802220 <__umoddi3+0xa0>
  8021ce:	0f bd ea             	bsr    %edx,%ebp
  8021d1:	83 f5 1f             	xor    $0x1f,%ebp
  8021d4:	75 5a                	jne    802230 <__umoddi3+0xb0>
  8021d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021da:	0f 82 e0 00 00 00    	jb     8022c0 <__umoddi3+0x140>
  8021e0:	39 0c 24             	cmp    %ecx,(%esp)
  8021e3:	0f 86 d7 00 00 00    	jbe    8022c0 <__umoddi3+0x140>
  8021e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021f1:	83 c4 1c             	add    $0x1c,%esp
  8021f4:	5b                   	pop    %ebx
  8021f5:	5e                   	pop    %esi
  8021f6:	5f                   	pop    %edi
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	85 ff                	test   %edi,%edi
  802202:	89 fd                	mov    %edi,%ebp
  802204:	75 0b                	jne    802211 <__umoddi3+0x91>
  802206:	b8 01 00 00 00       	mov    $0x1,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	f7 f7                	div    %edi
  80220f:	89 c5                	mov    %eax,%ebp
  802211:	89 f0                	mov    %esi,%eax
  802213:	31 d2                	xor    %edx,%edx
  802215:	f7 f5                	div    %ebp
  802217:	89 c8                	mov    %ecx,%eax
  802219:	f7 f5                	div    %ebp
  80221b:	89 d0                	mov    %edx,%eax
  80221d:	eb 99                	jmp    8021b8 <__umoddi3+0x38>
  80221f:	90                   	nop
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	83 c4 1c             	add    $0x1c,%esp
  802227:	5b                   	pop    %ebx
  802228:	5e                   	pop    %esi
  802229:	5f                   	pop    %edi
  80222a:	5d                   	pop    %ebp
  80222b:	c3                   	ret    
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	8b 34 24             	mov    (%esp),%esi
  802233:	bf 20 00 00 00       	mov    $0x20,%edi
  802238:	89 e9                	mov    %ebp,%ecx
  80223a:	29 ef                	sub    %ebp,%edi
  80223c:	d3 e0                	shl    %cl,%eax
  80223e:	89 f9                	mov    %edi,%ecx
  802240:	89 f2                	mov    %esi,%edx
  802242:	d3 ea                	shr    %cl,%edx
  802244:	89 e9                	mov    %ebp,%ecx
  802246:	09 c2                	or     %eax,%edx
  802248:	89 d8                	mov    %ebx,%eax
  80224a:	89 14 24             	mov    %edx,(%esp)
  80224d:	89 f2                	mov    %esi,%edx
  80224f:	d3 e2                	shl    %cl,%edx
  802251:	89 f9                	mov    %edi,%ecx
  802253:	89 54 24 04          	mov    %edx,0x4(%esp)
  802257:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80225b:	d3 e8                	shr    %cl,%eax
  80225d:	89 e9                	mov    %ebp,%ecx
  80225f:	89 c6                	mov    %eax,%esi
  802261:	d3 e3                	shl    %cl,%ebx
  802263:	89 f9                	mov    %edi,%ecx
  802265:	89 d0                	mov    %edx,%eax
  802267:	d3 e8                	shr    %cl,%eax
  802269:	89 e9                	mov    %ebp,%ecx
  80226b:	09 d8                	or     %ebx,%eax
  80226d:	89 d3                	mov    %edx,%ebx
  80226f:	89 f2                	mov    %esi,%edx
  802271:	f7 34 24             	divl   (%esp)
  802274:	89 d6                	mov    %edx,%esi
  802276:	d3 e3                	shl    %cl,%ebx
  802278:	f7 64 24 04          	mull   0x4(%esp)
  80227c:	39 d6                	cmp    %edx,%esi
  80227e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802282:	89 d1                	mov    %edx,%ecx
  802284:	89 c3                	mov    %eax,%ebx
  802286:	72 08                	jb     802290 <__umoddi3+0x110>
  802288:	75 11                	jne    80229b <__umoddi3+0x11b>
  80228a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80228e:	73 0b                	jae    80229b <__umoddi3+0x11b>
  802290:	2b 44 24 04          	sub    0x4(%esp),%eax
  802294:	1b 14 24             	sbb    (%esp),%edx
  802297:	89 d1                	mov    %edx,%ecx
  802299:	89 c3                	mov    %eax,%ebx
  80229b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80229f:	29 da                	sub    %ebx,%edx
  8022a1:	19 ce                	sbb    %ecx,%esi
  8022a3:	89 f9                	mov    %edi,%ecx
  8022a5:	89 f0                	mov    %esi,%eax
  8022a7:	d3 e0                	shl    %cl,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	d3 ea                	shr    %cl,%edx
  8022ad:	89 e9                	mov    %ebp,%ecx
  8022af:	d3 ee                	shr    %cl,%esi
  8022b1:	09 d0                	or     %edx,%eax
  8022b3:	89 f2                	mov    %esi,%edx
  8022b5:	83 c4 1c             	add    $0x1c,%esp
  8022b8:	5b                   	pop    %ebx
  8022b9:	5e                   	pop    %esi
  8022ba:	5f                   	pop    %edi
  8022bb:	5d                   	pop    %ebp
  8022bc:	c3                   	ret    
  8022bd:	8d 76 00             	lea    0x0(%esi),%esi
  8022c0:	29 f9                	sub    %edi,%ecx
  8022c2:	19 d6                	sbb    %edx,%esi
  8022c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022cc:	e9 18 ff ff ff       	jmp    8021e9 <__umoddi3+0x69>
