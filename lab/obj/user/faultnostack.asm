
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
  800039:	68 80 03 80 00       	push   $0x800380
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
  8000a0:	e8 ca 04 00 00       	call   80056f <close_all>
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
  800119:	68 aa 22 80 00       	push   $0x8022aa
  80011e:	6a 23                	push   $0x23
  800120:	68 c7 22 80 00       	push   $0x8022c7
  800125:	e8 be 13 00 00       	call   8014e8 <_panic>

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
  80019a:	68 aa 22 80 00       	push   $0x8022aa
  80019f:	6a 23                	push   $0x23
  8001a1:	68 c7 22 80 00       	push   $0x8022c7
  8001a6:	e8 3d 13 00 00       	call   8014e8 <_panic>

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
  8001dc:	68 aa 22 80 00       	push   $0x8022aa
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 c7 22 80 00       	push   $0x8022c7
  8001e8:	e8 fb 12 00 00       	call   8014e8 <_panic>

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
  80021e:	68 aa 22 80 00       	push   $0x8022aa
  800223:	6a 23                	push   $0x23
  800225:	68 c7 22 80 00       	push   $0x8022c7
  80022a:	e8 b9 12 00 00       	call   8014e8 <_panic>

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
  800260:	68 aa 22 80 00       	push   $0x8022aa
  800265:	6a 23                	push   $0x23
  800267:	68 c7 22 80 00       	push   $0x8022c7
  80026c:	e8 77 12 00 00       	call   8014e8 <_panic>

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
  8002a2:	68 aa 22 80 00       	push   $0x8022aa
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 c7 22 80 00       	push   $0x8022c7
  8002ae:	e8 35 12 00 00       	call   8014e8 <_panic>

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
  8002e4:	68 aa 22 80 00       	push   $0x8022aa
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 c7 22 80 00       	push   $0x8022c7
  8002f0:	e8 f3 11 00 00       	call   8014e8 <_panic>

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
  800348:	68 aa 22 80 00       	push   $0x8022aa
  80034d:	6a 23                	push   $0x23
  80034f:	68 c7 22 80 00       	push   $0x8022c7
  800354:	e8 8f 11 00 00       	call   8014e8 <_panic>

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

00800380 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800380:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800381:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  800386:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800388:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80038b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80038f:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  800393:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  800396:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  800399:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80039a:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80039d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80039e:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80039f:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8003a3:	c3                   	ret    

008003a4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003aa:	05 00 00 00 30       	add    $0x30000000,%eax
  8003af:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8003bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d6:	89 c2                	mov    %eax,%edx
  8003d8:	c1 ea 16             	shr    $0x16,%edx
  8003db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e2:	f6 c2 01             	test   $0x1,%dl
  8003e5:	74 11                	je     8003f8 <fd_alloc+0x2d>
  8003e7:	89 c2                	mov    %eax,%edx
  8003e9:	c1 ea 0c             	shr    $0xc,%edx
  8003ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f3:	f6 c2 01             	test   $0x1,%dl
  8003f6:	75 09                	jne    800401 <fd_alloc+0x36>
			*fd_store = fd;
  8003f8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ff:	eb 17                	jmp    800418 <fd_alloc+0x4d>
  800401:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800406:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80040b:	75 c9                	jne    8003d6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80040d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800413:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800420:	83 f8 1f             	cmp    $0x1f,%eax
  800423:	77 36                	ja     80045b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800425:	c1 e0 0c             	shl    $0xc,%eax
  800428:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80042d:	89 c2                	mov    %eax,%edx
  80042f:	c1 ea 16             	shr    $0x16,%edx
  800432:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800439:	f6 c2 01             	test   $0x1,%dl
  80043c:	74 24                	je     800462 <fd_lookup+0x48>
  80043e:	89 c2                	mov    %eax,%edx
  800440:	c1 ea 0c             	shr    $0xc,%edx
  800443:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80044a:	f6 c2 01             	test   $0x1,%dl
  80044d:	74 1a                	je     800469 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80044f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800452:	89 02                	mov    %eax,(%edx)
	return 0;
  800454:	b8 00 00 00 00       	mov    $0x0,%eax
  800459:	eb 13                	jmp    80046e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80045b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800460:	eb 0c                	jmp    80046e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800462:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800467:	eb 05                	jmp    80046e <fd_lookup+0x54>
  800469:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80046e:	5d                   	pop    %ebp
  80046f:	c3                   	ret    

00800470 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800479:	ba 54 23 80 00       	mov    $0x802354,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80047e:	eb 13                	jmp    800493 <dev_lookup+0x23>
  800480:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800483:	39 08                	cmp    %ecx,(%eax)
  800485:	75 0c                	jne    800493 <dev_lookup+0x23>
			*dev = devtab[i];
  800487:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80048a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80048c:	b8 00 00 00 00       	mov    $0x0,%eax
  800491:	eb 2e                	jmp    8004c1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800493:	8b 02                	mov    (%edx),%eax
  800495:	85 c0                	test   %eax,%eax
  800497:	75 e7                	jne    800480 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800499:	a1 08 40 80 00       	mov    0x804008,%eax
  80049e:	8b 40 48             	mov    0x48(%eax),%eax
  8004a1:	83 ec 04             	sub    $0x4,%esp
  8004a4:	51                   	push   %ecx
  8004a5:	50                   	push   %eax
  8004a6:	68 d8 22 80 00       	push   $0x8022d8
  8004ab:	e8 11 11 00 00       	call   8015c1 <cprintf>
	*dev = 0;
  8004b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004b9:	83 c4 10             	add    $0x10,%esp
  8004bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004c1:	c9                   	leave  
  8004c2:	c3                   	ret    

008004c3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004c3:	55                   	push   %ebp
  8004c4:	89 e5                	mov    %esp,%ebp
  8004c6:	56                   	push   %esi
  8004c7:	53                   	push   %ebx
  8004c8:	83 ec 10             	sub    $0x10,%esp
  8004cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d4:	50                   	push   %eax
  8004d5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004db:	c1 e8 0c             	shr    $0xc,%eax
  8004de:	50                   	push   %eax
  8004df:	e8 36 ff ff ff       	call   80041a <fd_lookup>
  8004e4:	83 c4 08             	add    $0x8,%esp
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	78 05                	js     8004f0 <fd_close+0x2d>
	    || fd != fd2)
  8004eb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004ee:	74 0c                	je     8004fc <fd_close+0x39>
		return (must_exist ? r : 0);
  8004f0:	84 db                	test   %bl,%bl
  8004f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f7:	0f 44 c2             	cmove  %edx,%eax
  8004fa:	eb 41                	jmp    80053d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800502:	50                   	push   %eax
  800503:	ff 36                	pushl  (%esi)
  800505:	e8 66 ff ff ff       	call   800470 <dev_lookup>
  80050a:	89 c3                	mov    %eax,%ebx
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	85 c0                	test   %eax,%eax
  800511:	78 1a                	js     80052d <fd_close+0x6a>
		if (dev->dev_close)
  800513:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800516:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800519:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80051e:	85 c0                	test   %eax,%eax
  800520:	74 0b                	je     80052d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800522:	83 ec 0c             	sub    $0xc,%esp
  800525:	56                   	push   %esi
  800526:	ff d0                	call   *%eax
  800528:	89 c3                	mov    %eax,%ebx
  80052a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	56                   	push   %esi
  800531:	6a 00                	push   $0x0
  800533:	e8 bd fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	89 d8                	mov    %ebx,%eax
}
  80053d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800540:	5b                   	pop    %ebx
  800541:	5e                   	pop    %esi
  800542:	5d                   	pop    %ebp
  800543:	c3                   	ret    

00800544 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80054a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80054d:	50                   	push   %eax
  80054e:	ff 75 08             	pushl  0x8(%ebp)
  800551:	e8 c4 fe ff ff       	call   80041a <fd_lookup>
  800556:	83 c4 08             	add    $0x8,%esp
  800559:	85 c0                	test   %eax,%eax
  80055b:	78 10                	js     80056d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	6a 01                	push   $0x1
  800562:	ff 75 f4             	pushl  -0xc(%ebp)
  800565:	e8 59 ff ff ff       	call   8004c3 <fd_close>
  80056a:	83 c4 10             	add    $0x10,%esp
}
  80056d:	c9                   	leave  
  80056e:	c3                   	ret    

0080056f <close_all>:

void
close_all(void)
{
  80056f:	55                   	push   %ebp
  800570:	89 e5                	mov    %esp,%ebp
  800572:	53                   	push   %ebx
  800573:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80057b:	83 ec 0c             	sub    $0xc,%esp
  80057e:	53                   	push   %ebx
  80057f:	e8 c0 ff ff ff       	call   800544 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800584:	83 c3 01             	add    $0x1,%ebx
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	83 fb 20             	cmp    $0x20,%ebx
  80058d:	75 ec                	jne    80057b <close_all+0xc>
		close(i);
}
  80058f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800592:	c9                   	leave  
  800593:	c3                   	ret    

00800594 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800594:	55                   	push   %ebp
  800595:	89 e5                	mov    %esp,%ebp
  800597:	57                   	push   %edi
  800598:	56                   	push   %esi
  800599:	53                   	push   %ebx
  80059a:	83 ec 2c             	sub    $0x2c,%esp
  80059d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a3:	50                   	push   %eax
  8005a4:	ff 75 08             	pushl  0x8(%ebp)
  8005a7:	e8 6e fe ff ff       	call   80041a <fd_lookup>
  8005ac:	83 c4 08             	add    $0x8,%esp
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	0f 88 c1 00 00 00    	js     800678 <dup+0xe4>
		return r;
	close(newfdnum);
  8005b7:	83 ec 0c             	sub    $0xc,%esp
  8005ba:	56                   	push   %esi
  8005bb:	e8 84 ff ff ff       	call   800544 <close>

	newfd = INDEX2FD(newfdnum);
  8005c0:	89 f3                	mov    %esi,%ebx
  8005c2:	c1 e3 0c             	shl    $0xc,%ebx
  8005c5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005cb:	83 c4 04             	add    $0x4,%esp
  8005ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005d1:	e8 de fd ff ff       	call   8003b4 <fd2data>
  8005d6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005d8:	89 1c 24             	mov    %ebx,(%esp)
  8005db:	e8 d4 fd ff ff       	call   8003b4 <fd2data>
  8005e0:	83 c4 10             	add    $0x10,%esp
  8005e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005e6:	89 f8                	mov    %edi,%eax
  8005e8:	c1 e8 16             	shr    $0x16,%eax
  8005eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005f2:	a8 01                	test   $0x1,%al
  8005f4:	74 37                	je     80062d <dup+0x99>
  8005f6:	89 f8                	mov    %edi,%eax
  8005f8:	c1 e8 0c             	shr    $0xc,%eax
  8005fb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800602:	f6 c2 01             	test   $0x1,%dl
  800605:	74 26                	je     80062d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800607:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060e:	83 ec 0c             	sub    $0xc,%esp
  800611:	25 07 0e 00 00       	and    $0xe07,%eax
  800616:	50                   	push   %eax
  800617:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061a:	6a 00                	push   $0x0
  80061c:	57                   	push   %edi
  80061d:	6a 00                	push   $0x0
  80061f:	e8 8f fb ff ff       	call   8001b3 <sys_page_map>
  800624:	89 c7                	mov    %eax,%edi
  800626:	83 c4 20             	add    $0x20,%esp
  800629:	85 c0                	test   %eax,%eax
  80062b:	78 2e                	js     80065b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80062d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800630:	89 d0                	mov    %edx,%eax
  800632:	c1 e8 0c             	shr    $0xc,%eax
  800635:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80063c:	83 ec 0c             	sub    $0xc,%esp
  80063f:	25 07 0e 00 00       	and    $0xe07,%eax
  800644:	50                   	push   %eax
  800645:	53                   	push   %ebx
  800646:	6a 00                	push   $0x0
  800648:	52                   	push   %edx
  800649:	6a 00                	push   $0x0
  80064b:	e8 63 fb ff ff       	call   8001b3 <sys_page_map>
  800650:	89 c7                	mov    %eax,%edi
  800652:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800655:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800657:	85 ff                	test   %edi,%edi
  800659:	79 1d                	jns    800678 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	53                   	push   %ebx
  80065f:	6a 00                	push   $0x0
  800661:	e8 8f fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800666:	83 c4 08             	add    $0x8,%esp
  800669:	ff 75 d4             	pushl  -0x2c(%ebp)
  80066c:	6a 00                	push   $0x0
  80066e:	e8 82 fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	89 f8                	mov    %edi,%eax
}
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
  800683:	53                   	push   %ebx
  800684:	83 ec 14             	sub    $0x14,%esp
  800687:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80068a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80068d:	50                   	push   %eax
  80068e:	53                   	push   %ebx
  80068f:	e8 86 fd ff ff       	call   80041a <fd_lookup>
  800694:	83 c4 08             	add    $0x8,%esp
  800697:	89 c2                	mov    %eax,%edx
  800699:	85 c0                	test   %eax,%eax
  80069b:	78 6d                	js     80070a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006a3:	50                   	push   %eax
  8006a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a7:	ff 30                	pushl  (%eax)
  8006a9:	e8 c2 fd ff ff       	call   800470 <dev_lookup>
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	85 c0                	test   %eax,%eax
  8006b3:	78 4c                	js     800701 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006b8:	8b 42 08             	mov    0x8(%edx),%eax
  8006bb:	83 e0 03             	and    $0x3,%eax
  8006be:	83 f8 01             	cmp    $0x1,%eax
  8006c1:	75 21                	jne    8006e4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006c3:	a1 08 40 80 00       	mov    0x804008,%eax
  8006c8:	8b 40 48             	mov    0x48(%eax),%eax
  8006cb:	83 ec 04             	sub    $0x4,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	50                   	push   %eax
  8006d0:	68 19 23 80 00       	push   $0x802319
  8006d5:	e8 e7 0e 00 00       	call   8015c1 <cprintf>
		return -E_INVAL;
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006e2:	eb 26                	jmp    80070a <read+0x8a>
	}
	if (!dev->dev_read)
  8006e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e7:	8b 40 08             	mov    0x8(%eax),%eax
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	74 17                	je     800705 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006ee:	83 ec 04             	sub    $0x4,%esp
  8006f1:	ff 75 10             	pushl  0x10(%ebp)
  8006f4:	ff 75 0c             	pushl  0xc(%ebp)
  8006f7:	52                   	push   %edx
  8006f8:	ff d0                	call   *%eax
  8006fa:	89 c2                	mov    %eax,%edx
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	eb 09                	jmp    80070a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800701:	89 c2                	mov    %eax,%edx
  800703:	eb 05                	jmp    80070a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800705:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80070a:	89 d0                	mov    %edx,%eax
  80070c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070f:	c9                   	leave  
  800710:	c3                   	ret    

