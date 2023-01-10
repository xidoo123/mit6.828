
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 30 80 00 60 	movl   $0x802260,0x803000
  800040:	22 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 ff 00 00 00       	call   800147 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 e8 04 00 00       	call   800583 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 6f 22 80 00       	push   $0x80226f
  800114:	6a 23                	push   $0x23
  800116:	68 8c 22 80 00       	push   $0x80228c
  80011b:	e8 dc 13 00 00       	call   8014fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 6f 22 80 00       	push   $0x80226f
  800195:	6a 23                	push   $0x23
  800197:	68 8c 22 80 00       	push   $0x80228c
  80019c:	e8 5b 13 00 00       	call   8014fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 6f 22 80 00       	push   $0x80226f
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 8c 22 80 00       	push   $0x80228c
  8001de:	e8 19 13 00 00       	call   8014fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 6f 22 80 00       	push   $0x80226f
  800219:	6a 23                	push   $0x23
  80021b:	68 8c 22 80 00       	push   $0x80228c
  800220:	e8 d7 12 00 00       	call   8014fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 6f 22 80 00       	push   $0x80226f
  80025b:	6a 23                	push   $0x23
  80025d:	68 8c 22 80 00       	push   $0x80228c
  800262:	e8 95 12 00 00       	call   8014fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 6f 22 80 00       	push   $0x80226f
  80029d:	6a 23                	push   $0x23
  80029f:	68 8c 22 80 00       	push   $0x80228c
  8002a4:	e8 53 12 00 00       	call   8014fc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 6f 22 80 00       	push   $0x80226f
  8002df:	6a 23                	push   $0x23
  8002e1:	68 8c 22 80 00       	push   $0x80228c
  8002e6:	e8 11 12 00 00       	call   8014fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 6f 22 80 00       	push   $0x80226f
  800343:	6a 23                	push   $0x23
  800345:	68 8c 22 80 00       	push   $0x80228c
  80034a:	e8 ad 11 00 00       	call   8014fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	57                   	push   %edi
  80035b:	56                   	push   %esi
  80035c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	b8 0e 00 00 00       	mov    $0xe,%eax
  800367:	89 d1                	mov    %edx,%ecx
  800369:	89 d3                	mov    %edx,%ebx
  80036b:	89 d7                	mov    %edx,%edi
  80036d:	89 d6                	mov    %edx,%esi
  80036f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	57                   	push   %edi
  80037a:	56                   	push   %esi
  80037b:	53                   	push   %ebx
  80037c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800384:	b8 0f 00 00 00       	mov    $0xf,%eax
  800389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038c:	8b 55 08             	mov    0x8(%ebp),%edx
  80038f:	89 df                	mov    %ebx,%edi
  800391:	89 de                	mov    %ebx,%esi
  800393:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800395:	85 c0                	test   %eax,%eax
  800397:	7e 17                	jle    8003b0 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800399:	83 ec 0c             	sub    $0xc,%esp
  80039c:	50                   	push   %eax
  80039d:	6a 0f                	push   $0xf
  80039f:	68 6f 22 80 00       	push   $0x80226f
  8003a4:	6a 23                	push   $0x23
  8003a6:	68 8c 22 80 00       	push   $0x80228c
  8003ab:	e8 4c 11 00 00       	call   8014fc <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8003b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b3:	5b                   	pop    %ebx
  8003b4:	5e                   	pop    %esi
  8003b5:	5f                   	pop    %edi
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003be:	05 00 00 00 30       	add    $0x30000000,%eax
  8003c3:	c1 e8 0c             	shr    $0xc,%eax
}
  8003c6:	5d                   	pop    %ebp
  8003c7:	c3                   	ret    

008003c8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ce:	05 00 00 00 30       	add    $0x30000000,%eax
  8003d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003d8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003ea:	89 c2                	mov    %eax,%edx
  8003ec:	c1 ea 16             	shr    $0x16,%edx
  8003ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f6:	f6 c2 01             	test   $0x1,%dl
  8003f9:	74 11                	je     80040c <fd_alloc+0x2d>
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 0c             	shr    $0xc,%edx
  800400:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	75 09                	jne    800415 <fd_alloc+0x36>
			*fd_store = fd;
  80040c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80040e:	b8 00 00 00 00       	mov    $0x0,%eax
  800413:	eb 17                	jmp    80042c <fd_alloc+0x4d>
  800415:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80041a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80041f:	75 c9                	jne    8003ea <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800421:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800427:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    

0080042e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800434:	83 f8 1f             	cmp    $0x1f,%eax
  800437:	77 36                	ja     80046f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800439:	c1 e0 0c             	shl    $0xc,%eax
  80043c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800441:	89 c2                	mov    %eax,%edx
  800443:	c1 ea 16             	shr    $0x16,%edx
  800446:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80044d:	f6 c2 01             	test   $0x1,%dl
  800450:	74 24                	je     800476 <fd_lookup+0x48>
  800452:	89 c2                	mov    %eax,%edx
  800454:	c1 ea 0c             	shr    $0xc,%edx
  800457:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80045e:	f6 c2 01             	test   $0x1,%dl
  800461:	74 1a                	je     80047d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800463:	8b 55 0c             	mov    0xc(%ebp),%edx
  800466:	89 02                	mov    %eax,(%edx)
	return 0;
  800468:	b8 00 00 00 00       	mov    $0x0,%eax
  80046d:	eb 13                	jmp    800482 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800474:	eb 0c                	jmp    800482 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800476:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80047b:	eb 05                	jmp    800482 <fd_lookup+0x54>
  80047d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800482:	5d                   	pop    %ebp
  800483:	c3                   	ret    

00800484 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80048d:	ba 18 23 80 00       	mov    $0x802318,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800492:	eb 13                	jmp    8004a7 <dev_lookup+0x23>
  800494:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800497:	39 08                	cmp    %ecx,(%eax)
  800499:	75 0c                	jne    8004a7 <dev_lookup+0x23>
			*dev = devtab[i];
  80049b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80049e:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	eb 2e                	jmp    8004d5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004a7:	8b 02                	mov    (%edx),%eax
  8004a9:	85 c0                	test   %eax,%eax
  8004ab:	75 e7                	jne    800494 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004ad:	a1 08 40 80 00       	mov    0x804008,%eax
  8004b2:	8b 40 48             	mov    0x48(%eax),%eax
  8004b5:	83 ec 04             	sub    $0x4,%esp
  8004b8:	51                   	push   %ecx
  8004b9:	50                   	push   %eax
  8004ba:	68 9c 22 80 00       	push   $0x80229c
  8004bf:	e8 11 11 00 00       	call   8015d5 <cprintf>
	*dev = 0;
  8004c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004d5:	c9                   	leave  
  8004d6:	c3                   	ret    

008004d7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	56                   	push   %esi
  8004db:	53                   	push   %ebx
  8004dc:	83 ec 10             	sub    $0x10,%esp
  8004df:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004e8:	50                   	push   %eax
  8004e9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004ef:	c1 e8 0c             	shr    $0xc,%eax
  8004f2:	50                   	push   %eax
  8004f3:	e8 36 ff ff ff       	call   80042e <fd_lookup>
  8004f8:	83 c4 08             	add    $0x8,%esp
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	78 05                	js     800504 <fd_close+0x2d>
	    || fd != fd2)
  8004ff:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800502:	74 0c                	je     800510 <fd_close+0x39>
		return (must_exist ? r : 0);
  800504:	84 db                	test   %bl,%bl
  800506:	ba 00 00 00 00       	mov    $0x0,%edx
  80050b:	0f 44 c2             	cmove  %edx,%eax
  80050e:	eb 41                	jmp    800551 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800516:	50                   	push   %eax
  800517:	ff 36                	pushl  (%esi)
  800519:	e8 66 ff ff ff       	call   800484 <dev_lookup>
  80051e:	89 c3                	mov    %eax,%ebx
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	85 c0                	test   %eax,%eax
  800525:	78 1a                	js     800541 <fd_close+0x6a>
		if (dev->dev_close)
  800527:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80052a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80052d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800532:	85 c0                	test   %eax,%eax
  800534:	74 0b                	je     800541 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800536:	83 ec 0c             	sub    $0xc,%esp
  800539:	56                   	push   %esi
  80053a:	ff d0                	call   *%eax
  80053c:	89 c3                	mov    %eax,%ebx
  80053e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	56                   	push   %esi
  800545:	6a 00                	push   $0x0
  800547:	e8 9f fc ff ff       	call   8001eb <sys_page_unmap>
	return r;
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	89 d8                	mov    %ebx,%eax
}
  800551:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800554:	5b                   	pop    %ebx
  800555:	5e                   	pop    %esi
  800556:	5d                   	pop    %ebp
  800557:	c3                   	ret    

00800558 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800558:	55                   	push   %ebp
  800559:	89 e5                	mov    %esp,%ebp
  80055b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80055e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800561:	50                   	push   %eax
  800562:	ff 75 08             	pushl  0x8(%ebp)
  800565:	e8 c4 fe ff ff       	call   80042e <fd_lookup>
  80056a:	83 c4 08             	add    $0x8,%esp
  80056d:	85 c0                	test   %eax,%eax
  80056f:	78 10                	js     800581 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	6a 01                	push   $0x1
  800576:	ff 75 f4             	pushl  -0xc(%ebp)
  800579:	e8 59 ff ff ff       	call   8004d7 <fd_close>
  80057e:	83 c4 10             	add    $0x10,%esp
}
  800581:	c9                   	leave  
  800582:	c3                   	ret    

00800583 <close_all>:

void
close_all(void)
{
  800583:	55                   	push   %ebp
  800584:	89 e5                	mov    %esp,%ebp
  800586:	53                   	push   %ebx
  800587:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80058a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80058f:	83 ec 0c             	sub    $0xc,%esp
  800592:	53                   	push   %ebx
  800593:	e8 c0 ff ff ff       	call   800558 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800598:	83 c3 01             	add    $0x1,%ebx
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	83 fb 20             	cmp    $0x20,%ebx
  8005a1:	75 ec                	jne    80058f <close_all+0xc>
		close(i);
}
  8005a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005a6:	c9                   	leave  
  8005a7:	c3                   	ret    

008005a8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005a8:	55                   	push   %ebp
  8005a9:	89 e5                	mov    %esp,%ebp
  8005ab:	57                   	push   %edi
  8005ac:	56                   	push   %esi
  8005ad:	53                   	push   %ebx
  8005ae:	83 ec 2c             	sub    $0x2c,%esp
  8005b1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005b7:	50                   	push   %eax
  8005b8:	ff 75 08             	pushl  0x8(%ebp)
  8005bb:	e8 6e fe ff ff       	call   80042e <fd_lookup>
  8005c0:	83 c4 08             	add    $0x8,%esp
  8005c3:	85 c0                	test   %eax,%eax
  8005c5:	0f 88 c1 00 00 00    	js     80068c <dup+0xe4>
		return r;
	close(newfdnum);
  8005cb:	83 ec 0c             	sub    $0xc,%esp
  8005ce:	56                   	push   %esi
  8005cf:	e8 84 ff ff ff       	call   800558 <close>

	newfd = INDEX2FD(newfdnum);
  8005d4:	89 f3                	mov    %esi,%ebx
  8005d6:	c1 e3 0c             	shl    $0xc,%ebx
  8005d9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005df:	83 c4 04             	add    $0x4,%esp
  8005e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005e5:	e8 de fd ff ff       	call   8003c8 <fd2data>
  8005ea:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005ec:	89 1c 24             	mov    %ebx,(%esp)
  8005ef:	e8 d4 fd ff ff       	call   8003c8 <fd2data>
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005fa:	89 f8                	mov    %edi,%eax
  8005fc:	c1 e8 16             	shr    $0x16,%eax
  8005ff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800606:	a8 01                	test   $0x1,%al
  800608:	74 37                	je     800641 <dup+0x99>
  80060a:	89 f8                	mov    %edi,%eax
  80060c:	c1 e8 0c             	shr    $0xc,%eax
  80060f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800616:	f6 c2 01             	test   $0x1,%dl
  800619:	74 26                	je     800641 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80061b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800622:	83 ec 0c             	sub    $0xc,%esp
  800625:	25 07 0e 00 00       	and    $0xe07,%eax
  80062a:	50                   	push   %eax
  80062b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80062e:	6a 00                	push   $0x0
  800630:	57                   	push   %edi
  800631:	6a 00                	push   $0x0
  800633:	e8 71 fb ff ff       	call   8001a9 <sys_page_map>
  800638:	89 c7                	mov    %eax,%edi
  80063a:	83 c4 20             	add    $0x20,%esp
  80063d:	85 c0                	test   %eax,%eax
  80063f:	78 2e                	js     80066f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800641:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800644:	89 d0                	mov    %edx,%eax
  800646:	c1 e8 0c             	shr    $0xc,%eax
  800649:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800650:	83 ec 0c             	sub    $0xc,%esp
  800653:	25 07 0e 00 00       	and    $0xe07,%eax
  800658:	50                   	push   %eax
  800659:	53                   	push   %ebx
  80065a:	6a 00                	push   $0x0
  80065c:	52                   	push   %edx
  80065d:	6a 00                	push   $0x0
  80065f:	e8 45 fb ff ff       	call   8001a9 <sys_page_map>
  800664:	89 c7                	mov    %eax,%edi
  800666:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800669:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80066b:	85 ff                	test   %edi,%edi
  80066d:	79 1d                	jns    80068c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 00                	push   $0x0
  800675:	e8 71 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  80067a:	83 c4 08             	add    $0x8,%esp
  80067d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800680:	6a 00                	push   $0x0
  800682:	e8 64 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	89 f8                	mov    %edi,%eax
}
  80068c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80068f:	5b                   	pop    %ebx
  800690:	5e                   	pop    %esi
  800691:	5f                   	pop    %edi
  800692:	5d                   	pop    %ebp
  800693:	c3                   	ret    

