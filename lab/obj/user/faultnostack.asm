
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
  800119:	68 2a 1e 80 00       	push   $0x801e2a
  80011e:	6a 23                	push   $0x23
  800120:	68 47 1e 80 00       	push   $0x801e47
  800125:	e8 38 0f 00 00       	call   801062 <_panic>

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
  80019a:	68 2a 1e 80 00       	push   $0x801e2a
  80019f:	6a 23                	push   $0x23
  8001a1:	68 47 1e 80 00       	push   $0x801e47
  8001a6:	e8 b7 0e 00 00       	call   801062 <_panic>

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
  8001dc:	68 2a 1e 80 00       	push   $0x801e2a
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 47 1e 80 00       	push   $0x801e47
  8001e8:	e8 75 0e 00 00       	call   801062 <_panic>

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
  80021e:	68 2a 1e 80 00       	push   $0x801e2a
  800223:	6a 23                	push   $0x23
  800225:	68 47 1e 80 00       	push   $0x801e47
  80022a:	e8 33 0e 00 00       	call   801062 <_panic>

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
  800260:	68 2a 1e 80 00       	push   $0x801e2a
  800265:	6a 23                	push   $0x23
  800267:	68 47 1e 80 00       	push   $0x801e47
  80026c:	e8 f1 0d 00 00       	call   801062 <_panic>

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
  8002a2:	68 2a 1e 80 00       	push   $0x801e2a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 47 1e 80 00       	push   $0x801e47
  8002ae:	e8 af 0d 00 00       	call   801062 <_panic>

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
  8002e4:	68 2a 1e 80 00       	push   $0x801e2a
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 47 1e 80 00       	push   $0x801e47
  8002f0:	e8 6d 0d 00 00       	call   801062 <_panic>

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
  800348:	68 2a 1e 80 00       	push   $0x801e2a
  80034d:	6a 23                	push   $0x23
  80034f:	68 47 1e 80 00       	push   $0x801e47
  800354:	e8 09 0d 00 00       	call   801062 <_panic>

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
  80045a:	ba d4 1e 80 00       	mov    $0x801ed4,%edx
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
  800487:	68 58 1e 80 00       	push   $0x801e58
  80048c:	e8 aa 0c 00 00       	call   80113b <cprintf>
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
  8006b1:	68 99 1e 80 00       	push   $0x801e99
  8006b6:	e8 80 0a 00 00       	call   80113b <cprintf>
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
  800786:	68 b5 1e 80 00       	push   $0x801eb5
  80078b:	e8 ab 09 00 00       	call   80113b <cprintf>
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
  80083b:	68 78 1e 80 00       	push   $0x801e78
  800840:	e8 f6 08 00 00       	call   80113b <cprintf>
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
  800904:	e8 d6 01 00 00       	call   800adf <open>
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
  80094b:	e8 b9 11 00 00       	call   801b09 <ipc_find_env>
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
  800966:	e8 4a 11 00 00       	call   801ab5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80096b:	83 c4 0c             	add    $0xc,%esp
  80096e:	6a 00                	push   $0x0
  800970:	53                   	push   %ebx
  800971:	6a 00                	push   $0x0
  800973:	e8 d6 10 00 00       	call   801a4e <ipc_recv>
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
  8009fc:	e8 bf 0c 00 00       	call   8016c0 <strcpy>
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
  800a2a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a30:	8b 52 0c             	mov    0xc(%edx),%edx
  800a33:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a39:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a3e:	50                   	push   %eax
  800a3f:	ff 75 0c             	pushl  0xc(%ebp)
  800a42:	68 08 50 80 00       	push   $0x805008
  800a47:	e8 06 0e 00 00       	call   801852 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a51:	b8 04 00 00 00       	mov    $0x4,%eax
  800a56:	e8 d9 fe ff ff       	call   800934 <fsipc>

}
  800a5b:	c9                   	leave  
  800a5c:	c3                   	ret    

00800a5d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a70:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a76:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a80:	e8 af fe ff ff       	call   800934 <fsipc>
  800a85:	89 c3                	mov    %eax,%ebx
  800a87:	85 c0                	test   %eax,%eax
  800a89:	78 4b                	js     800ad6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a8b:	39 c6                	cmp    %eax,%esi
  800a8d:	73 16                	jae    800aa5 <devfile_read+0x48>
  800a8f:	68 e4 1e 80 00       	push   $0x801ee4
  800a94:	68 eb 1e 80 00       	push   $0x801eeb
  800a99:	6a 7c                	push   $0x7c
  800a9b:	68 00 1f 80 00       	push   $0x801f00
  800aa0:	e8 bd 05 00 00       	call   801062 <_panic>
	assert(r <= PGSIZE);
  800aa5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aaa:	7e 16                	jle    800ac2 <devfile_read+0x65>
  800aac:	68 0b 1f 80 00       	push   $0x801f0b
  800ab1:	68 eb 1e 80 00       	push   $0x801eeb
  800ab6:	6a 7d                	push   $0x7d
  800ab8:	68 00 1f 80 00       	push   $0x801f00
  800abd:	e8 a0 05 00 00       	call   801062 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ac2:	83 ec 04             	sub    $0x4,%esp
  800ac5:	50                   	push   %eax
  800ac6:	68 00 50 80 00       	push   $0x805000
  800acb:	ff 75 0c             	pushl  0xc(%ebp)
  800ace:	e8 7f 0d 00 00       	call   801852 <memmove>
	return r;
  800ad3:	83 c4 10             	add    $0x10,%esp
}
  800ad6:	89 d8                	mov    %ebx,%eax
  800ad8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	53                   	push   %ebx
  800ae3:	83 ec 20             	sub    $0x20,%esp
  800ae6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ae9:	53                   	push   %ebx
  800aea:	e8 98 0b 00 00       	call   801687 <strlen>
  800aef:	83 c4 10             	add    $0x10,%esp
  800af2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af7:	7f 67                	jg     800b60 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af9:	83 ec 0c             	sub    $0xc,%esp
  800afc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aff:	50                   	push   %eax
  800b00:	e8 a7 f8 ff ff       	call   8003ac <fd_alloc>
  800b05:	83 c4 10             	add    $0x10,%esp
		return r;
  800b08:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0a:	85 c0                	test   %eax,%eax
  800b0c:	78 57                	js     800b65 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b0e:	83 ec 08             	sub    $0x8,%esp
  800b11:	53                   	push   %ebx
  800b12:	68 00 50 80 00       	push   $0x805000
  800b17:	e8 a4 0b 00 00       	call   8016c0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b27:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2c:	e8 03 fe ff ff       	call   800934 <fsipc>
  800b31:	89 c3                	mov    %eax,%ebx
  800b33:	83 c4 10             	add    $0x10,%esp
  800b36:	85 c0                	test   %eax,%eax
  800b38:	79 14                	jns    800b4e <open+0x6f>
		fd_close(fd, 0);
  800b3a:	83 ec 08             	sub    $0x8,%esp
  800b3d:	6a 00                	push   $0x0
  800b3f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b42:	e8 5d f9 ff ff       	call   8004a4 <fd_close>
		return r;
  800b47:	83 c4 10             	add    $0x10,%esp
  800b4a:	89 da                	mov    %ebx,%edx
  800b4c:	eb 17                	jmp    800b65 <open+0x86>
	}

	return fd2num(fd);
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	ff 75 f4             	pushl  -0xc(%ebp)
  800b54:	e8 2c f8 ff ff       	call   800385 <fd2num>
  800b59:	89 c2                	mov    %eax,%edx
  800b5b:	83 c4 10             	add    $0x10,%esp
  800b5e:	eb 05                	jmp    800b65 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b60:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b65:	89 d0                	mov    %edx,%eax
  800b67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 08 00 00 00       	mov    $0x8,%eax
  800b7c:	e8 b3 fd ff ff       	call   800934 <fsipc>
}
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b8b:	83 ec 0c             	sub    $0xc,%esp
  800b8e:	ff 75 08             	pushl  0x8(%ebp)
  800b91:	e8 ff f7 ff ff       	call   800395 <fd2data>
  800b96:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b98:	83 c4 08             	add    $0x8,%esp
  800b9b:	68 17 1f 80 00       	push   $0x801f17
  800ba0:	53                   	push   %ebx
  800ba1:	e8 1a 0b 00 00       	call   8016c0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba6:	8b 46 04             	mov    0x4(%esi),%eax
  800ba9:	2b 06                	sub    (%esi),%eax
  800bab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb8:	00 00 00 
	stat->st_dev = &devpipe;
  800bbb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bc2:	30 80 00 
	return 0;
}
  800bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	53                   	push   %ebx
  800bd5:	83 ec 0c             	sub    $0xc,%esp
  800bd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bdb:	53                   	push   %ebx
  800bdc:	6a 00                	push   $0x0
  800bde:	e8 12 f6 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800be3:	89 1c 24             	mov    %ebx,(%esp)
  800be6:	e8 aa f7 ff ff       	call   800395 <fd2data>
  800beb:	83 c4 08             	add    $0x8,%esp
  800bee:	50                   	push   %eax
  800bef:	6a 00                	push   $0x0
  800bf1:	e8 ff f5 ff ff       	call   8001f5 <sys_page_unmap>
}
  800bf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf9:	c9                   	leave  
  800bfa:	c3                   	ret    