00800711 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	57                   	push   %edi
  800715:	56                   	push   %esi
  800716:	53                   	push   %ebx
  800717:	83 ec 0c             	sub    $0xc,%esp
  80071a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800720:	bb 00 00 00 00       	mov    $0x0,%ebx
  800725:	eb 21                	jmp    800748 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800727:	83 ec 04             	sub    $0x4,%esp
  80072a:	89 f0                	mov    %esi,%eax
  80072c:	29 d8                	sub    %ebx,%eax
  80072e:	50                   	push   %eax
  80072f:	89 d8                	mov    %ebx,%eax
  800731:	03 45 0c             	add    0xc(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	57                   	push   %edi
  800736:	e8 45 ff ff ff       	call   800680 <read>
		if (m < 0)
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 10                	js     800752 <readn+0x41>
			return m;
		if (m == 0)
  800742:	85 c0                	test   %eax,%eax
  800744:	74 0a                	je     800750 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800746:	01 c3                	add    %eax,%ebx
  800748:	39 f3                	cmp    %esi,%ebx
  80074a:	72 db                	jb     800727 <readn+0x16>
  80074c:	89 d8                	mov    %ebx,%eax
  80074e:	eb 02                	jmp    800752 <readn+0x41>
  800750:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800752:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800755:	5b                   	pop    %ebx
  800756:	5e                   	pop    %esi
  800757:	5f                   	pop    %edi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	53                   	push   %ebx
  80075e:	83 ec 14             	sub    $0x14,%esp
  800761:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800764:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800767:	50                   	push   %eax
  800768:	53                   	push   %ebx
  800769:	e8 ac fc ff ff       	call   80041a <fd_lookup>
  80076e:	83 c4 08             	add    $0x8,%esp
  800771:	89 c2                	mov    %eax,%edx
  800773:	85 c0                	test   %eax,%eax
  800775:	78 68                	js     8007df <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800777:	83 ec 08             	sub    $0x8,%esp
  80077a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80077d:	50                   	push   %eax
  80077e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800781:	ff 30                	pushl  (%eax)
  800783:	e8 e8 fc ff ff       	call   800470 <dev_lookup>
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	85 c0                	test   %eax,%eax
  80078d:	78 47                	js     8007d6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80078f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800792:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800796:	75 21                	jne    8007b9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800798:	a1 08 40 80 00       	mov    0x804008,%eax
  80079d:	8b 40 48             	mov    0x48(%eax),%eax
  8007a0:	83 ec 04             	sub    $0x4,%esp
  8007a3:	53                   	push   %ebx
  8007a4:	50                   	push   %eax
  8007a5:	68 35 23 80 00       	push   $0x802335
  8007aa:	e8 12 0e 00 00       	call   8015c1 <cprintf>
		return -E_INVAL;
  8007af:	83 c4 10             	add    $0x10,%esp
  8007b2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007b7:	eb 26                	jmp    8007df <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	74 17                	je     8007da <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c3:	83 ec 04             	sub    $0x4,%esp
  8007c6:	ff 75 10             	pushl  0x10(%ebp)
  8007c9:	ff 75 0c             	pushl  0xc(%ebp)
  8007cc:	50                   	push   %eax
  8007cd:	ff d2                	call   *%edx
  8007cf:	89 c2                	mov    %eax,%edx
  8007d1:	83 c4 10             	add    $0x10,%esp
  8007d4:	eb 09                	jmp    8007df <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d6:	89 c2                	mov    %eax,%edx
  8007d8:	eb 05                	jmp    8007df <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007df:	89 d0                	mov    %edx,%eax
  8007e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    

008007e6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007ef:	50                   	push   %eax
  8007f0:	ff 75 08             	pushl  0x8(%ebp)
  8007f3:	e8 22 fc ff ff       	call   80041a <fd_lookup>
  8007f8:	83 c4 08             	add    $0x8,%esp
  8007fb:	85 c0                	test   %eax,%eax
  8007fd:	78 0e                	js     80080d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800802:	8b 55 0c             	mov    0xc(%ebp),%edx
  800805:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800808:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80080d:	c9                   	leave  
  80080e:	c3                   	ret    

0080080f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	83 ec 14             	sub    $0x14,%esp
  800816:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800819:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80081c:	50                   	push   %eax
  80081d:	53                   	push   %ebx
  80081e:	e8 f7 fb ff ff       	call   80041a <fd_lookup>
  800823:	83 c4 08             	add    $0x8,%esp
  800826:	89 c2                	mov    %eax,%edx
  800828:	85 c0                	test   %eax,%eax
  80082a:	78 65                	js     800891 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082c:	83 ec 08             	sub    $0x8,%esp
  80082f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800832:	50                   	push   %eax
  800833:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800836:	ff 30                	pushl  (%eax)
  800838:	e8 33 fc ff ff       	call   800470 <dev_lookup>
  80083d:	83 c4 10             	add    $0x10,%esp
  800840:	85 c0                	test   %eax,%eax
  800842:	78 44                	js     800888 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800844:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800847:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80084b:	75 21                	jne    80086e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80084d:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800852:	8b 40 48             	mov    0x48(%eax),%eax
  800855:	83 ec 04             	sub    $0x4,%esp
  800858:	53                   	push   %ebx
  800859:	50                   	push   %eax
  80085a:	68 f8 22 80 00       	push   $0x8022f8
  80085f:	e8 5d 0d 00 00       	call   8015c1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80086c:	eb 23                	jmp    800891 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80086e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800871:	8b 52 18             	mov    0x18(%edx),%edx
  800874:	85 d2                	test   %edx,%edx
  800876:	74 14                	je     80088c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	ff 75 0c             	pushl  0xc(%ebp)
  80087e:	50                   	push   %eax
  80087f:	ff d2                	call   *%edx
  800881:	89 c2                	mov    %eax,%edx
  800883:	83 c4 10             	add    $0x10,%esp
  800886:	eb 09                	jmp    800891 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800888:	89 c2                	mov    %eax,%edx
  80088a:	eb 05                	jmp    800891 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80088c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800891:	89 d0                	mov    %edx,%eax
  800893:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	53                   	push   %ebx
  80089c:	83 ec 14             	sub    $0x14,%esp
  80089f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a5:	50                   	push   %eax
  8008a6:	ff 75 08             	pushl  0x8(%ebp)
  8008a9:	e8 6c fb ff ff       	call   80041a <fd_lookup>
  8008ae:	83 c4 08             	add    $0x8,%esp
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	85 c0                	test   %eax,%eax
  8008b5:	78 58                	js     80090f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008bd:	50                   	push   %eax
  8008be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c1:	ff 30                	pushl  (%eax)
  8008c3:	e8 a8 fb ff ff       	call   800470 <dev_lookup>
  8008c8:	83 c4 10             	add    $0x10,%esp
  8008cb:	85 c0                	test   %eax,%eax
  8008cd:	78 37                	js     800906 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008d6:	74 32                	je     80090a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008d8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008db:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008e2:	00 00 00 
	stat->st_isdir = 0;
  8008e5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ec:	00 00 00 
	stat->st_dev = dev;
  8008ef:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008f5:	83 ec 08             	sub    $0x8,%esp
  8008f8:	53                   	push   %ebx
  8008f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008fc:	ff 50 14             	call   *0x14(%eax)
  8008ff:	89 c2                	mov    %eax,%edx
  800901:	83 c4 10             	add    $0x10,%esp
  800904:	eb 09                	jmp    80090f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800906:	89 c2                	mov    %eax,%edx
  800908:	eb 05                	jmp    80090f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80090a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80090f:	89 d0                	mov    %edx,%eax
  800911:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800914:	c9                   	leave  
  800915:	c3                   	ret    

00800916 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80091b:	83 ec 08             	sub    $0x8,%esp
  80091e:	6a 00                	push   $0x0
  800920:	ff 75 08             	pushl  0x8(%ebp)
  800923:	e8 d6 01 00 00       	call   800afe <open>
  800928:	89 c3                	mov    %eax,%ebx
  80092a:	83 c4 10             	add    $0x10,%esp
  80092d:	85 c0                	test   %eax,%eax
  80092f:	78 1b                	js     80094c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800931:	83 ec 08             	sub    $0x8,%esp
  800934:	ff 75 0c             	pushl  0xc(%ebp)
  800937:	50                   	push   %eax
  800938:	e8 5b ff ff ff       	call   800898 <fstat>
  80093d:	89 c6                	mov    %eax,%esi
	close(fd);
  80093f:	89 1c 24             	mov    %ebx,(%esp)
  800942:	e8 fd fb ff ff       	call   800544 <close>
	return r;
  800947:	83 c4 10             	add    $0x10,%esp
  80094a:	89 f0                	mov    %esi,%eax
}
  80094c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	56                   	push   %esi
  800957:	53                   	push   %ebx
  800958:	89 c6                	mov    %eax,%esi
  80095a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80095c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800963:	75 12                	jne    800977 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800965:	83 ec 0c             	sub    $0xc,%esp
  800968:	6a 01                	push   $0x1
  80096a:	e8 20 16 00 00       	call   801f8f <ipc_find_env>
  80096f:	a3 00 40 80 00       	mov    %eax,0x804000
  800974:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800977:	6a 07                	push   $0x7
  800979:	68 00 50 80 00       	push   $0x805000
  80097e:	56                   	push   %esi
  80097f:	ff 35 00 40 80 00    	pushl  0x804000
  800985:	e8 b1 15 00 00       	call   801f3b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80098a:	83 c4 0c             	add    $0xc,%esp
  80098d:	6a 00                	push   $0x0
  80098f:	53                   	push   %ebx
  800990:	6a 00                	push   $0x0
  800992:	e8 3d 15 00 00       	call   801ed4 <ipc_recv>
}
  800997:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80099a:	5b                   	pop    %ebx
  80099b:	5e                   	pop    %esi
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8009c1:	e8 8d ff ff ff       	call   800953 <fsipc>
}
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009de:	b8 06 00 00 00       	mov    $0x6,%eax
  8009e3:	e8 6b ff ff ff       	call   800953 <fsipc>
}
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	53                   	push   %ebx
  8009ee:	83 ec 04             	sub    $0x4,%esp
  8009f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800a04:	b8 05 00 00 00       	mov    $0x5,%eax
  800a09:	e8 45 ff ff ff       	call   800953 <fsipc>
  800a0e:	85 c0                	test   %eax,%eax
  800a10:	78 2c                	js     800a3e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a12:	83 ec 08             	sub    $0x8,%esp
  800a15:	68 00 50 80 00       	push   $0x805000
  800a1a:	53                   	push   %ebx
  800a1b:	e8 26 11 00 00       	call   801b46 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a20:	a1 80 50 80 00       	mov    0x805080,%eax
  800a25:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a2b:	a1 84 50 80 00       	mov    0x805084,%eax
  800a30:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a36:	83 c4 10             	add    $0x10,%esp
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	83 ec 0c             	sub    $0xc,%esp
  800a49:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a52:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a58:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a5d:	50                   	push   %eax
  800a5e:	ff 75 0c             	pushl  0xc(%ebp)
  800a61:	68 08 50 80 00       	push   $0x805008
  800a66:	e8 6d 12 00 00       	call   801cd8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a70:	b8 04 00 00 00       	mov    $0x4,%eax
  800a75:	e8 d9 fe ff ff       	call   800953 <fsipc>

}
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a95:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9f:	e8 af fe ff ff       	call   800953 <fsipc>
  800aa4:	89 c3                	mov    %eax,%ebx
  800aa6:	85 c0                	test   %eax,%eax
  800aa8:	78 4b                	js     800af5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aaa:	39 c6                	cmp    %eax,%esi
  800aac:	73 16                	jae    800ac4 <devfile_read+0x48>
  800aae:	68 68 23 80 00       	push   $0x802368
  800ab3:	68 6f 23 80 00       	push   $0x80236f
  800ab8:	6a 7c                	push   $0x7c
  800aba:	68 84 23 80 00       	push   $0x802384
  800abf:	e8 24 0a 00 00       	call   8014e8 <_panic>
	assert(r <= PGSIZE);
  800ac4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac9:	7e 16                	jle    800ae1 <devfile_read+0x65>
  800acb:	68 8f 23 80 00       	push   $0x80238f
  800ad0:	68 6f 23 80 00       	push   $0x80236f
  800ad5:	6a 7d                	push   $0x7d
  800ad7:	68 84 23 80 00       	push   $0x802384
  800adc:	e8 07 0a 00 00       	call   8014e8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae1:	83 ec 04             	sub    $0x4,%esp
  800ae4:	50                   	push   %eax
  800ae5:	68 00 50 80 00       	push   $0x805000
  800aea:	ff 75 0c             	pushl  0xc(%ebp)
  800aed:	e8 e6 11 00 00       	call   801cd8 <memmove>
	return r;
  800af2:	83 c4 10             	add    $0x10,%esp
}
  800af5:	89 d8                	mov    %ebx,%eax
  800af7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	53                   	push   %ebx
  800b02:	83 ec 20             	sub    $0x20,%esp
  800b05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b08:	53                   	push   %ebx
  800b09:	e8 ff 0f 00 00       	call   801b0d <strlen>
  800b0e:	83 c4 10             	add    $0x10,%esp
  800b11:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b16:	7f 67                	jg     800b7f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b18:	83 ec 0c             	sub    $0xc,%esp
  800b1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1e:	50                   	push   %eax
  800b1f:	e8 a7 f8 ff ff       	call   8003cb <fd_alloc>
  800b24:	83 c4 10             	add    $0x10,%esp
		return r;
  800b27:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b29:	85 c0                	test   %eax,%eax
  800b2b:	78 57                	js     800b84 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b2d:	83 ec 08             	sub    $0x8,%esp
  800b30:	53                   	push   %ebx
  800b31:	68 00 50 80 00       	push   $0x805000
  800b36:	e8 0b 10 00 00       	call   801b46 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b43:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b46:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4b:	e8 03 fe ff ff       	call   800953 <fsipc>
  800b50:	89 c3                	mov    %eax,%ebx
  800b52:	83 c4 10             	add    $0x10,%esp
  800b55:	85 c0                	test   %eax,%eax
  800b57:	79 14                	jns    800b6d <open+0x6f>
		fd_close(fd, 0);
  800b59:	83 ec 08             	sub    $0x8,%esp
  800b5c:	6a 00                	push   $0x0
  800b5e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b61:	e8 5d f9 ff ff       	call   8004c3 <fd_close>
		return r;
  800b66:	83 c4 10             	add    $0x10,%esp
  800b69:	89 da                	mov    %ebx,%edx
  800b6b:	eb 17                	jmp    800b84 <open+0x86>
	}

	return fd2num(fd);
  800b6d:	83 ec 0c             	sub    $0xc,%esp
  800b70:	ff 75 f4             	pushl  -0xc(%ebp)
  800b73:	e8 2c f8 ff ff       	call   8003a4 <fd2num>
  800b78:	89 c2                	mov    %eax,%edx
  800b7a:	83 c4 10             	add    $0x10,%esp
  800b7d:	eb 05                	jmp    800b84 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b7f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b84:	89 d0                	mov    %edx,%eax
  800b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    