00800694 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800694:	55                   	push   %ebp
  800695:	89 e5                	mov    %esp,%ebp
  800697:	53                   	push   %ebx
  800698:	83 ec 14             	sub    $0x14,%esp
  80069b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80069e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006a1:	50                   	push   %eax
  8006a2:	53                   	push   %ebx
  8006a3:	e8 86 fd ff ff       	call   80042e <fd_lookup>
  8006a8:	83 c4 08             	add    $0x8,%esp
  8006ab:	89 c2                	mov    %eax,%edx
  8006ad:	85 c0                	test   %eax,%eax
  8006af:	78 6d                	js     80071e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006b7:	50                   	push   %eax
  8006b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006bb:	ff 30                	pushl  (%eax)
  8006bd:	e8 c2 fd ff ff       	call   800484 <dev_lookup>
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	85 c0                	test   %eax,%eax
  8006c7:	78 4c                	js     800715 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006cc:	8b 42 08             	mov    0x8(%edx),%eax
  8006cf:	83 e0 03             	and    $0x3,%eax
  8006d2:	83 f8 01             	cmp    $0x1,%eax
  8006d5:	75 21                	jne    8006f8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006d7:	a1 08 40 80 00       	mov    0x804008,%eax
  8006dc:	8b 40 48             	mov    0x48(%eax),%eax
  8006df:	83 ec 04             	sub    $0x4,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	50                   	push   %eax
  8006e4:	68 dd 22 80 00       	push   $0x8022dd
  8006e9:	e8 e7 0e 00 00       	call   8015d5 <cprintf>
		return -E_INVAL;
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006f6:	eb 26                	jmp    80071e <read+0x8a>
	}
	if (!dev->dev_read)
  8006f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fb:	8b 40 08             	mov    0x8(%eax),%eax
  8006fe:	85 c0                	test   %eax,%eax
  800700:	74 17                	je     800719 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800702:	83 ec 04             	sub    $0x4,%esp
  800705:	ff 75 10             	pushl  0x10(%ebp)
  800708:	ff 75 0c             	pushl  0xc(%ebp)
  80070b:	52                   	push   %edx
  80070c:	ff d0                	call   *%eax
  80070e:	89 c2                	mov    %eax,%edx
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	eb 09                	jmp    80071e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800715:	89 c2                	mov    %eax,%edx
  800717:	eb 05                	jmp    80071e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800719:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80071e:	89 d0                	mov    %edx,%eax
  800720:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800723:	c9                   	leave  
  800724:	c3                   	ret    

00800725 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	57                   	push   %edi
  800729:	56                   	push   %esi
  80072a:	53                   	push   %ebx
  80072b:	83 ec 0c             	sub    $0xc,%esp
  80072e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800731:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800734:	bb 00 00 00 00       	mov    $0x0,%ebx
  800739:	eb 21                	jmp    80075c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80073b:	83 ec 04             	sub    $0x4,%esp
  80073e:	89 f0                	mov    %esi,%eax
  800740:	29 d8                	sub    %ebx,%eax
  800742:	50                   	push   %eax
  800743:	89 d8                	mov    %ebx,%eax
  800745:	03 45 0c             	add    0xc(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	57                   	push   %edi
  80074a:	e8 45 ff ff ff       	call   800694 <read>
		if (m < 0)
  80074f:	83 c4 10             	add    $0x10,%esp
  800752:	85 c0                	test   %eax,%eax
  800754:	78 10                	js     800766 <readn+0x41>
			return m;
		if (m == 0)
  800756:	85 c0                	test   %eax,%eax
  800758:	74 0a                	je     800764 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80075a:	01 c3                	add    %eax,%ebx
  80075c:	39 f3                	cmp    %esi,%ebx
  80075e:	72 db                	jb     80073b <readn+0x16>
  800760:	89 d8                	mov    %ebx,%eax
  800762:	eb 02                	jmp    800766 <readn+0x41>
  800764:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800766:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800769:	5b                   	pop    %ebx
  80076a:	5e                   	pop    %esi
  80076b:	5f                   	pop    %edi
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	53                   	push   %ebx
  800772:	83 ec 14             	sub    $0x14,%esp
  800775:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800778:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80077b:	50                   	push   %eax
  80077c:	53                   	push   %ebx
  80077d:	e8 ac fc ff ff       	call   80042e <fd_lookup>
  800782:	83 c4 08             	add    $0x8,%esp
  800785:	89 c2                	mov    %eax,%edx
  800787:	85 c0                	test   %eax,%eax
  800789:	78 68                	js     8007f3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800795:	ff 30                	pushl  (%eax)
  800797:	e8 e8 fc ff ff       	call   800484 <dev_lookup>
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	85 c0                	test   %eax,%eax
  8007a1:	78 47                	js     8007ea <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007aa:	75 21                	jne    8007cd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007ac:	a1 08 40 80 00       	mov    0x804008,%eax
  8007b1:	8b 40 48             	mov    0x48(%eax),%eax
  8007b4:	83 ec 04             	sub    $0x4,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	50                   	push   %eax
  8007b9:	68 f9 22 80 00       	push   $0x8022f9
  8007be:	e8 12 0e 00 00       	call   8015d5 <cprintf>
		return -E_INVAL;
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007cb:	eb 26                	jmp    8007f3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	74 17                	je     8007ee <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007d7:	83 ec 04             	sub    $0x4,%esp
  8007da:	ff 75 10             	pushl  0x10(%ebp)
  8007dd:	ff 75 0c             	pushl  0xc(%ebp)
  8007e0:	50                   	push   %eax
  8007e1:	ff d2                	call   *%edx
  8007e3:	89 c2                	mov    %eax,%edx
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 09                	jmp    8007f3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ea:	89 c2                	mov    %eax,%edx
  8007ec:	eb 05                	jmp    8007f3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007f3:	89 d0                	mov    %edx,%eax
  8007f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <seek>:

int
seek(int fdnum, off_t offset)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800800:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800803:	50                   	push   %eax
  800804:	ff 75 08             	pushl  0x8(%ebp)
  800807:	e8 22 fc ff ff       	call   80042e <fd_lookup>
  80080c:	83 c4 08             	add    $0x8,%esp
  80080f:	85 c0                	test   %eax,%eax
  800811:	78 0e                	js     800821 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800813:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
  800819:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80081c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	83 ec 14             	sub    $0x14,%esp
  80082a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800830:	50                   	push   %eax
  800831:	53                   	push   %ebx
  800832:	e8 f7 fb ff ff       	call   80042e <fd_lookup>
  800837:	83 c4 08             	add    $0x8,%esp
  80083a:	89 c2                	mov    %eax,%edx
  80083c:	85 c0                	test   %eax,%eax
  80083e:	78 65                	js     8008a5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800840:	83 ec 08             	sub    $0x8,%esp
  800843:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800846:	50                   	push   %eax
  800847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084a:	ff 30                	pushl  (%eax)
  80084c:	e8 33 fc ff ff       	call   800484 <dev_lookup>
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	85 c0                	test   %eax,%eax
  800856:	78 44                	js     80089c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800858:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80085f:	75 21                	jne    800882 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800861:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800866:	8b 40 48             	mov    0x48(%eax),%eax
  800869:	83 ec 04             	sub    $0x4,%esp
  80086c:	53                   	push   %ebx
  80086d:	50                   	push   %eax
  80086e:	68 bc 22 80 00       	push   $0x8022bc
  800873:	e8 5d 0d 00 00       	call   8015d5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800880:	eb 23                	jmp    8008a5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800882:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800885:	8b 52 18             	mov    0x18(%edx),%edx
  800888:	85 d2                	test   %edx,%edx
  80088a:	74 14                	je     8008a0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80088c:	83 ec 08             	sub    $0x8,%esp
  80088f:	ff 75 0c             	pushl  0xc(%ebp)
  800892:	50                   	push   %eax
  800893:	ff d2                	call   *%edx
  800895:	89 c2                	mov    %eax,%edx
  800897:	83 c4 10             	add    $0x10,%esp
  80089a:	eb 09                	jmp    8008a5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089c:	89 c2                	mov    %eax,%edx
  80089e:	eb 05                	jmp    8008a5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008a5:	89 d0                	mov    %edx,%eax
  8008a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008aa:	c9                   	leave  
  8008ab:	c3                   	ret    

008008ac <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	83 ec 14             	sub    $0x14,%esp
  8008b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b9:	50                   	push   %eax
  8008ba:	ff 75 08             	pushl  0x8(%ebp)
  8008bd:	e8 6c fb ff ff       	call   80042e <fd_lookup>
  8008c2:	83 c4 08             	add    $0x8,%esp
  8008c5:	89 c2                	mov    %eax,%edx
  8008c7:	85 c0                	test   %eax,%eax
  8008c9:	78 58                	js     800923 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008d1:	50                   	push   %eax
  8008d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d5:	ff 30                	pushl  (%eax)
  8008d7:	e8 a8 fb ff ff       	call   800484 <dev_lookup>
  8008dc:	83 c4 10             	add    $0x10,%esp
  8008df:	85 c0                	test   %eax,%eax
  8008e1:	78 37                	js     80091a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ea:	74 32                	je     80091e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008ec:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008ef:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008f6:	00 00 00 
	stat->st_isdir = 0;
  8008f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800900:	00 00 00 
	stat->st_dev = dev;
  800903:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800909:	83 ec 08             	sub    $0x8,%esp
  80090c:	53                   	push   %ebx
  80090d:	ff 75 f0             	pushl  -0x10(%ebp)
  800910:	ff 50 14             	call   *0x14(%eax)
  800913:	89 c2                	mov    %eax,%edx
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	eb 09                	jmp    800923 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80091a:	89 c2                	mov    %eax,%edx
  80091c:	eb 05                	jmp    800923 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80091e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800923:	89 d0                	mov    %edx,%eax
  800925:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80092f:	83 ec 08             	sub    $0x8,%esp
  800932:	6a 00                	push   $0x0
  800934:	ff 75 08             	pushl  0x8(%ebp)
  800937:	e8 d6 01 00 00       	call   800b12 <open>
  80093c:	89 c3                	mov    %eax,%ebx
  80093e:	83 c4 10             	add    $0x10,%esp
  800941:	85 c0                	test   %eax,%eax
  800943:	78 1b                	js     800960 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800945:	83 ec 08             	sub    $0x8,%esp
  800948:	ff 75 0c             	pushl  0xc(%ebp)
  80094b:	50                   	push   %eax
  80094c:	e8 5b ff ff ff       	call   8008ac <fstat>
  800951:	89 c6                	mov    %eax,%esi
	close(fd);
  800953:	89 1c 24             	mov    %ebx,(%esp)
  800956:	e8 fd fb ff ff       	call   800558 <close>
	return r;
  80095b:	83 c4 10             	add    $0x10,%esp
  80095e:	89 f0                	mov    %esi,%eax
}
  800960:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	56                   	push   %esi
  80096b:	53                   	push   %ebx
  80096c:	89 c6                	mov    %eax,%esi
  80096e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800970:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800977:	75 12                	jne    80098b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800979:	83 ec 0c             	sub    $0xc,%esp
  80097c:	6a 01                	push   $0x1
  80097e:	e8 d9 15 00 00       	call   801f5c <ipc_find_env>
  800983:	a3 00 40 80 00       	mov    %eax,0x804000
  800988:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80098b:	6a 07                	push   $0x7
  80098d:	68 00 50 80 00       	push   $0x805000
  800992:	56                   	push   %esi
  800993:	ff 35 00 40 80 00    	pushl  0x804000
  800999:	e8 6a 15 00 00       	call   801f08 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80099e:	83 c4 0c             	add    $0xc,%esp
  8009a1:	6a 00                	push   $0x0
  8009a3:	53                   	push   %ebx
  8009a4:	6a 00                	push   $0x0
  8009a6:	e8 f6 14 00 00       	call   801ea1 <ipc_recv>
}
  8009ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8009be:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8009d5:	e8 8d ff ff ff       	call   800967 <fsipc>
}
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8009f7:	e8 6b ff ff ff       	call   800967 <fsipc>
}
  8009fc:	c9                   	leave  
  8009fd:	c3                   	ret    

008009fe <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	53                   	push   %ebx
  800a02:	83 ec 04             	sub    $0x4,%esp
  800a05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a13:	ba 00 00 00 00       	mov    $0x0,%edx
  800a18:	b8 05 00 00 00       	mov    $0x5,%eax
  800a1d:	e8 45 ff ff ff       	call   800967 <fsipc>
  800a22:	85 c0                	test   %eax,%eax
  800a24:	78 2c                	js     800a52 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a26:	83 ec 08             	sub    $0x8,%esp
  800a29:	68 00 50 80 00       	push   $0x805000
  800a2e:	53                   	push   %ebx
  800a2f:	e8 26 11 00 00       	call   801b5a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a34:	a1 80 50 80 00       	mov    0x805080,%eax
  800a39:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a3f:	a1 84 50 80 00       	mov    0x805084,%eax
  800a44:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a4a:	83 c4 10             	add    $0x10,%esp
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	83 ec 0c             	sub    $0xc,%esp
  800a5d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a60:	8b 55 08             	mov    0x8(%ebp),%edx
  800a63:	8b 52 0c             	mov    0xc(%edx),%edx
  800a66:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a6c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a71:	50                   	push   %eax
  800a72:	ff 75 0c             	pushl  0xc(%ebp)
  800a75:	68 08 50 80 00       	push   $0x805008
  800a7a:	e8 6d 12 00 00       	call   801cec <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a84:	b8 04 00 00 00       	mov    $0x4,%eax
  800a89:	e8 d9 fe ff ff       	call   800967 <fsipc>

}
  800a8e:	c9                   	leave  
  800a8f:	c3                   	ret    