00800bfb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 1c             	sub    $0x1c,%esp
  800c04:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c07:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c09:	a1 04 40 80 00       	mov    0x804004,%eax
  800c0e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c11:	83 ec 0c             	sub    $0xc,%esp
  800c14:	ff 75 e0             	pushl  -0x20(%ebp)
  800c17:	e8 26 0f 00 00       	call   801b42 <pageref>
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	89 3c 24             	mov    %edi,(%esp)
  800c21:	e8 1c 0f 00 00       	call   801b42 <pageref>
  800c26:	83 c4 10             	add    $0x10,%esp
  800c29:	39 c3                	cmp    %eax,%ebx
  800c2b:	0f 94 c1             	sete   %cl
  800c2e:	0f b6 c9             	movzbl %cl,%ecx
  800c31:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c34:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c3a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c3d:	39 ce                	cmp    %ecx,%esi
  800c3f:	74 1b                	je     800c5c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c41:	39 c3                	cmp    %eax,%ebx
  800c43:	75 c4                	jne    800c09 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c45:	8b 42 58             	mov    0x58(%edx),%eax
  800c48:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c4b:	50                   	push   %eax
  800c4c:	56                   	push   %esi
  800c4d:	68 1e 1f 80 00       	push   $0x801f1e
  800c52:	e8 e4 04 00 00       	call   80113b <cprintf>
  800c57:	83 c4 10             	add    $0x10,%esp
  800c5a:	eb ad                	jmp    800c09 <_pipeisclosed+0xe>
	}
}
  800c5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 28             	sub    $0x28,%esp
  800c70:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c73:	56                   	push   %esi
  800c74:	e8 1c f7 ff ff       	call   800395 <fd2data>
  800c79:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c7b:	83 c4 10             	add    $0x10,%esp
  800c7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c83:	eb 4b                	jmp    800cd0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c85:	89 da                	mov    %ebx,%edx
  800c87:	89 f0                	mov    %esi,%eax
  800c89:	e8 6d ff ff ff       	call   800bfb <_pipeisclosed>
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	75 48                	jne    800cda <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c92:	e8 ba f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c97:	8b 43 04             	mov    0x4(%ebx),%eax
  800c9a:	8b 0b                	mov    (%ebx),%ecx
  800c9c:	8d 51 20             	lea    0x20(%ecx),%edx
  800c9f:	39 d0                	cmp    %edx,%eax
  800ca1:	73 e2                	jae    800c85 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800caa:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cad:	89 c2                	mov    %eax,%edx
  800caf:	c1 fa 1f             	sar    $0x1f,%edx
  800cb2:	89 d1                	mov    %edx,%ecx
  800cb4:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cba:	83 e2 1f             	and    $0x1f,%edx
  800cbd:	29 ca                	sub    %ecx,%edx
  800cbf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cc3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc7:	83 c0 01             	add    $0x1,%eax
  800cca:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ccd:	83 c7 01             	add    $0x1,%edi
  800cd0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cd3:	75 c2                	jne    800c97 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cd5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd8:	eb 05                	jmp    800cdf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cda:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 18             	sub    $0x18,%esp
  800cf0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cf3:	57                   	push   %edi
  800cf4:	e8 9c f6 ff ff       	call   800395 <fd2data>
  800cf9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cfb:	83 c4 10             	add    $0x10,%esp
  800cfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d03:	eb 3d                	jmp    800d42 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d05:	85 db                	test   %ebx,%ebx
  800d07:	74 04                	je     800d0d <devpipe_read+0x26>
				return i;
  800d09:	89 d8                	mov    %ebx,%eax
  800d0b:	eb 44                	jmp    800d51 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d0d:	89 f2                	mov    %esi,%edx
  800d0f:	89 f8                	mov    %edi,%eax
  800d11:	e8 e5 fe ff ff       	call   800bfb <_pipeisclosed>
  800d16:	85 c0                	test   %eax,%eax
  800d18:	75 32                	jne    800d4c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d1a:	e8 32 f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d1f:	8b 06                	mov    (%esi),%eax
  800d21:	3b 46 04             	cmp    0x4(%esi),%eax
  800d24:	74 df                	je     800d05 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d26:	99                   	cltd   
  800d27:	c1 ea 1b             	shr    $0x1b,%edx
  800d2a:	01 d0                	add    %edx,%eax
  800d2c:	83 e0 1f             	and    $0x1f,%eax
  800d2f:	29 d0                	sub    %edx,%eax
  800d31:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d3c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d3f:	83 c3 01             	add    $0x1,%ebx
  800d42:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d45:	75 d8                	jne    800d1f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d47:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4a:	eb 05                	jmp    800d51 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d4c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
  800d5e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d64:	50                   	push   %eax
  800d65:	e8 42 f6 ff ff       	call   8003ac <fd_alloc>
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	89 c2                	mov    %eax,%edx
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	0f 88 2c 01 00 00    	js     800ea3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d77:	83 ec 04             	sub    $0x4,%esp
  800d7a:	68 07 04 00 00       	push   $0x407
  800d7f:	ff 75 f4             	pushl  -0xc(%ebp)
  800d82:	6a 00                	push   $0x0
  800d84:	e8 e7 f3 ff ff       	call   800170 <sys_page_alloc>
  800d89:	83 c4 10             	add    $0x10,%esp
  800d8c:	89 c2                	mov    %eax,%edx
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	0f 88 0d 01 00 00    	js     800ea3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d96:	83 ec 0c             	sub    $0xc,%esp
  800d99:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d9c:	50                   	push   %eax
  800d9d:	e8 0a f6 ff ff       	call   8003ac <fd_alloc>
  800da2:	89 c3                	mov    %eax,%ebx
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	0f 88 e2 00 00 00    	js     800e91 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800daf:	83 ec 04             	sub    $0x4,%esp
  800db2:	68 07 04 00 00       	push   $0x407
  800db7:	ff 75 f0             	pushl  -0x10(%ebp)
  800dba:	6a 00                	push   $0x0
  800dbc:	e8 af f3 ff ff       	call   800170 <sys_page_alloc>
  800dc1:	89 c3                	mov    %eax,%ebx
  800dc3:	83 c4 10             	add    $0x10,%esp
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	0f 88 c3 00 00 00    	js     800e91 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd4:	e8 bc f5 ff ff       	call   800395 <fd2data>
  800dd9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddb:	83 c4 0c             	add    $0xc,%esp
  800dde:	68 07 04 00 00       	push   $0x407
  800de3:	50                   	push   %eax
  800de4:	6a 00                	push   $0x0
  800de6:	e8 85 f3 ff ff       	call   800170 <sys_page_alloc>
  800deb:	89 c3                	mov    %eax,%ebx
  800ded:	83 c4 10             	add    $0x10,%esp
  800df0:	85 c0                	test   %eax,%eax
  800df2:	0f 88 89 00 00 00    	js     800e81 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	ff 75 f0             	pushl  -0x10(%ebp)
  800dfe:	e8 92 f5 ff ff       	call   800395 <fd2data>
  800e03:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e0a:	50                   	push   %eax
  800e0b:	6a 00                	push   $0x0
  800e0d:	56                   	push   %esi
  800e0e:	6a 00                	push   $0x0
  800e10:	e8 9e f3 ff ff       	call   8001b3 <sys_page_map>
  800e15:	89 c3                	mov    %eax,%ebx
  800e17:	83 c4 20             	add    $0x20,%esp
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	78 55                	js     800e73 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e1e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e27:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e33:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e41:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e48:	83 ec 0c             	sub    $0xc,%esp
  800e4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4e:	e8 32 f5 ff ff       	call   800385 <fd2num>
  800e53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e56:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e58:	83 c4 04             	add    $0x4,%esp
  800e5b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5e:	e8 22 f5 ff ff       	call   800385 <fd2num>
  800e63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e66:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e69:	83 c4 10             	add    $0x10,%esp
  800e6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e71:	eb 30                	jmp    800ea3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e73:	83 ec 08             	sub    $0x8,%esp
  800e76:	56                   	push   %esi
  800e77:	6a 00                	push   $0x0
  800e79:	e8 77 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e7e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e81:	83 ec 08             	sub    $0x8,%esp
  800e84:	ff 75 f0             	pushl  -0x10(%ebp)
  800e87:	6a 00                	push   $0x0
  800e89:	e8 67 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e8e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e91:	83 ec 08             	sub    $0x8,%esp
  800e94:	ff 75 f4             	pushl  -0xc(%ebp)
  800e97:	6a 00                	push   $0x0
  800e99:	e8 57 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e9e:	83 c4 10             	add    $0x10,%esp
  800ea1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ea3:	89 d0                	mov    %edx,%eax
  800ea5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb5:	50                   	push   %eax
  800eb6:	ff 75 08             	pushl  0x8(%ebp)
  800eb9:	e8 3d f5 ff ff       	call   8003fb <fd_lookup>
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	78 18                	js     800edd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ec5:	83 ec 0c             	sub    $0xc,%esp
  800ec8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ecb:	e8 c5 f4 ff ff       	call   800395 <fd2data>
	return _pipeisclosed(fd, p);
  800ed0:	89 c2                	mov    %eax,%edx
  800ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed5:	e8 21 fd ff ff       	call   800bfb <_pipeisclosed>
  800eda:	83 c4 10             	add    $0x10,%esp
}
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ee2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eef:	68 36 1f 80 00       	push   $0x801f36
  800ef4:	ff 75 0c             	pushl  0xc(%ebp)
  800ef7:	e8 c4 07 00 00       	call   8016c0 <strcpy>
	return 0;
}
  800efc:	b8 00 00 00 00       	mov    $0x0,%eax
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	57                   	push   %edi
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f0f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f14:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f1a:	eb 2d                	jmp    800f49 <devcons_write+0x46>
		m = n - tot;
  800f1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f21:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f24:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f29:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f2c:	83 ec 04             	sub    $0x4,%esp
  800f2f:	53                   	push   %ebx
  800f30:	03 45 0c             	add    0xc(%ebp),%eax
  800f33:	50                   	push   %eax
  800f34:	57                   	push   %edi
  800f35:	e8 18 09 00 00       	call   801852 <memmove>
		sys_cputs(buf, m);
  800f3a:	83 c4 08             	add    $0x8,%esp
  800f3d:	53                   	push   %ebx
  800f3e:	57                   	push   %edi
  800f3f:	e8 70 f1 ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f44:	01 de                	add    %ebx,%esi
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	89 f0                	mov    %esi,%eax
  800f4b:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f4e:	72 cc                	jb     800f1c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f53:	5b                   	pop    %ebx
  800f54:	5e                   	pop    %esi
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 08             	sub    $0x8,%esp
  800f5e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f63:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f67:	74 2a                	je     800f93 <devcons_read+0x3b>
  800f69:	eb 05                	jmp    800f70 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f6b:	e8 e1 f1 ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f70:	e8 5d f1 ff ff       	call   8000d2 <sys_cgetc>
  800f75:	85 c0                	test   %eax,%eax
  800f77:	74 f2                	je     800f6b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	78 16                	js     800f93 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f7d:	83 f8 04             	cmp    $0x4,%eax
  800f80:	74 0c                	je     800f8e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f85:	88 02                	mov    %al,(%edx)
	return 1;
  800f87:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8c:	eb 05                	jmp    800f93 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f8e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    