00800b8b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b91:	ba 00 00 00 00       	mov    $0x0,%edx
  800b96:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9b:	e8 b3 fd ff ff       	call   800953 <fsipc>
}
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ba8:	68 9b 23 80 00       	push   $0x80239b
  800bad:	ff 75 0c             	pushl  0xc(%ebp)
  800bb0:	e8 91 0f 00 00       	call   801b46 <strcpy>
	return 0;
}
  800bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bba:	c9                   	leave  
  800bbb:	c3                   	ret    

00800bbc <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 10             	sub    $0x10,%esp
  800bc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bc6:	53                   	push   %ebx
  800bc7:	e8 fc 13 00 00       	call   801fc8 <pageref>
  800bcc:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bcf:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bd4:	83 f8 01             	cmp    $0x1,%eax
  800bd7:	75 10                	jne    800be9 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bd9:	83 ec 0c             	sub    $0xc,%esp
  800bdc:	ff 73 0c             	pushl  0xc(%ebx)
  800bdf:	e8 c0 02 00 00       	call   800ea4 <nsipc_close>
  800be4:	89 c2                	mov    %eax,%edx
  800be6:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800be9:	89 d0                	mov    %edx,%eax
  800beb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bee:	c9                   	leave  
  800bef:	c3                   	ret    

00800bf0 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bf6:	6a 00                	push   $0x0
  800bf8:	ff 75 10             	pushl  0x10(%ebp)
  800bfb:	ff 75 0c             	pushl  0xc(%ebp)
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	ff 70 0c             	pushl  0xc(%eax)
  800c04:	e8 78 03 00 00       	call   800f81 <nsipc_send>
}
  800c09:	c9                   	leave  
  800c0a:	c3                   	ret    

00800c0b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c11:	6a 00                	push   $0x0
  800c13:	ff 75 10             	pushl  0x10(%ebp)
  800c16:	ff 75 0c             	pushl  0xc(%ebp)
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	ff 70 0c             	pushl  0xc(%eax)
  800c1f:	e8 f1 02 00 00       	call   800f15 <nsipc_recv>
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c2c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c2f:	52                   	push   %edx
  800c30:	50                   	push   %eax
  800c31:	e8 e4 f7 ff ff       	call   80041a <fd_lookup>
  800c36:	83 c4 10             	add    $0x10,%esp
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	78 17                	js     800c54 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c40:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c46:	39 08                	cmp    %ecx,(%eax)
  800c48:	75 05                	jne    800c4f <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c4a:	8b 40 0c             	mov    0xc(%eax),%eax
  800c4d:	eb 05                	jmp    800c54 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c4f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c54:	c9                   	leave  
  800c55:	c3                   	ret    

00800c56 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 1c             	sub    $0x1c,%esp
  800c5e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c63:	50                   	push   %eax
  800c64:	e8 62 f7 ff ff       	call   8003cb <fd_alloc>
  800c69:	89 c3                	mov    %eax,%ebx
  800c6b:	83 c4 10             	add    $0x10,%esp
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	78 1b                	js     800c8d <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c72:	83 ec 04             	sub    $0x4,%esp
  800c75:	68 07 04 00 00       	push   $0x407
  800c7a:	ff 75 f4             	pushl  -0xc(%ebp)
  800c7d:	6a 00                	push   $0x0
  800c7f:	e8 ec f4 ff ff       	call   800170 <sys_page_alloc>
  800c84:	89 c3                	mov    %eax,%ebx
  800c86:	83 c4 10             	add    $0x10,%esp
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	79 10                	jns    800c9d <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c8d:	83 ec 0c             	sub    $0xc,%esp
  800c90:	56                   	push   %esi
  800c91:	e8 0e 02 00 00       	call   800ea4 <nsipc_close>
		return r;
  800c96:	83 c4 10             	add    $0x10,%esp
  800c99:	89 d8                	mov    %ebx,%eax
  800c9b:	eb 24                	jmp    800cc1 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c9d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cb2:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cb5:	83 ec 0c             	sub    $0xc,%esp
  800cb8:	50                   	push   %eax
  800cb9:	e8 e6 f6 ff ff       	call   8003a4 <fd2num>
  800cbe:	83 c4 10             	add    $0x10,%esp
}
  800cc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cce:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd1:	e8 50 ff ff ff       	call   800c26 <fd2sockid>
		return r;
  800cd6:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	78 1f                	js     800cfb <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cdc:	83 ec 04             	sub    $0x4,%esp
  800cdf:	ff 75 10             	pushl  0x10(%ebp)
  800ce2:	ff 75 0c             	pushl  0xc(%ebp)
  800ce5:	50                   	push   %eax
  800ce6:	e8 12 01 00 00       	call   800dfd <nsipc_accept>
  800ceb:	83 c4 10             	add    $0x10,%esp
		return r;
  800cee:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	78 07                	js     800cfb <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cf4:	e8 5d ff ff ff       	call   800c56 <alloc_sockfd>
  800cf9:	89 c1                	mov    %eax,%ecx
}
  800cfb:	89 c8                	mov    %ecx,%eax
  800cfd:	c9                   	leave  
  800cfe:	c3                   	ret    

00800cff <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d05:	8b 45 08             	mov    0x8(%ebp),%eax
  800d08:	e8 19 ff ff ff       	call   800c26 <fd2sockid>
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	78 12                	js     800d23 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d11:	83 ec 04             	sub    $0x4,%esp
  800d14:	ff 75 10             	pushl  0x10(%ebp)
  800d17:	ff 75 0c             	pushl  0xc(%ebp)
  800d1a:	50                   	push   %eax
  800d1b:	e8 2d 01 00 00       	call   800e4d <nsipc_bind>
  800d20:	83 c4 10             	add    $0x10,%esp
}
  800d23:	c9                   	leave  
  800d24:	c3                   	ret    

00800d25 <shutdown>:

int
shutdown(int s, int how)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2e:	e8 f3 fe ff ff       	call   800c26 <fd2sockid>
  800d33:	85 c0                	test   %eax,%eax
  800d35:	78 0f                	js     800d46 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d37:	83 ec 08             	sub    $0x8,%esp
  800d3a:	ff 75 0c             	pushl  0xc(%ebp)
  800d3d:	50                   	push   %eax
  800d3e:	e8 3f 01 00 00       	call   800e82 <nsipc_shutdown>
  800d43:	83 c4 10             	add    $0x10,%esp
}
  800d46:	c9                   	leave  
  800d47:	c3                   	ret    

00800d48 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	e8 d0 fe ff ff       	call   800c26 <fd2sockid>
  800d56:	85 c0                	test   %eax,%eax
  800d58:	78 12                	js     800d6c <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d5a:	83 ec 04             	sub    $0x4,%esp
  800d5d:	ff 75 10             	pushl  0x10(%ebp)
  800d60:	ff 75 0c             	pushl  0xc(%ebp)
  800d63:	50                   	push   %eax
  800d64:	e8 55 01 00 00       	call   800ebe <nsipc_connect>
  800d69:	83 c4 10             	add    $0x10,%esp
}
  800d6c:	c9                   	leave  
  800d6d:	c3                   	ret    

00800d6e <listen>:

int
listen(int s, int backlog)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d74:	8b 45 08             	mov    0x8(%ebp),%eax
  800d77:	e8 aa fe ff ff       	call   800c26 <fd2sockid>
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	78 0f                	js     800d8f <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d80:	83 ec 08             	sub    $0x8,%esp
  800d83:	ff 75 0c             	pushl  0xc(%ebp)
  800d86:	50                   	push   %eax
  800d87:	e8 67 01 00 00       	call   800ef3 <nsipc_listen>
  800d8c:	83 c4 10             	add    $0x10,%esp
}
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d97:	ff 75 10             	pushl  0x10(%ebp)
  800d9a:	ff 75 0c             	pushl  0xc(%ebp)
  800d9d:	ff 75 08             	pushl  0x8(%ebp)
  800da0:	e8 3a 02 00 00       	call   800fdf <nsipc_socket>
  800da5:	83 c4 10             	add    $0x10,%esp
  800da8:	85 c0                	test   %eax,%eax
  800daa:	78 05                	js     800db1 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dac:	e8 a5 fe ff ff       	call   800c56 <alloc_sockfd>
}
  800db1:	c9                   	leave  
  800db2:	c3                   	ret    

00800db3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	53                   	push   %ebx
  800db7:	83 ec 04             	sub    $0x4,%esp
  800dba:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dbc:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dc3:	75 12                	jne    800dd7 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	6a 02                	push   $0x2
  800dca:	e8 c0 11 00 00       	call   801f8f <ipc_find_env>
  800dcf:	a3 04 40 80 00       	mov    %eax,0x804004
  800dd4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dd7:	6a 07                	push   $0x7
  800dd9:	68 00 60 80 00       	push   $0x806000
  800dde:	53                   	push   %ebx
  800ddf:	ff 35 04 40 80 00    	pushl  0x804004
  800de5:	e8 51 11 00 00       	call   801f3b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dea:	83 c4 0c             	add    $0xc,%esp
  800ded:	6a 00                	push   $0x0
  800def:	6a 00                	push   $0x0
  800df1:	6a 00                	push   $0x0
  800df3:	e8 dc 10 00 00       	call   801ed4 <ipc_recv>
}
  800df8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dfb:	c9                   	leave  
  800dfc:	c3                   	ret    