00800a90 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
  800a95:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a9e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aa3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aae:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab3:	e8 af fe ff ff       	call   800967 <fsipc>
  800ab8:	89 c3                	mov    %eax,%ebx
  800aba:	85 c0                	test   %eax,%eax
  800abc:	78 4b                	js     800b09 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800abe:	39 c6                	cmp    %eax,%esi
  800ac0:	73 16                	jae    800ad8 <devfile_read+0x48>
  800ac2:	68 2c 23 80 00       	push   $0x80232c
  800ac7:	68 33 23 80 00       	push   $0x802333
  800acc:	6a 7c                	push   $0x7c
  800ace:	68 48 23 80 00       	push   $0x802348
  800ad3:	e8 24 0a 00 00       	call   8014fc <_panic>
	assert(r <= PGSIZE);
  800ad8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800add:	7e 16                	jle    800af5 <devfile_read+0x65>
  800adf:	68 53 23 80 00       	push   $0x802353
  800ae4:	68 33 23 80 00       	push   $0x802333
  800ae9:	6a 7d                	push   $0x7d
  800aeb:	68 48 23 80 00       	push   $0x802348
  800af0:	e8 07 0a 00 00       	call   8014fc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800af5:	83 ec 04             	sub    $0x4,%esp
  800af8:	50                   	push   %eax
  800af9:	68 00 50 80 00       	push   $0x805000
  800afe:	ff 75 0c             	pushl  0xc(%ebp)
  800b01:	e8 e6 11 00 00       	call   801cec <memmove>
	return r;
  800b06:	83 c4 10             	add    $0x10,%esp
}
  800b09:	89 d8                	mov    %ebx,%eax
  800b0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	53                   	push   %ebx
  800b16:	83 ec 20             	sub    $0x20,%esp
  800b19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b1c:	53                   	push   %ebx
  800b1d:	e8 ff 0f 00 00       	call   801b21 <strlen>
  800b22:	83 c4 10             	add    $0x10,%esp
  800b25:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b2a:	7f 67                	jg     800b93 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2c:	83 ec 0c             	sub    $0xc,%esp
  800b2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b32:	50                   	push   %eax
  800b33:	e8 a7 f8 ff ff       	call   8003df <fd_alloc>
  800b38:	83 c4 10             	add    $0x10,%esp
		return r;
  800b3b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	78 57                	js     800b98 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b41:	83 ec 08             	sub    $0x8,%esp
  800b44:	53                   	push   %ebx
  800b45:	68 00 50 80 00       	push   $0x805000
  800b4a:	e8 0b 10 00 00       	call   801b5a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b52:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b57:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5f:	e8 03 fe ff ff       	call   800967 <fsipc>
  800b64:	89 c3                	mov    %eax,%ebx
  800b66:	83 c4 10             	add    $0x10,%esp
  800b69:	85 c0                	test   %eax,%eax
  800b6b:	79 14                	jns    800b81 <open+0x6f>
		fd_close(fd, 0);
  800b6d:	83 ec 08             	sub    $0x8,%esp
  800b70:	6a 00                	push   $0x0
  800b72:	ff 75 f4             	pushl  -0xc(%ebp)
  800b75:	e8 5d f9 ff ff       	call   8004d7 <fd_close>
		return r;
  800b7a:	83 c4 10             	add    $0x10,%esp
  800b7d:	89 da                	mov    %ebx,%edx
  800b7f:	eb 17                	jmp    800b98 <open+0x86>
	}

	return fd2num(fd);
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	ff 75 f4             	pushl  -0xc(%ebp)
  800b87:	e8 2c f8 ff ff       	call   8003b8 <fd2num>
  800b8c:	89 c2                	mov    %eax,%edx
  800b8e:	83 c4 10             	add    $0x10,%esp
  800b91:	eb 05                	jmp    800b98 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b93:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b98:	89 d0                	mov    %edx,%eax
  800b9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  800baa:	b8 08 00 00 00       	mov    $0x8,%eax
  800baf:	e8 b3 fd ff ff       	call   800967 <fsipc>
}
  800bb4:	c9                   	leave  
  800bb5:	c3                   	ret    

00800bb6 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bbc:	68 5f 23 80 00       	push   $0x80235f
  800bc1:	ff 75 0c             	pushl  0xc(%ebp)
  800bc4:	e8 91 0f 00 00       	call   801b5a <strcpy>
	return 0;
}
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bce:	c9                   	leave  
  800bcf:	c3                   	ret    

00800bd0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 10             	sub    $0x10,%esp
  800bd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bda:	53                   	push   %ebx
  800bdb:	e8 b5 13 00 00       	call   801f95 <pageref>
  800be0:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800be3:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800be8:	83 f8 01             	cmp    $0x1,%eax
  800beb:	75 10                	jne    800bfd <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	ff 73 0c             	pushl  0xc(%ebx)
  800bf3:	e8 c0 02 00 00       	call   800eb8 <nsipc_close>
  800bf8:	89 c2                	mov    %eax,%edx
  800bfa:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bfd:	89 d0                	mov    %edx,%eax
  800bff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c02:	c9                   	leave  
  800c03:	c3                   	ret    

00800c04 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c0a:	6a 00                	push   $0x0
  800c0c:	ff 75 10             	pushl  0x10(%ebp)
  800c0f:	ff 75 0c             	pushl  0xc(%ebp)
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
  800c15:	ff 70 0c             	pushl  0xc(%eax)
  800c18:	e8 78 03 00 00       	call   800f95 <nsipc_send>
}
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c25:	6a 00                	push   $0x0
  800c27:	ff 75 10             	pushl  0x10(%ebp)
  800c2a:	ff 75 0c             	pushl  0xc(%ebp)
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c30:	ff 70 0c             	pushl  0xc(%eax)
  800c33:	e8 f1 02 00 00       	call   800f29 <nsipc_recv>
}
  800c38:	c9                   	leave  
  800c39:	c3                   	ret    

00800c3a <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c40:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c43:	52                   	push   %edx
  800c44:	50                   	push   %eax
  800c45:	e8 e4 f7 ff ff       	call   80042e <fd_lookup>
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	78 17                	js     800c68 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c54:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c5a:	39 08                	cmp    %ecx,(%eax)
  800c5c:	75 05                	jne    800c63 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c5e:	8b 40 0c             	mov    0xc(%eax),%eax
  800c61:	eb 05                	jmp    800c68 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c63:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c68:	c9                   	leave  
  800c69:	c3                   	ret    

00800c6a <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 1c             	sub    $0x1c,%esp
  800c72:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c77:	50                   	push   %eax
  800c78:	e8 62 f7 ff ff       	call   8003df <fd_alloc>
  800c7d:	89 c3                	mov    %eax,%ebx
  800c7f:	83 c4 10             	add    $0x10,%esp
  800c82:	85 c0                	test   %eax,%eax
  800c84:	78 1b                	js     800ca1 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c86:	83 ec 04             	sub    $0x4,%esp
  800c89:	68 07 04 00 00       	push   $0x407
  800c8e:	ff 75 f4             	pushl  -0xc(%ebp)
  800c91:	6a 00                	push   $0x0
  800c93:	e8 ce f4 ff ff       	call   800166 <sys_page_alloc>
  800c98:	89 c3                	mov    %eax,%ebx
  800c9a:	83 c4 10             	add    $0x10,%esp
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	79 10                	jns    800cb1 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800ca1:	83 ec 0c             	sub    $0xc,%esp
  800ca4:	56                   	push   %esi
  800ca5:	e8 0e 02 00 00       	call   800eb8 <nsipc_close>
		return r;
  800caa:	83 c4 10             	add    $0x10,%esp
  800cad:	89 d8                	mov    %ebx,%eax
  800caf:	eb 24                	jmp    800cd5 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800cb1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cba:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cbf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cc6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	e8 e6 f6 ff ff       	call   8003b8 <fd2num>
  800cd2:	83 c4 10             	add    $0x10,%esp
}
  800cd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce5:	e8 50 ff ff ff       	call   800c3a <fd2sockid>
		return r;
  800cea:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	78 1f                	js     800d0f <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cf0:	83 ec 04             	sub    $0x4,%esp
  800cf3:	ff 75 10             	pushl  0x10(%ebp)
  800cf6:	ff 75 0c             	pushl  0xc(%ebp)
  800cf9:	50                   	push   %eax
  800cfa:	e8 12 01 00 00       	call   800e11 <nsipc_accept>
  800cff:	83 c4 10             	add    $0x10,%esp
		return r;
  800d02:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	78 07                	js     800d0f <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d08:	e8 5d ff ff ff       	call   800c6a <alloc_sockfd>
  800d0d:	89 c1                	mov    %eax,%ecx
}
  800d0f:	89 c8                	mov    %ecx,%eax
  800d11:	c9                   	leave  
  800d12:	c3                   	ret    

00800d13 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	e8 19 ff ff ff       	call   800c3a <fd2sockid>
  800d21:	85 c0                	test   %eax,%eax
  800d23:	78 12                	js     800d37 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d25:	83 ec 04             	sub    $0x4,%esp
  800d28:	ff 75 10             	pushl  0x10(%ebp)
  800d2b:	ff 75 0c             	pushl  0xc(%ebp)
  800d2e:	50                   	push   %eax
  800d2f:	e8 2d 01 00 00       	call   800e61 <nsipc_bind>
  800d34:	83 c4 10             	add    $0x10,%esp
}
  800d37:	c9                   	leave  
  800d38:	c3                   	ret    

00800d39 <shutdown>:

int
shutdown(int s, int how)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	e8 f3 fe ff ff       	call   800c3a <fd2sockid>
  800d47:	85 c0                	test   %eax,%eax
  800d49:	78 0f                	js     800d5a <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d4b:	83 ec 08             	sub    $0x8,%esp
  800d4e:	ff 75 0c             	pushl  0xc(%ebp)
  800d51:	50                   	push   %eax
  800d52:	e8 3f 01 00 00       	call   800e96 <nsipc_shutdown>
  800d57:	83 c4 10             	add    $0x10,%esp
}
  800d5a:	c9                   	leave  
  800d5b:	c3                   	ret    

00800d5c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
  800d65:	e8 d0 fe ff ff       	call   800c3a <fd2sockid>
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	78 12                	js     800d80 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d6e:	83 ec 04             	sub    $0x4,%esp
  800d71:	ff 75 10             	pushl  0x10(%ebp)
  800d74:	ff 75 0c             	pushl  0xc(%ebp)
  800d77:	50                   	push   %eax
  800d78:	e8 55 01 00 00       	call   800ed2 <nsipc_connect>
  800d7d:	83 c4 10             	add    $0x10,%esp
}
  800d80:	c9                   	leave  
  800d81:	c3                   	ret    

00800d82 <listen>:

int
listen(int s, int backlog)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	e8 aa fe ff ff       	call   800c3a <fd2sockid>
  800d90:	85 c0                	test   %eax,%eax
  800d92:	78 0f                	js     800da3 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d94:	83 ec 08             	sub    $0x8,%esp
  800d97:	ff 75 0c             	pushl  0xc(%ebp)
  800d9a:	50                   	push   %eax
  800d9b:	e8 67 01 00 00       	call   800f07 <nsipc_listen>
  800da0:	83 c4 10             	add    $0x10,%esp
}
  800da3:	c9                   	leave  
  800da4:	c3                   	ret    

00800da5 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800dab:	ff 75 10             	pushl  0x10(%ebp)
  800dae:	ff 75 0c             	pushl  0xc(%ebp)
  800db1:	ff 75 08             	pushl  0x8(%ebp)
  800db4:	e8 3a 02 00 00       	call   800ff3 <nsipc_socket>
  800db9:	83 c4 10             	add    $0x10,%esp
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	78 05                	js     800dc5 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dc0:	e8 a5 fe ff ff       	call   800c6a <alloc_sockfd>
}
  800dc5:	c9                   	leave  
  800dc6:	c3                   	ret    

00800dc7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	53                   	push   %ebx
  800dcb:	83 ec 04             	sub    $0x4,%esp
  800dce:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dd0:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dd7:	75 12                	jne    800deb <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	6a 02                	push   $0x2
  800dde:	e8 79 11 00 00       	call   801f5c <ipc_find_env>
  800de3:	a3 04 40 80 00       	mov    %eax,0x804004
  800de8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800deb:	6a 07                	push   $0x7
  800ded:	68 00 60 80 00       	push   $0x806000
  800df2:	53                   	push   %ebx
  800df3:	ff 35 04 40 80 00    	pushl  0x804004
  800df9:	e8 0a 11 00 00       	call   801f08 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dfe:	83 c4 0c             	add    $0xc,%esp
  800e01:	6a 00                	push   $0x0
  800e03:	6a 00                	push   $0x0
  800e05:	6a 00                	push   $0x0
  800e07:	e8 95 10 00 00       	call   801ea1 <ipc_recv>
}
  800e0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e0f:	c9                   	leave  
  800e10:	c3                   	ret    

00800e11 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e19:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e21:	8b 06                	mov    (%esi),%eax
  800e23:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e28:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2d:	e8 95 ff ff ff       	call   800dc7 <nsipc>
  800e32:	89 c3                	mov    %eax,%ebx
  800e34:	85 c0                	test   %eax,%eax
  800e36:	78 20                	js     800e58 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e38:	83 ec 04             	sub    $0x4,%esp
  800e3b:	ff 35 10 60 80 00    	pushl  0x806010
  800e41:	68 00 60 80 00       	push   $0x806000
  800e46:	ff 75 0c             	pushl  0xc(%ebp)
  800e49:	e8 9e 0e 00 00       	call   801cec <memmove>
		*addrlen = ret->ret_addrlen;
  800e4e:	a1 10 60 80 00       	mov    0x806010,%eax
  800e53:	89 06                	mov    %eax,(%esi)
  800e55:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e58:	89 d8                	mov    %ebx,%eax
  800e5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	53                   	push   %ebx
  800e65:	83 ec 08             	sub    $0x8,%esp
  800e68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e73:	53                   	push   %ebx
  800e74:	ff 75 0c             	pushl  0xc(%ebp)
  800e77:	68 04 60 80 00       	push   $0x806004
  800e7c:	e8 6b 0e 00 00       	call   801cec <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e81:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e87:	b8 02 00 00 00       	mov    $0x2,%eax
  800e8c:	e8 36 ff ff ff       	call   800dc7 <nsipc>
}
  800e91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    