00800f95 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fa1:	6a 01                	push   $0x1
  800fa3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa6:	50                   	push   %eax
  800fa7:	e8 08 f1 ff ff       	call   8000b4 <sys_cputs>
}
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <getchar>:

int
getchar(void)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fb7:	6a 01                	push   $0x1
  800fb9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbc:	50                   	push   %eax
  800fbd:	6a 00                	push   $0x0
  800fbf:	e8 9d f6 ff ff       	call   800661 <read>
	if (r < 0)
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	78 0f                	js     800fda <getchar+0x29>
		return r;
	if (r < 1)
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	7e 06                	jle    800fd5 <getchar+0x24>
		return -E_EOF;
	return c;
  800fcf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fd3:	eb 05                	jmp    800fda <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fd5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe5:	50                   	push   %eax
  800fe6:	ff 75 08             	pushl  0x8(%ebp)
  800fe9:	e8 0d f4 ff ff       	call   8003fb <fd_lookup>
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 11                	js     801006 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ffe:	39 10                	cmp    %edx,(%eax)
  801000:	0f 94 c0             	sete   %al
  801003:	0f b6 c0             	movzbl %al,%eax
}
  801006:	c9                   	leave  
  801007:	c3                   	ret    

00801008 <opencons>:

int
opencons(void)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80100e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801011:	50                   	push   %eax
  801012:	e8 95 f3 ff ff       	call   8003ac <fd_alloc>
  801017:	83 c4 10             	add    $0x10,%esp
		return r;
  80101a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 3e                	js     80105e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801020:	83 ec 04             	sub    $0x4,%esp
  801023:	68 07 04 00 00       	push   $0x407
  801028:	ff 75 f4             	pushl  -0xc(%ebp)
  80102b:	6a 00                	push   $0x0
  80102d:	e8 3e f1 ff ff       	call   800170 <sys_page_alloc>
  801032:	83 c4 10             	add    $0x10,%esp
		return r;
  801035:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801037:	85 c0                	test   %eax,%eax
  801039:	78 23                	js     80105e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80103b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801041:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801044:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801049:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	50                   	push   %eax
  801054:	e8 2c f3 ff ff       	call   800385 <fd2num>
  801059:	89 c2                	mov    %eax,%edx
  80105b:	83 c4 10             	add    $0x10,%esp
}
  80105e:	89 d0                	mov    %edx,%eax
  801060:	c9                   	leave  
  801061:	c3                   	ret    

00801062 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801067:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80106a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801070:	e8 bd f0 ff ff       	call   800132 <sys_getenvid>
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	ff 75 0c             	pushl  0xc(%ebp)
  80107b:	ff 75 08             	pushl  0x8(%ebp)
  80107e:	56                   	push   %esi
  80107f:	50                   	push   %eax
  801080:	68 44 1f 80 00       	push   $0x801f44
  801085:	e8 b1 00 00 00       	call   80113b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80108a:	83 c4 18             	add    $0x18,%esp
  80108d:	53                   	push   %ebx
  80108e:	ff 75 10             	pushl  0x10(%ebp)
  801091:	e8 54 00 00 00       	call   8010ea <vcprintf>
	cprintf("\n");
  801096:	c7 04 24 2f 1f 80 00 	movl   $0x801f2f,(%esp)
  80109d:	e8 99 00 00 00       	call   80113b <cprintf>
  8010a2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010a5:	cc                   	int3   
  8010a6:	eb fd                	jmp    8010a5 <_panic+0x43>

008010a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	53                   	push   %ebx
  8010ac:	83 ec 04             	sub    $0x4,%esp
  8010af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010b2:	8b 13                	mov    (%ebx),%edx
  8010b4:	8d 42 01             	lea    0x1(%edx),%eax
  8010b7:	89 03                	mov    %eax,(%ebx)
  8010b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010c5:	75 1a                	jne    8010e1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010c7:	83 ec 08             	sub    $0x8,%esp
  8010ca:	68 ff 00 00 00       	push   $0xff
  8010cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8010d2:	50                   	push   %eax
  8010d3:	e8 dc ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8010d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010de:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010e1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e8:	c9                   	leave  
  8010e9:	c3                   	ret    

008010ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010fa:	00 00 00 
	b.cnt = 0;
  8010fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801104:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801107:	ff 75 0c             	pushl  0xc(%ebp)
  80110a:	ff 75 08             	pushl  0x8(%ebp)
  80110d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801113:	50                   	push   %eax
  801114:	68 a8 10 80 00       	push   $0x8010a8
  801119:	e8 54 01 00 00       	call   801272 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80111e:	83 c4 08             	add    $0x8,%esp
  801121:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801127:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80112d:	50                   	push   %eax
  80112e:	e8 81 ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  801133:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801139:	c9                   	leave  
  80113a:	c3                   	ret    

0080113b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801141:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801144:	50                   	push   %eax
  801145:	ff 75 08             	pushl  0x8(%ebp)
  801148:	e8 9d ff ff ff       	call   8010ea <vcprintf>
	va_end(ap);

	return cnt;
}
  80114d:	c9                   	leave  
  80114e:	c3                   	ret    

0080114f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	57                   	push   %edi
  801153:	56                   	push   %esi
  801154:	53                   	push   %ebx
  801155:	83 ec 1c             	sub    $0x1c,%esp
  801158:	89 c7                	mov    %eax,%edi
  80115a:	89 d6                	mov    %edx,%esi
  80115c:	8b 45 08             	mov    0x8(%ebp),%eax
  80115f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801162:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801165:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801168:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80116b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801170:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801173:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801176:	39 d3                	cmp    %edx,%ebx
  801178:	72 05                	jb     80117f <printnum+0x30>
  80117a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80117d:	77 45                	ja     8011c4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80117f:	83 ec 0c             	sub    $0xc,%esp
  801182:	ff 75 18             	pushl  0x18(%ebp)
  801185:	8b 45 14             	mov    0x14(%ebp),%eax
  801188:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80118b:	53                   	push   %ebx
  80118c:	ff 75 10             	pushl  0x10(%ebp)
  80118f:	83 ec 08             	sub    $0x8,%esp
  801192:	ff 75 e4             	pushl  -0x1c(%ebp)
  801195:	ff 75 e0             	pushl  -0x20(%ebp)
  801198:	ff 75 dc             	pushl  -0x24(%ebp)
  80119b:	ff 75 d8             	pushl  -0x28(%ebp)
  80119e:	e8 dd 09 00 00       	call   801b80 <__udivdi3>
  8011a3:	83 c4 18             	add    $0x18,%esp
  8011a6:	52                   	push   %edx
  8011a7:	50                   	push   %eax
  8011a8:	89 f2                	mov    %esi,%edx
  8011aa:	89 f8                	mov    %edi,%eax
  8011ac:	e8 9e ff ff ff       	call   80114f <printnum>
  8011b1:	83 c4 20             	add    $0x20,%esp
  8011b4:	eb 18                	jmp    8011ce <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011b6:	83 ec 08             	sub    $0x8,%esp
  8011b9:	56                   	push   %esi
  8011ba:	ff 75 18             	pushl  0x18(%ebp)
  8011bd:	ff d7                	call   *%edi
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	eb 03                	jmp    8011c7 <printnum+0x78>
  8011c4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011c7:	83 eb 01             	sub    $0x1,%ebx
  8011ca:	85 db                	test   %ebx,%ebx
  8011cc:	7f e8                	jg     8011b6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	56                   	push   %esi
  8011d2:	83 ec 04             	sub    $0x4,%esp
  8011d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011db:	ff 75 dc             	pushl  -0x24(%ebp)
  8011de:	ff 75 d8             	pushl  -0x28(%ebp)
  8011e1:	e8 ca 0a 00 00       	call   801cb0 <__umoddi3>
  8011e6:	83 c4 14             	add    $0x14,%esp
  8011e9:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011f0:	50                   	push   %eax
  8011f1:	ff d7                	call   *%edi
}
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f9:	5b                   	pop    %ebx
  8011fa:	5e                   	pop    %esi
  8011fb:	5f                   	pop    %edi
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801201:	83 fa 01             	cmp    $0x1,%edx
  801204:	7e 0e                	jle    801214 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801206:	8b 10                	mov    (%eax),%edx
  801208:	8d 4a 08             	lea    0x8(%edx),%ecx
  80120b:	89 08                	mov    %ecx,(%eax)
  80120d:	8b 02                	mov    (%edx),%eax
  80120f:	8b 52 04             	mov    0x4(%edx),%edx
  801212:	eb 22                	jmp    801236 <getuint+0x38>
	else if (lflag)
  801214:	85 d2                	test   %edx,%edx
  801216:	74 10                	je     801228 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801218:	8b 10                	mov    (%eax),%edx
  80121a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80121d:	89 08                	mov    %ecx,(%eax)
  80121f:	8b 02                	mov    (%edx),%eax
  801221:	ba 00 00 00 00       	mov    $0x0,%edx
  801226:	eb 0e                	jmp    801236 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801228:	8b 10                	mov    (%eax),%edx
  80122a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80122d:	89 08                	mov    %ecx,(%eax)
  80122f:	8b 02                	mov    (%edx),%eax
  801231:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80123e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801242:	8b 10                	mov    (%eax),%edx
  801244:	3b 50 04             	cmp    0x4(%eax),%edx
  801247:	73 0a                	jae    801253 <sprintputch+0x1b>
		*b->buf++ = ch;
  801249:	8d 4a 01             	lea    0x1(%edx),%ecx
  80124c:	89 08                	mov    %ecx,(%eax)
  80124e:	8b 45 08             	mov    0x8(%ebp),%eax
  801251:	88 02                	mov    %al,(%edx)
}
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    