00800dfd <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e0d:	8b 06                	mov    (%esi),%eax
  800e0f:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e14:	b8 01 00 00 00       	mov    $0x1,%eax
  800e19:	e8 95 ff ff ff       	call   800db3 <nsipc>
  800e1e:	89 c3                	mov    %eax,%ebx
  800e20:	85 c0                	test   %eax,%eax
  800e22:	78 20                	js     800e44 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e24:	83 ec 04             	sub    $0x4,%esp
  800e27:	ff 35 10 60 80 00    	pushl  0x806010
  800e2d:	68 00 60 80 00       	push   $0x806000
  800e32:	ff 75 0c             	pushl  0xc(%ebp)
  800e35:	e8 9e 0e 00 00       	call   801cd8 <memmove>
		*addrlen = ret->ret_addrlen;
  800e3a:	a1 10 60 80 00       	mov    0x806010,%eax
  800e3f:	89 06                	mov    %eax,(%esi)
  800e41:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e44:	89 d8                	mov    %ebx,%eax
  800e46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	53                   	push   %ebx
  800e51:	83 ec 08             	sub    $0x8,%esp
  800e54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e57:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e5f:	53                   	push   %ebx
  800e60:	ff 75 0c             	pushl  0xc(%ebp)
  800e63:	68 04 60 80 00       	push   $0x806004
  800e68:	e8 6b 0e 00 00       	call   801cd8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e6d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e73:	b8 02 00 00 00       	mov    $0x2,%eax
  800e78:	e8 36 ff ff ff       	call   800db3 <nsipc>
}
  800e7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e80:	c9                   	leave  
  800e81:	c3                   	ret    

00800e82 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e93:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e98:	b8 03 00 00 00       	mov    $0x3,%eax
  800e9d:	e8 11 ff ff ff       	call   800db3 <nsipc>
}
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800ead:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eb2:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb7:	e8 f7 fe ff ff       	call   800db3 <nsipc>
}
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	53                   	push   %ebx
  800ec2:	83 ec 08             	sub    $0x8,%esp
  800ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ed0:	53                   	push   %ebx
  800ed1:	ff 75 0c             	pushl  0xc(%ebp)
  800ed4:	68 04 60 80 00       	push   $0x806004
  800ed9:	e8 fa 0d 00 00       	call   801cd8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ede:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ee4:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee9:	e8 c5 fe ff ff       	call   800db3 <nsipc>
}
  800eee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  800efc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f04:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f09:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0e:	e8 a0 fe ff ff       	call   800db3 <nsipc>
}
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    

00800f15 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
  800f1a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f20:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f25:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2e:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f33:	b8 07 00 00 00       	mov    $0x7,%eax
  800f38:	e8 76 fe ff ff       	call   800db3 <nsipc>
  800f3d:	89 c3                	mov    %eax,%ebx
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 35                	js     800f78 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f43:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f48:	7f 04                	jg     800f4e <nsipc_recv+0x39>
  800f4a:	39 c6                	cmp    %eax,%esi
  800f4c:	7d 16                	jge    800f64 <nsipc_recv+0x4f>
  800f4e:	68 a7 23 80 00       	push   $0x8023a7
  800f53:	68 6f 23 80 00       	push   $0x80236f
  800f58:	6a 62                	push   $0x62
  800f5a:	68 bc 23 80 00       	push   $0x8023bc
  800f5f:	e8 84 05 00 00       	call   8014e8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	50                   	push   %eax
  800f68:	68 00 60 80 00       	push   $0x806000
  800f6d:	ff 75 0c             	pushl  0xc(%ebp)
  800f70:	e8 63 0d 00 00       	call   801cd8 <memmove>
  800f75:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f78:	89 d8                	mov    %ebx,%eax
  800f7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    

00800f81 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	53                   	push   %ebx
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8e:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f93:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f99:	7e 16                	jle    800fb1 <nsipc_send+0x30>
  800f9b:	68 c8 23 80 00       	push   $0x8023c8
  800fa0:	68 6f 23 80 00       	push   $0x80236f
  800fa5:	6a 6d                	push   $0x6d
  800fa7:	68 bc 23 80 00       	push   $0x8023bc
  800fac:	e8 37 05 00 00       	call   8014e8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fb1:	83 ec 04             	sub    $0x4,%esp
  800fb4:	53                   	push   %ebx
  800fb5:	ff 75 0c             	pushl  0xc(%ebp)
  800fb8:	68 0c 60 80 00       	push   $0x80600c
  800fbd:	e8 16 0d 00 00       	call   801cd8 <memmove>
	nsipcbuf.send.req_size = size;
  800fc2:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fc8:	8b 45 14             	mov    0x14(%ebp),%eax
  800fcb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd5:	e8 d9 fd ff ff       	call   800db3 <nsipc>
}
  800fda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    

00800fdf <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff0:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ff5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800ffd:	b8 09 00 00 00       	mov    $0x9,%eax
  801002:	e8 ac fd ff ff       	call   800db3 <nsipc>
}
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	56                   	push   %esi
  80100d:	53                   	push   %ebx
  80100e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801011:	83 ec 0c             	sub    $0xc,%esp
  801014:	ff 75 08             	pushl  0x8(%ebp)
  801017:	e8 98 f3 ff ff       	call   8003b4 <fd2data>
  80101c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80101e:	83 c4 08             	add    $0x8,%esp
  801021:	68 d4 23 80 00       	push   $0x8023d4
  801026:	53                   	push   %ebx
  801027:	e8 1a 0b 00 00       	call   801b46 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80102c:	8b 46 04             	mov    0x4(%esi),%eax
  80102f:	2b 06                	sub    (%esi),%eax
  801031:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801037:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80103e:	00 00 00 
	stat->st_dev = &devpipe;
  801041:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801048:	30 80 00 
	return 0;
}
  80104b:	b8 00 00 00 00       	mov    $0x0,%eax
  801050:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	53                   	push   %ebx
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801061:	53                   	push   %ebx
  801062:	6a 00                	push   $0x0
  801064:	e8 8c f1 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801069:	89 1c 24             	mov    %ebx,(%esp)
  80106c:	e8 43 f3 ff ff       	call   8003b4 <fd2data>
  801071:	83 c4 08             	add    $0x8,%esp
  801074:	50                   	push   %eax
  801075:	6a 00                	push   $0x0
  801077:	e8 79 f1 ff ff       	call   8001f5 <sys_page_unmap>
}
  80107c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107f:	c9                   	leave  
  801080:	c3                   	ret    

00801081 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	57                   	push   %edi
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
  801087:	83 ec 1c             	sub    $0x1c,%esp
  80108a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80108d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80108f:	a1 08 40 80 00       	mov    0x804008,%eax
  801094:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	ff 75 e0             	pushl  -0x20(%ebp)
  80109d:	e8 26 0f 00 00       	call   801fc8 <pageref>
  8010a2:	89 c3                	mov    %eax,%ebx
  8010a4:	89 3c 24             	mov    %edi,(%esp)
  8010a7:	e8 1c 0f 00 00       	call   801fc8 <pageref>
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	39 c3                	cmp    %eax,%ebx
  8010b1:	0f 94 c1             	sete   %cl
  8010b4:	0f b6 c9             	movzbl %cl,%ecx
  8010b7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010ba:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010c0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010c3:	39 ce                	cmp    %ecx,%esi
  8010c5:	74 1b                	je     8010e2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010c7:	39 c3                	cmp    %eax,%ebx
  8010c9:	75 c4                	jne    80108f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010cb:	8b 42 58             	mov    0x58(%edx),%eax
  8010ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d1:	50                   	push   %eax
  8010d2:	56                   	push   %esi
  8010d3:	68 db 23 80 00       	push   $0x8023db
  8010d8:	e8 e4 04 00 00       	call   8015c1 <cprintf>
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	eb ad                	jmp    80108f <_pipeisclosed+0xe>
	}
}
  8010e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5f                   	pop    %edi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	57                   	push   %edi
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 28             	sub    $0x28,%esp
  8010f6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010f9:	56                   	push   %esi
  8010fa:	e8 b5 f2 ff ff       	call   8003b4 <fd2data>
  8010ff:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	bf 00 00 00 00       	mov    $0x0,%edi
  801109:	eb 4b                	jmp    801156 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80110b:	89 da                	mov    %ebx,%edx
  80110d:	89 f0                	mov    %esi,%eax
  80110f:	e8 6d ff ff ff       	call   801081 <_pipeisclosed>
  801114:	85 c0                	test   %eax,%eax
  801116:	75 48                	jne    801160 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801118:	e8 34 f0 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80111d:	8b 43 04             	mov    0x4(%ebx),%eax
  801120:	8b 0b                	mov    (%ebx),%ecx
  801122:	8d 51 20             	lea    0x20(%ecx),%edx
  801125:	39 d0                	cmp    %edx,%eax
  801127:	73 e2                	jae    80110b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801129:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801130:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801133:	89 c2                	mov    %eax,%edx
  801135:	c1 fa 1f             	sar    $0x1f,%edx
  801138:	89 d1                	mov    %edx,%ecx
  80113a:	c1 e9 1b             	shr    $0x1b,%ecx
  80113d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801140:	83 e2 1f             	and    $0x1f,%edx
  801143:	29 ca                	sub    %ecx,%edx
  801145:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801149:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80114d:	83 c0 01             	add    $0x1,%eax
  801150:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801153:	83 c7 01             	add    $0x1,%edi
  801156:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801159:	75 c2                	jne    80111d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80115b:	8b 45 10             	mov    0x10(%ebp),%eax
  80115e:	eb 05                	jmp    801165 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801160:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801165:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801168:	5b                   	pop    %ebx
  801169:	5e                   	pop    %esi
  80116a:	5f                   	pop    %edi
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	57                   	push   %edi
  801171:	56                   	push   %esi
  801172:	53                   	push   %ebx
  801173:	83 ec 18             	sub    $0x18,%esp
  801176:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801179:	57                   	push   %edi
  80117a:	e8 35 f2 ff ff       	call   8003b4 <fd2data>
  80117f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	bb 00 00 00 00       	mov    $0x0,%ebx
  801189:	eb 3d                	jmp    8011c8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80118b:	85 db                	test   %ebx,%ebx
  80118d:	74 04                	je     801193 <devpipe_read+0x26>
				return i;
  80118f:	89 d8                	mov    %ebx,%eax
  801191:	eb 44                	jmp    8011d7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801193:	89 f2                	mov    %esi,%edx
  801195:	89 f8                	mov    %edi,%eax
  801197:	e8 e5 fe ff ff       	call   801081 <_pipeisclosed>
  80119c:	85 c0                	test   %eax,%eax
  80119e:	75 32                	jne    8011d2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011a0:	e8 ac ef ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011a5:	8b 06                	mov    (%esi),%eax
  8011a7:	3b 46 04             	cmp    0x4(%esi),%eax
  8011aa:	74 df                	je     80118b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011ac:	99                   	cltd   
  8011ad:	c1 ea 1b             	shr    $0x1b,%edx
  8011b0:	01 d0                	add    %edx,%eax
  8011b2:	83 e0 1f             	and    $0x1f,%eax
  8011b5:	29 d0                	sub    %edx,%eax
  8011b7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bf:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011c2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c5:	83 c3 01             	add    $0x1,%ebx
  8011c8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011cb:	75 d8                	jne    8011a5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d0:	eb 05                	jmp    8011d7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011d2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011da:	5b                   	pop    %ebx
  8011db:	5e                   	pop    %esi
  8011dc:	5f                   	pop    %edi
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	56                   	push   %esi
  8011e3:	53                   	push   %ebx
  8011e4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ea:	50                   	push   %eax
  8011eb:	e8 db f1 ff ff       	call   8003cb <fd_alloc>
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	89 c2                	mov    %eax,%edx
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	0f 88 2c 01 00 00    	js     801329 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011fd:	83 ec 04             	sub    $0x4,%esp
  801200:	68 07 04 00 00       	push   $0x407
  801205:	ff 75 f4             	pushl  -0xc(%ebp)
  801208:	6a 00                	push   $0x0
  80120a:	e8 61 ef ff ff       	call   800170 <sys_page_alloc>
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	89 c2                	mov    %eax,%edx
  801214:	85 c0                	test   %eax,%eax
  801216:	0f 88 0d 01 00 00    	js     801329 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80121c:	83 ec 0c             	sub    $0xc,%esp
  80121f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801222:	50                   	push   %eax
  801223:	e8 a3 f1 ff ff       	call   8003cb <fd_alloc>
  801228:	89 c3                	mov    %eax,%ebx
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	0f 88 e2 00 00 00    	js     801317 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801235:	83 ec 04             	sub    $0x4,%esp
  801238:	68 07 04 00 00       	push   $0x407
  80123d:	ff 75 f0             	pushl  -0x10(%ebp)
  801240:	6a 00                	push   $0x0
  801242:	e8 29 ef ff ff       	call   800170 <sys_page_alloc>
  801247:	89 c3                	mov    %eax,%ebx
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	0f 88 c3 00 00 00    	js     801317 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801254:	83 ec 0c             	sub    $0xc,%esp
  801257:	ff 75 f4             	pushl  -0xc(%ebp)
  80125a:	e8 55 f1 ff ff       	call   8003b4 <fd2data>
  80125f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801261:	83 c4 0c             	add    $0xc,%esp
  801264:	68 07 04 00 00       	push   $0x407
  801269:	50                   	push   %eax
  80126a:	6a 00                	push   $0x0
  80126c:	e8 ff ee ff ff       	call   800170 <sys_page_alloc>
  801271:	89 c3                	mov    %eax,%ebx
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	85 c0                	test   %eax,%eax
  801278:	0f 88 89 00 00 00    	js     801307 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127e:	83 ec 0c             	sub    $0xc,%esp
  801281:	ff 75 f0             	pushl  -0x10(%ebp)
  801284:	e8 2b f1 ff ff       	call   8003b4 <fd2data>
  801289:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801290:	50                   	push   %eax
  801291:	6a 00                	push   $0x0
  801293:	56                   	push   %esi
  801294:	6a 00                	push   $0x0
  801296:	e8 18 ef ff ff       	call   8001b3 <sys_page_map>
  80129b:	89 c3                	mov    %eax,%ebx
  80129d:	83 c4 20             	add    $0x20,%esp
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	78 55                	js     8012f9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012a4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ad:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012b9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012ce:	83 ec 0c             	sub    $0xc,%esp
  8012d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d4:	e8 cb f0 ff ff       	call   8003a4 <fd2num>
  8012d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012dc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012de:	83 c4 04             	add    $0x4,%esp
  8012e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e4:	e8 bb f0 ff ff       	call   8003a4 <fd2num>
  8012e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ec:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f7:	eb 30                	jmp    801329 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	56                   	push   %esi
  8012fd:	6a 00                	push   $0x0
  8012ff:	e8 f1 ee ff ff       	call   8001f5 <sys_page_unmap>
  801304:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801307:	83 ec 08             	sub    $0x8,%esp
  80130a:	ff 75 f0             	pushl  -0x10(%ebp)
  80130d:	6a 00                	push   $0x0
  80130f:	e8 e1 ee ff ff       	call   8001f5 <sys_page_unmap>
  801314:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801317:	83 ec 08             	sub    $0x8,%esp
  80131a:	ff 75 f4             	pushl  -0xc(%ebp)
  80131d:	6a 00                	push   $0x0
  80131f:	e8 d1 ee ff ff       	call   8001f5 <sys_page_unmap>
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801329:	89 d0                	mov    %edx,%eax
  80132b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132e:	5b                   	pop    %ebx
  80132f:	5e                   	pop    %esi
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    