00800e96 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800eac:	b8 03 00 00 00       	mov    $0x3,%eax
  800eb1:	e8 11 ff ff ff       	call   800dc7 <nsipc>
}
  800eb6:	c9                   	leave  
  800eb7:	c3                   	ret    

00800eb8 <nsipc_close>:

int
nsipc_close(int s)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ebe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec1:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ec6:	b8 04 00 00 00       	mov    $0x4,%eax
  800ecb:	e8 f7 fe ff ff       	call   800dc7 <nsipc>
}
  800ed0:	c9                   	leave  
  800ed1:	c3                   	ret    

00800ed2 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 08             	sub    $0x8,%esp
  800ed9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800edc:	8b 45 08             	mov    0x8(%ebp),%eax
  800edf:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ee4:	53                   	push   %ebx
  800ee5:	ff 75 0c             	pushl  0xc(%ebp)
  800ee8:	68 04 60 80 00       	push   $0x806004
  800eed:	e8 fa 0d 00 00       	call   801cec <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ef2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ef8:	b8 05 00 00 00       	mov    $0x5,%eax
  800efd:	e8 c5 fe ff ff       	call   800dc7 <nsipc>
}
  800f02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    

00800f07 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f10:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f18:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f1d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f22:	e8 a0 fe ff ff       	call   800dc7 <nsipc>
}
  800f27:	c9                   	leave  
  800f28:	c3                   	ret    

00800f29 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
  800f2e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f31:	8b 45 08             	mov    0x8(%ebp),%eax
  800f34:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f39:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f3f:	8b 45 14             	mov    0x14(%ebp),%eax
  800f42:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f47:	b8 07 00 00 00       	mov    $0x7,%eax
  800f4c:	e8 76 fe ff ff       	call   800dc7 <nsipc>
  800f51:	89 c3                	mov    %eax,%ebx
  800f53:	85 c0                	test   %eax,%eax
  800f55:	78 35                	js     800f8c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f57:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f5c:	7f 04                	jg     800f62 <nsipc_recv+0x39>
  800f5e:	39 c6                	cmp    %eax,%esi
  800f60:	7d 16                	jge    800f78 <nsipc_recv+0x4f>
  800f62:	68 6b 23 80 00       	push   $0x80236b
  800f67:	68 33 23 80 00       	push   $0x802333
  800f6c:	6a 62                	push   $0x62
  800f6e:	68 80 23 80 00       	push   $0x802380
  800f73:	e8 84 05 00 00       	call   8014fc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f78:	83 ec 04             	sub    $0x4,%esp
  800f7b:	50                   	push   %eax
  800f7c:	68 00 60 80 00       	push   $0x806000
  800f81:	ff 75 0c             	pushl  0xc(%ebp)
  800f84:	e8 63 0d 00 00       	call   801cec <memmove>
  800f89:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f8c:	89 d8                	mov    %ebx,%eax
  800f8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	53                   	push   %ebx
  800f99:	83 ec 04             	sub    $0x4,%esp
  800f9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa2:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fa7:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fad:	7e 16                	jle    800fc5 <nsipc_send+0x30>
  800faf:	68 8c 23 80 00       	push   $0x80238c
  800fb4:	68 33 23 80 00       	push   $0x802333
  800fb9:	6a 6d                	push   $0x6d
  800fbb:	68 80 23 80 00       	push   $0x802380
  800fc0:	e8 37 05 00 00       	call   8014fc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fc5:	83 ec 04             	sub    $0x4,%esp
  800fc8:	53                   	push   %ebx
  800fc9:	ff 75 0c             	pushl  0xc(%ebp)
  800fcc:	68 0c 60 80 00       	push   $0x80600c
  800fd1:	e8 16 0d 00 00       	call   801cec <memmove>
	nsipcbuf.send.req_size = size;
  800fd6:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fdc:	8b 45 14             	mov    0x14(%ebp),%eax
  800fdf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fe4:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe9:	e8 d9 fd ff ff       	call   800dc7 <nsipc>
}
  800fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800ff9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801001:	8b 45 0c             	mov    0xc(%ebp),%eax
  801004:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801009:	8b 45 10             	mov    0x10(%ebp),%eax
  80100c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801011:	b8 09 00 00 00       	mov    $0x9,%eax
  801016:	e8 ac fd ff ff       	call   800dc7 <nsipc>
}
  80101b:	c9                   	leave  
  80101c:	c3                   	ret    

0080101d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	56                   	push   %esi
  801021:	53                   	push   %ebx
  801022:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	ff 75 08             	pushl  0x8(%ebp)
  80102b:	e8 98 f3 ff ff       	call   8003c8 <fd2data>
  801030:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801032:	83 c4 08             	add    $0x8,%esp
  801035:	68 98 23 80 00       	push   $0x802398
  80103a:	53                   	push   %ebx
  80103b:	e8 1a 0b 00 00       	call   801b5a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801040:	8b 46 04             	mov    0x4(%esi),%eax
  801043:	2b 06                	sub    (%esi),%eax
  801045:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80104b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801052:	00 00 00 
	stat->st_dev = &devpipe;
  801055:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80105c:	30 80 00 
	return 0;
}
  80105f:	b8 00 00 00 00       	mov    $0x0,%eax
  801064:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801067:	5b                   	pop    %ebx
  801068:	5e                   	pop    %esi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	53                   	push   %ebx
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801075:	53                   	push   %ebx
  801076:	6a 00                	push   $0x0
  801078:	e8 6e f1 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80107d:	89 1c 24             	mov    %ebx,(%esp)
  801080:	e8 43 f3 ff ff       	call   8003c8 <fd2data>
  801085:	83 c4 08             	add    $0x8,%esp
  801088:	50                   	push   %eax
  801089:	6a 00                	push   $0x0
  80108b:	e8 5b f1 ff ff       	call   8001eb <sys_page_unmap>
}
  801090:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801093:	c9                   	leave  
  801094:	c3                   	ret    

00801095 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	53                   	push   %ebx
  80109b:	83 ec 1c             	sub    $0x1c,%esp
  80109e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010a1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010a3:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8010b1:	e8 df 0e 00 00       	call   801f95 <pageref>
  8010b6:	89 c3                	mov    %eax,%ebx
  8010b8:	89 3c 24             	mov    %edi,(%esp)
  8010bb:	e8 d5 0e 00 00       	call   801f95 <pageref>
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	39 c3                	cmp    %eax,%ebx
  8010c5:	0f 94 c1             	sete   %cl
  8010c8:	0f b6 c9             	movzbl %cl,%ecx
  8010cb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010ce:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010d4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010d7:	39 ce                	cmp    %ecx,%esi
  8010d9:	74 1b                	je     8010f6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010db:	39 c3                	cmp    %eax,%ebx
  8010dd:	75 c4                	jne    8010a3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010df:	8b 42 58             	mov    0x58(%edx),%eax
  8010e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e5:	50                   	push   %eax
  8010e6:	56                   	push   %esi
  8010e7:	68 9f 23 80 00       	push   $0x80239f
  8010ec:	e8 e4 04 00 00       	call   8015d5 <cprintf>
  8010f1:	83 c4 10             	add    $0x10,%esp
  8010f4:	eb ad                	jmp    8010a3 <_pipeisclosed+0xe>
	}
}
  8010f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	57                   	push   %edi
  801105:	56                   	push   %esi
  801106:	53                   	push   %ebx
  801107:	83 ec 28             	sub    $0x28,%esp
  80110a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80110d:	56                   	push   %esi
  80110e:	e8 b5 f2 ff ff       	call   8003c8 <fd2data>
  801113:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	bf 00 00 00 00       	mov    $0x0,%edi
  80111d:	eb 4b                	jmp    80116a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80111f:	89 da                	mov    %ebx,%edx
  801121:	89 f0                	mov    %esi,%eax
  801123:	e8 6d ff ff ff       	call   801095 <_pipeisclosed>
  801128:	85 c0                	test   %eax,%eax
  80112a:	75 48                	jne    801174 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80112c:	e8 16 f0 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801131:	8b 43 04             	mov    0x4(%ebx),%eax
  801134:	8b 0b                	mov    (%ebx),%ecx
  801136:	8d 51 20             	lea    0x20(%ecx),%edx
  801139:	39 d0                	cmp    %edx,%eax
  80113b:	73 e2                	jae    80111f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80113d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801140:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801144:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801147:	89 c2                	mov    %eax,%edx
  801149:	c1 fa 1f             	sar    $0x1f,%edx
  80114c:	89 d1                	mov    %edx,%ecx
  80114e:	c1 e9 1b             	shr    $0x1b,%ecx
  801151:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801154:	83 e2 1f             	and    $0x1f,%edx
  801157:	29 ca                	sub    %ecx,%edx
  801159:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80115d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801161:	83 c0 01             	add    $0x1,%eax
  801164:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801167:	83 c7 01             	add    $0x1,%edi
  80116a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80116d:	75 c2                	jne    801131 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80116f:	8b 45 10             	mov    0x10(%ebp),%eax
  801172:	eb 05                	jmp    801179 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801174:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	5f                   	pop    %edi
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	57                   	push   %edi
  801185:	56                   	push   %esi
  801186:	53                   	push   %ebx
  801187:	83 ec 18             	sub    $0x18,%esp
  80118a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80118d:	57                   	push   %edi
  80118e:	e8 35 f2 ff ff       	call   8003c8 <fd2data>
  801193:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119d:	eb 3d                	jmp    8011dc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80119f:	85 db                	test   %ebx,%ebx
  8011a1:	74 04                	je     8011a7 <devpipe_read+0x26>
				return i;
  8011a3:	89 d8                	mov    %ebx,%eax
  8011a5:	eb 44                	jmp    8011eb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011a7:	89 f2                	mov    %esi,%edx
  8011a9:	89 f8                	mov    %edi,%eax
  8011ab:	e8 e5 fe ff ff       	call   801095 <_pipeisclosed>
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	75 32                	jne    8011e6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011b4:	e8 8e ef ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011b9:	8b 06                	mov    (%esi),%eax
  8011bb:	3b 46 04             	cmp    0x4(%esi),%eax
  8011be:	74 df                	je     80119f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011c0:	99                   	cltd   
  8011c1:	c1 ea 1b             	shr    $0x1b,%edx
  8011c4:	01 d0                	add    %edx,%eax
  8011c6:	83 e0 1f             	and    $0x1f,%eax
  8011c9:	29 d0                	sub    %edx,%eax
  8011cb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011d6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d9:	83 c3 01             	add    $0x1,%ebx
  8011dc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011df:	75 d8                	jne    8011b9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8011e4:	eb 05                	jmp    8011eb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011e6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ee:	5b                   	pop    %ebx
  8011ef:	5e                   	pop    %esi
  8011f0:	5f                   	pop    %edi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fe:	50                   	push   %eax
  8011ff:	e8 db f1 ff ff       	call   8003df <fd_alloc>
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	89 c2                	mov    %eax,%edx
  801209:	85 c0                	test   %eax,%eax
  80120b:	0f 88 2c 01 00 00    	js     80133d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	68 07 04 00 00       	push   $0x407
  801219:	ff 75 f4             	pushl  -0xc(%ebp)
  80121c:	6a 00                	push   $0x0
  80121e:	e8 43 ef ff ff       	call   800166 <sys_page_alloc>
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	89 c2                	mov    %eax,%edx
  801228:	85 c0                	test   %eax,%eax
  80122a:	0f 88 0d 01 00 00    	js     80133d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801230:	83 ec 0c             	sub    $0xc,%esp
  801233:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801236:	50                   	push   %eax
  801237:	e8 a3 f1 ff ff       	call   8003df <fd_alloc>
  80123c:	89 c3                	mov    %eax,%ebx
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	85 c0                	test   %eax,%eax
  801243:	0f 88 e2 00 00 00    	js     80132b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801249:	83 ec 04             	sub    $0x4,%esp
  80124c:	68 07 04 00 00       	push   $0x407
  801251:	ff 75 f0             	pushl  -0x10(%ebp)
  801254:	6a 00                	push   $0x0
  801256:	e8 0b ef ff ff       	call   800166 <sys_page_alloc>
  80125b:	89 c3                	mov    %eax,%ebx
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	85 c0                	test   %eax,%eax
  801262:	0f 88 c3 00 00 00    	js     80132b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801268:	83 ec 0c             	sub    $0xc,%esp
  80126b:	ff 75 f4             	pushl  -0xc(%ebp)
  80126e:	e8 55 f1 ff ff       	call   8003c8 <fd2data>
  801273:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801275:	83 c4 0c             	add    $0xc,%esp
  801278:	68 07 04 00 00       	push   $0x407
  80127d:	50                   	push   %eax
  80127e:	6a 00                	push   $0x0
  801280:	e8 e1 ee ff ff       	call   800166 <sys_page_alloc>
  801285:	89 c3                	mov    %eax,%ebx
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	85 c0                	test   %eax,%eax
  80128c:	0f 88 89 00 00 00    	js     80131b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801292:	83 ec 0c             	sub    $0xc,%esp
  801295:	ff 75 f0             	pushl  -0x10(%ebp)
  801298:	e8 2b f1 ff ff       	call   8003c8 <fd2data>
  80129d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012a4:	50                   	push   %eax
  8012a5:	6a 00                	push   $0x0
  8012a7:	56                   	push   %esi
  8012a8:	6a 00                	push   $0x0
  8012aa:	e8 fa ee ff ff       	call   8001a9 <sys_page_map>
  8012af:	89 c3                	mov    %eax,%ebx
  8012b1:	83 c4 20             	add    $0x20,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 55                	js     80130d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012b8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012cd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012db:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012e2:	83 ec 0c             	sub    $0xc,%esp
  8012e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e8:	e8 cb f0 ff ff       	call   8003b8 <fd2num>
  8012ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012f2:	83 c4 04             	add    $0x4,%esp
  8012f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8012f8:	e8 bb f0 ff ff       	call   8003b8 <fd2num>
  8012fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801300:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	ba 00 00 00 00       	mov    $0x0,%edx
  80130b:	eb 30                	jmp    80133d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	56                   	push   %esi
  801311:	6a 00                	push   $0x0
  801313:	e8 d3 ee ff ff       	call   8001eb <sys_page_unmap>
  801318:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	ff 75 f0             	pushl  -0x10(%ebp)
  801321:	6a 00                	push   $0x0
  801323:	e8 c3 ee ff ff       	call   8001eb <sys_page_unmap>
  801328:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80132b:	83 ec 08             	sub    $0x8,%esp
  80132e:	ff 75 f4             	pushl  -0xc(%ebp)
  801331:	6a 00                	push   $0x0
  801333:	e8 b3 ee ff ff       	call   8001eb <sys_page_unmap>
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80133d:	89 d0                	mov    %edx,%eax
  80133f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801342:	5b                   	pop    %ebx
  801343:	5e                   	pop    %esi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80134c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134f:	50                   	push   %eax
  801350:	ff 75 08             	pushl  0x8(%ebp)
  801353:	e8 d6 f0 ff ff       	call   80042e <fd_lookup>
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	85 c0                	test   %eax,%eax
  80135d:	78 18                	js     801377 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80135f:	83 ec 0c             	sub    $0xc,%esp
  801362:	ff 75 f4             	pushl  -0xc(%ebp)
  801365:	e8 5e f0 ff ff       	call   8003c8 <fd2data>
	return _pipeisclosed(fd, p);
  80136a:	89 c2                	mov    %eax,%edx
  80136c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136f:	e8 21 fd ff ff       	call   801095 <_pipeisclosed>
  801374:	83 c4 10             	add    $0x10,%esp
}
  801377:	c9                   	leave  
  801378:	c3                   	ret    