00801255 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80125b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80125e:	50                   	push   %eax
  80125f:	ff 75 10             	pushl  0x10(%ebp)
  801262:	ff 75 0c             	pushl  0xc(%ebp)
  801265:	ff 75 08             	pushl  0x8(%ebp)
  801268:	e8 05 00 00 00       	call   801272 <vprintfmt>
	va_end(ap);
}
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	c9                   	leave  
  801271:	c3                   	ret    

00801272 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	57                   	push   %edi
  801276:	56                   	push   %esi
  801277:	53                   	push   %ebx
  801278:	83 ec 2c             	sub    $0x2c,%esp
  80127b:	8b 75 08             	mov    0x8(%ebp),%esi
  80127e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801281:	8b 7d 10             	mov    0x10(%ebp),%edi
  801284:	eb 12                	jmp    801298 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801286:	85 c0                	test   %eax,%eax
  801288:	0f 84 89 03 00 00    	je     801617 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80128e:	83 ec 08             	sub    $0x8,%esp
  801291:	53                   	push   %ebx
  801292:	50                   	push   %eax
  801293:	ff d6                	call   *%esi
  801295:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801298:	83 c7 01             	add    $0x1,%edi
  80129b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80129f:	83 f8 25             	cmp    $0x25,%eax
  8012a2:	75 e2                	jne    801286 <vprintfmt+0x14>
  8012a4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012a8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012af:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012b6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c2:	eb 07                	jmp    8012cb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012c7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012cb:	8d 47 01             	lea    0x1(%edi),%eax
  8012ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012d1:	0f b6 07             	movzbl (%edi),%eax
  8012d4:	0f b6 c8             	movzbl %al,%ecx
  8012d7:	83 e8 23             	sub    $0x23,%eax
  8012da:	3c 55                	cmp    $0x55,%al
  8012dc:	0f 87 1a 03 00 00    	ja     8015fc <vprintfmt+0x38a>
  8012e2:	0f b6 c0             	movzbl %al,%eax
  8012e5:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  8012ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012ef:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012f3:	eb d6                	jmp    8012cb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801300:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801303:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801307:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80130a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80130d:	83 fa 09             	cmp    $0x9,%edx
  801310:	77 39                	ja     80134b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801312:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801315:	eb e9                	jmp    801300 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801317:	8b 45 14             	mov    0x14(%ebp),%eax
  80131a:	8d 48 04             	lea    0x4(%eax),%ecx
  80131d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801320:	8b 00                	mov    (%eax),%eax
  801322:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801328:	eb 27                	jmp    801351 <vprintfmt+0xdf>
  80132a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80132d:	85 c0                	test   %eax,%eax
  80132f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801334:	0f 49 c8             	cmovns %eax,%ecx
  801337:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80133d:	eb 8c                	jmp    8012cb <vprintfmt+0x59>
  80133f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801342:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801349:	eb 80                	jmp    8012cb <vprintfmt+0x59>
  80134b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80134e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801351:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801355:	0f 89 70 ff ff ff    	jns    8012cb <vprintfmt+0x59>
				width = precision, precision = -1;
  80135b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80135e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801361:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801368:	e9 5e ff ff ff       	jmp    8012cb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80136d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801373:	e9 53 ff ff ff       	jmp    8012cb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801378:	8b 45 14             	mov    0x14(%ebp),%eax
  80137b:	8d 50 04             	lea    0x4(%eax),%edx
  80137e:	89 55 14             	mov    %edx,0x14(%ebp)
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	53                   	push   %ebx
  801385:	ff 30                	pushl  (%eax)
  801387:	ff d6                	call   *%esi
			break;
  801389:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80138f:	e9 04 ff ff ff       	jmp    801298 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801394:	8b 45 14             	mov    0x14(%ebp),%eax
  801397:	8d 50 04             	lea    0x4(%eax),%edx
  80139a:	89 55 14             	mov    %edx,0x14(%ebp)
  80139d:	8b 00                	mov    (%eax),%eax
  80139f:	99                   	cltd   
  8013a0:	31 d0                	xor    %edx,%eax
  8013a2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013a4:	83 f8 0f             	cmp    $0xf,%eax
  8013a7:	7f 0b                	jg     8013b4 <vprintfmt+0x142>
  8013a9:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  8013b0:	85 d2                	test   %edx,%edx
  8013b2:	75 18                	jne    8013cc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013b4:	50                   	push   %eax
  8013b5:	68 7f 1f 80 00       	push   $0x801f7f
  8013ba:	53                   	push   %ebx
  8013bb:	56                   	push   %esi
  8013bc:	e8 94 fe ff ff       	call   801255 <printfmt>
  8013c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013c7:	e9 cc fe ff ff       	jmp    801298 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013cc:	52                   	push   %edx
  8013cd:	68 fd 1e 80 00       	push   $0x801efd
  8013d2:	53                   	push   %ebx
  8013d3:	56                   	push   %esi
  8013d4:	e8 7c fe ff ff       	call   801255 <printfmt>
  8013d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013df:	e9 b4 fe ff ff       	jmp    801298 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e7:	8d 50 04             	lea    0x4(%eax),%edx
  8013ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ed:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013ef:	85 ff                	test   %edi,%edi
  8013f1:	b8 78 1f 80 00       	mov    $0x801f78,%eax
  8013f6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013fd:	0f 8e 94 00 00 00    	jle    801497 <vprintfmt+0x225>
  801403:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801407:	0f 84 98 00 00 00    	je     8014a5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80140d:	83 ec 08             	sub    $0x8,%esp
  801410:	ff 75 d0             	pushl  -0x30(%ebp)
  801413:	57                   	push   %edi
  801414:	e8 86 02 00 00       	call   80169f <strnlen>
  801419:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80141c:	29 c1                	sub    %eax,%ecx
  80141e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801421:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801424:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801428:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80142b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80142e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801430:	eb 0f                	jmp    801441 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801432:	83 ec 08             	sub    $0x8,%esp
  801435:	53                   	push   %ebx
  801436:	ff 75 e0             	pushl  -0x20(%ebp)
  801439:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80143b:	83 ef 01             	sub    $0x1,%edi
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	85 ff                	test   %edi,%edi
  801443:	7f ed                	jg     801432 <vprintfmt+0x1c0>
  801445:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801448:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80144b:	85 c9                	test   %ecx,%ecx
  80144d:	b8 00 00 00 00       	mov    $0x0,%eax
  801452:	0f 49 c1             	cmovns %ecx,%eax
  801455:	29 c1                	sub    %eax,%ecx
  801457:	89 75 08             	mov    %esi,0x8(%ebp)
  80145a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80145d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801460:	89 cb                	mov    %ecx,%ebx
  801462:	eb 4d                	jmp    8014b1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801464:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801468:	74 1b                	je     801485 <vprintfmt+0x213>
  80146a:	0f be c0             	movsbl %al,%eax
  80146d:	83 e8 20             	sub    $0x20,%eax
  801470:	83 f8 5e             	cmp    $0x5e,%eax
  801473:	76 10                	jbe    801485 <vprintfmt+0x213>
					putch('?', putdat);
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	ff 75 0c             	pushl  0xc(%ebp)
  80147b:	6a 3f                	push   $0x3f
  80147d:	ff 55 08             	call   *0x8(%ebp)
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	eb 0d                	jmp    801492 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	ff 75 0c             	pushl  0xc(%ebp)
  80148b:	52                   	push   %edx
  80148c:	ff 55 08             	call   *0x8(%ebp)
  80148f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801492:	83 eb 01             	sub    $0x1,%ebx
  801495:	eb 1a                	jmp    8014b1 <vprintfmt+0x23f>
  801497:	89 75 08             	mov    %esi,0x8(%ebp)
  80149a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80149d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a3:	eb 0c                	jmp    8014b1 <vprintfmt+0x23f>
  8014a5:	89 75 08             	mov    %esi,0x8(%ebp)
  8014a8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014ab:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014ae:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014b1:	83 c7 01             	add    $0x1,%edi
  8014b4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014b8:	0f be d0             	movsbl %al,%edx
  8014bb:	85 d2                	test   %edx,%edx
  8014bd:	74 23                	je     8014e2 <vprintfmt+0x270>
  8014bf:	85 f6                	test   %esi,%esi
  8014c1:	78 a1                	js     801464 <vprintfmt+0x1f2>
  8014c3:	83 ee 01             	sub    $0x1,%esi
  8014c6:	79 9c                	jns    801464 <vprintfmt+0x1f2>
  8014c8:	89 df                	mov    %ebx,%edi
  8014ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8014cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014d0:	eb 18                	jmp    8014ea <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014d2:	83 ec 08             	sub    $0x8,%esp
  8014d5:	53                   	push   %ebx
  8014d6:	6a 20                	push   $0x20
  8014d8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014da:	83 ef 01             	sub    $0x1,%edi
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	eb 08                	jmp    8014ea <vprintfmt+0x278>
  8014e2:	89 df                	mov    %ebx,%edi
  8014e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014ea:	85 ff                	test   %edi,%edi
  8014ec:	7f e4                	jg     8014d2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014f1:	e9 a2 fd ff ff       	jmp    801298 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014f6:	83 fa 01             	cmp    $0x1,%edx
  8014f9:	7e 16                	jle    801511 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fe:	8d 50 08             	lea    0x8(%eax),%edx
  801501:	89 55 14             	mov    %edx,0x14(%ebp)
  801504:	8b 50 04             	mov    0x4(%eax),%edx
  801507:	8b 00                	mov    (%eax),%eax
  801509:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80150c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80150f:	eb 32                	jmp    801543 <vprintfmt+0x2d1>
	else if (lflag)
  801511:	85 d2                	test   %edx,%edx
  801513:	74 18                	je     80152d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801515:	8b 45 14             	mov    0x14(%ebp),%eax
  801518:	8d 50 04             	lea    0x4(%eax),%edx
  80151b:	89 55 14             	mov    %edx,0x14(%ebp)
  80151e:	8b 00                	mov    (%eax),%eax
  801520:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801523:	89 c1                	mov    %eax,%ecx
  801525:	c1 f9 1f             	sar    $0x1f,%ecx
  801528:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80152b:	eb 16                	jmp    801543 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80152d:	8b 45 14             	mov    0x14(%ebp),%eax
  801530:	8d 50 04             	lea    0x4(%eax),%edx
  801533:	89 55 14             	mov    %edx,0x14(%ebp)
  801536:	8b 00                	mov    (%eax),%eax
  801538:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80153b:	89 c1                	mov    %eax,%ecx
  80153d:	c1 f9 1f             	sar    $0x1f,%ecx
  801540:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801543:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801546:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801549:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80154e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801552:	79 74                	jns    8015c8 <vprintfmt+0x356>
				putch('-', putdat);
  801554:	83 ec 08             	sub    $0x8,%esp
  801557:	53                   	push   %ebx
  801558:	6a 2d                	push   $0x2d
  80155a:	ff d6                	call   *%esi
				num = -(long long) num;
  80155c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80155f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801562:	f7 d8                	neg    %eax
  801564:	83 d2 00             	adc    $0x0,%edx
  801567:	f7 da                	neg    %edx
  801569:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80156c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801571:	eb 55                	jmp    8015c8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801573:	8d 45 14             	lea    0x14(%ebp),%eax
  801576:	e8 83 fc ff ff       	call   8011fe <getuint>
			base = 10;
  80157b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801580:	eb 46                	jmp    8015c8 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801582:	8d 45 14             	lea    0x14(%ebp),%eax
  801585:	e8 74 fc ff ff       	call   8011fe <getuint>
			base = 8;
  80158a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80158f:	eb 37                	jmp    8015c8 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	53                   	push   %ebx
  801595:	6a 30                	push   $0x30
  801597:	ff d6                	call   *%esi
			putch('x', putdat);
  801599:	83 c4 08             	add    $0x8,%esp
  80159c:	53                   	push   %ebx
  80159d:	6a 78                	push   $0x78
  80159f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a4:	8d 50 04             	lea    0x4(%eax),%edx
  8015a7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015aa:	8b 00                	mov    (%eax),%eax
  8015ac:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015b1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015b4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015b9:	eb 0d                	jmp    8015c8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8015be:	e8 3b fc ff ff       	call   8011fe <getuint>
			base = 16;
  8015c3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015c8:	83 ec 0c             	sub    $0xc,%esp
  8015cb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015cf:	57                   	push   %edi
  8015d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d3:	51                   	push   %ecx
  8015d4:	52                   	push   %edx
  8015d5:	50                   	push   %eax
  8015d6:	89 da                	mov    %ebx,%edx
  8015d8:	89 f0                	mov    %esi,%eax
  8015da:	e8 70 fb ff ff       	call   80114f <printnum>
			break;
  8015df:	83 c4 20             	add    $0x20,%esp
  8015e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015e5:	e9 ae fc ff ff       	jmp    801298 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015ea:	83 ec 08             	sub    $0x8,%esp
  8015ed:	53                   	push   %ebx
  8015ee:	51                   	push   %ecx
  8015ef:	ff d6                	call   *%esi
			break;
  8015f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015f7:	e9 9c fc ff ff       	jmp    801298 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	53                   	push   %ebx
  801600:	6a 25                	push   $0x25
  801602:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	eb 03                	jmp    80160c <vprintfmt+0x39a>
  801609:	83 ef 01             	sub    $0x1,%edi
  80160c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801610:	75 f7                	jne    801609 <vprintfmt+0x397>
  801612:	e9 81 fc ff ff       	jmp    801298 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801617:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161a:	5b                   	pop    %ebx
  80161b:	5e                   	pop    %esi
  80161c:	5f                   	pop    %edi
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    