00801332 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801338:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	ff 75 08             	pushl  0x8(%ebp)
  80133f:	e8 d6 f0 ff ff       	call   80041a <fd_lookup>
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 18                	js     801363 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80134b:	83 ec 0c             	sub    $0xc,%esp
  80134e:	ff 75 f4             	pushl  -0xc(%ebp)
  801351:	e8 5e f0 ff ff       	call   8003b4 <fd2data>
	return _pipeisclosed(fd, p);
  801356:	89 c2                	mov    %eax,%edx
  801358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135b:	e8 21 fd ff ff       	call   801081 <_pipeisclosed>
  801360:	83 c4 10             	add    $0x10,%esp
}
  801363:	c9                   	leave  
  801364:	c3                   	ret    

00801365 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801368:	b8 00 00 00 00       	mov    $0x0,%eax
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    

0080136f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801375:	68 f3 23 80 00       	push   $0x8023f3
  80137a:	ff 75 0c             	pushl  0xc(%ebp)
  80137d:	e8 c4 07 00 00       	call   801b46 <strcpy>
	return 0;
}
  801382:	b8 00 00 00 00       	mov    $0x0,%eax
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	57                   	push   %edi
  80138d:	56                   	push   %esi
  80138e:	53                   	push   %ebx
  80138f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801395:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80139a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a0:	eb 2d                	jmp    8013cf <devcons_write+0x46>
		m = n - tot;
  8013a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013a7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013aa:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013af:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013b2:	83 ec 04             	sub    $0x4,%esp
  8013b5:	53                   	push   %ebx
  8013b6:	03 45 0c             	add    0xc(%ebp),%eax
  8013b9:	50                   	push   %eax
  8013ba:	57                   	push   %edi
  8013bb:	e8 18 09 00 00       	call   801cd8 <memmove>
		sys_cputs(buf, m);
  8013c0:	83 c4 08             	add    $0x8,%esp
  8013c3:	53                   	push   %ebx
  8013c4:	57                   	push   %edi
  8013c5:	e8 ea ec ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013ca:	01 de                	add    %ebx,%esi
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	89 f0                	mov    %esi,%eax
  8013d1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013d4:	72 cc                	jb     8013a2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013ed:	74 2a                	je     801419 <devcons_read+0x3b>
  8013ef:	eb 05                	jmp    8013f6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013f1:	e8 5b ed ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013f6:	e8 d7 ec ff ff       	call   8000d2 <sys_cgetc>
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	74 f2                	je     8013f1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 16                	js     801419 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801403:	83 f8 04             	cmp    $0x4,%eax
  801406:	74 0c                	je     801414 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801408:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140b:	88 02                	mov    %al,(%edx)
	return 1;
  80140d:	b8 01 00 00 00       	mov    $0x1,%eax
  801412:	eb 05                	jmp    801419 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801414:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801419:	c9                   	leave  
  80141a:	c3                   	ret    

0080141b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
  801424:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801427:	6a 01                	push   $0x1
  801429:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80142c:	50                   	push   %eax
  80142d:	e8 82 ec ff ff       	call   8000b4 <sys_cputs>
}
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	c9                   	leave  
  801436:	c3                   	ret    

00801437 <getchar>:

int
getchar(void)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80143d:	6a 01                	push   $0x1
  80143f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801442:	50                   	push   %eax
  801443:	6a 00                	push   $0x0
  801445:	e8 36 f2 ff ff       	call   800680 <read>
	if (r < 0)
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	85 c0                	test   %eax,%eax
  80144f:	78 0f                	js     801460 <getchar+0x29>
		return r;
	if (r < 1)
  801451:	85 c0                	test   %eax,%eax
  801453:	7e 06                	jle    80145b <getchar+0x24>
		return -E_EOF;
	return c;
  801455:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801459:	eb 05                	jmp    801460 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80145b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801460:	c9                   	leave  
  801461:	c3                   	ret    

00801462 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801468:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146b:	50                   	push   %eax
  80146c:	ff 75 08             	pushl  0x8(%ebp)
  80146f:	e8 a6 ef ff ff       	call   80041a <fd_lookup>
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	85 c0                	test   %eax,%eax
  801479:	78 11                	js     80148c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80147b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801484:	39 10                	cmp    %edx,(%eax)
  801486:	0f 94 c0             	sete   %al
  801489:	0f b6 c0             	movzbl %al,%eax
}
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <opencons>:

int
opencons(void)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801494:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	e8 2e ef ff ff       	call   8003cb <fd_alloc>
  80149d:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 3e                	js     8014e4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a6:	83 ec 04             	sub    $0x4,%esp
  8014a9:	68 07 04 00 00       	push   $0x407
  8014ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b1:	6a 00                	push   $0x0
  8014b3:	e8 b8 ec ff ff       	call   800170 <sys_page_alloc>
  8014b8:	83 c4 10             	add    $0x10,%esp
		return r;
  8014bb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 23                	js     8014e4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014c1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	50                   	push   %eax
  8014da:	e8 c5 ee ff ff       	call   8003a4 <fd2num>
  8014df:	89 c2                	mov    %eax,%edx
  8014e1:	83 c4 10             	add    $0x10,%esp
}
  8014e4:	89 d0                	mov    %edx,%eax
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	56                   	push   %esi
  8014ec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014ed:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014f0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014f6:	e8 37 ec ff ff       	call   800132 <sys_getenvid>
  8014fb:	83 ec 0c             	sub    $0xc,%esp
  8014fe:	ff 75 0c             	pushl  0xc(%ebp)
  801501:	ff 75 08             	pushl  0x8(%ebp)
  801504:	56                   	push   %esi
  801505:	50                   	push   %eax
  801506:	68 00 24 80 00       	push   $0x802400
  80150b:	e8 b1 00 00 00       	call   8015c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801510:	83 c4 18             	add    $0x18,%esp
  801513:	53                   	push   %ebx
  801514:	ff 75 10             	pushl  0x10(%ebp)
  801517:	e8 54 00 00 00       	call   801570 <vcprintf>
	cprintf("\n");
  80151c:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  801523:	e8 99 00 00 00       	call   8015c1 <cprintf>
  801528:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80152b:	cc                   	int3   
  80152c:	eb fd                	jmp    80152b <_panic+0x43>

0080152e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	53                   	push   %ebx
  801532:	83 ec 04             	sub    $0x4,%esp
  801535:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801538:	8b 13                	mov    (%ebx),%edx
  80153a:	8d 42 01             	lea    0x1(%edx),%eax
  80153d:	89 03                	mov    %eax,(%ebx)
  80153f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801542:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801546:	3d ff 00 00 00       	cmp    $0xff,%eax
  80154b:	75 1a                	jne    801567 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80154d:	83 ec 08             	sub    $0x8,%esp
  801550:	68 ff 00 00 00       	push   $0xff
  801555:	8d 43 08             	lea    0x8(%ebx),%eax
  801558:	50                   	push   %eax
  801559:	e8 56 eb ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  80155e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801564:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801567:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80156b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156e:	c9                   	leave  
  80156f:	c3                   	ret    

00801570 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801579:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801580:	00 00 00 
	b.cnt = 0;
  801583:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80158a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80158d:	ff 75 0c             	pushl  0xc(%ebp)
  801590:	ff 75 08             	pushl  0x8(%ebp)
  801593:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	68 2e 15 80 00       	push   $0x80152e
  80159f:	e8 54 01 00 00       	call   8016f8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015a4:	83 c4 08             	add    $0x8,%esp
  8015a7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	e8 fb ea ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  8015b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015c7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015ca:	50                   	push   %eax
  8015cb:	ff 75 08             	pushl  0x8(%ebp)
  8015ce:	e8 9d ff ff ff       	call   801570 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015d3:	c9                   	leave  
  8015d4:	c3                   	ret    

008015d5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	57                   	push   %edi
  8015d9:	56                   	push   %esi
  8015da:	53                   	push   %ebx
  8015db:	83 ec 1c             	sub    $0x1c,%esp
  8015de:	89 c7                	mov    %eax,%edi
  8015e0:	89 d6                	mov    %edx,%esi
  8015e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015f9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015fc:	39 d3                	cmp    %edx,%ebx
  8015fe:	72 05                	jb     801605 <printnum+0x30>
  801600:	39 45 10             	cmp    %eax,0x10(%ebp)
  801603:	77 45                	ja     80164a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801605:	83 ec 0c             	sub    $0xc,%esp
  801608:	ff 75 18             	pushl  0x18(%ebp)
  80160b:	8b 45 14             	mov    0x14(%ebp),%eax
  80160e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801611:	53                   	push   %ebx
  801612:	ff 75 10             	pushl  0x10(%ebp)
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161b:	ff 75 e0             	pushl  -0x20(%ebp)
  80161e:	ff 75 dc             	pushl  -0x24(%ebp)
  801621:	ff 75 d8             	pushl  -0x28(%ebp)
  801624:	e8 e7 09 00 00       	call   802010 <__udivdi3>
  801629:	83 c4 18             	add    $0x18,%esp
  80162c:	52                   	push   %edx
  80162d:	50                   	push   %eax
  80162e:	89 f2                	mov    %esi,%edx
  801630:	89 f8                	mov    %edi,%eax
  801632:	e8 9e ff ff ff       	call   8015d5 <printnum>
  801637:	83 c4 20             	add    $0x20,%esp
  80163a:	eb 18                	jmp    801654 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80163c:	83 ec 08             	sub    $0x8,%esp
  80163f:	56                   	push   %esi
  801640:	ff 75 18             	pushl  0x18(%ebp)
  801643:	ff d7                	call   *%edi
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	eb 03                	jmp    80164d <printnum+0x78>
  80164a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80164d:	83 eb 01             	sub    $0x1,%ebx
  801650:	85 db                	test   %ebx,%ebx
  801652:	7f e8                	jg     80163c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801654:	83 ec 08             	sub    $0x8,%esp
  801657:	56                   	push   %esi
  801658:	83 ec 04             	sub    $0x4,%esp
  80165b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165e:	ff 75 e0             	pushl  -0x20(%ebp)
  801661:	ff 75 dc             	pushl  -0x24(%ebp)
  801664:	ff 75 d8             	pushl  -0x28(%ebp)
  801667:	e8 d4 0a 00 00       	call   802140 <__umoddi3>
  80166c:	83 c4 14             	add    $0x14,%esp
  80166f:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
  801676:	50                   	push   %eax
  801677:	ff d7                	call   *%edi
}
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167f:	5b                   	pop    %ebx
  801680:	5e                   	pop    %esi
  801681:	5f                   	pop    %edi
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    