00801379 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80137c:	b8 00 00 00 00       	mov    $0x0,%eax
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    

00801383 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801389:	68 b7 23 80 00       	push   $0x8023b7
  80138e:	ff 75 0c             	pushl  0xc(%ebp)
  801391:	e8 c4 07 00 00       	call   801b5a <strcpy>
	return 0;
}
  801396:	b8 00 00 00 00       	mov    $0x0,%eax
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    

0080139d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	57                   	push   %edi
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
  8013a3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013ae:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013b4:	eb 2d                	jmp    8013e3 <devcons_write+0x46>
		m = n - tot;
  8013b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013bb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013be:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013c3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013c6:	83 ec 04             	sub    $0x4,%esp
  8013c9:	53                   	push   %ebx
  8013ca:	03 45 0c             	add    0xc(%ebp),%eax
  8013cd:	50                   	push   %eax
  8013ce:	57                   	push   %edi
  8013cf:	e8 18 09 00 00       	call   801cec <memmove>
		sys_cputs(buf, m);
  8013d4:	83 c4 08             	add    $0x8,%esp
  8013d7:	53                   	push   %ebx
  8013d8:	57                   	push   %edi
  8013d9:	e8 cc ec ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013de:	01 de                	add    %ebx,%esi
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	89 f0                	mov    %esi,%eax
  8013e5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013e8:	72 cc                	jb     8013b6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ed:	5b                   	pop    %ebx
  8013ee:	5e                   	pop    %esi
  8013ef:	5f                   	pop    %edi
  8013f0:	5d                   	pop    %ebp
  8013f1:	c3                   	ret    

008013f2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801401:	74 2a                	je     80142d <devcons_read+0x3b>
  801403:	eb 05                	jmp    80140a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801405:	e8 3d ed ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80140a:	e8 b9 ec ff ff       	call   8000c8 <sys_cgetc>
  80140f:	85 c0                	test   %eax,%eax
  801411:	74 f2                	je     801405 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801413:	85 c0                	test   %eax,%eax
  801415:	78 16                	js     80142d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801417:	83 f8 04             	cmp    $0x4,%eax
  80141a:	74 0c                	je     801428 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80141c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80141f:	88 02                	mov    %al,(%edx)
	return 1;
  801421:	b8 01 00 00 00       	mov    $0x1,%eax
  801426:	eb 05                	jmp    80142d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801428:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    

0080142f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801435:	8b 45 08             	mov    0x8(%ebp),%eax
  801438:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80143b:	6a 01                	push   $0x1
  80143d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801440:	50                   	push   %eax
  801441:	e8 64 ec ff ff       	call   8000aa <sys_cputs>
}
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	c9                   	leave  
  80144a:	c3                   	ret    

0080144b <getchar>:

int
getchar(void)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801451:	6a 01                	push   $0x1
  801453:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801456:	50                   	push   %eax
  801457:	6a 00                	push   $0x0
  801459:	e8 36 f2 ff ff       	call   800694 <read>
	if (r < 0)
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	85 c0                	test   %eax,%eax
  801463:	78 0f                	js     801474 <getchar+0x29>
		return r;
	if (r < 1)
  801465:	85 c0                	test   %eax,%eax
  801467:	7e 06                	jle    80146f <getchar+0x24>
		return -E_EOF;
	return c;
  801469:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80146d:	eb 05                	jmp    801474 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80146f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801474:	c9                   	leave  
  801475:	c3                   	ret    

00801476 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80147c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	ff 75 08             	pushl  0x8(%ebp)
  801483:	e8 a6 ef ff ff       	call   80042e <fd_lookup>
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 11                	js     8014a0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80148f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801492:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801498:	39 10                	cmp    %edx,(%eax)
  80149a:	0f 94 c0             	sete   %al
  80149d:	0f b6 c0             	movzbl %al,%eax
}
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    

008014a2 <opencons>:

int
opencons(void)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ab:	50                   	push   %eax
  8014ac:	e8 2e ef ff ff       	call   8003df <fd_alloc>
  8014b1:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	78 3e                	js     8014f8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ba:	83 ec 04             	sub    $0x4,%esp
  8014bd:	68 07 04 00 00       	push   $0x407
  8014c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c5:	6a 00                	push   $0x0
  8014c7:	e8 9a ec ff ff       	call   800166 <sys_page_alloc>
  8014cc:	83 c4 10             	add    $0x10,%esp
		return r;
  8014cf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 23                	js     8014f8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014d5:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014de:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014ea:	83 ec 0c             	sub    $0xc,%esp
  8014ed:	50                   	push   %eax
  8014ee:	e8 c5 ee ff ff       	call   8003b8 <fd2num>
  8014f3:	89 c2                	mov    %eax,%edx
  8014f5:	83 c4 10             	add    $0x10,%esp
}
  8014f8:	89 d0                	mov    %edx,%eax
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	56                   	push   %esi
  801500:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801501:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801504:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80150a:	e8 19 ec ff ff       	call   800128 <sys_getenvid>
  80150f:	83 ec 0c             	sub    $0xc,%esp
  801512:	ff 75 0c             	pushl  0xc(%ebp)
  801515:	ff 75 08             	pushl  0x8(%ebp)
  801518:	56                   	push   %esi
  801519:	50                   	push   %eax
  80151a:	68 c4 23 80 00       	push   $0x8023c4
  80151f:	e8 b1 00 00 00       	call   8015d5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801524:	83 c4 18             	add    $0x18,%esp
  801527:	53                   	push   %ebx
  801528:	ff 75 10             	pushl  0x10(%ebp)
  80152b:	e8 54 00 00 00       	call   801584 <vcprintf>
	cprintf("\n");
  801530:	c7 04 24 b0 23 80 00 	movl   $0x8023b0,(%esp)
  801537:	e8 99 00 00 00       	call   8015d5 <cprintf>
  80153c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80153f:	cc                   	int3   
  801540:	eb fd                	jmp    80153f <_panic+0x43>

00801542 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	53                   	push   %ebx
  801546:	83 ec 04             	sub    $0x4,%esp
  801549:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80154c:	8b 13                	mov    (%ebx),%edx
  80154e:	8d 42 01             	lea    0x1(%edx),%eax
  801551:	89 03                	mov    %eax,(%ebx)
  801553:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801556:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80155a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80155f:	75 1a                	jne    80157b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801561:	83 ec 08             	sub    $0x8,%esp
  801564:	68 ff 00 00 00       	push   $0xff
  801569:	8d 43 08             	lea    0x8(%ebx),%eax
  80156c:	50                   	push   %eax
  80156d:	e8 38 eb ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  801572:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801578:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80157b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80157f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801582:	c9                   	leave  
  801583:	c3                   	ret    

00801584 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80158d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801594:	00 00 00 
	b.cnt = 0;
  801597:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80159e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015a1:	ff 75 0c             	pushl  0xc(%ebp)
  8015a4:	ff 75 08             	pushl  0x8(%ebp)
  8015a7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	68 42 15 80 00       	push   $0x801542
  8015b3:	e8 54 01 00 00       	call   80170c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015b8:	83 c4 08             	add    $0x8,%esp
  8015bb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015c1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015c7:	50                   	push   %eax
  8015c8:	e8 dd ea ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  8015cd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015d3:	c9                   	leave  
  8015d4:	c3                   	ret    

008015d5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015db:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015de:	50                   	push   %eax
  8015df:	ff 75 08             	pushl  0x8(%ebp)
  8015e2:	e8 9d ff ff ff       	call   801584 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015e7:	c9                   	leave  
  8015e8:	c3                   	ret    

008015e9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	57                   	push   %edi
  8015ed:	56                   	push   %esi
  8015ee:	53                   	push   %ebx
  8015ef:	83 ec 1c             	sub    $0x1c,%esp
  8015f2:	89 c7                	mov    %eax,%edi
  8015f4:	89 d6                	mov    %edx,%esi
  8015f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801602:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801605:	bb 00 00 00 00       	mov    $0x0,%ebx
  80160a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80160d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801610:	39 d3                	cmp    %edx,%ebx
  801612:	72 05                	jb     801619 <printnum+0x30>
  801614:	39 45 10             	cmp    %eax,0x10(%ebp)
  801617:	77 45                	ja     80165e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801619:	83 ec 0c             	sub    $0xc,%esp
  80161c:	ff 75 18             	pushl  0x18(%ebp)
  80161f:	8b 45 14             	mov    0x14(%ebp),%eax
  801622:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801625:	53                   	push   %ebx
  801626:	ff 75 10             	pushl  0x10(%ebp)
  801629:	83 ec 08             	sub    $0x8,%esp
  80162c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80162f:	ff 75 e0             	pushl  -0x20(%ebp)
  801632:	ff 75 dc             	pushl  -0x24(%ebp)
  801635:	ff 75 d8             	pushl  -0x28(%ebp)
  801638:	e8 93 09 00 00       	call   801fd0 <__udivdi3>
  80163d:	83 c4 18             	add    $0x18,%esp
  801640:	52                   	push   %edx
  801641:	50                   	push   %eax
  801642:	89 f2                	mov    %esi,%edx
  801644:	89 f8                	mov    %edi,%eax
  801646:	e8 9e ff ff ff       	call   8015e9 <printnum>
  80164b:	83 c4 20             	add    $0x20,%esp
  80164e:	eb 18                	jmp    801668 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	56                   	push   %esi
  801654:	ff 75 18             	pushl  0x18(%ebp)
  801657:	ff d7                	call   *%edi
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	eb 03                	jmp    801661 <printnum+0x78>
  80165e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801661:	83 eb 01             	sub    $0x1,%ebx
  801664:	85 db                	test   %ebx,%ebx
  801666:	7f e8                	jg     801650 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801668:	83 ec 08             	sub    $0x8,%esp
  80166b:	56                   	push   %esi
  80166c:	83 ec 04             	sub    $0x4,%esp
  80166f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801672:	ff 75 e0             	pushl  -0x20(%ebp)
  801675:	ff 75 dc             	pushl  -0x24(%ebp)
  801678:	ff 75 d8             	pushl  -0x28(%ebp)
  80167b:	e8 80 0a 00 00       	call   802100 <__umoddi3>
  801680:	83 c4 14             	add    $0x14,%esp
  801683:	0f be 80 e7 23 80 00 	movsbl 0x8023e7(%eax),%eax
  80168a:	50                   	push   %eax
  80168b:	ff d7                	call   *%edi
}
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801693:	5b                   	pop    %ebx
  801694:	5e                   	pop    %esi
  801695:	5f                   	pop    %edi
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80169b:	83 fa 01             	cmp    $0x1,%edx
  80169e:	7e 0e                	jle    8016ae <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016a0:	8b 10                	mov    (%eax),%edx
  8016a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016a5:	89 08                	mov    %ecx,(%eax)
  8016a7:	8b 02                	mov    (%edx),%eax
  8016a9:	8b 52 04             	mov    0x4(%edx),%edx
  8016ac:	eb 22                	jmp    8016d0 <getuint+0x38>
	else if (lflag)
  8016ae:	85 d2                	test   %edx,%edx
  8016b0:	74 10                	je     8016c2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016b2:	8b 10                	mov    (%eax),%edx
  8016b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b7:	89 08                	mov    %ecx,(%eax)
  8016b9:	8b 02                	mov    (%edx),%eax
  8016bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c0:	eb 0e                	jmp    8016d0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016c2:	8b 10                	mov    (%eax),%edx
  8016c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016c7:	89 08                	mov    %ecx,(%eax)
  8016c9:	8b 02                	mov    (%edx),%eax
  8016cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    