0080161f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	83 ec 18             	sub    $0x18,%esp
  801625:	8b 45 08             	mov    0x8(%ebp),%eax
  801628:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80162b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80162e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801632:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801635:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80163c:	85 c0                	test   %eax,%eax
  80163e:	74 26                	je     801666 <vsnprintf+0x47>
  801640:	85 d2                	test   %edx,%edx
  801642:	7e 22                	jle    801666 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801644:	ff 75 14             	pushl  0x14(%ebp)
  801647:	ff 75 10             	pushl  0x10(%ebp)
  80164a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80164d:	50                   	push   %eax
  80164e:	68 38 12 80 00       	push   $0x801238
  801653:	e8 1a fc ff ff       	call   801272 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801658:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80165b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80165e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	eb 05                	jmp    80166b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801666:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80166b:	c9                   	leave  
  80166c:	c3                   	ret    

0080166d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801673:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801676:	50                   	push   %eax
  801677:	ff 75 10             	pushl  0x10(%ebp)
  80167a:	ff 75 0c             	pushl  0xc(%ebp)
  80167d:	ff 75 08             	pushl  0x8(%ebp)
  801680:	e8 9a ff ff ff       	call   80161f <vsnprintf>
	va_end(ap);

	return rc;
}
  801685:	c9                   	leave  
  801686:	c3                   	ret    

00801687 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80168d:	b8 00 00 00 00       	mov    $0x0,%eax
  801692:	eb 03                	jmp    801697 <strlen+0x10>
		n++;
  801694:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801697:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80169b:	75 f7                	jne    801694 <strlen+0xd>
		n++;
	return n;
}
  80169d:	5d                   	pop    %ebp
  80169e:	c3                   	ret    

0080169f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ad:	eb 03                	jmp    8016b2 <strnlen+0x13>
		n++;
  8016af:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016b2:	39 c2                	cmp    %eax,%edx
  8016b4:	74 08                	je     8016be <strnlen+0x1f>
  8016b6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016ba:	75 f3                	jne    8016af <strnlen+0x10>
  8016bc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	53                   	push   %ebx
  8016c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016ca:	89 c2                	mov    %eax,%edx
  8016cc:	83 c2 01             	add    $0x1,%edx
  8016cf:	83 c1 01             	add    $0x1,%ecx
  8016d2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016d6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016d9:	84 db                	test   %bl,%bl
  8016db:	75 ef                	jne    8016cc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016dd:	5b                   	pop    %ebx
  8016de:	5d                   	pop    %ebp
  8016df:	c3                   	ret    

008016e0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016e7:	53                   	push   %ebx
  8016e8:	e8 9a ff ff ff       	call   801687 <strlen>
  8016ed:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016f0:	ff 75 0c             	pushl  0xc(%ebp)
  8016f3:	01 d8                	add    %ebx,%eax
  8016f5:	50                   	push   %eax
  8016f6:	e8 c5 ff ff ff       	call   8016c0 <strcpy>
	return dst;
}
  8016fb:	89 d8                	mov    %ebx,%eax
  8016fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801700:	c9                   	leave  
  801701:	c3                   	ret    

00801702 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	56                   	push   %esi
  801706:	53                   	push   %ebx
  801707:	8b 75 08             	mov    0x8(%ebp),%esi
  80170a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170d:	89 f3                	mov    %esi,%ebx
  80170f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801712:	89 f2                	mov    %esi,%edx
  801714:	eb 0f                	jmp    801725 <strncpy+0x23>
		*dst++ = *src;
  801716:	83 c2 01             	add    $0x1,%edx
  801719:	0f b6 01             	movzbl (%ecx),%eax
  80171c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80171f:	80 39 01             	cmpb   $0x1,(%ecx)
  801722:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801725:	39 da                	cmp    %ebx,%edx
  801727:	75 ed                	jne    801716 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801729:	89 f0                	mov    %esi,%eax
  80172b:	5b                   	pop    %ebx
  80172c:	5e                   	pop    %esi
  80172d:	5d                   	pop    %ebp
  80172e:	c3                   	ret    

0080172f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	56                   	push   %esi
  801733:	53                   	push   %ebx
  801734:	8b 75 08             	mov    0x8(%ebp),%esi
  801737:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173a:	8b 55 10             	mov    0x10(%ebp),%edx
  80173d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80173f:	85 d2                	test   %edx,%edx
  801741:	74 21                	je     801764 <strlcpy+0x35>
  801743:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801747:	89 f2                	mov    %esi,%edx
  801749:	eb 09                	jmp    801754 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80174b:	83 c2 01             	add    $0x1,%edx
  80174e:	83 c1 01             	add    $0x1,%ecx
  801751:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801754:	39 c2                	cmp    %eax,%edx
  801756:	74 09                	je     801761 <strlcpy+0x32>
  801758:	0f b6 19             	movzbl (%ecx),%ebx
  80175b:	84 db                	test   %bl,%bl
  80175d:	75 ec                	jne    80174b <strlcpy+0x1c>
  80175f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801761:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801764:	29 f0                	sub    %esi,%eax
}
  801766:	5b                   	pop    %ebx
  801767:	5e                   	pop    %esi
  801768:	5d                   	pop    %ebp
  801769:	c3                   	ret    