00801684 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801687:	83 fa 01             	cmp    $0x1,%edx
  80168a:	7e 0e                	jle    80169a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80168c:	8b 10                	mov    (%eax),%edx
  80168e:	8d 4a 08             	lea    0x8(%edx),%ecx
  801691:	89 08                	mov    %ecx,(%eax)
  801693:	8b 02                	mov    (%edx),%eax
  801695:	8b 52 04             	mov    0x4(%edx),%edx
  801698:	eb 22                	jmp    8016bc <getuint+0x38>
	else if (lflag)
  80169a:	85 d2                	test   %edx,%edx
  80169c:	74 10                	je     8016ae <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80169e:	8b 10                	mov    (%eax),%edx
  8016a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016a3:	89 08                	mov    %ecx,(%eax)
  8016a5:	8b 02                	mov    (%edx),%eax
  8016a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ac:	eb 0e                	jmp    8016bc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016ae:	8b 10                	mov    (%eax),%edx
  8016b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b3:	89 08                	mov    %ecx,(%eax)
  8016b5:	8b 02                	mov    (%edx),%eax
  8016b7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016c4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016c8:	8b 10                	mov    (%eax),%edx
  8016ca:	3b 50 04             	cmp    0x4(%eax),%edx
  8016cd:	73 0a                	jae    8016d9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016cf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016d2:	89 08                	mov    %ecx,(%eax)
  8016d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d7:	88 02                	mov    %al,(%edx)
}
  8016d9:	5d                   	pop    %ebp
  8016da:	c3                   	ret    

008016db <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016e1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016e4:	50                   	push   %eax
  8016e5:	ff 75 10             	pushl  0x10(%ebp)
  8016e8:	ff 75 0c             	pushl  0xc(%ebp)
  8016eb:	ff 75 08             	pushl  0x8(%ebp)
  8016ee:	e8 05 00 00 00       	call   8016f8 <vprintfmt>
	va_end(ap);
}
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	57                   	push   %edi
  8016fc:	56                   	push   %esi
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 2c             	sub    $0x2c,%esp
  801701:	8b 75 08             	mov    0x8(%ebp),%esi
  801704:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801707:	8b 7d 10             	mov    0x10(%ebp),%edi
  80170a:	eb 12                	jmp    80171e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80170c:	85 c0                	test   %eax,%eax
  80170e:	0f 84 89 03 00 00    	je     801a9d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801714:	83 ec 08             	sub    $0x8,%esp
  801717:	53                   	push   %ebx
  801718:	50                   	push   %eax
  801719:	ff d6                	call   *%esi
  80171b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80171e:	83 c7 01             	add    $0x1,%edi
  801721:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801725:	83 f8 25             	cmp    $0x25,%eax
  801728:	75 e2                	jne    80170c <vprintfmt+0x14>
  80172a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80172e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801735:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80173c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801743:	ba 00 00 00 00       	mov    $0x0,%edx
  801748:	eb 07                	jmp    801751 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80174d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801751:	8d 47 01             	lea    0x1(%edi),%eax
  801754:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801757:	0f b6 07             	movzbl (%edi),%eax
  80175a:	0f b6 c8             	movzbl %al,%ecx
  80175d:	83 e8 23             	sub    $0x23,%eax
  801760:	3c 55                	cmp    $0x55,%al
  801762:	0f 87 1a 03 00 00    	ja     801a82 <vprintfmt+0x38a>
  801768:	0f b6 c0             	movzbl %al,%eax
  80176b:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  801772:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801775:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801779:	eb d6                	jmp    801751 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80177b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80177e:	b8 00 00 00 00       	mov    $0x0,%eax
  801783:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801786:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801789:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80178d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801790:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801793:	83 fa 09             	cmp    $0x9,%edx
  801796:	77 39                	ja     8017d1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801798:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80179b:	eb e9                	jmp    801786 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80179d:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a0:	8d 48 04             	lea    0x4(%eax),%ecx
  8017a3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017a6:	8b 00                	mov    (%eax),%eax
  8017a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017ae:	eb 27                	jmp    8017d7 <vprintfmt+0xdf>
  8017b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017ba:	0f 49 c8             	cmovns %eax,%ecx
  8017bd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c3:	eb 8c                	jmp    801751 <vprintfmt+0x59>
  8017c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017c8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017cf:	eb 80                	jmp    801751 <vprintfmt+0x59>
  8017d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017d4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017db:	0f 89 70 ff ff ff    	jns    801751 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017e7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017ee:	e9 5e ff ff ff       	jmp    801751 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017f3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017f9:	e9 53 ff ff ff       	jmp    801751 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801801:	8d 50 04             	lea    0x4(%eax),%edx
  801804:	89 55 14             	mov    %edx,0x14(%ebp)
  801807:	83 ec 08             	sub    $0x8,%esp
  80180a:	53                   	push   %ebx
  80180b:	ff 30                	pushl  (%eax)
  80180d:	ff d6                	call   *%esi
			break;
  80180f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801812:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801815:	e9 04 ff ff ff       	jmp    80171e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80181a:	8b 45 14             	mov    0x14(%ebp),%eax
  80181d:	8d 50 04             	lea    0x4(%eax),%edx
  801820:	89 55 14             	mov    %edx,0x14(%ebp)
  801823:	8b 00                	mov    (%eax),%eax
  801825:	99                   	cltd   
  801826:	31 d0                	xor    %edx,%eax
  801828:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80182a:	83 f8 0f             	cmp    $0xf,%eax
  80182d:	7f 0b                	jg     80183a <vprintfmt+0x142>
  80182f:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  801836:	85 d2                	test   %edx,%edx
  801838:	75 18                	jne    801852 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80183a:	50                   	push   %eax
  80183b:	68 3b 24 80 00       	push   $0x80243b
  801840:	53                   	push   %ebx
  801841:	56                   	push   %esi
  801842:	e8 94 fe ff ff       	call   8016db <printfmt>
  801847:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80184d:	e9 cc fe ff ff       	jmp    80171e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801852:	52                   	push   %edx
  801853:	68 81 23 80 00       	push   $0x802381
  801858:	53                   	push   %ebx
  801859:	56                   	push   %esi
  80185a:	e8 7c fe ff ff       	call   8016db <printfmt>
  80185f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801862:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801865:	e9 b4 fe ff ff       	jmp    80171e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80186a:	8b 45 14             	mov    0x14(%ebp),%eax
  80186d:	8d 50 04             	lea    0x4(%eax),%edx
  801870:	89 55 14             	mov    %edx,0x14(%ebp)
  801873:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801875:	85 ff                	test   %edi,%edi
  801877:	b8 34 24 80 00       	mov    $0x802434,%eax
  80187c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80187f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801883:	0f 8e 94 00 00 00    	jle    80191d <vprintfmt+0x225>
  801889:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80188d:	0f 84 98 00 00 00    	je     80192b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	ff 75 d0             	pushl  -0x30(%ebp)
  801899:	57                   	push   %edi
  80189a:	e8 86 02 00 00       	call   801b25 <strnlen>
  80189f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018a2:	29 c1                	sub    %eax,%ecx
  8018a4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018a7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018aa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018b4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018b6:	eb 0f                	jmp    8018c7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018b8:	83 ec 08             	sub    $0x8,%esp
  8018bb:	53                   	push   %ebx
  8018bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8018bf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c1:	83 ef 01             	sub    $0x1,%edi
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	85 ff                	test   %edi,%edi
  8018c9:	7f ed                	jg     8018b8 <vprintfmt+0x1c0>
  8018cb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018ce:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018d1:	85 c9                	test   %ecx,%ecx
  8018d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d8:	0f 49 c1             	cmovns %ecx,%eax
  8018db:	29 c1                	sub    %eax,%ecx
  8018dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018e6:	89 cb                	mov    %ecx,%ebx
  8018e8:	eb 4d                	jmp    801937 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018ee:	74 1b                	je     80190b <vprintfmt+0x213>
  8018f0:	0f be c0             	movsbl %al,%eax
  8018f3:	83 e8 20             	sub    $0x20,%eax
  8018f6:	83 f8 5e             	cmp    $0x5e,%eax
  8018f9:	76 10                	jbe    80190b <vprintfmt+0x213>
					putch('?', putdat);
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	ff 75 0c             	pushl  0xc(%ebp)
  801901:	6a 3f                	push   $0x3f
  801903:	ff 55 08             	call   *0x8(%ebp)
  801906:	83 c4 10             	add    $0x10,%esp
  801909:	eb 0d                	jmp    801918 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80190b:	83 ec 08             	sub    $0x8,%esp
  80190e:	ff 75 0c             	pushl  0xc(%ebp)
  801911:	52                   	push   %edx
  801912:	ff 55 08             	call   *0x8(%ebp)
  801915:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801918:	83 eb 01             	sub    $0x1,%ebx
  80191b:	eb 1a                	jmp    801937 <vprintfmt+0x23f>
  80191d:	89 75 08             	mov    %esi,0x8(%ebp)
  801920:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801923:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801926:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801929:	eb 0c                	jmp    801937 <vprintfmt+0x23f>
  80192b:	89 75 08             	mov    %esi,0x8(%ebp)
  80192e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801931:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801934:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801937:	83 c7 01             	add    $0x1,%edi
  80193a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80193e:	0f be d0             	movsbl %al,%edx
  801941:	85 d2                	test   %edx,%edx
  801943:	74 23                	je     801968 <vprintfmt+0x270>
  801945:	85 f6                	test   %esi,%esi
  801947:	78 a1                	js     8018ea <vprintfmt+0x1f2>
  801949:	83 ee 01             	sub    $0x1,%esi
  80194c:	79 9c                	jns    8018ea <vprintfmt+0x1f2>
  80194e:	89 df                	mov    %ebx,%edi
  801950:	8b 75 08             	mov    0x8(%ebp),%esi
  801953:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801956:	eb 18                	jmp    801970 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801958:	83 ec 08             	sub    $0x8,%esp
  80195b:	53                   	push   %ebx
  80195c:	6a 20                	push   $0x20
  80195e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801960:	83 ef 01             	sub    $0x1,%edi
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	eb 08                	jmp    801970 <vprintfmt+0x278>
  801968:	89 df                	mov    %ebx,%edi
  80196a:	8b 75 08             	mov    0x8(%ebp),%esi
  80196d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801970:	85 ff                	test   %edi,%edi
  801972:	7f e4                	jg     801958 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801974:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801977:	e9 a2 fd ff ff       	jmp    80171e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80197c:	83 fa 01             	cmp    $0x1,%edx
  80197f:	7e 16                	jle    801997 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801981:	8b 45 14             	mov    0x14(%ebp),%eax
  801984:	8d 50 08             	lea    0x8(%eax),%edx
  801987:	89 55 14             	mov    %edx,0x14(%ebp)
  80198a:	8b 50 04             	mov    0x4(%eax),%edx
  80198d:	8b 00                	mov    (%eax),%eax
  80198f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801992:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801995:	eb 32                	jmp    8019c9 <vprintfmt+0x2d1>
	else if (lflag)
  801997:	85 d2                	test   %edx,%edx
  801999:	74 18                	je     8019b3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80199b:	8b 45 14             	mov    0x14(%ebp),%eax
  80199e:	8d 50 04             	lea    0x4(%eax),%edx
  8019a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a4:	8b 00                	mov    (%eax),%eax
  8019a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a9:	89 c1                	mov    %eax,%ecx
  8019ab:	c1 f9 1f             	sar    $0x1f,%ecx
  8019ae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019b1:	eb 16                	jmp    8019c9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b6:	8d 50 04             	lea    0x4(%eax),%edx
  8019b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8019bc:	8b 00                	mov    (%eax),%eax
  8019be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c1:	89 c1                	mov    %eax,%ecx
  8019c3:	c1 f9 1f             	sar    $0x1f,%ecx
  8019c6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019cf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019d4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019d8:	79 74                	jns    801a4e <vprintfmt+0x356>
				putch('-', putdat);
  8019da:	83 ec 08             	sub    $0x8,%esp
  8019dd:	53                   	push   %ebx
  8019de:	6a 2d                	push   $0x2d
  8019e0:	ff d6                	call   *%esi
				num = -(long long) num;
  8019e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019e8:	f7 d8                	neg    %eax
  8019ea:	83 d2 00             	adc    $0x0,%edx
  8019ed:	f7 da                	neg    %edx
  8019ef:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019f7:	eb 55                	jmp    801a4e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8019fc:	e8 83 fc ff ff       	call   801684 <getuint>
			base = 10;
  801a01:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a06:	eb 46                	jmp    801a4e <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a08:	8d 45 14             	lea    0x14(%ebp),%eax
  801a0b:	e8 74 fc ff ff       	call   801684 <getuint>
			base = 8;
  801a10:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a15:	eb 37                	jmp    801a4e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a17:	83 ec 08             	sub    $0x8,%esp
  801a1a:	53                   	push   %ebx
  801a1b:	6a 30                	push   $0x30
  801a1d:	ff d6                	call   *%esi
			putch('x', putdat);
  801a1f:	83 c4 08             	add    $0x8,%esp
  801a22:	53                   	push   %ebx
  801a23:	6a 78                	push   $0x78
  801a25:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a27:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2a:	8d 50 04             	lea    0x4(%eax),%edx
  801a2d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a30:	8b 00                	mov    (%eax),%eax
  801a32:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a37:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a3a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a3f:	eb 0d                	jmp    801a4e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a41:	8d 45 14             	lea    0x14(%ebp),%eax
  801a44:	e8 3b fc ff ff       	call   801684 <getuint>
			base = 16;
  801a49:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a55:	57                   	push   %edi
  801a56:	ff 75 e0             	pushl  -0x20(%ebp)
  801a59:	51                   	push   %ecx
  801a5a:	52                   	push   %edx
  801a5b:	50                   	push   %eax
  801a5c:	89 da                	mov    %ebx,%edx
  801a5e:	89 f0                	mov    %esi,%eax
  801a60:	e8 70 fb ff ff       	call   8015d5 <printnum>
			break;
  801a65:	83 c4 20             	add    $0x20,%esp
  801a68:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a6b:	e9 ae fc ff ff       	jmp    80171e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a70:	83 ec 08             	sub    $0x8,%esp
  801a73:	53                   	push   %ebx
  801a74:	51                   	push   %ecx
  801a75:	ff d6                	call   *%esi
			break;
  801a77:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a7d:	e9 9c fc ff ff       	jmp    80171e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a82:	83 ec 08             	sub    $0x8,%esp
  801a85:	53                   	push   %ebx
  801a86:	6a 25                	push   $0x25
  801a88:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	eb 03                	jmp    801a92 <vprintfmt+0x39a>
  801a8f:	83 ef 01             	sub    $0x1,%edi
  801a92:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a96:	75 f7                	jne    801a8f <vprintfmt+0x397>
  801a98:	e9 81 fc ff ff       	jmp    80171e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5f                   	pop    %edi
  801aa3:	5d                   	pop    %ebp
  801aa4:	c3                   	ret    