008016d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016dc:	8b 10                	mov    (%eax),%edx
  8016de:	3b 50 04             	cmp    0x4(%eax),%edx
  8016e1:	73 0a                	jae    8016ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8016e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016e6:	89 08                	mov    %ecx,(%eax)
  8016e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016eb:	88 02                	mov    %al,(%edx)
}
  8016ed:	5d                   	pop    %ebp
  8016ee:	c3                   	ret    

008016ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016f8:	50                   	push   %eax
  8016f9:	ff 75 10             	pushl  0x10(%ebp)
  8016fc:	ff 75 0c             	pushl  0xc(%ebp)
  8016ff:	ff 75 08             	pushl  0x8(%ebp)
  801702:	e8 05 00 00 00       	call   80170c <vprintfmt>
	va_end(ap);
}
  801707:	83 c4 10             	add    $0x10,%esp
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	57                   	push   %edi
  801710:	56                   	push   %esi
  801711:	53                   	push   %ebx
  801712:	83 ec 2c             	sub    $0x2c,%esp
  801715:	8b 75 08             	mov    0x8(%ebp),%esi
  801718:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80171b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80171e:	eb 12                	jmp    801732 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801720:	85 c0                	test   %eax,%eax
  801722:	0f 84 89 03 00 00    	je     801ab1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801728:	83 ec 08             	sub    $0x8,%esp
  80172b:	53                   	push   %ebx
  80172c:	50                   	push   %eax
  80172d:	ff d6                	call   *%esi
  80172f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801732:	83 c7 01             	add    $0x1,%edi
  801735:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801739:	83 f8 25             	cmp    $0x25,%eax
  80173c:	75 e2                	jne    801720 <vprintfmt+0x14>
  80173e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801742:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801749:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801750:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801757:	ba 00 00 00 00       	mov    $0x0,%edx
  80175c:	eb 07                	jmp    801765 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80175e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801761:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801765:	8d 47 01             	lea    0x1(%edi),%eax
  801768:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80176b:	0f b6 07             	movzbl (%edi),%eax
  80176e:	0f b6 c8             	movzbl %al,%ecx
  801771:	83 e8 23             	sub    $0x23,%eax
  801774:	3c 55                	cmp    $0x55,%al
  801776:	0f 87 1a 03 00 00    	ja     801a96 <vprintfmt+0x38a>
  80177c:	0f b6 c0             	movzbl %al,%eax
  80177f:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801786:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801789:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80178d:	eb d6                	jmp    801765 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801792:	b8 00 00 00 00       	mov    $0x0,%eax
  801797:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80179a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80179d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017a1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017a4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017a7:	83 fa 09             	cmp    $0x9,%edx
  8017aa:	77 39                	ja     8017e5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017af:	eb e9                	jmp    80179a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b4:	8d 48 04             	lea    0x4(%eax),%ecx
  8017b7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017ba:	8b 00                	mov    (%eax),%eax
  8017bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017c2:	eb 27                	jmp    8017eb <vprintfmt+0xdf>
  8017c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017ce:	0f 49 c8             	cmovns %eax,%ecx
  8017d1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017d7:	eb 8c                	jmp    801765 <vprintfmt+0x59>
  8017d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017dc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017e3:	eb 80                	jmp    801765 <vprintfmt+0x59>
  8017e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017e8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017ef:	0f 89 70 ff ff ff    	jns    801765 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801802:	e9 5e ff ff ff       	jmp    801765 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801807:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80180d:	e9 53 ff ff ff       	jmp    801765 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801812:	8b 45 14             	mov    0x14(%ebp),%eax
  801815:	8d 50 04             	lea    0x4(%eax),%edx
  801818:	89 55 14             	mov    %edx,0x14(%ebp)
  80181b:	83 ec 08             	sub    $0x8,%esp
  80181e:	53                   	push   %ebx
  80181f:	ff 30                	pushl  (%eax)
  801821:	ff d6                	call   *%esi
			break;
  801823:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801826:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801829:	e9 04 ff ff ff       	jmp    801732 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80182e:	8b 45 14             	mov    0x14(%ebp),%eax
  801831:	8d 50 04             	lea    0x4(%eax),%edx
  801834:	89 55 14             	mov    %edx,0x14(%ebp)
  801837:	8b 00                	mov    (%eax),%eax
  801839:	99                   	cltd   
  80183a:	31 d0                	xor    %edx,%eax
  80183c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80183e:	83 f8 0f             	cmp    $0xf,%eax
  801841:	7f 0b                	jg     80184e <vprintfmt+0x142>
  801843:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80184a:	85 d2                	test   %edx,%edx
  80184c:	75 18                	jne    801866 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80184e:	50                   	push   %eax
  80184f:	68 ff 23 80 00       	push   $0x8023ff
  801854:	53                   	push   %ebx
  801855:	56                   	push   %esi
  801856:	e8 94 fe ff ff       	call   8016ef <printfmt>
  80185b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801861:	e9 cc fe ff ff       	jmp    801732 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801866:	52                   	push   %edx
  801867:	68 45 23 80 00       	push   $0x802345
  80186c:	53                   	push   %ebx
  80186d:	56                   	push   %esi
  80186e:	e8 7c fe ff ff       	call   8016ef <printfmt>
  801873:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801876:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801879:	e9 b4 fe ff ff       	jmp    801732 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80187e:	8b 45 14             	mov    0x14(%ebp),%eax
  801881:	8d 50 04             	lea    0x4(%eax),%edx
  801884:	89 55 14             	mov    %edx,0x14(%ebp)
  801887:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801889:	85 ff                	test   %edi,%edi
  80188b:	b8 f8 23 80 00       	mov    $0x8023f8,%eax
  801890:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801893:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801897:	0f 8e 94 00 00 00    	jle    801931 <vprintfmt+0x225>
  80189d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018a1:	0f 84 98 00 00 00    	je     80193f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	ff 75 d0             	pushl  -0x30(%ebp)
  8018ad:	57                   	push   %edi
  8018ae:	e8 86 02 00 00       	call   801b39 <strnlen>
  8018b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018b6:	29 c1                	sub    %eax,%ecx
  8018b8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018bb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018be:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018c8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018ca:	eb 0f                	jmp    8018db <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018cc:	83 ec 08             	sub    $0x8,%esp
  8018cf:	53                   	push   %ebx
  8018d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8018d3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018d5:	83 ef 01             	sub    $0x1,%edi
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	85 ff                	test   %edi,%edi
  8018dd:	7f ed                	jg     8018cc <vprintfmt+0x1c0>
  8018df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018e2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018e5:	85 c9                	test   %ecx,%ecx
  8018e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ec:	0f 49 c1             	cmovns %ecx,%eax
  8018ef:	29 c1                	sub    %eax,%ecx
  8018f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8018f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018fa:	89 cb                	mov    %ecx,%ebx
  8018fc:	eb 4d                	jmp    80194b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801902:	74 1b                	je     80191f <vprintfmt+0x213>
  801904:	0f be c0             	movsbl %al,%eax
  801907:	83 e8 20             	sub    $0x20,%eax
  80190a:	83 f8 5e             	cmp    $0x5e,%eax
  80190d:	76 10                	jbe    80191f <vprintfmt+0x213>
					putch('?', putdat);
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	ff 75 0c             	pushl  0xc(%ebp)
  801915:	6a 3f                	push   $0x3f
  801917:	ff 55 08             	call   *0x8(%ebp)
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	eb 0d                	jmp    80192c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80191f:	83 ec 08             	sub    $0x8,%esp
  801922:	ff 75 0c             	pushl  0xc(%ebp)
  801925:	52                   	push   %edx
  801926:	ff 55 08             	call   *0x8(%ebp)
  801929:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80192c:	83 eb 01             	sub    $0x1,%ebx
  80192f:	eb 1a                	jmp    80194b <vprintfmt+0x23f>
  801931:	89 75 08             	mov    %esi,0x8(%ebp)
  801934:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801937:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80193a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80193d:	eb 0c                	jmp    80194b <vprintfmt+0x23f>
  80193f:	89 75 08             	mov    %esi,0x8(%ebp)
  801942:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801945:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801948:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80194b:	83 c7 01             	add    $0x1,%edi
  80194e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801952:	0f be d0             	movsbl %al,%edx
  801955:	85 d2                	test   %edx,%edx
  801957:	74 23                	je     80197c <vprintfmt+0x270>
  801959:	85 f6                	test   %esi,%esi
  80195b:	78 a1                	js     8018fe <vprintfmt+0x1f2>
  80195d:	83 ee 01             	sub    $0x1,%esi
  801960:	79 9c                	jns    8018fe <vprintfmt+0x1f2>
  801962:	89 df                	mov    %ebx,%edi
  801964:	8b 75 08             	mov    0x8(%ebp),%esi
  801967:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80196a:	eb 18                	jmp    801984 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80196c:	83 ec 08             	sub    $0x8,%esp
  80196f:	53                   	push   %ebx
  801970:	6a 20                	push   $0x20
  801972:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801974:	83 ef 01             	sub    $0x1,%edi
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	eb 08                	jmp    801984 <vprintfmt+0x278>
  80197c:	89 df                	mov    %ebx,%edi
  80197e:	8b 75 08             	mov    0x8(%ebp),%esi
  801981:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801984:	85 ff                	test   %edi,%edi
  801986:	7f e4                	jg     80196c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801988:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80198b:	e9 a2 fd ff ff       	jmp    801732 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801990:	83 fa 01             	cmp    $0x1,%edx
  801993:	7e 16                	jle    8019ab <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801995:	8b 45 14             	mov    0x14(%ebp),%eax
  801998:	8d 50 08             	lea    0x8(%eax),%edx
  80199b:	89 55 14             	mov    %edx,0x14(%ebp)
  80199e:	8b 50 04             	mov    0x4(%eax),%edx
  8019a1:	8b 00                	mov    (%eax),%eax
  8019a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019a9:	eb 32                	jmp    8019dd <vprintfmt+0x2d1>
	else if (lflag)
  8019ab:	85 d2                	test   %edx,%edx
  8019ad:	74 18                	je     8019c7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019af:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b2:	8d 50 04             	lea    0x4(%eax),%edx
  8019b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8019b8:	8b 00                	mov    (%eax),%eax
  8019ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019bd:	89 c1                	mov    %eax,%ecx
  8019bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8019c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019c5:	eb 16                	jmp    8019dd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ca:	8d 50 04             	lea    0x4(%eax),%edx
  8019cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8019d0:	8b 00                	mov    (%eax),%eax
  8019d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019d5:	89 c1                	mov    %eax,%ecx
  8019d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8019da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019e8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019ec:	79 74                	jns    801a62 <vprintfmt+0x356>
				putch('-', putdat);
  8019ee:	83 ec 08             	sub    $0x8,%esp
  8019f1:	53                   	push   %ebx
  8019f2:	6a 2d                	push   $0x2d
  8019f4:	ff d6                	call   *%esi
				num = -(long long) num;
  8019f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019fc:	f7 d8                	neg    %eax
  8019fe:	83 d2 00             	adc    $0x0,%edx
  801a01:	f7 da                	neg    %edx
  801a03:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a06:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a0b:	eb 55                	jmp    801a62 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a0d:	8d 45 14             	lea    0x14(%ebp),%eax
  801a10:	e8 83 fc ff ff       	call   801698 <getuint>
			base = 10;
  801a15:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a1a:	eb 46                	jmp    801a62 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a1c:	8d 45 14             	lea    0x14(%ebp),%eax
  801a1f:	e8 74 fc ff ff       	call   801698 <getuint>
			base = 8;
  801a24:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a29:	eb 37                	jmp    801a62 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a2b:	83 ec 08             	sub    $0x8,%esp
  801a2e:	53                   	push   %ebx
  801a2f:	6a 30                	push   $0x30
  801a31:	ff d6                	call   *%esi
			putch('x', putdat);
  801a33:	83 c4 08             	add    $0x8,%esp
  801a36:	53                   	push   %ebx
  801a37:	6a 78                	push   $0x78
  801a39:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a3b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3e:	8d 50 04             	lea    0x4(%eax),%edx
  801a41:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a44:	8b 00                	mov    (%eax),%eax
  801a46:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a4b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a4e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a53:	eb 0d                	jmp    801a62 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a55:	8d 45 14             	lea    0x14(%ebp),%eax
  801a58:	e8 3b fc ff ff       	call   801698 <getuint>
			base = 16;
  801a5d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a69:	57                   	push   %edi
  801a6a:	ff 75 e0             	pushl  -0x20(%ebp)
  801a6d:	51                   	push   %ecx
  801a6e:	52                   	push   %edx
  801a6f:	50                   	push   %eax
  801a70:	89 da                	mov    %ebx,%edx
  801a72:	89 f0                	mov    %esi,%eax
  801a74:	e8 70 fb ff ff       	call   8015e9 <printnum>
			break;
  801a79:	83 c4 20             	add    $0x20,%esp
  801a7c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a7f:	e9 ae fc ff ff       	jmp    801732 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a84:	83 ec 08             	sub    $0x8,%esp
  801a87:	53                   	push   %ebx
  801a88:	51                   	push   %ecx
  801a89:	ff d6                	call   *%esi
			break;
  801a8b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a8e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a91:	e9 9c fc ff ff       	jmp    801732 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a96:	83 ec 08             	sub    $0x8,%esp
  801a99:	53                   	push   %ebx
  801a9a:	6a 25                	push   $0x25
  801a9c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	eb 03                	jmp    801aa6 <vprintfmt+0x39a>
  801aa3:	83 ef 01             	sub    $0x1,%edi
  801aa6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801aaa:	75 f7                	jne    801aa3 <vprintfmt+0x397>
  801aac:	e9 81 fc ff ff       	jmp    801732 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ab1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab4:	5b                   	pop    %ebx
  801ab5:	5e                   	pop    %esi
  801ab6:	5f                   	pop    %edi
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 18             	sub    $0x18,%esp
  801abf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ac5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ac8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801acc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801acf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	74 26                	je     801b00 <vsnprintf+0x47>
  801ada:	85 d2                	test   %edx,%edx
  801adc:	7e 22                	jle    801b00 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ade:	ff 75 14             	pushl  0x14(%ebp)
  801ae1:	ff 75 10             	pushl  0x10(%ebp)
  801ae4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ae7:	50                   	push   %eax
  801ae8:	68 d2 16 80 00       	push   $0x8016d2
  801aed:	e8 1a fc ff ff       	call   80170c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801af2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801af5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	eb 05                	jmp    801b05 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b0d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b10:	50                   	push   %eax
  801b11:	ff 75 10             	pushl  0x10(%ebp)
  801b14:	ff 75 0c             	pushl  0xc(%ebp)
  801b17:	ff 75 08             	pushl  0x8(%ebp)
  801b1a:	e8 9a ff ff ff       	call   801ab9 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b1f:	c9                   	leave  
  801b20:	c3                   	ret    