0080176a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801770:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801773:	eb 06                	jmp    80177b <strcmp+0x11>
		p++, q++;
  801775:	83 c1 01             	add    $0x1,%ecx
  801778:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80177b:	0f b6 01             	movzbl (%ecx),%eax
  80177e:	84 c0                	test   %al,%al
  801780:	74 04                	je     801786 <strcmp+0x1c>
  801782:	3a 02                	cmp    (%edx),%al
  801784:	74 ef                	je     801775 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801786:	0f b6 c0             	movzbl %al,%eax
  801789:	0f b6 12             	movzbl (%edx),%edx
  80178c:	29 d0                	sub    %edx,%eax
}
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	53                   	push   %ebx
  801794:	8b 45 08             	mov    0x8(%ebp),%eax
  801797:	8b 55 0c             	mov    0xc(%ebp),%edx
  80179a:	89 c3                	mov    %eax,%ebx
  80179c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80179f:	eb 06                	jmp    8017a7 <strncmp+0x17>
		n--, p++, q++;
  8017a1:	83 c0 01             	add    $0x1,%eax
  8017a4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017a7:	39 d8                	cmp    %ebx,%eax
  8017a9:	74 15                	je     8017c0 <strncmp+0x30>
  8017ab:	0f b6 08             	movzbl (%eax),%ecx
  8017ae:	84 c9                	test   %cl,%cl
  8017b0:	74 04                	je     8017b6 <strncmp+0x26>
  8017b2:	3a 0a                	cmp    (%edx),%cl
  8017b4:	74 eb                	je     8017a1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b6:	0f b6 00             	movzbl (%eax),%eax
  8017b9:	0f b6 12             	movzbl (%edx),%edx
  8017bc:	29 d0                	sub    %edx,%eax
  8017be:	eb 05                	jmp    8017c5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017c0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017c5:	5b                   	pop    %ebx
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017d2:	eb 07                	jmp    8017db <strchr+0x13>
		if (*s == c)
  8017d4:	38 ca                	cmp    %cl,%dl
  8017d6:	74 0f                	je     8017e7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017d8:	83 c0 01             	add    $0x1,%eax
  8017db:	0f b6 10             	movzbl (%eax),%edx
  8017de:	84 d2                	test   %dl,%dl
  8017e0:	75 f2                	jne    8017d4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f3:	eb 03                	jmp    8017f8 <strfind+0xf>
  8017f5:	83 c0 01             	add    $0x1,%eax
  8017f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017fb:	38 ca                	cmp    %cl,%dl
  8017fd:	74 04                	je     801803 <strfind+0x1a>
  8017ff:	84 d2                	test   %dl,%dl
  801801:	75 f2                	jne    8017f5 <strfind+0xc>
			break;
	return (char *) s;
}
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    

00801805 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	57                   	push   %edi
  801809:	56                   	push   %esi
  80180a:	53                   	push   %ebx
  80180b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80180e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801811:	85 c9                	test   %ecx,%ecx
  801813:	74 36                	je     80184b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801815:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80181b:	75 28                	jne    801845 <memset+0x40>
  80181d:	f6 c1 03             	test   $0x3,%cl
  801820:	75 23                	jne    801845 <memset+0x40>
		c &= 0xFF;
  801822:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801826:	89 d3                	mov    %edx,%ebx
  801828:	c1 e3 08             	shl    $0x8,%ebx
  80182b:	89 d6                	mov    %edx,%esi
  80182d:	c1 e6 18             	shl    $0x18,%esi
  801830:	89 d0                	mov    %edx,%eax
  801832:	c1 e0 10             	shl    $0x10,%eax
  801835:	09 f0                	or     %esi,%eax
  801837:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801839:	89 d8                	mov    %ebx,%eax
  80183b:	09 d0                	or     %edx,%eax
  80183d:	c1 e9 02             	shr    $0x2,%ecx
  801840:	fc                   	cld    
  801841:	f3 ab                	rep stos %eax,%es:(%edi)
  801843:	eb 06                	jmp    80184b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801845:	8b 45 0c             	mov    0xc(%ebp),%eax
  801848:	fc                   	cld    
  801849:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80184b:	89 f8                	mov    %edi,%eax
  80184d:	5b                   	pop    %ebx
  80184e:	5e                   	pop    %esi
  80184f:	5f                   	pop    %edi
  801850:	5d                   	pop    %ebp
  801851:	c3                   	ret    

00801852 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	57                   	push   %edi
  801856:	56                   	push   %esi
  801857:	8b 45 08             	mov    0x8(%ebp),%eax
  80185a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80185d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801860:	39 c6                	cmp    %eax,%esi
  801862:	73 35                	jae    801899 <memmove+0x47>
  801864:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801867:	39 d0                	cmp    %edx,%eax
  801869:	73 2e                	jae    801899 <memmove+0x47>
		s += n;
		d += n;
  80186b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80186e:	89 d6                	mov    %edx,%esi
  801870:	09 fe                	or     %edi,%esi
  801872:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801878:	75 13                	jne    80188d <memmove+0x3b>
  80187a:	f6 c1 03             	test   $0x3,%cl
  80187d:	75 0e                	jne    80188d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80187f:	83 ef 04             	sub    $0x4,%edi
  801882:	8d 72 fc             	lea    -0x4(%edx),%esi
  801885:	c1 e9 02             	shr    $0x2,%ecx
  801888:	fd                   	std    
  801889:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80188b:	eb 09                	jmp    801896 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80188d:	83 ef 01             	sub    $0x1,%edi
  801890:	8d 72 ff             	lea    -0x1(%edx),%esi
  801893:	fd                   	std    
  801894:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801896:	fc                   	cld    
  801897:	eb 1d                	jmp    8018b6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801899:	89 f2                	mov    %esi,%edx
  80189b:	09 c2                	or     %eax,%edx
  80189d:	f6 c2 03             	test   $0x3,%dl
  8018a0:	75 0f                	jne    8018b1 <memmove+0x5f>
  8018a2:	f6 c1 03             	test   $0x3,%cl
  8018a5:	75 0a                	jne    8018b1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018a7:	c1 e9 02             	shr    $0x2,%ecx
  8018aa:	89 c7                	mov    %eax,%edi
  8018ac:	fc                   	cld    
  8018ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018af:	eb 05                	jmp    8018b6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018b1:	89 c7                	mov    %eax,%edi
  8018b3:	fc                   	cld    
  8018b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018b6:	5e                   	pop    %esi
  8018b7:	5f                   	pop    %edi
  8018b8:	5d                   	pop    %ebp
  8018b9:	c3                   	ret    

008018ba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018bd:	ff 75 10             	pushl  0x10(%ebp)
  8018c0:	ff 75 0c             	pushl  0xc(%ebp)
  8018c3:	ff 75 08             	pushl  0x8(%ebp)
  8018c6:	e8 87 ff ff ff       	call   801852 <memmove>
}
  8018cb:	c9                   	leave  
  8018cc:	c3                   	ret    

008018cd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	56                   	push   %esi
  8018d1:	53                   	push   %ebx
  8018d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d8:	89 c6                	mov    %eax,%esi
  8018da:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018dd:	eb 1a                	jmp    8018f9 <memcmp+0x2c>
		if (*s1 != *s2)
  8018df:	0f b6 08             	movzbl (%eax),%ecx
  8018e2:	0f b6 1a             	movzbl (%edx),%ebx
  8018e5:	38 d9                	cmp    %bl,%cl
  8018e7:	74 0a                	je     8018f3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018e9:	0f b6 c1             	movzbl %cl,%eax
  8018ec:	0f b6 db             	movzbl %bl,%ebx
  8018ef:	29 d8                	sub    %ebx,%eax
  8018f1:	eb 0f                	jmp    801902 <memcmp+0x35>
		s1++, s2++;
  8018f3:	83 c0 01             	add    $0x1,%eax
  8018f6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f9:	39 f0                	cmp    %esi,%eax
  8018fb:	75 e2                	jne    8018df <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801902:	5b                   	pop    %ebx
  801903:	5e                   	pop    %esi
  801904:	5d                   	pop    %ebp
  801905:	c3                   	ret    

00801906 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	53                   	push   %ebx
  80190a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80190d:	89 c1                	mov    %eax,%ecx
  80190f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801912:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801916:	eb 0a                	jmp    801922 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801918:	0f b6 10             	movzbl (%eax),%edx
  80191b:	39 da                	cmp    %ebx,%edx
  80191d:	74 07                	je     801926 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80191f:	83 c0 01             	add    $0x1,%eax
  801922:	39 c8                	cmp    %ecx,%eax
  801924:	72 f2                	jb     801918 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801926:	5b                   	pop    %ebx
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    