00801aa5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	83 ec 18             	sub    $0x18,%esp
  801aab:	8b 45 08             	mov    0x8(%ebp),%eax
  801aae:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ab1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ab4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ab8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801abb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	74 26                	je     801aec <vsnprintf+0x47>
  801ac6:	85 d2                	test   %edx,%edx
  801ac8:	7e 22                	jle    801aec <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801aca:	ff 75 14             	pushl  0x14(%ebp)
  801acd:	ff 75 10             	pushl  0x10(%ebp)
  801ad0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ad3:	50                   	push   %eax
  801ad4:	68 be 16 80 00       	push   $0x8016be
  801ad9:	e8 1a fc ff ff       	call   8016f8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ade:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ae1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	eb 05                	jmp    801af1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801aec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    

00801af3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801af9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801afc:	50                   	push   %eax
  801afd:	ff 75 10             	pushl  0x10(%ebp)
  801b00:	ff 75 0c             	pushl  0xc(%ebp)
  801b03:	ff 75 08             	pushl  0x8(%ebp)
  801b06:	e8 9a ff ff ff       	call   801aa5 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b0b:	c9                   	leave  
  801b0c:	c3                   	ret    

00801b0d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b0d:	55                   	push   %ebp
  801b0e:	89 e5                	mov    %esp,%ebp
  801b10:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
  801b18:	eb 03                	jmp    801b1d <strlen+0x10>
		n++;
  801b1a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b1d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b21:	75 f7                	jne    801b1a <strlen+0xd>
		n++;
	return n;
}
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b33:	eb 03                	jmp    801b38 <strnlen+0x13>
		n++;
  801b35:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b38:	39 c2                	cmp    %eax,%edx
  801b3a:	74 08                	je     801b44 <strnlen+0x1f>
  801b3c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b40:	75 f3                	jne    801b35 <strnlen+0x10>
  801b42:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b44:	5d                   	pop    %ebp
  801b45:	c3                   	ret    

00801b46 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	53                   	push   %ebx
  801b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b50:	89 c2                	mov    %eax,%edx
  801b52:	83 c2 01             	add    $0x1,%edx
  801b55:	83 c1 01             	add    $0x1,%ecx
  801b58:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b5c:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b5f:	84 db                	test   %bl,%bl
  801b61:	75 ef                	jne    801b52 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b63:	5b                   	pop    %ebx
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    

00801b66 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	53                   	push   %ebx
  801b6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b6d:	53                   	push   %ebx
  801b6e:	e8 9a ff ff ff       	call   801b0d <strlen>
  801b73:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b76:	ff 75 0c             	pushl  0xc(%ebp)
  801b79:	01 d8                	add    %ebx,%eax
  801b7b:	50                   	push   %eax
  801b7c:	e8 c5 ff ff ff       	call   801b46 <strcpy>
	return dst;
}
  801b81:	89 d8                	mov    %ebx,%eax
  801b83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b86:	c9                   	leave  
  801b87:	c3                   	ret    

00801b88 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	56                   	push   %esi
  801b8c:	53                   	push   %ebx
  801b8d:	8b 75 08             	mov    0x8(%ebp),%esi
  801b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b93:	89 f3                	mov    %esi,%ebx
  801b95:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b98:	89 f2                	mov    %esi,%edx
  801b9a:	eb 0f                	jmp    801bab <strncpy+0x23>
		*dst++ = *src;
  801b9c:	83 c2 01             	add    $0x1,%edx
  801b9f:	0f b6 01             	movzbl (%ecx),%eax
  801ba2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ba5:	80 39 01             	cmpb   $0x1,(%ecx)
  801ba8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bab:	39 da                	cmp    %ebx,%edx
  801bad:	75 ed                	jne    801b9c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801baf:	89 f0                	mov    %esi,%eax
  801bb1:	5b                   	pop    %ebx
  801bb2:	5e                   	pop    %esi
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    

00801bb5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	56                   	push   %esi
  801bb9:	53                   	push   %ebx
  801bba:	8b 75 08             	mov    0x8(%ebp),%esi
  801bbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc0:	8b 55 10             	mov    0x10(%ebp),%edx
  801bc3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bc5:	85 d2                	test   %edx,%edx
  801bc7:	74 21                	je     801bea <strlcpy+0x35>
  801bc9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bcd:	89 f2                	mov    %esi,%edx
  801bcf:	eb 09                	jmp    801bda <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bd1:	83 c2 01             	add    $0x1,%edx
  801bd4:	83 c1 01             	add    $0x1,%ecx
  801bd7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bda:	39 c2                	cmp    %eax,%edx
  801bdc:	74 09                	je     801be7 <strlcpy+0x32>
  801bde:	0f b6 19             	movzbl (%ecx),%ebx
  801be1:	84 db                	test   %bl,%bl
  801be3:	75 ec                	jne    801bd1 <strlcpy+0x1c>
  801be5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801be7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bea:	29 f0                	sub    %esi,%eax
}
  801bec:	5b                   	pop    %ebx
  801bed:	5e                   	pop    %esi
  801bee:	5d                   	pop    %ebp
  801bef:	c3                   	ret    

00801bf0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bf9:	eb 06                	jmp    801c01 <strcmp+0x11>
		p++, q++;
  801bfb:	83 c1 01             	add    $0x1,%ecx
  801bfe:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c01:	0f b6 01             	movzbl (%ecx),%eax
  801c04:	84 c0                	test   %al,%al
  801c06:	74 04                	je     801c0c <strcmp+0x1c>
  801c08:	3a 02                	cmp    (%edx),%al
  801c0a:	74 ef                	je     801bfb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c0c:	0f b6 c0             	movzbl %al,%eax
  801c0f:	0f b6 12             	movzbl (%edx),%edx
  801c12:	29 d0                	sub    %edx,%eax
}
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	53                   	push   %ebx
  801c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c20:	89 c3                	mov    %eax,%ebx
  801c22:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c25:	eb 06                	jmp    801c2d <strncmp+0x17>
		n--, p++, q++;
  801c27:	83 c0 01             	add    $0x1,%eax
  801c2a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c2d:	39 d8                	cmp    %ebx,%eax
  801c2f:	74 15                	je     801c46 <strncmp+0x30>
  801c31:	0f b6 08             	movzbl (%eax),%ecx
  801c34:	84 c9                	test   %cl,%cl
  801c36:	74 04                	je     801c3c <strncmp+0x26>
  801c38:	3a 0a                	cmp    (%edx),%cl
  801c3a:	74 eb                	je     801c27 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c3c:	0f b6 00             	movzbl (%eax),%eax
  801c3f:	0f b6 12             	movzbl (%edx),%edx
  801c42:	29 d0                	sub    %edx,%eax
  801c44:	eb 05                	jmp    801c4b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c46:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c4b:	5b                   	pop    %ebx
  801c4c:	5d                   	pop    %ebp
  801c4d:	c3                   	ret    

00801c4e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	8b 45 08             	mov    0x8(%ebp),%eax
  801c54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c58:	eb 07                	jmp    801c61 <strchr+0x13>
		if (*s == c)
  801c5a:	38 ca                	cmp    %cl,%dl
  801c5c:	74 0f                	je     801c6d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c5e:	83 c0 01             	add    $0x1,%eax
  801c61:	0f b6 10             	movzbl (%eax),%edx
  801c64:	84 d2                	test   %dl,%dl
  801c66:	75 f2                	jne    801c5a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c6d:	5d                   	pop    %ebp
  801c6e:	c3                   	ret    

00801c6f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
  801c75:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c79:	eb 03                	jmp    801c7e <strfind+0xf>
  801c7b:	83 c0 01             	add    $0x1,%eax
  801c7e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c81:	38 ca                	cmp    %cl,%dl
  801c83:	74 04                	je     801c89 <strfind+0x1a>
  801c85:	84 d2                	test   %dl,%dl
  801c87:	75 f2                	jne    801c7b <strfind+0xc>
			break;
	return (char *) s;
}
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    

00801c8b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	57                   	push   %edi
  801c8f:	56                   	push   %esi
  801c90:	53                   	push   %ebx
  801c91:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c94:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c97:	85 c9                	test   %ecx,%ecx
  801c99:	74 36                	je     801cd1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c9b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ca1:	75 28                	jne    801ccb <memset+0x40>
  801ca3:	f6 c1 03             	test   $0x3,%cl
  801ca6:	75 23                	jne    801ccb <memset+0x40>
		c &= 0xFF;
  801ca8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cac:	89 d3                	mov    %edx,%ebx
  801cae:	c1 e3 08             	shl    $0x8,%ebx
  801cb1:	89 d6                	mov    %edx,%esi
  801cb3:	c1 e6 18             	shl    $0x18,%esi
  801cb6:	89 d0                	mov    %edx,%eax
  801cb8:	c1 e0 10             	shl    $0x10,%eax
  801cbb:	09 f0                	or     %esi,%eax
  801cbd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cbf:	89 d8                	mov    %ebx,%eax
  801cc1:	09 d0                	or     %edx,%eax
  801cc3:	c1 e9 02             	shr    $0x2,%ecx
  801cc6:	fc                   	cld    
  801cc7:	f3 ab                	rep stos %eax,%es:(%edi)
  801cc9:	eb 06                	jmp    801cd1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cce:	fc                   	cld    
  801ccf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cd1:	89 f8                	mov    %edi,%eax
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    