00801b21 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b27:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2c:	eb 03                	jmp    801b31 <strlen+0x10>
		n++;
  801b2e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b31:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b35:	75 f7                	jne    801b2e <strlen+0xd>
		n++;
	return n;
}
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b42:	ba 00 00 00 00       	mov    $0x0,%edx
  801b47:	eb 03                	jmp    801b4c <strnlen+0x13>
		n++;
  801b49:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b4c:	39 c2                	cmp    %eax,%edx
  801b4e:	74 08                	je     801b58 <strnlen+0x1f>
  801b50:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b54:	75 f3                	jne    801b49 <strnlen+0x10>
  801b56:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    

00801b5a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	53                   	push   %ebx
  801b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b64:	89 c2                	mov    %eax,%edx
  801b66:	83 c2 01             	add    $0x1,%edx
  801b69:	83 c1 01             	add    $0x1,%ecx
  801b6c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b70:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b73:	84 db                	test   %bl,%bl
  801b75:	75 ef                	jne    801b66 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b77:	5b                   	pop    %ebx
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	53                   	push   %ebx
  801b7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b81:	53                   	push   %ebx
  801b82:	e8 9a ff ff ff       	call   801b21 <strlen>
  801b87:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b8a:	ff 75 0c             	pushl  0xc(%ebp)
  801b8d:	01 d8                	add    %ebx,%eax
  801b8f:	50                   	push   %eax
  801b90:	e8 c5 ff ff ff       	call   801b5a <strcpy>
	return dst;
}
  801b95:	89 d8                	mov    %ebx,%eax
  801b97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9a:	c9                   	leave  
  801b9b:	c3                   	ret    

00801b9c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	56                   	push   %esi
  801ba0:	53                   	push   %ebx
  801ba1:	8b 75 08             	mov    0x8(%ebp),%esi
  801ba4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba7:	89 f3                	mov    %esi,%ebx
  801ba9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bac:	89 f2                	mov    %esi,%edx
  801bae:	eb 0f                	jmp    801bbf <strncpy+0x23>
		*dst++ = *src;
  801bb0:	83 c2 01             	add    $0x1,%edx
  801bb3:	0f b6 01             	movzbl (%ecx),%eax
  801bb6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bb9:	80 39 01             	cmpb   $0x1,(%ecx)
  801bbc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bbf:	39 da                	cmp    %ebx,%edx
  801bc1:	75 ed                	jne    801bb0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bc3:	89 f0                	mov    %esi,%eax
  801bc5:	5b                   	pop    %ebx
  801bc6:	5e                   	pop    %esi
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	56                   	push   %esi
  801bcd:	53                   	push   %ebx
  801bce:	8b 75 08             	mov    0x8(%ebp),%esi
  801bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd4:	8b 55 10             	mov    0x10(%ebp),%edx
  801bd7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bd9:	85 d2                	test   %edx,%edx
  801bdb:	74 21                	je     801bfe <strlcpy+0x35>
  801bdd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801be1:	89 f2                	mov    %esi,%edx
  801be3:	eb 09                	jmp    801bee <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801be5:	83 c2 01             	add    $0x1,%edx
  801be8:	83 c1 01             	add    $0x1,%ecx
  801beb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bee:	39 c2                	cmp    %eax,%edx
  801bf0:	74 09                	je     801bfb <strlcpy+0x32>
  801bf2:	0f b6 19             	movzbl (%ecx),%ebx
  801bf5:	84 db                	test   %bl,%bl
  801bf7:	75 ec                	jne    801be5 <strlcpy+0x1c>
  801bf9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bfb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bfe:	29 f0                	sub    %esi,%eax
}
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    

00801c04 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c0a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c0d:	eb 06                	jmp    801c15 <strcmp+0x11>
		p++, q++;
  801c0f:	83 c1 01             	add    $0x1,%ecx
  801c12:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c15:	0f b6 01             	movzbl (%ecx),%eax
  801c18:	84 c0                	test   %al,%al
  801c1a:	74 04                	je     801c20 <strcmp+0x1c>
  801c1c:	3a 02                	cmp    (%edx),%al
  801c1e:	74 ef                	je     801c0f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c20:	0f b6 c0             	movzbl %al,%eax
  801c23:	0f b6 12             	movzbl (%edx),%edx
  801c26:	29 d0                	sub    %edx,%eax
}
  801c28:	5d                   	pop    %ebp
  801c29:	c3                   	ret    

00801c2a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	53                   	push   %ebx
  801c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c31:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c34:	89 c3                	mov    %eax,%ebx
  801c36:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c39:	eb 06                	jmp    801c41 <strncmp+0x17>
		n--, p++, q++;
  801c3b:	83 c0 01             	add    $0x1,%eax
  801c3e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c41:	39 d8                	cmp    %ebx,%eax
  801c43:	74 15                	je     801c5a <strncmp+0x30>
  801c45:	0f b6 08             	movzbl (%eax),%ecx
  801c48:	84 c9                	test   %cl,%cl
  801c4a:	74 04                	je     801c50 <strncmp+0x26>
  801c4c:	3a 0a                	cmp    (%edx),%cl
  801c4e:	74 eb                	je     801c3b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c50:	0f b6 00             	movzbl (%eax),%eax
  801c53:	0f b6 12             	movzbl (%edx),%edx
  801c56:	29 d0                	sub    %edx,%eax
  801c58:	eb 05                	jmp    801c5f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c5a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c5f:	5b                   	pop    %ebx
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	8b 45 08             	mov    0x8(%ebp),%eax
  801c68:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c6c:	eb 07                	jmp    801c75 <strchr+0x13>
		if (*s == c)
  801c6e:	38 ca                	cmp    %cl,%dl
  801c70:	74 0f                	je     801c81 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c72:	83 c0 01             	add    $0x1,%eax
  801c75:	0f b6 10             	movzbl (%eax),%edx
  801c78:	84 d2                	test   %dl,%dl
  801c7a:	75 f2                	jne    801c6e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    

00801c83 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	8b 45 08             	mov    0x8(%ebp),%eax
  801c89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c8d:	eb 03                	jmp    801c92 <strfind+0xf>
  801c8f:	83 c0 01             	add    $0x1,%eax
  801c92:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c95:	38 ca                	cmp    %cl,%dl
  801c97:	74 04                	je     801c9d <strfind+0x1a>
  801c99:	84 d2                	test   %dl,%dl
  801c9b:	75 f2                	jne    801c8f <strfind+0xc>
			break;
	return (char *) s;
}
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    

00801c9f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	57                   	push   %edi
  801ca3:	56                   	push   %esi
  801ca4:	53                   	push   %ebx
  801ca5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ca8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cab:	85 c9                	test   %ecx,%ecx
  801cad:	74 36                	je     801ce5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801caf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cb5:	75 28                	jne    801cdf <memset+0x40>
  801cb7:	f6 c1 03             	test   $0x3,%cl
  801cba:	75 23                	jne    801cdf <memset+0x40>
		c &= 0xFF;
  801cbc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cc0:	89 d3                	mov    %edx,%ebx
  801cc2:	c1 e3 08             	shl    $0x8,%ebx
  801cc5:	89 d6                	mov    %edx,%esi
  801cc7:	c1 e6 18             	shl    $0x18,%esi
  801cca:	89 d0                	mov    %edx,%eax
  801ccc:	c1 e0 10             	shl    $0x10,%eax
  801ccf:	09 f0                	or     %esi,%eax
  801cd1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cd3:	89 d8                	mov    %ebx,%eax
  801cd5:	09 d0                	or     %edx,%eax
  801cd7:	c1 e9 02             	shr    $0x2,%ecx
  801cda:	fc                   	cld    
  801cdb:	f3 ab                	rep stos %eax,%es:(%edi)
  801cdd:	eb 06                	jmp    801ce5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce2:	fc                   	cld    
  801ce3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ce5:	89 f8                	mov    %edi,%eax
  801ce7:	5b                   	pop    %ebx
  801ce8:	5e                   	pop    %esi
  801ce9:	5f                   	pop    %edi
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    

00801cec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	57                   	push   %edi
  801cf0:	56                   	push   %esi
  801cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cf7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cfa:	39 c6                	cmp    %eax,%esi
  801cfc:	73 35                	jae    801d33 <memmove+0x47>
  801cfe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d01:	39 d0                	cmp    %edx,%eax
  801d03:	73 2e                	jae    801d33 <memmove+0x47>
		s += n;
		d += n;
  801d05:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d08:	89 d6                	mov    %edx,%esi
  801d0a:	09 fe                	or     %edi,%esi
  801d0c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d12:	75 13                	jne    801d27 <memmove+0x3b>
  801d14:	f6 c1 03             	test   $0x3,%cl
  801d17:	75 0e                	jne    801d27 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d19:	83 ef 04             	sub    $0x4,%edi
  801d1c:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d1f:	c1 e9 02             	shr    $0x2,%ecx
  801d22:	fd                   	std    
  801d23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d25:	eb 09                	jmp    801d30 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d27:	83 ef 01             	sub    $0x1,%edi
  801d2a:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d2d:	fd                   	std    
  801d2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d30:	fc                   	cld    
  801d31:	eb 1d                	jmp    801d50 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d33:	89 f2                	mov    %esi,%edx
  801d35:	09 c2                	or     %eax,%edx
  801d37:	f6 c2 03             	test   $0x3,%dl
  801d3a:	75 0f                	jne    801d4b <memmove+0x5f>
  801d3c:	f6 c1 03             	test   $0x3,%cl
  801d3f:	75 0a                	jne    801d4b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d41:	c1 e9 02             	shr    $0x2,%ecx
  801d44:	89 c7                	mov    %eax,%edi
  801d46:	fc                   	cld    
  801d47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d49:	eb 05                	jmp    801d50 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d4b:	89 c7                	mov    %eax,%edi
  801d4d:	fc                   	cld    
  801d4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d50:	5e                   	pop    %esi
  801d51:	5f                   	pop    %edi
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    

00801d54 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d57:	ff 75 10             	pushl  0x10(%ebp)
  801d5a:	ff 75 0c             	pushl  0xc(%ebp)
  801d5d:	ff 75 08             	pushl  0x8(%ebp)
  801d60:	e8 87 ff ff ff       	call   801cec <memmove>
}
  801d65:	c9                   	leave  
  801d66:	c3                   	ret    

00801d67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	56                   	push   %esi
  801d6b:	53                   	push   %ebx
  801d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d72:	89 c6                	mov    %eax,%esi
  801d74:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d77:	eb 1a                	jmp    801d93 <memcmp+0x2c>
		if (*s1 != *s2)
  801d79:	0f b6 08             	movzbl (%eax),%ecx
  801d7c:	0f b6 1a             	movzbl (%edx),%ebx
  801d7f:	38 d9                	cmp    %bl,%cl
  801d81:	74 0a                	je     801d8d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d83:	0f b6 c1             	movzbl %cl,%eax
  801d86:	0f b6 db             	movzbl %bl,%ebx
  801d89:	29 d8                	sub    %ebx,%eax
  801d8b:	eb 0f                	jmp    801d9c <memcmp+0x35>
		s1++, s2++;
  801d8d:	83 c0 01             	add    $0x1,%eax
  801d90:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d93:	39 f0                	cmp    %esi,%eax
  801d95:	75 e2                	jne    801d79 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d9c:	5b                   	pop    %ebx
  801d9d:	5e                   	pop    %esi
  801d9e:	5d                   	pop    %ebp
  801d9f:	c3                   	ret    

00801da0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	53                   	push   %ebx
  801da4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801da7:	89 c1                	mov    %eax,%ecx
  801da9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801dac:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801db0:	eb 0a                	jmp    801dbc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801db2:	0f b6 10             	movzbl (%eax),%edx
  801db5:	39 da                	cmp    %ebx,%edx
  801db7:	74 07                	je     801dc0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801db9:	83 c0 01             	add    $0x1,%eax
  801dbc:	39 c8                	cmp    %ecx,%eax
  801dbe:	72 f2                	jb     801db2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dc0:	5b                   	pop    %ebx
  801dc1:	5d                   	pop    %ebp
  801dc2:	c3                   	ret    