00801929 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	57                   	push   %edi
  80192d:	56                   	push   %esi
  80192e:	53                   	push   %ebx
  80192f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801932:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801935:	eb 03                	jmp    80193a <strtol+0x11>
		s++;
  801937:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80193a:	0f b6 01             	movzbl (%ecx),%eax
  80193d:	3c 20                	cmp    $0x20,%al
  80193f:	74 f6                	je     801937 <strtol+0xe>
  801941:	3c 09                	cmp    $0x9,%al
  801943:	74 f2                	je     801937 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801945:	3c 2b                	cmp    $0x2b,%al
  801947:	75 0a                	jne    801953 <strtol+0x2a>
		s++;
  801949:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80194c:	bf 00 00 00 00       	mov    $0x0,%edi
  801951:	eb 11                	jmp    801964 <strtol+0x3b>
  801953:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801958:	3c 2d                	cmp    $0x2d,%al
  80195a:	75 08                	jne    801964 <strtol+0x3b>
		s++, neg = 1;
  80195c:	83 c1 01             	add    $0x1,%ecx
  80195f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801964:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80196a:	75 15                	jne    801981 <strtol+0x58>
  80196c:	80 39 30             	cmpb   $0x30,(%ecx)
  80196f:	75 10                	jne    801981 <strtol+0x58>
  801971:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801975:	75 7c                	jne    8019f3 <strtol+0xca>
		s += 2, base = 16;
  801977:	83 c1 02             	add    $0x2,%ecx
  80197a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80197f:	eb 16                	jmp    801997 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801981:	85 db                	test   %ebx,%ebx
  801983:	75 12                	jne    801997 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801985:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80198a:	80 39 30             	cmpb   $0x30,(%ecx)
  80198d:	75 08                	jne    801997 <strtol+0x6e>
		s++, base = 8;
  80198f:	83 c1 01             	add    $0x1,%ecx
  801992:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801997:	b8 00 00 00 00       	mov    $0x0,%eax
  80199c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80199f:	0f b6 11             	movzbl (%ecx),%edx
  8019a2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019a5:	89 f3                	mov    %esi,%ebx
  8019a7:	80 fb 09             	cmp    $0x9,%bl
  8019aa:	77 08                	ja     8019b4 <strtol+0x8b>
			dig = *s - '0';
  8019ac:	0f be d2             	movsbl %dl,%edx
  8019af:	83 ea 30             	sub    $0x30,%edx
  8019b2:	eb 22                	jmp    8019d6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019b4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019b7:	89 f3                	mov    %esi,%ebx
  8019b9:	80 fb 19             	cmp    $0x19,%bl
  8019bc:	77 08                	ja     8019c6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019be:	0f be d2             	movsbl %dl,%edx
  8019c1:	83 ea 57             	sub    $0x57,%edx
  8019c4:	eb 10                	jmp    8019d6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019c6:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019c9:	89 f3                	mov    %esi,%ebx
  8019cb:	80 fb 19             	cmp    $0x19,%bl
  8019ce:	77 16                	ja     8019e6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019d0:	0f be d2             	movsbl %dl,%edx
  8019d3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019d6:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019d9:	7d 0b                	jge    8019e6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019db:	83 c1 01             	add    $0x1,%ecx
  8019de:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019e2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019e4:	eb b9                	jmp    80199f <strtol+0x76>

	if (endptr)
  8019e6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019ea:	74 0d                	je     8019f9 <strtol+0xd0>
		*endptr = (char *) s;
  8019ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019ef:	89 0e                	mov    %ecx,(%esi)
  8019f1:	eb 06                	jmp    8019f9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019f3:	85 db                	test   %ebx,%ebx
  8019f5:	74 98                	je     80198f <strtol+0x66>
  8019f7:	eb 9e                	jmp    801997 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019f9:	89 c2                	mov    %eax,%edx
  8019fb:	f7 da                	neg    %edx
  8019fd:	85 ff                	test   %edi,%edi
  8019ff:	0f 45 c2             	cmovne %edx,%eax
}
  801a02:	5b                   	pop    %ebx
  801a03:	5e                   	pop    %esi
  801a04:	5f                   	pop    %edi
  801a05:	5d                   	pop    %ebp
  801a06:	c3                   	ret    

00801a07 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a0d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a14:	75 2e                	jne    801a44 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801a16:	e8 17 e7 ff ff       	call   800132 <sys_getenvid>
  801a1b:	83 ec 04             	sub    $0x4,%esp
  801a1e:	68 07 0e 00 00       	push   $0xe07
  801a23:	68 00 f0 bf ee       	push   $0xeebff000
  801a28:	50                   	push   %eax
  801a29:	e8 42 e7 ff ff       	call   800170 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801a2e:	e8 ff e6 ff ff       	call   800132 <sys_getenvid>
  801a33:	83 c4 08             	add    $0x8,%esp
  801a36:	68 61 03 80 00       	push   $0x800361
  801a3b:	50                   	push   %eax
  801a3c:	e8 7a e8 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801a41:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a44:	8b 45 08             	mov    0x8(%ebp),%eax
  801a47:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801a4c:	c9                   	leave  
  801a4d:	c3                   	ret    

00801a4e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	56                   	push   %esi
  801a52:	53                   	push   %ebx
  801a53:	8b 75 08             	mov    0x8(%ebp),%esi
  801a56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801a5c:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801a5e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a63:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	50                   	push   %eax
  801a6a:	e8 b1 e8 ff ff       	call   800320 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	85 f6                	test   %esi,%esi
  801a74:	74 14                	je     801a8a <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801a76:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 09                	js     801a88 <ipc_recv+0x3a>
  801a7f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a85:	8b 52 74             	mov    0x74(%edx),%edx
  801a88:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a8a:	85 db                	test   %ebx,%ebx
  801a8c:	74 14                	je     801aa2 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a8e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a93:	85 c0                	test   %eax,%eax
  801a95:	78 09                	js     801aa0 <ipc_recv+0x52>
  801a97:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a9d:	8b 52 78             	mov    0x78(%edx),%edx
  801aa0:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	78 08                	js     801aae <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801aa6:	a1 04 40 80 00       	mov    0x804004,%eax
  801aab:	8b 40 70             	mov    0x70(%eax),%eax
}
  801aae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab1:	5b                   	pop    %ebx
  801ab2:	5e                   	pop    %esi
  801ab3:	5d                   	pop    %ebp
  801ab4:	c3                   	ret    

00801ab5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	57                   	push   %edi
  801ab9:	56                   	push   %esi
  801aba:	53                   	push   %ebx
  801abb:	83 ec 0c             	sub    $0xc,%esp
  801abe:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ac1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ac4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801ac7:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ac9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ace:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ad1:	ff 75 14             	pushl  0x14(%ebp)
  801ad4:	53                   	push   %ebx
  801ad5:	56                   	push   %esi
  801ad6:	57                   	push   %edi
  801ad7:	e8 21 e8 ff ff       	call   8002fd <sys_ipc_try_send>

		if (err < 0) {
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	79 1e                	jns    801b01 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801ae3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ae6:	75 07                	jne    801aef <ipc_send+0x3a>
				sys_yield();
  801ae8:	e8 64 e6 ff ff       	call   800151 <sys_yield>
  801aed:	eb e2                	jmp    801ad1 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801aef:	50                   	push   %eax
  801af0:	68 60 22 80 00       	push   $0x802260
  801af5:	6a 49                	push   $0x49
  801af7:	68 6d 22 80 00       	push   $0x80226d
  801afc:	e8 61 f5 ff ff       	call   801062 <_panic>
		}

	} while (err < 0);

}
  801b01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b04:	5b                   	pop    %ebx
  801b05:	5e                   	pop    %esi
  801b06:	5f                   	pop    %edi
  801b07:	5d                   	pop    %ebp
  801b08:	c3                   	ret    

00801b09 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b0f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b14:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b17:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b1d:	8b 52 50             	mov    0x50(%edx),%edx
  801b20:	39 ca                	cmp    %ecx,%edx
  801b22:	75 0d                	jne    801b31 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b24:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b27:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b2c:	8b 40 48             	mov    0x48(%eax),%eax
  801b2f:	eb 0f                	jmp    801b40 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b31:	83 c0 01             	add    $0x1,%eax
  801b34:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b39:	75 d9                	jne    801b14 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b40:	5d                   	pop    %ebp
  801b41:	c3                   	ret    

00801b42 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b48:	89 d0                	mov    %edx,%eax
  801b4a:	c1 e8 16             	shr    $0x16,%eax
  801b4d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b54:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b59:	f6 c1 01             	test   $0x1,%cl
  801b5c:	74 1d                	je     801b7b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b5e:	c1 ea 0c             	shr    $0xc,%edx
  801b61:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b68:	f6 c2 01             	test   $0x1,%dl
  801b6b:	74 0e                	je     801b7b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b6d:	c1 ea 0c             	shr    $0xc,%edx
  801b70:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b77:	ef 
  801b78:	0f b7 c0             	movzwl %ax,%eax
}
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    
  801b7d:	66 90                	xchg   %ax,%ax
  801b7f:	90                   	nop