00801cd8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	57                   	push   %edi
  801cdc:	56                   	push   %esi
  801cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ce3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ce6:	39 c6                	cmp    %eax,%esi
  801ce8:	73 35                	jae    801d1f <memmove+0x47>
  801cea:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ced:	39 d0                	cmp    %edx,%eax
  801cef:	73 2e                	jae    801d1f <memmove+0x47>
		s += n;
		d += n;
  801cf1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf4:	89 d6                	mov    %edx,%esi
  801cf6:	09 fe                	or     %edi,%esi
  801cf8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cfe:	75 13                	jne    801d13 <memmove+0x3b>
  801d00:	f6 c1 03             	test   $0x3,%cl
  801d03:	75 0e                	jne    801d13 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d05:	83 ef 04             	sub    $0x4,%edi
  801d08:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d0b:	c1 e9 02             	shr    $0x2,%ecx
  801d0e:	fd                   	std    
  801d0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d11:	eb 09                	jmp    801d1c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d13:	83 ef 01             	sub    $0x1,%edi
  801d16:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d19:	fd                   	std    
  801d1a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d1c:	fc                   	cld    
  801d1d:	eb 1d                	jmp    801d3c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d1f:	89 f2                	mov    %esi,%edx
  801d21:	09 c2                	or     %eax,%edx
  801d23:	f6 c2 03             	test   $0x3,%dl
  801d26:	75 0f                	jne    801d37 <memmove+0x5f>
  801d28:	f6 c1 03             	test   $0x3,%cl
  801d2b:	75 0a                	jne    801d37 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d2d:	c1 e9 02             	shr    $0x2,%ecx
  801d30:	89 c7                	mov    %eax,%edi
  801d32:	fc                   	cld    
  801d33:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d35:	eb 05                	jmp    801d3c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d37:	89 c7                	mov    %eax,%edi
  801d39:	fc                   	cld    
  801d3a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d3c:	5e                   	pop    %esi
  801d3d:	5f                   	pop    %edi
  801d3e:	5d                   	pop    %ebp
  801d3f:	c3                   	ret    

00801d40 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d43:	ff 75 10             	pushl  0x10(%ebp)
  801d46:	ff 75 0c             	pushl  0xc(%ebp)
  801d49:	ff 75 08             	pushl  0x8(%ebp)
  801d4c:	e8 87 ff ff ff       	call   801cd8 <memmove>
}
  801d51:	c9                   	leave  
  801d52:	c3                   	ret    

00801d53 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	56                   	push   %esi
  801d57:	53                   	push   %ebx
  801d58:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d5e:	89 c6                	mov    %eax,%esi
  801d60:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d63:	eb 1a                	jmp    801d7f <memcmp+0x2c>
		if (*s1 != *s2)
  801d65:	0f b6 08             	movzbl (%eax),%ecx
  801d68:	0f b6 1a             	movzbl (%edx),%ebx
  801d6b:	38 d9                	cmp    %bl,%cl
  801d6d:	74 0a                	je     801d79 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d6f:	0f b6 c1             	movzbl %cl,%eax
  801d72:	0f b6 db             	movzbl %bl,%ebx
  801d75:	29 d8                	sub    %ebx,%eax
  801d77:	eb 0f                	jmp    801d88 <memcmp+0x35>
		s1++, s2++;
  801d79:	83 c0 01             	add    $0x1,%eax
  801d7c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d7f:	39 f0                	cmp    %esi,%eax
  801d81:	75 e2                	jne    801d65 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d88:	5b                   	pop    %ebx
  801d89:	5e                   	pop    %esi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	53                   	push   %ebx
  801d90:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d93:	89 c1                	mov    %eax,%ecx
  801d95:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d98:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d9c:	eb 0a                	jmp    801da8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d9e:	0f b6 10             	movzbl (%eax),%edx
  801da1:	39 da                	cmp    %ebx,%edx
  801da3:	74 07                	je     801dac <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da5:	83 c0 01             	add    $0x1,%eax
  801da8:	39 c8                	cmp    %ecx,%eax
  801daa:	72 f2                	jb     801d9e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dac:	5b                   	pop    %ebx
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    

00801daf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	57                   	push   %edi
  801db3:	56                   	push   %esi
  801db4:	53                   	push   %ebx
  801db5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dbb:	eb 03                	jmp    801dc0 <strtol+0x11>
		s++;
  801dbd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc0:	0f b6 01             	movzbl (%ecx),%eax
  801dc3:	3c 20                	cmp    $0x20,%al
  801dc5:	74 f6                	je     801dbd <strtol+0xe>
  801dc7:	3c 09                	cmp    $0x9,%al
  801dc9:	74 f2                	je     801dbd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dcb:	3c 2b                	cmp    $0x2b,%al
  801dcd:	75 0a                	jne    801dd9 <strtol+0x2a>
		s++;
  801dcf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dd2:	bf 00 00 00 00       	mov    $0x0,%edi
  801dd7:	eb 11                	jmp    801dea <strtol+0x3b>
  801dd9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801dde:	3c 2d                	cmp    $0x2d,%al
  801de0:	75 08                	jne    801dea <strtol+0x3b>
		s++, neg = 1;
  801de2:	83 c1 01             	add    $0x1,%ecx
  801de5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dea:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801df0:	75 15                	jne    801e07 <strtol+0x58>
  801df2:	80 39 30             	cmpb   $0x30,(%ecx)
  801df5:	75 10                	jne    801e07 <strtol+0x58>
  801df7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801dfb:	75 7c                	jne    801e79 <strtol+0xca>
		s += 2, base = 16;
  801dfd:	83 c1 02             	add    $0x2,%ecx
  801e00:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e05:	eb 16                	jmp    801e1d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e07:	85 db                	test   %ebx,%ebx
  801e09:	75 12                	jne    801e1d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e0b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e10:	80 39 30             	cmpb   $0x30,(%ecx)
  801e13:	75 08                	jne    801e1d <strtol+0x6e>
		s++, base = 8;
  801e15:	83 c1 01             	add    $0x1,%ecx
  801e18:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e22:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e25:	0f b6 11             	movzbl (%ecx),%edx
  801e28:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e2b:	89 f3                	mov    %esi,%ebx
  801e2d:	80 fb 09             	cmp    $0x9,%bl
  801e30:	77 08                	ja     801e3a <strtol+0x8b>
			dig = *s - '0';
  801e32:	0f be d2             	movsbl %dl,%edx
  801e35:	83 ea 30             	sub    $0x30,%edx
  801e38:	eb 22                	jmp    801e5c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e3a:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e3d:	89 f3                	mov    %esi,%ebx
  801e3f:	80 fb 19             	cmp    $0x19,%bl
  801e42:	77 08                	ja     801e4c <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e44:	0f be d2             	movsbl %dl,%edx
  801e47:	83 ea 57             	sub    $0x57,%edx
  801e4a:	eb 10                	jmp    801e5c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e4c:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e4f:	89 f3                	mov    %esi,%ebx
  801e51:	80 fb 19             	cmp    $0x19,%bl
  801e54:	77 16                	ja     801e6c <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e56:	0f be d2             	movsbl %dl,%edx
  801e59:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e5c:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e5f:	7d 0b                	jge    801e6c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e61:	83 c1 01             	add    $0x1,%ecx
  801e64:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e68:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e6a:	eb b9                	jmp    801e25 <strtol+0x76>

	if (endptr)
  801e6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e70:	74 0d                	je     801e7f <strtol+0xd0>
		*endptr = (char *) s;
  801e72:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e75:	89 0e                	mov    %ecx,(%esi)
  801e77:	eb 06                	jmp    801e7f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e79:	85 db                	test   %ebx,%ebx
  801e7b:	74 98                	je     801e15 <strtol+0x66>
  801e7d:	eb 9e                	jmp    801e1d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e7f:	89 c2                	mov    %eax,%edx
  801e81:	f7 da                	neg    %edx
  801e83:	85 ff                	test   %edi,%edi
  801e85:	0f 45 c2             	cmovne %edx,%eax
}
  801e88:	5b                   	pop    %ebx
  801e89:	5e                   	pop    %esi
  801e8a:	5f                   	pop    %edi
  801e8b:	5d                   	pop    %ebp
  801e8c:	c3                   	ret    

00801e8d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e93:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801e9a:	75 2e                	jne    801eca <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801e9c:	e8 91 e2 ff ff       	call   800132 <sys_getenvid>
  801ea1:	83 ec 04             	sub    $0x4,%esp
  801ea4:	68 07 0e 00 00       	push   $0xe07
  801ea9:	68 00 f0 bf ee       	push   $0xeebff000
  801eae:	50                   	push   %eax
  801eaf:	e8 bc e2 ff ff       	call   800170 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801eb4:	e8 79 e2 ff ff       	call   800132 <sys_getenvid>
  801eb9:	83 c4 08             	add    $0x8,%esp
  801ebc:	68 80 03 80 00       	push   $0x800380
  801ec1:	50                   	push   %eax
  801ec2:	e8 f4 e3 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801ec7:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801eca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecd:	a3 00 70 80 00       	mov    %eax,0x807000
}
  801ed2:	c9                   	leave  
  801ed3:	c3                   	ret    

00801ed4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	56                   	push   %esi
  801ed8:	53                   	push   %ebx
  801ed9:	8b 75 08             	mov    0x8(%ebp),%esi
  801edc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801edf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ee2:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ee4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ee9:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801eec:	83 ec 0c             	sub    $0xc,%esp
  801eef:	50                   	push   %eax
  801ef0:	e8 2b e4 ff ff       	call   800320 <sys_ipc_recv>

	if (from_env_store != NULL)
  801ef5:	83 c4 10             	add    $0x10,%esp
  801ef8:	85 f6                	test   %esi,%esi
  801efa:	74 14                	je     801f10 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801efc:	ba 00 00 00 00       	mov    $0x0,%edx
  801f01:	85 c0                	test   %eax,%eax
  801f03:	78 09                	js     801f0e <ipc_recv+0x3a>
  801f05:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f0b:	8b 52 74             	mov    0x74(%edx),%edx
  801f0e:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f10:	85 db                	test   %ebx,%ebx
  801f12:	74 14                	je     801f28 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f14:	ba 00 00 00 00       	mov    $0x0,%edx
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	78 09                	js     801f26 <ipc_recv+0x52>
  801f1d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f23:	8b 52 78             	mov    0x78(%edx),%edx
  801f26:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 08                	js     801f34 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f2c:	a1 08 40 80 00       	mov    0x804008,%eax
  801f31:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f37:	5b                   	pop    %ebx
  801f38:	5e                   	pop    %esi
  801f39:	5d                   	pop    %ebp
  801f3a:	c3                   	ret    

00801f3b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f3b:	55                   	push   %ebp
  801f3c:	89 e5                	mov    %esp,%ebp
  801f3e:	57                   	push   %edi
  801f3f:	56                   	push   %esi
  801f40:	53                   	push   %ebx
  801f41:	83 ec 0c             	sub    $0xc,%esp
  801f44:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f47:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f4d:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f4f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f54:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f57:	ff 75 14             	pushl  0x14(%ebp)
  801f5a:	53                   	push   %ebx
  801f5b:	56                   	push   %esi
  801f5c:	57                   	push   %edi
  801f5d:	e8 9b e3 ff ff       	call   8002fd <sys_ipc_try_send>

		if (err < 0) {
  801f62:	83 c4 10             	add    $0x10,%esp
  801f65:	85 c0                	test   %eax,%eax
  801f67:	79 1e                	jns    801f87 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f69:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f6c:	75 07                	jne    801f75 <ipc_send+0x3a>
				sys_yield();
  801f6e:	e8 de e1 ff ff       	call   800151 <sys_yield>
  801f73:	eb e2                	jmp    801f57 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f75:	50                   	push   %eax
  801f76:	68 20 27 80 00       	push   $0x802720
  801f7b:	6a 49                	push   $0x49
  801f7d:	68 2d 27 80 00       	push   $0x80272d
  801f82:	e8 61 f5 ff ff       	call   8014e8 <_panic>
		}

	} while (err < 0);

}
  801f87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f8a:	5b                   	pop    %ebx
  801f8b:	5e                   	pop    %esi
  801f8c:	5f                   	pop    %edi
  801f8d:	5d                   	pop    %ebp
  801f8e:	c3                   	ret    

00801f8f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f95:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f9a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f9d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fa3:	8b 52 50             	mov    0x50(%edx),%edx
  801fa6:	39 ca                	cmp    %ecx,%edx
  801fa8:	75 0d                	jne    801fb7 <ipc_find_env+0x28>
			return envs[i].env_id;
  801faa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fad:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fb2:	8b 40 48             	mov    0x48(%eax),%eax
  801fb5:	eb 0f                	jmp    801fc6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fb7:	83 c0 01             	add    $0x1,%eax
  801fba:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fbf:	75 d9                	jne    801f9a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    

00801fc8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fce:	89 d0                	mov    %edx,%eax
  801fd0:	c1 e8 16             	shr    $0x16,%eax
  801fd3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fda:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fdf:	f6 c1 01             	test   $0x1,%cl
  801fe2:	74 1d                	je     802001 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fe4:	c1 ea 0c             	shr    $0xc,%edx
  801fe7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fee:	f6 c2 01             	test   $0x1,%dl
  801ff1:	74 0e                	je     802001 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ff3:	c1 ea 0c             	shr    $0xc,%edx
  801ff6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ffd:	ef 
  801ffe:	0f b7 c0             	movzwl %ax,%eax
}
  802001:	5d                   	pop    %ebp
  802002:	c3                   	ret    
  802003:	66 90                	xchg   %ax,%ax
  802005:	66 90                	xchg   %ax,%ax
  802007:	66 90                	xchg   %ax,%ax
  802009:	66 90                	xchg   %ax,%ax
  80200b:	66 90                	xchg   %ax,%ax
  80200d:	66 90                	xchg   %ax,%ax
  80200f:	90                   	nop

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