00801dc3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	57                   	push   %edi
  801dc7:	56                   	push   %esi
  801dc8:	53                   	push   %ebx
  801dc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dcf:	eb 03                	jmp    801dd4 <strtol+0x11>
		s++;
  801dd1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dd4:	0f b6 01             	movzbl (%ecx),%eax
  801dd7:	3c 20                	cmp    $0x20,%al
  801dd9:	74 f6                	je     801dd1 <strtol+0xe>
  801ddb:	3c 09                	cmp    $0x9,%al
  801ddd:	74 f2                	je     801dd1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ddf:	3c 2b                	cmp    $0x2b,%al
  801de1:	75 0a                	jne    801ded <strtol+0x2a>
		s++;
  801de3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801de6:	bf 00 00 00 00       	mov    $0x0,%edi
  801deb:	eb 11                	jmp    801dfe <strtol+0x3b>
  801ded:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801df2:	3c 2d                	cmp    $0x2d,%al
  801df4:	75 08                	jne    801dfe <strtol+0x3b>
		s++, neg = 1;
  801df6:	83 c1 01             	add    $0x1,%ecx
  801df9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dfe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e04:	75 15                	jne    801e1b <strtol+0x58>
  801e06:	80 39 30             	cmpb   $0x30,(%ecx)
  801e09:	75 10                	jne    801e1b <strtol+0x58>
  801e0b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e0f:	75 7c                	jne    801e8d <strtol+0xca>
		s += 2, base = 16;
  801e11:	83 c1 02             	add    $0x2,%ecx
  801e14:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e19:	eb 16                	jmp    801e31 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e1b:	85 db                	test   %ebx,%ebx
  801e1d:	75 12                	jne    801e31 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e1f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e24:	80 39 30             	cmpb   $0x30,(%ecx)
  801e27:	75 08                	jne    801e31 <strtol+0x6e>
		s++, base = 8;
  801e29:	83 c1 01             	add    $0x1,%ecx
  801e2c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e31:	b8 00 00 00 00       	mov    $0x0,%eax
  801e36:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e39:	0f b6 11             	movzbl (%ecx),%edx
  801e3c:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e3f:	89 f3                	mov    %esi,%ebx
  801e41:	80 fb 09             	cmp    $0x9,%bl
  801e44:	77 08                	ja     801e4e <strtol+0x8b>
			dig = *s - '0';
  801e46:	0f be d2             	movsbl %dl,%edx
  801e49:	83 ea 30             	sub    $0x30,%edx
  801e4c:	eb 22                	jmp    801e70 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e4e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e51:	89 f3                	mov    %esi,%ebx
  801e53:	80 fb 19             	cmp    $0x19,%bl
  801e56:	77 08                	ja     801e60 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e58:	0f be d2             	movsbl %dl,%edx
  801e5b:	83 ea 57             	sub    $0x57,%edx
  801e5e:	eb 10                	jmp    801e70 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e60:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e63:	89 f3                	mov    %esi,%ebx
  801e65:	80 fb 19             	cmp    $0x19,%bl
  801e68:	77 16                	ja     801e80 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e6a:	0f be d2             	movsbl %dl,%edx
  801e6d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e70:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e73:	7d 0b                	jge    801e80 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e75:	83 c1 01             	add    $0x1,%ecx
  801e78:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e7c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e7e:	eb b9                	jmp    801e39 <strtol+0x76>

	if (endptr)
  801e80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e84:	74 0d                	je     801e93 <strtol+0xd0>
		*endptr = (char *) s;
  801e86:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e89:	89 0e                	mov    %ecx,(%esi)
  801e8b:	eb 06                	jmp    801e93 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e8d:	85 db                	test   %ebx,%ebx
  801e8f:	74 98                	je     801e29 <strtol+0x66>
  801e91:	eb 9e                	jmp    801e31 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e93:	89 c2                	mov    %eax,%edx
  801e95:	f7 da                	neg    %edx
  801e97:	85 ff                	test   %edi,%edi
  801e99:	0f 45 c2             	cmovne %edx,%eax
}
  801e9c:	5b                   	pop    %ebx
  801e9d:	5e                   	pop    %esi
  801e9e:	5f                   	pop    %edi
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    

00801ea1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	56                   	push   %esi
  801ea5:	53                   	push   %ebx
  801ea6:	8b 75 08             	mov    0x8(%ebp),%esi
  801ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801eaf:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801eb1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801eb6:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801eb9:	83 ec 0c             	sub    $0xc,%esp
  801ebc:	50                   	push   %eax
  801ebd:	e8 54 e4 ff ff       	call   800316 <sys_ipc_recv>

	if (from_env_store != NULL)
  801ec2:	83 c4 10             	add    $0x10,%esp
  801ec5:	85 f6                	test   %esi,%esi
  801ec7:	74 14                	je     801edd <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801ec9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	78 09                	js     801edb <ipc_recv+0x3a>
  801ed2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ed8:	8b 52 74             	mov    0x74(%edx),%edx
  801edb:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801edd:	85 db                	test   %ebx,%ebx
  801edf:	74 14                	je     801ef5 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ee1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ee6:	85 c0                	test   %eax,%eax
  801ee8:	78 09                	js     801ef3 <ipc_recv+0x52>
  801eea:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ef0:	8b 52 78             	mov    0x78(%edx),%edx
  801ef3:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	78 08                	js     801f01 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ef9:	a1 08 40 80 00       	mov    0x804008,%eax
  801efe:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f04:	5b                   	pop    %ebx
  801f05:	5e                   	pop    %esi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    

00801f08 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	57                   	push   %edi
  801f0c:	56                   	push   %esi
  801f0d:	53                   	push   %ebx
  801f0e:	83 ec 0c             	sub    $0xc,%esp
  801f11:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f14:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f1a:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f1c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f21:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f24:	ff 75 14             	pushl  0x14(%ebp)
  801f27:	53                   	push   %ebx
  801f28:	56                   	push   %esi
  801f29:	57                   	push   %edi
  801f2a:	e8 c4 e3 ff ff       	call   8002f3 <sys_ipc_try_send>

		if (err < 0) {
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	85 c0                	test   %eax,%eax
  801f34:	79 1e                	jns    801f54 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f36:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f39:	75 07                	jne    801f42 <ipc_send+0x3a>
				sys_yield();
  801f3b:	e8 07 e2 ff ff       	call   800147 <sys_yield>
  801f40:	eb e2                	jmp    801f24 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f42:	50                   	push   %eax
  801f43:	68 e0 26 80 00       	push   $0x8026e0
  801f48:	6a 49                	push   $0x49
  801f4a:	68 ed 26 80 00       	push   $0x8026ed
  801f4f:	e8 a8 f5 ff ff       	call   8014fc <_panic>
		}

	} while (err < 0);

}
  801f54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f57:	5b                   	pop    %ebx
  801f58:	5e                   	pop    %esi
  801f59:	5f                   	pop    %edi
  801f5a:	5d                   	pop    %ebp
  801f5b:	c3                   	ret    

00801f5c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f5c:	55                   	push   %ebp
  801f5d:	89 e5                	mov    %esp,%ebp
  801f5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f62:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f67:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f6a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f70:	8b 52 50             	mov    0x50(%edx),%edx
  801f73:	39 ca                	cmp    %ecx,%edx
  801f75:	75 0d                	jne    801f84 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f77:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f7a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f7f:	8b 40 48             	mov    0x48(%eax),%eax
  801f82:	eb 0f                	jmp    801f93 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f84:	83 c0 01             	add    $0x1,%eax
  801f87:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f8c:	75 d9                	jne    801f67 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f93:	5d                   	pop    %ebp
  801f94:	c3                   	ret    

00801f95 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9b:	89 d0                	mov    %edx,%eax
  801f9d:	c1 e8 16             	shr    $0x16,%eax
  801fa0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fa7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fac:	f6 c1 01             	test   $0x1,%cl
  801faf:	74 1d                	je     801fce <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fb1:	c1 ea 0c             	shr    $0xc,%edx
  801fb4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fbb:	f6 c2 01             	test   $0x1,%dl
  801fbe:	74 0e                	je     801fce <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc0:	c1 ea 0c             	shr    $0xc,%edx
  801fc3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fca:	ef 
  801fcb:	0f b7 c0             	movzwl %ax,%eax
}
  801fce:	5d                   	pop    %ebp
  801fcf:	c3                   	ret    

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fed:	89 ca                	mov    %ecx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	75 3d                	jne    802030 <__udivdi3+0x60>
  801ff3:	39 cf                	cmp    %ecx,%edi
  801ff5:	0f 87 c5 00 00 00    	ja     8020c0 <__udivdi3+0xf0>
  801ffb:	85 ff                	test   %edi,%edi
  801ffd:	89 fd                	mov    %edi,%ebp
  801fff:	75 0b                	jne    80200c <__udivdi3+0x3c>
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	31 d2                	xor    %edx,%edx
  802008:	f7 f7                	div    %edi
  80200a:	89 c5                	mov    %eax,%ebp
  80200c:	89 c8                	mov    %ecx,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f5                	div    %ebp
  802012:	89 c1                	mov    %eax,%ecx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	89 cf                	mov    %ecx,%edi
  802018:	f7 f5                	div    %ebp
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	77 74                	ja     8020a8 <__udivdi3+0xd8>
  802034:	0f bd fe             	bsr    %esi,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0x108>
  802040:	bb 20 00 00 00       	mov    $0x20,%ebx
  802045:	89 f9                	mov    %edi,%ecx
  802047:	89 c5                	mov    %eax,%ebp
  802049:	29 fb                	sub    %edi,%ebx
  80204b:	d3 e6                	shl    %cl,%esi
  80204d:	89 d9                	mov    %ebx,%ecx
  80204f:	d3 ed                	shr    %cl,%ebp
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e0                	shl    %cl,%eax
  802055:	09 ee                	or     %ebp,%esi
  802057:	89 d9                	mov    %ebx,%ecx
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 d5                	mov    %edx,%ebp
  80205f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802063:	d3 ed                	shr    %cl,%ebp
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e2                	shl    %cl,%edx
  802069:	89 d9                	mov    %ebx,%ecx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	89 d0                	mov    %edx,%eax
  802071:	89 ea                	mov    %ebp,%edx
  802073:	f7 f6                	div    %esi
  802075:	89 d5                	mov    %edx,%ebp
  802077:	89 c3                	mov    %eax,%ebx
  802079:	f7 64 24 0c          	mull   0xc(%esp)
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	72 10                	jb     802091 <__udivdi3+0xc1>
  802081:	8b 74 24 08          	mov    0x8(%esp),%esi
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e6                	shl    %cl,%esi
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	73 07                	jae    802094 <__udivdi3+0xc4>
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	75 03                	jne    802094 <__udivdi3+0xc4>
  802091:	83 eb 01             	sub    $0x1,%ebx
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 d8                	mov    %ebx,%eax
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	31 ff                	xor    %edi,%edi
  8020aa:	31 db                	xor    %ebx,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	f7 f7                	div    %edi
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 fa                	mov    %edi,%edx
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 ce                	cmp    %ecx,%esi
  8020da:	72 0c                	jb     8020e8 <__udivdi3+0x118>
  8020dc:	31 db                	xor    %ebx,%ebx
  8020de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020e2:	0f 87 34 ff ff ff    	ja     80201c <__udivdi3+0x4c>
  8020e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ed:	e9 2a ff ff ff       	jmp    80201c <__udivdi3+0x4c>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 d2                	test   %edx,%edx
  802119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f3                	mov    %esi,%ebx
  802123:	89 3c 24             	mov    %edi,(%esp)
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	75 1c                	jne    802148 <__umoddi3+0x48>
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	76 50                	jbe    802180 <__umoddi3+0x80>
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	f7 f7                	div    %edi
  802136:	89 d0                	mov    %edx,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	77 52                	ja     8021a0 <__umoddi3+0xa0>
  80214e:	0f bd ea             	bsr    %edx,%ebp
  802151:	83 f5 1f             	xor    $0x1f,%ebp
  802154:	75 5a                	jne    8021b0 <__umoddi3+0xb0>
  802156:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	39 0c 24             	cmp    %ecx,(%esp)
  802163:	0f 86 d7 00 00 00    	jbe    802240 <__umoddi3+0x140>
  802169:	8b 44 24 08          	mov    0x8(%esp),%eax
  80216d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	85 ff                	test   %edi,%edi
  802182:	89 fd                	mov    %edi,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 f0                	mov    %esi,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 c8                	mov    %ecx,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	eb 99                	jmp    802138 <__umoddi3+0x38>
  80219f:	90                   	nop
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 1c             	add    $0x1c,%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5f                   	pop    %edi
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	8b 34 24             	mov    (%esp),%esi
  8021b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	29 ef                	sub    %ebp,%edi
  8021bc:	d3 e0                	shl    %cl,%eax
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	d3 ea                	shr    %cl,%edx
  8021c4:	89 e9                	mov    %ebp,%ecx
  8021c6:	09 c2                	or     %eax,%edx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 14 24             	mov    %edx,(%esp)
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	89 c6                	mov    %eax,%esi
  8021e1:	d3 e3                	shl    %cl,%ebx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	09 d8                	or     %ebx,%eax
  8021ed:	89 d3                	mov    %edx,%ebx
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	f7 34 24             	divl   (%esp)
  8021f4:	89 d6                	mov    %edx,%esi
  8021f6:	d3 e3                	shl    %cl,%ebx
  8021f8:	f7 64 24 04          	mull   0x4(%esp)
  8021fc:	39 d6                	cmp    %edx,%esi
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	89 d1                	mov    %edx,%ecx
  802204:	89 c3                	mov    %eax,%ebx
  802206:	72 08                	jb     802210 <__umoddi3+0x110>
  802208:	75 11                	jne    80221b <__umoddi3+0x11b>
  80220a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80220e:	73 0b                	jae    80221b <__umoddi3+0x11b>
  802210:	2b 44 24 04          	sub    0x4(%esp),%eax
  802214:	1b 14 24             	sbb    (%esp),%edx
  802217:	89 d1                	mov    %edx,%ecx
  802219:	89 c3                	mov    %eax,%ebx
  80221b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80221f:	29 da                	sub    %ebx,%edx
  802221:	19 ce                	sbb    %ecx,%esi
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e0                	shl    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	09 d0                	or     %edx,%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	83 c4 1c             	add    $0x1c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 f9                	sub    %edi,%ecx
  802242:	19 d6                	sbb    %edx,%esi
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224c:	e9 18 ff ff ff       	jmp    802169 <__umoddi3+0x69>