00801b80 <__udivdi3>:
  801b80:	55                   	push   %ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	83 ec 1c             	sub    $0x1c,%esp
  801b87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b97:	85 f6                	test   %esi,%esi
  801b99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b9d:	89 ca                	mov    %ecx,%edx
  801b9f:	89 f8                	mov    %edi,%eax
  801ba1:	75 3d                	jne    801be0 <__udivdi3+0x60>
  801ba3:	39 cf                	cmp    %ecx,%edi
  801ba5:	0f 87 c5 00 00 00    	ja     801c70 <__udivdi3+0xf0>
  801bab:	85 ff                	test   %edi,%edi
  801bad:	89 fd                	mov    %edi,%ebp
  801baf:	75 0b                	jne    801bbc <__udivdi3+0x3c>
  801bb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb6:	31 d2                	xor    %edx,%edx
  801bb8:	f7 f7                	div    %edi
  801bba:	89 c5                	mov    %eax,%ebp
  801bbc:	89 c8                	mov    %ecx,%eax
  801bbe:	31 d2                	xor    %edx,%edx
  801bc0:	f7 f5                	div    %ebp
  801bc2:	89 c1                	mov    %eax,%ecx
  801bc4:	89 d8                	mov    %ebx,%eax
  801bc6:	89 cf                	mov    %ecx,%edi
  801bc8:	f7 f5                	div    %ebp
  801bca:	89 c3                	mov    %eax,%ebx
  801bcc:	89 d8                	mov    %ebx,%eax
  801bce:	89 fa                	mov    %edi,%edx
  801bd0:	83 c4 1c             	add    $0x1c,%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    
  801bd8:	90                   	nop
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	39 ce                	cmp    %ecx,%esi
  801be2:	77 74                	ja     801c58 <__udivdi3+0xd8>
  801be4:	0f bd fe             	bsr    %esi,%edi
  801be7:	83 f7 1f             	xor    $0x1f,%edi
  801bea:	0f 84 98 00 00 00    	je     801c88 <__udivdi3+0x108>
  801bf0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	89 c5                	mov    %eax,%ebp
  801bf9:	29 fb                	sub    %edi,%ebx
  801bfb:	d3 e6                	shl    %cl,%esi
  801bfd:	89 d9                	mov    %ebx,%ecx
  801bff:	d3 ed                	shr    %cl,%ebp
  801c01:	89 f9                	mov    %edi,%ecx
  801c03:	d3 e0                	shl    %cl,%eax
  801c05:	09 ee                	or     %ebp,%esi
  801c07:	89 d9                	mov    %ebx,%ecx
  801c09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c0d:	89 d5                	mov    %edx,%ebp
  801c0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c13:	d3 ed                	shr    %cl,%ebp
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e2                	shl    %cl,%edx
  801c19:	89 d9                	mov    %ebx,%ecx
  801c1b:	d3 e8                	shr    %cl,%eax
  801c1d:	09 c2                	or     %eax,%edx
  801c1f:	89 d0                	mov    %edx,%eax
  801c21:	89 ea                	mov    %ebp,%edx
  801c23:	f7 f6                	div    %esi
  801c25:	89 d5                	mov    %edx,%ebp
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	f7 64 24 0c          	mull   0xc(%esp)
  801c2d:	39 d5                	cmp    %edx,%ebp
  801c2f:	72 10                	jb     801c41 <__udivdi3+0xc1>
  801c31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	d3 e6                	shl    %cl,%esi
  801c39:	39 c6                	cmp    %eax,%esi
  801c3b:	73 07                	jae    801c44 <__udivdi3+0xc4>
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	75 03                	jne    801c44 <__udivdi3+0xc4>
  801c41:	83 eb 01             	sub    $0x1,%ebx
  801c44:	31 ff                	xor    %edi,%edi
  801c46:	89 d8                	mov    %ebx,%eax
  801c48:	89 fa                	mov    %edi,%edx
  801c4a:	83 c4 1c             	add    $0x1c,%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    
  801c52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c58:	31 ff                	xor    %edi,%edi
  801c5a:	31 db                	xor    %ebx,%ebx
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	89 fa                	mov    %edi,%edx
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    
  801c68:	90                   	nop
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	89 d8                	mov    %ebx,%eax
  801c72:	f7 f7                	div    %edi
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	89 d8                	mov    %ebx,%eax
  801c7a:	89 fa                	mov    %edi,%edx
  801c7c:	83 c4 1c             	add    $0x1c,%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5f                   	pop    %edi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    
  801c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c88:	39 ce                	cmp    %ecx,%esi
  801c8a:	72 0c                	jb     801c98 <__udivdi3+0x118>
  801c8c:	31 db                	xor    %ebx,%ebx
  801c8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c92:	0f 87 34 ff ff ff    	ja     801bcc <__udivdi3+0x4c>
  801c98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c9d:	e9 2a ff ff ff       	jmp    801bcc <__udivdi3+0x4c>
  801ca2:	66 90                	xchg   %ax,%ax
  801ca4:	66 90                	xchg   %ax,%ax
  801ca6:	66 90                	xchg   %ax,%ax
  801ca8:	66 90                	xchg   %ax,%ax
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__umoddi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc7:	85 d2                	test   %edx,%edx
  801cc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ccd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cd1:	89 f3                	mov    %esi,%ebx
  801cd3:	89 3c 24             	mov    %edi,(%esp)
  801cd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cda:	75 1c                	jne    801cf8 <__umoddi3+0x48>
  801cdc:	39 f7                	cmp    %esi,%edi
  801cde:	76 50                	jbe    801d30 <__umoddi3+0x80>
  801ce0:	89 c8                	mov    %ecx,%eax
  801ce2:	89 f2                	mov    %esi,%edx
  801ce4:	f7 f7                	div    %edi
  801ce6:	89 d0                	mov    %edx,%eax
  801ce8:	31 d2                	xor    %edx,%edx
  801cea:	83 c4 1c             	add    $0x1c,%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5f                   	pop    %edi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    
  801cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf8:	39 f2                	cmp    %esi,%edx
  801cfa:	89 d0                	mov    %edx,%eax
  801cfc:	77 52                	ja     801d50 <__umoddi3+0xa0>
  801cfe:	0f bd ea             	bsr    %edx,%ebp
  801d01:	83 f5 1f             	xor    $0x1f,%ebp
  801d04:	75 5a                	jne    801d60 <__umoddi3+0xb0>
  801d06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d0a:	0f 82 e0 00 00 00    	jb     801df0 <__umoddi3+0x140>
  801d10:	39 0c 24             	cmp    %ecx,(%esp)
  801d13:	0f 86 d7 00 00 00    	jbe    801df0 <__umoddi3+0x140>
  801d19:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d21:	83 c4 1c             	add    $0x1c,%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	85 ff                	test   %edi,%edi
  801d32:	89 fd                	mov    %edi,%ebp
  801d34:	75 0b                	jne    801d41 <__umoddi3+0x91>
  801d36:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3b:	31 d2                	xor    %edx,%edx
  801d3d:	f7 f7                	div    %edi
  801d3f:	89 c5                	mov    %eax,%ebp
  801d41:	89 f0                	mov    %esi,%eax
  801d43:	31 d2                	xor    %edx,%edx
  801d45:	f7 f5                	div    %ebp
  801d47:	89 c8                	mov    %ecx,%eax
  801d49:	f7 f5                	div    %ebp
  801d4b:	89 d0                	mov    %edx,%eax
  801d4d:	eb 99                	jmp    801ce8 <__umoddi3+0x38>
  801d4f:	90                   	nop
  801d50:	89 c8                	mov    %ecx,%eax
  801d52:	89 f2                	mov    %esi,%edx
  801d54:	83 c4 1c             	add    $0x1c,%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5f                   	pop    %edi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    
  801d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d60:	8b 34 24             	mov    (%esp),%esi
  801d63:	bf 20 00 00 00       	mov    $0x20,%edi
  801d68:	89 e9                	mov    %ebp,%ecx
  801d6a:	29 ef                	sub    %ebp,%edi
  801d6c:	d3 e0                	shl    %cl,%eax
  801d6e:	89 f9                	mov    %edi,%ecx
  801d70:	89 f2                	mov    %esi,%edx
  801d72:	d3 ea                	shr    %cl,%edx
  801d74:	89 e9                	mov    %ebp,%ecx
  801d76:	09 c2                	or     %eax,%edx
  801d78:	89 d8                	mov    %ebx,%eax
  801d7a:	89 14 24             	mov    %edx,(%esp)
  801d7d:	89 f2                	mov    %esi,%edx
  801d7f:	d3 e2                	shl    %cl,%edx
  801d81:	89 f9                	mov    %edi,%ecx
  801d83:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d8b:	d3 e8                	shr    %cl,%eax
  801d8d:	89 e9                	mov    %ebp,%ecx
  801d8f:	89 c6                	mov    %eax,%esi
  801d91:	d3 e3                	shl    %cl,%ebx
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	89 d0                	mov    %edx,%eax
  801d97:	d3 e8                	shr    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	09 d8                	or     %ebx,%eax
  801d9d:	89 d3                	mov    %edx,%ebx
  801d9f:	89 f2                	mov    %esi,%edx
  801da1:	f7 34 24             	divl   (%esp)
  801da4:	89 d6                	mov    %edx,%esi
  801da6:	d3 e3                	shl    %cl,%ebx
  801da8:	f7 64 24 04          	mull   0x4(%esp)
  801dac:	39 d6                	cmp    %edx,%esi
  801dae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801db2:	89 d1                	mov    %edx,%ecx
  801db4:	89 c3                	mov    %eax,%ebx
  801db6:	72 08                	jb     801dc0 <__umoddi3+0x110>
  801db8:	75 11                	jne    801dcb <__umoddi3+0x11b>
  801dba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dbe:	73 0b                	jae    801dcb <__umoddi3+0x11b>
  801dc0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dc4:	1b 14 24             	sbb    (%esp),%edx
  801dc7:	89 d1                	mov    %edx,%ecx
  801dc9:	89 c3                	mov    %eax,%ebx
  801dcb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dcf:	29 da                	sub    %ebx,%edx
  801dd1:	19 ce                	sbb    %ecx,%esi
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 f0                	mov    %esi,%eax
  801dd7:	d3 e0                	shl    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	d3 ea                	shr    %cl,%edx
  801ddd:	89 e9                	mov    %ebp,%ecx
  801ddf:	d3 ee                	shr    %cl,%esi
  801de1:	09 d0                	or     %edx,%eax
  801de3:	89 f2                	mov    %esi,%edx
  801de5:	83 c4 1c             	add    $0x1c,%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5f                   	pop    %edi
  801deb:	5d                   	pop    %ebp
  801dec:	c3                   	ret    
  801ded:	8d 76 00             	lea    0x0(%esi),%esi
  801df0:	29 f9                	sub    %edi,%ecx
  801df2:	19 d6                	sbb    %edx,%esi
  801df4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801df8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dfc:	e9 18 ff ff ff       	jmp    801d19 <__umoddi3+0x69>
